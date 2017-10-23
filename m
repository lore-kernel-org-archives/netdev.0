From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/7] ipv6: addrconf: add per netns perturbation in inet6_addr_hash()
Date: Mon, 23 Oct 2017 16:17:47 -0700
Message-ID: <20171023231751.29530-4-edumazet@google.com>
References: <20171023231751.29530-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:47010 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751330AbdJWXSD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 19:18:03 -0400
Received: by mail-it0-f67.google.com with SMTP id f187so7900538itb.1
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 16:18:03 -0700 (PDT)
In-Reply-To: <20171023231751.29530-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bring IPv6 in par with IPv4 :

- Use net_hash_mix() to spread addresses a bit more.
- Use 256 slots hash table instead of 16

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/addrconf.h |  2 +-
 net/ipv6/addrconf.c    | 16 +++++++++-------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index b8b16437c6d5bcb9c8b5c42b4f9c0161b477d605..15b5ffd7253d6088f2444ada5de99e4977e143ff 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -58,7 +58,7 @@ struct in6_validator_info {
 	struct netlink_ext_ack	*extack;
 };
 
-#define IN6_ADDR_HSIZE_SHIFT	4
+#define IN6_ADDR_HSIZE_SHIFT	8
 #define IN6_ADDR_HSIZE		(1 << IN6_ADDR_HSIZE_SHIFT)
 
 int addrconf_init(void);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c1a5028f394c75d347fe703573548fd617b5c142..d70d98122053652b4f4420786de8788c6c9385ff 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -950,9 +950,11 @@ ipv6_link_dev_addr(struct inet6_dev *idev, struct inet6_ifaddr *ifp)
 	list_add_tail_rcu(&ifp->if_list, p);
 }
 
-static u32 inet6_addr_hash(const struct in6_addr *addr)
+static u32 inet6_addr_hash(const struct net *net, const struct in6_addr *addr)
 {
-	return hash_32(ipv6_addr_hash(addr), IN6_ADDR_HSIZE_SHIFT);
+	u32 val = ipv6_addr_hash(addr) ^ net_hash_mix(net);
+
+	return hash_32(val, IN6_ADDR_HSIZE_SHIFT);
 }
 
 static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
@@ -973,7 +975,7 @@ static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 
 static int ipv6_add_addr_hash(struct net_device *dev, struct inet6_ifaddr *ifa)
 {
-	unsigned int hash = inet6_addr_hash(&ifa->addr);
+	unsigned int hash = inet6_addr_hash(dev_net(dev), &ifa->addr);
 	int err = 0;
 
 	spin_lock(&addrconf_hash_lock);
@@ -1838,8 +1840,8 @@ int ipv6_chk_addr_and_flags(struct net *net, const struct in6_addr *addr,
 			    const struct net_device *dev, int strict,
 			    u32 banned_flags)
 {
+	unsigned int hash = inet6_addr_hash(net, addr);
 	struct inet6_ifaddr *ifp;
-	unsigned int hash = inet6_addr_hash(addr);
 	u32 ifp_flags;
 
 	rcu_read_lock_bh();
@@ -1917,8 +1919,8 @@ EXPORT_SYMBOL(ipv6_chk_prefix);
 struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *addr,
 				     struct net_device *dev, int strict)
 {
+	unsigned int hash = inet6_addr_hash(net, addr);
 	struct inet6_ifaddr *ifp, *result = NULL;
-	unsigned int hash = inet6_addr_hash(addr);
 
 	rcu_read_lock_bh();
 	hlist_for_each_entry_rcu_bh(ifp, &inet6_addr_lst[hash], addr_lst) {
@@ -4242,9 +4244,9 @@ void if6_proc_exit(void)
 /* Check if address is a home address configured on any interface. */
 int ipv6_chk_home_addr(struct net *net, const struct in6_addr *addr)
 {
-	int ret = 0;
+	unsigned int hash = inet6_addr_hash(net, addr);
 	struct inet6_ifaddr *ifp = NULL;
-	unsigned int hash = inet6_addr_hash(addr);
+	int ret = 0;
 
 	rcu_read_lock_bh();
 	hlist_for_each_entry_rcu_bh(ifp, &inet6_addr_lst[hash], addr_lst) {
-- 
2.15.0.rc0.271.g36b669edcc-goog
