From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH net-next 1/2] net/ipv6/udp: Add encap_rcv support to IPv6 UDP
Date: Tue, 10 Apr 2012 22:20:47 -0400
Message-ID: <20120411022047.GA19124@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:46883 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759933Ab2DKCUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 22:20:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At present, UDP encapsulated protocols (like L2TP) are only able to use the
encap_rcv hook with UDP over IPv4.  This patch adds the same support for use
with UDP over IPv6.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
---
 net/ipv6/udp.c |   31 +++++++++++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 37b0699..4d7cd72 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -515,6 +515,37 @@ int udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto drop;
 
+	if (up->encap_type) {
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
+				UDP6_INC_STATS_BH(sock_net(sk),
+						  UDP_MIB_INDATAGRAMS,
+						  is_udplite);
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
