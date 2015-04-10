From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/7] net: add netfilter ingress hook
Date: Fri, 10 Apr 2015 14:15:40 +0200
Message-ID: <1428668142-4006-6-git-send-email-pablo@netfilter.org>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
Cc: kaber@trash.net, netdev@vger.kernel.org, davem@davemloft.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
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

To keep the context around, the skb->cb area is used to save and restore the
relevant information since we're in full control of this area as it happens in
handle_ing().

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netdevice.h         |    4 +-
 include/linux/netfilter.h         |    1 +
 include/linux/netfilter_ingress.h |   80 +++++++++++++++++++++++++++++++++++++
 include/uapi/linux/netfilter.h    |    6 +++
 net/core/dev.c                    |   34 ++++++++++++++++
 net/netfilter/core.c              |   22 +++++++++-
 6 files changed, 145 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/netfilter_ingress.h

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index bf6d9df..26f7c65 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1645,7 +1645,9 @@ struct net_device {
 
 	struct netdev_queue __rcu *ingress_queue;
 	unsigned char		broadcast[MAX_ADDR_LEN];
-
+#ifdef CONFIG_NETFILTER
+	struct list_head	nf_hooks_ingress;
+#endif
 
 /*
  * Cache lines mostly used on transmit path
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 49d0063..1138cea 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -90,6 +90,7 @@ struct nf_hook_ops {
 	void			*priv;
 	u_int8_t		pf;
 	unsigned int		hooknum;
+	struct net_device	*dev;
 	/* Hooks are ordered in ascending priority. */
 	int			priority;
 };
diff --git a/include/linux/netfilter_ingress.h b/include/linux/netfilter_ingress.h
new file mode 100644
index 0000000..95c4537
--- /dev/null
+++ b/include/linux/netfilter_ingress.h
@@ -0,0 +1,80 @@
+#ifndef _NETFILTER_INGRESS_H_
+#define _NETFILTER_INGRESS_H_
+
+#include <linux/netfilter.h>
+#include <linux/netdevice.h>
+
+#ifdef CONFIG_NETFILTER
+struct nf_ingress_skb_cb {
+	struct packet_type	*pt_prev;
+	struct net_device	*orig_dev;
+	bool			pfmemalloc;
+};
+
+static inline struct nf_ingress_skb_cb *nf_ingress_skb_cb(struct sk_buff *skb)
+{
+	return (struct nf_ingress_skb_cb *)skb->cb;
+}
+
+static inline void nf_ingress_ctx_save(struct sk_buff *skb,
+				       struct packet_type *pt_prev,
+				       struct net_device *orig_dev,
+				       bool pfmemalloc)
+{
+	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct nf_ingress_skb_cb));
+
+	nf_ingress_skb_cb(skb)->orig_dev = orig_dev;
+	nf_ingress_skb_cb(skb)->pt_prev = pt_prev;
+	nf_ingress_skb_cb(skb)->pfmemalloc = pfmemalloc;
+}
+
+static inline void nf_ingress_ctx_restore(struct sk_buff *skb,
+					  struct packet_type **pt_prev,
+					  struct net_device **orig_dev,
+					  bool *pfmemalloc)
+{
+	*orig_dev = nf_ingress_skb_cb(skb)->orig_dev;
+	*pt_prev = nf_ingress_skb_cb(skb)->pt_prev;
+	*pfmemalloc = nf_ingress_skb_cb(skb)->pfmemalloc;
+}
+
+static inline int nf_hook_ingress_active(struct sk_buff *skb)
+{
+	return nf_hook_list_active(&skb->dev->nf_hooks_ingress,
+				   NFPROTO_NETDEV, NF_NETDEV_INGRESS);
+}
+
+static inline int
+__nf_hook_ingress(struct sk_buff *skb,
+		  int (*okfn)(struct sock *sk, struct sk_buff *skb))
+{
+	struct nf_hook_state state;
+	int ret;
+
+	nf_hook_state_init(&state, &skb->dev->nf_hooks_ingress,
+			   NF_NETDEV_INGRESS, INT_MIN, NFPROTO_NETDEV, NULL,
+			   skb->dev, NULL, okfn);
+
+	ret = nf_hook_slow(skb, &state);
+	if (ret < 0)
+		return NET_RX_DROP;
+	else if (ret == 1)
+		ret = okfn(NULL, skb);
+
+	return ret;
+}
+#else
+static inline int nf_hook_ingress_active(struct sk_buff *skb)
+{
+	return 0;
+}
+
+static inline int nf_hook_ingress(struct sk_buff *skb,
+				  struct packet_type *pt_prev,
+				  struct net_device *orig_dev,
+				  bool pfmemalloc)
+{
+	BUG("nf_hook_ingress() called with CONFIG_NETFILTER disabled\n");
+}
+#endif /* CONFIG_NETFILTER */
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
index 0e19e4f..9ba8f27 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -135,6 +135,7 @@
 #include <linux/if_macvlan.h>
 #include <linux/errqueue.h>
 #include <linux/hrtimer.h>
+#include <linux/netfilter_ingress.h>
 
 #include "net-sysfs.h"
 
@@ -3727,6 +3728,33 @@ drop:
 	return ret;
 }
 
+#ifdef CONFIG_NETFILTER
+static int nf_hook_ingress_finish(struct sock *sk, struct sk_buff *skb)
+{
+	struct net_device *orig_dev;
+	struct packet_type *pt_prev;
+	bool pfmemalloc;
+
+	nf_ingress_ctx_restore(skb, &pt_prev, &orig_dev, &pfmemalloc);
+
+	return __netif_receive_skb_finish(skb, pfmemalloc, pt_prev, orig_dev);
+}
+
+static int nf_hook_ingress(struct sk_buff *skb, struct packet_type *pt_prev,
+			   struct net_device *orig_dev, bool pfmemalloc)
+{
+	int ret;
+
+	if (pt_prev) {
+		ret = deliver_skb(skb, pt_prev, orig_dev);
+		pt_prev = NULL;
+	}
+	nf_ingress_ctx_save(skb, pt_prev, orig_dev, pfmemalloc);
+
+	return __nf_hook_ingress(skb, nf_hook_ingress_finish);
+}
+#endif
+
 static int __netif_receive_skb_ingress(struct sk_buff *skb, bool pfmemalloc,
 				       struct net_device *orig_dev)
 {
@@ -3772,6 +3800,8 @@ skip_taps:
 	if (!skb)
 		return NET_RX_DROP;
 #endif
+	if (nf_hook_ingress_active(skb))
+		return nf_hook_ingress(skb, pt_prev, orig_dev, pfmemalloc);
 
 	return __netif_receive_skb_finish(skb, pfmemalloc, pt_prev, orig_dev);
 }
@@ -6862,6 +6892,10 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	if (netif_alloc_netdev_queues(dev))
 		goto free_all;
 
+#ifdef CONFIG_NETFILTER
+	INIT_LIST_HEAD(&dev->nf_hooks_ingress);
+#endif
+
 #ifdef CONFIG_SYSFS
 	dev->num_rx_queues = rxqs;
 	dev->real_num_rx_queues = rxqs;
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index e418cfd..aa817d5 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -64,10 +64,23 @@ static DEFINE_MUTEX(nf_hook_mutex);
 
 int nf_register_hook(struct nf_hook_ops *reg)
 {
+	struct list_head *nf_hook_list;
 	struct nf_hook_ops *elem;
 
 	mutex_lock(&nf_hook_mutex);
-	list_for_each_entry(elem, &nf_hooks[reg->pf][reg->hooknum], list) {
+	switch (reg->pf) {
+	case NFPROTO_NETDEV:
+		if (reg->hooknum == NF_NETDEV_INGRESS) {
+			BUG_ON(reg->dev == NULL);
+			nf_hook_list = &reg->dev->nf_hooks_ingress;
+			break;
+		}
+		/* Fall through. */
+	default:
+		nf_hook_list = &nf_hooks[reg->pf][reg->hooknum];
+		break;
+	}
+	list_for_each_entry(elem, nf_hook_list, list) {
 		if (reg->priority < elem->priority)
 			break;
 	}
@@ -84,6 +97,13 @@ void nf_unregister_hook(struct nf_hook_ops *reg)
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

