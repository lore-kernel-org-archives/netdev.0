From: kaber@trash.net
Subject: [PATCH 07/12] netfilter: xtables: change hotdrop pointer to direct modification
Date: Thu, 13 May 2010 18:16:20 +0200
Message-ID: <1273767385-18225-8-git-send-email-kaber@trash.net>
References: <1273767385-18225-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58086 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759318Ab0EMQQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 12:16:36 -0400
In-Reply-To: <1273767385-18225-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Since xt_action_param is writable, let's use it. The pointer to
'bool hotdrop' always worried (8 bytes (64-bit) to write 1 byte!).
Surprisingly results in a reduction in size:

   text    data     bss filename
5457066  692730  357892 vmlinux.o-prev
5456554  692730  357892 vmlinux.o

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter/x_tables.h |    5 ++++-
 net/bridge/netfilter/ebtables.c    |    5 ++---
 net/ipv4/netfilter/arp_tables.c    |    6 +++---
 net/ipv4/netfilter/ip_tables.c     |    9 ++++-----
 net/ipv4/netfilter/ipt_ah.c        |    2 +-
 net/ipv4/netfilter/ipt_ecn.c       |    2 +-
 net/ipv6/netfilter/ip6_tables.c    |   11 +++++------
 net/ipv6/netfilter/ip6t_ah.c       |    4 ++--
 net/ipv6/netfilter/ip6t_eui64.c    |    2 +-
 net/ipv6/netfilter/ip6t_frag.c     |    4 ++--
 net/ipv6/netfilter/ip6t_hbh.c      |    4 ++--
 net/ipv6/netfilter/ip6t_mh.c       |    4 ++--
 net/ipv6/netfilter/ip6t_rt.c       |    4 ++--
 net/netfilter/xt_connlimit.c       |    4 ++--
 net/netfilter/xt_dccp.c            |    4 ++--
 net/netfilter/xt_esp.c             |    2 +-
 net/netfilter/xt_hashlimit.c       |    2 +-
 net/netfilter/xt_multiport.c       |    2 +-
 net/netfilter/xt_recent.c          |    2 +-
 net/netfilter/xt_sctp.c            |    4 ++--
 net/netfilter/xt_tcpmss.c          |    2 +-
 net/netfilter/xt_tcpudp.c          |   10 +++++-----
 22 files changed, 47 insertions(+), 47 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 40c6a8d..c2ee5d8 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -196,6 +196,9 @@ struct xt_counters_info {
  * @hook:	hook number given packet came from
  * @family:	Actual NFPROTO_* through which the function is invoked
  * 		(helpful when match->family == NFPROTO_UNSPEC)
+ *
+ * Fields written to by extensions:
+ *
  * @hotdrop:	drop packet if we had inspection problems
  * Network namespace obtainable using dev_net(in/out)
  */
@@ -212,7 +215,7 @@ struct xt_action_param {
 	unsigned int thoff;
 	unsigned int hooknum;
 	u_int8_t family;
-	bool *hotdrop;
+	bool hotdrop;
 };
 
 /**
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 290d435..59ca00e 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -186,13 +186,12 @@ unsigned int ebt_do_table (unsigned int hook, struct sk_buff *skb,
 	struct ebt_entries *chaininfo;
 	const char *base;
 	const struct ebt_table_info *private;
-	bool hotdrop = false;
 	struct xt_action_param acpar;
 
 	acpar.family  = NFPROTO_BRIDGE;
 	acpar.in      = in;
 	acpar.out     = out;
-	acpar.hotdrop = &hotdrop;
+	acpar.hotdrop = false;
 	acpar.hooknum = hook;
 
 	read_lock_bh(&table->lock);
@@ -216,7 +215,7 @@ unsigned int ebt_do_table (unsigned int hook, struct sk_buff *skb,
 
 		if (EBT_MATCH_ITERATE(point, ebt_do_match, skb, &acpar) != 0)
 			goto letscontinue;
-		if (hotdrop) {
+		if (acpar.hotdrop) {
 			read_unlock_bh(&table->lock);
 			return NF_DROP;
 		}
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 9e7d089..8cc56d2 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -260,7 +260,6 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	unsigned int verdict = NF_DROP;
 	const struct arphdr *arp;
-	bool hotdrop = false;
 	struct arpt_entry *e, *back;
 	const char *indev, *outdev;
 	void *table_base;
@@ -284,6 +283,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	acpar.out     = out;
 	acpar.hooknum = hook;
 	acpar.family  = NFPROTO_ARP;
+	acpar.hotdrop = false;
 
 	arp = arp_hdr(skb);
 	do {
@@ -345,10 +345,10 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 		else
 			/* Verdict */
 			break;
-	} while (!hotdrop);
+	} while (!acpar.hotdrop);
 	xt_info_rdunlock_bh();
 
-	if (hotdrop)
+	if (acpar.hotdrop)
 		return NF_DROP;
 	else
 		return verdict;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 4e674f2..607f89f 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -308,7 +308,6 @@ ipt_do_table(struct sk_buff *skb,
 {
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	const struct iphdr *ip;
-	bool hotdrop = false;
 	/* Initializing verdict to NF_DROP keeps gcc happy. */
 	unsigned int verdict = NF_DROP;
 	const char *indev, *outdev;
@@ -330,7 +329,7 @@ ipt_do_table(struct sk_buff *skb,
 	 * match it. */
 	acpar.fragoff = ntohs(ip->frag_off) & IP_OFFSET;
 	acpar.thoff   = ip_hdrlen(skb);
-	acpar.hotdrop = &hotdrop;
+	acpar.hotdrop = false;
 	acpar.in      = in;
 	acpar.out     = out;
 	acpar.family  = NFPROTO_IPV4;
@@ -432,7 +431,7 @@ ipt_do_table(struct sk_buff *skb,
 		else
 			/* Verdict */
 			break;
-	} while (!hotdrop);
+	} while (!acpar.hotdrop);
 	xt_info_rdunlock_bh();
 	pr_debug("Exiting %s; resetting sp from %u to %u\n",
 		 __func__, *stackptr, origptr);
@@ -440,7 +439,7 @@ ipt_do_table(struct sk_buff *skb,
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
 #else
-	if (hotdrop)
+	if (acpar.hotdrop)
 		return NF_DROP;
 	else return verdict;
 #endif
@@ -2154,7 +2153,7 @@ icmp_match(const struct sk_buff *skb, struct xt_action_param *par)
 		 * can't.  Hence, no choice but to drop.
 		 */
 		duprintf("Dropping evil ICMP tinygram.\n");
-		*par->hotdrop = true;
+		par->hotdrop = true;
 		return false;
 	}
 
diff --git a/net/ipv4/netfilter/ipt_ah.c b/net/ipv4/netfilter/ipt_ah.c
index c9d83dc..14a2aa8 100644
--- a/net/ipv4/netfilter/ipt_ah.c
+++ b/net/ipv4/netfilter/ipt_ah.c
@@ -46,7 +46,7 @@ static bool ah_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		 * can't.  Hence, no choice but to drop.
 		 */
 		pr_debug("Dropping evil AH tinygram.\n");
-		*par->hotdrop = true;
+		par->hotdrop = true;
 		return 0;
 	}
 
diff --git a/net/ipv4/netfilter/ipt_ecn.c b/net/ipv4/netfilter/ipt_ecn.c
index b79dddc..af6e9c7 100644
--- a/net/ipv4/netfilter/ipt_ecn.c
+++ b/net/ipv4/netfilter/ipt_ecn.c
@@ -78,7 +78,7 @@ static bool ecn_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	if (info->operation & (IPT_ECN_OP_MATCH_ECE|IPT_ECN_OP_MATCH_CWR)) {
 		if (ip_hdr(skb)->protocol != IPPROTO_TCP)
 			return false;
-		if (!match_tcp(skb, info, par->hotdrop))
+		if (!match_tcp(skb, info, &par->hotdrop))
 			return false;
 	}
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 4549f8d..557fac9 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -337,7 +337,6 @@ ip6t_do_table(struct sk_buff *skb,
 	      struct xt_table *table)
 {
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
-	bool hotdrop = false;
 	/* Initializing verdict to NF_DROP keeps gcc happy. */
 	unsigned int verdict = NF_DROP;
 	const char *indev, *outdev;
@@ -356,7 +355,7 @@ ip6t_do_table(struct sk_buff *skb,
 	 * things we don't know, ie. tcp syn flag or ports).  If the
 	 * rule is also a fragment-specific rule, non-fragments won't
 	 * match it. */
-	acpar.hotdrop = &hotdrop;
+	acpar.hotdrop = false;
 	acpar.in      = in;
 	acpar.out     = out;
 	acpar.family  = NFPROTO_IPV6;
@@ -380,7 +379,7 @@ ip6t_do_table(struct sk_buff *skb,
 
 		IP_NF_ASSERT(e);
 		if (!ip6_packet_match(skb, indev, outdev, &e->ipv6,
-		    &acpar.thoff, &acpar.fragoff, &hotdrop)) {
+		    &acpar.thoff, &acpar.fragoff, &acpar.hotdrop)) {
  no_match:
 			e = ip6t_next_entry(e);
 			continue;
@@ -447,7 +446,7 @@ ip6t_do_table(struct sk_buff *skb,
 		else
 			/* Verdict */
 			break;
-	} while (!hotdrop);
+	} while (!acpar.hotdrop);
 
 	xt_info_rdunlock_bh();
 	*stackptr = origptr;
@@ -455,7 +454,7 @@ ip6t_do_table(struct sk_buff *skb,
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
 #else
-	if (hotdrop)
+	if (acpar.hotdrop)
 		return NF_DROP;
 	else return verdict;
 #endif
@@ -2170,7 +2169,7 @@ icmp6_match(const struct sk_buff *skb, struct xt_action_param *par)
 		 * can't.  Hence, no choice but to drop.
 		 */
 		duprintf("Dropping evil ICMP tinygram.\n");
-		*par->hotdrop = true;
+		par->hotdrop = true;
 		return false;
 	}
 
diff --git a/net/ipv6/netfilter/ip6t_ah.c b/net/ipv6/netfilter/ip6t_ah.c
index c89887f..89cccc5 100644
--- a/net/ipv6/netfilter/ip6t_ah.c
+++ b/net/ipv6/netfilter/ip6t_ah.c
@@ -48,13 +48,13 @@ static bool ah_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	err = ipv6_find_hdr(skb, &ptr, NEXTHDR_AUTH, NULL);
 	if (err < 0) {
 		if (err != -ENOENT)
-			*par->hotdrop = true;
+			par->hotdrop = true;
 		return false;
 	}
 
 	ah = skb_header_pointer(skb, ptr, sizeof(_ah), &_ah);
 	if (ah == NULL) {
-		*par->hotdrop = true;
+		par->hotdrop = true;
 		return false;
 	}
 
diff --git a/net/ipv6/netfilter/ip6t_eui64.c b/net/ipv6/netfilter/ip6t_eui64.c
index f32fce3..aab0706 100644
--- a/net/ipv6/netfilter/ip6t_eui64.c
+++ b/net/ipv6/netfilter/ip6t_eui64.c
@@ -27,7 +27,7 @@ eui64_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	if (!(skb_mac_header(skb) >= skb->head &&
 	      skb_mac_header(skb) + ETH_HLEN <= skb->data) &&
 	    par->fragoff != 0) {
-		*par->hotdrop = true;
+		par->hotdrop = true;
 		return false;
 	}
 
diff --git a/net/ipv6/netfilter/ip6t_frag.c b/net/ipv6/netfilter/ip6t_frag.c
index fcc8c72..eda898f 100644
--- a/net/ipv6/netfilter/ip6t_frag.c
+++ b/net/ipv6/netfilter/ip6t_frag.c
@@ -46,13 +46,13 @@ frag_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	err = ipv6_find_hdr(skb, &ptr, NEXTHDR_FRAGMENT, NULL);
 	if (err < 0) {
 		if (err != -ENOENT)
-			*par->hotdrop = true;
+			par->hotdrop = true;
 		return false;
 	}
 
 	fh = skb_header_pointer(skb, ptr, sizeof(_frag), &_frag);
 	if (fh == NULL) {
-		*par->hotdrop = true;
+		par->hotdrop = true;
 		return false;
 	}
 
diff --git a/net/ipv6/netfilter/ip6t_hbh.c b/net/ipv6/netfilter/ip6t_hbh.c
index f8aebc0..59df051 100644
--- a/net/ipv6/netfilter/ip6t_hbh.c
+++ b/net/ipv6/netfilter/ip6t_hbh.c
@@ -65,13 +65,13 @@ hbh_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 			    NEXTHDR_HOP : NEXTHDR_DEST, NULL);
 	if (err < 0) {
 		if (err != -ENOENT)
-			*par->hotdrop = true;
+			par->hotdrop = true;
 		return false;
 	}
 
 	oh = skb_header_pointer(skb, ptr, sizeof(_optsh), &_optsh);
 	if (oh == NULL) {
-		*par->hotdrop = true;
+		par->hotdrop = true;
 		return false;
 	}
 
diff --git a/net/ipv6/netfilter/ip6t_mh.c b/net/ipv6/netfilter/ip6t_mh.c
index eb1c3d6..0c90c66 100644
--- a/net/ipv6/netfilter/ip6t_mh.c
+++ b/net/ipv6/netfilter/ip6t_mh.c
@@ -47,14 +47,14 @@ static bool mh_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 		/* We've been asked to examine this packet, and we
 		   can't.  Hence, no choice but to drop. */
 		pr_debug("Dropping evil MH tinygram.\n");
-		*par->hotdrop = true;
+		par->hotdrop = true;
 		return false;
 	}
 
 	if (mh->ip6mh_proto != IPPROTO_NONE) {
 		pr_debug("Dropping invalid MH Payload Proto: %u\n",
 			 mh->ip6mh_proto);
-		*par->hotdrop = true;
+		par->hotdrop = true;
 		return false;
 	}
 
diff --git a/net/ipv6/netfilter/ip6t_rt.c b/net/ipv6/netfilter/ip6t_rt.c
index ee58469..d8488c5 100644
--- a/net/ipv6/netfilter/ip6t_rt.c
+++ b/net/ipv6/netfilter/ip6t_rt.c
@@ -52,13 +52,13 @@ static bool rt_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	err = ipv6_find_hdr(skb, &ptr, NEXTHDR_ROUTING, NULL);
 	if (err < 0) {
 		if (err != -ENOENT)
-			*par->hotdrop = true;
+			par->hotdrop = true;
 		return false;
 	}
 
 	rh = skb_header_pointer(skb, ptr, sizeof(_route), &_route);
 	if (rh == NULL) {
-		*par->hotdrop = true;
+		par->hotdrop = true;
 		return false;
 	}
 
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index f130fd9..5c5b6b9 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -206,14 +206,14 @@ connlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 
 	if (connections < 0) {
 		/* kmalloc failed, drop it entirely */
-		*par->hotdrop = true;
+		par->hotdrop = true;
 		return false;
 	}
 
 	return (connections > info->limit) ^ info->inverse;
 
  hotdrop:
-	*par->hotdrop = true;
+	par->hotdrop = true;
 	return false;
 }
 
diff --git a/net/netfilter/xt_dccp.c b/net/netfilter/xt_dccp.c
index cc2c291..b63d2a3 100644
--- a/net/netfilter/xt_dccp.c
+++ b/net/netfilter/xt_dccp.c
@@ -107,7 +107,7 @@ dccp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 
 	dh = skb_header_pointer(skb, par->thoff, sizeof(_dh), &_dh);
 	if (dh == NULL) {
-		*par->hotdrop = true;
+		par->hotdrop = true;
 		return false;
 	}
 
@@ -120,7 +120,7 @@ dccp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		&& DCCHECK(match_types(dh, info->typemask),
 			   XT_DCCP_TYPE, info->flags, info->invflags)
 		&& DCCHECK(match_option(info->option, skb, par->thoff, dh,
-					par->hotdrop),
+					&par->hotdrop),
 			   XT_DCCP_OPTION, info->flags, info->invflags);
 }
 
diff --git a/net/netfilter/xt_esp.c b/net/netfilter/xt_esp.c
index 7c2d800..171ba82 100644
--- a/net/netfilter/xt_esp.c
+++ b/net/netfilter/xt_esp.c
@@ -52,7 +52,7 @@ static bool esp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		 * can't.  Hence, no choice but to drop.
 		 */
 		pr_debug("Dropping evil ESP tinygram.\n");
-		*par->hotdrop = true;
+		par->hotdrop = true;
 		return false;
 	}
 
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 25a6e54..b46a839 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -562,7 +562,7 @@ hashlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	return info->cfg.mode & XT_HASHLIMIT_INVERT;
 
  hotdrop:
-	*par->hotdrop = true;
+	par->hotdrop = true;
 	return false;
 }
 
diff --git a/net/netfilter/xt_multiport.c b/net/netfilter/xt_multiport.c
index 52beb68..ac1d3c3 100644
--- a/net/netfilter/xt_multiport.c
+++ b/net/netfilter/xt_multiport.c
@@ -87,7 +87,7 @@ multiport_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		 * can't.  Hence, no choice but to drop.
 		 */
 		pr_debug("Dropping evil offset=0 tinygram.\n");
-		*par->hotdrop = true;
+		par->hotdrop = true;
 		return false;
 	}
 
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 2808a7e..76aec6a 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -268,7 +268,7 @@ recent_mt(const struct sk_buff *skb, struct xt_action_param *par)
 			goto out;
 		e = recent_entry_init(t, &addr, par->family, ttl);
 		if (e == NULL)
-			*par->hotdrop = true;
+			par->hotdrop = true;
 		ret = !ret;
 		goto out;
 	}
diff --git a/net/netfilter/xt_sctp.c b/net/netfilter/xt_sctp.c
index 94d8b5d..c04fcf3 100644
--- a/net/netfilter/xt_sctp.c
+++ b/net/netfilter/xt_sctp.c
@@ -128,7 +128,7 @@ sctp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	sh = skb_header_pointer(skb, par->thoff, sizeof(_sh), &_sh);
 	if (sh == NULL) {
 		pr_debug("Dropping evil TCP offset=0 tinygram.\n");
-		*par->hotdrop = true;
+		par->hotdrop = true;
 		return false;
 	}
 	pr_debug("spt: %d\tdpt: %d\n", ntohs(sh->source), ntohs(sh->dest));
@@ -140,7 +140,7 @@ sctp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 			&& ntohs(sh->dest) <= info->dpts[1],
 			XT_SCTP_DEST_PORTS, info->flags, info->invflags)
 		&& SCCHECK(match_packet(skb, par->thoff + sizeof(sctp_sctphdr_t),
-					info, par->hotdrop),
+					info, &par->hotdrop),
 			   XT_SCTP_CHUNK_TYPES, info->flags, info->invflags);
 }
 
diff --git a/net/netfilter/xt_tcpmss.c b/net/netfilter/xt_tcpmss.c
index f90728f..c53d4d1 100644
--- a/net/netfilter/xt_tcpmss.c
+++ b/net/netfilter/xt_tcpmss.c
@@ -73,7 +73,7 @@ out:
 	return info->invert;
 
 dropit:
-	*par->hotdrop = true;
+	par->hotdrop = true;
 	return false;
 }
 
diff --git a/net/netfilter/xt_tcpudp.c b/net/netfilter/xt_tcpudp.c
index dedde33..c14d464 100644
--- a/net/netfilter/xt_tcpudp.c
+++ b/net/netfilter/xt_tcpudp.c
@@ -77,7 +77,7 @@ static bool tcp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		*/
 		if (par->fragoff == 1) {
 			pr_debug("Dropping evil TCP offset=1 frag.\n");
-			*par->hotdrop = true;
+			par->hotdrop = true;
 		}
 		/* Must not be a fragment. */
 		return false;
@@ -90,7 +90,7 @@ static bool tcp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		/* We've been asked to examine this packet, and we
 		   can't.  Hence, no choice but to drop. */
 		pr_debug("Dropping evil TCP offset=0 tinygram.\n");
-		*par->hotdrop = true;
+		par->hotdrop = true;
 		return false;
 	}
 
@@ -108,13 +108,13 @@ static bool tcp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		return false;
 	if (tcpinfo->option) {
 		if (th->doff * 4 < sizeof(_tcph)) {
-			*par->hotdrop = true;
+			par->hotdrop = true;
 			return false;
 		}
 		if (!tcp_find_option(tcpinfo->option, skb, par->thoff,
 				     th->doff*4 - sizeof(_tcph),
 				     tcpinfo->invflags & XT_TCP_INV_OPTION,
-				     par->hotdrop))
+				     &par->hotdrop))
 			return false;
 	}
 	return true;
@@ -143,7 +143,7 @@ static bool udp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 		/* We've been asked to examine this packet, and we
 		   can't.  Hence, no choice but to drop. */
 		pr_debug("Dropping evil UDP tinygram.\n");
-		*par->hotdrop = true;
+		par->hotdrop = true;
 		return false;
 	}
 
-- 
1.7.0.4

