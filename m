From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 7/6] cls_fw: CONFIG_NET_CLS_IND is not dependant on CONFIG_NET_CLS_ACT
Date: Fri, 29 Oct 2004 12:26:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029102620.GH12289@postel.suug.ch>
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

--- linux-2.6.10-rc1-bk7.orig/net/sched/cls_fw.c	2004-10-29 12:14:07.000000000 +0200
+++ linux-2.6.10-rc1-bk7/net/sched/cls_fw.c	2004-10-29 12:15:27.000000000 +0200
@@ -56,11 +56,11 @@
 	struct fw_filter	*next;
 	u32			id;
 	struct tcf_result	res;
-#ifdef CONFIG_NET_CLS_ACT
-	struct tc_action        *action;
 #ifdef CONFIG_NET_CLS_IND
 	char			indev[IFNAMSIZ];
 #endif /* CONFIG_NET_CLS_IND */
+#ifdef CONFIG_NET_CLS_ACT
+	struct tc_action        *action;
 #else /* CONFIG_NET_CLS_ACT */
 #ifdef CONFIG_NET_CLS_POLICE
 	struct tcf_police	*police;
@@ -88,11 +88,11 @@
 		for (f=head->ht[fw_hash(id)]; f; f=f->next) {
 			if (f->id == id) {
 				*res = f->res;
-#ifdef CONFIG_NET_CLS_ACT
 #ifdef CONFIG_NET_CLS_IND
 				if (!tcf_match_indev(skb, f->indev))
 					continue;
 #endif /* CONFIG_NET_CLS_IND */
+#ifdef CONFIG_NET_CLS_ACT
 				if (f->action) {
 					int act_res = tcf_action_exec(skb, f->action, res);
 					if (act_res >= 0)
@@ -217,6 +217,14 @@
 		tcf_bind_filter(tp, &f->res, base);
 	}
 
+#ifdef CONFIG_NET_CLS_IND
+	if (tb[TCA_FW_INDEV-1]) {
+		err = tcf_change_indev(tp, f->indev, tb[TCA_FW_INDEV-1]);
+		if (err < 0)
+			goto errout;
+	}
+#endif /* CONFIG_NET_CLS_IND */
+
 #ifdef CONFIG_NET_CLS_ACT
 	if (tb[TCA_FW_POLICE-1]) {
 		err = tcf_change_act_police(tp, &f->action, tb[TCA_FW_POLICE-1],
@@ -231,14 +239,6 @@
 		if (err < 0)
 			goto errout;
 	}
-
-#ifdef CONFIG_NET_CLS_IND
-	if (tb[TCA_FW_INDEV-1]) {
-		err = tcf_change_indev(tp, f->indev, tb[TCA_FW_INDEV-1]);
-		if (err < 0)
-			goto errout;
-	}
-#endif /* CONFIG_NET_CLS_IND */
 #else /* CONFIG_NET_CLS_ACT */
 #ifdef CONFIG_NET_CLS_POLICE
 	if (tb[TCA_FW_POLICE-1]) {
@@ -373,13 +373,13 @@
 
 	if (f->res.classid)
 		RTA_PUT(skb, TCA_FW_CLASSID, 4, &f->res.classid);
-#ifdef CONFIG_NET_CLS_ACT
-	if (tcf_dump_act(skb, f->action, TCA_FW_ACT, TCA_FW_POLICE) < 0)
-		goto rtattr_failure;
 #ifdef CONFIG_NET_CLS_IND
 	if (strlen(f->indev))
 		RTA_PUT(skb, TCA_FW_INDEV, IFNAMSIZ, f->indev);
 #endif /* CONFIG_NET_CLS_IND */
+#ifdef CONFIG_NET_CLS_ACT
+	if (tcf_dump_act(skb, f->action, TCA_FW_ACT, TCA_FW_POLICE) < 0)
+		goto rtattr_failure;
 #else /* CONFIG_NET_CLS_ACT */
 #ifdef CONFIG_NET_CLS_POLICE
 	if (tcf_dump_police(skb, f->police, TCA_FW_POLICE) < 0)
