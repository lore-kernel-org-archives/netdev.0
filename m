From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 4/22]: act_api.c: remove checks for impossible conditions
Date: Mon, 10 Jan 2005 20:37:49 +0100
Message-ID: <41E2D98D.8050609@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070600040905060400070801"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070600040905060400070801
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------070600040905060400070801
Content-Type: text/x-patch;
 name="04.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="04.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/09 22:51:34+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: act_api.c: remove checks for impossible conditions
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2005/01/09 22:51:25+01:00 kaber@coreworks.de +15 -34
#   [PKT_SCHED]: act_api.c: remove checks for impossible conditions
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2005-01-10 06:21:56 +01:00
+++ b/net/sched/act_api.c	2005-01-10 06:21:56 +01:00
@@ -191,26 +191,18 @@
 {
 	struct tc_action *a;
 
-	for (a = act; act; a = act) {
-		if (a && a->ops && a->ops->cleanup) {
+	for (a = act; a; a = act) {
+		if (a->ops && a->ops->cleanup) {
 			DPRINTK("tcf_action_destroy destroying %p next %p\n",
-			        a, a->next ? a->next : NULL);
-			act = act->next;
+			        a, a->next);
 			if (a->ops->cleanup(a, bind) == ACT_P_DELETED)
 				module_put(a->ops->owner);
-			
-			a->ops = NULL;
+			act = act->next;
 			kfree(a);
 		} else { /*FIXME: Remove later - catch insertion bugs*/
 			printk("tcf_action_destroy: BUG? destroying NULL ops\n");
-			if (a) {
-				act = act->next;
-				kfree(a);
-			} else {
-				printk("tcf_action_destroy: BUG? destroying "
-				       "NULL action!\n");
-				break;
-			}
+			act = act->next;
+			kfree(a);
 		}
 	}
 }
@@ -220,7 +212,7 @@
 {
 	int err = -EINVAL;
 
-	if ((a == NULL) || (a->ops == NULL) || (a->ops->dump == NULL))
+	if (a->ops == NULL || a->ops->dump == NULL)
 		return err;
 	return a->ops->dump(skb, a, bind, ref);
 }
@@ -232,8 +224,7 @@
 	unsigned char *b = skb->tail;
 	struct rtattr *r;
 
-	if ((a == NULL) || (a->ops == NULL) || (a->ops->dump == NULL) ||
-	    (a->ops->kind == NULL))
+	if (a->ops == NULL || a->ops->dump == NULL)
 		return err;
 
 	RTA_PUT(skb, TCA_KIND, IFNAMSIZ, a->ops->kind);
@@ -563,14 +554,9 @@
 {
 	struct tc_action *a;
 
-	for (a = act; act; a = act) {
-		if (a) {
-			act = act->next;
-			a->ops = NULL;
-			a->priv = NULL;
-			kfree(a);
-		} else
-			printk("cleanup_a: BUG? empty action\n");
+	for (a = act; a; a = act) {
+		act = a->next;
+		kfree(a);
 	}
 }
 
@@ -715,7 +701,7 @@
 		if (tb[i] == NULL)
 			break;
 		act = create_a(i+1);
-		if (a != NULL && a != act) {
+		if (a != NULL) {
 			a->next = act;
 			a = act;
 		} else
@@ -826,14 +812,9 @@
 	 * stays intact
 	 * */
 	ret = tcf_add_notify(act, pid, seq, RTM_NEWACTION, n->nlmsg_flags);
-	for (a = act; act; a = act) {
-		if (a) {
-			act = act->next;
-			a->ops = NULL;
-			a->priv = NULL;
-			kfree(a);
-		} else
-			printk("tcf_action_add: BUG? empty action\n");
+	for (a = act; a; a = act) {
+		act = a->next;
+		kfree(a);
 	}
 done:
 	return ret;

--------------070600040905060400070801--
