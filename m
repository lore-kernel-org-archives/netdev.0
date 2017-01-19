From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] net/sched: cls_flower: reduce fl_change stack size
Date: Thu, 19 Jan 2017 10:45:31 +0100
Message-ID: <20170119094551.2780983-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Amir Vadai <amir@vadai.me>, Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>,
        Roi Dayan <roid@mellanox.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:57040 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751599AbdASJqa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 04:46:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new ARP support has pushed the stack size over the edge on ARM,
as there are two large objects on the stack in this function (mask
and tb) and both have now grown a bit more:

net/sched/cls_flower.c: In function 'fl_change':
net/sched/cls_flower.c:928:1: error: the frame size of 1072 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]

We can solve this by dynamically allocating one or both of them.
I first tried to do it just for the mask, but that only saved
152 bytes on ARM, while this version just does it for the 'tb'
array, bringing the stack size back down to 664 bytes.

Fixes: 99d31326cbe6 ("net/sched: cls_flower: Support matching on ARP")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/sched/cls_flower.c | 23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 27934456d984..9e74b0fa4b89 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -832,23 +832,31 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	struct cls_fl_head *head = rtnl_dereference(tp->root);
 	struct cls_fl_filter *fold = (struct cls_fl_filter *) *arg;
 	struct cls_fl_filter *fnew;
-	struct nlattr *tb[TCA_FLOWER_MAX + 1];
+	struct nlattr **tb;
 	struct fl_flow_mask mask = {};
 	int err;
 
 	if (!tca[TCA_OPTIONS])
 		return -EINVAL;
 
+	tb = kcalloc(TCA_FLOWER_MAX + 1, sizeof(struct nlattr *), GFP_KERNEL);
+	if (!tb)
+		return -ENOBUFS;
+
 	err = nla_parse_nested(tb, TCA_FLOWER_MAX, tca[TCA_OPTIONS], fl_policy);
 	if (err < 0)
-		return err;
+		goto errout_tb;
 
-	if (fold && handle && fold->handle != handle)
-		return -EINVAL;
+	if (fold && handle && fold->handle != handle) {
+		err = -EINVAL;
+		goto errout_tb;
+	}
 
 	fnew = kzalloc(sizeof(*fnew), GFP_KERNEL);
-	if (!fnew)
-		return -ENOBUFS;
+	if (!fnew) {
+		err = -ENOBUFS;
+		goto errout_tb;
+	}
 
 	err = tcf_exts_init(&fnew->exts, TCA_FLOWER_ACT, 0);
 	if (err < 0)
@@ -919,11 +927,14 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 		list_add_tail_rcu(&fnew->list, &head->filters);
 	}
 
+	kfree(tb);
 	return 0;
 
 errout:
 	tcf_exts_destroy(&fnew->exts);
 	kfree(fnew);
+errout_tb:
+	kfree(tb);
 	return err;
 }
 
-- 
2.9.0
