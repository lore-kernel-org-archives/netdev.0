From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 9/11] PKT_SCHED: Cleanup cls_set_class
Date: Wed, 27 Oct 2004 00:28:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026222813.GJ12289@postel.suug.ch>
References: <20041026222148.GA12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041026222148.GA12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Clean up a really messy cross reference where a macro cls_set_class
in pkt_sched.h would point to a function tcf_set_class in cls_api.c
that uses a inlined function __cls_set_class in pkt_sched.h again.

Make tcf_set_class be cls_set_class since it was never used and
inline it as well.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk1.orig/include/net/pkt_cls.h	2004-10-26 23:36:12.000000000 +0200
+++ linux-2.6.10-rc1-bk1/include/net/pkt_cls.h	2004-10-26 23:39:34.000000000 +0200
@@ -18,4 +18,29 @@
 extern int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
 extern int ing_filter(struct sk_buff *skb);
 
+static inline unsigned long
+__cls_set_class(unsigned long *clp, unsigned long cl)
+{
+	unsigned long old_cl;
+ 
+	old_cl = *clp;
+	*clp = cl;
+	return old_cl;
+}
+
+static inline long
+cls_set_class(struct tcf_proto *tp, unsigned long *clp, 
+	unsigned long cl)
+{
+	unsigned long old_cl;
+	
+	qdisc_lock_tree(tp->q->dev);
+
+	tcf_tree_lock(tp);
+	old_cl = __cls_set_class(clp, cl);
+	tcf_tree_unlock(tp);
+ 
+	return old_cl;
+}
+
 #endif
--- linux-2.6.10-rc1-bk1.orig/include/net/pkt_sched.h	2004-10-26 23:36:12.000000000 +0200
+++ linux-2.6.10-rc1-bk1/include/net/pkt_sched.h	2004-10-26 23:40:20.000000000 +0200
@@ -22,18 +22,6 @@
 			      & ~QDISC_ALIGN_CONST);
 }
 
-#define cls_set_class(tp, clp, cl) tcf_set_class(tp, clp, cl)
-static inline unsigned long
-__cls_set_class(unsigned long *clp, unsigned long cl)
-{
-	unsigned long old_cl;
-
-	old_cl = *clp;
-	*clp = cl;
-	return old_cl;
-}
-
-
 /* 
    Timer resolution MUST BE < 10% of min_schedulable_packet_size/bandwidth
    
--- linux-2.6.10-rc1-bk1.orig/net/sched/cls_api.c	2004-10-26 22:57:08.000000000 +0200
+++ linux-2.6.10-rc1-bk1/net/sched/cls_api.c	2004-10-26 23:41:23.000000000 +0200
@@ -297,19 +297,6 @@
 	return err;
 }
 
-unsigned long tcf_set_class(struct tcf_proto *tp, unsigned long *clp, 
-			    unsigned long cl)
-{
-	unsigned long old_cl;
-
-	tcf_tree_lock(tp);
-	old_cl = __cls_set_class(clp, cl);
-	tcf_tree_unlock(tp);
-
-	return old_cl;
-}
-
-
 static int
 tcf_fill_node(struct sk_buff *skb, struct tcf_proto *tp, unsigned long fh,
 	      u32 pid, u32 seq, unsigned flags, int event)
@@ -475,4 +462,3 @@
 
 EXPORT_SYMBOL(register_tcf_proto_ops);
 EXPORT_SYMBOL(unregister_tcf_proto_ops);
-EXPORT_SYMBOL(tcf_set_class);
