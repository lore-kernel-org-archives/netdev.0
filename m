From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] PKT_SCHED: Fix double locking in tcindex destroy path
Date: Fri, 10 Dec 2004 02:49:18 +0100
Message-ID: <20041210014918.GT1371@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

tcindex's destroy uses its own delete functions to destroy its
configuration. The delete function (correctly) takes the qdisc_tree_lock
to prevent list walkings from happening while removing from the list.
The qdisc_tree_lock is already held if we're comming via the destroy
path and thus a double locking takes place.

Patch not needed for 2.4 since both destroy paths are unlocked but will
be needed if we add them.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc2-bk13.orig/net/sched/cls_tcindex.c	2004-11-30 14:01:12.000000000 +0100
+++ linux-2.6.10-rc2-bk13/net/sched/cls_tcindex.c	2004-12-10 02:20:51.000000000 +0100
@@ -160,7 +160,8 @@
 }
 
 
-static int tcindex_delete(struct tcf_proto *tp, unsigned long arg)
+static int
+__tcindex_delete(struct tcf_proto *tp, unsigned long arg, int already_locked)
 {
 	struct tcindex_data *p = PRIV(tp);
 	struct tcindex_filter_result *r = (struct tcindex_filter_result *) arg;
@@ -182,9 +183,11 @@
 
 found:
 		f = *walk;
-		tcf_tree_lock(tp); 
+		if (!already_locked)
+			tcf_tree_lock(tp);
 		*walk = f->next;
-		tcf_tree_unlock(tp);
+		if (!already_locked)
+			tcf_tree_unlock(tp);
 	}
 	tcf_unbind_filter(tp, &r->res);
 #ifdef CONFIG_NET_CLS_POLICE
@@ -195,6 +198,10 @@
 	return 0;
 }
 
+static int tcindex_delete(struct tcf_proto *tp, unsigned long arg)
+{
+	return __tcindex_delete(tp, arg, 0);
+}
 
 /*
  * There are no parameters for tcindex_init, so we overload tcindex_change
@@ -384,7 +391,7 @@
 static int tcindex_destroy_element(struct tcf_proto *tp,
     unsigned long arg, struct tcf_walker *walker)
 {
-	return tcindex_delete(tp,arg);
+	return __tcindex_delete(tp,arg, 1);
 }
 
 
