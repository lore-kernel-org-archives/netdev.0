From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 19/22]: act_api.c: remove module loading from get/delete
 operations
Date: Mon, 10 Jan 2005 20:38:15 +0100
Message-ID: <41E2D9A7.7090909@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020005010809070002090708"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020005010809070002090708
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

If get/delete can't find the action we can assume there is nothing
to get/delete.



--------------020005010809070002090708
Content-Type: text/x-patch;
 name="19.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="19.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 05:31:11+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: act_api.c: remove module loading from get/delete operations
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2005/01/10 05:31:05+01:00 kaber@coreworks.de +15 -79
#   [PKT_SCHED]: act_api.c: remove module loading from get/delete operations
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2005-01-10 06:23:07 +01:00
+++ b/net/sched/act_api.c	2005-01-10 06:23:07 +01:00
@@ -380,10 +380,6 @@
 	struct gnet_dump d;
 	struct tcf_act_hdr *h = a->priv;
 	
-#ifdef CONFIG_KMOD
-	/* place holder */
-#endif
-
 	if (h == NULL)
 		goto errout;
 
@@ -470,58 +466,27 @@
 static int tcf_action_get_1(struct rtattr *rta, struct tc_action *a,
                             struct nlmsghdr *n, u32 pid)
 {
-	struct tc_action_ops *a_o;
-	char act_name[IFNAMSIZ];
 	struct rtattr *tb[TCA_ACT_MAX+1];
-	struct rtattr *kind;
 	int index;
-	int err = -EINVAL;
+	int err = 0;
 
 	if (rtattr_parse(tb, TCA_ACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta)) < 0)
-		goto err_out;
-	kind = tb[TCA_ACT_KIND-1];
-	if (kind != NULL) {
-		if (rtattr_strlcpy(act_name, kind, IFNAMSIZ) >= IFNAMSIZ)
-			goto err_out;
-	} else {
-		printk("tcf_action_get_1: action bad kind\n");
-		goto err_out;
-	}
-
-	if (tb[TCA_ACT_INDEX - 1])
-		index = *(int *)RTA_DATA(tb[TCA_ACT_INDEX - 1]);
-	else {
-		printk("tcf_action_get_1: index not received\n");
-		goto err_out;
-	}
-
-	a_o = tc_lookup_action(kind);
-#ifdef CONFIG_KMOD
-	if (a_o == NULL) {
-		request_module (act_name);
-		a_o = tc_lookup_action_n(act_name);
-	}
-#endif
-	if (a_o == NULL) {
-		printk("failed to find %s\n", act_name);
-		goto err_out;
-	}
-	if (a == NULL)
-		goto err_mod;
+		return -EINVAL;
 
-	a->ops = a_o;
+	if (tb[TCA_ACT_INDEX - 1] == NULL ||
+	    RTA_PAYLOAD(tb[TCA_ACT_INDEX - 1]) < sizeof(index))
+		return -EINVAL;
+	index = *(int *)RTA_DATA(tb[TCA_ACT_INDEX - 1]);
 
-	if (a_o->lookup == NULL || a_o->lookup(a, index) == 0) {
-		a->ops = NULL;
+	a->ops = tc_lookup_action(tb[TCA_ACT_KIND - 1]);
+	if (a->ops == NULL)
+		return -EINVAL;
+	if (a->ops->lookup == NULL)
 		err = -EINVAL;
-		goto err_mod;
-	}
+	else if (a->ops->lookup(a, index) == 0)
+		err = -ENOENT;
 
-	module_put(a_o->owner);
-	return 0;
-err_mod:
-	module_put(a_o->owner);
-err_out:
+	module_put(a->ops->owner);
 	return err;
 }
 
@@ -535,36 +500,6 @@
 	}
 }
 
-static struct tc_action_ops *get_ao(struct rtattr *kind, struct tc_action *a)
-{
-	char act_name[IFNAMSIZ];
-	struct tc_action_ops *a_o;
-
-	if (kind != NULL) {
-		if (rtattr_strlcpy(act_name, kind, IFNAMSIZ) >= IFNAMSIZ)
-			return NULL;
-	} else {
-		printk("get_ao: action bad kind\n");
-		return NULL;
-	}
-
-	a_o = tc_lookup_action(kind);
-#ifdef CONFIG_KMOD
-	if (a_o == NULL) {
-		DPRINTK("get_ao: trying to load module %s\n", act_name);
-		request_module(act_name);
-		a_o = tc_lookup_action_n(act_name);
-	}
-#endif
-	if (a_o == NULL) {
-		printk("get_ao: failed to find %s\n", act_name);
-		return NULL;
-	}
-
-	a->ops = a_o;
-	return a_o;
-}
-
 static struct tc_action *create_a(int i)
 {
 	struct tc_action *act;
@@ -610,7 +545,8 @@
 		goto err_out;
 
 	kind = tb[TCA_ACT_KIND-1];
-	if (get_ao(kind, a) == NULL)
+	a->ops = tc_lookup_action(kind);
+	if (a->ops == NULL)
 		goto err_out;
 
 	nlh = NLMSG_PUT(skb, pid, n->nlmsg_seq, RTM_DELACTION, sizeof(*t));

--------------020005010809070002090708--
