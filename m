From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 3/17]: Remove checks for impossible conditions in
 act_api.c
Date: Thu, 30 Dec 2004 04:39:26 +0100
Message-ID: <41D3786E.3070800@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060704050804080901090705"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060704050804080901090705
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Remove checks for impossible conditions, also remove some
useless NULL-ptr assignments and make loops iterating over
actions clearer.


--------------060704050804080901090705
Content-Type: text/x-patch;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/30 01:36:55+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Remove checks for impossible conditions in act_api.c
#   
#   Also remove some useless NULL-ptr assignments and make loops iterating
#   over actions clearer.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2004/12/30 01:36:48+01:00 kaber@coreworks.de +14 -32
#   [PKT_SCHED]: Remove checks for impossible conditions in act_api.c
#   
#   Also remove some useless NULL-ptr assignments and make loops iterating
#   over actions clearer.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2004-12-30 04:01:06 +01:00
+++ b/net/sched/act_api.c	2004-12-30 04:01:06 +01:00
@@ -195,25 +195,18 @@
 {
 	struct tc_action *a;
 
-	for (a = act; act; a = act) {
-		if (a && a->ops && a->ops->cleanup) {
+	for (a = act; a; a = act) {
+		if (a->ops && a->ops->cleanup) {
 			DPRINTK("tcf_action_destroy destroying %p next %p\n",
-			        a, a->next ? a->next : NULL);
+			        a, a->next);
 			act = act->next;
 			if (a->ops->cleanup(a, bind) == ACT_P_DELETED)
 				module_put(a->ops->owner);
-			
-			a->ops = NULL;
 			kfree(a);
 		} else { /*FIXME: Remove later - catch insertion bugs*/
 			printk("tcf_action_destroy: BUG? destroying NULL ops\n");
-			if (a) {
-				act = act->next;
-				kfree(a);
-			} else {
-				printk("tcf_action_destroy: BUG? destroying NULL action!\n");
-				break;
-			}
+			act = act->next;
+			kfree(a);
 		}
 	}
 }
@@ -223,7 +216,7 @@
 {
 	int err = -EINVAL;
 
-	if ((a == NULL) || (a->ops == NULL) || (a->ops->dump == NULL))
+	if (a->ops == NULL || a->ops->dump == NULL)
 		return err;
 	return a->ops->dump(skb, a, bind, ref);
 }
@@ -235,8 +228,7 @@
 	unsigned char *b = skb->tail;
 	struct rtattr *r;
 
-	if ((a == NULL) || (a->ops == NULL) || (a->ops->dump == NULL) ||
-	    (a->ops->kind == NULL))
+	if (a->ops == NULL || a->ops->dump == NULL || a->ops->kind == NULL)
 		return err;
 
 	RTA_PUT(skb, TCA_KIND, IFNAMSIZ, a->ops->kind);
@@ -563,14 +555,9 @@
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
 
@@ -715,7 +702,7 @@
 		if (tb[i] == NULL)
 			break;
 		act = create_a(i+1);
-		if (a != NULL && a != act) {
+		if (a != NULL) {
 			a->next = act;
 			a = act;
 		} else
@@ -826,14 +813,9 @@
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

--------------060704050804080901090705--
