From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 07/31: xtables: reduce indent level by one
Date: Wed, 10 Jun 2009 21:46:31 +0200 (MEST)
Message-ID: <20090610194629.11112.66543.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33154 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761046AbZFJTqa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 15:46:30 -0400
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit a1ff4ac84e58503691058e88d55fa48949822683
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Apr 15 21:28:39 2009 +0200

    netfilter: xtables: reduce indent level by one
    
    Cosmetic only. Transformation applied:
    
    	-if (foo) { long block; } else { short block; }
    	+if (!foo) { short block; continue; } long block;
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 940e54b..ecba246 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -273,66 +273,62 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 
 	arp = arp_hdr(skb);
 	do {
-		if (arp_packet_match(arp, skb->dev, indev, outdev, &e->arp)) {
-			struct arpt_entry_target *t;
-			int hdr_len;
+		struct arpt_entry_target *t;
+		int hdr_len;
 
-			hdr_len = sizeof(*arp) + (2 * sizeof(struct in_addr)) +
-				(2 * skb->dev->addr_len);
+		if (!arp_packet_match(arp, skb->dev, indev, outdev, &e->arp)) {
+			e = arpt_next_entry(e);
+			continue;
+		}
 
-			ADD_COUNTER(e->counters, hdr_len, 1);
+		hdr_len = sizeof(*arp) + (2 * sizeof(struct in_addr)) +
+			(2 * skb->dev->addr_len);
+		ADD_COUNTER(e->counters, hdr_len, 1);
 
-			t = arpt_get_target(e);
+		t = arpt_get_target(e);
 
-			/* Standard target? */
-			if (!t->u.kernel.target->target) {
-				int v;
+		/* Standard target? */
+		if (!t->u.kernel.target->target) {
+			int v;
 
-				v = ((struct arpt_standard_target *)t)->verdict;
-				if (v < 0) {
-					/* Pop from stack? */
-					if (v != ARPT_RETURN) {
-						verdict = (unsigned)(-v) - 1;
-						break;
-					}
-					e = back;
-					back = get_entry(table_base,
-							 back->comefrom);
-					continue;
-				}
-				if (table_base + v
-				    != arpt_next_entry(e)) {
-					/* Save old back ptr in next entry */
-					struct arpt_entry *next
-						= arpt_next_entry(e);
-					next->comefrom =
-						(void *)back - table_base;
-
-					/* set back pointer to next entry */
-					back = next;
-				}
-
-				e = get_entry(table_base, v);
-			} else {
-				/* Targets which reenter must return
-				 * abs. verdicts
-				 */
-				tgpar.target   = t->u.kernel.target;
-				tgpar.targinfo = t->data;
-				verdict = t->u.kernel.target->target(skb,
-								     &tgpar);
-
-				/* Target might have changed stuff. */
-				arp = arp_hdr(skb);
-
-				if (verdict == ARPT_CONTINUE)
-					e = arpt_next_entry(e);
-				else
-					/* Verdict */
+			v = ((struct arpt_standard_target *)t)->verdict;
+			if (v < 0) {
+				/* Pop from stack? */
+				if (v != ARPT_RETURN) {
+					verdict = (unsigned)(-v) - 1;
 					break;
+				}
+				e = back;
+				back = get_entry(table_base, back->comefrom);
+				continue;
 			}
+			if (table_base + v
+			    != arpt_next_entry(e)) {
+				/* Save old back ptr in next entry */
+				struct arpt_entry *next = arpt_next_entry(e);
+				next->comefrom = (void *)back - table_base;
+
+				/* set back pointer to next entry */
+				back = next;
+			}
+
+			e = get_entry(table_base, v);
 		} else {
-			e = arpt_next_entry(e);
+			/* Targets which reenter must return
+			 * abs. verdicts
+			 */
+			tgpar.target   = t->u.kernel.target;
+			tgpar.targinfo = t->data;
+			verdict = t->u.kernel.target->target(skb, &tgpar);
+
+			/* Target might have changed stuff. */
+			arp = arp_hdr(skb);
+
+			if (verdict == ARPT_CONTINUE)
+				e = arpt_next_entry(e);
+			else
+				/* Verdict */
+				break;
 		}
 	} while (!hotdrop);
 	xt_info_rdunlock_bh();
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 7ec4e40..82888bc 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -354,91 +354,87 @@ ipt_do_table(struct sk_buff *skb,
 	back = get_entry(table_base, private->underflow[hook]);
 
 	do {
+		struct ipt_entry_target *t;
+
 		IP_NF_ASSERT(e);
 		IP_NF_ASSERT(back);
-		if (ip_packet_match(ip, indev, outdev,
+		if (!ip_packet_match(ip, indev, outdev,
 		    &e->ip, mtpar.fragoff)) {
-			struct ipt_entry_target *t;
+ no_match:
+			e = ipt_next_entry(e);
+			continue;
+		}
 
-			if (IPT_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0)
-				goto no_match;
+		if (IPT_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0)
+			goto no_match;
 
-			ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
+		ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
 
-			t = ipt_get_target(e);
-			IP_NF_ASSERT(t->u.kernel.target);
+		t = ipt_get_target(e);
+		IP_NF_ASSERT(t->u.kernel.target);
 
 #if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
     defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
-			/* The packet is traced: log it */
-			if (unlikely(skb->nf_trace))
-				trace_packet(skb, hook, in, out,
-					     table->name, private, e);
+		/* The packet is traced: log it */
+		if (unlikely(skb->nf_trace))
+			trace_packet(skb, hook, in, out,
+				     table->name, private, e);
 #endif
-			/* Standard target? */
-			if (!t->u.kernel.target->target) {
-				int v;
-
-				v = ((struct ipt_standard_target *)t)->verdict;
-				if (v < 0) {
-					/* Pop from stack? */
-					if (v != IPT_RETURN) {
-						verdict = (unsigned)(-v) - 1;
-						break;
-					}
-					e = back;
-					back = get_entry(table_base,
-							 back->comefrom);
-					continue;
-				}
-				if (table_base + v != ipt_next_entry(e)
-				    && !(e->ip.flags & IPT_F_GOTO)) {
-					/* Save old back ptr in next entry */
-					struct ipt_entry *next
-						= ipt_next_entry(e);
-					next->comefrom
-						= (void *)back - table_base;
-					/* set back pointer to next entry */
-					back = next;
+		/* Standard target? */
+		if (!t->u.kernel.target->target) {
+			int v;
+
+			v = ((struct ipt_standard_target *)t)->verdict;
+			if (v < 0) {
+				/* Pop from stack? */
+				if (v != IPT_RETURN) {
+					verdict = (unsigned)(-v) - 1;
+					break;
 				}
+				e = back;
+				back = get_entry(table_base, back->comefrom);
+				continue;
+			}
+			if (table_base + v != ipt_next_entry(e)
+			    && !(e->ip.flags & IPT_F_GOTO)) {
+				/* Save old back ptr in next entry */
+				struct ipt_entry *next = ipt_next_entry(e);
+				next->comefrom = (void *)back - table_base;
+				/* set back pointer to next entry */
+				back = next;
+			}
 
-				e = get_entry(table_base, v);
-			} else {
-				/* Targets which reenter must return
-				   abs. verdicts */
-				tgpar.target   = t->u.kernel.target;
-				tgpar.targinfo = t->data;
+			e = get_entry(table_base, v);
+		} else {
+			/* Targets which reenter must return
+			   abs. verdicts */
+			tgpar.target   = t->u.kernel.target;
+			tgpar.targinfo = t->data;
 #ifdef CONFIG_NETFILTER_DEBUG
-				((struct ipt_entry *)table_base)->comefrom
-					= 0xeeeeeeec;
+			((struct ipt_entry *)table_base)->comefrom
+				= 0xeeeeeeec;
 #endif
-				verdict = t->u.kernel.target->target(skb,
-								     &tgpar);
+			verdict = t->u.kernel.target->target(skb, &tgpar);
 #ifdef CONFIG_NETFILTER_DEBUG
-				if (((struct ipt_entry *)table_base)->comefrom
-				    != 0xeeeeeeec
-				    && verdict == IPT_CONTINUE) {
-					printk("Target %s reentered!\n",
-					       t->u.kernel.target->name);
-					verdict = NF_DROP;
-				}
-				((struct ipt_entry *)table_base)->comefrom
-					= 0x57acc001;
-#endif
-				/* Target might have changed stuff. */
-				ip = ip_hdr(skb);
-				datalen = skb->len - ip->ihl * 4;
-
-				if (verdict == IPT_CONTINUE)
-					e = ipt_next_entry(e);
-				else
-					/* Verdict */
-					break;
+			if (((struct ipt_entry *)table_base)->comefrom
+			    != 0xeeeeeeec
+			    && verdict == IPT_CONTINUE) {
+				printk("Target %s reentered!\n",
+				       t->u.kernel.target->name);
+				verdict = NF_DROP;
 			}
-		} else {
-
-		no_match:
-			e = ipt_next_entry(e);
+			((struct ipt_entry *)table_base)->comefrom
+				= 0x57acc001;
+#endif
+			/* Target might have changed stuff. */
+			ip = ip_hdr(skb);
+			datalen = skb->len - ip->ihl * 4;
+
+			if (verdict == IPT_CONTINUE)
+				e = ipt_next_entry(e);
+			else
+				/* Verdict */
+				break;
 		}
 	} while (!hotdrop);
 	xt_info_rdunlock_bh();
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 9176e98..a6c2213 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -381,91 +381,87 @@ ip6t_do_table(struct sk_buff *skb,
 	back = get_entry(table_base, private->underflow[hook]);
 
 	do {
+		struct ip6t_entry_target *t;
+
 		IP_NF_ASSERT(e);
 		IP_NF_ASSERT(back);
-		if (ip6_packet_match(skb, indev, outdev, &e->ipv6,
-			&mtpar.thoff, &mtpar.fragoff, &hotdrop)) {
-			struct ip6t_entry_target *t;
+		if (!ip6_packet_match(skb, indev, outdev, &e->ipv6,
+		    &mtpar.thoff, &mtpar.fragoff, &hotdrop)) {
+ no_match:
+			e = ip6t_next_entry(e);
+			continue;
+		}
 
-			if (IP6T_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0)
-				goto no_match;
+		if (IP6T_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0)
+			goto no_match;
 
-			ADD_COUNTER(e->counters,
-				    ntohs(ipv6_hdr(skb)->payload_len) +
-				    sizeof(struct ipv6hdr), 1);
+		ADD_COUNTER(e->counters,
+			    ntohs(ipv6_hdr(skb)->payload_len) +
+			    sizeof(struct ipv6hdr), 1);
 
-			t = ip6t_get_target(e);
-			IP_NF_ASSERT(t->u.kernel.target);
+		t = ip6t_get_target(e);
+		IP_NF_ASSERT(t->u.kernel.target);
 
 #if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
     defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
-			/* The packet is traced: log it */
-			if (unlikely(skb->nf_trace))
-				trace_packet(skb, hook, in, out,
-					     table->name, private, e);
+		/* The packet is traced: log it */
+		if (unlikely(skb->nf_trace))
+			trace_packet(skb, hook, in, out,
+				     table->name, private, e);
 #endif
-			/* Standard target? */
-			if (!t->u.kernel.target->target) {
-				int v;
-
-				v = ((struct ip6t_standard_target *)t)->verdict;
-				if (v < 0) {
-					/* Pop from stack? */
-					if (v != IP6T_RETURN) {
-						verdict = (unsigned)(-v) - 1;
-						break;
-					}
-					e = back;
-					back = get_entry(table_base,
-							 back->comefrom);
-					continue;
-				}
-				if (table_base + v != ip6t_next_entry(e)
-				    && !(e->ipv6.flags & IP6T_F_GOTO)) {
-					/* Save old back ptr in next entry */
-					struct ip6t_entry *next
-						= ip6t_next_entry(e);
-					next->comefrom
-						= (void *)back - table_base;
-					/* set back pointer to next entry */
-					back = next;
+		/* Standard target? */
+		if (!t->u.kernel.target->target) {
+			int v;
+
+			v = ((struct ip6t_standard_target *)t)->verdict;
+			if (v < 0) {
+				/* Pop from stack? */
+				if (v != IP6T_RETURN) {
+					verdict = (unsigned)(-v) - 1;
+					break;
 				}
+				e = back;
+				back = get_entry(table_base, back->comefrom);
+				continue;
+			}
+			if (table_base + v != ip6t_next_entry(e)
+			    && !(e->ipv6.flags & IP6T_F_GOTO)) {
+				/* Save old back ptr in next entry */
+				struct ip6t_entry *next = ip6t_next_entry(e);
+				next->comefrom = (void *)back - table_base;
+				/* set back pointer to next entry */
+				back = next;
+			}
 
-				e = get_entry(table_base, v);
-			} else {
-				/* Targets which reenter must return
-				   abs. verdicts */
-				tgpar.target   = t->u.kernel.target;
-				tgpar.targinfo = t->data;
+			e = get_entry(table_base, v);
+		} else {
+			/* Targets which reenter must return
+			   abs. verdicts */
+			tgpar.target   = t->u.kernel.target;
+			tgpar.targinfo = t->data;
 
 #ifdef CONFIG_NETFILTER_DEBUG
-				((struct ip6t_entry *)table_base)->comefrom
-					= 0xeeeeeeec;
+			((struct ip6t_entry *)table_base)->comefrom
+				= 0xeeeeeeec;
 #endif
-				verdict = t->u.kernel.target->target(skb,
-								     &tgpar);
+			verdict = t->u.kernel.target->target(skb, &tgpar);
 
 #ifdef CONFIG_NETFILTER_DEBUG
-				if (((struct ip6t_entry *)table_base)->comefrom
-				    != 0xeeeeeeec
-				    && verdict == IP6T_CONTINUE) {
-					printk("Target %s reentered!\n",
-					       t->u.kernel.target->name);
-					verdict = NF_DROP;
-				}
-				((struct ip6t_entry *)table_base)->comefrom
-					= 0x57acc001;
-#endif
-				if (verdict == IP6T_CONTINUE)
-					e = ip6t_next_entry(e);
-				else
-					/* Verdict */
-					break;
+			if (((struct ip6t_entry *)table_base)->comefrom
+			    != 0xeeeeeeec
+			    && verdict == IP6T_CONTINUE) {
+				printk("Target %s reentered!\n",
+				       t->u.kernel.target->name);
+				verdict = NF_DROP;
 			}
-		} else {
-
-		no_match:
-			e = ip6t_next_entry(e);
+			((struct ip6t_entry *)table_base)->comefrom
+				= 0x57acc001;
+#endif
+			if (verdict == IP6T_CONTINUE)
+				e = ip6t_next_entry(e);
+			else
+				/* Verdict */
+				break;
 		}
 	} while (!hotdrop);
 
