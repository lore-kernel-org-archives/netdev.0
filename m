From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 8/9] PKT_SCHED: Remove old action/police helpers
Date: Thu, 30 Dec 2004 13:35:41 +0100
Message-ID: <20041230123541.GU32419@postel.suug.ch>
References: <20041230122652.GM32419@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, Patrick McHardy <kaber@trash.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041230122652.GM32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-bk1.orig/include/net/pkt_cls.h	2004-12-27 21:35:31.000000000 +0100
+++ linux-2.6.10-bk1/include/net/pkt_cls.h	2004-12-27 22:46:36.000000000 +0100
@@ -149,88 +149,6 @@
 extern int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts,
 	                       struct tcf_ext_map *map);
 
-#ifdef CONFIG_NET_CLS_ACT
-static inline int
-tcf_change_act_police(struct tcf_proto *tp, struct tc_action **action,
-	struct rtattr *act_police_tlv, struct rtattr *rate_tlv)
-{
-	int ret;
-	struct tc_action *act;
-
-	act = tcf_action_init_1(act_police_tlv, rate_tlv, "police",
-	                        TCA_ACT_NOREPLACE, TCA_ACT_BIND, &ret);
-	if (act == NULL)
-		return ret;
-
-	act->type = TCA_OLD_COMPAT;
-
-	if (*action) {
-		tcf_tree_lock(tp);
-		act = xchg(action, act);
-		tcf_tree_unlock(tp);
-
-		tcf_action_destroy(act, TCA_ACT_UNBIND);
-	} else
-		*action = act;
-
-	return 0;
-}
-
-static inline int
-tcf_change_act(struct tcf_proto *tp, struct tc_action **action,
-	struct rtattr *act_tlv, struct rtattr *rate_tlv)
-{
-	int ret;
-	struct tc_action *act;
-
-	act = tcf_action_init(act_tlv, rate_tlv, NULL,
-	                      TCA_ACT_NOREPLACE, TCA_ACT_BIND, &ret);
-	if (act == NULL)
-		return ret;
-
-	if (*action) {
-		tcf_tree_lock(tp);
-		act = xchg(action, act);
-		tcf_tree_unlock(tp);
-
-		tcf_action_destroy(act, TCA_ACT_UNBIND);
-	} else
-		*action = act;
-
-	return 0;
-}
-
-static inline int
-tcf_dump_act(struct sk_buff *skb, struct tc_action *action,
-	int act_type, int compat_type)
-{
-	/*
-	 * again for backward compatible mode - we want
-	 * to work with both old and new modes of entering
-	 * tc data even if iproute2  was newer - jhs
-	 */
-	if (action) {
-		struct rtattr * p_rta = (struct rtattr*) skb->tail;
-
-		if (action->type != TCA_OLD_COMPAT) {
-			RTA_PUT(skb, act_type, 0, NULL);
-			if (tcf_action_dump(skb, action, 0, 0) < 0)
-				goto rtattr_failure;
-		} else {
-			RTA_PUT(skb, compat_type, 0, NULL);
-			if (tcf_action_dump_old(skb, action, 0, 0) < 0)
-				goto rtattr_failure;
-		}
-		
-		p_rta->rta_len = skb->tail - (u8*)p_rta;
-	}
-	return 0;
-
-rtattr_failure:
-	return -1;
-}
-#endif /* CONFIG_NET_CLS_ACT */
-
 #ifdef CONFIG_NET_CLS_IND
 static inline int
 tcf_change_indev(struct tcf_proto *tp, char *indev, struct rtattr *indev_tlv)
@@ -260,44 +178,4 @@
 }
 #endif /* CONFIG_NET_CLS_IND */
 
-#ifdef CONFIG_NET_CLS_POLICE
-static inline int
-tcf_change_police(struct tcf_proto *tp, struct tcf_police **police,
-	struct rtattr *police_tlv, struct rtattr *rate_tlv)
-{
-	struct tcf_police *p = tcf_police_locate(police_tlv, rate_tlv);
-
-	if (*police) {
-		tcf_tree_lock(tp);
-		p = xchg(police, p);
-		tcf_tree_unlock(tp);
-
-		tcf_police_release(p, TCA_ACT_UNBIND);
-	} else
-		*police = p;
-
-	return 0;
-}
-
-static inline int
-tcf_dump_police(struct sk_buff *skb, struct tcf_police *police,
-	int police_type)
-{
-	if (police) {
-		struct rtattr * p_rta = (struct rtattr*) skb->tail;
-
-		RTA_PUT(skb, police_type, 0, NULL);
-
-		if (tcf_police_dump(skb, police) < 0)
-			goto rtattr_failure;
-
-		p_rta->rta_len = skb->tail - (u8*)p_rta;
-	}
-	return 0;
-
-rtattr_failure:
-	return -1;
-}
-#endif /* CONFIG_NET_CLS_POLICE */
-
 #endif
