From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/6] cls_fw: Cleanup fw_classify
Date: Fri, 29 Oct 2004 02:23:18 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029002318.GA12289@postel.suug.ch>
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

Cleans up fw_classify by using the generic routines and
adds a additional but unneeded "continue" to document that
an action may overrule the filter's match result.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk7.orig/net/sched/cls_fw.c	2004-10-28 22:03:29.000000000 +0200
+++ linux-2.6.10-rc1-bk7/net/sched/cls_fw.c	2004-10-29 00:00:50.000000000 +0200
@@ -84,47 +84,39 @@
 	u32 id = 0;
 #endif
 
-	if (head == NULL)
-		goto old_method;
-
-	for (f=head->ht[fw_hash(id)]; f; f=f->next) {
-		if (f->id == id) {
-			*res = f->res;
+	if (head != NULL) {
+		for (f=head->ht[fw_hash(id)]; f; f=f->next) {
+			if (f->id == id) {
+				*res = f->res;
 #ifdef CONFIG_NET_CLS_ACT
 #ifdef CONFIG_NET_CLS_IND
-			if (0 != f->indev[0]) {
-				if  (NULL == skb->input_dev) {
+				if (!tcf_match_indev(skb, f->indev))
+					continue;
+#endif /* CONFIG_NET_CLS_IND */
+				if (f->action) {
+					int act_res = tcf_action_exec(skb, f->action, res);
+					if (act_res >= 0)
+						return act_res;
 					continue;
-				} else {
-					if (0 != strcmp(f->indev, skb->input_dev->name)) {
-						continue;
-					}
 				}
-			}
-#endif
-                               if (f->action) {
-                                       int pol_res = tcf_action_exec(skb, f->action, res);
-                                       if (pol_res >= 0)
-                                               return pol_res;
-                               } else
-#else
+#else /* CONFIG_NET_CLS_ACT */
 #ifdef CONFIG_NET_CLS_POLICE
-			if (f->police)
-				return tcf_police(skb, f->police);
-#endif
-#endif
+				if (f->police)
+					return tcf_police(skb, f->police);
+#endif /* CONFIG_NET_CLS_POLICE */
+#endif /* CONFIG_NET_CLS_ACT */
+				return 0;
+			}
+		}
+	} else {
+		/* old method */
+		if (id && (TC_H_MAJ(id) == 0 || !(TC_H_MAJ(id^tp->q->handle)))) {
+			res->classid = id;
+			res->class = 0;
 			return 0;
 		}
 	}
-	return -1;
 
-old_method:
-	if (id && (TC_H_MAJ(id) == 0 ||
-		     !(TC_H_MAJ(id^tp->q->handle)))) {
-		res->classid = id;
-		res->class = 0;
-		return 0;
-	}
 	return -1;
 }
 
