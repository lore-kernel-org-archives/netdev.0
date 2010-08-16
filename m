From: =?iso-8859-1?Q?Gr=E9goire?= Baron <baronchon@n7mm.org>
Subject: [PATCH] net/sched: add ACT_CSUM action to update packets checksums
Date: Mon, 16 Aug 2010 23:15:42 +0200
Message-ID: <20100816211542.GA21083@n7mm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from solo.fdn.fr ([80.67.169.19]:39423 "EHLO solo.fdn.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689Ab0HPU60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Aug 2010 16:58:26 -0400
Received: from localhost.localdomain (playground.n7mm.org [80.67.176.86])
	by smtp.fdn.fr (Postfix) with ESMTP id C3BB22541E1
	for <netdev@vger.kernel.org>; Mon, 16 Aug 2010 22:58:24 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/sched: add ACT_CSUM action to update packets checksums

ACT_CSUM can be called just after ACT_PEDIT in order to re-compute some
altered checksums in IPv4 and IPv6 packets. The following checksums are
supported by this patch:
 - IPv4: IPv4 header, ICMP, IGMP, TCP, UDP & UDPLite
 - IPv6: ICMPv6, TCP, UDP & UDPLite
It's possible to request in the same action to update different kind of
checksums, if the packets flow mix TCP, UDP and UDPLite, ...

An example of usage is done in the associated iproute2 patch.

Signed-off-by: Gregoire Baron <baronchon@n7mm.org>
---
 include/linux/tc_act/Kbuild    |    1 +
 include/linux/tc_act/tc_csum.h |   32 ++
 include/net/tc_act/tc_csum.h   |   15 +
 net/sched/Kconfig              |   10 +
 net/sched/Makefile             |    1 +
 net/sched/act_csum.c           |  700 ++++++++++++++++++++++++++++++++++++++++
 6 files changed, 759 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/tc_act/tc_csum.h
 create mode 100644 include/net/tc_act/tc_csum.h
 create mode 100644 net/sched/act_csum.c

diff --git a/include/linux/tc_act/Kbuild b/include/linux/tc_act/Kbuild
index 7699093..67b501c 100644
--- a/include/linux/tc_act/Kbuild
+++ b/include/linux/tc_act/Kbuild
@@ -4,3 +4,4 @@ header-y += tc_mirred.h
 header-y += tc_pedit.h
 header-y += tc_nat.h
 header-y += tc_skbedit.h
+header-y += tc_csum.h
diff --git a/include/linux/tc_act/tc_csum.h b/include/linux/tc_act/tc_csum.h
new file mode 100644
index 0000000..a047c49
--- /dev/null
+++ b/include/linux/tc_act/tc_csum.h
@@ -0,0 +1,32 @@
+#ifndef __LINUX_TC_CSUM_H
+#define __LINUX_TC_CSUM_H
+
+#include <linux/types.h>
+#include <linux/pkt_cls.h>
+
+#define TCA_ACT_CSUM 16
+
+enum {
+	TCA_CSUM_UNSPEC,
+	TCA_CSUM_PARMS,
+	TCA_CSUM_TM,
+	__TCA_CSUM_MAX
+};
+#define TCA_CSUM_MAX (__TCA_CSUM_MAX - 1)
+
+enum {
+	TCA_CSUM_UPDATE_FLAG_IPV4HDR = 1,
+	TCA_CSUM_UPDATE_FLAG_ICMP    = 2,
+	TCA_CSUM_UPDATE_FLAG_IGMP    = 4,
+	TCA_CSUM_UPDATE_FLAG_TCP     = 8,
+	TCA_CSUM_UPDATE_FLAG_UDP     = 16,
+	TCA_CSUM_UPDATE_FLAG_UDPLITE = 32
+};
+
+struct tc_csum {
+	tc_gen;
+
+	__u32 update_flags;
+};
+
+#endif /* __LINUX_TC_CSUM_H */
diff --git a/include/net/tc_act/tc_csum.h b/include/net/tc_act/tc_csum.h
new file mode 100644
index 0000000..9e8710b
--- /dev/null
+++ b/include/net/tc_act/tc_csum.h
@@ -0,0 +1,15 @@
+#ifndef __NET_TC_CSUM_H
+#define __NET_TC_CSUM_H
+
+#include <linux/types.h>
+#include <net/act_api.h>
+
+struct tcf_csum {
+	struct tcf_common common;
+
+	u32 update_flags;
+};
+#define to_tcf_csum(pc) \
+	container_of(pc,struct tcf_csum,common)
+
+#endif /* __NET_TC_CSUM_H */
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 2f691fb..522d5a9 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -518,6 +518,16 @@ config NET_ACT_SKBEDIT
 	  To compile this code as a module, choose M here: the
 	  module will be called act_skbedit.
 
+config NET_ACT_CSUM
+        tristate "Checksum Updating"
+        depends on NET_CLS_ACT
+        ---help---
+	  Say Y here to update some common checksum after some direct
+	  packet alterations.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called act_csum.
+
 config NET_CLS_IND
 	bool "Incoming device classification"
 	depends on NET_CLS_U32 || NET_CLS_FW
diff --git a/net/sched/Makefile b/net/sched/Makefile
index f14e71b..960f5db 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -15,6 +15,7 @@ obj-$(CONFIG_NET_ACT_NAT)	+= act_nat.o
 obj-$(CONFIG_NET_ACT_PEDIT)	+= act_pedit.o
 obj-$(CONFIG_NET_ACT_SIMP)	+= act_simple.o
 obj-$(CONFIG_NET_ACT_SKBEDIT)	+= act_skbedit.o
+obj-$(CONFIG_NET_ACT_CSUM)	+= act_csum.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
 obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
new file mode 100644
index 0000000..6f24012
--- /dev/null
+++ b/net/sched/act_csum.c
@@ -0,0 +1,700 @@
+/*
+ * Checksum updating actions
+ *
+ * Copyright (c) 2010 Gregoire Baron <baronchon@n7mm.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ */
+
+#include <linux/types.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/spinlock.h>
+
+#include <linux/netlink.h>
+#include <net/netlink.h>
+#include <linux/rtnetlink.h>
+
+#include <linux/skbuff.h>
+
+#include <net/ip.h>
+#include <net/ipv6.h>
+#include <net/icmp.h>
+#include <linux/icmpv6.h>
+#include <linux/igmp.h>
+#include <net/tcp.h>
+#include <net/udp.h>
+
+#include <net/act_api.h>
+
+#include <linux/tc_act/tc_csum.h>
+#include <net/tc_act/tc_csum.h>
+
+#define CSUM_TAB_MASK 15
+static struct tcf_common *tcf_csum_ht[CSUM_TAB_MASK + 1];
+static u32 csum_idx_gen;
+static DEFINE_RWLOCK(csum_lock);
+
+static struct tcf_hashinfo csum_hash_info = {
+	.htab	=	tcf_csum_ht,
+	.hmask	=	CSUM_TAB_MASK,
+	.lock	=	&csum_lock,
+};
+
+static const struct nla_policy csum_policy[TCA_CSUM_MAX + 1] = {
+	[TCA_CSUM_PARMS] = { .len = sizeof(struct tc_csum), },
+};
+
+static int tcf_csum_init(struct nlattr *nla, struct nlattr *est,
+			 struct tc_action *a, int ovr, int bind)
+{
+	struct nlattr *tb[TCA_CSUM_MAX + 1];
+	struct tc_csum *parm;
+	struct tcf_common *pc;
+	struct tcf_csum *p;
+	int ret = 0, err;
+
+	if (nla == NULL)
+		return -EINVAL;
+
+	err = nla_parse_nested(tb, TCA_CSUM_MAX, nla,csum_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[TCA_CSUM_PARMS] == NULL)
+		return -EINVAL;
+	parm = nla_data(tb[TCA_CSUM_PARMS]);
+
+	pc = tcf_hash_check(parm->index, a, bind, &csum_hash_info);
+	if (!pc) {
+		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind, &csum_idx_gen, &csum_hash_info);
+		if (IS_ERR(pc))
+			return PTR_ERR(pc);
+		p = to_tcf_csum(pc);
+		ret = ACT_P_CREATED;
+	} else {
+		p = to_tcf_csum(pc);
+		if (!ovr) {
+			tcf_hash_release(pc, bind, &csum_hash_info);
+			return -EEXIST;
+		}
+	}
+
+	spin_lock_bh(&p->tcf_lock);
+	p->tcf_action = parm->action;
+	p->update_flags = parm->update_flags;
+	spin_unlock_bh(&p->tcf_lock);
+
+	if (ret == ACT_P_CREATED)
+		tcf_hash_insert(pc, &csum_hash_info);
+
+	return ret;
+}
+
+static int tcf_csum_cleanup(struct tc_action *a, int bind)
+{
+	struct tcf_csum *p = a->priv;
+	return tcf_hash_release(&p->common, bind, &csum_hash_info);
+}
+
+static int tcf_csum_ipv4_icmp(struct sk_buff *skb, struct iphdr *iph,
+			      unsigned int ihl, unsigned int ipl)
+{
+	struct icmphdr *icmph;
+	int hl;
+	int ntkoff;
+
+	ntkoff = skb_network_offset(skb);
+
+	hl = ihl + sizeof(*icmph);
+
+	if (!pskb_may_pull(skb, ipl + ntkoff) || (ipl < hl) ||
+	    (skb_cloned(skb) &&
+	     !skb_clone_writable(skb, hl + ntkoff) &&
+	     pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+		goto fail;
+
+	icmph = (void *)(skb_network_header(skb) + ihl);
+
+	icmph->checksum = 0;
+	skb->csum = csum_partial(icmph, ipl - ihl, 0);
+	icmph->checksum = csum_fold(skb->csum);
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	return 1;
+
+fail:
+	return 0;
+}
+
+static int tcf_csum_ipv4_igmp(struct sk_buff *skb, struct iphdr *iph,
+			      unsigned int ihl, unsigned int ipl)
+{
+	struct igmphdr *igmph;
+	int hl;
+	int ntkoff;
+
+	ntkoff = skb_network_offset(skb);
+
+	hl = ihl + sizeof(*igmph);
+
+	if (!pskb_may_pull(skb, ipl + ntkoff) || (ipl < hl) ||
+	    (skb_cloned(skb) &&
+	     !skb_clone_writable(skb, hl + ntkoff) &&
+	     pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+		goto fail;
+
+	igmph = (void *)(skb_network_header(skb) + ihl);
+
+	igmph->csum = 0;
+	skb->csum = csum_partial(igmph, ipl - ihl, 0);
+	igmph->csum = csum_fold(skb->csum);
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	return 1;
+
+fail:
+	return 0;
+}
+
+static int tcf_csum_ipv6_icmp(struct sk_buff *skb, struct ipv6hdr *ip6h,
+			      unsigned int ihl, unsigned int ipl)
+{
+	struct icmp6hdr *icmp6h;
+	int hl;
+	int ntkoff;
+
+	ntkoff = skb_network_offset(skb);
+
+	hl = ihl + sizeof(*icmp6h);
+
+	if (!pskb_may_pull(skb, ipl + ntkoff) || (ipl < hl) ||
+	    (skb_cloned(skb) &&
+	     !skb_clone_writable(skb, hl + ntkoff) &&
+	     pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+		goto fail;
+
+	icmp6h = (void *)(skb_network_header(skb) + ihl);
+
+	icmp6h->icmp6_cksum = 0;
+	skb->csum = csum_partial(icmp6h, ipl - ihl, 0);
+	icmp6h->icmp6_cksum = csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
+					      ipl - ihl, IPPROTO_ICMPV6,
+					      skb->csum);
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	return 1;
+
+fail:
+	return 0;
+}
+
+static int tcf_csum_ipv4_tcp(struct sk_buff *skb, struct iphdr *iph,
+			     unsigned int ihl, unsigned int ipl)
+{
+	struct tcphdr *tcph;
+	int hl;
+	int ntkoff;
+
+	ntkoff = skb_network_offset(skb);
+
+	hl = ihl + sizeof(*tcph);
+
+	if (!pskb_may_pull(skb, ipl + ntkoff) || (ipl < hl) ||
+	    (skb_cloned(skb) &&
+	     !skb_clone_writable(skb, hl + ntkoff) &&
+	     pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+		goto fail;
+
+	tcph = (void *)(skb_network_header(skb) + ihl);
+
+	tcph->check = 0;
+	skb->csum = csum_partial(tcph, ipl - ihl, 0);
+	tcph->check = tcp_v4_check(ipl - ihl,
+				   iph->saddr, iph->daddr, skb->csum);
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	return 1;
+
+fail:
+	return 0;
+}
+
+static int tcf_csum_ipv6_tcp(struct sk_buff *skb, struct ipv6hdr *ip6h,
+			     unsigned int ihl, unsigned int ipl)
+{
+	struct tcphdr *tcph;
+	int hl;
+	int ntkoff;
+
+	ntkoff = skb_network_offset(skb);
+
+	hl = ihl + sizeof(*tcph);
+
+	if (!pskb_may_pull(skb, ipl + ntkoff) || (ipl < hl) ||
+	    (skb_cloned(skb) &&
+	     !skb_clone_writable(skb, hl + ntkoff) &&
+	     pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+		goto fail;
+
+	tcph = (void *)(skb_network_header(skb) + ihl);
+
+	tcph->check = 0;
+	skb->csum = csum_partial(tcph, ipl - ihl, 0);
+	tcph->check = csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
+				      ipl - ihl, IPPROTO_TCP,
+				      skb->csum);
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	return 1;
+
+fail:
+	return 0;
+}
+
+static int tcf_csum_ipv4_udp(struct sk_buff *skb, struct iphdr *iph,
+			     unsigned int ihl, unsigned int ipl, int udplite)
+{
+	struct udphdr *udph;
+	int hl;
+	int ntkoff;
+	u16 ul;
+
+	/* Support both UDP and UDPLITE checksum algorithms,
+	 * Don't use udph->len to get the real length without any protocol check,
+	 * UDPLITE uses udph->len for another thing,
+	 * Use iph->tot_len, or just ipl.
+	 */
+
+	ntkoff = skb_network_offset(skb);
+
+	hl = ihl + sizeof(*udph);
+
+	if (!pskb_may_pull(skb, ipl + ntkoff) || (ipl < hl) ||
+	    (skb_cloned(skb) &&
+	     !skb_clone_writable(skb, hl + ntkoff) &&
+	     pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+		goto fail;
+
+	udph = (void *)(skb_network_header(skb) + ihl);
+	ul = ntohs(udph->len);
+
+	if (udplite || udph->check) {
+
+		udph->check = 0;
+
+		if (udplite) {
+			if (ul == 0)
+				skb->csum = csum_partial(udph, ipl - ihl, 0);
+
+			else if ((ul >= sizeof(*udph)) && (ul <= ipl - ihl))
+				skb->csum = csum_partial(udph, ul, 0);
+
+			else
+				goto ignore_obscure_skb;
+		} else {
+			if (ul != ipl - ihl)
+				goto ignore_obscure_skb;
+
+			skb->csum = csum_partial(udph, ul, 0);
+		}
+
+		udph->check = csum_tcpudp_magic(iph->saddr, iph->daddr,
+						ul, iph->protocol,
+						skb->csum);
+
+		if (!udph->check)
+			udph->check = CSUM_MANGLED_0;
+	}
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+ignore_obscure_skb:
+	return 1;
+
+fail:
+	return 0;
+}
+
+static int tcf_csum_ipv6_udp(struct sk_buff *skb, struct ipv6hdr *ip6h,
+			     unsigned int ihl, unsigned int ipl, int udplite)
+{
+	struct udphdr *udph;
+	int hl;
+	int ntkoff;
+	u16 ul;
+
+	/* Support both UDP and UDPLITE checksum algorithms,
+	 * Don't use udph->len to get the real length without any protocol check,
+	 * UDPLITE uses udph->len for another thing,
+	 * Use ip6h->payload_len + sizeof(*ip6h) ... , or just ipl.
+	 */
+
+	ntkoff = skb_network_offset(skb);
+
+	hl = ihl + sizeof(*udph);
+
+	if (!pskb_may_pull(skb, ipl + ntkoff) || (ipl < hl) ||
+	    (skb_cloned(skb) &&
+	     !skb_clone_writable(skb, hl + ntkoff) &&
+	     pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+		goto fail;
+
+	udph = (void *)(skb_network_header(skb) + ihl);
+	ul = ntohs(udph->len);
+
+	udph->check = 0;
+
+	if (udplite) {
+		if (ul == 0)
+			skb->csum = csum_partial(udph, ipl - ihl, 0);
+
+		else if ((ul >= sizeof(*udph)) && (ul <= ipl - ihl))
+			skb->csum = csum_partial(udph, ul, 0);
+
+		else
+			goto ignore_obscure_skb;
+	} else {
+		if (ul != ipl - ihl)
+			goto ignore_obscure_skb;
+
+		skb->csum = csum_partial(udph, ul, 0);
+	}
+
+	udph->check = csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr, ul,
+				      udplite ? IPPROTO_UDPLITE : IPPROTO_UDP,
+				      skb->csum);
+
+	if (!udph->check)
+		udph->check = CSUM_MANGLED_0;
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+ignore_obscure_skb:
+	return 1;
+
+fail:
+	return 0;
+}
+
+static int tcf_csum_ipv4(struct sk_buff *skb, u32 update_flags)
+{
+	struct iphdr *iph;
+	int ntkoff;
+
+	ntkoff = skb_network_offset(skb);
+
+	if (!pskb_may_pull(skb, sizeof(*iph) + ntkoff))
+		goto fail;
+
+	iph = ip_hdr(skb);
+
+	switch (iph->frag_off & htons(IP_OFFSET) ? 0 : iph->protocol) {
+	case IPPROTO_ICMP:
+	{
+		if (update_flags & TCA_CSUM_UPDATE_FLAG_ICMP)
+			if (!tcf_csum_ipv4_icmp(skb, iph,
+						iph->ihl * 4, ntohs(iph->tot_len)))
+				goto fail;
+		break;
+	}
+	case IPPROTO_IGMP:
+	{
+		if (update_flags & TCA_CSUM_UPDATE_FLAG_IGMP)
+			if (!tcf_csum_ipv4_igmp(skb, iph,
+						iph->ihl * 4, ntohs(iph->tot_len)))
+				goto fail;
+		break;
+	}
+	case IPPROTO_TCP:
+	{
+		if (update_flags & TCA_CSUM_UPDATE_FLAG_TCP)
+			if (!tcf_csum_ipv4_tcp(skb, iph,
+					       iph->ihl * 4, ntohs(iph->tot_len)))
+				goto fail;
+		break;
+	}
+	case IPPROTO_UDP:
+	{
+		if (update_flags & TCA_CSUM_UPDATE_FLAG_UDP)
+			if (!tcf_csum_ipv4_udp(skb, iph,
+					       iph->ihl * 4, ntohs(iph->tot_len), 0))
+				goto fail;
+		break;
+	}
+	case IPPROTO_UDPLITE:
+	{
+		if (update_flags & TCA_CSUM_UPDATE_FLAG_UDPLITE)
+			if (!tcf_csum_ipv4_udp(skb, iph,
+					       iph->ihl * 4, ntohs(iph->tot_len), 1))
+				goto fail;
+		break;
+	}
+	default:
+		break;
+	}
+
+	if (update_flags & TCA_CSUM_UPDATE_FLAG_IPV4HDR) {
+		if (skb_cloned(skb) &&
+		    !skb_clone_writable(skb, sizeof(*iph) + ntkoff) &&
+		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+			goto fail;
+
+		ip_send_check(iph);
+	}
+
+	return 1;
+
+fail:
+	return 0;
+}
+
+static int tcf_csum_ipv6_hopopts(struct ipv6_opt_hdr *ip6xh,
+				  unsigned int ixhl, unsigned int *pl)
+{
+	int off, len, optlen;
+	unsigned char *xh = (void *)ip6xh;
+
+	off = sizeof(*ip6xh);
+	len = ixhl - off;
+
+	while (len > 0) {
+		switch (xh[off])
+		{
+		case IPV6_TLV_PAD0:
+			optlen = 1;
+			break;
+		case IPV6_TLV_JUMBO:
+			optlen = xh[off + 1] + 2;
+			if (xh[off + 1] != 4 || (off & 3) != 2)
+				/* wrong jumbo option length/alignment */
+				goto fail;
+			*pl = ntohl(*(__be32 *)(xh + off + 2));
+			goto done;
+		default:
+			optlen = xh[off + 1] + 2;
+			if (optlen > len)
+				goto ignore;
+			break;
+		}
+		off += optlen;
+		len -= optlen;
+	}
+
+done:
+ignore:
+	return 1;
+
+fail:
+	return 0;
+}
+
+static int tcf_csum_ipv6(struct sk_buff *skb, u32 update_flags)
+{
+	struct ipv6hdr *ip6h;
+	struct ipv6_opt_hdr *ip6xh;
+	unsigned int hl, ixhl;
+	unsigned int pl;
+	int ntkoff;
+	u8 nexthdr;
+
+	ntkoff = skb_network_offset(skb);
+
+	hl = sizeof(*ip6h);
+
+	if (!pskb_may_pull(skb, hl + ntkoff))
+		goto fail;
+
+	ip6h = ipv6_hdr(skb);
+
+	pl = ntohs(ip6h->payload_len);
+	nexthdr = ip6h->nexthdr;
+
+	do {
+		switch (nexthdr) {
+		case NEXTHDR_FRAGMENT:
+			goto ignore_skb;
+		case NEXTHDR_ROUTING:
+		case NEXTHDR_HOP:
+		case NEXTHDR_DEST:
+		{
+			if (!pskb_may_pull(skb, hl + sizeof(*ip6xh) + ntkoff))
+				goto fail;
+			ip6xh = (void *)(skb_network_header(skb) + hl);
+			ixhl = ipv6_optlen(ip6xh);
+			if (!pskb_may_pull(skb, hl + ixhl + ntkoff))
+				goto fail;
+			if ((nexthdr == NEXTHDR_HOP) &&
+			    !(tcf_csum_ipv6_hopopts(ip6xh, ixhl, &pl)))
+				goto fail;
+			nexthdr = ip6xh->nexthdr;
+			hl += ixhl;
+			break;
+		}
+		case IPPROTO_ICMPV6:
+		{
+			if (update_flags & TCA_CSUM_UPDATE_FLAG_ICMP)
+				if (!tcf_csum_ipv6_icmp(skb, ip6h,
+							hl, pl + sizeof(*ip6h)))
+					goto fail;
+			goto done;
+		}
+		case IPPROTO_TCP:
+		{
+			if (update_flags & TCA_CSUM_UPDATE_FLAG_TCP)
+				if (!tcf_csum_ipv6_tcp(skb, ip6h,
+						       hl, pl + sizeof(*ip6h)))
+					goto fail;
+			goto done;
+		}
+		case IPPROTO_UDP:
+		{
+			if (update_flags & TCA_CSUM_UPDATE_FLAG_UDP)
+				if (!tcf_csum_ipv6_udp(skb, ip6h,
+						       hl, pl + sizeof(*ip6h), 0))
+					goto fail;
+			goto done;
+		}
+		case IPPROTO_UDPLITE:
+		{
+			if (update_flags & TCA_CSUM_UPDATE_FLAG_UDPLITE)
+				if (!tcf_csum_ipv6_udp(skb, ip6h,
+						       hl, pl + sizeof(*ip6h), 1))
+					goto fail;
+			goto done;
+		}
+		default:
+			goto ignore_skb;
+		}
+	} while (pskb_may_pull(skb, hl + 1 + ntkoff));
+
+done:
+ignore_skb:
+	return 1;
+
+fail:
+	return 0;
+}
+
+static int tcf_csum(struct sk_buff *skb,
+		    struct tc_action *a, struct tcf_result *res)
+{
+	struct tcf_csum *p = a->priv;
+	int action;
+	u32 update_flags;
+
+	spin_lock(&p->tcf_lock);
+	p->tcf_tm.lastuse = jiffies;
+	p->tcf_bstats.bytes += qdisc_pkt_len(skb);
+	p->tcf_bstats.packets++;
+	action = p->tcf_action;
+	update_flags = p->update_flags;
+	spin_unlock(&p->tcf_lock);
+
+	if (unlikely(action == TC_ACT_SHOT))
+		goto drop;
+
+	switch (skb->protocol) {
+	case cpu_to_be16(ETH_P_IP):
+	{
+		if (!tcf_csum_ipv4(skb, update_flags))
+			goto drop;
+		break;
+	}
+	case cpu_to_be16(ETH_P_IPV6):
+	{
+		if (!tcf_csum_ipv6(skb, update_flags))
+			goto drop;
+		break;
+	}
+	default:
+		break;
+	}
+
+	return action;
+
+drop:
+	spin_lock(&p->tcf_lock);
+	p->tcf_qstats.drops++;
+	spin_unlock(&p->tcf_lock);
+	return TC_ACT_SHOT;
+}
+
+static int tcf_csum_dump(struct sk_buff *skb,
+			 struct tc_action *a, int bind, int ref)
+{
+	unsigned char *b = skb_tail_pointer(skb);
+	struct tcf_csum *p = a->priv;
+	struct tc_csum *opt;
+	struct tcf_t t;
+	int s;
+
+	s = sizeof(*opt);
+
+	/* netlink spinlocks held above us - must use ATOMIC */
+	opt = kzalloc(s, GFP_ATOMIC);
+	if (unlikely(!opt))
+		return -ENOBUFS;
+
+	opt->update_flags = p->update_flags;
+
+	opt->index = p->tcf_index;
+	opt->action = p->tcf_action;
+	opt->refcnt = p->tcf_refcnt - ref;
+	opt->bindcnt = p->tcf_bindcnt - bind;
+
+	NLA_PUT(skb,TCA_CSUM_PARMS,s,opt);
+	t.install = jiffies_to_clock_t(jiffies - p->tcf_tm.install);
+	t.lastuse = jiffies_to_clock_t(jiffies - p->tcf_tm.lastuse);
+	t.expires = jiffies_to_clock_t(p->tcf_tm.expires);
+	NLA_PUT(skb,TCA_CSUM_TM,sizeof(t),&t);
+
+	kfree(opt);
+
+	return skb->len;
+
+nla_put_failure:
+	nlmsg_trim(skb, b);
+	kfree(opt);
+	return -1;
+}
+
+static struct tc_action_ops act_csum_ops = {
+	.kind		=	"csum",
+	.hinfo		=	&csum_hash_info,
+	.type		=	TCA_ACT_CSUM,
+	.capab		=	TCA_CAP_NONE,
+	.owner		=	THIS_MODULE,
+	.act		=	tcf_csum,
+	.dump		=	tcf_csum_dump,
+	.cleanup	=	tcf_csum_cleanup,
+	.lookup		=	tcf_hash_search,
+	.init		=	tcf_csum_init,
+	.walk		=	tcf_generic_walker
+};
+
+MODULE_DESCRIPTION("Checksum updating actions");
+MODULE_LICENSE("GPL");
+
+static int __init csum_init_module(void)
+{
+	return tcf_register_action(&act_csum_ops);
+}
+
+static void __exit csum_cleanup_module(void)
+{
+	tcf_unregister_action(&act_csum_ops);
+}
+
+module_init(csum_init_module);
+module_exit(csum_cleanup_module);
