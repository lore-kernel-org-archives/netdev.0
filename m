From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Resend WAS(Re: cls patchlet
Date: Sun, 3 Oct 2004 15:12:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041003151216.5a56531f.davem@davemloft.net>
References: <1096833127.1048.333.camel@jzny.localdomain>
	<1096834352.1046.349.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1096834352.1046.349.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 03 Oct 2004 16:12:32 -0400
jamal <hadi@cyberus.ca> wrote:

> Ignore previous. This is better formated ;->

Any particular reason not to remove this work into the
common code in tcf_action_exec()?  Like so:

===== include/net/pkt_sched.h 1.23 vs edited =====
--- 1.23/include/net/pkt_sched.h	2004-09-28 13:58:51 -07:00
+++ edited/include/net/pkt_sched.h	2004-10-03 14:50:35 -07:00
@@ -376,7 +376,7 @@ struct tc_action_ops
 extern int tcf_register_action(struct tc_action_ops *a);
 extern int tcf_unregister_action(struct tc_action_ops *a);
 extern void tcf_action_destroy(struct tc_action *a, int bind);
-extern int tcf_action_exec(struct sk_buff *skb, struct tc_action *a);
+extern int tcf_action_exec(struct sk_buff *skb, struct tc_action *a, struct tcf_result *res);
 extern int tcf_action_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,char *n, int ovr, int bind);
 extern int tcf_action_init_1(struct rtattr *rta, struct rtattr *est, struct tc_action *a,char *n, int ovr, int bind);
 extern int tcf_action_dump(struct sk_buff *skb, struct tc_action *a, int, int);
===== net/sched/act_api.c 1.4 vs edited =====
--- 1.4/net/sched/act_api.c	2004-06-29 14:20:44 -07:00
+++ edited/net/sched/act_api.c	2004-10-03 14:51:41 -07:00
@@ -155,7 +155,7 @@ struct tc_action_ops *tc_lookup_action_i
 	return a;
 }
 
-int tcf_action_exec(struct sk_buff *skb,struct tc_action *act)
+int tcf_action_exec(struct sk_buff *skb,struct tc_action *act, struct tcf_result *res)
 {
 
 	struct tc_action *a;
@@ -164,7 +164,8 @@ int tcf_action_exec(struct sk_buff *skb,
 	if (skb->tc_verd & TC_NCLS) {
 		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
 		D2PRINTK("(%p)tcf_action_exec: cleared TC_NCLS in %s out %s\n",skb,skb->input_dev?skb->input_dev->name:"xxx",skb->dev->name);
-		return TC_ACT_OK;
+		ret = TC_ACT_OK;
+		goto exec_done;
 	}
 	while ((a = act) != NULL) {
 repeat:
@@ -186,6 +187,11 @@ repeat:
 	}
 
 exec_done:
+	if (skb->tc_classid > 0) {
+		res->classid = skb->tc_classid;
+		res->class = 0;
+		skb->tc_classid = 0;
+	}
 
 	return ret;
 }
===== net/sched/cls_fw.c 1.8 vs edited =====
--- 1.8/net/sched/cls_fw.c	2004-07-06 14:26:23 -07:00
+++ edited/net/sched/cls_fw.c	2004-10-03 14:52:05 -07:00
@@ -102,7 +102,7 @@ static int fw_classify(struct sk_buff *s
 			}
 #endif
                                if (f->action) {
-                                       int pol_res = tcf_action_exec(skb, f->action);
+                                       int pol_res = tcf_action_exec(skb, f->action, res);
                                        if (pol_res >= 0)
                                                return pol_res;
                                } else
===== net/sched/cls_u32.c 1.16 vs edited =====
--- 1.16/net/sched/cls_u32.c	2004-07-29 15:44:49 -07:00
+++ edited/net/sched/cls_u32.c	2004-10-03 14:52:00 -07:00
@@ -175,12 +175,7 @@ check_terminal:
 #endif
 #ifdef CONFIG_NET_CLS_ACT
 				if (n->action) {
-					int pol_res = tcf_action_exec(skb, n->action);
-					if (skb->tc_classid > 0) {
-						res->classid = skb->tc_classid;
-						skb->tc_classid = 0;
-					}
-
+					int pol_res = tcf_action_exec(skb, n->action, res);
 					if (pol_res >= 0)
 						return pol_res;
 				} else
