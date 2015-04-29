From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/6] net: add netfilter ingress hook
Date: Wed, 29 Apr 2015 20:53:08 +0200
Message-ID: <1430333589-4940-6-git-send-email-pablo@netfilter.org>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, jhs@mojatatu.com
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1430333589-4940-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a new NFPROTO_NETDEV family that allows you to register hooks
from the ingress path.

This patch adds a hook list per device, so this introduces a new net_device
structure pointer to nf_hook_ops that needs to be set before hook registration.
The caller is responsible for holding/putting the reference on the net_device
that is attached to nf_hook_ops.

As in other netfilter hooks, we have a static key to enable the netfilter path
if we at least have one registered hook. So the code follows the usual path for
people that don't need this.

The follow up patch moves qdisc ingress on top of netfilter ingress to cancel
the extra overhead in the critical input path.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netdevice.h         |    4 ++++
 include/linux/netfilter_hooks.h   |    1 +
 include/linux/netfilter_ingress.h |   44 +++++++++++++++++++++++++++++++++++++
 include/uapi/linux/netfilter.h    |    6 +++++
 net/Kconfig                       |    7 ++++++
 net/core/dev.c                    |   26 +++++++++++++++++++++-
 net/core/hooks.c                  |   25 ++++++++++++++++++++-
 7 files changed, 111 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/netfilter_ingress.h

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index dbad4d7..a644af5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1654,6 +1654,10 @@ struct net_device {
 	void __rcu		*rx_handler_data;
 
 	struct netdev_queue __rcu *ingress_queue;
+#ifdef CONFIG_NETFILTER_INGRESS
+	struct list_head	nf_hooks_ingress;
+#endif
+
 	unsigned char		broadcast[MAX_ADDR_LEN];
 #ifdef CONFIG_RFS_ACCEL
 	struct cpu_rmap		*rx_cpu_rmap;
diff --git a/include/linux/netfilter_hooks.h b/include/linux/netfilter_hooks.h
index d7a65e6..10683b9 100644
--- a/include/linux/netfilter_hooks.h
+++ b/include/linux/netfilter_hooks.h
@@ -54,6 +54,7 @@ struct nf_hook_ops {
 
 	/* User fills in from here down. */
 	nf_hookfn		*hook;
+	struct net_device	*dev;
 	struct module		*owner;
 	void			*priv;
 	u_int8_t		pf;
diff --git a/include/linux/netfilter_ingress.h b/include/linux/netfilter_ingress.h
new file mode 100644
index 0000000..1620dae3
--- /dev/null
+++ b/include/linux/netfilter_ingress.h
@@ -0,0 +1,44 @@
+#ifndef _NETFILTER_INGRESS_H_
+#define _NETFILTER_INGRESS_H_
+
+#include <linux/netfilter.h>
+#include <linux/netdevice.h>
+#include <linux/netfilter_hooks.h>
+
+#ifdef CONFIG_NETFILTER_INGRESS
+static inline int nf_hook_ingress_active(struct sk_buff *skb)
+{
+	return nf_hook_list_active(&skb->dev->nf_hooks_ingress,
+				   NFPROTO_NETDEV, NF_NETDEV_INGRESS);
+}
+
+static inline int nf_hook_do_ingress(struct sk_buff *skb)
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
+static inline int nf_hook_ingress(struct sk_buff *skb,
+				  struct packet_type **pt_prev,
+				  struct net_device *orig_dev)
+{
+	BUG("nf_hook_ingress() called with CONFIG_NETFILTER_INGRESS disabled\n");
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
diff --git a/net/Kconfig b/net/Kconfig
index 710d393..4a98cb5 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -109,6 +109,13 @@ config NETFILTER_HOOKS
 	  If this option is enabled, the kernel will include support
 	  for the generic Netfilter hook infrastructure.
 
+config NETFILTER_INGRESS
+	bool "Netfilter ingress support"
+	select NETFILTER_HOOKS
+	help
+	  This allows you to classify packets from ingress using the Netfilter
+	  infrastructure.
+
 menuconfig NETFILTER
 	select NETFILTER_HOOKS
 	bool "Network packet filtering framework (Netfilter)"
diff --git a/net/core/dev.c b/net/core/dev.c
index 3d63b85..fa8a262 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -135,7 +135,7 @@
 #include <linux/if_macvlan.h>
 #include <linux/errqueue.h>
 #include <linux/hrtimer.h>
-#include <linux/netfilter_hooks.h>
+#include <linux/netfilter_ingress.h>
 
 #include "net-sysfs.h"
 
@@ -3653,6 +3653,20 @@ static bool skb_pfmemalloc_protocol(struct sk_buff *skb)
 	}
 }
 
+#ifdef CONFIG_NETFILTER_INGRESS
+static inline int nf_hook_ingress(struct sk_buff *skb,
+				  struct packet_type **pt_prev,
+				  int *ret, struct net_device *orig_dev)
+{
+	if (*pt_prev) {
+		*ret = deliver_skb(skb, *pt_prev, orig_dev);
+		*pt_prev = NULL;
+	}
+
+	return nf_hook_do_ingress(skb);
+}
+#endif
+
 static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 {
 	struct packet_type *ptype, *pt_prev;
@@ -3722,6 +3736,14 @@ skip_taps:
 	skb->tc_verd = 0;
 ncls:
 #endif
+	if (nf_hook_ingress_active(skb)) {
+		ret = nf_hook_ingress(skb, &pt_prev, &ret, orig_dev);
+		if (ret < 0) {
+			ret = NET_RX_DROP;
+			goto unlock;
+		}
+	}
+
 	if (pfmemalloc && !skb_pfmemalloc_protocol(skb))
 		goto drop;
 
@@ -6870,6 +6892,8 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	dev->group = INIT_NETDEV_GROUP;
 	if (!dev->ethtool_ops)
 		dev->ethtool_ops = &default_ethtool_ops;
+
+	nf_hook_ingress_init(dev);
 	return dev;
 
 free_all:
diff --git a/net/core/hooks.c b/net/core/hooks.c
index aa9c56c..e30ace0 100644
--- a/net/core/hooks.c
+++ b/net/core/hooks.c
@@ -19,10 +19,26 @@ static DEFINE_MUTEX(nf_hook_mutex);
 
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
@@ -39,6 +55,13 @@ void nf_unregister_hook(struct nf_hook_ops *reg)
 {
 	mutex_lock(&nf_hook_mutex);
 	list_del_rcu(&reg->list);
+	switch (reg->pf) {
+	case NFPROTO_NETDEV:
+		WARN_ON(reg->dev == NULL);
+		break;
+	default:
+		break;
+	}
 	mutex_unlock(&nf_hook_mutex);
 #ifdef HAVE_JUMP_LABEL
 	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
-- 
1.7.10.4

