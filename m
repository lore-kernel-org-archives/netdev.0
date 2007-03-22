From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 06/12] [PKT_SCHED] qdisc: Use rtnl registration interface
Date: Thu, 22 Mar 2007 14:00:01 +0100
Message-ID: <20070322130057.944682992@lsx.localdomain>
References: <20070322125955.055083236@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53652 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751535AbXCVNB4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 09:01:56 -0400
Content-Disposition: inline; filename=rtnl_reg_qdisc_convert
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/include/net/sch_generic.h
===================================================================
--- net-2.6.22.orig/include/net/sch_generic.h	2007-03-22 13:23:14.000000000 +0100
+++ net-2.6.22/include/net/sch_generic.h	2007-03-22 13:23:57.000000000 +0100
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
--- net-2.6.22.orig/net/sched/sch_api.c	2007-03-22 13:23:14.000000000 +0100
+++ net-2.6.22/net/sched/sch_api.c	2007-03-22 13:23:57.000000000 +0100
@@ -27,7 +27,6 @@
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
-#include <linux/rtnetlink.h>
 #include <linux/init.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
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
 
+	rtnl_register(PF_UNSPEC, RTM_NEWQDISC, tc_modify_qdisc, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELQDISC, tc_get_qdisc, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETQDISC, tc_get_qdisc, tc_dump_qdisc);
+	rtnl_register(PF_UNSPEC, RTM_NEWTCLASS, tc_ctl_tclass, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELTCLASS, tc_ctl_tclass, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETTCLASS, tc_ctl_tclass, tc_dump_tclass);
+
 	return 0;
 }
 

--

