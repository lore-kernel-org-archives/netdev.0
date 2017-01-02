From: Paul Blakey <paulb@mellanox.com>
Subject: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Mon,  2 Jan 2017 15:13:53 +0200
Message-ID: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
Cc: Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Paul Blakey <paulb@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45141 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755964AbdABNOU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 08:14:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to support saving extra data that might be helpful on retrieval.
First use case is upcoming openvswitch flow offloads, extra data will
include UFID and port mappings for each added flow.

Signed-off-by: Paul Blakey <paulb@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 include/uapi/linux/pkt_cls.h |  3 +++
 net/sched/cls_flower.c       | 22 +++++++++++++++++++++-
 2 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index cb4bcdc..ca9bbe3 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -471,10 +471,13 @@ enum {
 	TCA_FLOWER_KEY_ICMPV6_TYPE,	/* u8 */
 	TCA_FLOWER_KEY_ICMPV6_TYPE_MASK,/* u8 */
 
+	TCA_FLOWER_COOKIE,		/* binary */
+
 	__TCA_FLOWER_MAX,
 };
 
 #define TCA_FLOWER_MAX (__TCA_FLOWER_MAX - 1)
+#define FLOWER_MAX_COOKIE_SIZE 128
 
 enum {
 	TCA_FLOWER_KEY_FLAGS_IS_FRAGMENT = (1 << 0),
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 333f8e2..e2f5b25 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -85,6 +85,8 @@ struct cls_fl_filter {
 	struct rcu_head	rcu;
 	struct tc_to_netdev tc;
 	struct net_device *hw_dev;
+	size_t cookie_len;
+	long cookie[0];
 };
 
 static unsigned short int fl_mask_range(const struct fl_flow_mask *mask)
@@ -794,6 +796,9 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	struct cls_fl_filter *fnew;
 	struct nlattr *tb[TCA_FLOWER_MAX + 1];
 	struct fl_flow_mask mask = {};
+	const struct nlattr *attr;
+	size_t cookie_len = 0;
+	void *cookie;
 	int err;
 
 	if (!tca[TCA_OPTIONS])
@@ -806,10 +811,22 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	if (fold && handle && fold->handle != handle)
 		return -EINVAL;
 
-	fnew = kzalloc(sizeof(*fnew), GFP_KERNEL);
+	if (tb[TCA_FLOWER_COOKIE]) {
+		attr = tb[TCA_FLOWER_COOKIE];
+		cookie_len = nla_len(attr);
+		cookie = nla_data(attr);
+		if (cookie_len > FLOWER_MAX_COOKIE_SIZE)
+			return -EINVAL;
+	}
+
+	fnew = kzalloc(sizeof(*fnew) + cookie_len, GFP_KERNEL);
 	if (!fnew)
 		return -ENOBUFS;
 
+	fnew->cookie_len = cookie_len;
+	if (cookie_len)
+		memcpy(fnew->cookie, cookie, cookie_len);
+
 	err = tcf_exts_init(&fnew->exts, TCA_FLOWER_ACT, 0);
 	if (err < 0)
 		goto errout;
@@ -1151,6 +1168,9 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 
 	nla_put_u32(skb, TCA_FLOWER_FLAGS, f->flags);
 
+	if (f->cookie_len)
+		nla_put(skb, TCA_FLOWER_COOKIE, f->cookie_len, f->cookie);
+
 	if (tcf_exts_dump(skb, &f->exts))
 		goto nla_put_failure;
 
-- 
1.8.3.1
