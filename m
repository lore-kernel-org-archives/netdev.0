From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 20/22]: act_api.c: push memory allocation to tcf_action_get_1
Date: Mon, 10 Jan 2005 20:38:16 +0100
Message-ID: <41E2D9A8.9080003@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040200000705010208020307"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040200000705010208020307
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------040200000705010208020307
Content-Type: text/x-patch;
 name="20.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="20.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 05:47:32+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: act_api.c: push memory allocation to tcf_action_get_1
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2005/01/10 05:47:25+01:00 kaber@coreworks.de +30 -18
#   [PKT_SCHED]: act_api.c: push memory allocation to tcf_action_get_1
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2005-01-10 06:23:12 +01:00
+++ b/net/sched/act_api.c	2005-01-10 06:23:12 +01:00
@@ -463,31 +463,46 @@
 	return err;
 }
 
-static int tcf_action_get_1(struct rtattr *rta, struct tc_action *a,
-                            struct nlmsghdr *n, u32 pid)
+static struct tc_action *
+tcf_action_get_1(struct rtattr *rta, struct nlmsghdr *n, u32 pid, int *err)
 {
 	struct rtattr *tb[TCA_ACT_MAX+1];
+	struct tc_action *a;
 	int index;
-	int err = 0;
 
+	*err = -EINVAL;
 	if (rtattr_parse(tb, TCA_ACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
-		return -EINVAL;
+		return NULL;
 
 	if (tb[TCA_ACT_INDEX - 1] == NULL ||
 	    RTA_PAYLOAD(tb[TCA_ACT_INDEX - 1]) < sizeof(index))
-		return -EINVAL;
+		return NULL;
 	index = *(int *)RTA_DATA(tb[TCA_ACT_INDEX - 1]);
 
+	*err = -ENOMEM;
+	a = kmalloc(sizeof(struct tc_action), GFP_KERNEL);
+	if (a == NULL)
+		return NULL;
+	memset(a, 0, sizeof(struct tc_action));
+
+	*err = -EINVAL;
 	a->ops = tc_lookup_action(tb[TCA_ACT_KIND - 1]);
 	if (a->ops == NULL)
-		return -EINVAL;
+		goto err_free;
 	if (a->ops->lookup == NULL)
-		err = -EINVAL;
-	else if (a->ops->lookup(a, index) == 0)
-		err = -ENOENT;
+		goto err_mod;
+	*err = -ENOENT;
+	if (a->ops->lookup(a, index) == 0)
+		goto err_mod;
 
 	module_put(a->ops->owner);
-	return err;
+	*err = 0;
+	return a;
+err_mod:
+	module_put(a->ops->owner);
+err_free:
+	kfree(a);
+	return NULL;
 }
 
 static void cleanup_a(struct tc_action *act)
@@ -606,7 +621,11 @@
 	for (i=0; i < TCA_ACT_MAX_PRIO; i++) {
 		if (tb[i] == NULL)
 			break;
-		act = create_a(i+1);
+		act = tcf_action_get_1(tb[i], n, pid, &ret);
+		if (act == NULL)
+			goto rtattr_failure;
+		act->order = i+1;
+
 		if (a != NULL) {
 			a->next = act;
 			a = act;
@@ -615,13 +634,6 @@
 
 		if (a_s == NULL)
 			a_s = a;
-
-		ret = tcf_action_get_1(tb[i], act, n, pid);
-		if (ret < 0) {
-			printk("tcf_action_get: failed to get!\n");
-			ret = -EINVAL;
-			goto rtattr_failure;
-		}
 	}
 
 	if (event == RTM_GETACTION)

--------------040200000705010208020307--
