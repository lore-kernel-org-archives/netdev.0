From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 7/11] PKT_SCHED: Move tc_classify from pkt_cls.h to sch_api.c
Date: Wed, 27 Oct 2004 00:27:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026222701.GH12289@postel.suug.ch>
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

tc_classiy has grown too big to be inlined, move it to sch_api.c
and export it.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk1.orig/include/net/pkt_cls.h	2004-10-26 23:19:23.000000000 +0200
+++ linux-2.6.10-rc1-bk1/include/net/pkt_cls.h	2004-10-26 23:27:03.000000000 +0200
@@ -14,51 +14,6 @@
 	int	(*fn)(struct tcf_proto *, unsigned long node, struct tcf_walker *);
 };
 
-/* Main classifier routine: scans classifier chain attached
-   to this qdisc, (optionally) tests for protocol and asks
-   specific classifiers.
- */
-
-static inline int tc_classify(struct sk_buff *skb, struct tcf_proto *tp, struct tcf_result *res)
-{
-	int err = 0;
-	u32 protocol = skb->protocol;
-#ifdef CONFIG_NET_CLS_ACT
-	struct tcf_proto *otp = tp;
-reclassify:
-#endif
-	protocol = skb->protocol;
-
-	for ( ; tp; tp = tp->next) {
-		if ((tp->protocol == protocol ||
-			tp->protocol == __constant_htons(ETH_P_ALL)) &&
-			(err = tp->classify(skb, tp, res)) >= 0) {
-#ifdef CONFIG_NET_CLS_ACT
-			if ( TC_ACT_RECLASSIFY == err) {
-				__u32 verd = (__u32) G_TC_VERD(skb->tc_verd);
-				tp = otp;
-
-				if (MAX_REC_LOOP < verd++) {
-					printk("rule prio %d protocol %02x reclassify is buggy packet dropped\n",tp->prio&0xffff, ntohs(tp->protocol));
-					return TC_ACT_SHOT;
-				}
-				skb->tc_verd = SET_TC_VERD(skb->tc_verd,verd);
-				goto reclassify;
-			} else {
-				if (skb->tc_verd) 
-					skb->tc_verd = SET_TC_VERD(skb->tc_verd,0);
-				return err;
-			}
-#else
-
-			return err;
-#endif
-            }
-
-	}
-	return -1;
-}
-
 extern int register_tcf_proto_ops(struct tcf_proto_ops *ops);
 extern int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
 extern int ing_filter(struct sk_buff *skb);
--- linux-2.6.10-rc1-bk1.orig/include/net/pkt_sched.h	2004-10-26 23:31:17.000000000 +0200
+++ linux-2.6.10-rc1-bk1/include/net/pkt_sched.h	2004-10-26 23:31:50.000000000 +0200
@@ -232,6 +232,9 @@
 
 extern int qdisc_restart(struct net_device *dev);
 
+extern int tc_classify(struct sk_buff *skb, struct tcf_proto *tp,
+	struct tcf_result *res);
+
 /* Calculate maximal size of packet seen by hard_start_xmit
    routine of this device.
  */
--- linux-2.6.10-rc1-bk1.orig/net/sched/sch_api.c	2004-10-26 22:57:06.000000000 +0200
+++ linux-2.6.10-rc1-bk1/net/sched/sch_api.c	2004-10-26 23:34:40.000000000 +0200
@@ -1099,6 +1099,52 @@
 	return skb->len;
 }
 
+/* Main classifier routine: scans classifier chain attached
+   to this qdisc, (optionally) tests for protocol and asks
+   specific classifiers.
+ */
+int tc_classify(struct sk_buff *skb, struct tcf_proto *tp,
+	struct tcf_result *res)
+{
+	int err = 0;
+	u32 protocol = skb->protocol;
+#ifdef CONFIG_NET_CLS_ACT
+	struct tcf_proto *otp = tp;
+reclassify:
+#endif
+	protocol = skb->protocol;
+
+	for ( ; tp; tp = tp->next) {
+		if ((tp->protocol == protocol ||
+			tp->protocol == __constant_htons(ETH_P_ALL)) &&
+			(err = tp->classify(skb, tp, res)) >= 0) {
+#ifdef CONFIG_NET_CLS_ACT
+			if ( TC_ACT_RECLASSIFY == err) {
+				__u32 verd = (__u32) G_TC_VERD(skb->tc_verd);
+				tp = otp;
+
+				if (MAX_REC_LOOP < verd++) {
+					printk("rule prio %d protocol %02x reclassify is buggy packet dropped\n",
+						tp->prio&0xffff, ntohs(tp->protocol));
+					return TC_ACT_SHOT;
+				}
+				skb->tc_verd = SET_TC_VERD(skb->tc_verd,verd);
+				goto reclassify;
+			} else {
+				if (skb->tc_verd) 
+					skb->tc_verd = SET_TC_VERD(skb->tc_verd,0);
+				return err;
+			}
+#else
+
+			return err;
+#endif
+		}
+
+	}
+	return -1;
+}
+
 int psched_us_per_tick = 1;
 int psched_tick_per_us = 1;
 
@@ -1246,3 +1292,4 @@
 EXPORT_SYMBOL(qdisc_put_rtab);
 EXPORT_SYMBOL(register_qdisc);
 EXPORT_SYMBOL(unregister_qdisc);
+EXPORT_SYMBOL(tc_classify);
