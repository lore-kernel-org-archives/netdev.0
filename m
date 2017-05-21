From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 1/4] net: ipv4: Plumb extack through route add functions
Date: Sun, 21 May 2017 10:12:02 -0600
Message-ID: <20170521161205.36720-2-dsahern@gmail.com>
References: <20170521161205.36720-1-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35884 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756191AbdEUQMU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 12:12:20 -0400
Received: by mail-pg0-f66.google.com with SMTP id h64so14998115pge.3
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 09:12:20 -0700 (PDT)
In-Reply-To: <20170521161205.36720-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Plumb extack argument down to route add functions.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/ip_fib.h     |  3 ++-
 net/ipv4/fib_frontend.c  | 16 +++++++++-------
 net/ipv4/fib_lookup.h    |  3 ++-
 net/ipv4/fib_semantics.c | 22 +++++++++++++---------
 net/ipv4/fib_trie.c      |  4 ++--
 5 files changed, 28 insertions(+), 20 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 6692c5758b33..42e8b8f55f7c 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -263,7 +263,8 @@ struct fib_table {
 
 int fib_table_lookup(struct fib_table *tb, const struct flowi4 *flp,
 		     struct fib_result *res, int fib_flags);
-int fib_table_insert(struct net *, struct fib_table *, struct fib_config *);
+int fib_table_insert(struct net *, struct fib_table *, struct fib_config *,
+		     struct netlink_ext_ack *extack);
 int fib_table_delete(struct net *, struct fib_table *, struct fib_config *);
 int fib_table_dump(struct fib_table *table, struct sk_buff *skb,
 		   struct netlink_callback *cb);
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 83e3ed258467..511edff76c01 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -594,7 +594,8 @@ int ip_rt_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 			} else {
 				tb = fib_new_table(net, cfg.fc_table);
 				if (tb)
-					err = fib_table_insert(net, tb, &cfg);
+					err = fib_table_insert(net, tb,
+							       &cfg, NULL);
 				else
 					err = -ENOBUFS;
 			}
@@ -626,14 +627,15 @@ const struct nla_policy rtm_ipv4_policy[RTA_MAX + 1] = {
 };
 
 static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
-			     struct nlmsghdr *nlh, struct fib_config *cfg)
+			     struct nlmsghdr *nlh, struct fib_config *cfg,
+			     struct netlink_ext_ack *extack)
 {
 	struct nlattr *attr;
 	int err, remaining;
 	struct rtmsg *rtm;
 
 	err = nlmsg_validate(nlh, sizeof(*rtm), RTA_MAX, rtm_ipv4_policy,
-			     NULL);
+			     extack);
 	if (err < 0)
 		goto errout;
 
@@ -718,7 +720,7 @@ static int inet_rtm_delroute(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct fib_table *tb;
 	int err;
 
-	err = rtm_to_fib_config(net, skb, nlh, &cfg);
+	err = rtm_to_fib_config(net, skb, nlh, &cfg, extack);
 	if (err < 0)
 		goto errout;
 
@@ -741,7 +743,7 @@ static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct fib_table *tb;
 	int err;
 
-	err = rtm_to_fib_config(net, skb, nlh, &cfg);
+	err = rtm_to_fib_config(net, skb, nlh, &cfg, extack);
 	if (err < 0)
 		goto errout;
 
@@ -751,7 +753,7 @@ static int inet_rtm_newroute(struct sk_buff *skb, struct nlmsghdr *nlh,
 		goto errout;
 	}
 
-	err = fib_table_insert(net, tb, &cfg);
+	err = fib_table_insert(net, tb, &cfg, extack);
 errout:
 	return err;
 }
@@ -845,7 +847,7 @@ static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifad
 		cfg.fc_scope = RT_SCOPE_HOST;
 
 	if (cmd == RTM_NEWROUTE)
-		fib_table_insert(net, tb, &cfg);
+		fib_table_insert(net, tb, &cfg, NULL);
 	else
 		fib_table_delete(net, tb, &cfg);
 }
diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index 9c02920725db..2704e08545da 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -28,7 +28,8 @@ static inline void fib_alias_accessed(struct fib_alias *fa)
 
 /* Exported by fib_semantics.c */
 void fib_release_info(struct fib_info *);
-struct fib_info *fib_create_info(struct fib_config *cfg);
+struct fib_info *fib_create_info(struct fib_config *cfg,
+				 struct netlink_ext_ack *extack);
 int fib_nh_match(struct fib_config *cfg, struct fib_info *fi);
 int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event, u32 tb_id,
 		  u8 type, __be32 dst, int dst_len, u8 tos, struct fib_info *fi,
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index da449ddb8cc1..8587d1b55b53 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -454,7 +454,8 @@ static int fib_detect_death(struct fib_info *fi, int order,
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 
-static int fib_count_nexthops(struct rtnexthop *rtnh, int remaining)
+static int fib_count_nexthops(struct rtnexthop *rtnh, int remaining,
+			      struct netlink_ext_ack *extack)
 {
 	int nhs = 0;
 
@@ -468,7 +469,8 @@ static int fib_count_nexthops(struct rtnexthop *rtnh, int remaining)
 }
 
 static int fib_get_nhs(struct fib_info *fi, struct rtnexthop *rtnh,
-		       int remaining, struct fib_config *cfg)
+		       int remaining, struct fib_config *cfg,
+		       struct netlink_ext_ack *extack)
 {
 	int ret;
 
@@ -714,7 +716,7 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi)
  *					|-> {local prefix} (terminal node)
  */
 static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
-			struct fib_nh *nh)
+			struct fib_nh *nh, struct netlink_ext_ack *extack)
 {
 	int err = 0;
 	struct net *net;
@@ -797,7 +799,6 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 
 		if (nh->nh_flags & (RTNH_F_PERVASIVE | RTNH_F_ONLINK))
 			return -EINVAL;
-
 		rcu_read_lock();
 		err = -ENODEV;
 		in_dev = inetdev_by_index(net, nh->nh_oif);
@@ -980,7 +981,8 @@ fib_convert_metrics(struct fib_info *fi, const struct fib_config *cfg)
 	return 0;
 }
 
-struct fib_info *fib_create_info(struct fib_config *cfg)
+struct fib_info *fib_create_info(struct fib_config *cfg,
+				 struct netlink_ext_ack *extack)
 {
 	int err;
 	struct fib_info *fi = NULL;
@@ -1000,7 +1002,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (cfg->fc_mp) {
-		nhs = fib_count_nexthops(cfg->fc_mp, cfg->fc_mp_len);
+		nhs = fib_count_nexthops(cfg->fc_mp, cfg->fc_mp_len, extack);
 		if (nhs == 0)
 			goto err_inval;
 	}
@@ -1062,7 +1064,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 
 	if (cfg->fc_mp) {
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-		err = fib_get_nhs(fi, cfg->fc_mp, cfg->fc_mp_len, cfg);
+		err = fib_get_nhs(fi, cfg->fc_mp, cfg->fc_mp_len, cfg, extack);
 		if (err != 0)
 			goto failure;
 		if (cfg->fc_oif && fi->fib_nh->nh_oif != cfg->fc_oif)
@@ -1129,7 +1131,9 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		struct fib_nh *nh = fi->fib_nh;
 
 		/* Local address is added. */
-		if (nhs != 1 || nh->nh_gw)
+		if (nhs != 1)
+			goto err_inval;
+		if (nh->nh_gw)
 			goto err_inval;
 		nh->nh_scope = RT_SCOPE_NOWHERE;
 		nh->nh_dev = dev_get_by_index(net, fi->fib_nh->nh_oif);
@@ -1140,7 +1144,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		int linkdown = 0;
 
 		change_nexthops(fi) {
-			err = fib_check_nh(cfg, fi, nexthop_nh);
+			err = fib_check_nh(cfg, fi, nexthop_nh, extack);
 			if (err != 0)
 				goto failure;
 			if (nexthop_nh->nh_flags & RTNH_F_LINKDOWN)
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 51182ff2b441..6d0f6c79d9aa 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1101,7 +1101,7 @@ static int fib_insert_alias(struct trie *t, struct key_vector *tp,
 
 /* Caller must hold RTNL. */
 int fib_table_insert(struct net *net, struct fib_table *tb,
-		     struct fib_config *cfg)
+		     struct fib_config *cfg, struct netlink_ext_ack *extack)
 {
 	enum fib_event_type event = FIB_EVENT_ENTRY_ADD;
 	struct trie *t = (struct trie *)tb->tb_data;
@@ -1125,7 +1125,7 @@ int fib_table_insert(struct net *net, struct fib_table *tb,
 	if ((plen < KEYLENGTH) && (key << plen))
 		return -EINVAL;
 
-	fi = fib_create_info(cfg);
+	fi = fib_create_info(cfg, extack);
 	if (IS_ERR(fi)) {
 		err = PTR_ERR(fi);
 		goto err;
-- 
2.11.0 (Apple Git-81)
