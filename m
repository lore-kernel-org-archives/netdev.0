From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/9] PKT_SCHED: tc filter extension API
Date: Thu, 30 Dec 2004 13:30:23 +0100
Message-ID: <20041230123023.GO32419@postel.suug.ch>
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

The tcf_exts API abstracts extensions such as actions/policers
into a generic layer and reduces the knowledge inside classifiers
to the minimum required. It isolates the validation code into
its own function to allow classifiers to validate all input
data before making changes and thus avoids the need to undo changes
if a extension configuration request cannot be fullfilled.

As a nice side effect, using this API removes the existing
ifdef clutter.

Usage:
  The classifier holds struct tcf_exts which may be empty if no
  extensions are compiled in. It then calls tcf_exts_validate
  when a new change request was received and provides a temporary
  tcf_exts copy to store the change requests. Given it succeeded
  the classifier may change its own parameters and at the end
  call tcf_exts_change to commit the changes and replace the
  existing extension configuration with the new one. The classifier
  is responsible to destroy his temporary copy if any of its own
  validation checks fail.

  The classifier specific TLV types must be exported to the extensions
  API via tcf_ext_map.

  Destroying the extensions is as easy as calling tcf_exts_destroy.

  The extensions are executed by the classifier by calling tcf_exts_exec
  which must be done as the last thing after making sure the
  filter matches. Note: A classifier might take further actions after
  the execution to tcf_exts_exec such as correcting its own cache to
  avoid caching results which could have been influenced by the extensions.

  tcf_exts_exec returns a negative error code if the filter must be
  considered unmatched, 0 on normal execution or a positive classifier
  return code (TC_ACT_*) which must be returned to the underlying layer
  as-is.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-bk2.orig/include/net/pkt_cls.h	2004-12-30 01:22:01.000000000 +0100
+++ linux-2.6.10-bk2/include/net/pkt_cls.h	2004-12-30 01:22:39.000000000 +0100
@@ -62,6 +62,93 @@
 		tp->q->ops->cl_ops->unbind_tcf(tp->q, cl);
 }
 
+struct tcf_exts
+{
+#ifdef CONFIG_NET_CLS_ACT
+	struct tc_action *action;
+#elif defined CONFIG_NET_CLS_POLICE
+	struct tcf_police *police;
+#endif
+};
+
+/* Map to export classifier specific extension TLV types to the
+ * generic extensions API. Unsupported extensions must be set to 0.
+ */
+struct tcf_ext_map
+{
+	int action;
+	int police;
+};
+
+/**
+ * tcf_exts_is_predicative - check if a predicative extension is present
+ * @exts: tc filter extensions handle
+ *
+ * Returns 1 if a predicative extension is present, i.e. an extension which
+ * might cause further actions and thus overrule the regular tcf_result.
+ */
+static inline int
+tcf_exts_is_predicative(struct tcf_exts *exts)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	return !!exts->action;
+#elif defined CONFIG_NET_CLS_POLICE
+	return !!exts->police;
+#else
+	return 0;
+#endif
+}
+
+/**
+ * tcf_exts_is_available - check if at least one extension is present
+ * @exts: tc filter extensions handle
+ *
+ * Returns 1 if at least one extension is present.
+ */
+static inline int
+tcf_exts_is_available(struct tcf_exts *exts)
+{
+	/* All non-predicative extensions must be added here. */
+	return tcf_exts_is_predicative(exts);
+}
+
+/**
+ * tcf_exts_exec - execute tc filter extensions
+ * @skb: socket buffer
+ * @exts: tc filter extensions handle
+ * @res: desired result
+ *
+ * Executes all configured extensions. Returns 0 on a normal execution,
+ * a negative number if the filter must be considered unmatched or
+ * a positive action code (TC_ACT_*) which must be returned to the
+ * underlying layer.
+ */
+static inline int
+tcf_exts_exec(struct sk_buff *skb, struct tcf_exts *exts,
+	       struct tcf_result *res)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	if (exts->action)
+		return tcf_action_exec(skb, exts->action, res);
+#elif defined CONFIG_NET_CLS_POLICE
+	if (exts->police)
+		return tcf_police(skb, exts->police);
+#endif
+
+	return 0;
+}
+
+extern int tcf_exts_validate(struct tcf_proto *tp, struct rtattr **tb,
+	                     struct rtattr *rate_tlv, struct tcf_exts *exts,
+	                     struct tcf_ext_map *map);
+extern void tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts);
+extern void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
+	                     struct tcf_exts *src);
+extern int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts,
+	                 struct tcf_ext_map *map);
+extern int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts,
+	                       struct tcf_ext_map *map);
+
 #ifdef CONFIG_NET_CLS_ACT
 static inline int
 tcf_change_act_police(struct tcf_proto *tp, struct tc_action **action,
--- linux-2.6.10-bk2.orig/net/sched/cls_api.c	2004-12-30 01:22:01.000000000 +0100
+++ linux-2.6.10-bk2/net/sched/cls_api.c	2004-12-30 00:47:06.000000000 +0100
@@ -439,6 +439,162 @@
 	return skb->len;
 }
 
+void
+tcf_exts_destroy(struct tcf_proto *tp, struct tcf_exts *exts)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	if (exts->action) {
+		tcf_action_destroy(exts->action, TCA_ACT_UNBIND);
+		exts->action = NULL;
+	}
+#elif defined CONFIG_NET_CLS_POLICE
+	if (exts->police) {
+		tcf_police_release(exts->police, TCA_ACT_UNBIND);
+		exts->police = NULL;
+	}
+#endif
+}
+
+
+int
+tcf_exts_validate(struct tcf_proto *tp, struct rtattr **tb,
+	          struct rtattr *rate_tlv, struct tcf_exts *exts,
+	          struct tcf_ext_map *map)
+{
+	memset(exts, 0, sizeof(*exts));
+	
+#ifdef CONFIG_NET_CLS_ACT
+	int err;
+	struct tc_action *act;
+
+	if (map->police && tb[map->police-1] && rate_tlv) {
+		act = tcf_action_init_1(tb[map->police-1], rate_tlv, "police",
+			TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
+		if (NULL == act)
+			return err;
+
+		act->type = TCA_OLD_COMPAT;
+		exts->action = act;
+	} else if (map->action && tb[map->action-1] && rate_tlv) {
+		act = tcf_action_init(tb[map->action-1], rate_tlv, NULL,
+			TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
+		if (NULL == act)
+			return err;
+
+		exts->action = act;
+	}
+#elif defined CONFIG_NET_CLS_POLICE
+	if (map->police && tb[map->police-1] && rate_tlv) {
+		struct tcf_police *p;
+		
+		p = tcf_police_locate(tb[map->police-1], rate_tlv);
+		if (NULL == p)
+			return -EINVAL;
+
+		exts->police = p;
+	} else if (map->action && tb[map->action-1])
+		return -EOPNOTSUPP;
+#else
+	if ((map->action && tb[map->action-1]) ||
+	    (map->police && tb[map->police-1]))
+		return -EOPNOTSUPP;
+#endif
+
+	return 0;
+}
+
+void
+tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
+	        struct tcf_exts *src)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	if (src->action) {
+		if (dst->action) {
+			struct tc_action *act;
+
+			tcf_tree_lock(tp);
+			act = xchg(&dst->action, src->action);
+			tcf_tree_unlock(tp);
+
+			tcf_action_destroy(act, TCA_ACT_UNBIND);
+		} else
+			dst->action = src->action;
+	}
+#elif defined CONFIG_NET_CLS_POLICE
+	if (src->police) {
+		if (dst->police) {
+			struct tcf_police *p;
+
+			tcf_tree_lock(tp);
+			p = xchg(&dst->police, src->police);
+			tcf_tree_unlock(tp);
+
+			tcf_police_release(p, TCA_ACT_UNBIND);
+		} else
+			dst->police = src->police;
+	}
+#endif
+}
+
+int
+tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts,
+	      struct tcf_ext_map *map)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	if (map->action && exts->action) {
+		/*
+		 * again for backward compatible mode - we want
+		 * to work with both old and new modes of entering
+		 * tc data even if iproute2  was newer - jhs
+		 */
+		struct rtattr * p_rta = (struct rtattr*) skb->tail;
+
+		if (exts->action->type != TCA_OLD_COMPAT) {
+			RTA_PUT(skb, map->action, 0, NULL);
+			if (tcf_action_dump(skb, exts->action, 0, 0) < 0)
+				goto rtattr_failure;
+			p_rta->rta_len = skb->tail - (u8*)p_rta;
+		} else if (map->police) {
+			RTA_PUT(skb, map->police, 0, NULL);
+			if (tcf_action_dump_old(skb, exts->action, 0, 0) < 0)
+				goto rtattr_failure;
+			p_rta->rta_len = skb->tail - (u8*)p_rta;
+		}
+	}
+#elif defined CONFIG_NET_CLS_POLICE
+	if (map->police && exts->police) {
+		struct rtattr * p_rta = (struct rtattr*) skb->tail;
+
+		RTA_PUT(skb, map->police, 0, NULL);
+
+		if (tcf_police_dump(skb, exts->police) < 0)
+			goto rtattr_failure;
+
+		p_rta->rta_len = skb->tail - (u8*)p_rta;
+	}
+#endif
+	return 0;
+rtattr_failure:
+	return -1;
+}
+
+int
+tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts,
+	            struct tcf_ext_map *map)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	if (exts->action)
+		if (tcf_action_copy_stats(skb, exts->action) < 0)
+			goto rtattr_failure;
+#elif defined CONFIG_NET_CLS_POLICE
+	if (exts->police)
+		if (tcf_police_dump_stats(skb, exts->police) < 0)
+			goto rtattr_failure;
+#endif
+	return 0;
+rtattr_failure:
+	return -1;
+}
 
 static int __init tc_filter_init(void)
 {
@@ -461,3 +617,8 @@
 
 EXPORT_SYMBOL(register_tcf_proto_ops);
 EXPORT_SYMBOL(unregister_tcf_proto_ops);
+EXPORT_SYMBOL(tcf_exts_validate);
+EXPORT_SYMBOL(tcf_exts_destroy);
+EXPORT_SYMBOL(tcf_exts_change);
+EXPORT_SYMBOL(tcf_exts_dump);
+EXPORT_SYMBOL(tcf_exts_dump_stats);
