From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 PKT_SCHED]: Fix scheduler/classifier module unload race
Date: Sun, 07 Nov 2004 23:41:27 +0100
Message-ID: <418EA497.10302@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090303090605070009050009"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090303090605070009050009
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes an scheduler/classifier module unload race.
struct Qdisc_ops which includes the owner field is also part
of the module's memory, so ops might already be freed when
try_module_get(ops->owner) is called outside of the locked
section.

Regards
Patrick



--------------090303090605070009050009
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/07 05:03:11+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Fix scheduler/classifier module unload race
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/sch_api.c
#   2004/11/07 05:03:04+01:00 kaber@coreworks.de +4 -4
#   [PKT_SCHED]: Fix scheduler/classifier module unload race
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/cls_api.c
#   2004/11/07 05:03:04+01:00 kaber@coreworks.de +4 -6
#   [PKT_SCHED]: Fix scheduler/classifier module unload race
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/cls_api.c b/net/sched/cls_api.c
--- a/net/sched/cls_api.c	2004-11-07 23:32:50 +01:00
+++ b/net/sched/cls_api.c	2004-11-07 23:32:50 +01:00
@@ -60,8 +60,11 @@
 	if (kind) {
 		read_lock(&cls_mod_lock);
 		for (t = tcf_proto_base; t; t = t->next) {
-			if (rtattr_strcmp(kind, t->kind) == 0)
+			if (rtattr_strcmp(kind, t->kind) == 0) {
+				if (!try_module_get(t->owner))
+					t = NULL;
 				break;
+			}
 		}
 		read_unlock(&cls_mod_lock);
 	}
@@ -231,11 +234,6 @@
 		tp->q = q;
 		tp->classify = tp_ops->classify;
 		tp->classid = parent;
-		err = -EBUSY;
-		if (!try_module_get(tp_ops->owner)) {
-			kfree(tp);
-			goto errout;
-		}
 		if ((err = tp_ops->init(tp)) != 0) {
 			module_put(tp_ops->owner);
 			kfree(tp);
diff -Nru a/net/sched/sch_api.c b/net/sched/sch_api.c
--- a/net/sched/sch_api.c	2004-11-07 23:32:50 +01:00
+++ b/net/sched/sch_api.c	2004-11-07 23:32:50 +01:00
@@ -229,8 +229,11 @@
 	if (kind) {
 		read_lock(&qdisc_mod_lock);
 		for (q = qdisc_base; q; q = q->next) {
-			if (rtattr_strcmp(kind, q->id) == 0)
+			if (rtattr_strcmp(kind, q->id) == 0) {
+				if (!try_module_get(q->owner))
+					q = NULL;
 				break;
+			}
 		}
 		read_unlock(&qdisc_mod_lock);
 	}
@@ -408,9 +411,6 @@
 
 	err = -EINVAL;
 	if (ops == NULL)
-		goto err_out;
-	err = -EBUSY;
-	if (!try_module_get(ops->owner))
 		goto err_out;
 
 	/* ensure that the Qdisc and the private data are 32-byte aligned */

--------------090303090605070009050009--
