From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/3] [PKT_SCHED]: Fix illegal memory dereferences when dumping actions
Date: Wed, 05 Jul 2006 00:00:01 +0200
Message-ID: <20060704220549.952720000@postel.suug.ch>
References: <20060704220504.787776000@postel.suug.ch>
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:55749 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932310AbWGDWGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 18:06:45 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=act_fix_dump_null_deref
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TCA_ACT_KIND attribute is used without checking its
availability when dumping actions therefore leading to a
value of 0x4 being dereferenced.

The use of strcmp() in tc_lookup_action_n() isn't safe
when fed with string from an attribute without enforcing
proper NUL termination.

Both bugs can be triggered with malformed netlink message
and don't require any privileges.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.git/net/sched/act_api.c
===================================================================
--- net-2.6.git.orig/net/sched/act_api.c
+++ net-2.6.git/net/sched/act_api.c
@@ -776,7 +776,7 @@ replay:
 	return ret;
 }
 
-static char *
+static struct rtattr *
 find_dump_kind(struct nlmsghdr *n)
 {
 	struct rtattr *tb1, *tb2[TCA_ACT_MAX+1];
@@ -804,7 +804,7 @@ find_dump_kind(struct nlmsghdr *n)
 		return NULL;
 	kind = tb2[TCA_ACT_KIND-1];
 
-	return (char *) RTA_DATA(kind);
+	return kind;
 }
 
 static int
@@ -817,16 +817,15 @@ tc_dump_action(struct sk_buff *skb, stru
 	struct tc_action a;
 	int ret = 0;
 	struct tcamsg *t = (struct tcamsg *) NLMSG_DATA(cb->nlh);
-	char *kind = find_dump_kind(cb->nlh);
+	struct rtattr *kind = find_dump_kind(cb->nlh);
 
 	if (kind == NULL) {
 		printk("tc_dump_action: action bad kind\n");
 		return 0;
 	}
 
-	a_o = tc_lookup_action_n(kind);
+	a_o = tc_lookup_action(kind);
 	if (a_o == NULL) {
-		printk("failed to find %s\n", kind);
 		return 0;
 	}
 
@@ -834,7 +833,7 @@ tc_dump_action(struct sk_buff *skb, stru
 	a.ops = a_o;
 
 	if (a_o->walk == NULL) {
-		printk("tc_dump_action: %s !capable of dumping table\n", kind);
+		printk("tc_dump_action: %s !capable of dumping table\n", a_o->kind);
 		goto rtattr_failure;
 	}
 

--

