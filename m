From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 2/5] xfrm: Use ipv6_addr_equal() where appropriate.
Date: Wed, 30 Jan 2013 07:48:31 +0900
Message-ID: <510851BF.6090502@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:54620 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751690Ab3A2Wsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 17:48:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/xfrm.h      |   13 ++++++++++---
 net/ipv6/xfrm6_tunnel.c |    4 ++--
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 421f764..0d8a797 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1032,7 +1032,7 @@ static inline int
 __xfrm6_state_addr_cmp(const struct xfrm_tmpl *tmpl, const struct xfrm_state *x)
 {
 	return	(!ipv6_addr_any((struct in6_addr*)&tmpl->saddr) &&
-		 ipv6_addr_cmp((struct in6_addr *)&tmpl->saddr, (struct in6_addr*)&x->props.saddr));
+		 !ipv6_addr_equal((struct in6_addr *)&tmpl->saddr, (struct in6_addr*)&x->props.saddr));
 }
 
 static inline int
@@ -1243,8 +1243,8 @@ static __inline__ int
 __xfrm6_state_addr_check(const struct xfrm_state *x,
 			 const xfrm_address_t *daddr, const xfrm_address_t *saddr)
 {
-	if (!ipv6_addr_cmp((struct in6_addr *)daddr, (struct in6_addr *)&x->id.daddr) &&
-	    (!ipv6_addr_cmp((struct in6_addr *)saddr, (struct in6_addr *)&x->props.saddr)|| 
+	if (ipv6_addr_equal((struct in6_addr *)daddr, (struct in6_addr *)&x->id.daddr) &&
+	    (ipv6_addr_equal((struct in6_addr *)saddr, (struct in6_addr *)&x->props.saddr) ||
 	     ipv6_addr_any((struct in6_addr *)saddr) || 
 	     ipv6_addr_any((struct in6_addr *)&x->props.saddr)))
 		return 1;
@@ -1588,6 +1588,13 @@ static inline int xfrm_addr_cmp(const xfrm_address_t *a,
 	}
 }
 
+static inline bool xfrm6_addr_equal(const xfrm_address_t *a,
+				    const xfrm_address_t *b)
+{
+	return ipv6_addr_equal((const struct in6_addr *)a,
+			       (const struct in6_addr *)b);
+}
+
 static inline int xfrm_policy_id2dir(u32 index)
 {
 	return index & 7;
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index babd167..6cc4801 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -94,7 +94,7 @@ static struct xfrm6_tunnel_spi *__xfrm6_tunnel_spi_lookup(struct net *net, const
 	hlist_for_each_entry_rcu(x6spi, pos,
 			     &xfrm6_tn->spi_byaddr[xfrm6_tunnel_spi_hash_byaddr(saddr)],
 			     list_byaddr) {
-		if (memcmp(&x6spi->addr, saddr, sizeof(x6spi->addr)) == 0)
+		if (xfrm6_addr_equal(&x6spi->addr, saddr))
 			return x6spi;
 	}
 
@@ -211,7 +211,7 @@ static void xfrm6_tunnel_free_spi(struct net *net, xfrm_address_t *saddr)
 				  &xfrm6_tn->spi_byaddr[xfrm6_tunnel_spi_hash_byaddr(saddr)],
 				  list_byaddr)
 	{
-		if (memcmp(&x6spi->addr, saddr, sizeof(x6spi->addr)) == 0) {
+		if (xfrm6_addr_equal(&x6spi->addr, saddr)) {
 			if (atomic_dec_and_test(&x6spi->refcnt)) {
 				hlist_del_rcu(&x6spi->list_byaddr);
 				hlist_del_rcu(&x6spi->list_byspi);
-- 
1.7.9.5
