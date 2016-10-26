From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] netlink: Add nla_memdup() to wrap kmemdup() use on nlattr
Date: Wed, 26 Oct 2016 10:53:16 +0200
Message-ID: <2d0864c85200f1b42b1ebceee7c2dc60fe29f26a.1477471562.git.tgraf@suug.ch>
Cc: johannes@sipsolutions.net, daniel@iogearbox.net,
        netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:35952 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754930AbcJZIx1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 04:53:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrap several common instances of:
	kmemdup(nla_data(attr), nla_len(attr), GFP_KERNEL);

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/netlink.h  | 10 ++++++++++
 net/sched/act_bpf.c    |  4 +---
 net/sched/cls_bpf.c    |  4 +---
 net/wireless/nl80211.c |  3 +--
 4 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 254a0fc..a34f53a 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -1191,6 +1191,16 @@ static inline struct in6_addr nla_get_in6_addr(const struct nlattr *nla)
 }
 
 /**
+ * nla_memdup - duplicate attribute memory (kmemdup)
+ * @src: netlink attribute to duplicate from
+ * @gfp: GFP mask
+ */
+static inline void *nla_memdup(const struct nlattr *src, gfp_t gfp)
+{
+	return kmemdup(nla_data(src), nla_len(src), gfp);
+}
+
+/**
  * nla_nest_start - Start a new level of nested attributes
  * @skb: socket buffer to add attributes to
  * @attrtype: attribute type of container
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index 1d39600..9ff06cf 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -226,9 +226,7 @@ static int tcf_bpf_init_from_efd(struct nlattr **tb, struct tcf_bpf_cfg *cfg)
 		return PTR_ERR(fp);
 
 	if (tb[TCA_ACT_BPF_NAME]) {
-		name = kmemdup(nla_data(tb[TCA_ACT_BPF_NAME]),
-			       nla_len(tb[TCA_ACT_BPF_NAME]),
-			       GFP_KERNEL);
+		name = nla_memdup(tb[TCA_ACT_BPF_NAME], GFP_KERNEL);
 		if (!name) {
 			bpf_prog_put(fp);
 			return -ENOMEM;
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index bb1d5a4..52dc85a 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -369,9 +369,7 @@ static int cls_bpf_prog_from_efd(struct nlattr **tb, struct cls_bpf_prog *prog,
 		return PTR_ERR(fp);
 
 	if (tb[TCA_BPF_NAME]) {
-		name = kmemdup(nla_data(tb[TCA_BPF_NAME]),
-			       nla_len(tb[TCA_BPF_NAME]),
-			       GFP_KERNEL);
+		name = nla_memdup(tb[TCA_BPF_NAME], GFP_KERNEL);
 		if (!name) {
 			bpf_prog_put(fp);
 			return -ENOMEM;
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index c510810..7bfe1e0 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -10638,8 +10638,7 @@ static int handle_nan_filter(struct nlattr *attr_filter,
 
 	i = 0;
 	nla_for_each_nested(attr, attr_filter, rem) {
-		filter[i].filter = kmemdup(nla_data(attr), nla_len(attr),
-					   GFP_KERNEL);
+		filter[i].filter = nla_memdup(attr, GFP_KERNEL);
 		filter[i].len = nla_len(attr);
 		i++;
 	}
-- 
2.7.4
