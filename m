From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH 3/4] net/ipv6/udp: introduce encap_rcv hook into IPv6
Date: Wed, 18 Apr 2012 09:44:10 -0400
Message-ID: <20120418134410.GA5143@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:43605 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125Ab2DRNoK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Apr 2012 09:44:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the sematics of udpv6_queue_rcv_skb() match IPv4's
udp_queue_rcv_skb(), introduce the UDP encap_rcv() hook for IPv6.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 include/net/udp.h |    3 +++
 net/ipv6/udp.c    |   39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index e66fc29..065f379 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -268,4 +268,7 @@ extern int udp4_ufo_send_check(struct sk_buff *skb);
 extern struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 	netdev_features_t features);
 extern void udp_encap_enable(void);
+#if IS_ENABLED(CONFIG_IPV6)
+extern void udpv6_encap_enable(void);
+#endif
 #endif	/* _UDP_H */
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e507654..d3a486b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -525,6 +525,14 @@ static __inline__ void udpv6_err(struct sk_buff *skb,
 	__udp6_lib_err(skb, opt, type, code, offset, info, &udp_table);
 }
 
+static struct static_key udpv6_encap_needed __read_mostly;
+void udpv6_encap_enable(void)
+{
+	if (!static_key_enabled(&udpv6_encap_needed))
+		static_key_slow_inc(&udpv6_encap_needed);
+}
+EXPORT_SYMBOL(udpv6_encap_enable);
+
 int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_sock *up = udp_sk(sk);
@@ -534,6 +542,37 @@ int udpv6_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto drop;
 
+	if (static_key_false(&udpv6_encap_needed) && up->encap_type) {
+		int (*encap_rcv)(struct sock *sk, struct sk_buff *skb);
+
+		/*
+		 * This is an encapsulation socket so pass the skb to
+		 * the socket's udp_encap_rcv() hook. Otherwise, just
+		 * fall through and pass this up the UDP socket.
+		 * up->encap_rcv() returns the following value:
+		 * =0 if skb was successfully passed to the encap
+		 *    handler or was discarded by it.
+		 * >0 if skb should be passed on to UDP.
+		 * <0 if skb should be resubmitted as proto -N
+		 */
+
+		/* if we're overly short, let UDP handle it */
+		encap_rcv = ACCESS_ONCE(up->encap_rcv);
+		if (skb->len > sizeof(struct udphdr) && encap_rcv != NULL) {
+			int ret;
+
+			ret = encap_rcv(sk, skb);
+			if (ret <= 0) {
+				UDP_INC_STATS_BH(sock_net(sk),
+						 UDP_MIB_INDATAGRAMS,
+						 is_udplite);
+				return -ret;
+			}
+		}
+
+		/* FALLTHROUGH -- it's a UDP Packet */
+	}
+
 	/*
 	 * UDP-Lite specific tests, ignored on UDP sockets (see net/ipv4/udp.c).
 	 */
-- 
1.7.4.1


-- 
"Thought is the essence of where you are now."
