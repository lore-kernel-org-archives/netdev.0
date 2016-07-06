From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 25/26] netfilter: Convert FWINV<[foo]> macros and uses to NF_INVF
Date: Wed,  6 Jul 2016 16:24:07 +0200
Message-ID: <1467815048-2240-26-git-send-email-pablo@netfilter.org>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>

netfilter uses multiple FWINV #defines with identical form that hide a
specific structure variable and dereference it with a invflags member.

$ git grep "#define FWINV"
include/linux/netfilter_bridge/ebtables.h:#define FWINV(bool,invflg) ((bool) ^ !!(info->invflags & invflg))
net/bridge/netfilter/ebtables.c:#define FWINV2(bool, invflg) ((bool) ^ !!(e->invflags & invflg))
net/ipv4/netfilter/arp_tables.c:#define FWINV(bool, invflg) ((bool) ^ !!(arpinfo->invflags & (invflg)))
net/ipv4/netfilter/ip_tables.c:#define FWINV(bool, invflg) ((bool) ^ !!(ipinfo->invflags & (invflg)))
net/ipv6/netfilter/ip6_tables.c:#define FWINV(bool, invflg) ((bool) ^ !!(ip6info->invflags & (invflg)))
net/netfilter/xt_tcpudp.c:#define FWINVTCP(bool, invflg) ((bool) ^ !!(tcpinfo->invflags & (invflg)))

Consolidate these macros into a single NF_INVF macro.

Miscellanea:

o Neaten the alignment around these uses
o A few lines are > 80 columns for intelligibility

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/x_tables.h        |  4 +++
 include/linux/netfilter_bridge/ebtables.h |  2 --
 net/bridge/netfilter/ebt_802_3.c          |  6 ++--
 net/bridge/netfilter/ebt_arp.c            | 38 +++++++++++-----------
 net/bridge/netfilter/ebt_ip.c             | 28 ++++++++---------
 net/bridge/netfilter/ebt_ip6.c            | 41 +++++++++++++-----------
 net/bridge/netfilter/ebt_stp.c            | 52 ++++++++++++++++---------------
 net/bridge/netfilter/ebtables.c           | 27 ++++++++--------
 net/ipv4/netfilter/arp_tables.c           | 41 ++++++++++++------------
 net/ipv4/netfilter/ip_tables.c            | 20 ++++++------
 net/ipv6/netfilter/ip6_tables.c           | 16 +++++-----
 net/netfilter/xt_tcpudp.c                 |  7 ++---
 12 files changed, 144 insertions(+), 138 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index dc4f58a..e94e81a 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -6,6 +6,10 @@
 #include <linux/static_key.h>
 #include <uapi/linux/netfilter/x_tables.h>
 
+/* Test a struct->invflags and a boolean for inequality */
+#define NF_INVF(ptr, flag, boolean)					\
+	((boolean) ^ !!((ptr)->invflags & (flag)))
+
 /**
  * struct xt_action_param - parameters for matches/targets
  *
diff --git a/include/linux/netfilter_bridge/ebtables.h b/include/linux/netfilter_bridge/ebtables.h
index 2ea517c..984b211 100644
--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -115,8 +115,6 @@ extern unsigned int ebt_do_table(struct sk_buff *skb,
 				 const struct nf_hook_state *state,
 				 struct ebt_table *table);
 
-/* Used in the kernel match() functions */
-#define FWINV(bool,invflg) ((bool) ^ !!(info->invflags & invflg))
 /* True if the hook mask denotes that the rule is in a base chain,
  * used in the check() functions */
 #define BASE_CHAIN (par->hook_mask & (1 << NF_BR_NUMHOOKS))
diff --git a/net/bridge/netfilter/ebt_802_3.c b/net/bridge/netfilter/ebt_802_3.c
index 2a449b7..5fc4aff 100644
--- a/net/bridge/netfilter/ebt_802_3.c
+++ b/net/bridge/netfilter/ebt_802_3.c
@@ -20,16 +20,16 @@ ebt_802_3_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	__be16 type = hdr->llc.ui.ctrl & IS_UI ? hdr->llc.ui.type : hdr->llc.ni.type;
 
 	if (info->bitmask & EBT_802_3_SAP) {
-		if (FWINV(info->sap != hdr->llc.ui.ssap, EBT_802_3_SAP))
+		if (NF_INVF(info, EBT_802_3_SAP, info->sap != hdr->llc.ui.ssap))
 			return false;
-		if (FWINV(info->sap != hdr->llc.ui.dsap, EBT_802_3_SAP))
+		if (NF_INVF(info, EBT_802_3_SAP, info->sap != hdr->llc.ui.dsap))
 			return false;
 	}
 
 	if (info->bitmask & EBT_802_3_TYPE) {
 		if (!(hdr->llc.ui.dsap == CHECK_TYPE && hdr->llc.ui.ssap == CHECK_TYPE))
 			return false;
-		if (FWINV(info->type != type, EBT_802_3_TYPE))
+		if (NF_INVF(info, EBT_802_3_TYPE, info->type != type))
 			return false;
 	}
 
diff --git a/net/bridge/netfilter/ebt_arp.c b/net/bridge/netfilter/ebt_arp.c
index cca0a89..2271422 100644
--- a/net/bridge/netfilter/ebt_arp.c
+++ b/net/bridge/netfilter/ebt_arp.c
@@ -25,14 +25,14 @@ ebt_arp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	ah = skb_header_pointer(skb, 0, sizeof(_arph), &_arph);
 	if (ah == NULL)
 		return false;
-	if (info->bitmask & EBT_ARP_OPCODE && FWINV(info->opcode !=
-	   ah->ar_op, EBT_ARP_OPCODE))
+	if ((info->bitmask & EBT_ARP_OPCODE) &&
+	    NF_INVF(info, EBT_ARP_OPCODE, info->opcode != ah->ar_op))
 		return false;
-	if (info->bitmask & EBT_ARP_HTYPE && FWINV(info->htype !=
-	   ah->ar_hrd, EBT_ARP_HTYPE))
+	if ((info->bitmask & EBT_ARP_HTYPE) &&
+	    NF_INVF(info, EBT_ARP_HTYPE, info->htype != ah->ar_hrd))
 		return false;
-	if (info->bitmask & EBT_ARP_PTYPE && FWINV(info->ptype !=
-	   ah->ar_pro, EBT_ARP_PTYPE))
+	if ((info->bitmask & EBT_ARP_PTYPE) &&
+	    NF_INVF(info, EBT_ARP_PTYPE, info->ptype != ah->ar_pro))
 		return false;
 
 	if (info->bitmask & (EBT_ARP_SRC_IP | EBT_ARP_DST_IP | EBT_ARP_GRAT)) {
@@ -51,14 +51,16 @@ ebt_arp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 					sizeof(daddr), &daddr);
 		if (dap == NULL)
 			return false;
-		if (info->bitmask & EBT_ARP_SRC_IP &&
-		    FWINV(info->saddr != (*sap & info->smsk), EBT_ARP_SRC_IP))
+		if ((info->bitmask & EBT_ARP_SRC_IP) &&
+		    NF_INVF(info, EBT_ARP_SRC_IP,
+			    info->saddr != (*sap & info->smsk)))
 			return false;
-		if (info->bitmask & EBT_ARP_DST_IP &&
-		    FWINV(info->daddr != (*dap & info->dmsk), EBT_ARP_DST_IP))
+		if ((info->bitmask & EBT_ARP_DST_IP) &&
+		    NF_INVF(info, EBT_ARP_DST_IP,
+			    info->daddr != (*dap & info->dmsk)))
 			return false;
-		if (info->bitmask & EBT_ARP_GRAT &&
-		    FWINV(*dap != *sap, EBT_ARP_GRAT))
+		if ((info->bitmask & EBT_ARP_GRAT) &&
+		    NF_INVF(info, EBT_ARP_GRAT, *dap != *sap))
 			return false;
 	}
 
@@ -73,9 +75,9 @@ ebt_arp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 						sizeof(_mac), &_mac);
 			if (mp == NULL)
 				return false;
-			if (FWINV(!ether_addr_equal_masked(mp, info->smaddr,
-							   info->smmsk),
-				  EBT_ARP_SRC_MAC))
+			if (NF_INVF(info, EBT_ARP_SRC_MAC,
+				    !ether_addr_equal_masked(mp, info->smaddr,
+							     info->smmsk)))
 				return false;
 		}
 
@@ -85,9 +87,9 @@ ebt_arp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 						sizeof(_mac), &_mac);
 			if (mp == NULL)
 				return false;
-			if (FWINV(!ether_addr_equal_masked(mp, info->dmaddr,
-							   info->dmmsk),
-				  EBT_ARP_DST_MAC))
+			if (NF_INVF(info, EBT_ARP_DST_MAC,
+				    !ether_addr_equal_masked(mp, info->dmaddr,
+							     info->dmmsk)))
 				return false;
 		}
 	}
diff --git a/net/bridge/netfilter/ebt_ip.c b/net/bridge/netfilter/ebt_ip.c
index 23bca62..d06968b 100644
--- a/net/bridge/netfilter/ebt_ip.c
+++ b/net/bridge/netfilter/ebt_ip.c
@@ -36,19 +36,19 @@ ebt_ip_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	ih = skb_header_pointer(skb, 0, sizeof(_iph), &_iph);
 	if (ih == NULL)
 		return false;
-	if (info->bitmask & EBT_IP_TOS &&
-	   FWINV(info->tos != ih->tos, EBT_IP_TOS))
+	if ((info->bitmask & EBT_IP_TOS) &&
+	    NF_INVF(info, EBT_IP_TOS, info->tos != ih->tos))
 		return false;
-	if (info->bitmask & EBT_IP_SOURCE &&
-	   FWINV((ih->saddr & info->smsk) !=
-	   info->saddr, EBT_IP_SOURCE))
+	if ((info->bitmask & EBT_IP_SOURCE) &&
+	    NF_INVF(info, EBT_IP_SOURCE,
+		    (ih->saddr & info->smsk) != info->saddr))
 		return false;
 	if ((info->bitmask & EBT_IP_DEST) &&
-	   FWINV((ih->daddr & info->dmsk) !=
-	   info->daddr, EBT_IP_DEST))
+	    NF_INVF(info, EBT_IP_DEST,
+		    (ih->daddr & info->dmsk) != info->daddr))
 		return false;
 	if (info->bitmask & EBT_IP_PROTO) {
-		if (FWINV(info->protocol != ih->protocol, EBT_IP_PROTO))
+		if (NF_INVF(info, EBT_IP_PROTO, info->protocol != ih->protocol))
 			return false;
 		if (!(info->bitmask & EBT_IP_DPORT) &&
 		    !(info->bitmask & EBT_IP_SPORT))
@@ -61,16 +61,16 @@ ebt_ip_mt(const struct sk_buff *skb, struct xt_action_param *par)
 			return false;
 		if (info->bitmask & EBT_IP_DPORT) {
 			u32 dst = ntohs(pptr->dst);
-			if (FWINV(dst < info->dport[0] ||
-				  dst > info->dport[1],
-				  EBT_IP_DPORT))
+			if (NF_INVF(info, EBT_IP_DPORT,
+				    dst < info->dport[0] ||
+				    dst > info->dport[1]))
 			return false;
 		}
 		if (info->bitmask & EBT_IP_SPORT) {
 			u32 src = ntohs(pptr->src);
-			if (FWINV(src < info->sport[0] ||
-				  src > info->sport[1],
-				  EBT_IP_SPORT))
+			if (NF_INVF(info, EBT_IP_SPORT,
+				    src < info->sport[0] ||
+				    src > info->sport[1]))
 			return false;
 		}
 	}
diff --git a/net/bridge/netfilter/ebt_ip6.c b/net/bridge/netfilter/ebt_ip6.c
index 98de6e7..4617491 100644
--- a/net/bridge/netfilter/ebt_ip6.c
+++ b/net/bridge/netfilter/ebt_ip6.c
@@ -45,15 +45,18 @@ ebt_ip6_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	ih6 = skb_header_pointer(skb, 0, sizeof(_ip6h), &_ip6h);
 	if (ih6 == NULL)
 		return false;
-	if (info->bitmask & EBT_IP6_TCLASS &&
-	   FWINV(info->tclass != ipv6_get_dsfield(ih6), EBT_IP6_TCLASS))
+	if ((info->bitmask & EBT_IP6_TCLASS) &&
+	    NF_INVF(info, EBT_IP6_TCLASS,
+		    info->tclass != ipv6_get_dsfield(ih6)))
 		return false;
-	if ((info->bitmask & EBT_IP6_SOURCE &&
-	    FWINV(ipv6_masked_addr_cmp(&ih6->saddr, &info->smsk,
-				       &info->saddr), EBT_IP6_SOURCE)) ||
-	    (info->bitmask & EBT_IP6_DEST &&
-	    FWINV(ipv6_masked_addr_cmp(&ih6->daddr, &info->dmsk,
-				       &info->daddr), EBT_IP6_DEST)))
+	if (((info->bitmask & EBT_IP6_SOURCE) &&
+	     NF_INVF(info, EBT_IP6_SOURCE,
+		     ipv6_masked_addr_cmp(&ih6->saddr, &info->smsk,
+					  &info->saddr))) ||
+	    ((info->bitmask & EBT_IP6_DEST) &&
+	     NF_INVF(info, EBT_IP6_DEST,
+		     ipv6_masked_addr_cmp(&ih6->daddr, &info->dmsk,
+					  &info->daddr))))
 		return false;
 	if (info->bitmask & EBT_IP6_PROTO) {
 		uint8_t nexthdr = ih6->nexthdr;
@@ -63,7 +66,7 @@ ebt_ip6_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		offset_ph = ipv6_skip_exthdr(skb, sizeof(_ip6h), &nexthdr, &frag_off);
 		if (offset_ph == -1)
 			return false;
-		if (FWINV(info->protocol != nexthdr, EBT_IP6_PROTO))
+		if (NF_INVF(info, EBT_IP6_PROTO, info->protocol != nexthdr))
 			return false;
 		if (!(info->bitmask & (EBT_IP6_DPORT |
 				       EBT_IP6_SPORT | EBT_IP6_ICMP6)))
@@ -76,22 +79,24 @@ ebt_ip6_mt(const struct sk_buff *skb, struct xt_action_param *par)
 			return false;
 		if (info->bitmask & EBT_IP6_DPORT) {
 			u16 dst = ntohs(pptr->tcpudphdr.dst);
-			if (FWINV(dst < info->dport[0] ||
-				  dst > info->dport[1], EBT_IP6_DPORT))
+			if (NF_INVF(info, EBT_IP6_DPORT,
+				    dst < info->dport[0] ||
+				    dst > info->dport[1]))
 				return false;
 		}
 		if (info->bitmask & EBT_IP6_SPORT) {
 			u16 src = ntohs(pptr->tcpudphdr.src);
-			if (FWINV(src < info->sport[0] ||
-				  src > info->sport[1], EBT_IP6_SPORT))
+			if (NF_INVF(info, EBT_IP6_SPORT,
+				    src < info->sport[0] ||
+				    src > info->sport[1]))
 			return false;
 		}
 		if ((info->bitmask & EBT_IP6_ICMP6) &&
-		     FWINV(pptr->icmphdr.type < info->icmpv6_type[0] ||
-			   pptr->icmphdr.type > info->icmpv6_type[1] ||
-			   pptr->icmphdr.code < info->icmpv6_code[0] ||
-			   pptr->icmphdr.code > info->icmpv6_code[1],
-							EBT_IP6_ICMP6))
+		    NF_INVF(info, EBT_IP6_ICMP6,
+			    pptr->icmphdr.type < info->icmpv6_type[0] ||
+			    pptr->icmphdr.type > info->icmpv6_type[1] ||
+			    pptr->icmphdr.code < info->icmpv6_code[0] ||
+			    pptr->icmphdr.code > info->icmpv6_code[1]))
 			return false;
 	}
 	return true;
diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_stp.c
index 45f73d5..3140eb9 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -49,66 +49,68 @@ static bool ebt_filter_config(const struct ebt_stp_info *info,
 
 	c = &info->config;
 	if ((info->bitmask & EBT_STP_FLAGS) &&
-	    FWINV(c->flags != stpc->flags, EBT_STP_FLAGS))
+	    NF_INVF(info, EBT_STP_FLAGS, c->flags != stpc->flags))
 		return false;
 	if (info->bitmask & EBT_STP_ROOTPRIO) {
 		v16 = NR16(stpc->root);
-		if (FWINV(v16 < c->root_priol || v16 > c->root_priou,
-			  EBT_STP_ROOTPRIO))
+		if (NF_INVF(info, EBT_STP_ROOTPRIO,
+			    v16 < c->root_priol || v16 > c->root_priou))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_ROOTADDR) {
-		if (FWINV(!ether_addr_equal_masked(&stpc->root[2], c->root_addr,
-						   c->root_addrmsk),
-			  EBT_STP_ROOTADDR))
+		if (NF_INVF(info, EBT_STP_ROOTADDR,
+			    !ether_addr_equal_masked(&stpc->root[2],
+						     c->root_addr,
+						     c->root_addrmsk)))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_ROOTCOST) {
 		v32 = NR32(stpc->root_cost);
-		if (FWINV(v32 < c->root_costl || v32 > c->root_costu,
-			  EBT_STP_ROOTCOST))
+		if (NF_INVF(info, EBT_STP_ROOTCOST,
+			    v32 < c->root_costl || v32 > c->root_costu))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_SENDERPRIO) {
 		v16 = NR16(stpc->sender);
-		if (FWINV(v16 < c->sender_priol || v16 > c->sender_priou,
-			  EBT_STP_SENDERPRIO))
+		if (NF_INVF(info, EBT_STP_SENDERPRIO,
+			    v16 < c->sender_priol || v16 > c->sender_priou))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_SENDERADDR) {
-		if (FWINV(!ether_addr_equal_masked(&stpc->sender[2],
-						   c->sender_addr,
-						   c->sender_addrmsk),
-			  EBT_STP_SENDERADDR))
+		if (NF_INVF(info, EBT_STP_SENDERADDR,
+			    !ether_addr_equal_masked(&stpc->sender[2],
+						     c->sender_addr,
+						     c->sender_addrmsk)))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_PORT) {
 		v16 = NR16(stpc->port);
-		if (FWINV(v16 < c->portl || v16 > c->portu, EBT_STP_PORT))
+		if (NF_INVF(info, EBT_STP_PORT,
+			    v16 < c->portl || v16 > c->portu))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_MSGAGE) {
 		v16 = NR16(stpc->msg_age);
-		if (FWINV(v16 < c->msg_agel || v16 > c->msg_ageu,
-			  EBT_STP_MSGAGE))
+		if (NF_INVF(info, EBT_STP_MSGAGE,
+			    v16 < c->msg_agel || v16 > c->msg_ageu))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_MAXAGE) {
 		v16 = NR16(stpc->max_age);
-		if (FWINV(v16 < c->max_agel || v16 > c->max_ageu,
-			  EBT_STP_MAXAGE))
+		if (NF_INVF(info, EBT_STP_MAXAGE,
+			    v16 < c->max_agel || v16 > c->max_ageu))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_HELLOTIME) {
 		v16 = NR16(stpc->hello_time);
-		if (FWINV(v16 < c->hello_timel || v16 > c->hello_timeu,
-			  EBT_STP_HELLOTIME))
+		if (NF_INVF(info, EBT_STP_HELLOTIME,
+			    v16 < c->hello_timel || v16 > c->hello_timeu))
 			return false;
 	}
 	if (info->bitmask & EBT_STP_FWDD) {
 		v16 = NR16(stpc->forward_delay);
-		if (FWINV(v16 < c->forward_delayl || v16 > c->forward_delayu,
-			  EBT_STP_FWDD))
+		if (NF_INVF(info, EBT_STP_FWDD,
+			    v16 < c->forward_delayl || v16 > c->forward_delayu))
 			return false;
 	}
 	return true;
@@ -130,8 +132,8 @@ ebt_stp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	if (memcmp(sp, header, sizeof(header)))
 		return false;
 
-	if (info->bitmask & EBT_STP_TYPE &&
-	    FWINV(info->type != sp->type, EBT_STP_TYPE))
+	if ((info->bitmask & EBT_STP_TYPE) &&
+	    NF_INVF(info, EBT_STP_TYPE, info->type != sp->type))
 		return false;
 
 	if (sp->type == BPDU_TYPE_CONFIG &&
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 5721a25..cceac5b 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -121,7 +121,6 @@ ebt_dev_check(const char *entry, const struct net_device *device)
 	return devname[i] != entry[i] && entry[i] != 1;
 }
 
-#define FWINV2(bool, invflg) ((bool) ^ !!(e->invflags & invflg))
 /* process standard matches */
 static inline int
 ebt_basic_match(const struct ebt_entry *e, const struct sk_buff *skb,
@@ -137,34 +136,36 @@ ebt_basic_match(const struct ebt_entry *e, const struct sk_buff *skb,
 		ethproto = h->h_proto;
 
 	if (e->bitmask & EBT_802_3) {
-		if (FWINV2(eth_proto_is_802_3(ethproto), EBT_IPROTO))
+		if (NF_INVF(e, EBT_IPROTO, eth_proto_is_802_3(ethproto)))
 			return 1;
 	} else if (!(e->bitmask & EBT_NOPROTO) &&
-	   FWINV2(e->ethproto != ethproto, EBT_IPROTO))
+		   NF_INVF(e, EBT_IPROTO, e->ethproto != ethproto))
 		return 1;
 
-	if (FWINV2(ebt_dev_check(e->in, in), EBT_IIN))
+	if (NF_INVF(e, EBT_IIN, ebt_dev_check(e->in, in)))
 		return 1;
-	if (FWINV2(ebt_dev_check(e->out, out), EBT_IOUT))
+	if (NF_INVF(e, EBT_IOUT, ebt_dev_check(e->out, out)))
 		return 1;
 	/* rcu_read_lock()ed by nf_hook_slow */
 	if (in && (p = br_port_get_rcu(in)) != NULL &&
-	    FWINV2(ebt_dev_check(e->logical_in, p->br->dev), EBT_ILOGICALIN))
+	    NF_INVF(e, EBT_ILOGICALIN,
+		    ebt_dev_check(e->logical_in, p->br->dev)))
 		return 1;
 	if (out && (p = br_port_get_rcu(out)) != NULL &&
-	    FWINV2(ebt_dev_check(e->logical_out, p->br->dev), EBT_ILOGICALOUT))
+	    NF_INVF(e, EBT_ILOGICALOUT,
+		    ebt_dev_check(e->logical_out, p->br->dev)))
 		return 1;
 
 	if (e->bitmask & EBT_SOURCEMAC) {
-		if (FWINV2(!ether_addr_equal_masked(h->h_source,
-						    e->sourcemac, e->sourcemsk),
-			   EBT_ISOURCE))
+		if (NF_INVF(e, EBT_ISOURCE,
+			    !ether_addr_equal_masked(h->h_source, e->sourcemac,
+						     e->sourcemsk)))
 			return 1;
 	}
 	if (e->bitmask & EBT_DESTMAC) {
-		if (FWINV2(!ether_addr_equal_masked(h->h_dest,
-						    e->destmac, e->destmsk),
-			   EBT_IDEST))
+		if (NF_INVF(e, EBT_IDEST,
+			    !ether_addr_equal_masked(h->h_dest, e->destmac,
+						     e->destmsk)))
 			return 1;
 	}
 	return 0;
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 2033f92..c8dd9e2 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -89,22 +89,20 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 	__be32 src_ipaddr, tgt_ipaddr;
 	long ret;
 
-#define FWINV(bool, invflg) ((bool) ^ !!(arpinfo->invflags & (invflg)))
-
-	if (FWINV((arphdr->ar_op & arpinfo->arpop_mask) != arpinfo->arpop,
-		  ARPT_INV_ARPOP))
+	if (NF_INVF(arpinfo, ARPT_INV_ARPOP,
+		    (arphdr->ar_op & arpinfo->arpop_mask) != arpinfo->arpop))
 		return 0;
 
-	if (FWINV((arphdr->ar_hrd & arpinfo->arhrd_mask) != arpinfo->arhrd,
-		  ARPT_INV_ARPHRD))
+	if (NF_INVF(arpinfo, ARPT_INV_ARPHRD,
+		    (arphdr->ar_hrd & arpinfo->arhrd_mask) != arpinfo->arhrd))
 		return 0;
 
-	if (FWINV((arphdr->ar_pro & arpinfo->arpro_mask) != arpinfo->arpro,
-		  ARPT_INV_ARPPRO))
+	if (NF_INVF(arpinfo, ARPT_INV_ARPPRO,
+		    (arphdr->ar_pro & arpinfo->arpro_mask) != arpinfo->arpro))
 		return 0;
 
-	if (FWINV((arphdr->ar_hln & arpinfo->arhln_mask) != arpinfo->arhln,
-		  ARPT_INV_ARPHLN))
+	if (NF_INVF(arpinfo, ARPT_INV_ARPHLN,
+		    (arphdr->ar_hln & arpinfo->arhln_mask) != arpinfo->arhln))
 		return 0;
 
 	src_devaddr = arpptr;
@@ -115,31 +113,32 @@ static inline int arp_packet_match(const struct arphdr *arphdr,
 	arpptr += dev->addr_len;
 	memcpy(&tgt_ipaddr, arpptr, sizeof(u32));
 
-	if (FWINV(arp_devaddr_compare(&arpinfo->src_devaddr, src_devaddr, dev->addr_len),
-		  ARPT_INV_SRCDEVADDR) ||
-	    FWINV(arp_devaddr_compare(&arpinfo->tgt_devaddr, tgt_devaddr, dev->addr_len),
-		  ARPT_INV_TGTDEVADDR))
+	if (NF_INVF(arpinfo, ARPT_INV_SRCDEVADDR,
+		    arp_devaddr_compare(&arpinfo->src_devaddr, src_devaddr,
+					dev->addr_len)) ||
+	    NF_INVF(arpinfo, ARPT_INV_TGTDEVADDR,
+		    arp_devaddr_compare(&arpinfo->tgt_devaddr, tgt_devaddr,
+					dev->addr_len)))
 		return 0;
 
-	if (FWINV((src_ipaddr & arpinfo->smsk.s_addr) != arpinfo->src.s_addr,
-		  ARPT_INV_SRCIP) ||
-	    FWINV(((tgt_ipaddr & arpinfo->tmsk.s_addr) != arpinfo->tgt.s_addr),
-		  ARPT_INV_TGTIP))
+	if (NF_INVF(arpinfo, ARPT_INV_SRCIP,
+		    (src_ipaddr & arpinfo->smsk.s_addr) != arpinfo->src.s_addr) ||
+	    NF_INVF(arpinfo, ARPT_INV_TGTIP,
+		    (tgt_ipaddr & arpinfo->tmsk.s_addr) != arpinfo->tgt.s_addr))
 		return 0;
 
 	/* Look for ifname matches.  */
 	ret = ifname_compare(indev, arpinfo->iniface, arpinfo->iniface_mask);
 
-	if (FWINV(ret != 0, ARPT_INV_VIA_IN))
+	if (NF_INVF(arpinfo, ARPT_INV_VIA_IN, ret != 0))
 		return 0;
 
 	ret = ifname_compare(outdev, arpinfo->outiface, arpinfo->outiface_mask);
 
-	if (FWINV(ret != 0, ARPT_INV_VIA_OUT))
+	if (NF_INVF(arpinfo, ARPT_INV_VIA_OUT, ret != 0))
 		return 0;
 
 	return 1;
-#undef FWINV
 }
 
 static inline int arp_checkentry(const struct arpt_arp *arp)
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 54906e0..f0df66f 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -58,32 +58,31 @@ ip_packet_match(const struct iphdr *ip,
 {
 	unsigned long ret;
 
-#define FWINV(bool, invflg) ((bool) ^ !!(ipinfo->invflags & (invflg)))
-
-	if (FWINV((ip->saddr&ipinfo->smsk.s_addr) != ipinfo->src.s_addr,
-		  IPT_INV_SRCIP) ||
-	    FWINV((ip->daddr&ipinfo->dmsk.s_addr) != ipinfo->dst.s_addr,
-		  IPT_INV_DSTIP))
+	if (NF_INVF(ipinfo, IPT_INV_SRCIP,
+		    (ip->saddr & ipinfo->smsk.s_addr) != ipinfo->src.s_addr) ||
+	    NF_INVF(ipinfo, IPT_INV_DSTIP,
+		    (ip->daddr & ipinfo->dmsk.s_addr) != ipinfo->dst.s_addr))
 		return false;
 
 	ret = ifname_compare_aligned(indev, ipinfo->iniface, ipinfo->iniface_mask);
 
-	if (FWINV(ret != 0, IPT_INV_VIA_IN))
+	if (NF_INVF(ipinfo, IPT_INV_VIA_IN, ret != 0))
 		return false;
 
 	ret = ifname_compare_aligned(outdev, ipinfo->outiface, ipinfo->outiface_mask);
 
-	if (FWINV(ret != 0, IPT_INV_VIA_OUT))
+	if (NF_INVF(ipinfo, IPT_INV_VIA_OUT, ret != 0))
 		return false;
 
 	/* Check specific protocol */
 	if (ipinfo->proto &&
-	    FWINV(ip->protocol != ipinfo->proto, IPT_INV_PROTO))
+	    NF_INVF(ipinfo, IPT_INV_PROTO, ip->protocol != ipinfo->proto))
 		return false;
 
 	/* If we have a fragment rule but the packet is not a fragment
 	 * then we return zero */
-	if (FWINV((ipinfo->flags&IPT_F_FRAG) && !isfrag, IPT_INV_FRAG))
+	if (NF_INVF(ipinfo, IPT_INV_FRAG,
+		    (ipinfo->flags & IPT_F_FRAG) && !isfrag))
 		return false;
 
 	return true;
@@ -122,7 +121,6 @@ static inline bool unconditional(const struct ipt_entry *e)
 
 	return e->target_offset == sizeof(struct ipt_entry) &&
 	       memcmp(&e->ip, &uncond, sizeof(uncond)) == 0;
-#undef FWINV
 }
 
 /* for const-correctness */
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 63e06c3..61ed950 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -73,22 +73,22 @@ ip6_packet_match(const struct sk_buff *skb,
 	unsigned long ret;
 	const struct ipv6hdr *ipv6 = ipv6_hdr(skb);
 
-#define FWINV(bool, invflg) ((bool) ^ !!(ip6info->invflags & (invflg)))
-
-	if (FWINV(ipv6_masked_addr_cmp(&ipv6->saddr, &ip6info->smsk,
-				       &ip6info->src), IP6T_INV_SRCIP) ||
-	    FWINV(ipv6_masked_addr_cmp(&ipv6->daddr, &ip6info->dmsk,
-				       &ip6info->dst), IP6T_INV_DSTIP))
+	if (NF_INVF(ip6info, IP6T_INV_SRCIP,
+		    ipv6_masked_addr_cmp(&ipv6->saddr, &ip6info->smsk,
+					 &ip6info->src)) ||
+	    NF_INVF(ip6info, IP6T_INV_DSTIP,
+		    ipv6_masked_addr_cmp(&ipv6->daddr, &ip6info->dmsk,
+					 &ip6info->dst)))
 		return false;
 
 	ret = ifname_compare_aligned(indev, ip6info->iniface, ip6info->iniface_mask);
 
-	if (FWINV(ret != 0, IP6T_INV_VIA_IN))
+	if (NF_INVF(ip6info, IP6T_INV_VIA_IN, ret != 0))
 		return false;
 
 	ret = ifname_compare_aligned(outdev, ip6info->outiface, ip6info->outiface_mask);
 
-	if (FWINV(ret != 0, IP6T_INV_VIA_OUT))
+	if (NF_INVF(ip6info, IP6T_INV_VIA_OUT, ret != 0))
 		return false;
 
 /* ... might want to do something with class and flowlabel here ... */
diff --git a/net/netfilter/xt_tcpudp.c b/net/netfilter/xt_tcpudp.c
index c14d464..ade024c 100644
--- a/net/netfilter/xt_tcpudp.c
+++ b/net/netfilter/xt_tcpudp.c
@@ -83,8 +83,6 @@ static bool tcp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		return false;
 	}
 
-#define FWINVTCP(bool, invflg) ((bool) ^ !!(tcpinfo->invflags & (invflg)))
-
 	th = skb_header_pointer(skb, par->thoff, sizeof(_tcph), &_tcph);
 	if (th == NULL) {
 		/* We've been asked to examine this packet, and we
@@ -102,9 +100,8 @@ static bool tcp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 			ntohs(th->dest),
 			!!(tcpinfo->invflags & XT_TCP_INV_DSTPT)))
 		return false;
-	if (!FWINVTCP((((unsigned char *)th)[13] & tcpinfo->flg_mask)
-		      == tcpinfo->flg_cmp,
-		      XT_TCP_INV_FLAGS))
+	if (!NF_INVF(tcpinfo, XT_TCP_INV_FLAGS,
+		     (((unsigned char *)th)[13] & tcpinfo->flg_mask) == tcpinfo->flg_cmp))
 		return false;
 	if (tcpinfo->option) {
 		if (th->doff * 4 < sizeof(_tcph)) {
-- 
2.1.4

