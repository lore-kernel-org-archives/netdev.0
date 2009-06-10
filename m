From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 06/31: xtables: consolidate open-coded logic
Date: Wed, 10 Jun 2009 21:46:30 +0200 (MEST)
Message-ID: <20090610194628.11112.16337.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 98e86403162d08a30b03426c54c2a8fca1f695d1
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Apr 15 21:06:05 2009 +0200

    netfilter: xtables: consolidate open-coded logic
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 820252a..2455583 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -142,6 +142,12 @@ static inline int ebt_basic_match(struct ebt_entry *e, struct ethhdr *h,
 	return 0;
 }
 
+static inline __pure
+struct ebt_entry *ebt_next_entry(const struct ebt_entry *entry)
+{
+	return (void *)entry + entry->next_offset;
+}
+
 /* Do some firewalling */
 unsigned int ebt_do_table (unsigned int hook, struct sk_buff *skb,
    const struct net_device *in, const struct net_device *out,
@@ -249,8 +255,7 @@ letsreturn:
 		/* jump to a udc */
 		cs[sp].n = i + 1;
 		cs[sp].chaininfo = chaininfo;
-		cs[sp].e = (struct ebt_entry *)
-		   (((char *)point) + point->next_offset);
+		cs[sp].e = ebt_next_entry(point);
 		i = 0;
 		chaininfo = (struct ebt_entries *) (base + verdict);
 #ifdef CONFIG_NETFILTER_DEBUG
@@ -266,8 +271,7 @@ letsreturn:
 		sp++;
 		continue;
 letscontinue:
-		point = (struct ebt_entry *)
-		   (((char *)point) + point->next_offset);
+		point = ebt_next_entry(point);
 		i++;
 	}
 
@@ -787,7 +791,7 @@ static int check_chainloops(struct ebt_entries *chain, struct ebt_cl_stack *cl_s
 			/* this can't be 0, so the loop test is correct */
 			cl_s[i].cs.n = pos + 1;
 			pos = 0;
-			cl_s[i].cs.e = ((void *)e + e->next_offset);
+			cl_s[i].cs.e = ebt_next_entry(e);
 			e = (struct ebt_entry *)(hlp2->data);
 			nentries = hlp2->nentries;
 			cl_s[i].from = chain_nr;
@@ -797,7 +801,7 @@ static int check_chainloops(struct ebt_entries *chain, struct ebt_cl_stack *cl_s
 			continue;
 		}
 letscontinue:
-		e = (void *)e + e->next_offset;
+		e = ebt_next_entry(e);
 		pos++;
 	}
 	return 0;
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 831fe18..940e54b 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -231,6 +231,12 @@ static inline struct arpt_entry *get_entry(void *base, unsigned int offset)
 	return (struct arpt_entry *)(base + offset);
 }
 
+static inline __pure
+struct arpt_entry *arpt_next_entry(const struct arpt_entry *entry)
+{
+	return (void *)entry + entry->next_offset;
+}
+
 unsigned int arpt_do_table(struct sk_buff *skb,
 			   unsigned int hook,
 			   const struct net_device *in,
@@ -295,10 +301,10 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 					continue;
 				}
 				if (table_base + v
-				    != (void *)e + e->next_offset) {
+				    != arpt_next_entry(e)) {
 					/* Save old back ptr in next entry */
 					struct arpt_entry *next
-						= (void *)e + e->next_offset;
+						= arpt_next_entry(e);
 					next->comefrom =
 						(void *)back - table_base;
 
@@ -320,13 +326,13 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 				arp = arp_hdr(skb);
 
 				if (verdict == ARPT_CONTINUE)
-					e = (void *)e + e->next_offset;
+					e = arpt_next_entry(e);
 				else
 					/* Verdict */
 					break;
 			}
 		} else {
-			e = (void *)e + e->next_offset;
+			e = arpt_next_entry(e);
 		}
 	} while (!hotdrop);
 	xt_info_rdunlock_bh();
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 16b7c09..7ec4e40 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -297,6 +297,12 @@ static void trace_packet(struct sk_buff *skb,
 }
 #endif
 
+static inline __pure
+struct ipt_entry *ipt_next_entry(const struct ipt_entry *entry)
+{
+	return (void *)entry + entry->next_offset;
+}
+
 /* Returns one of the generic firewall policies, like NF_ACCEPT. */
 unsigned int
 ipt_do_table(struct sk_buff *skb,
@@ -385,11 +391,11 @@ ipt_do_table(struct sk_buff *skb,
 							 back->comefrom);
 					continue;
 				}
-				if (table_base + v != (void *)e + e->next_offset
+				if (table_base + v != ipt_next_entry(e)
 				    && !(e->ip.flags & IPT_F_GOTO)) {
 					/* Save old back ptr in next entry */
 					struct ipt_entry *next
-						= (void *)e + e->next_offset;
+						= ipt_next_entry(e);
 					next->comefrom
 						= (void *)back - table_base;
 					/* set back pointer to next entry */
@@ -424,7 +430,7 @@ ipt_do_table(struct sk_buff *skb,
 				datalen = skb->len - ip->ihl * 4;
 
 				if (verdict == IPT_CONTINUE)
-					e = (void *)e + e->next_offset;
+					e = ipt_next_entry(e);
 				else
 					/* Verdict */
 					break;
@@ -432,7 +438,7 @@ ipt_do_table(struct sk_buff *skb,
 		} else {
 
 		no_match:
-			e = (void *)e + e->next_offset;
+			e = ipt_next_entry(e);
 		}
 	} while (!hotdrop);
 	xt_info_rdunlock_bh();
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 4853a3d..9176e98 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -329,6 +329,12 @@ static void trace_packet(struct sk_buff *skb,
 }
 #endif
 
+static inline __pure struct ip6t_entry *
+ip6t_next_entry(const struct ip6t_entry *entry)
+{
+	return (void *)entry + entry->next_offset;
+}
+
 /* Returns one of the generic firewall policies, like NF_ACCEPT. */
 unsigned int
 ip6t_do_table(struct sk_buff *skb,
@@ -414,11 +420,11 @@ ip6t_do_table(struct sk_buff *skb,
 							 back->comefrom);
 					continue;
 				}
-				if (table_base + v != (void *)e + e->next_offset
+				if (table_base + v != ip6t_next_entry(e)
 				    && !(e->ipv6.flags & IP6T_F_GOTO)) {
 					/* Save old back ptr in next entry */
 					struct ip6t_entry *next
-						= (void *)e + e->next_offset;
+						= ip6t_next_entry(e);
 					next->comefrom
 						= (void *)back - table_base;
 					/* set back pointer to next entry */
@@ -451,7 +457,7 @@ ip6t_do_table(struct sk_buff *skb,
 					= 0x57acc001;
 #endif
 				if (verdict == IP6T_CONTINUE)
-					e = (void *)e + e->next_offset;
+					e = ip6t_next_entry(e);
 				else
 					/* Verdict */
 					break;
@@ -459,7 +465,7 @@ ip6t_do_table(struct sk_buff *skb,
 		} else {
 
 		no_match:
-			e = (void *)e + e->next_offset;
+			e = ip6t_next_entry(e);
 		}
 	} while (!hotdrop);
 
