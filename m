From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 4/4] net: sched: create hardware only classifier
 filter
Date: Tue, 23 Feb 2016 11:03:56 -0800
Message-ID: <20160223190356.5970.94298.stgit@john-Precision-Tower-5810>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, jhs@mojatatu.com
To: jiri@resnulli.us, john.fastabend@gmail.com, daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34353 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754903AbcBWTEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 14:04:20 -0500
Received: by mail-pf0-f174.google.com with SMTP id x65so116858457pfb.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 11:04:20 -0800 (PST)
In-Reply-To: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If users want to run filters specifically in hardware without software
running the classifiers we need to use a special handler for this.
By using a new classifier list we are able to add filters in hardware
and keep all the same semantics in the core module. So the core code
will continue to block duplicate entries, incorrect usage of flags
such as exclusive, and all the other cases software already handles.

Additionally by having a filter list that is not run by software in
the datapath we avoid any overhead related to adding these rules in
the hot path.

The new filter list TC_H_MIN_INGRESS_HW is logically run in front
of the TC_H_MIN_INGRESS filter list. Driver writers can avoid aborting
on many cases that would potentially conflict with software rules in
the TC_H_MIN_INGRESS filter list this way.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/netdevice.h      |    1 +
 include/uapi/linux/pkt_sched.h |    1 +
 net/sched/sch_ingress.c        |    5 +++++
 3 files changed, 7 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 47671ce0..df0ca01 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1741,6 +1741,7 @@ struct net_device {
 
 #ifdef CONFIG_NET_CLS_ACT
 	struct tcf_proto __rcu  *ingress_cl_list;
+	struct tcf_proto __rcu  *ingress_hw_cl_list;
 #endif
 	struct netdev_queue __rcu *ingress_queue;
 #ifdef CONFIG_NETFILTER_INGRESS
diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 8cb18b4..e2899c2 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -76,6 +76,7 @@ struct tc_estimator {
 
 #define TC_H_MIN_INGRESS	0xFFF2U
 #define TC_H_MIN_EGRESS		0xFFF3U
+#define TC_H_MIN_INGRESS_HW	0xFFF4U
 
 /* Need to corrospond to iproute2 tc/tc_core.h "enum link_layer" */
 enum tc_link_layer {
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 10adbc6..792b85c 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -104,6 +104,7 @@ static unsigned long clsact_get(struct Qdisc *sch, u32 classid)
 	switch (TC_H_MIN(classid)) {
 	case TC_H_MIN(TC_H_MIN_INGRESS):
 	case TC_H_MIN(TC_H_MIN_EGRESS):
+	case TC_H_MIN(TC_H_MIN_INGRESS_HW):
 		return TC_H_MIN(classid);
 	default:
 		return 0;
@@ -126,6 +127,8 @@ static struct tcf_proto __rcu **clsact_find_tcf(struct Qdisc *sch,
 		return &dev->ingress_cl_list;
 	case TC_H_MIN(TC_H_MIN_EGRESS):
 		return &dev->egress_cl_list;
+	case TC_H_MIN(TC_H_MIN_INGRESS_HW):
+		return &dev->ingress_hw_cl_list;
 	default:
 		return NULL;
 	}
@@ -148,6 +151,8 @@ static void clsact_destroy(struct Qdisc *sch)
 	tcf_destroy_chain(&dev->ingress_cl_list);
 	tcf_destroy_chain(&dev->egress_cl_list);
 
+	tcf_destroy_chain(&dev->ingress_hw_cl_list);
+
 	net_dec_ingress_queue();
 	net_dec_egress_queue();
 }
