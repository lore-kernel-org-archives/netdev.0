From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 1/7]: Fix module leak in tc_ctl_tfilter error path
Date: Sun, 03 Oct 2004 23:12:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41606B50.3080201@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000601040605010702000606"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000601040605010702000606
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

When tp_ops->init fails we leak a module reference.



--------------000601040605010702000606
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/03 20:25:10+02:00 kaber@coreworks.de 
#   [NET_SCHED]: Fix module leak in tc_ctl_tfilter error path
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/cls_api.c
#   2004/10/03 20:24:47+02:00 kaber@coreworks.de +6 -2
#   [NET_SCHED]: Fix module leak in tc_ctl_tfilter error path
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/cls_api.c b/net/sched/cls_api.c
--- a/net/sched/cls_api.c	2004-10-03 22:18:04 +02:00
+++ b/net/sched/cls_api.c	2004-10-03 22:18:04 +02:00
@@ -231,8 +231,12 @@
 		tp->classify = tp_ops->classify;
 		tp->classid = parent;
 		err = -EBUSY;
-		if (!try_module_get(tp_ops->owner) ||
-		    (err = tp_ops->init(tp)) != 0) {
+		if (!try_module_get(tp_ops->owner)) {
+			kfree(tp);
+			goto errout;
+		}
+		if ((err = tp_ops->init(tp)) != 0) {
+			module_put(tp_ops->owner);
 			kfree(tp);
 			goto errout;
 		}

--------------000601040605010702000606--
