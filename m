From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] ip: report the original address of ICMP messages
Date: Tue, 23 Jun 2015 08:34:39 +0300
Message-ID: <1435037679-2304-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org, Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:41943 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753138AbbFWFfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2015 01:35:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ICMP messages can trigger ICMP and local errors. In this case
serr->port is 0 and starting from Linux 4.0 we do not return
the original target address to the error queue readers.
Add function to define which errors provide addr_offset.
With this fix my ping command is not silent anymore.

Fixes: c247f0534cc5 ("ip: fix error queue empty skb handling")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/ip_sockglue.c | 11 ++++++++++-
 net/ipv6/datagram.c    | 12 +++++++++++-
 2 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 7cfb089..6ddde89 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -432,6 +432,15 @@ void ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 port, u32 inf
 		kfree_skb(skb);
 }
 
+/* For some errors we have valid addr_offset even with zero payload and
+ * zero port. Also, addr_offset should be supported if port is set.
+ */
+static inline bool ipv4_datagram_support_addr(struct sock_exterr_skb *serr)
+{
+	return serr->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
+	       serr->ee.ee_origin == SO_EE_ORIGIN_LOCAL || serr->port;
+}
+
 /* IPv4 supports cmsg on all imcp errors and some timestamps
  *
  * Timestamp code paths do not initialize the fields expected by cmsg:
@@ -498,7 +507,7 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 
 	serr = SKB_EXT_ERR(skb);
 
-	if (sin && serr->port) {
+	if (sin && ipv4_datagram_support_addr(serr)) {
 		sin->sin_family = AF_INET;
 		sin->sin_addr.s_addr = *(__be32 *)(skb_network_header(skb) +
 						   serr->addr_offset);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 762a58c..62d908e 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -325,6 +325,16 @@ void ipv6_local_rxpmtu(struct sock *sk, struct flowi6 *fl6, u32 mtu)
 	kfree_skb(skb);
 }
 
+/* For some errors we have valid addr_offset even with zero payload and
+ * zero port. Also, addr_offset should be supported if port is set.
+ */
+static inline bool ipv6_datagram_support_addr(struct sock_exterr_skb *serr)
+{
+	return serr->ee.ee_origin == SO_EE_ORIGIN_ICMP6 ||
+	       serr->ee.ee_origin == SO_EE_ORIGIN_ICMP ||
+	       serr->ee.ee_origin == SO_EE_ORIGIN_LOCAL || serr->port;
+}
+
 /* IPv6 supports cmsg on all origins aside from SO_EE_ORIGIN_LOCAL.
  *
  * At one point, excluding local errors was a quick test to identify icmp/icmp6
@@ -389,7 +399,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 
 	serr = SKB_EXT_ERR(skb);
 
-	if (sin && serr->port) {
+	if (sin && ipv6_datagram_support_addr(serr)) {
 		const unsigned char *nh = skb_network_header(skb);
 		sin->sin6_family = AF_INET6;
 		sin->sin6_flowinfo = 0;
-- 
1.9.3
