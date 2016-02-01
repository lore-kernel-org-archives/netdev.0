From: Amir Vadai <amir@vadai.me>
Subject: [RFC net-next 4/9] net/act_skbedit: Introduce hardware offload support
Date: Mon,  1 Feb 2016 08:34:40 +0000
Message-ID: <1454315685-32202-5-git-send-email-amir@vadai.me>
References: <1454315685-32202-1-git-send-email-amir@vadai.me>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:32925 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751614AbcBAIhA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2016 03:37:00 -0500
In-Reply-To: <1454315685-32202-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently only 'mark' operation is supported when hardware offload is
requested.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 net/sched/act_skbedit.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 6751b5f..3113dfc 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -23,6 +23,7 @@
 #include <linux/rtnetlink.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/switchdev.h>
 
 #include <linux/tc_act/tc_skbedit.h>
 #include <net/tc_act/tc_skbedit.h>
@@ -173,6 +174,22 @@ nla_put_failure:
 	return -1;
 }
 
+static int tcf_skbedit_offload_init(struct tc_action *a,
+				    struct switchdev_obj_port_flow_act *obj)
+{
+	struct tcf_skbedit *d = a->priv;
+
+	if (d->flags == SKBEDIT_F_MARK) {
+		obj->actions |= BIT(SWITCHDEV_OBJ_PORT_FLOW_ACT_MARK);
+		obj->mark = d->mark;
+
+		return 0;
+	}
+
+	pr_err("Only 'mark' is supported for offloaded skbedit\n");
+	return -ENOTSUPP;
+}
+
 static struct tc_action_ops act_skbedit_ops = {
 	.kind		=	"skbedit",
 	.type		=	TCA_ACT_SKBEDIT,
@@ -180,6 +197,7 @@ static struct tc_action_ops act_skbedit_ops = {
 	.act		=	tcf_skbedit,
 	.dump		=	tcf_skbedit_dump,
 	.init		=	tcf_skbedit_init,
+	.offload_init	=	tcf_skbedit_offload_init,
 };
 
 MODULE_AUTHOR("Alexander Duyck, <alexander.h.duyck@intel.com>");
-- 
2.7.0
