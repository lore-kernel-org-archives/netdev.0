From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [RFC PATCH 2/5] xfrm: add possibility for parallel processing
Date: Mon, 1 Dec 2008 08:17:58 +0100
Message-ID: <20081201071758.GR476@secunet.com>
References: <20081201071614.GP476@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	klassert@mathematik.tu-chemnitz.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:46526 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874AbYLAHsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Dec 2008 02:48:21 -0500
Content-Disposition: inline
In-Reply-To: <20081201071614.GP476@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>

This patch uses the padata parallelization interface to run the expensive
parts of xfrm in parallel.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/crypto.h     |    1 +
 include/linux/interrupt.h  |    2 +
 include/linux/padata.h     |    2 +
 include/linux/skbuff.h     |    5 +
 include/linux/sysctl.h     |    3 +-
 include/net/xfrm.h         |   38 ++++++
 kernel/sysctl_check.c      |    1 +
 net/core/skbuff.c          |    3 +
 net/core/sysctl_net_core.c |   11 ++
 net/xfrm/Kconfig           |    8 ++
 net/xfrm/Makefile          |    2 +-
 net/xfrm/xfrm_input.c      |    7 +-
 net/xfrm/xfrm_output.c     |    5 +
 net/xfrm/xfrm_padata.c     |  270 ++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_policy.c     |    2 +
 15 files changed, 357 insertions(+), 3 deletions(-)
 create mode 100644 net/xfrm/xfrm_padata.c

diff --git a/include/linux/crypto.h b/include/linux/crypto.h
index 3d2317e..d5dd094 100644
--- a/include/linux/crypto.h
+++ b/include/linux/crypto.h
@@ -78,6 +78,7 @@
 #define CRYPTO_TFM_REQ_WEAK_KEY		0x00000100
 #define CRYPTO_TFM_REQ_MAY_SLEEP	0x00000200
 #define CRYPTO_TFM_REQ_MAY_BACKLOG	0x00000400
+#define CRYPTO_TFM_REQ_FORCE_SYNC	0x00000800
 #define CRYPTO_TFM_RES_WEAK_KEY		0x00100000
 #define CRYPTO_TFM_RES_BAD_KEY_LEN   	0x00200000
 #define CRYPTO_TFM_RES_BAD_KEY_SCHED 	0x00400000
diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 4d2f4bb..02b7fba 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -248,6 +248,8 @@ enum
 	TIMER_SOFTIRQ,
 	NET_TX_SOFTIRQ,
 	NET_RX_SOFTIRQ,
+	XFRM_INPUT_SOFTIRQ,
+	XFRM_OUTPUT_SOFTIRQ,
 	BLOCK_SOFTIRQ,
 	TASKLET_SOFTIRQ,
 	SCHED_SOFTIRQ,
diff --git a/include/linux/padata.h b/include/linux/padata.h
index 6447c93..786ec44 100644
--- a/include/linux/padata.h
+++ b/include/linux/padata.h
@@ -28,6 +28,8 @@
 enum
 {
 	NO_PADATA=0,
+	XFRM_INPUT_PADATA,
+	XFRM_OUTPUT_PADATA,
 	NR_PADATA
 };
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2725f4e..a5c9986 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -18,6 +18,7 @@
 #include <linux/compiler.h>
 #include <linux/time.h>
 #include <linux/cache.h>
+#include <linux/padata.h>
 
 #include <asm/atomic.h>
 #include <asm/types.h>
@@ -261,6 +262,10 @@ struct sk_buff {
 	struct sk_buff		*next;
 	struct sk_buff		*prev;
 
+#ifdef CONFIG_XFRM_PADATA
+	struct padata_priv       padata;
+#endif
+
 	struct sock		*sk;
 	ktime_t			tstamp;
 	struct net_device	*dev;
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 39d471d..fd86b44 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -284,7 +284,8 @@ enum
 	NET_CORE_BUDGET=19,
 	NET_CORE_AEVENT_ETIME=20,
 	NET_CORE_AEVENT_RSEQTH=21,
-	NET_CORE_WARNINGS=22,
+	NET_CORE_PADATA=22,
+	NET_CORE_WARNINGS=23,
 };
 
 /* /proc/sys/net/ethernet */
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 11c890a..ee0ae79 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -12,6 +12,7 @@
 #include <linux/in6.h>
 #include <linux/mutex.h>
 #include <linux/audit.h>
+#include <linux/crypto.h>
 
 #include <net/sock.h>
 #include <net/dst.h>
@@ -741,6 +742,43 @@ static inline void xfrm_pols_put(struct xfrm_policy **pols, int npols)
 }
 #endif
 
+#ifdef CONFIG_XFRM_PADATA
+extern u32 xfrm_padata_conf;
+extern int xfrm_do_parallel_input(struct sk_buff *skb);
+extern int xfrm_do_parallel_output(struct sk_buff *skb);
+extern void xfrm_init_padata(void);
+extern int xfrm_padata_strategy(ctl_table *ctl, void __user *oldval,
+		size_t __user *oldlenp, void __user *newval, size_t newlen);
+extern int xfrm_padata_sysctl(struct ctl_table *ctrl, int write,
+				struct file* filp, void __user *buffer,
+				size_t *lenp, loff_t *ppos);
+static inline u32 xfrm_aead_set_flags(struct sk_buff *skb, u32 flags)
+{
+	if (skb->padata.nr == XFRM_OUTPUT_PADATA ||
+			skb->padata.nr == XFRM_INPUT_PADATA)
+
+		flags |= CRYPTO_TFM_REQ_FORCE_SYNC;
+
+	return flags;
+}
+#else
+static inline int xfrm_do_parallel_input(struct sk_buff *skb)
+{
+	return 0;
+}
+static inline int xfrm_do_parallel_output(struct sk_buff *skb)
+{
+	return 0;
+}
+static inline void xfrm_init_padata(void)
+{
+}
+static inline u32 xfrm_aead_set_flags(struct sk_buff *skb, u32 flags)
+{
+	return 0;
+}
+#endif
+
 extern void __xfrm_state_destroy(struct xfrm_state *);
 
 static inline void __xfrm_state_put(struct xfrm_state *x)
diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
index c35da23..011f74e 100644
--- a/kernel/sysctl_check.c
+++ b/kernel/sysctl_check.c
@@ -161,6 +161,7 @@ static const struct trans_ctl_table trans_net_core_table[] = {
 	{ NET_CORE_BUDGET,		"netdev_budget" },
 	{ NET_CORE_AEVENT_ETIME,	"xfrm_aevent_etime" },
 	{ NET_CORE_AEVENT_RSEQTH,	"xfrm_aevent_rseqth" },
+	{ NET_CORE_PADATA,		"xfrm_padata" },
 	{ NET_CORE_WARNINGS,		"warnings" },
 	{},
 };
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d49ef83..6c8c86d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -495,6 +495,9 @@ EXPORT_SYMBOL(skb_recycle_check);
 
 static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 {
+#ifdef CONFIG_XFRM_PADATA
+	memset(&new->padata, 0, sizeof(struct padata_priv));
+#endif
 	new->tstamp		= old->tstamp;
 	new->dev		= old->dev;
 	new->transport_header	= old->transport_header;
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index f686467..7688916 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -122,6 +122,17 @@ static struct ctl_table net_core_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+#ifdef CONFIG_XFRM_PADATA
+	{
+		.ctl_name	= NET_CORE_PADATA,
+		.procname	= "xfrm_padata",
+		.data		= &xfrm_padata_conf,
+		.maxlen		= sizeof(u32),
+		.mode		= 0644,
+		.proc_handler	= &xfrm_padata_sysctl,
+		.strategy       = &xfrm_padata_strategy,
+	},
+#endif /* CONFIG_XFRM_PADATA */
 #endif /* CONFIG_XFRM */
 #endif /* CONFIG_NET */
 	{
diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index 6d08167..ba509e0 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -46,6 +46,14 @@ config XFRM_STATISTICS
 
 	  If unsure, say N.
 
+config XFRM_PADATA
+	bool "Transformation parallel processing (EXPERIMENTAL)"
+	depends on INET && XFRM && USE_GENERIC_SMP_HELPERS && EXPERIMENTAL
+	---help---
+	  Support parallel processing of the expencive parts of IPsec.
+
+	  If unsure, say N.
+
 config XFRM_IPCOMP
 	tristate
 	select XFRM
diff --git a/net/xfrm/Makefile b/net/xfrm/Makefile
index 0f439a7..09f3f35 100644
--- a/net/xfrm/Makefile
+++ b/net/xfrm/Makefile
@@ -7,4 +7,4 @@ obj-$(CONFIG_XFRM) := xfrm_policy.o xfrm_state.o xfrm_hash.o \
 obj-$(CONFIG_XFRM_STATISTICS) += xfrm_proc.o
 obj-$(CONFIG_XFRM_USER) += xfrm_user.o
 obj-$(CONFIG_XFRM_IPCOMP) += xfrm_ipcomp.o
-
+obj-$(CONFIG_XFRM_PADATA) += xfrm_padata.o
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 7527940..28126cd 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -115,7 +115,8 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 	/* A negative encap_type indicates async resumption. */
 	if (encap_type < 0) {
-		async = 1;
+		if (encap_type == -1)
+			async = 1;
 		x = xfrm_input_state(skb);
 		seq = XFRM_SKB_CB(skb)->seq.input;
 		goto resume;
@@ -185,6 +186,10 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		XFRM_SKB_CB(skb)->seq.input = seq;
 
+
+		if (xfrm_do_parallel_input(skb))
+			return 0;
+
 		nexthdr = x->type->input(x, skb);
 
 		if (nexthdr == -EINPROGRESS)
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index dc50f1e..1fb134b 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -83,6 +83,11 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 
 		spin_unlock_bh(&x->lock);
 
+		if (xfrm_do_parallel_output(skb)) {
+			err = -EINPROGRESS;
+			goto out_exit;
+		}
+
 		err = x->type->output(x, skb);
 		if (err == -EINPROGRESS)
 			goto out_exit;
diff --git a/net/xfrm/xfrm_padata.c b/net/xfrm/xfrm_padata.c
new file mode 100644
index 0000000..4cbc95c
--- /dev/null
+++ b/net/xfrm/xfrm_padata.c
@@ -0,0 +1,270 @@
+/*
+ * xfrm_padata.c - IPsec parallelization code
+ *
+ * Copyright (C) 2008 secunet Security Networks AG
+ * Copyright (C) 2008 Steffen Klassert <steffen.klassert@secunet.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ */
+
+#include<linux/padata.h>
+#include <linux/skbuff.h>
+#include <linux/interrupt.h>
+#include <net/xfrm.h>
+#include <linux/cpu.h>
+
+u32 xfrm_padata_conf __read_mostly = 0;
+
+int xfrm_padata_strategy(ctl_table *ctl, void __user *oldval,
+		size_t __user *oldlenp, void __user *newval, size_t newlen)
+{
+	int new;
+
+	if (!newval || !newlen)
+		return 0;
+
+	if (newlen != sizeof(u32))
+		return -EINVAL;
+
+	if (get_user(new, (int __user *)newval))
+		return -EFAULT;
+
+	if (new < 0 || new > 1)
+		return -EINVAL;
+
+	return 1;
+}
+
+int xfrm_padata_sysctl(struct ctl_table *ctl, int write,
+				struct file* filp, void __user *buffer,
+				size_t *lenp, loff_t *ppos)
+{
+	int old_val = xfrm_padata_conf;
+	int ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
+
+	if (write &&  xfrm_padata_conf != old_val) {
+		if (xfrm_padata_conf == 0){
+			padata_stop(XFRM_INPUT_PADATA);
+			padata_stop(XFRM_OUTPUT_PADATA);
+
+		} else {
+			padata_start(XFRM_INPUT_PADATA);
+			padata_start(XFRM_OUTPUT_PADATA);
+		}
+	}
+	return ret;
+}
+
+static void xfrm_input_callback(unsigned long data)
+{
+	struct sk_buff *skb;
+	struct padata_priv *padata = (void *) data;
+
+	skb = container_of(padata, struct sk_buff, padata);
+
+	xfrm_input(skb, skb->padata.info, 0 , -501);
+}
+
+static void xfrm_output_callback(unsigned long data)
+{
+	struct sk_buff *skb;
+	struct padata_priv *padata = (void *) data;
+
+	skb = container_of(padata, struct sk_buff, padata);
+
+	xfrm_output_resume(skb, skb->padata.info);
+}
+
+static void xfrm_input_action(struct softirq_action *h)
+{
+	struct xfrm_state *x;
+	struct list_head *cpu_list, local_list;
+
+	cpu_list = &__get_cpu_var(softirq_work_list[XFRM_INPUT_SOFTIRQ]);
+
+	local_irq_disable();
+	list_replace_init(cpu_list, &local_list);
+	local_irq_enable();
+
+	while (!list_empty(&local_list)) {
+		struct padata_priv *padata;
+		struct sk_buff *skb;
+
+		padata = list_entry(local_list.next, struct padata_priv,
+				csd.list);
+
+		list_del_init(&padata->csd.list);
+		skb = container_of(padata, struct sk_buff, padata);
+
+		x = xfrm_input_state(skb);
+		padata->info = x->type->input(x, skb);
+		if (padata->info == -EINPROGRESS) {
+			padata_dont_wait(XFRM_INPUT_PADATA, padata);
+			continue;
+		}
+		if (padata_do_serial(XFRM_INPUT_PADATA, padata))
+			continue;
+
+		xfrm_input(skb, padata->info, 0 , -1);
+	}
+}
+
+static void xfrm_output_action(struct softirq_action *h)
+{
+	struct list_head *cpu_list, local_list;
+
+	cpu_list = &__get_cpu_var(softirq_work_list[XFRM_OUTPUT_SOFTIRQ]);
+
+	local_irq_disable();
+	list_replace_init(cpu_list, &local_list);
+	local_irq_enable();
+
+	while (!list_empty(&local_list)) {
+		struct padata_priv *padata;
+		struct sk_buff *skb;
+		struct xfrm_state *x;
+
+		padata = list_entry(local_list.next, struct padata_priv,
+				csd.list);
+
+		list_del_init(&padata->csd.list);
+		skb = container_of(padata, struct sk_buff, padata);
+
+		x = skb->dst->xfrm;
+		padata->info = x->type->output(x, skb);
+		if (padata->info == -EINPROGRESS) {
+			padata_dont_wait(XFRM_OUTPUT_PADATA, padata);
+			continue;
+		}
+		if (padata_do_serial(XFRM_OUTPUT_PADATA, padata))
+			continue;
+
+		xfrm_output_resume(skb, padata->info);
+	}
+}
+
+static u32 simple_hashrnd;
+static int simple_hashrnd_initialized = 0;
+
+/* Borrowed from simple_tx_hash() */
+u16 xfrm_state_cpu_hash(struct xfrm_state *x, __be16 protocol, int num_cpus)
+{
+	u32 daddr, spi, proto;
+	u32 hash;
+
+	if (unlikely(!simple_hashrnd_initialized)) {
+		get_random_bytes(&simple_hashrnd, 4);
+		simple_hashrnd_initialized = 1;
+	}
+
+
+	switch (protocol) {
+	case __constant_htons(ETH_P_IP):
+
+		daddr = x->id.daddr.a4;
+		spi = x->id.spi;
+		proto = x->id.proto;
+		break;
+	case __constant_htons(ETH_P_IPV6):
+
+		daddr = x->id.daddr.a6[3];
+		spi = x->id.spi;
+		proto = x->id.proto;
+		break;
+	default:
+		return 0;
+	}
+
+	hash = jhash_3words(daddr, spi, proto, simple_hashrnd);
+
+	return (u16) (((u64) hash * num_cpus) >> 32);
+}
+
+int xfrm_do_parallel_input(struct sk_buff *skb)
+{
+	unsigned int cpu, cpu_index, num_cpus, callback_cpu;
+	struct xfrm_state *x;
+	cpumask_t cpu_map;
+
+	cpu_map = padata_get_cpumap(XFRM_INPUT_PADATA);
+	num_cpus = cpus_weight(cpu_map);
+
+	x = xfrm_input_state(skb);
+	cpu_index = xfrm_state_cpu_hash(x, skb->protocol, num_cpus);
+
+	callback_cpu = first_cpu(cpu_map);
+	for (cpu = 0; cpu < cpu_index; cpu++)
+		callback_cpu = next_cpu(callback_cpu, cpu_map);
+
+	return padata_do_parallel(XFRM_INPUT_SOFTIRQ, XFRM_INPUT_PADATA,
+						&skb->padata, callback_cpu);
+}
+
+int xfrm_do_parallel_output(struct sk_buff *skb)
+{
+	int ret;
+	unsigned int cpu, cpu_index, num_cpus, callback_cpu;
+	struct xfrm_state *x;
+	cpumask_t cpu_map;
+
+	cpu_map = padata_get_cpumap(XFRM_OUTPUT_PADATA);
+	num_cpus = cpus_weight(cpu_map);
+
+	x = skb->dst->xfrm;
+	cpu_index = xfrm_state_cpu_hash(x, skb->protocol, num_cpus);
+
+	callback_cpu = first_cpu(cpu_map);
+	for (cpu = 0; cpu < cpu_index; cpu++)
+		callback_cpu = next_cpu(callback_cpu, cpu_map);
+
+	local_bh_disable();
+	ret = padata_do_parallel(XFRM_OUTPUT_SOFTIRQ, XFRM_OUTPUT_PADATA,
+						&skb->padata, callback_cpu);
+	local_bh_enable();
+
+	return ret;
+}
+
+static int __devinit xfrm_cpu_callback(struct notifier_block *nfb,
+				unsigned long action, void *hcpu)
+{
+	int cpu = (unsigned long)hcpu;
+
+	switch (action) {
+		case CPU_ONLINE:
+		case CPU_ONLINE_FROZEN:
+			padata_add_cpu(XFRM_INPUT_PADATA, cpu);
+			padata_add_cpu(XFRM_OUTPUT_PADATA, cpu);
+			break;
+
+		case CPU_DEAD:
+		case CPU_DEAD_FROZEN:
+			padata_remove_cpu(XFRM_INPUT_PADATA, cpu);
+			padata_remove_cpu(XFRM_OUTPUT_PADATA, cpu);
+			break;
+	}
+
+	return NOTIFY_OK;
+}
+
+void __init xfrm_init_padata(void)
+{
+	open_softirq(XFRM_INPUT_SOFTIRQ, xfrm_input_action);
+	open_softirq(XFRM_OUTPUT_SOFTIRQ, xfrm_output_action);
+
+	padata_init(XFRM_INPUT_PADATA, cpu_online_map, xfrm_input_callback);
+	padata_init(XFRM_OUTPUT_PADATA, cpu_online_map, xfrm_output_callback);
+
+	hotcpu_notifier(xfrm_cpu_callback, 0);
+}
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 058f04f..41d3670 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2433,6 +2433,8 @@ static void __init xfrm_policy_init(void)
 
 void __init xfrm_init(void)
 {
+	xfrm_init_padata();
+
 #ifdef CONFIG_XFRM_STATISTICS
 	xfrm_statistics_init();
 #endif
-- 
1.5.4.2

