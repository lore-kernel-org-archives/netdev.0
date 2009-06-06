From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next 1/4] IPv6: HW csum support for outgoing large UFO
 packets
Date: Fri, 05 Jun 2009 17:16:27 -0700
Message-ID: <1244247387.1526.170.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, kvm@vger.kernel.org,
	herbert.xu@redhat.com, rusty@rustcorp.com.au
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add HW checksum support for outgoing large UDP/IPv6 packets destined to a UFO
enabled device.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---

 net/ipv6/udp.c |   51 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 50 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index fc333d8..fad0f5f 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -638,6 +638,47 @@ static void udp_v6_flush_pending_frames(struct sock *sk)
 	}
 }
 
+/**
+ * 	udp6_hwcsum_outgoing  -  handle outgoing HW checksumming
+ * 	@sk: 	socket we are sending on
+ * 	@skb: 	sk_buff containing the filled-in UDP header
+ * 	        (checksum field must be zeroed out)
+ */
+static void udp6_hwcsum_outgoing(struct sock *sk, struct sk_buff *skb,
+				 const struct in6_addr *saddr,
+				 const struct in6_addr *daddr, int len)
+{
+	unsigned int offset;
+	struct udphdr *uh = udp_hdr(skb);
+	__wsum csum = 0;
+
+	if (skb_queue_len(&sk->sk_write_queue) == 1) {
+		/* Only one fragment on the socket.  */
+		skb->csum_start = skb_transport_header(skb) - skb->head;
+		skb->csum_offset = offsetof(struct udphdr, check);
+		uh->check = csum_ipv6_magic(saddr, daddr, len, IPPROTO_UDP, 0);
+	} else {
+		/*
+		 * HW-checksum won't work as there are two or more
+		 * fragments on the socket so that all csums of sk_buffs
+		 * should be together
+		 */
+		offset = skb_transport_offset(skb);
+		skb->csum = skb_checksum(skb, offset, skb->len - offset, 0);
+
+		skb->ip_summed = CHECKSUM_NONE;
+
+		skb_queue_walk(&sk->sk_write_queue, skb) {
+			csum = csum_add(csum, skb->csum);
+		}
+
+		uh->check = csum_ipv6_magic(saddr, daddr, len, IPPROTO_UDP,
+					    csum);
+		if (uh->check == 0)
+			uh->check = CSUM_MANGLED_0;
+	}
+}
+
 /*
  *	Sending
  */
@@ -668,7 +709,14 @@ static int udp_v6_push_pending_frames(struct sock *sk)
 
 	if (is_udplite)
 		csum = udplite_csum_outgoing(sk, skb);
-	 else
+	 else if (sk->sk_no_check == UDP_CSUM_NOXMIT) {	/* UDP csum disabled */
+		skb->ip_summed = CHECKSUM_NONE;
+		goto send;
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL) { /* UDP hardware csum */
+		udp6_hwcsum_outgoing(sk, skb, &fl->fl6_src, &fl->fl6_dst,
+				     up->len);
+		goto send;
+	} else
 		csum = udp_csum_outgoing(sk, skb);
 
 	/* add protocol-dependent pseudo-header */
@@ -677,6 +725,7 @@ static int udp_v6_push_pending_frames(struct sock *sk)
 	if (uh->check == 0)
 		uh->check = CSUM_MANGLED_0;
 
+send:
 	err = ip6_push_pending_frames(sk);
 out:
 	up->len = 0;


