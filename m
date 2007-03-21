From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 06/12] [PKT_SCHED] qdisc: Use rtnl registration interface
Date: Wed, 21 Mar 2007 01:05:59 +0100
Message-ID: <20070321000710.004774005@lsx.localdomain>
References: <20070321000553.070942307@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44406 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751538AbXCUAmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 20:42:09 -0400
Content-Disposition: inline; filename=rtnl_reg_qdisc_convert
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/include/net/sch_generic.h
===================================================================
--- net-2.6.22.orig/include/net/sch_generic.h	2007-03-20 23:53:20.000000000 +0100
+++ net-2.6.22/include/net/sch_generic.h	2007-03-21 00:52:35.000000000 +0100
@@ -5,10 +5,10 @@
 #include <linux/types.h>
 #include <linux/rcupdate.h>
 #include <linux/module.h>
-#include <linux/rtnetlink.h>
 #include <linux/pkt_sched.h>
 #include <linux/pkt_cls.h>
 #include <net/gen_stats.h>
+#include <net/rtnetlink.h>
 
 struct Qdisc_ops;
 struct qdisc_walker;
Index: net-2.6.22/net/sched/sch_api.c
===================================================================
--- net-2.6.22.orig/net/sched/sch_api.c	2007-03-20 23:53:20.000000000 +0100
+++ net-2.6.22/net/sched/sch_api.c	2007-03-21 00:52:35.000000000 +0100
@@ -27,7 +27,6 @@
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
-#include <linux/rtnetlink.h>
 #include <linux/init.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -611,7 +610,7 @@ check_loop_fn(struct Qdisc *q, unsigned 
  * Delete/get qdisc.
  */
 
-static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
+static int nl_qdisc_get(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
 	struct tcmsg *tcm = NLMSG_DATA(n);
 	struct rtattr **tca = arg;
@@ -672,7 +671,7 @@ static int tc_get_qdisc(struct sk_buff *
    Create/change qdisc.
  */
 
-static int tc_modify_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
+static int nl_qdisc_new(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
 	struct tcmsg *tcm;
 	struct rtattr **tca;
@@ -884,7 +883,7 @@ err_out:
 	return -EINVAL;
 }
 
-static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
+static int nl_qdisc_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int idx, q_idx;
 	int s_idx, s_q_idx;
@@ -933,7 +932,7 @@ done:
 
 
 
-static int tc_ctl_tclass(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
+static int nl_class_modify(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
 	struct tcmsg *tcm = NLMSG_DATA(n);
 	struct rtattr **tca = arg;
@@ -1119,7 +1118,7 @@ static int qdisc_class_dump(struct Qdisc
 			      a->cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWTCLASS);
 }
 
-static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
+static int nl_class_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int t;
 	int s_t;
@@ -1239,29 +1238,17 @@ static const struct file_operations psch
 
 static int __init pktsched_init(void)
 {
-	struct rtnetlink_link *link_p;
-
-	link_p = rtnetlink_links[PF_UNSPEC];
-
-	/* Setup rtnetlink links. It is made here to avoid
-	   exporting large number of public symbols.
-	 */
-
-	if (link_p) {
-		link_p[RTM_NEWQDISC-RTM_BASE].doit = tc_modify_qdisc;
-		link_p[RTM_DELQDISC-RTM_BASE].doit = tc_get_qdisc;
-		link_p[RTM_GETQDISC-RTM_BASE].doit = tc_get_qdisc;
-		link_p[RTM_GETQDISC-RTM_BASE].dumpit = tc_dump_qdisc;
-		link_p[RTM_NEWTCLASS-RTM_BASE].doit = tc_ctl_tclass;
-		link_p[RTM_DELTCLASS-RTM_BASE].doit = tc_ctl_tclass;
-		link_p[RTM_GETTCLASS-RTM_BASE].doit = tc_ctl_tclass;
-		link_p[RTM_GETTCLASS-RTM_BASE].dumpit = tc_dump_tclass;
-	}
-
 	register_qdisc(&pfifo_qdisc_ops);
 	register_qdisc(&bfifo_qdisc_ops);
 	proc_net_fops_create("psched", 0, &psched_fops);
 
+	rtnl_register(PF_UNSPEC, RTM_NEWQDISC, nl_qdisc_new, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELQDISC, nl_qdisc_get, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETQDISC, nl_qdisc_get, nl_qdisc_dump);
+	rtnl_register(PF_UNSPEC, RTM_NEWTCLASS, nl_class_modify, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELTCLASS, nl_class_modify, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETTCLASS, nl_class_modify, nl_class_dump);
+
 	return 0;
 }
 

--

