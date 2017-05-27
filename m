From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 2/9] net: ipv4: Add extack message for invalid prefix or length
Date: Sat, 27 May 2017 16:19:26 -0600
Message-ID: <20170527221933.57644-3-dsahern@gmail.com>
References: <20170527221933.57644-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33708 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750781AbdE0WTm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 18:19:42 -0400
Received: by mail-pg0-f66.google.com with SMTP id s62so2469466pgc.0
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 15:19:42 -0700 (PDT)
In-Reply-To: <20170527221933.57644-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add extack error message for invalid prefix length and invalid prefix.
Example of the latter is a route spec containing 172.16.100.1/24, where
the /24 mask means the lower 8-bits should be 0. Amazing how easy that
one is to overlook when an EINVAL is returned.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/ip_fib.h    |  3 ++-
 net/ipv4/fib_frontend.c |  7 ++++---
 net/ipv4/fib_trie.c     | 17 +++++++++++------
 3 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 25f5c516afd1..c3fa1f0438c1 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -266,7 +266,8 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		     struct fib_result *res, int fib_flags);
 int fib_table_insert(struct net *, struct fib_table *, struct fib_config *,
 		     struct netlink_ext_ack *extack);
-int fib_table_delete(struct net *, struct fib_table *, struct fib_config *);
+int fib_table_delete(struct net *, struct fib_table *, struct fib_config *,
+		     struct netlink_ext_ack *extack);
 int fib_table_dump(struct fib_table *table, struct sk_buff *skb,
 		   struct netlink_callback *cb);
 int fib_table_flush(struct net *net, struct fib_table *table);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 14d2f7bd7c76..715b7967d8ea 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -588,7 +588,8 @@ int ip_rt_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 			if (cmd == SIOCDELRT) {
 				tb = fib_get_table(net, cfg.fc_table);
 				if (tb)
-					err = fib_table_delete(net, tb, &cfg);
+					err = fib_table_delete(net, tb, &cfg,
+							       NULL);
 				else
 					err = -ESRCH;
 			} else {
@@ -732,7 +733,7 @@ static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh,
 		goto errout;
 	}
 
-	err = fib_table_delete(net, tb, &cfg);
+	err = fib_table_delete(net, tb, &cfg, extack);
 errout:
 	return err;
 }
@@ -851,7 +852,7 @@ static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifad
 	if (cmd == RTM_NEWROUTE)
 		fib_table_insert(net, tb, &cfg, NULL);
 	else
-		fib_table_delete(net, tb, &cfg);
+		fib_table_delete(net, tb, &cfg, NULL);
 }
 
 void fib_add_ifaddr(struct in_ifaddr *ifa)
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 9bd46e1e1037..a624d380c81d 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1099,13 +1099,18 @@ static int fib_insert_alias(struct trie *t, struct key_vector *tp,
 	return 0;
 }
 
-static bool fib_valid_key_len(u32 key, u8 plen)
+static bool fib_valid_key_len(u32 key, u8 plen, struct netlink_ext_ack *extack)
 {
-	if (plen > KEYLENGTH)
+	if (plen > KEYLENGTH) {
+		NL_SET_ERR_MSG(extack, "Invalid prefix length");
 		return false;
+	}
 
-	if ((plen < KEYLENGTH) && (key << plen))
+	if ((plen < KEYLENGTH) && (key << plen)) {
+		NL_SET_ERR_MSG(extack,
+			       "Invalid prefix for given prefix length");
 		return false;
+	}
 
 	return true;
 }
@@ -1128,7 +1133,7 @@ int fib_table_insert(struct net *net, struct fib_table *tb,
 
 	key = ntohl(cfg->fc_dst);
 
-	if (!fib_valid_key_len(key, plen))
+	if (!fib_valid_key_len(key, plen, extack))
 		return -EINVAL;
 
 	pr_debug("Insert table=%u %08x/%d\n", tb->tb_id, key, plen);
@@ -1516,7 +1521,7 @@ static void fib_remove_alias(struct trie *t, struct key_vector *tp,
 
 /* Caller must hold RTNL. */
 int fib_table_delete(struct net *net, struct fib_table *tb,
-		     struct fib_config *cfg)
+		     struct fib_config *cfg, struct netlink_ext_ack *extack)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	struct fib_alias *fa, *fa_to_delete;
@@ -1528,7 +1533,7 @@ int fib_table_delete(struct net *net, struct fib_table *tb,
 
 	key = ntohl(cfg->fc_dst);
 
-	if (!fib_valid_key_len(key, plen))
+	if (!fib_valid_key_len(key, plen, extack))
 		return -EINVAL;
 
 	l = fib_find_node(t, &tp, key);
-- 
2.11.0 (Apple Git-81)
