From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/3][NETLABEL]: Don't produce unused variables when IPv6 is
 off.
Date: Thu, 07 Feb 2008 20:24:15 +0300
Message-ID: <47AB3EBF.2090300@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53562 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756242AbYBGRYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2008 12:24:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some code declares variables on the stack, but uses them
under #ifdef CONFIG_IPV6, so thay become unused when ipv6
is off. Fortunately, they are used in a switch's case
branches, so the fix is rather simple.

Is it OK from coding style POV to add braces inside "cases",
or should I better avoid such style and rework the patch?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/netlabel/netlabel_unlabeled.c |   28 ++++++++++++++++++----------
 1 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 42e81fd..3587874 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -617,8 +617,6 @@ static int netlbl_unlhsh_add(struct net *net,
 	int ifindex;
 	struct net_device *dev;
 	struct netlbl_unlhsh_iface *iface;
-	struct in_addr *addr4, *mask4;
-	struct in6_addr *addr6, *mask6;
 	struct audit_buffer *audit_buf = NULL;
 	char *secctx = NULL;
 	u32 secctx_len;
@@ -651,7 +649,9 @@ static int netlbl_unlhsh_add(struct net *net,
 	audit_buf = netlbl_audit_start_common(AUDIT_MAC_UNLBL_STCADD,
 					      audit_info);
 	switch (addr_len) {
-	case sizeof(struct in_addr):
+	case sizeof(struct in_addr): {
+		struct in_addr *addr4, *mask4;
+
 		addr4 = (struct in_addr *)addr;
 		mask4 = (struct in_addr *)mask;
 		ret_val = netlbl_unlhsh_add_addr4(iface, addr4, mask4, secid);
@@ -661,8 +661,11 @@ static int netlbl_unlhsh_add(struct net *net,
 						   addr4->s_addr,
 						   mask4->s_addr);
 		break;
+	}
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	case sizeof(struct in6_addr):
+	case sizeof(struct in6_addr): {
+		struct in6_addr *addr6, *mask6;
+
 		addr6 = (struct in6_addr *)addr;
 		mask6 = (struct in6_addr *)mask;
 		ret_val = netlbl_unlhsh_add_addr6(iface, addr6, mask6, secid);
@@ -671,6 +674,7 @@ static int netlbl_unlhsh_add(struct net *net,
 						   dev_name,
 						   addr6, mask6);
 		break;
+	}
 #endif /* IPv6 */
 	default:
 		ret_val = -EINVAL;
@@ -1741,10 +1745,6 @@ int netlbl_unlabel_getattr(const struct sk_buff *skb,
 			   u16 family,
 			   struct netlbl_lsm_secattr *secattr)
 {
-	struct iphdr *hdr4;
-	struct ipv6hdr *hdr6;
-	struct netlbl_unlhsh_addr4 *addr4;
-	struct netlbl_unlhsh_addr6 *addr6;
 	struct netlbl_unlhsh_iface *iface;
 
 	rcu_read_lock();
@@ -1752,21 +1752,29 @@ int netlbl_unlabel_getattr(const struct sk_buff *skb,
 	if (iface == NULL)
 		goto unlabel_getattr_nolabel;
 	switch (family) {
-	case PF_INET:
+	case PF_INET: {
+		struct iphdr *hdr4;
+		struct netlbl_unlhsh_addr4 *addr4;
+
 		hdr4 = ip_hdr(skb);
 		addr4 = netlbl_unlhsh_search_addr4(hdr4->saddr, iface);
 		if (addr4 == NULL)
 			goto unlabel_getattr_nolabel;
 		secattr->attr.secid = addr4->secid;
 		break;
+	}
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-	case PF_INET6:
+	case PF_INET6: {
+		struct ipv6hdr *hdr6;
+		struct netlbl_unlhsh_addr6 *addr6;
+
 		hdr6 = ipv6_hdr(skb);
 		addr6 = netlbl_unlhsh_search_addr6(&hdr6->saddr, iface);
 		if (addr6 == NULL)
 			goto unlabel_getattr_nolabel;
 		secattr->attr.secid = addr6->secid;
 		break;
+	}
 #endif /* IPv6 */
 	default:
 		goto unlabel_getattr_nolabel;
-- 
1.5.3.4

