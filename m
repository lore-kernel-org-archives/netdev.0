From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6 PKT_SCHED]: Fix overflow on 64bit in times reported
 to userspace by tc actions
Date: Mon, 22 Nov 2004 20:40:37 +0100
Message-ID: <41A240B5.5070404@trash.net>
References: <41908D1D.50405@trash.net>	 <20041111150314.576ce699.davem@davemloft.net>	 <1101059233.1093.151.camel@jzny.localdomain>  <41A1C99B.6010202@trash.net> <1101129873.1093.300.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050801050102000903020706"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1101129873.1093.300.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050801050102000903020706
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

jamal wrote:

>I think thats the one I am acking, no?
>
Sorry, seems my eyes were still closed when replying to your mail :)

>Can you resend it just to be
>sure. Note that i had no issues with any of the other patches (other
>than one i explicitly flagged to test).
>
Attached, description from the original mail:

This patch moves memory allocation for tc_actions to
tcf_action_init_1 and fixes multiple bugs in error paths:

- when memory allocation fails in tcf_action_init, the
 action is destroyed twice, once in tcf_action_init and
 once in tcf_action_add/tcf_change_act

- when tcf_action_init_1 fails for the first action, the action
 is passed to tcf_action_destroy in an undefined state by
 tcf_action_add/tcf_change_act/tcf_change_act_police

- when tcf_action_init_1 fails for any but the first action,
 the action leaks in tcf_action_init

Regards
Patrick


--------------050801050102000903020706
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/09 07:31:03+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Clean up tcf_action_init memory handling
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2004/11/09 07:30:52+01:00 kaber@coreworks.de +47 -57
#   [PKT_SCHED]: Clean up tcf_action_init memory handling
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/net/pkt_cls.h
#   2004/11/09 07:30:52+01:00 kaber@coreworks.de +6 -20
#   [PKT_SCHED]: Clean up tcf_action_init memory handling
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# include/net/act_api.h
#   2004/11/09 07:30:52+01:00 kaber@coreworks.de +2 -2
#   [PKT_SCHED]: Clean up tcf_action_init memory handling
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/include/net/act_api.h b/include/net/act_api.h
--- a/include/net/act_api.h	2004-11-09 09:31:36 +01:00
+++ b/include/net/act_api.h	2004-11-09 09:31:36 +01:00
@@ -87,8 +87,8 @@
 extern int tcf_unregister_action(struct tc_action_ops *a);
 extern void tcf_action_destroy(struct tc_action *a, int bind);
 extern int tcf_action_exec(struct sk_buff *skb, struct tc_action *a, struct tcf_result *res);
-extern int tcf_action_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,char *n, int ovr, int bind);
-extern int tcf_action_init_1(struct rtattr *rta, struct rtattr *est, struct tc_action *a,char *n, int ovr, int bind);
+extern struct tc_action *tcf_action_init(struct rtattr *rta, struct rtattr *est, char *n, int ovr, int bind, int *err);
+extern struct tc_action *tcf_action_init_1(struct rtattr *rta, struct rtattr *est, char *n, int ovr, int bind, int *err);
 extern int tcf_action_dump(struct sk_buff *skb, struct tc_action *a, int, int);
 extern int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
 extern int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
diff -Nru a/include/net/pkt_cls.h b/include/net/pkt_cls.h
--- a/include/net/pkt_cls.h	2004-11-09 09:31:36 +01:00
+++ b/include/net/pkt_cls.h	2004-11-09 09:31:36 +01:00
@@ -70,17 +70,10 @@
 	int ret;
 	struct tc_action *act;
 
-	act = kmalloc(sizeof(*act), GFP_KERNEL);
-	if (NULL == act)
-		return -ENOMEM;
-	memset(act, 0, sizeof(*act));
-	
-	ret = tcf_action_init_1(act_police_tlv, rate_tlv, act, "police",
-		TCA_ACT_NOREPLACE, TCA_ACT_BIND);
-	if (ret < 0) {
-		tcf_action_destroy(act, TCA_ACT_UNBIND);
+	act = tcf_action_init_1(act_police_tlv, rate_tlv, "police",
+	                        TCA_ACT_NOREPLACE, TCA_ACT_BIND, &ret);
+	if (act == NULL)
 		return ret;
-	}
 
 	act->type = TCA_OLD_COMPAT;
 
@@ -103,17 +96,10 @@
 	int ret;
 	struct tc_action *act;
 
-	act = kmalloc(sizeof(*act), GFP_KERNEL);
-	if (NULL == act)
-		return -ENOMEM;
-	memset(act, 0, sizeof(*act));
-
-	ret = tcf_action_init(act_tlv, rate_tlv, act, NULL,
-		TCA_ACT_NOREPLACE, TCA_ACT_BIND);
-	if (ret < 0) {
-		tcf_action_destroy(act, TCA_ACT_UNBIND);
+	act = tcf_action_init(act_tlv, rate_tlv, NULL,
+	                      TCA_ACT_NOREPLACE, TCA_ACT_BIND, &ret);
+	if (act == NULL)
 		return ret;
-	}
 
 	if (*action) {
 		tcf_tree_lock(tp);
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2004-11-09 09:31:36 +01:00
+++ b/net/sched/act_api.c	2004-11-09 09:31:36 +01:00
@@ -294,14 +294,16 @@
 	
 }
 
-int tcf_action_init_1(struct rtattr *rta, struct rtattr *est, struct tc_action *a, char *name, int ovr, int bind )
+struct tc_action *tcf_action_init_1(struct rtattr *rta, struct rtattr *est,
+                                    char *name, int ovr, int bind, int *err)
 {
+	struct tc_action *a;
 	struct tc_action_ops *a_o;
 	char act_name[4 + IFNAMSIZ + 1];
 	struct rtattr *tb[TCA_ACT_MAX+1];
 	struct rtattr *kind = NULL;
 
-	int err = -EINVAL;
+	*err = -EINVAL;
 
 	if (NULL == name) {
 		if (rtattr_parse(tb, TCA_ACT_MAX, RTA_DATA(rta), RTA_PAYLOAD(rta))<0)
@@ -337,22 +339,25 @@
 		goto err_out;
 	}
 
-	if (NULL == a) {
+	a = kmalloc(sizeof(*a), GFP_KERNEL);
+	if (a == NULL) {
+		*err = -ENOMEM;
 		goto err_mod;
 	}
+	memset(a, 0, sizeof(*a));
 
 	/* backward compatibility for policer */
 	if (NULL == name) {
-		err = a_o->init(tb[TCA_ACT_OPTIONS-1], est, a, ovr, bind);
-		if (0 > err ) {
-			err = -EINVAL;
-			goto err_mod;
+		*err = a_o->init(tb[TCA_ACT_OPTIONS-1], est, a, ovr, bind);
+		if (*err < 0) {
+			*err = -EINVAL;
+			goto err_free;
 		}
 	} else {
-		err = a_o->init(rta, est, a, ovr, bind);
-		if (0 > err ) {
-			err = -EINVAL;
-			goto err_mod;
+		*err = a_o->init(rta, est, a, ovr, bind);
+		if (*err < 0) {
+			*err = -EINVAL;
+			goto err_free;
 		}
 	}
 
@@ -360,60 +365,58 @@
 	   if it exists and is only bound to in a_o->init() then
            ACT_P_CREATED is not returned (a zero is).
         */
-	if (ACT_P_CREATED != err) {
+	if (*err != ACT_P_CREATED)
 		module_put(a_o->owner);
-	} 
 	a->ops = a_o;
 	DPRINTK("tcf_action_init_1: successfull %s \n",act_name);
 
-	return 0;
+	*err = 0;
+	return a;
+
+err_free:
+	kfree(a);
 err_mod:
 	module_put(a_o->owner);
 err_out:
-	return err;
+	return NULL;
 }
 
-int tcf_action_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a, char *name, int ovr , int bind)
+struct tc_action *tcf_action_init(struct rtattr *rta, struct rtattr *est,
+                                  char *name, int ovr, int bind, int *err)
 {
 	struct rtattr *tb[TCA_ACT_MAX_PRIO+1];
+	struct tc_action *a = NULL, *act, *act_prev = NULL;
 	int i;
-	struct tc_action *act = a, *a_s = a;
-
-	int err = -EINVAL;
 
-	if (rtattr_parse(tb, TCA_ACT_MAX_PRIO, RTA_DATA(rta), RTA_PAYLOAD(rta))<0)
-		return err;
+	if (rtattr_parse(tb, TCA_ACT_MAX_PRIO, RTA_DATA(rta),
+	                 RTA_PAYLOAD(rta)) < 0) {
+		*err = -EINVAL;
+		return a;
+	}
 
-	for (i=0; i < TCA_ACT_MAX_PRIO ; i++) {
+	for (i=0; i < TCA_ACT_MAX_PRIO; i++) {
 		if (tb[i]) {
-			if (NULL == act) {
-				act = kmalloc(sizeof(*act),GFP_KERNEL);
-				if (NULL == act) {
-					err = -ENOMEM;
-					goto bad_ret;
-				}
-				memset(act, 0,sizeof(*act));
-			}
-			act->next = NULL;
-			if (0 > tcf_action_init_1(tb[i],est,act,name,ovr,bind)) {
-				printk("Error processing action order %d\n",i);
-				return err;
+			act = tcf_action_init_1(tb[i], est, name, ovr, bind, err);
+			if (act == NULL) {
+				printk("Error processing action order %d\n", i);
+				goto bad_ret;
 			}
 
 			act->order = i+1;
-			if (a_s != act) {
-				a_s->next = act;
-				a_s = act;
-			}
-			act = NULL;
+			if (a == NULL)
+				a = act;
+			else
+				act_prev->next = act;
+			act_prev = act;
 		}
 
 	}
+	return a;
 
-	return 0;
 bad_ret:
-	tcf_action_destroy(a, bind);
-	return err;
+	if (a != NULL)
+		tcf_action_destroy(a, bind);
+	return NULL;
 }
 
 int tcf_action_copy_stats (struct sk_buff *skb,struct tc_action *a)
@@ -849,21 +852,9 @@
 	struct tc_action *a = NULL;
 	u32 seq = n->nlmsg_seq;
 
-	act = kmalloc(sizeof(*act),GFP_KERNEL);
-	if (NULL == act)
-		return -ENOMEM;
-
-	memset(act, 0, sizeof(*act));
-
-	ret = tcf_action_init(rta, NULL,act,NULL,ovr,0);
-	/* NOTE: We have an all-or-none model
-	 * This means that of any of the actions fail
-	 * to update then all are undone.
-	 * */
-	if (0 > ret) {
-		tcf_action_destroy(act, 0);
+	act = tcf_action_init(rta, NULL, NULL, ovr, 0, &ret);
+	if (act == NULL)
 		goto done;
-	}
 
 	/* dump then free all the actions after update; inserted policy
 	 * stays intact
@@ -880,7 +871,6 @@
 		}
 	}
 done:
-
 	return ret;
 }
 

--------------050801050102000903020706--
