From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH RFC] act_cpu: packet distributing
Date: Wed, 14 Jul 2010 11:17:55 +0800
Message-ID: <1279077475-2956-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:41264 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753624Ab0GNDU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 23:20:29 -0400
Received: by pxi14 with SMTP id 14so2544532pxi.19
        for <netdev@vger.kernel.org>; Tue, 13 Jul 2010 20:20:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I want to know if I can assign the sk to skb as nf_tproxy_core does to avoid
the duplicate search later. Thanks.

act_cpu: packet distributing

This TC action can be used to redirect packets to the CPU:
 * specified by the cpuid option
 * specified by the class minor ID obtained previously
 * on which the corresponding application runs

It supports the similar functions of RPS and RFS, but is more flexible.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/linux/netdevice.h     |    2 
 include/linux/tc_act/tc_cpu.h |   31 +++++
 include/net/sock.h            |   24 +++
 include/net/tc_act/tc_cpu.h   |   18 ++
 net/core/dev.c                |    4 
 net/core/sock.c               |    1 
 net/sched/Kconfig             |   12 +
 net/sched/Makefile            |    1 
 net/sched/act_cpu.c           |  260 ++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 350 insertions(+), 3 deletions(-)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c4fedf0..318d422 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1435,6 +1435,8 @@ static inline void input_queue_tail_incr_save(struct softnet_data *sd,
 
 DECLARE_PER_CPU_ALIGNED(struct softnet_data, softnet_data);
 
+int enqueue_to_backlog(struct sk_buff *skb, int cpu, unsigned int *qtail);
+
 #define HAVE_NETIF_QUEUE
 
 extern void __netif_schedule(struct Qdisc *q);
diff --git a/include/linux/tc_act/tc_cpu.h b/include/linux/tc_act/tc_cpu.h
new file mode 100644
index 0000000..2704607
--- /dev/null
+++ b/include/linux/tc_act/tc_cpu.h
@@ -0,0 +1,31 @@
+#ifndef __LINUX_TC_CPU_H
+#define __LINUX_TC_CPU_H
+
+#include <linux/pkt_cls.h>
+#include <linux/types.h>
+
+#define TCA_ACT_CPU 12
+
+enum {
+	TCA_CPU_UNSPEC,
+	TCA_CPU_PARMS,
+	TCA_CPU_TM,
+	__TCA_CPU_MAX
+};
+#define TCA_CPU_MAX (__TCA_CPU_MAX - 1)
+
+enum {
+	TCA_CPU_TYPE_MAP,
+	TCA_CPU_TYPE_CPUID,
+	TCA_CPU_TYPE_SOCKET,
+	__TCA_CPU_TYPE_MAX
+};
+#define TCA_CPU_TYPE_MAX (__TCA_CPU_TYPE_MAX - 1)
+
+struct tc_cpu {
+	tc_gen;
+	__u32		type;
+	__u32		value;
+};
+
+#endif /* __LINUX_TC_CPU_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 3100e71..7913158 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -200,6 +200,7 @@ struct sock_common {
   *	@sk_rcvtimeo: %SO_RCVTIMEO setting
   *	@sk_sndtimeo: %SO_SNDTIMEO setting
   *	@sk_rxhash: flow hash received from netif layer
+  *	@sk_cpu: the CPU on which the corresponding process works.
   *	@sk_filter: socket filtering instructions
   *	@sk_protinfo: private area, net family specific, when not using slab
   *	@sk_timer: sock cleanup timer
@@ -284,6 +285,9 @@ struct sock {
 #ifdef CONFIG_RPS
 	__u32			sk_rxhash;
 #endif
+#if defined(CONFIG_NET_ACT_CPU) || defined(CONFIG_NET_ACT_CPU_MODULE)
+	int			sk_cpu;
+#endif
 	unsigned long 		sk_flags;
 	unsigned long	        sk_lingertime;
 	struct sk_buff_head	sk_error_queue;
@@ -639,7 +643,24 @@ static inline int sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 	return sk->sk_backlog_rcv(sk, skb);
 }
 
-static inline void sock_rps_record_flow(const struct sock *sk)
+static inline void sock_reset_cpu(struct sock *sk)
+{
+#if defined(CONFIG_NET_ACT_CPU) || defined(CONFIG_NET_ACT_CPU_MODULE)
+	sk->sk_cpu = nr_cpumask_bits;
+#endif
+}
+
+static inline void sock_save_cpu(struct sock *sk)
+{
+#if defined(CONFIG_NET_ACT_CPU) || defined(CONFIG_NET_ACT_CPU_MODULE)
+	int cpu = get_cpu();
+	if (sk->sk_cpu != cpu)
+		sk->sk_cpu = cpu;
+	put_cpu();
+#endif
+}
+
+static inline void sock_rps_record_flow(struct sock *sk)
 {
 #ifdef CONFIG_RPS
 	struct rps_sock_flow_table *sock_flow_table;
@@ -649,6 +670,7 @@ static inline void sock_rps_record_flow(const struct sock *sk)
 	rps_record_sock_flow(sock_flow_table, sk->sk_rxhash);
 	rcu_read_unlock();
 #endif
+	sock_save_cpu(sk);
 }
 
 static inline void sock_rps_reset_flow(const struct sock *sk)
diff --git a/include/net/tc_act/tc_cpu.h b/include/net/tc_act/tc_cpu.h
new file mode 100644
index 0000000..0504bf0
--- /dev/null
+++ b/include/net/tc_act/tc_cpu.h
@@ -0,0 +1,18 @@
+#ifndef __NET_TC_CPU_H
+#define __NET_TC_CPU_H
+
+#include <linux/types.h>
+#include <net/act_api.h>
+
+struct tcf_cpu {
+	struct tcf_common	common;
+	u32			type;
+	u32			value;
+};
+
+static inline struct tcf_cpu *to_tcf_cpu(struct tcf_common *pc)
+{
+	return container_of(pc, struct tcf_cpu, common);
+}
+
+#endif /* __NET_TC_CPU_H */
diff --git a/net/core/dev.c b/net/core/dev.c
index e2b9fa2..45e8a21 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2443,8 +2443,7 @@ static int rps_ipi_queued(struct softnet_data *sd)
  * enqueue_to_backlog is called to queue an skb to a per CPU backlog
  * queue (may be a remote CPU queue).
  */
-static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
-			      unsigned int *qtail)
+int enqueue_to_backlog(struct sk_buff *skb, int cpu, unsigned int *qtail)
 {
 	struct softnet_data *sd;
 	unsigned long flags;
@@ -2482,6 +2481,7 @@ enqueue:
 	kfree_skb(skb);
 	return NET_RX_DROP;
 }
+EXPORT_SYMBOL(enqueue_to_backlog);
 
 /**
  *	netif_rx	-	post buffer to the network code
diff --git a/net/core/sock.c b/net/core/sock.c
index 363bc26..7a71e76 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1045,6 +1045,7 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
 		if (!try_module_get(prot->owner))
 			goto out_free_sec;
 		sk_tx_queue_clear(sk);
+		sock_reset_cpu(sk);
 	}
 
 	return sk;
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 2f691fb..a826758 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -427,6 +427,18 @@ config NET_CLS_ACT
 	  A recent version of the iproute2 package is required to use
 	  extended matches.
 
+config NET_ACT_CPU
+        tristate "Packet distributing"
+        depends on NET_CLS_ACT
+        depends on RPS
+        ---help---
+	  Say Y here to do packets distributing. With it, you can distribute
+	  the packets among the CPUs on the system in any way as you like. It
+	  only works in ingress.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called act_cpu.
+
 config NET_ACT_POLICE
 	tristate "Traffic Policing"
         depends on NET_CLS_ACT 
diff --git a/net/sched/Makefile b/net/sched/Makefile
index f14e71b..a9e0b96 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -7,6 +7,7 @@ obj-y	:= sch_generic.o sch_mq.o
 obj-$(CONFIG_NET_SCHED)		+= sch_api.o sch_blackhole.o
 obj-$(CONFIG_NET_CLS)		+= cls_api.o
 obj-$(CONFIG_NET_CLS_ACT)	+= act_api.o
+obj-$(CONFIG_NET_ACT_CPU)	+= act_cpu.o
 obj-$(CONFIG_NET_ACT_POLICE)	+= act_police.o
 obj-$(CONFIG_NET_ACT_GACT)	+= act_gact.o
 obj-$(CONFIG_NET_ACT_MIRRED)	+= act_mirred.o
diff --git a/net/sched/act_cpu.c b/net/sched/act_cpu.c
new file mode 100644
index 0000000..6b7d7fc
--- /dev/null
+++ b/net/sched/act_cpu.c
@@ -0,0 +1,260 @@
+/*
+ * Packet distributing actions
+ *
+ * Copyright (c) 2010- Changli Gao <xiaosuo@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ */
+
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/gfp.h>
+#include <net/net_namespace.h>
+#include <net/netlink.h>
+#include <net/pkt_sched.h>
+#include <net/tcp.h>
+#include <net/udp.h>
+#include <linux/tc_act/tc_cpu.h>
+#include <net/tc_act/tc_cpu.h>
+
+#define CPU_TAB_MASK     15
+static struct tcf_common *tcf_cpu_ht[CPU_TAB_MASK + 1];
+static u32 cpu_idx_gen;
+static DEFINE_RWLOCK(cpu_lock);
+
+static struct tcf_hashinfo cpu_hash_info = {
+	.htab	= tcf_cpu_ht,
+	.hmask	= CPU_TAB_MASK,
+	.lock	= &cpu_lock
+};
+
+static const struct nla_policy cpu_policy[TCA_CPU_MAX + 1] = {
+	[TCA_CPU_PARMS]	= { .len = sizeof(struct tc_cpu) },
+};
+
+static int tcf_cpu_init(struct nlattr *nla, struct nlattr *est,
+			struct tc_action *a, int ovr, int bind)
+{
+	struct nlattr *tb[TCA_CPU_MAX + 1];
+	struct tc_cpu *parm;
+	struct tcf_cpu *p;
+	struct tcf_common *pc;
+	int ret;
+
+	if (nla == NULL)
+		return -EINVAL;
+	ret = nla_parse_nested(tb, TCA_CPU_MAX, nla, cpu_policy);
+	if (ret < 0)
+		return ret;
+	if (tb[TCA_CPU_PARMS] == NULL)
+		return -EINVAL;
+	parm = nla_data(tb[TCA_CPU_PARMS]);
+	if (parm->type > TCA_CPU_TYPE_MAX || parm->action != TC_ACT_STOLEN)
+		return -EINVAL;
+
+	pc = tcf_hash_check(parm->index, a, bind, &cpu_hash_info);
+	if (!pc) {
+		pc = tcf_hash_create(parm->index, est, a, sizeof(*p), bind,
+				     &cpu_idx_gen, &cpu_hash_info);
+		if (IS_ERR(pc))
+			return PTR_ERR(pc);
+		ret = ACT_P_CREATED;
+	} else {
+		if (!ovr) {
+			tcf_hash_release(pc, bind, &cpu_hash_info);
+			return -EEXIST;
+		}
+		ret = 0;
+	}
+	p = to_tcf_cpu(pc);
+
+	spin_lock_bh(&p->tcf_lock);
+	p->type = parm->type;
+	p->value = parm->value;
+	p->tcf_action = parm->action;
+	spin_unlock_bh(&p->tcf_lock);
+
+	if (ret == ACT_P_CREATED)
+		tcf_hash_insert(pc, &cpu_hash_info);
+
+	return ret;
+}
+
+static int tcf_cpu_cleanup(struct tc_action *a, int bind)
+{
+	struct tcf_cpu *p = a->priv;
+
+	return tcf_hash_release(&p->common, bind, &cpu_hash_info);
+}
+
+static int tcf_cpu_from_sock(struct sk_buff *skb)
+{
+	struct iphdr *iph;
+	struct sock *sk;
+	struct {
+		__be16 source, dest;
+	} *ports;
+	int cpu;
+
+	if (skb->dev == NULL || skb->protocol != __constant_htons(ETH_P_IP))
+		goto err;
+	if (!pskb_may_pull(skb, sizeof(*iph)))
+		goto err;
+	iph = (struct iphdr *) skb->data;
+	if (!pskb_may_pull(skb, iph->ihl * 4 + 4))
+		goto err;
+	ports = (void *) (skb->data + iph->ihl * 4);
+	switch (iph->protocol) {
+	case IPPROTO_TCP:
+		sk = __inet_lookup(dev_net(skb->dev), &tcp_hashinfo, iph->saddr,
+				   ports->source, iph->daddr, ports->dest,
+				   skb->dev->ifindex);
+		break;
+	case IPPROTO_UDP:
+		sk = udp4_lib_lookup(dev_net(skb->dev), iph->saddr,
+				     ports->source, iph->daddr, ports->dest,
+				     skb->dev->ifindex);
+		break;
+	default:
+		goto err;
+	}
+
+	if (!sk)
+		goto err;
+	cpu = sk->sk_cpu;
+	if (sk->sk_protocol == IPPROTO_TCP && sk->sk_state == TCP_TIME_WAIT)
+		inet_twsk_put(inet_twsk(sk));
+	else
+		sock_put(sk);
+
+	return cpu;
+
+err:
+	return smp_processor_id();
+}
+
+static int tcf_cpu(struct sk_buff *skb, struct tc_action *a,
+		   struct tcf_result *res)
+{
+	struct tcf_cpu *p = a->priv;
+	u32 type;
+	u32 value;
+	int cpu, action;
+	struct sk_buff *nskb;
+	unsigned int qtail;
+
+	spin_lock(&p->tcf_lock);
+	p->tcf_tm.lastuse = jiffies;
+	p->tcf_bstats.bytes += qdisc_pkt_len(skb);
+	p->tcf_bstats.packets++;
+	type = p->type;
+	value = p->value;
+	action = p->tcf_action;
+	spin_unlock(&p->tcf_lock);
+
+	if (G_TC_AT(skb->tc_verd) & AT_EGRESS) {
+		if (net_ratelimit())
+			pr_notice("act_cpu only works in ingress!\n");
+		goto drop;
+	}
+
+	nskb = skb_act_clone(skb, GFP_ATOMIC, action);
+	if (nskb == NULL)
+		goto drop;
+	nskb->tc_verd = 0;
+	nskb->tc_verd = SET_TC_NCLS(nskb->tc_verd);
+
+	switch (type) {
+	case TCA_CPU_TYPE_MAP:
+		cpu = TC_H_MIN(res->classid) - value;
+		break;
+	case TCA_CPU_TYPE_CPUID:
+		cpu = value;
+		break;
+	case TCA_CPU_TYPE_SOCKET:
+		cpu = tcf_cpu_from_sock(nskb);
+		break;
+	default:
+		kfree_skb(nskb);
+		goto drop;
+	}
+	if (cpu >= nr_cpumask_bits || !cpu_online(cpu))
+		cpu = smp_processor_id();
+
+	if (enqueue_to_backlog(nskb, cpu, &qtail) != NET_RX_SUCCESS)
+		goto drop;
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
+static int tcf_cpu_dump(struct sk_buff *skb, struct tc_action *a, int bind,
+			int ref)
+{
+	unsigned char *b = skb_tail_pointer(skb);
+	struct tcf_cpu *p = a->priv;
+	struct tc_cpu opt;
+	struct tcf_t t;
+
+	opt.index = p->tcf_index;
+	opt.action = p->tcf_action;
+	opt.refcnt = p->tcf_refcnt - ref;
+	opt.bindcnt = p->tcf_bindcnt - bind;
+	opt.type = p->type;
+	opt.value = p->value;
+	NLA_PUT(skb, TCA_CPU_PARMS, sizeof(opt), &opt);
+	t.install = jiffies_to_clock_t(jiffies - p->tcf_tm.install);
+	t.lastuse = jiffies_to_clock_t(jiffies - p->tcf_tm.lastuse);
+	t.expires = jiffies_to_clock_t(p->tcf_tm.expires);
+	NLA_PUT(skb, TCA_CPU_TM, sizeof(t), &t);
+	return skb->len;
+
+nla_put_failure:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+static struct tc_action_ops act_cpu_ops = {
+	.kind		=	"cpu",
+	.hinfo		=	&cpu_hash_info,
+	.type		=	TCA_ACT_CPU,
+	.capab		=	TCA_CAP_NONE,
+	.owner		=	THIS_MODULE,
+	.act		=	tcf_cpu,
+	.dump		=	tcf_cpu_dump,
+	.cleanup	=	tcf_cpu_cleanup,
+	.lookup		=	tcf_hash_search,
+	.init		=	tcf_cpu_init,
+	.walk		=	tcf_generic_walker
+};
+
+MODULE_AUTHOR("Changli Gao <xiaosuo@gmail.com>");
+MODULE_DESCRIPTION("Packet distributing actions");
+MODULE_LICENSE("GPL");
+
+static int __init cpu_init_module(void)
+{
+	return tcf_register_action(&act_cpu_ops);
+}
+
+static void __exit cpu_cleanup_module(void)
+{
+	tcf_unregister_action(&act_cpu_ops);
+}
+
+module_init(cpu_init_module);
+module_exit(cpu_cleanup_module);
