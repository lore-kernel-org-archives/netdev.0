From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next] ipv4: do metrics match when looking up and deleting a route
Date: Wed, 23 Aug 2017 10:07:26 +0800
Message-ID: <63b0473e7248f4931d46c45ac64e63b07bea6eeb.1503454046.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32856 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753036AbdHWCHf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 22:07:35 -0400
Received: by mail-pf0-f196.google.com with SMTP id x137so366697pfd.0
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 19:07:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when ipv4 route inserts a fib_info, it memcmp fib_metrics.
It means ipv4 route identifies one route also with metrics.

But when removing a route, it tries to find the route without
caring about the metrics. It will cause that the route with
right metrics can't be removed.

Thomas noticed this issue when doing the testing:

1. add:
   # ip route append 192.168.7.0/24 dev v window 1000
   # ip route append 192.168.7.0/24 dev v window 1001
   # ip route append 192.168.7.0/24 dev v window 1002
   # ip route append 192.168.7.0/24 dev v window 1003
2. delete:
   # ip route delete 192.168.7.0/24 dev v window 1002
3. show:
     192.168.7.0/24 proto boot scope link window 1001
     192.168.7.0/24 proto boot scope link window 1002
     192.168.7.0/24 proto boot scope link window 1003

The one with window 1002 wasn't deleted but the first one was.

This patch is to do metrics match when looking up and deleting
one route.

Reported-by: Thomas Haller <thaller@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/fib_lookup.h    |  1 +
 net/ipv4/fib_semantics.c | 34 ++++++++++++++++++++++++++++++++++
 net/ipv4/fib_trie.c      |  3 ++-
 3 files changed, 37 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index 769ab87..5b2af19 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -32,6 +32,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg,
 				 struct netlink_ext_ack *extack);
 int fib_nh_match(struct fib_config *cfg, struct fib_info *fi,
 		 struct netlink_ext_ack *extack);
+bool fib_metrics_match(struct fib_config *cfg, struct fib_info *fi);
 int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event, u32 tb_id,
 		  u8 type, __be32 dst, int dst_len, u8 tos, struct fib_info *fi,
 		  unsigned int);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 394d800..57a5d48 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -696,6 +696,40 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi,
 	return 0;
 }
 
+bool fib_metrics_match(struct fib_config *cfg, struct fib_info *fi)
+{
+	struct nlattr *nla;
+	int remaining;
+
+	if (!cfg->fc_mx)
+		return true;
+
+	nla_for_each_attr(nla, cfg->fc_mx, cfg->fc_mx_len, remaining) {
+		int type = nla_type(nla);
+		u32 val;
+
+		if (!type)
+			continue;
+		if (type > RTAX_MAX)
+			return false;
+
+		if (type == RTAX_CC_ALGO) {
+			char tmp[TCP_CA_NAME_MAX];
+			bool ecn_ca = false;
+
+			nla_strlcpy(tmp, nla, sizeof(tmp));
+			val = tcp_ca_get_key_by_name(tmp, &ecn_ca);
+		} else {
+			val = nla_get_u32(nla);
+		}
+
+		if (fi->fib_metrics->metrics[type - 1] != val)
+			return false;
+	}
+
+	return true;
+}
+
 
 /*
  * Picture
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 1a6ffb0..c636650 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1563,7 +1563,8 @@ int fib_table_delete(struct net *net, struct fib_table *tb,
 		     fi->fib_prefsrc == cfg->fc_prefsrc) &&
 		    (!cfg->fc_protocol ||
 		     fi->fib_protocol == cfg->fc_protocol) &&
-		    fib_nh_match(cfg, fi, extack) == 0) {
+		    fib_nh_match(cfg, fi, extack) == 0 &&
+		    fib_metrics_match(cfg, fi)) {
 			fa_to_delete = fa;
 			break;
 		}
-- 
2.1.0
