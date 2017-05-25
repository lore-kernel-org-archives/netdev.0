From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 1/6] net: ipv4: Add extack message for invalid prefix or length
Date: Wed, 24 May 2017 21:54:37 -0600
Message-ID: <20170525035442.51407-2-dsahern@gmail.com>
References: <20170525035442.51407-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34498 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941523AbdEYDyu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 23:54:50 -0400
Received: by mail-pf0-f193.google.com with SMTP id w69so36353640pfk.1
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 20:54:49 -0700 (PDT)
In-Reply-To: <20170525035442.51407-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add extack error message for invalid prefix length and invalid prefix.
Example of the latter is a route spec containing 172.16.100.1/24, where
the /24 mask means the lower 8-bits should be 0. Amazing how easy that
one is to overlook when an EINVAL is returned.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/ip_fib.h    |  3 ++-
 net/ipv4/fib_frontend.c |  6 +++---
 net/ipv4/fib_trie.c     | 20 +++++++++++++++-----
 3 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 42e8b8f55f7c..d490a0f8dc4c 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -265,7 +265,8 @@ int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
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
index 14d2f7bd7c76..2d55882d566e 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -588,7 +588,7 @@ int ip_rt_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 			if (cmd == SIOCDELRT) {
 				tb = fib_get_table(net, cfg.fc_table);
 				if (tb)
-					err = fib_table_delete(net, tb, &cfg);
+					err = fib_table_delete(net, tb, &cfg, NULL);
 				else
 					err = -ESRCH;
 			} else {
@@ -732,7 +732,7 @@ static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh,
 		goto errout;
 	}
 
-	err = fib_table_delete(net, tb, &cfg);
+	err = fib_table_delete(net, tb, &cfg, extack);
 errout:
 	return err;
 }
@@ -851,7 +851,7 @@ static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifad
 	if (cmd == RTM_NEWROUTE)
 		fib_table_insert(net, tb, &cfg, NULL);
 	else
-		fib_table_delete(net, tb, &cfg);
+		fib_table_delete(net, tb, &cfg, NULL);
 }
 
 void fib_add_ifaddr(struct in_ifaddr *ifa)
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 6d0f6c79d9aa..015ff759b0fd 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1115,15 +1115,20 @@ int fib_table_insert(struct net *net, struct fib_table *tb,
 	u32 key;
 	int err;
 
-	if (plen > KEYLENGTH)
+	if (plen > KEYLENGTH) {
+		NL_SET_ERR_MSG(extack, "Invalid prefix length");
 		return -EINVAL;
+	}
 
 	key = ntohl(cfg->fc_dst);
 
 	pr_debug("Insert table=%u %08x/%d\n", tb->tb_id, key, plen);
 
-	if ((plen < KEYLENGTH) && (key << plen))
+	if ((plen < KEYLENGTH) && (key << plen)) {
+		NL_SET_ERR_MSG(extack,
+			       "Invalid prefix for given prefix length");
 		return -EINVAL;
+	}
 
 	fi = fib_create_info(cfg, extack);
 	if (IS_ERR(fi)) {
@@ -1507,7 +1512,7 @@ static void fib_remove_alias(struct trie *t, struct key_vector *tp,
 
 /* Caller must hold RTNL. */
 int fib_table_delete(struct net *net, struct fib_table *tb,
-		     struct fib_config *cfg)
+		     struct fib_config *cfg, struct netlink_ext_ack *extack)
 {
 	struct trie *t = (struct trie *) tb->tb_data;
 	struct fib_alias *fa, *fa_to_delete;
@@ -1517,13 +1522,18 @@ int fib_table_delete(struct net *net, struct fib_table *tb,
 	u8 tos = cfg->fc_tos;
 	u32 key;
 
-	if (plen > KEYLENGTH)
+	if (plen > KEYLENGTH) {
+		NL_SET_ERR_MSG(extack, "Invalid prefix length");
 		return -EINVAL;
+	}
 
 	key = ntohl(cfg->fc_dst);
 
-	if ((plen < KEYLENGTH) && (key << plen))
+	if ((plen < KEYLENGTH) && (key << plen)) {
+		NL_SET_ERR_MSG(extack,
+			       "Invalid prefix for given prefix length");
 		return -EINVAL;
+	}
 
 	l = fib_find_node(t, &tp, key);
 	if (!l)
-- 
2.11.0 (Apple Git-81)
