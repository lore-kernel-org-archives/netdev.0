From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH PKT_SCHED 2/6]: Fix memory leaks in cls_u32.c error path
Date: Tue, 11 Jan 2005 22:46:20 +0100
Message-ID: <41E4492C.7050703@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080407090209000003070504"
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080407090209000003070504
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------080407090209000003070504
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/11 20:25:26+01:00 kaber@coreworks.de 
#   [PKT_SCHED]: Fix memory leaks in cls_u32.c error path
#   
#   Also silence an unused-variable warning when CONFIG_CLS_U32_MARK is not set.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
# net/sched/cls_u32.c
#   2005/01/11 20:25:16+01:00 kaber@coreworks.de +11 -5
#   [PKT_SCHED]: Fix memory leaks in cls_u32.c error path
#   
#   Also silence an unused-variable warning when CONFIG_CLS_U32_MARK is not set.
#   
#   Signed-off-by: Patrick McHardy <kaber@trash.net>
# 
diff -Nru a/net/sched/cls_u32.c b/net/sched/cls_u32.c
--- a/net/sched/cls_u32.c	2005-01-11 22:32:10 +01:00
+++ b/net/sched/cls_u32.c	2005-01-11 22:32:10 +01:00
@@ -549,7 +549,6 @@
 	struct tc_u_hnode *ht;
 	struct tc_u_knode *n;
 	struct tc_u32_sel *s;
-	struct tc_u32_mark *mark;
 	struct rtattr *opt = tca[TCA_OPTIONS-1];
 	struct rtattr *tb[TCA_U32_MAX];
 	u32 htid;
@@ -654,15 +653,22 @@
 	n->fshift = i;
 }
 
-#ifdef CONFIG_CLS_U32_MARK                                                                                                                                             
+#ifdef CONFIG_CLS_U32_MARK
 	if (tb[TCA_U32_MARK-1]) {
-		if (RTA_PAYLOAD(tb[TCA_U32_MARK-1]) < sizeof(struct tc_u32_mark))
+		struct tc_u32_mark *mark;
+
+		if (RTA_PAYLOAD(tb[TCA_U32_MARK-1]) < sizeof(struct tc_u32_mark)) {
+#ifdef CONFIG_CLS_U32_PERF
+			kfree(n->pf);
+#endif
+			kfree(n);
 			return -EINVAL;
+		}
 		mark = RTA_DATA(tb[TCA_U32_MARK-1]);
 		memcpy(&n->mark, mark, sizeof(struct tc_u32_mark));
 		n->mark.success = 0;
-	}                                                                                                                                                                
-#endif                                                                                                                                                                 
+	}
+#endif
 
 	err = u32_set_parms(tp, base, ht, n, tb, tca[TCA_RATE-1]);
 	if (err == 0) {

--------------080407090209000003070504--
