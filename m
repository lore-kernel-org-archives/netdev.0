From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/9] ipv6: user better hash for addrconf
Date: Wed, 17 Mar 2010 23:31:12 -0700
Message-ID: <20100318063123.092727548@vyatta.com>
References: <20100318063108.109693694@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:33119 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752974Ab0CRGgT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 02:36:19 -0400
Content-Disposition: inline; filename=ipv6-hash-addrconf.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing hash function has a couple of issues:
  * it is hardwired to 16 for IN6_ADDR_HSIZE
  * limited to 256 and callers using int
  * use jhash2 rather than some old BSD algorithm

No need for random seed since this is local only (based on assigned
addresses) table.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/ipv6/addrconf.c |   25 ++++++++-----------------
 1 file changed, 8 insertions(+), 17 deletions(-)

--- a/net/ipv6/addrconf.c	2010-03-15 16:10:23.890774242 -0700
+++ b/net/ipv6/addrconf.c	2010-03-15 16:10:24.489836390 -0700
@@ -573,23 +573,14 @@ ipv6_link_dev_addr(struct inet6_dev *ide
 	*ifap = ifp;
 }
 
-/*
- *	Hash function taken from net_alias.c
- */
-static u8 ipv6_addr_hash(const struct in6_addr *addr)
+static u32 ipv6_addr_hash(const struct in6_addr *addr)
 {
-	__u32 word;
-
 	/*
 	 * We perform the hash function over the last 64 bits of the address
 	 * This will include the IEEE address token on links that support it.
 	 */
-
-	word = (__force u32)(addr->s6_addr32[2] ^ addr->s6_addr32[3]);
-	word ^= (word >> 16);
-	word ^= (word >> 8);
-
-	return ((word ^ (word >> 4)) & 0x0f);
+	return jhash_2words(addr->s6_addr32[2],  addr->s6_addr32[3], 0)
+		& (IN6_ADDR_HSIZE - 1);
 }
 
 /* On success it returns ifp with increased reference count */
@@ -600,7 +591,7 @@ ipv6_add_addr(struct inet6_dev *idev, co
 {
 	struct inet6_ifaddr *ifa = NULL;
 	struct rt6_info *rt;
-	int hash;
+	unsigned int hash;
 	int err = 0;
 	int addr_type = ipv6_addr_type(addr);
 
@@ -1277,7 +1268,7 @@ int ipv6_chk_addr(struct net *net, struc
 {
 	struct inet6_ifaddr *ifp = NULL;
 	struct hlist_node *node;
-	u8 hash = ipv6_addr_hash(addr);
+	unsigned int hash = ipv6_addr_hash(addr);
 
 	rcu_read_lock_bh();
 	hlist_for_each_entry_rcu(ifp, node, &inet6_addr_lst[hash], addr_lst) {
@@ -1302,7 +1293,7 @@ int ipv6_chk_same_addr(struct net *net, 
 {
 	struct inet6_ifaddr *ifp;
 	struct hlist_node *node;
-	u8 hash = ipv6_addr_hash(addr);
+	unsigned int hash = ipv6_addr_hash(addr);
 
 	hlist_for_each_entry(ifp, node, &inet6_addr_lst[hash], addr_lst) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
@@ -1345,7 +1336,7 @@ struct inet6_ifaddr *ipv6_get_ifaddr(str
 {
 	struct inet6_ifaddr *ifp = NULL;
 	struct hlist_node *node;
-	u8 hash = ipv6_addr_hash(addr);
+	unsigned int hash = ipv6_addr_hash(addr);
 
 	rcu_read_lock_bh();
 	hlist_for_each_entry_rcu(ifp, node, &inet6_addr_lst[hash], addr_lst) {
@@ -3083,7 +3074,7 @@ int ipv6_chk_home_addr(struct net *net, 
 	int ret = 0;
 	struct inet6_ifaddr *ifp = NULL;
 	struct hlist_node *n;
-	u8 hash = ipv6_addr_hash(addr);
+	unsigned int hash = ipv6_addr_hash(addr);
 
 	rcu_read_lock_bh();
 	hlist_for_each_entry_rcu(ifp, n, &inet6_addr_lst[hash], addr_lst) {

-- 

