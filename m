From: Amir Vadai <amir@vadai.me>
Subject: [RFC net-next 5/9] net/act_gact: Introduce hardware offload support for drop
Date: Mon,  1 Feb 2016 08:34:41 +0000
Message-ID: <1454315685-32202-6-git-send-email-amir@vadai.me>
References: <1454315685-32202-1-git-send-email-amir@vadai.me>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:32933 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751738AbcBAIhD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2016 03:37:03 -0500
In-Reply-To: <1454315685-32202-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable hardware offloaded packet dropping when filter is marked with
'offload' attribute.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 net/sched/act_gact.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index 5c1b051..b639b18 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -20,6 +20,7 @@
 #include <linux/init.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/switchdev.h>
 #include <linux/tc_act/tc_gact.h>
 #include <net/tc_act/tc_gact.h>
 
@@ -183,6 +184,21 @@ nla_put_failure:
 	return -1;
 }
 
+static int tcf_gact_offload_init(struct tc_action *a,
+				 struct switchdev_obj_port_flow_act *obj)
+{
+	struct tcf_gact *gact = a->priv;
+
+	if (gact->tcf_action == TC_ACT_SHOT) {
+		obj->actions |= BIT(SWITCHDEV_OBJ_PORT_FLOW_ACT_DROP);
+
+		return 0;
+	}
+
+	pr_err("Only 'drop' is supported for offloaded gact\n");
+	return -ENOTSUPP;
+}
+
 static struct tc_action_ops act_gact_ops = {
 	.kind		=	"gact",
 	.type		=	TCA_ACT_GACT,
@@ -190,6 +206,7 @@ static struct tc_action_ops act_gact_ops = {
 	.act		=	tcf_gact,
 	.dump		=	tcf_gact_dump,
 	.init		=	tcf_gact_init,
+	.offload_init	=	tcf_gact_offload_init,
 };
 
 MODULE_AUTHOR("Jamal Hadi Salim(2002-4)");
-- 
2.7.0
