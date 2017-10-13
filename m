From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/9] net: sched: store net pointer in block and introduce qdisc_net helper
Date: Fri, 13 Oct 2017 14:00:58 +0200
Message-ID: <20171013120105.23358-3-jiri@resnulli.us>
References: <20171013120105.23358-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:37643 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753413AbdJMMBK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 08:01:10 -0400
Received: by mail-wm0-f66.google.com with SMTP id r68so5588134wmr.4
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 05:01:09 -0700 (PDT)
In-Reply-To: <20171013120105.23358-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Store net pointer in the block structure. Along the way, introduce
qdisc_net helper which allows to easily obtain net pointer for
qdisc instance.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_sched.h   | 7 +++++++
 include/net/sch_generic.h | 1 +
 net/sched/cls_api.c       | 1 +
 3 files changed, 9 insertions(+)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 259bc19..2d234af 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -4,7 +4,9 @@
 #include <linux/jiffies.h>
 #include <linux/ktime.h>
 #include <linux/if_vlan.h>
+#include <linux/netdevice.h>
 #include <net/sch_generic.h>
+#include <net/net_namespace.h>
 #include <uapi/linux/pkt_sched.h>
 
 #define DEFAULT_TX_QUEUE_LEN	1000
@@ -146,4 +148,9 @@ static inline bool is_classid_clsact_egress(u32 classid)
 	       TC_H_MIN(classid) == TC_H_MIN(TC_H_MIN_EGRESS);
 }
 
+static inline struct net *qdisc_net(struct Qdisc *q)
+{
+	return dev_net(q->dev_queue->dev);
+}
+
 #endif
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index df4032c..9b2cb91 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -270,6 +270,7 @@ struct tcf_chain {
 
 struct tcf_block {
 	struct list_head chain_list;
+	struct net *net;
 	struct Qdisc *q;
 };
 
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index f7d3f1f..856003c 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -257,6 +257,7 @@ int tcf_block_get(struct tcf_block **p_block,
 		goto err_chain_create;
 	}
 	tcf_chain_filter_chain_ptr_set(chain, p_filter_chain);
+	block->net = qdisc_net(q);
 	block->q = q;
 	*p_block = block;
 	return 0;
-- 
2.9.5
