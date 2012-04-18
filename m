From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: avoid expensive pskb_expand_head() calls
Date: Wed, 18 Apr 2012 17:49:44 +0200
Message-ID: <1334764184.2472.299.camel@edumazet-glaptop>
References: <1334653608.6226.11.camel@edumazet-laptop>
	 <1334654187.2696.2.camel@jtkirshe-mobl>  <4F8D93E1.9090000@intel.com>
	 <1334681204.2472.41.camel@edumazet-glaptop>
	 <1334698722.2472.71.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58316 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320Ab2DRPtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 11:49:50 -0400
Received: by bkcik5 with SMTP id ik5so5611980bkc.19
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 08:49:48 -0700 (PDT)
In-Reply-To: <1334698722.2472.71.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

While doing netperf sessions on 10Gb Intel nics (ixgbe), I noticed
unexpected profiling results, with pskb_expand_head() being in the top.

After further analysis, I found we hit badly page refcounts,
because when we transmit full size skb (64 KB), we can receive ACK for
the first segments of the frame while skb was not completely sent by
NIC.

It takes ~54 us to send a full TSO packet at 10Gb speed, but with a
close peer, we can receive TCP ACK in less than 50 us rtt.

This is also true on 1Gb links but we were limited by wire speed, not
cpu.

When we try to trim skb, tcp_trim_head() has to call pskb_expand_head()=
,
because the skb clone we did for transmit is still alive in TX ring
buffer.

pskb_expand_head() is really expensive : It has to make about 16+16
atomic operations on page refcounts, not counting the skb head
reallocation/copy. It increases chances of false sharing.

In fact, we dont really need to trim skb. This costly operation can be
delayed to the point it is really needed : Thats when a retransmit must
happen.

Most of the time, upcoming ACKS will ack the whole packet, and we can
free it with minimal cost (since clone was already freed by TX
completion)

Of course, this means we dont uncharge the acked part from socket limit=
s
until retransmit, but this is hardly a concern with current autotuning
(around 4MB per socket)
Even with small cwnd limit, a single packet can not hold more than half
the window.

Performance results on my Q6600 cpu and 82599EB 10-Gigabit card :
About 3% less cpu used for same workload (single netperf TCP_STREAM),
bounded by x4 PCI-e slots (4660 Mbits).

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 include/net/tcp.h     |    6 ++++--
 net/ipv4/tcp_input.c  |   24 +++++++++++++-----------
 net/ipv4/tcp_output.c |   17 +++++++++++------
 3 files changed, 28 insertions(+), 19 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index d5984e3..0f57706 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -477,7 +477,8 @@ extern int tcp_retransmit_skb(struct sock *, struct=
 sk_buff *);
 extern void tcp_retransmit_timer(struct sock *sk);
 extern void tcp_xmit_retransmit_queue(struct sock *);
 extern void tcp_simple_retransmit(struct sock *);
-extern int tcp_trim_head(struct sock *, struct sk_buff *, u32);
+extern void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff=
 *skb,
+				 unsigned int mss_now);
 extern int tcp_fragment(struct sock *, struct sk_buff *, u32, unsigned=
 int);
=20
 extern void tcp_send_probe0(struct sock *);
@@ -640,7 +641,8 @@ struct tcp_skb_cb {
 #if IS_ENABLED(CONFIG_IPV6)
 		struct inet6_skb_parm	h6;
 #endif
-	} header;	/* For incoming frames		*/
+		unsigned int offset_ack; /* part of acked data in this skb */
+	} header;
 	__u32		seq;		/* Starting sequence number	*/
 	__u32		end_seq;	/* SEQ + FIN + SYN + datalen	*/
 	__u32		when;		/* used to compute rtt's	*/
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 99448f0..529740c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3260,25 +3260,27 @@ static void tcp_rearm_rto(struct sock *sk)
 	}
 }
=20
-/* If we get here, the whole TSO packet has not been acked. */
+/* If we get here, the whole packet has not been acked.
+ * We used to call tcp_trim_head() to remove acked data from skb,
+ * but its expensive with TSO if our previous clone is still in flight=
=2E
+ * We thus maintain an offset_ack, and hope no pskb_expand_head()
+ * is needed until whole packet is acked by upcoming ACKs.
+ */
 static u32 tcp_tso_acked(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
-	u32 packets_acked;
+	u32 prev_packets_acked;
=20
 	BUG_ON(!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una));
=20
-	packets_acked =3D tcp_skb_pcount(skb);
-	if (tcp_trim_head(sk, skb, tp->snd_una - TCP_SKB_CB(skb)->seq))
-		return 0;
-	packets_acked -=3D tcp_skb_pcount(skb);
+	prev_packets_acked =3D tcp_skb_pcount(skb);
=20
-	if (packets_acked) {
-		BUG_ON(tcp_skb_pcount(skb) =3D=3D 0);
-		BUG_ON(!before(TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq));
-	}
+	TCP_SKB_CB(skb)->header.offset_ack =3D tp->snd_una - TCP_SKB_CB(skb)-=
>seq;
+
+	if (tcp_skb_pcount(skb) > 1)
+		tcp_set_skb_tso_segs(sk, skb, tcp_skb_mss(skb));
=20
-	return packets_acked;
+	return prev_packets_acked - tcp_skb_pcount(skb);
 }
=20
 /* Remove acknowledged frames from the retransmission queue. If our pa=
cket
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index de8790c..426b400 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -927,11 +927,15 @@ static void tcp_queue_skb(struct sock *sk, struct=
 sk_buff *skb)
 	sk_mem_charge(sk, skb->truesize);
 }
=20
-/* Initialize TSO segments for a packet. */
-static void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff=
 *skb,
-				 unsigned int mss_now)
+/* Initialize TSO segments for a packet.
+ * Part of skb (offset_ack) might have been acked.
+ */
+void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff *skb,
+			  unsigned int mss_now)
 {
-	if (skb->len <=3D mss_now || !sk_can_gso(sk) ||
+	unsigned int len =3D skb->len - TCP_SKB_CB(skb)->header.offset_ack;
+
+	if (len <=3D mss_now || !sk_can_gso(sk) ||
 	    skb->ip_summed =3D=3D CHECKSUM_NONE) {
 		/* Avoid the costly divide in the normal
 		 * non-TSO case.
@@ -940,7 +944,7 @@ static void tcp_set_skb_tso_segs(const struct sock =
*sk, struct sk_buff *skb,
 		skb_shinfo(skb)->gso_size =3D 0;
 		skb_shinfo(skb)->gso_type =3D 0;
 	} else {
-		skb_shinfo(skb)->gso_segs =3D DIV_ROUND_UP(skb->len, mss_now);
+		skb_shinfo(skb)->gso_segs =3D DIV_ROUND_UP(len, mss_now);
 		skb_shinfo(skb)->gso_size =3D mss_now;
 		skb_shinfo(skb)->gso_type =3D sk->sk_gso_type;
 	}
@@ -1126,7 +1130,7 @@ static void __pskb_trim_head(struct sk_buff *skb,=
 int len)
 }
=20
 /* Remove acked data from a packet in the transmit queue. */
-int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
+static int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len=
)
 {
 	if (skb_cloned(skb) && pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 		return -ENOMEM;
@@ -1134,6 +1138,7 @@ int tcp_trim_head(struct sock *sk, struct sk_buff=
 *skb, u32 len)
 	__pskb_trim_head(skb, len);
=20
 	TCP_SKB_CB(skb)->seq +=3D len;
+	TCP_SKB_CB(skb)->header.offset_ack =3D 0;
 	skb->ip_summed =3D CHECKSUM_PARTIAL;
=20
 	skb->truesize	     -=3D len;
