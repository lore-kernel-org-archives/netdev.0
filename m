From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/5] netfilter: add netfilter ingress hook after handle_ing() under unique static key
Date: Wed, 13 May 2015 18:19:38 +0200
Message-ID: <1431533978-26901-6-git-send-email-pablo@netfilter.org>
References: <1431533978-26901-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, jhs@mojatatu.com,
	daniel@iogearbox.net, eric.dumazet@gmail.com, kaber@trash.net,
	ast@plumgrid.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34184 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965027AbbEMQPP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 12:15:15 -0400
In-Reply-To: <1431533978-26901-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the Netfilter ingress hook just after the existing tc ingress
hook, that seems to be the consensus solution for this.

Note that the Netfilter hook resides under the global static key that enables
ingress filtering. Nonetheless, Netfilter still also has its own static key for
minimal impact on the existing handle_ing().

* Without this patch:

Result: OK: 6216490(c6216338+d152) usec, 100000000 (60byte,0frags)
  16086246pps 7721Mb/sec (7721398080bps) errors: 100000000

    42.46%  kpktgend_0   [kernel.kallsyms]   [k] __netif_receive_skb_core
    25.92%  kpktgend_0   [kernel.kallsyms]   [k] kfree_skb
     7.81%  kpktgend_0   [pktgen]            [k] pktgen_thread_worker
     5.62%  kpktgend_0   [kernel.kallsyms]   [k] ip_rcv
     2.70%  kpktgend_0   [kernel.kallsyms]   [k] netif_receive_skb_internal
     2.34%  kpktgend_0   [kernel.kallsyms]   [k] netif_receive_skb_sk
     1.44%  kpktgend_0   [kernel.kallsyms]   [k] __build_skb

* With this patch:

Result: OK: 6214833(c6214731+d101) usec, 100000000 (60byte,0frags)
  16090536pps 7723Mb/sec (7723457280bps) errors: 100000000

    41.23%  kpktgend_0      [kernel.kallsyms]  [k] __netif_receive_skb_core
    26.57%  kpktgend_0      [kernel.kallsyms]  [k] kfree_skb
     7.72%  kpktgend_0      [pktgen]           [k] pktgen_thread_worker
     5.55%  kpktgend_0      [kernel.kallsyms]  [k] ip_rcv
     2.78%  kpktgend_0      [kernel.kallsyms]  [k] netif_receive_skb_internal
     2.06%  kpktgend_0      [kernel.kallsyms]  [k] netif_receive_skb_sk
     1.43%  kpktgend_0      [kernel.kallsyms]  [k] __build_skb

* Without this patch + tc ingress:

        tc filter add dev eth4 parent ffff: protocol ip prio 1 \
                u32 match ip dst 4.3.2.1/32

Result: OK: 9269001(c9268821+d179) usec, 100000000 (60byte,0frags)
  10788648pps 5178Mb/sec (5178551040bps) errors: 100000000

    40.99%  kpktgend_0   [kernel.kallsyms]  [k] __netif_receive_skb_core
    17.50%  kpktgend_0   [kernel.kallsyms]  [k] kfree_skb
    11.77%  kpktgend_0   [cls_u32]          [k] u32_classify
     5.62%  kpktgend_0   [kernel.kallsyms]  [k] tc_classify_compat
     5.18%  kpktgend_0   [pktgen]           [k] pktgen_thread_worker
     3.23%  kpktgend_0   [kernel.kallsyms]  [k] tc_classify
     2.97%  kpktgend_0   [kernel.kallsyms]  [k] ip_rcv
     1.83%  kpktgend_0   [kernel.kallsyms]  [k] netif_receive_skb_internal
     1.50%  kpktgend_0   [kernel.kallsyms]  [k] netif_receive_skb_sk
     0.99%  kpktgend_0   [kernel.kallsyms]  [k] __build_skb

* With this patch + tc ingress:

        tc filter add dev eth4 parent ffff: protocol ip prio 1 \
                u32 match ip dst 4.3.2.1/32

Result: OK: 9308218(c9308091+d126) usec, 100000000 (60byte,0frags)
  10743194pps 5156Mb/sec (5156733120bps) errors: 100000000

    42.01%  kpktgend_0   [kernel.kallsyms]   [k] __netif_receive_skb_core
    17.78%  kpktgend_0   [kernel.kallsyms]   [k] kfree_skb
    11.70%  kpktgend_0   [cls_u32]           [k] u32_classify
     5.46%  kpktgend_0   [kernel.kallsyms]   [k] tc_classify_compat
     5.16%  kpktgend_0   [pktgen]            [k] pktgen_thread_worker
     2.98%  kpktgend_0   [kernel.kallsyms]   [k] ip_rcv
     2.84%  kpktgend_0   [kernel.kallsyms]   [k] tc_classify
     1.96%  kpktgend_0   [kernel.kallsyms]   [k] netif_receive_skb_internal
     1.57%  kpktgend_0   [kernel.kallsyms]   [k] netif_receive_skb_sk

Note that the results are very similar before and after.

I can see gcc gets the code under the ingress static key out of the hot path.
Then, on that cold branch, it generates the code to accomodate the netfilter
ingress static key. My explanation for this is that this reduces the pressure
on the instruction cache for non-users as the new code is out of the hot path,
and it comes with minimal impact for tc ingress users.

Using gcc version 4.8.4 on:

Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                8
[...]
L1d cache:             16K
L1i cache:             64K
L2 cache:              2048K
L3 cache:              8192K

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netdevice.h         |    3 +++
 include/linux/netfilter.h         |    1 +
 include/linux/netfilter_ingress.h |   41 +++++++++++++++++++++++++++++++++++++
 include/uapi/linux/netfilter.h    |    6 ++++++
 net/core/dev.c                    |   36 ++++++++++++++++++++++++++++++++
 net/netfilter/Kconfig             |    7 +++++++
 net/netfilter/core.c              |   31 +++++++++++++++++++++++++++-
 7 files changed, 124 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/netfilter_ingress.h

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2b39235..6c256f8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1659,6 +1659,9 @@ struct net_device {
 	struct tcf_proto __rcu  *ingress_cl_list;
 #endif
 	struct netdev_queue __rcu *ingress_queue;
+#ifdef CONFIG_NETFILTER_INGRESS
+	struct list_head	nf_hooks_ingress;
+#endif
 
 	unsigned char		broadcast[MAX_ADDR_LEN];
 #ifdef CONFIG_RFS_ACCEL
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 49d0063..f5ff5d1 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -86,6 +86,7 @@ struct nf_hook_ops {
 
 	/* User fills in from here down. */
 	nf_hookfn		*hook;
+	struct net_device	*dev;
 	struct module		*owner;
 	void			*priv;
 	u_int8_t		pf;
diff --git a/include/linux/netfilter_ingress.h b/include/linux/netfilter_ingress.h
new file mode 100644
index 0000000..4fa4a0f
--- /dev/null
+++ b/include/linux/netfilter_ingress.h
@@ -0,0 +1,41 @@
+#ifndef _NETFILTER_INGRESS_H_
+#define _NETFILTER_INGRESS_H_
+
+#include <linux/netfilter.h>
+#include <linux/netdevice.h>
+
+#ifdef CONFIG_NETFILTER_INGRESS
+static inline int nf_hook_ingress_active(struct sk_buff *skb)
+{
+	return nf_hook_list_active(&skb->dev->nf_hooks_ingress,
+				   NFPROTO_NETDEV, NF_NETDEV_INGRESS);
+}
+
+static inline int nf_hook_ingress(struct sk_buff *skb)
+{
+	struct nf_hook_state state;
+
+	nf_hook_state_init(&state, &skb->dev->nf_hooks_ingress,
+			   NF_NETDEV_INGRESS, INT_MIN, NFPROTO_NETDEV, NULL,
+			   skb->dev, NULL, NULL);
+	return nf_hook_slow(skb, &state);
+}
+
+static inline void nf_hook_ingress_init(struct net_device *dev)
+{
+        INIT_LIST_HEAD(&dev->nf_hooks_ingress);
+}
+#else /* CONFIG_NETFILTER_INGRESS */
+static inline int nf_hook_ingress_active(struct sk_buff *skb)
+{
+	return 0;
+}
+
+static inline int nf_hook_ingress(struct sk_buff *skb)
+{
+	return 0;
+}
+
+static inline void nf_hook_ingress_init(struct net_device *dev) {}
+#endif /* CONFIG_NETFILTER_INGRESS */
+#endif /* _NETFILTER_INGRESS_H_ */
diff --git a/include/uapi/linux/netfilter.h b/include/uapi/linux/netfilter.h
index ef1b1f8..177027c 100644
--- a/include/uapi/linux/netfilter.h
+++ b/include/uapi/linux/netfilter.h
@@ -51,11 +51,17 @@ enum nf_inet_hooks {
 	NF_INET_NUMHOOKS
 };
 
+enum nf_dev_hooks {
+	NF_NETDEV_INGRESS,
+	NF_NETDEV_NUMHOOKS
+};
+
 enum {
 	NFPROTO_UNSPEC =  0,
 	NFPROTO_INET   =  1,
 	NFPROTO_IPV4   =  2,
 	NFPROTO_ARP    =  3,
+	NFPROTO_NETDEV =  5,
 	NFPROTO_BRIDGE =  7,
 	NFPROTO_IPV6   = 10,
 	NFPROTO_DECNET = 12,
diff --git a/net/core/dev.c b/net/core/dev.c
index 5b3dc5c..15e51a9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -135,6 +135,7 @@
 #include <linux/if_macvlan.h>
 #include <linux/errqueue.h>
 #include <linux/hrtimer.h>
+#include <linux/netfilter_ingress.h>
 
 #include "net-sysfs.h"
 
@@ -3560,6 +3561,13 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 
 	return skb;
 }
+#else
+static inline struct sk_buff *handle_ing(struct sk_buff *skb,
+					 struct packet_type **pt_prev,
+					 int *ret, struct net_device *orig_dev)
+{
+	return skb;
+}
 #endif
 
 /**
@@ -3633,6 +3641,28 @@ static bool skb_pfmemalloc_protocol(struct sk_buff *skb)
 	}
 }
 
+#ifdef CONFIG_NETFILTER_INGRESS
+static inline int nf_ingress(struct sk_buff *skb, struct packet_type **pt_prev,
+			     int *ret, struct net_device *orig_dev)
+{
+	if (nf_hook_ingress_active(skb)) {
+		if (*pt_prev) {
+			*ret = deliver_skb(skb, *pt_prev, orig_dev);
+			*pt_prev = NULL;
+		}
+
+		return nf_hook_ingress(skb);
+	}
+	return 0;
+}
+#else
+static inline int nf_ingress(struct sk_buff *skb, struct packet_type **pt_prev,
+			     int *ret, struct net_device *orig_dev)
+{
+	return 0;
+}
+#endif
+
 static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 {
 	struct packet_type *ptype, *pt_prev;
@@ -3697,6 +3727,9 @@ skip_taps:
 		skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
 		if (!skb)
 			goto unlock;
+
+		if (nf_ingress(skb, &pt_prev, &ret, orig_dev) < 0)
+			goto unlock;
 	}
 #endif
 #ifdef CONFIG_NET_CLS_ACT
@@ -6851,6 +6884,9 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	dev->group = INIT_NETDEV_GROUP;
 	if (!dev->ethtool_ops)
 		dev->ethtool_ops = &default_ethtool_ops;
+
+	nf_hook_ingress_init(dev);
+
 	return dev;
 
 free_all:
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index f70e34a..db1c674 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -1,6 +1,13 @@
 menu "Core Netfilter Configuration"
 	depends on NET && INET && NETFILTER
 
+config NETFILTER_INGRESS
+	bool "Netfilter ingress support"
+	select NET_INGRESS
+	help
+	  This allows you to classify packets from ingress using the Netfilter
+	  infrastructure.
+
 config NETFILTER_NETLINK
 	tristate
 
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index e418cfd..653e32e 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -64,10 +64,27 @@ static DEFINE_MUTEX(nf_hook_mutex);
 
 int nf_register_hook(struct nf_hook_ops *reg)
 {
+	struct list_head *nf_hook_list;
 	struct nf_hook_ops *elem;
 
 	mutex_lock(&nf_hook_mutex);
-	list_for_each_entry(elem, &nf_hooks[reg->pf][reg->hooknum], list) {
+	switch (reg->pf) {
+	case NFPROTO_NETDEV:
+#ifdef CONFIG_NETFILTER_INGRESS
+		if (reg->hooknum == NF_NETDEV_INGRESS) {
+			BUG_ON(reg->dev == NULL);
+			nf_hook_list = &reg->dev->nf_hooks_ingress;
+			net_inc_ingress_queue();
+			break;
+		}
+#endif
+		/* Fall through. */
+	default:
+		nf_hook_list = &nf_hooks[reg->pf][reg->hooknum];
+		break;
+	}
+
+	list_for_each_entry(elem, nf_hook_list, list) {
 		if (reg->priority < elem->priority)
 			break;
 	}
@@ -85,6 +102,18 @@ void nf_unregister_hook(struct nf_hook_ops *reg)
 	mutex_lock(&nf_hook_mutex);
 	list_del_rcu(&reg->list);
 	mutex_unlock(&nf_hook_mutex);
+	switch (reg->pf) {
+	case NFPROTO_NETDEV:
+#ifdef CONFIG_NETFILTER_INGRESS
+		if (reg->hooknum == NF_NETDEV_INGRESS) {
+			net_dec_ingress_queue();
+			break;
+		}
+		break;
+#endif
+	default:
+		break;
+	}
 #ifdef HAVE_JUMP_LABEL
 	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
 #endif
-- 
1.7.10.4
