From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC net-next 02/22] lwtunnel: infrastructure for handling light weight tunnels like mpls
Date: Fri, 10 Jul 2015 16:19:04 +0200
Message-ID: <d4fef1a0bb6e21984ecb28db1befa4c05f1d8631.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40467 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932665AbbGJOTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 10:19:35 -0400
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Provides infrastructure to parse/dump/store encap information for
light weight tunnels like mpls. Encap information for such tunnels
is associated with fib routes.

This infrastructure is based on previous suggestions from
Eric Biederman to follow the xfrm infrastructure.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/linux/lwtunnel.h      |   6 ++
 include/net/lwtunnel.h        | 132 ++++++++++++++++++++++++++++++++
 include/uapi/linux/lwtunnel.h |  15 ++++
 net/Kconfig                   |   7 ++
 net/core/Makefile             |   1 +
 net/core/lwtunnel.c           | 172 ++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 333 insertions(+)
 create mode 100644 include/linux/lwtunnel.h
 create mode 100644 include/net/lwtunnel.h
 create mode 100644 include/uapi/linux/lwtunnel.h
 create mode 100644 net/core/lwtunnel.c

diff --git a/include/linux/lwtunnel.h b/include/linux/lwtunnel.h
new file mode 100644
index 0000000..97f32f8
--- /dev/null
+++ b/include/linux/lwtunnel.h
@@ -0,0 +1,6 @@
+#ifndef _LINUX_LWTUNNEL_H_
+#define _LINUX_LWTUNNEL_H_
+
+#include <uapi/linux/lwtunnel.h>
+
+#endif /* _LINUX_LWTUNNEL_H_ */
diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
new file mode 100644
index 0000000..df24b36
--- /dev/null
+++ b/include/net/lwtunnel.h
@@ -0,0 +1,132 @@
+#ifndef __NET_LWTUNNEL_H
+#define __NET_LWTUNNEL_H 1
+
+#include <linux/lwtunnel.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/types.h>
+#include <net/route.h>
+
+#define LWTUNNEL_HASH_BITS   7
+#define LWTUNNEL_HASH_SIZE   (1 << LWTUNNEL_HASH_BITS)
+
+/* lw tunnel state flags */
+#define LWTUNNEL_STATE_OUTPUT_REDIRECT 0x1
+
+struct lwtunnel_state {
+	__u16		type;
+	__u16		flags;
+	atomic_t	refcnt;
+	int             len;
+	__u8            data[0];
+};
+
+struct lwtunnel_encap_ops {
+	int (*build_state)(struct net_device *dev, struct nlattr *encap,
+			   struct lwtunnel_state **ts);
+	int (*output)(struct sock *sk, struct sk_buff *skb);
+	int (*fill_encap)(struct sk_buff *skb,
+			  struct lwtunnel_state *lwtstate);
+	int (*get_encap_size)(struct lwtunnel_state *lwtstate);
+	int (*cmp_encap)(struct lwtunnel_state *a, struct lwtunnel_state *b);
+};
+
+extern const struct lwtunnel_encap_ops __rcu *
+		lwtun_encaps[LWTUNNEL_ENCAP_MAX+1];
+
+#ifdef CONFIG_LWTUNNEL
+static inline void lwtunnel_state_get(struct lwtunnel_state *lws)
+{
+	atomic_inc(&lws->refcnt);
+}
+
+static inline void lwtunnel_state_put(struct lwtunnel_state *lws)
+{
+	if (!lws)
+		return;
+
+	if (atomic_dec_and_test(&lws->refcnt))
+		kfree(lws);
+}
+
+static inline bool lwtunnel_output_redirect(struct lwtunnel_state *lwtstate)
+{
+	if (lwtstate && (lwtstate->flags & LWTUNNEL_STATE_OUTPUT_REDIRECT))
+		return true;
+
+	return false;
+}
+
+int lwtunnel_encap_add_ops(const struct lwtunnel_encap_ops *op,
+			   unsigned int num);
+int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *op,
+			   unsigned int num);
+int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
+			 struct nlattr *encap,
+			 struct lwtunnel_state **lws);
+int lwtunnel_fill_encap(struct sk_buff *skb,
+			struct lwtunnel_state *lwtstate);
+int lwtunnel_get_encap_size(struct lwtunnel_state *lwtstate);
+struct lwtunnel_state *lwtunnel_state_alloc(int hdr_len);
+int lwtunnel_cmp_encap(struct lwtunnel_state *a, struct lwtunnel_state *b);
+
+#else
+
+static inline void lwtunnel_state_get(struct lwtunnel_state *lws)
+{
+}
+
+static inline void lwtunnel_state_put(struct lwtunnel_state *lws)
+{
+}
+
+static inline bool lwtunnel_output_redirect(struct lwtunnel_state *lwtstate)
+{
+	return false;
+}
+
+static inline int lwtunnel_encap_add_ops(const struct lwtunnel_encap_ops *op,
+					 unsigned int num)
+{
+	return -EOPNOTSUPP;
+
+}
+
+static inline int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *op,
+					 unsigned int num)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
+				       struct nlattr *encap,
+				       struct lwtunnel_state **lws)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int lwtunnel_fill_encap(struct sk_buff *skb,
+				      struct lwtunnel_state *lwtstate)
+{
+	return 0;
+}
+
+static inline int lwtunnel_get_encap_size(struct lwtunnel_state *lwtstate)
+{
+	return 0;
+}
+
+static inline struct lwtunnel_state *lwtunnel_state_alloc(int hdr_len)
+{
+	return NULL;
+}
+
+static inline int lwtunnel_cmp_encap(struct lwtunnel_state *a,
+				     struct lwtunnel_state *b)
+{
+	return 0;
+}
+
+#endif
+
+#endif /* __NET_LWTUNNEL_H */
diff --git a/include/uapi/linux/lwtunnel.h b/include/uapi/linux/lwtunnel.h
new file mode 100644
index 0000000..aa611d9
--- /dev/null
+++ b/include/uapi/linux/lwtunnel.h
@@ -0,0 +1,15 @@
+#ifndef _UAPI_LWTUNNEL_H_
+#define _UAPI_LWTUNNEL_H_
+
+#include <linux/types.h>
+
+enum lwtunnel_encap_types {
+	LWTUNNEL_ENCAP_NONE,
+	LWTUNNEL_ENCAP_MPLS,
+	__LWTUNNEL_ENCAP_MAX,
+};
+
+#define LWTUNNEL_ENCAP_MAX (__LWTUNNEL_ENCAP_MAX - 1)
+
+
+#endif /* _UAPI_LWTUNNEL_H_ */
diff --git a/net/Kconfig b/net/Kconfig
index 57a7c5a..7021c1b 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -374,6 +374,13 @@ source "net/caif/Kconfig"
 source "net/ceph/Kconfig"
 source "net/nfc/Kconfig"
 
+config LWTUNNEL
+	bool "Network light weight tunnels"
+	---help---
+	  This feature provides an infrastructure to support light weight
+	  tunnels like mpls. There is no netdevice associated with a light
+	  weight tunnel endpoint. Tunnel encapsulation parameters are stored
+	  with light weight tunnel state associated with fib routes.
 
 endif   # if NET
 
diff --git a/net/core/Makefile b/net/core/Makefile
index fec0856..086b01f 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -23,3 +23,4 @@ obj-$(CONFIG_NETWORK_PHY_TIMESTAMPING) += timestamping.o
 obj-$(CONFIG_NET_PTP_CLASSIFY) += ptp_classifier.o
 obj-$(CONFIG_CGROUP_NET_PRIO) += netprio_cgroup.o
 obj-$(CONFIG_CGROUP_NET_CLASSID) += netclassid_cgroup.o
+obj-$(CONFIG_LWTUNNEL) += lwtunnel.o
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
new file mode 100644
index 0000000..ae876d1
--- /dev/null
+++ b/net/core/lwtunnel.c
@@ -0,0 +1,172 @@
+/*
+ * lwtunnel	Infrastructure for light weight tunnels like mpls
+ *
+ * Authors:	Roopa Prabhu, <roopa@cumulusnetworks.com>
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ */
+
+#include <linux/capability.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/lwtunnel.h>
+#include <linux/in.h>
+#include <linux/init.h>
+#include <linux/err.h>
+
+#include <net/lwtunnel.h>
+#include <net/rtnetlink.h>
+
+struct lwtunnel_state *lwtunnel_state_alloc(int encap_len)
+{
+	struct lwtunnel_state *lws;
+
+	lws = kzalloc(sizeof(*lws) + encap_len, GFP_ATOMIC);
+
+	return lws;
+}
+EXPORT_SYMBOL(lwtunnel_state_alloc);
+
+const struct lwtunnel_encap_ops __rcu *
+		lwtun_encaps[LWTUNNEL_ENCAP_MAX + 1] __read_mostly;
+
+int lwtunnel_encap_add_ops(const struct lwtunnel_encap_ops *ops,
+			   unsigned int num)
+{
+	if (num > LWTUNNEL_ENCAP_MAX)
+		return -ERANGE;
+
+	return !cmpxchg((const struct lwtunnel_encap_ops **)
+			&lwtun_encaps[num],
+			NULL, ops) ? 0 : -1;
+}
+EXPORT_SYMBOL(lwtunnel_encap_add_ops);
+
+int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *ops,
+			   unsigned int encap_type)
+{
+	int ret;
+
+	if (encap_type == LWTUNNEL_ENCAP_NONE ||
+	    encap_type > LWTUNNEL_ENCAP_MAX)
+		return -ERANGE;
+
+	ret = (cmpxchg((const struct lwtunnel_encap_ops **)
+		       &lwtun_encaps[encap_type],
+		       ops, NULL) == ops) ? 0 : -1;
+
+	synchronize_net();
+
+	return ret;
+}
+EXPORT_SYMBOL(lwtunnel_encap_del_ops);
+
+int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
+			 struct nlattr *encap, struct lwtunnel_state **lws)
+{
+	const struct lwtunnel_encap_ops *ops;
+	int ret = -EINVAL;
+
+	if (encap_type == LWTUNNEL_ENCAP_NONE ||
+	    encap_type > LWTUNNEL_ENCAP_MAX)
+		return ret;
+
+	ret = -EOPNOTSUPP;
+	rcu_read_lock();
+	ops = rcu_dereference(lwtun_encaps[encap_type]);
+	if (likely(ops && ops->build_state))
+		ret = ops->build_state(dev, encap, lws);
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL(lwtunnel_build_state);
+
+int lwtunnel_fill_encap(struct sk_buff *skb, struct lwtunnel_state *lwtstate)
+{
+	const struct lwtunnel_encap_ops *ops;
+	struct nlattr *nest;
+	int ret = -EINVAL;
+
+	if (!lwtstate)
+		return 0;
+
+	if (lwtstate->type == LWTUNNEL_ENCAP_NONE ||
+	    lwtstate->type > LWTUNNEL_ENCAP_MAX)
+		return 0;
+
+	ret = -EOPNOTSUPP;
+	nest = nla_nest_start(skb, RTA_ENCAP);
+	rcu_read_lock();
+	ops = rcu_dereference(lwtun_encaps[lwtstate->type]);
+	if (likely(ops && ops->fill_encap))
+		ret = ops->fill_encap(skb, lwtstate);
+	rcu_read_unlock();
+
+	if (ret)
+		goto nla_put_failure;
+	nla_nest_end(skb, nest);
+	ret = nla_put_u16(skb, RTA_ENCAP_TYPE, lwtstate->type);
+	if (ret)
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, nest);
+
+	return (ret == -EOPNOTSUPP ? 0 : ret);
+}
+EXPORT_SYMBOL(lwtunnel_fill_encap);
+
+int lwtunnel_get_encap_size(struct lwtunnel_state *lwtstate)
+{
+	const struct lwtunnel_encap_ops *ops;
+	int ret = 0;
+
+	if (!lwtstate)
+		return 0;
+
+	if (lwtstate->type == LWTUNNEL_ENCAP_NONE ||
+	    lwtstate->type > LWTUNNEL_ENCAP_MAX)
+		return 0;
+
+	rcu_read_lock();
+	ops = rcu_dereference(lwtun_encaps[lwtstate->type]);
+	if (likely(ops && ops->get_encap_size))
+		ret = nla_total_size(ops->get_encap_size(lwtstate));
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL(lwtunnel_get_encap_size);
+
+int lwtunnel_cmp_encap(struct lwtunnel_state *a, struct lwtunnel_state *b)
+{
+	const struct lwtunnel_encap_ops *ops;
+	int ret = 0;
+
+	if (!a || !b)
+		return 1;
+
+	if (a->type != b->type)
+		return 1;
+
+	rcu_read_lock();
+	ops = rcu_dereference(lwtun_encaps[a->type]);
+	if (likely(ops && ops->cmp_encap))
+		ret = ops->cmp_encap(a, b);
+	rcu_read_unlock();
+
+	return 0;
+}
+EXPORT_SYMBOL(lwtunnel_cmp_encap);
-- 
2.4.3
