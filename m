From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/6] cls_fw: Use generic routines to dump action/policer
Date: Fri, 29 Oct 2004 02:24:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029002459.GC12289@postel.suug.ch>
References: <20041029002113.GY12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041029002113.GY12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk7.orig/net/sched/cls_fw.c	2004-10-29 00:28:59.000000000 +0200
+++ linux-2.6.10-rc1-bk7/net/sched/cls_fw.c	2004-10-29 00:35:27.000000000 +0200
@@ -375,48 +375,18 @@
 	if (f->res.classid)
 		RTA_PUT(skb, TCA_FW_CLASSID, 4, &f->res.classid);
 #ifdef CONFIG_NET_CLS_ACT
-               /* again for backward compatible mode - we want
-               *  to work with both old and new modes of entering
-               *  tc data even if iproute2  was newer - jhs
-               */
-	if (f->action) {
-		struct rtattr * p_rta = (struct rtattr*)skb->tail;
-
-		if (f->action->type != TCA_OLD_COMPAT) {
-			RTA_PUT(skb, TCA_FW_ACT, 0, NULL);
-			if (tcf_action_dump(skb,f->action,0,0) < 0) {
-				goto rtattr_failure;
-			}
-		} else {
-			RTA_PUT(skb, TCA_FW_POLICE, 0, NULL);
-			if (tcf_action_dump_old(skb,f->action,0,0) < 0) {
-				goto rtattr_failure;
-			}
-		}
-
-		p_rta->rta_len = skb->tail - (u8*)p_rta;
-	}
+	if (tcf_dump_act(skb, f->action, TCA_FW_ACT, TCA_FW_POLICE) < 0)
+		goto rtattr_failure;
 #ifdef CONFIG_NET_CLS_IND
-	if(strlen(f->indev)) {
-		struct rtattr * p_rta = (struct rtattr*)skb->tail;
+	if (strlen(f->indev))
 		RTA_PUT(skb, TCA_FW_INDEV, IFNAMSIZ, f->indev);
-		p_rta->rta_len = skb->tail - (u8*)p_rta;
-	}
-#endif
-#else
+#endif /* CONFIG_NET_CLS_IND */
+#else /* CONFIG_NET_CLS_ACT */
 #ifdef CONFIG_NET_CLS_POLICE
-	if (f->police) {
-		struct rtattr * p_rta = (struct rtattr*)skb->tail;
-
-		RTA_PUT(skb, TCA_FW_POLICE, 0, NULL);
-
-		if (tcf_police_dump(skb, f->police) < 0)
-			goto rtattr_failure;
-
-		p_rta->rta_len = skb->tail - (u8*)p_rta;
-	}
-#endif
-#endif
+	if (tcf_dump_police(skb, f->police, TCA_FW_POLICE) < 0)
+		goto rtattr_failure;
+#endif /* CONFIG_NET_CLS_POLICE */
+#endif /* CONFIG_NET_CLS_ACT */
 
 	rta->rta_len = skb->tail - b;
 #ifdef CONFIG_NET_CLS_ACT
