From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 8/22]: act_api.c: clean up init path, propagate
 errors properly
Date: Mon, 10 Jan 2005 20:37:56 +0100
Message-ID: <41E2D994.6070304@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000909040505000102080502"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000909040505000102080502
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------000909040505000102080502
Content-Type: text/x-patch;
 name="08.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="08.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/09 23:31:15+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: act_api.c: clean up init path, propagate errors properly
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2005/01/09 23:31:08+01:00 kaber@coreworks.de +17 -36
#   [PKT_SCHED]: act_api.c: clean up init path, propagate errors properly
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2005-01-10 06:22:15 +01:00
+++ b/net/sched/act_api.c	2005-01-10 06:22:15 +01:00
@@ -283,55 +283,39 @@
 		                 RTA_PAYLOAD(rta)) < 0)
 			goto err_out;
 		kind = tb[TCA_ACT_KIND-1];
-		if (kind != NULL) {
-			if (rtattr_strlcpy(act_name, kind,
-			                   IFNAMSIZ) >= IFNAMSIZ)
-				goto err_out;
-		} else {
-			printk("Action bad kind\n");
+		if (kind == NULL)
+			goto err_out;
+		if (rtattr_strlcpy(act_name, kind, IFNAMSIZ) >= IFNAMSIZ)
 			goto err_out;
-		}
-		a_o = tc_lookup_action(kind);
 	} else {
-		sprintf(act_name, "%s", name);
-		DPRINTK("tcf_action_init_1: finding %s\n", act_name);
-		a_o = tc_lookup_action_n(name);
+		if (strlcpy(act_name, name, IFNAMSIZ) >= IFNAMSIZ)
+			goto err_out;
 	}
+
+	*err = -ENOENT;
+	a_o = tc_lookup_action_n(act_name);
 #ifdef CONFIG_KMOD
 	if (a_o == NULL) {
-		DPRINTK("tcf_action_init_1: trying to load module %s\n",
-		        act_name);
 		request_module(act_name);
 		a_o = tc_lookup_action_n(act_name);
 	}
-
 #endif
-	if (a_o == NULL) {
-		printk("failed to find %s\n", act_name);
+	if (a_o == NULL)
 		goto err_out;
-	}
 
+	*err = -ENOMEM;
 	a = kmalloc(sizeof(*a), GFP_KERNEL);
-	if (a == NULL) {
-		*err = -ENOMEM;
+	if (a == NULL)
 		goto err_mod;
-	}
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
@@ -370,10 +354,8 @@
 		if (tb[i]) {
 			act = tcf_action_init_1(tb[i], est, name, ovr, bind,
 			                        err);
-			if (act == NULL) {
-				printk("Error processing action order %d\n", i);
+			if (act == NULL)
 				goto bad_ret;
-			}
 
 			act->order = i+1;
 			if (a == NULL)
@@ -838,8 +820,7 @@
 		ret = tca_action_gd(tca[TCA_ACT_TAB-1], n, pid, RTM_GETACTION);
 		break;
 	default:
-		printk("Unknown cmd was detected\n");
-		break;
+		BUG();
 	}
 
 	return ret;

--------------000909040505000102080502--
