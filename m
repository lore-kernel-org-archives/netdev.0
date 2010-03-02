From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 07/12] ipv6: user better hash for addrconf
Date: Tue, 02 Mar 2010 15:32:50 -0800
Message-ID: <20100302234003.335370522@vyatta.com>
References: <20100302233243.259794027@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58949 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757761Ab0CBXrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 18:47:16 -0500
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
 net/ipv6/addrconf.c |   26 +++++++++-----------------
 1 file changed, 9 insertions(+), 17 deletions(-)

--- a/net/ipv6/addrconf.c	2010-03-02 14:33:59.033450885 -0800
+++ b/net/ipv6/addrconf.c	2010-03-02 14:34:41.516826671 -0800
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
@@ -3073,7 +3064,7 @@ int ipv6_chk_home_addr(struct net *net, 
 	int ret = 0;
 	struct inet6_ifaddr *ifp = NULL;
 	struct hlist_node *n;
-	u8 hash = ipv6_addr_hash(addr);
+	unsigned int hash = ipv6_addr_hash(addr);
 
 	rcu_read_lock_bh();
 	hlist_for_each_entry_rcu(ifp, n, &inet6_addr_lst[hash], addr_lst) {

-- 

