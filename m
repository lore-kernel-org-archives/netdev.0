From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 18/22]: ipt action: fix module refcnt underflow/mem
 leaks in tcf_ipt_cleanup
Date: Mon, 10 Jan 2005 20:38:13 +0100
Message-ID: <41E2D9A5.4070006@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070006030409040304080401"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070006030409040304080401
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------070006030409040304080401
Content-Type: text/x-patch;
 name="18.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="18.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/10 03:28:14+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: ipt action: fix module refcnt underflow/mem leaks in tcf_ipt_cleanup
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/ipt.c
#   2005/01/10 03:28:07+01:00 kaber@coreworks.de +22 -10
#   [PKT_SCHED]: ipt action: fix module refcnt underflow/mem leaks in tcf_ipt_cleanup
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/ipt.c b/net/sched/ipt.c
--- a/net/sched/ipt.c	2005-01-10 06:23:03 +01:00
+++ b/net/sched/ipt.c	2005-01-10 06:23:03 +01:00
@@ -92,6 +92,25 @@
 }
 
 static int
+tcf_ipt_release(struct tcf_ipt *p, int bind)
+{
+	int ret = 0;
+	if (p) {
+		if (bind)
+			p->bindcnt--;
+		p->refcnt--;
+		if (p->bindcnt <= 0 && p->refcnt <= 0) {
+			ipt_destroy_target(p->t);
+			kfree(p->tname);
+			kfree(p->t);
+			tcf_hash_destroy(p);
+			ret = ACT_P_DELETED;
+		}
+	}
+	return ret;
+}
+
+static int
 tcf_ipt_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,
              int ovr, int bind)
 {
@@ -129,7 +148,7 @@
 		ret = ACT_P_CREATED;
 	} else {
 		if (!ovr) {
-			tcf_hash_release(p, bind);
+			tcf_ipt_release(p, bind);
 			return -EEXIST;
 		}
 	}
@@ -178,15 +197,8 @@
 static int
 tcf_ipt_cleanup(struct tc_action *a, int bind)
 {
-	struct tcf_ipt *p = PRIV(a,ipt);
-
-	if (NULL != p) {
-		struct ipt_entry_target *t = p->t;
-		if (t && t->u.kernel.target)
-			module_put(t->u.kernel.target->me);
-		return tcf_hash_release(p, bind);
-	}
-	return 0;
+	struct tcf_ipt *p = PRIV(a, ipt);
+	return tcf_ipt_release(p, bind);
 }
 
 static int

--------------070006030409040304080401--
