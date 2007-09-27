From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 15:34:47 +0800
Message-ID: <20070927073446.GA14643@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3098 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750703AbXI0HfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 03:35:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

[PKT_SCHED]: Add stateless NAT

Stateless NAT is useful in controlled environments where restrictions are
placed on through traffic such that we don't need connection tracking to
correctly NAT protocol-specific data.

In particular, this is of interest when the number of flows or the number
of addresses being NATed is large, or if connection tracking information
has to be replicated and where it is not practical to do so.

Previously we had stateless NAT functionality which was integrated into
the IPv4 routing subsystem.  This was a great solution as long as the NAT
worked on a subnet to subnet basis such that the number of NAT rules was
relatively small.  The reason is that for SNAT the routing based system
had to perform a linear scan through the rules.

If the number of rules is large then major renovations would have take
place in the routing subsystem to make this practical.

For the time being, the least intrusive way of achieving this is to use
the u32 classifier written by Alexey Kuznetsov along with the actions
infrastructure implemented by Jamal Hadi Salim.

The following patch is an attempt at this problem by creating a new nat
action that can be invoked from u32 hash tables which would allow large
number of stateless NAT rules that can be used/updated in constant time.

The actual NAT code is mostly based on the previous stateless NAT code
written by Alexey.  In future we might be able to utilise the protocol
NAT code from netfilter to improve support for other protocols.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/tc_act/tc_nat.h b/include/linux/tc_act/tc_nat.h
new file mode 100644
index 0000000..9280c6f
--- /dev/null
+++ b/include/linux/tc_act/tc_nat.h
@@ -0,0 +1,29 @@
+#ifndef __LINUX_TC_NAT_H
+#define __LINUX_TC_NAT_H
+
+#include <linux/pkt_cls.h>
+#include <linux/types.h>
+
+#define TCA_ACT_NAT 9
+
+enum
+{
+	TCA_NAT_UNSPEC,
+	TCA_NAT_PARMS,
+	TCA_NAT_TM,
+	__TCA_NAT_MAX
+};
+#define TCA_NAT_MAX (__TCA_NAT_MAX - 1)
+
+#define TCA_NAT_FLAG_EGRESS 1
+                                                                               
+struct tc_nat
+{
+	tc_gen;
+	__be32 old_addr;
+	__be32 new_addr;
+	__be32 mask;
+	__u32 flags;
+};
+
+#endif
diff --git a/include/net/tc_act/tc_nat.h b/include/net/tc_act/tc_nat.h
new file mode 100644
index 0000000..4a691f3
--- /dev/null
+++ b/include/net/tc_act/tc_nat.h
@@ -0,0 +1,21 @@
+#ifndef __NET_TC_NAT_H
+#define __NET_TC_NAT_H
+
+#include <linux/types.h>
+#include <net/act_api.h>
+
+struct tcf_nat {
+	struct tcf_common common;
+
+	__be32 old_addr;
+	__be32 new_addr;
+	__be32 mask;
+	u32 flags;
+};
+
+static inline struct tcf_nat *to_tcf_nat(struct tcf_common *pc)
+{
+	return container_of(pc, struct tcf_nat, common);
+}
+
+#endif /* __NET_TC_NAT_H */
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 8a74cac..22b34f2 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -447,6 +447,17 @@ config NET_ACT_IPT
 	  To compile this code as a module, choose M here: the
 	  module will be called ipt.
 
+config NET_ACT_NAT
+        tristate "Stateless NAT"
+        depends on NET_CLS_ACT
+        select NETFILTER
+        ---help---
+	  Say Y here to do stateless NAT on IPv4 packets.  You should use
+	  netfilter for NAT unless you know what you are doing.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called ipt.
+
 config NET_ACT_PEDIT
         tristate "Packet Editing"
         depends on NET_CLS_ACT
diff --git a/net/sched/Makefile b/net/sched/Makefile
index b67c36f..81ecbe8 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -11,6 +11,7 @@ obj-$(CONFIG_NET_ACT_POLICE)	+= act_police.o
 obj-$(CONFIG_NET_ACT_GACT)	+= act_gact.o
 obj-$(CONFIG_NET_ACT_MIRRED)	+= act_mirred.o
 obj-$(CONFIG_NET_ACT_IPT)	+= act_ipt.o
+obj-$(CONFIG_NET_ACT_NAT)	+= act_nat.o
 obj-$(CONFIG_NET_ACT_PEDIT)	+= act_pedit.o
 obj-$(CONFIG_NET_ACT_SIMP)	+= act_simple.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
new file mode 100644
index 0000000..efd6d7d
--- /dev/null
+++ b/net/sched/act_nat.c
@@ -0,0 +1,313 @@
+/*
+ * Stateless NAT actions
+ *
+ * Copyright (c) 2007 Herbert Xu <herbert@gondor.apana.org.au>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ */
+
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netfilter.h>
+#include <linux/rtnetlink.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/string.h>
+#include <linux/tc_act/tc_nat.h>
+#include <net/act_api.h>
+#include <net/icmp.h>
+#include <net/ip.h>
+#include <net/netlink.h>
+#include <net/tc_act/tc_nat.h>
+#include <net/tcp.h>
+#include <net/udp.h>
+
+
+#define NAT_TAB_MASK	15
+static struct tcf_common *tcf_nat_ht[NAT_TAB_MASK + 1];
+static u32 nat_idx_gen;
+static DEFINE_RWLOCK(nat_lock);
+
+static struct tcf_hashinfo nat_hash_info = {
+	.htab	=	tcf_nat_ht,
+	.hmask	=	NAT_TAB_MASK,
+	.lock	=	&nat_lock,
+};
+
+static int tcf_nat_init(struct rtattr *rta, struct rtattr *est,
+			struct tc_action *a, int ovr, int bind)
+{
+	struct rtattr *tb[TCA_NAT_MAX];
+	struct tc_nat *parm;
+	int ret = 0;
+	struct tcf_nat *p;
+	struct tcf_common *pc;
+
+	if (rta == NULL || rtattr_parse_nested(tb, TCA_NAT_MAX, rta) < 0)
+		return -EINVAL;
+
+	if (tb[TCA_NAT_PARMS - 1] == NULL ||
+	    RTA_PAYLOAD(tb[TCA_NAT_PARMS - 1]) < sizeof(*parm))
+		return -EINVAL;
+	parm = RTA_DATA(tb[TCA_NAT_PARMS - 1]);
+
+	pc = tcf_hash_check(parm->index, a, bind, &nat_hash_info);
+	if (!pc) {
+		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind,
+				     &nat_idx_gen, &nat_hash_info);
+		if (unlikely(!pc))
+			return -ENOMEM;
+		p = to_tcf_nat(pc);
+		ret = ACT_P_CREATED;
+	} else {
+		p = to_tcf_nat(pc);
+		if (!ovr) {
+			tcf_hash_release(pc, bind, &nat_hash_info);
+			return -EEXIST;
+		}
+	}
+
+	spin_lock_bh(&p->tcf_lock);
+	p->old_addr = parm->old_addr;
+	p->new_addr = parm->new_addr;
+	p->mask = parm->mask;
+	p->flags = parm->flags;
+
+	p->tcf_action = parm->action;
+	spin_unlock_bh(&p->tcf_lock);
+
+	if (ret == ACT_P_CREATED)
+		tcf_hash_insert(pc, &nat_hash_info);
+
+	return ret;
+}
+
+static int tcf_nat_cleanup(struct tc_action *a, int bind)
+{
+	struct tcf_nat *p = a->priv;
+
+	return tcf_hash_release(&p->common, bind, &nat_hash_info);
+}
+
+static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
+		   struct tcf_result *res)
+{
+	struct tcf_nat *p = a->priv;
+	struct iphdr *iph;
+	__be32 old_addr;
+	__be32 new_addr;
+	__be32 mask;
+	__be32 addr;
+	int egress;
+	int action;
+	int ihl;
+
+	spin_lock(&p->tcf_lock);
+
+	p->tcf_tm.lastuse = jiffies;
+	old_addr = p->old_addr;
+	new_addr = p->new_addr;
+	mask = p->mask;
+	egress = p->flags & TCA_NAT_FLAG_EGRESS;
+	action = p->tcf_action;
+
+	p->tcf_bstats.bytes += skb->len;
+	p->tcf_bstats.packets++;
+
+	spin_unlock(&p->tcf_lock);
+
+	if (!pskb_may_pull(skb, sizeof(*iph)))
+		return TC_ACT_SHOT;
+
+	iph = ip_hdr(skb);
+
+	if (egress)
+		addr = iph->saddr;
+	else
+		addr = iph->daddr;
+
+	if (!((old_addr ^ addr) & mask)) {
+		if (skb_cloned(skb) &&
+		    !skb_clone_writable(skb, sizeof(*iph)) &&
+		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+			return TC_ACT_SHOT;
+
+		new_addr &= mask;
+		new_addr |= addr & ~mask;
+
+		/* Rewrite IP header */
+		iph = ip_hdr(skb);
+		if (egress)
+			iph->saddr = new_addr;
+		else
+			iph->daddr = new_addr;
+
+		nf_csum_replace4(&iph->check, addr, new_addr);
+	}
+
+	ihl = iph->ihl * 4;
+
+	/* It would be nice to share code with stateful NAT. */
+	switch (iph->frag_off & htons(IP_OFFSET) ? 0 : iph->protocol) {
+	case IPPROTO_TCP:
+	{
+		struct tcphdr *tcph;
+
+		if (!pskb_may_pull(skb, ihl + sizeof(*tcph)) ||
+		    (skb_cloned(skb) &&
+		     !skb_clone_writable(skb, ihl + sizeof(*tcph)) &&
+		     pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+			return TC_ACT_SHOT;
+
+		tcph = (void *)(skb_network_header(skb) + ihl);
+		nf_proto_csum_replace4(&tcph->check, skb, addr, new_addr, 1);
+		break;
+	}
+	case IPPROTO_UDP:
+	{
+		struct udphdr *udph;
+
+		if (!pskb_may_pull(skb, ihl + sizeof(*udph)) ||
+		    (skb_cloned(skb) &&
+		     !skb_clone_writable(skb, ihl + sizeof(*udph)) &&
+		     pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+			return TC_ACT_SHOT;
+
+		udph = (void *)(skb_network_header(skb) + ihl);
+		if (udph->check || skb->ip_summed == CHECKSUM_PARTIAL) {
+			nf_proto_csum_replace4(&udph->check, skb, addr,
+					       new_addr, 1);
+			if (!udph->check)
+				udph->check = CSUM_MANGLED_0;
+		}
+		break;
+	}
+	case IPPROTO_ICMP:
+	{
+		struct icmphdr *icmph;
+
+		if (!pskb_may_pull(skb, ihl + sizeof(*icmph) + sizeof(*iph)))
+			return TC_ACT_SHOT;
+
+		icmph = (void *)(skb_network_header(skb) + ihl);
+
+		if ((icmph->type != ICMP_DEST_UNREACH) &&
+		    (icmph->type != ICMP_TIME_EXCEEDED) &&
+		    (icmph->type != ICMP_PARAMETERPROB))
+			break;
+
+		iph = (void *)(icmph + 1);
+		if (egress)
+			addr = iph->daddr;
+		else
+			addr = iph->saddr;
+
+		if ((old_addr ^ addr) & mask)
+			break;
+
+		if (skb_cloned(skb) &&
+		    !skb_clone_writable(skb,
+		    			ihl + sizeof(*icmph) + sizeof(*iph)) &&
+		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+			return TC_ACT_SHOT;
+
+		icmph = (void *)(skb_network_header(skb) + ihl);
+		iph = (void *)(icmph + 1);
+
+		new_addr &= mask;
+		new_addr |= addr & ~mask;
+
+		/* XXX Fix up the inner checksums. */
+		if (egress)
+			iph->daddr = new_addr;
+		else
+			iph->saddr = new_addr;
+
+		nf_proto_csum_replace4(&icmph->checksum, skb, addr, new_addr,
+				       1);
+		break;
+	}
+	default:
+		break;
+	}
+
+	return action;
+}
+
+static int tcf_nat_dump(struct sk_buff *skb, struct tc_action *a,
+			int bind, int ref)
+{
+	unsigned char *b = skb_tail_pointer(skb);
+	struct tcf_nat *p = a->priv;
+	struct tc_nat *opt;
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
+	opt->old_addr = p->old_addr;
+	opt->new_addr = p->new_addr;
+	opt->mask = p->mask;
+	opt->flags = p->flags;
+
+	opt->index = p->tcf_index;
+	opt->action = p->tcf_action;
+	opt->refcnt = p->tcf_refcnt - ref;
+	opt->bindcnt = p->tcf_bindcnt - bind;
+
+	RTA_PUT(skb, TCA_NAT_PARMS, s, opt);
+	t.install = jiffies_to_clock_t(jiffies - p->tcf_tm.install);
+	t.lastuse = jiffies_to_clock_t(jiffies - p->tcf_tm.lastuse);
+	t.expires = jiffies_to_clock_t(p->tcf_tm.expires);
+	RTA_PUT(skb, TCA_NAT_TM, sizeof(t), &t);
+
+	kfree(opt);
+
+	return skb->len;
+
+rtattr_failure:
+	nlmsg_trim(skb, b);
+	kfree(opt);
+	return -1;
+}
+
+static struct tc_action_ops act_nat_ops = {
+	.kind		=	"nat",
+	.hinfo		=	&nat_hash_info,
+	.type		=	TCA_ACT_NAT,
+	.capab		=	TCA_CAP_NONE,
+	.owner		=	THIS_MODULE,
+	.act		=	tcf_nat,
+	.dump		=	tcf_nat_dump,
+	.cleanup	=	tcf_nat_cleanup,
+	.lookup		=	tcf_hash_search,
+	.init		=	tcf_nat_init,
+	.walk		=	tcf_generic_walker
+};
+
+MODULE_DESCRIPTION("Stateless NAT actions");
+MODULE_LICENSE("GPL");
+
+static int __init nat_init_module(void)
+{
+	return tcf_register_action(&act_nat_ops);
+}
+
+static void __exit nat_cleanup_module(void)
+{
+	tcf_unregister_action(&act_nat_ops);
+}
+
+module_init(nat_init_module);
+module_exit(nat_cleanup_module);
