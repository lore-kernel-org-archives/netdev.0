From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 4/6]: act_api.c: drop rtnl for loading modules
Date: Tue, 11 Jan 2005 22:46:30 +0100
Message-ID: <41E44936.4020304@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090903010106030403090009"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090903010106030403090009
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------090903010106030403090009
Content-Type: text/x-patch;
 name="04.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="04.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/11 22:10:34+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: act_api.c: drop rtnl for loading modules
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/cls_api.c
#   2005/01/11 22:10:27+01:00 kaber@coreworks.de +18 -7
#   [PKT_SCHED]: act_api.c: drop rtnl for loading modules
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/act_api.c
#   2005/01/11 22:10:26+01:00 kaber@coreworks.de +19 -4
#   [PKT_SCHED]: act_api.c: drop rtnl for loading modules
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/act_api.c b/net/sched/act_api.c
--- a/net/sched/act_api.c	2005-01-11 22:32:20 +01:00
+++ b/net/sched/act_api.c	2005-01-11 22:32:20 +01:00
@@ -291,16 +291,28 @@
 			goto err_out;
 	}
 
-	*err = -ENOENT;
 	a_o = tc_lookup_action_n(act_name);
-#ifdef CONFIG_KMOD
 	if (a_o == NULL) {
+#ifdef CONFIG_KMOD
+		rtnl_unlock();
 		request_module(act_name);
+		rtnl_lock();
+
 		a_o = tc_lookup_action_n(act_name);
-	}
+
+		/* We dropped the RTNL semaphore in order to
+		 * perform the module load.  So, even if we
+		 * succeeded in loading the module we have to
+		 * tell the caller to replay the request.  We
+		 * indicate this using -EAGAIN.
+		 */
+		if (a_o != NULL) {
+			*err = -EAGAIN;
+			goto err_mod;
+		}
 #endif
-	if (a_o == NULL)
 		goto err_out;
+	}
 
 	*err = -ENOMEM;
 	a = kmalloc(sizeof(*a), GFP_KERNEL);
@@ -740,7 +752,10 @@
 		 */
 		if (n->nlmsg_flags&NLM_F_REPLACE)
 			ovr = 1;
+replay:
 		ret = tcf_action_add(tca[TCA_ACT_TAB-1], n, pid, ovr);
+		if (ret == -EAGAIN)
+			goto replay;
 		break;
 	case RTM_DELACTION:
 		ret = tca_action_gd(tca[TCA_ACT_TAB-1], n, pid, RTM_DELACTION);
diff -Nru a/net/sched/cls_api.c b/net/sched/cls_api.c
--- a/net/sched/cls_api.c	2005-01-11 22:32:20 +01:00
+++ b/net/sched/cls_api.c	2005-01-11 22:32:20 +01:00
@@ -130,22 +130,30 @@
 
 static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
 {
-	struct rtattr **tca = arg;
-	struct tcmsg *t = NLMSG_DATA(n);
-	u32 protocol = TC_H_MIN(t->tcm_info);
-	u32 prio = TC_H_MAJ(t->tcm_info);
-	u32 nprio = prio;
-	u32 parent = t->tcm_parent;
+	struct rtattr **tca;
+	struct tcmsg *t;
+	u32 protocol;
+	u32 prio;
+	u32 nprio;
+	u32 parent;
 	struct net_device *dev;
 	struct Qdisc  *q;
 	struct tcf_proto **back, **chain;
-	struct tcf_proto *tp = NULL;
+	struct tcf_proto *tp;
 	struct tcf_proto_ops *tp_ops;
 	struct Qdisc_class_ops *cops;
 	unsigned long cl = 0;
 	unsigned long fh;
 	int err;
 
+replay:
+	tca = arg;
+	t = NLMSG_DATA(n);
+	protocol = TC_H_MIN(t->tcm_info);
+	prio = TC_H_MAJ(t->tcm_info);
+	nprio = prio;
+	parent = t->tcm_parent;
+
 	if (prio == 0) {
 		/* If no priority is given, user wants we allocated it. */
 		if (n->nlmsg_type != RTM_NEWTFILTER || !(n->nlmsg_flags&NLM_F_CREATE))
@@ -294,6 +302,9 @@
 errout:
 	if (cl)
 		cops->put(q, cl);
+	if (err == -EAGAIN)
+		/* Replay the request. */
+		goto replay;
 	return err;
 }
 

--------------090903010106030403090009--
