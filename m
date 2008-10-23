From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: FYI - TCP/IP thin stream latency
Date: Thu, 23 Oct 2008 15:22:17 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810231516220.7072@wrl-59.cs.helsinki.fi>
References: <20081016095518.749ae6e9@speedy> <20081022.221410.139436406.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1615253665-1224764537=:7072"
Cc: shemminger@vyatta.com, doug.leith@nuim.ie,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38855 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414AbYJWMWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 08:22:21 -0400
In-Reply-To: <20081022.221410.139436406.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1615253665-1224764537=:7072
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 22 Oct 2008, David Miller wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 16 Oct 2008 09:55:18 -0700
> 
> >          when retransmitting send full MTU (vs redoing only than send)
> 
> We already do this (partially), see tcp_retransmit_skb():
> 
> 	/* Collapse two adjacent packets if worthwhile and we can. */
> 	if (!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN) &&
> 	    (skb->len < (cur_mss >> 1)) &&
> 	    (!tcp_skb_is_last(sk, skb)) &&
> 	    (tcp_write_queue_next(sk, skb) != tcp_send_head(sk)) &&
> 	    (skb_shinfo(skb)->nr_frags == 0 &&
> 	     skb_shinfo(tcp_write_queue_next(sk, skb))->nr_frags == 0) &&
> 	    (tcp_skb_pcount(skb) == 1 &&
> 	     tcp_skb_pcount(tcp_write_queue_next(sk, skb)) == 1) &&
> 	    (sysctl_tcp_retrans_collapse != 0))
> 		tcp_retrans_try_collapse(sk, skb, cur_mss);
> 
> We'd need to make this thing loop until no further progress can be
> made.

Something along these lines...? It's not that trivial though to get
full MSS worth of contiguous area if SACK is enabled though, unless we 
make it include already sacked areas too.

--
[PATCH not-now :-)] tcp: collapse more than two on retransmission

I always had thought that collapsing up to two at a time was
intentional decision to avoid excessive processing if 1 byte
sized skbs are to be combined for a full mtu, and consecutive
retransmissions would make the size of the retransmittee
double each round anyway.

tcp_skb_is_last check is now provided by the loop.

I tried to make the order of tests bit more sensible to make
it break earlier for things which seem more common case
(in favor of TSO and SG, though latter is a restriction which
could be made less strict I think).

Barely compile tested.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |   98 ++++++++++++++++++++++++++++++------------------
 1 files changed, 61 insertions(+), 37 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e4c5ac9..99ee943 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1766,46 +1766,22 @@ u32 __tcp_select_window(struct sock *sk)
 	return window;
 }
 
-/* Attempt to collapse two adjacent SKB's during retransmission. */
-static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *skb,
-				     int mss_now)
+/* Collapses two adjacent SKB's during retransmission. */
+static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *next_skb = tcp_write_queue_next(sk, skb);
 	int skb_size, next_skb_size;
 	u16 flags;
 
-	/* The first test we must make is that neither of these two
-	 * SKB's are still referenced by someone else.
-	 */
-	if (skb_cloned(skb) || skb_cloned(next_skb))
-		return;
-
 	skb_size = skb->len;
 	next_skb_size = next_skb->len;
 	flags = TCP_SKB_CB(skb)->flags;
 
-	/* Also punt if next skb has been SACK'd. */
-	if (TCP_SKB_CB(next_skb)->sacked & TCPCB_SACKED_ACKED)
-		return;
-
-	/* Next skb is out of window. */
-	if (after(TCP_SKB_CB(next_skb)->end_seq, tcp_wnd_end(tp)))
-		return;
-
-	/* Punt if not enough space exists in the first SKB for
-	 * the data in the second, or the total combined payload
-	 * would exceed the MSS.
-	 */
-	if ((next_skb_size > skb_tailroom(skb)) ||
-	    ((skb_size + next_skb_size) > mss_now))
-		return;
-
 	BUG_ON(tcp_skb_pcount(skb) != 1 || tcp_skb_pcount(next_skb) != 1);
 
 	tcp_highest_sack_combine(sk, next_skb, skb);
 
-	/* Ok.	We will be able to collapse the packet. */
 	tcp_unlink_write_queue(next_skb, sk);
 
 	skb_copy_from_linear_data(next_skb, skb_put(skb, next_skb_size),
@@ -1847,6 +1823,64 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *skb,
 	sk_wmem_free_skb(sk, next_skb);
 }
 
+static int tcp_can_collapse(struct sock *sk, struct sk_buff *skb)
+{
+	if (tcp_skb_pcount(skb) > 1)
+		return 0;
+	/* Once recombining for SACK completes this check could be made
+	 * less strict by reusing those parts.
+	 */
+	if (skb_shinfo(skb)->nr_frags != 0)
+		return 0;
+	if (skb_cloned(skb))
+		return 0;
+	if (skb == tcp_send_head(sk))
+		return 0;
+	/* Some heurestics for collapsing over SACK'd could be invented */
+	if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
+		return 0;
+
+	return 1;
+}
+
+static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
+				     int space)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb = to, *tmp;
+	int first = 1;
+
+	if (!sysctl_tcp_retrans_collapse)
+		return;
+	if (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN)
+		return;
+
+	tcp_for_write_queue_from_safe(skb, tmp, sk) {
+		if (!tcp_can_collapse(sk, skb))
+			break;
+
+		space -= skb->len;
+
+		if (first) {
+			first = 0;
+			continue;
+		}
+
+		if (space < 0)
+			break;
+		/* Punt if not enough space exists in the first SKB for
+		 * the data in the second
+		 */
+		if (skb->len > skb_tailroom(to))
+			break;
+
+		if (after(TCP_SKB_CB(skb)->end_seq, tcp_wnd_end(tp)))
+			break;
+
+		tcp_collapse_retrans(sk, to);
+	}
+}
+
 /* Do a simple retransmit without using the backoff mechanisms in
  * tcp_timer. This is used for path mtu discovery.
  * The socket is already locked here.
@@ -1946,17 +1980,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 			return -ENOMEM; /* We'll try again later. */
 	}
 
-	/* Collapse two adjacent packets if worthwhile and we can. */
-	if (!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN) &&
-	    (skb->len < (cur_mss >> 1)) &&
-	    (!tcp_skb_is_last(sk, skb)) &&
-	    (tcp_write_queue_next(sk, skb) != tcp_send_head(sk)) &&
-	    (skb_shinfo(skb)->nr_frags == 0 &&
-	     skb_shinfo(tcp_write_queue_next(sk, skb))->nr_frags == 0) &&
-	    (tcp_skb_pcount(skb) == 1 &&
-	     tcp_skb_pcount(tcp_write_queue_next(sk, skb)) == 1) &&
-	    (sysctl_tcp_retrans_collapse != 0))
-		tcp_retrans_try_collapse(sk, skb, cur_mss);
+	tcp_retrans_try_collapse(sk, skb, cur_mss);
 
 	/* Some Solaris stacks overoptimize and ignore the FIN on a
 	 * retransmit when old data is attached.  So strip it off
-- 
1.5.2.2
k
---696208474-1615253665-1224764537=:7072--
