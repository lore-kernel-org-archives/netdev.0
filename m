From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 21/22]: act_api.c: sync multi action order processing
Date: Mon, 10 Jan 2005 20:38:18 +0100
Message-ID: <41E2D9AA.6090709@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090705080909070608000401"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090705080909070608000401
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------090705080909070608000401
Content-Type: text/x-patch;
 name="21.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="21.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 06:08:56+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: act_api.c: sync multi action order processing
#   
#   Sync tcf_action_init and tca_action_gd. Rename a few variables
#   to make the code more easily understandable and rename the
#   rtattr_failure/nlmsg_failure labels. These are usually called
#   from the netlink macros, it is misleading to use them in a
#   larger function without actually using netlink macros.
#   
#   Multi action orders were processed differently before,
#   tcf_action_init skipped empty ones while tca_action_gd stopped
#   at the first empty one. This patch makes both stop at the first
#   empty one.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2005/01/10 06:08:50+01:00 kaber@coreworks.de +35 -51
#   [PKT_SCHED]: act_api.c: sync multi action order processing
#   
#   Sync tcf_action_init and tca_action_gd. Rename a few variables
#   to make the code more easily understandable and rename the
#   rtattr_failure/nlmsg_failure labels. These are usually called
#   from the netlink macros, it is misleading to use them in a
#   larger function without actually using netlink macros.
#   
#   Multi action orders were processed differently before,
#   tcf_action_init skipped empty ones while tca_action_gd stopped
#   at the first empty one. This patch makes both stop at the first
#   empty one.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2005-01-10 06:23:17 +01:00
+++ b/net/sched/act_api.c	2005-01-10 06:23:17 +01:00
@@ -341,36 +341,32 @@
                                   char *name, int ovr, int bind, int *err)
 {
 	struct rtattr *tb[TCA_ACT_MAX_PRIO+1];
-	struct tc_action *a = NULL, *act, *act_prev = NULL;
+	struct tc_action *head = NULL, *act, *act_prev = NULL;
 	int i;
 
 	if (rtattr_parse(tb, TCA_ACT_MAX_PRIO, RTA_DATA(rta),
 	                 RTA_PAYLOAD(rta)) < 0) {
 		*err = -EINVAL;
-		return a;
+		return head;
 	}
 
-	for (i=0; i < TCA_ACT_MAX_PRIO; i++) {
-		if (tb[i]) {
-			act = tcf_action_init_1(tb[i], est, name, ovr, bind,
-			                        err);
-			if (act == NULL)
-				goto bad_ret;
-
-			act->order = i+1;
-			if (a == NULL)
-				a = act;
-			else
-				act_prev->next = act;
-			act_prev = act;
-		}
-
-	}
-	return a;
+	for (i=0; i < TCA_ACT_MAX_PRIO && tb[i]; i++) {
+		act = tcf_action_init_1(tb[i], est, name, ovr, bind, err);
+		if (act == NULL)
+			goto err;
+		act->order = i+1;
 
-bad_ret:
-	if (a != NULL)
-		tcf_action_destroy(a, bind);
+		if (head == NULL)
+			head = act;
+		else
+			act_prev->next = act;
+		act_prev = act;
+	}
+	return head;
+
+err:
+	if (head != NULL)
+		tcf_action_destroy(head, bind);
 	return NULL;
 }
 
@@ -600,71 +596,59 @@
 tca_action_gd(struct rtattr *rta, struct nlmsghdr *n, u32 pid, int event)
 {
 	int i, ret = 0;
-	struct tc_action *act;
 	struct rtattr *tb[TCA_ACT_MAX_PRIO+1];
-	struct tc_action *a = NULL, *a_s = NULL;
-
-	if (event != RTM_GETACTION && event != RTM_DELACTION)
-		ret = -EINVAL;
+	struct tc_action *head = NULL, *act, *act_prev = NULL;
 
 	if (rtattr_parse(tb, TCA_ACT_MAX_PRIO, RTA_DATA(rta),
-	                 RTA_PAYLOAD(rta)) < 0) {
-		ret = -EINVAL;
-		goto nlmsg_failure;
-	}
+	                 RTA_PAYLOAD(rta)) < 0)
+		return -EINVAL;
 
 	if (event == RTM_DELACTION && n->nlmsg_flags&NLM_F_ROOT) {
 		if (tb[0] != NULL && tb[1] == NULL)
 			return tca_action_flush(tb[0], n, pid);
 	}
 
-	for (i=0; i < TCA_ACT_MAX_PRIO; i++) {
-		if (tb[i] == NULL)
-			break;
+	for (i=0; i < TCA_ACT_MAX_PRIO && tb[i]; i++) {
 		act = tcf_action_get_1(tb[i], n, pid, &ret);
 		if (act == NULL)
-			goto rtattr_failure;
+			goto err;
 		act->order = i+1;
 
-		if (a != NULL) {
-			a->next = act;
-			a = act;
-		} else
-			a = act;
-
-		if (a_s == NULL)
-			a_s = a;
+		if (head == NULL)
+			head = act;
+		else
+			act_prev->next = act;
+		act_prev = act;
 	}
 
 	if (event == RTM_GETACTION)
-		ret = act_get_notify(pid, n, a_s, event);
+		ret = act_get_notify(pid, n, head, event);
 	else { /* delete */
 		struct sk_buff *skb;
 
 		skb = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
 		if (!skb) {
 			ret = -ENOBUFS;
-			goto nlmsg_failure;
+			goto err;
 		}
 
-		if (tca_get_fill(skb, a_s, pid, n->nlmsg_seq, 0, event,
+		if (tca_get_fill(skb, head, pid, n->nlmsg_seq, 0, event,
 		                 0, 1) <= 0) {
 			kfree_skb(skb);
 			ret = -EINVAL;
-			goto nlmsg_failure;
+			goto err;
 		}
 
 		/* now do the delete */
-		tcf_action_destroy(a_s, 0);
+		tcf_action_destroy(head, 0);
 		ret = rtnetlink_send(skb, pid, RTMGRP_TC,
 		                     n->nlmsg_flags&NLM_F_ECHO);
 		if (ret > 0)
 			return 0;
 		return ret;
 	}
-rtattr_failure:
-nlmsg_failure:
-	cleanup_a(a_s);
+err:
+	cleanup_a(head);
 	return ret;
 }
 

--------------090705080909070608000401--
