From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 5/17]: Clean up act_api.c action init path, propagate
 errors properly
Date: Thu, 30 Dec 2004 04:39:44 +0100
Message-ID: <41D37880.7030709@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060902040500040601030304"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060902040500040601030304
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Clean up act_api.c action init path, propagate errors properly.
Also replace an unrelated printk for an impossible condition by
BUG().


--------------060902040500040601030304
Content-Type: text/x-patch;
 name="05.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="05.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/12/30 02:01:06+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Clean up act_api.c action init path, propagate errors properly
#   
#   Also replace an unrelated printk for an impossible condition by BUG().
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2004/12/30 02:01:00+01:00 kaber@coreworks.de +11 -25
#   [PKT_SCHED]: Clean up act_api.c action init path, propagate errors properly
#   
#   Also replace an unrelated printk for an impossible condition by BUG().
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2004-12-30 04:01:15 +01:00
+++ b/net/sched/act_api.c	2004-12-30 04:01:15 +01:00
@@ -287,14 +287,11 @@
 		                 RTA_PAYLOAD(rta)) < 0)
 			goto err_out;
 		kind = tb[TCA_ACT_KIND-1];
-		if (kind != NULL) {
-			if (RTA_PAYLOAD(kind) >= IFNAMSIZ)
-				goto err_out;
-			sprintf(act_name, "%s", (char*)RTA_DATA(kind));
-		} else {
-			printk("Action bad kind\n");
+		if (kind == NULL)
 			goto err_out;
-		}
+		if (RTA_PAYLOAD(kind) >= IFNAMSIZ)
+			goto err_out;
+		sprintf(act_name, "%s", (char*)RTA_DATA(kind));
 		a_o = tc_lookup_action(kind);
 	} else {
 		sprintf(act_name, "%s", name);
@@ -310,7 +307,7 @@
 
 #endif
 	if (a_o == NULL) {
-		printk("failed to find %s\n", act_name);
+		*err = -ENOENT;
 		goto err_out;
 	}
 
@@ -322,19 +319,12 @@
 	memset(a, 0, sizeof(*a));
 
 	/* backward compatibility for policer */
-	if (name == NULL) {
+	if (name == NULL)
 		*err = a_o->init(tb[TCA_ACT_OPTIONS-1], est, a, ovr, bind);
-		if (*err < 0) {
-			*err = -EINVAL;
-			goto err_free;
-		}
-	} else {
+	else
 		*err = a_o->init(rta, est, a, ovr, bind);
-		if (*err < 0) {
-			*err = -EINVAL;
-			goto err_free;
-		}
-	}
+	if (*err < 0)
+		goto err_free;
 
 	/* module count goes up only when brand new policy is created
 	   if it exists and is only bound to in a_o->init() then
@@ -372,11 +362,8 @@
 	for (i=0; i < TCA_ACT_MAX_PRIO; i++) {
 		if (tb[i]) {
 			act = tcf_action_init_1(tb[i], est, name, ovr, bind, err);
-			if (act == NULL) {
-				printk("Error processing action order %d\n", i);
+			if (act == NULL)
 				goto bad_ret;
-			}
-
 			act->order = i+1;
 			if (a == NULL)
 				a = act;
@@ -845,8 +832,7 @@
 		ret = tca_action_gd(tca[TCA_ACT_TAB-1], n, pid, RTM_GETACTION);
 		break;
 	default:
-		printk("Unknown cmd was detected\n");
-		break;
+		BUG();
 	}
 
 	return ret;

--------------060902040500040601030304--
