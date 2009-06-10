From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 10/31: xtables: consolidate comefrom debug cast access
Date: Wed, 10 Jun 2009 21:46:35 +0200 (MEST)
Message-ID: <20090610194633.11112.81944.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit bb70dfa5f8ab4a0f1c699ddb3ef0276d91219b7c
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Apr 15 21:40:13 2009 +0200

    netfilter: xtables: consolidate comefrom debug cast access
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index d91ecd4..7b35c0b 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -311,6 +311,8 @@ ipt_do_table(struct sk_buff *skb,
 	     const struct net_device *out,
 	     struct xt_table *table)
 {
+#define tb_comefrom ((struct ipt_entry *)table_base)->comefrom
+
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	const struct iphdr *ip;
 	u_int16_t datalen;
@@ -409,18 +411,19 @@ ipt_do_table(struct sk_buff *skb,
 		   abs. verdicts */
 		tgpar.target   = t->u.kernel.target;
 		tgpar.targinfo = t->data;
+
+
 #ifdef CONFIG_NETFILTER_DEBUG
-		((struct ipt_entry *)table_base)->comefrom = 0xeeeeeeec;
+		tb_comefrom = 0xeeeeeeec;
 #endif
 		verdict = t->u.kernel.target->target(skb, &tgpar);
 #ifdef CONFIG_NETFILTER_DEBUG
-		if (((struct ipt_entry *)table_base)->comefrom != 0xeeeeeeec &&
-		    verdict == IPT_CONTINUE) {
+		if (comefrom != 0xeeeeeeec && verdict == IPT_CONTINUE) {
 			printk("Target %s reentered!\n",
 			       t->u.kernel.target->name);
 			verdict = NF_DROP;
 		}
-		((struct ipt_entry *)table_base)->comefrom = 0x57acc001;
+		tb_comefrom = 0x57acc001;
 #endif
 		/* Target might have changed stuff. */
 		ip = ip_hdr(skb);
@@ -441,6 +444,8 @@ ipt_do_table(struct sk_buff *skb,
 		return NF_DROP;
 	else return verdict;
 #endif
+
+#undef tb_comefrom
 }
 
 /* Figures out from what hook each rule can be called: returns 0 if
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 5a178be..5164e0b 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -343,6 +343,8 @@ ip6t_do_table(struct sk_buff *skb,
 	      const struct net_device *out,
 	      struct xt_table *table)
 {
+#define tb_comefrom ((struct ip6t_entry *)table_base)->comefrom
+
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	bool hotdrop = false;
 	/* Initializing verdict to NF_DROP keeps gcc happy. */
@@ -440,18 +442,17 @@ ip6t_do_table(struct sk_buff *skb,
 		tgpar.targinfo = t->data;
 
 #ifdef CONFIG_NETFILTER_DEBUG
-		((struct ip6t_entry *)table_base)->comefrom = 0xeeeeeeec;
+		tb_comefrom = 0xeeeeeeec;
 #endif
 		verdict = t->u.kernel.target->target(skb, &tgpar);
 
 #ifdef CONFIG_NETFILTER_DEBUG
-		if (((struct ip6t_entry *)table_base)->comefrom != 0xeeeeeeec &&
-		    verdict == IP6T_CONTINUE) {
+		if (tb_comefrom != 0xeeeeeeec && verdict == IP6T_CONTINUE) {
 			printk("Target %s reentered!\n",
 			       t->u.kernel.target->name);
 			verdict = NF_DROP;
 		}
-		((struct ip6t_entry *)table_base)->comefrom = 0x57acc001;
+		tb_comefrom = 0x57acc001;
 #endif
 		if (verdict == IP6T_CONTINUE)
 			e = ip6t_next_entry(e);
@@ -461,7 +462,7 @@ ip6t_do_table(struct sk_buff *skb,
 	} while (!hotdrop);
 
 #ifdef CONFIG_NETFILTER_DEBUG
-	((struct ip6t_entry *)table_base)->comefrom = NETFILTER_LINK_POISON;
+	tb_comefrom = NETFILTER_LINK_POISON;
 #endif
 	xt_info_rdunlock_bh();
 
@@ -472,6 +473,8 @@ ip6t_do_table(struct sk_buff *skb,
 		return NF_DROP;
 	else return verdict;
 #endif
+
+#undef tb_comefrom
 }
 
 /* Figures out from what hook each rule can be called: returns 0 if
