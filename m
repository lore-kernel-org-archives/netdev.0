From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 07/12] [PKT_SCHED] cls: Use rtnl registration interface
Date: Wed, 21 Mar 2007 01:06:00 +0100
Message-ID: <20070321000710.136641836@lsx.localdomain>
References: <20070321000553.070942307@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44413 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752346AbXCUAmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 20:42:11 -0400
Content-Disposition: inline; filename=rtnl_reg_cls_convert
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/sched/cls_api.c
===================================================================
--- net-2.6.22.orig/net/sched/cls_api.c	2007-03-20 23:53:20.000000000 +0100
+++ net-2.6.22/net/sched/cls_api.c	2007-03-21 00:52:36.000000000 +0100
@@ -29,7 +29,6 @@
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
-#include <linux/rtnetlink.h>
 #include <linux/init.h>
 #include <linux/kmod.h>
 #include <linux/netlink.h>
@@ -128,7 +127,7 @@ static __inline__ u32 tcf_auto_prio(stru
 
 /* Add/change/delete/get a filter node */
 
-static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
+static int nl_cls_modify(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
 	struct rtattr **tca;
 	struct tcmsg *t;
@@ -384,7 +383,7 @@ static int tcf_node_dump(struct tcf_prot
 			     a->cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWTFILTER);
 }
 
-static int tc_dump_tfilter(struct sk_buff *skb, struct netlink_callback *cb)
+static int nl_cls_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int t;
 	int s_t;
@@ -616,18 +615,10 @@ rtattr_failure: __attribute__ ((unused))
 
 static int __init tc_filter_init(void)
 {
-	struct rtnetlink_link *link_p = rtnetlink_links[PF_UNSPEC];
+	rtnl_register(PF_UNSPEC, RTM_NEWTFILTER, nl_cls_modify, NULL);
+	rtnl_register(PF_UNSPEC, RTM_DELTFILTER, nl_cls_modify, NULL);
+	rtnl_register(PF_UNSPEC, RTM_GETTFILTER, nl_cls_modify, nl_cls_dump);
 
-	/* Setup rtnetlink links. It is made here to avoid
-	   exporting large number of public symbols.
-	 */
-
-	if (link_p) {
-		link_p[RTM_NEWTFILTER-RTM_BASE].doit = tc_ctl_tfilter;
-		link_p[RTM_DELTFILTER-RTM_BASE].doit = tc_ctl_tfilter;
-		link_p[RTM_GETTFILTER-RTM_BASE].doit = tc_ctl_tfilter;
-		link_p[RTM_GETTFILTER-RTM_BASE].dumpit = tc_dump_tfilter;
-	}
 	return 0;
 }
 

--

