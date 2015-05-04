From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/4] net: add netfilter ingress hook
Date: Mon,  4 May 2015 12:50:49 +0200
Message-ID: <1430736649-3546-5-git-send-email-pablo@netfilter.org>
References: <1430736649-3546-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net,
	jhs@mojatatu.com
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58276 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753169AbbEDKqa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 06:46:30 -0400
In-Reply-To: <1430736649-3546-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new NFPROTO_NETDEV family that allows you to register
per-device hooks from the ingress path. This is built upon the minimalistic
ingress hook infrastructure.

The caller is responsible for holding/putting the reference on the net_device
that is attached to nf_hook_ops.
---
 include/linux/netdevice.h         |    3 +++
 include/linux/netfilter.h         |    1 +
 include/linux/netfilter_ingress.h |   26 +++++++++++++++++++++++
 include/uapi/linux/netfilter.h    |    6 ++++++
 net/Kconfig                       |    6 ++++++
 net/core/dev.c                    |    3 +++
 net/netfilter/Makefile            |    1 +
 net/netfilter/core.c              |   23 ++++++++++++++++++++-
 net/netfilter/ingress.c           |   41 +++++++++++++++++++++++++++++++++++++
 9 files changed, 109 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/netfilter_ingress.h
 create mode 100644 net/netfilter/ingress.c

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 18e1500..8333feb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1668,6 +1668,9 @@ struct net_device {
 	ingress_hook_func_t __rcu *ingress_hook;
 #endif
 	struct netdev_queue __rcu *ingress_queue;
+#ifdef CONFIG_NETFILTER_INGRESS
+	struct list_head 	nf_hooks_ingress;
+#endif
 
 	unsigned char		broadcast[MAX_ADDR_LEN];
 #ifdef CONFIG_RFS_ACCEL
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 388ed19..f91715a 100644
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
index 0000000..5d94872
--- /dev/null
+++ b/include/linux/netfilter_ingress.h
@@ -0,0 +1,26 @@
+#ifndef _NETFILTER_INGRESS_H_
+#define _NETFILTER_INGRESS_H_
+
+#include <linux/netdevice.h>
+
+#ifdef CONFIG_NETFILTER_INGRESS
+struct list_head *nf_register_ingress_hook(struct nf_hook_ops *reg);
+void nf_unregister_ingress_hook(struct nf_hook_ops *reg);
+
+static inline void nf_hook_ingress_init(struct net_device *dev)
+{
+	INIT_LIST_HEAD(&dev->nf_hooks_ingress);
+}
+#else
+static inline struct list_head *
+nf_register_ingress_hook(struct nf_hook_ops *reg)
+{
+	return &nf_hooks[reg->pf][reg->hooknum];
+}
+
+static inline void nf_unregister_ingress_hook(struct nf_hook_ops *reg) {}
+
+static inline void nf_hook_ingress_init(struct net_device *dev) {}
+#endif
+
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
index f0e2f3f..78d58c9 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -191,6 +191,12 @@ config BRIDGE_NETFILTER
 
 	  If unsure, say N.
 
+config NETFILTER_INGRESS
+	bool "Netfilter ingress hooks"
+	select NET_INGRESS_HOOK
+	help
+	  You can say Y here if you want to enable Netfilter ingress hook.
+
 source "net/netfilter/Kconfig"
 source "net/ipv4/netfilter/Kconfig"
 source "net/ipv6/netfilter/Kconfig"
diff --git a/net/core/dev.c b/net/core/dev.c
index 126d0b1..99d8728 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -135,6 +135,7 @@
 #include <linux/if_macvlan.h>
 #include <linux/errqueue.h>
 #include <linux/hrtimer.h>
+#include <linux/netfilter_ingress.h>
 
 #include "net-sysfs.h"
 
@@ -6841,6 +6842,8 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 #ifdef CONFIG_NET_INGRESS_HOOK
 	RCU_INIT_POINTER(dev->ingress_hook, NULL);
 #endif
+	nf_hook_ingress_init(dev);
+
 #ifdef CONFIG_SYSFS
 	dev->num_rx_queues = rxqs;
 	dev->real_num_rx_queues = rxqs;
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index a87d8b8..f6923e2 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -1,4 +1,5 @@
 netfilter-objs := core.o nf_log.o nf_queue.o nf_sockopt.o
+netfilter-$(CONFIG_NETFILTER_INGRESS) += ingress.o
 
 nf_conntrack-y	:= nf_conntrack_core.o nf_conntrack_standalone.o nf_conntrack_expect.o nf_conntrack_helper.o nf_conntrack_proto.o nf_conntrack_l3proto_generic.o nf_conntrack_proto_generic.o nf_conntrack_proto_tcp.o nf_conntrack_proto_udp.o nf_conntrack_extend.o nf_conntrack_acct.o nf_conntrack_seqadj.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_TIMEOUT) += nf_conntrack_timeout.o
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index e418cfd..370ea06 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -22,6 +22,7 @@
 #include <linux/proc_fs.h>
 #include <linux/mutex.h>
 #include <linux/slab.h>
+#include <linux/netfilter_ingress.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
 
@@ -64,10 +65,23 @@ static DEFINE_MUTEX(nf_hook_mutex);
 
 int nf_register_hook(struct nf_hook_ops *reg)
 {
+	struct list_head *nf_hook_list;
 	struct nf_hook_ops *elem;
 
 	mutex_lock(&nf_hook_mutex);
-	list_for_each_entry(elem, &nf_hooks[reg->pf][reg->hooknum], list) {
+	switch (reg->pf) {
+	case NFPROTO_NETDEV:
+		nf_hook_list = nf_register_ingress_hook(reg);
+		if (IS_ERR(nf_hook_list)) {
+			mutex_unlock(&nf_hook_mutex);
+			return PTR_ERR(nf_hook_list);
+		}
+		break;
+	default:
+		nf_hook_list = &nf_hooks[reg->pf][reg->hooknum];
+		break;
+	}
+	list_for_each_entry(elem, nf_hook_list, list) {
 		if (reg->priority < elem->priority)
 			break;
 	}
@@ -84,6 +98,13 @@ void nf_unregister_hook(struct nf_hook_ops *reg)
 {
 	mutex_lock(&nf_hook_mutex);
 	list_del_rcu(&reg->list);
+	switch (reg->pf) {
+	case NFPROTO_NETDEV:
+		nf_unregister_ingress_hook(reg);
+		break;
+	default:
+		break;
+	}
 	mutex_unlock(&nf_hook_mutex);
 #ifdef HAVE_JUMP_LABEL
 	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
diff --git a/net/netfilter/ingress.c b/net/netfilter/ingress.c
new file mode 100644
index 0000000..82bcfd1
--- /dev/null
+++ b/net/netfilter/ingress.c
@@ -0,0 +1,41 @@
+#include <linux/skbuff.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ingress.h>
+
+static struct sk_buff *nf_hook_ingress(struct sk_buff *skb)
+{
+	struct nf_hook_state state;
+
+	nf_hook_state_init(&state, &skb->dev->nf_hooks_ingress,
+			   NF_NETDEV_INGRESS, INT_MIN, NFPROTO_NETDEV, NULL,
+			   skb->dev, NULL, NULL);
+	if (nf_hook_slow(skb, &state) < 0)
+		return NULL;
+
+	return skb;
+}
+
+struct list_head *nf_register_ingress_hook(struct nf_hook_ops *reg)
+{
+	int ret;
+
+	BUG_ON(reg->dev == NULL);
+
+	if (reg->hooknum == NF_NETDEV_INGRESS &&
+	    list_empty(&reg->dev->nf_hooks_ingress)) {
+		ret = dev_ingress_hook_register(reg->dev, nf_hook_ingress);
+		if (ret < 0)
+			return ERR_PTR(ret);
+	}
+
+	return &reg->dev->nf_hooks_ingress;
+}
+
+void nf_unregister_ingress_hook(struct nf_hook_ops *reg)
+{
+	WARN_ON(reg->dev == NULL);
+
+	if (reg->hooknum == NF_NETDEV_INGRESS &&
+	    list_empty(&reg->dev->nf_hooks_ingress))
+		dev_ingress_hook_unregister(reg->dev);
+}
-- 
1.7.10.4
