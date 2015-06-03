From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH WIP RFC 1/3] lwtunnels: basic infra for light weight tunnels like mpls
Date: Wed,  3 Jun 2015 07:21:44 -0700
Message-ID: <1433341306-29288-2-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com, rshearma@brocade.com, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:35370 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932786AbbFCOVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 10:21:55 -0400
Received: by qgg60 with SMTP id 60so4292516qgg.2
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 07:21:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Still in the works. Not fully functional.
And in some cases me going back and forth on a
few things.

Started with thinking the tunnel hdr can be shared
and refcounted. Its somewhere mid way now.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/linux/if_lwtunnel.h      |    8 ++
 include/net/lwtunnel.h           |   61 +++++++++++++
 include/uapi/linux/if_lwtunnel.h |   12 +++
 include/uapi/linux/rtnetlink.h   |    8 +-
 net/Makefile                     |    2 +-
 net/lwtunnel.c                   |  177 ++++++++++++++++++++++++++++++++++++++
 6 files changed, 266 insertions(+), 2 deletions(-)
 create mode 100644 include/linux/if_lwtunnel.h
 create mode 100644 include/net/lwtunnel.h
 create mode 100644 include/uapi/linux/if_lwtunnel.h
 create mode 100644 net/lwtunnel.c

diff --git a/include/linux/if_lwtunnel.h b/include/linux/if_lwtunnel.h
new file mode 100644
index 0000000..5fa7ca2
--- /dev/null
+++ b/include/linux/if_lwtunnel.h
@@ -0,0 +1,8 @@
+#ifndef _IF_LWTUNNEL_H_
+#define _IF_LWTUNNEL_H_
+
+#include <linux/ip.h>
+#include <linux/in6.h>
+#include <uapi/linux/if_lwtunnel.h>
+
+#endif /* _IF_LWTUNNEL_H_ */
diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
new file mode 100644
index 0000000..3964f15
--- /dev/null
+++ b/include/net/lwtunnel.h
@@ -0,0 +1,61 @@
+#ifndef __NET_LW_TUNNELS_H
+#define __NET_LW_TUNNELS_H 1
+
+#include <linux/if_lwtunnel.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/types.h>
+#include <linux/u64_stats_sync.h>
+#include <net/dsfield.h>
+#include <net/gro_cells.h>
+#include <net/inet_ecn.h>
+#include <net/ip.h>
+#include <net/netns/generic.h>
+#include <net/rtnetlink.h>
+
+#define LW_TNL_HASH_BITS   7
+#define LW_TNL_HASH_SIZE   (1 << LW_TNL_HASH_BITS)
+
+struct lwtunnel_hdr {
+	int             len;
+	__u8            data[0];
+};
+
+struct lwtunnel_state {
+	__u16			type;
+	atomic_t          refcnt;
+	spinlock_t        lock;
+	struct lwtunnel_hdr tunnel;
+};
+
+struct lwtunnel_net {
+	struct hlist_head tunnels[LW_TNL_HASH_SIZE];
+};
+
+struct lwtunnel_encap_ops {
+	size_t (*encap_hlen)(struct rtencap *e);
+	int (*build_state)(struct rtencap *e, int len, struct lwtunnel_state **ts);
+	int (*output)(struct sock *sk, struct sk_buff *skb);
+	int (*dump_encap_hdr)(struct sk_buff *skb, int attr, struct lwtunnel_state *lwtstate);
+};
+
+#define MAX_LWTUN_ENCAP_OPS 8
+extern const struct lwtunnel_encap_ops __rcu *
+		lwtun_encaps[MAX_LWTUN_ENCAP_OPS];
+
+int lwtunnel_encap_add_ops(const struct lwtunnel_encap_ops *op,
+			    unsigned int num);
+int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *op,
+			    unsigned int num);
+int lwtunnel_dst_set_output(struct lwtunnel_state *lwtstate,
+                             struct dst_entry *dst);
+int lwtunnel_build_state(struct rtencap *encap, int len,
+                          struct lwtunnel_state **lws);
+int lwtunnel_dump_encap(struct sk_buff *skb,
+                         struct lwtunnel_state *lwtstate);
+int lwtunnel_encap_size(struct lwtunnel_state *lwtstate);
+
+struct lwtunnel_state *lwtunnel_state_alloc(int hdr_len);
+void lwtunnel_state_free(struct lwtunnel_state *lws);
+
+#endif /* __NET_LW_TUNNELS_H */
diff --git a/include/uapi/linux/if_lwtunnel.h b/include/uapi/linux/if_lwtunnel.h
new file mode 100644
index 0000000..28b8497
--- /dev/null
+++ b/include/uapi/linux/if_lwtunnel.h
@@ -0,0 +1,12 @@
+#ifndef _UAPI_IF_LW_TUNNEL_H_
+#define _UAPI_IF_LW_TUNNEL_H_
+
+#include <linux/types.h>
+#include <asm/byteorder.h>
+
+enum tunnel_encap_types {
+	LW_TUNNEL_ENCAP_NONE,
+	LW_TUNNEL_ENCAP_MPLS,
+};
+
+#endif /* _UAPI_IF_LW_TUNNEL_H_ */
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 17fb02f..47e5de1 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -308,6 +308,7 @@ enum rtattr_type_t {
 	RTA_VIA,
 	RTA_NEWDST,
 	RTA_PREF,
+	RTA_ENCAP,
 	__RTA_MAX
 };
 
@@ -356,8 +357,13 @@ struct rtvia {
 	__u8			rtvia_addr[0];
 };
 
-/* RTM_CACHEINFO */
+/* RTA_ENCAP */
+struct rtencap {
+	__u16	type;
+	__u8	dst[0];
+};
 
+/* RTM_CACHEINFO */
 struct rta_cacheinfo {
 	__u32	rta_clntref;
 	__u32	rta_lastuse;
diff --git a/net/Makefile b/net/Makefile
index 3995613..6d51a9d 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -5,7 +5,7 @@
 # Rewritten to use lists instead of if-statements.
 #
 
-obj-$(CONFIG_NET)		:= socket.o core/
+obj-$(CONFIG_NET)		:= socket.o lwtunnel.o core/
 
 tmp-$(CONFIG_COMPAT) 		:= compat.o
 obj-$(CONFIG_NET)		+= $(tmp-y)
diff --git a/net/lwtunnel.c b/net/lwtunnel.c
new file mode 100644
index 0000000..e367a60
--- /dev/null
+++ b/net/lwtunnel.c
@@ -0,0 +1,177 @@
+/*
+ * Copyright (c) 2015 Cumulus Networks, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/capability.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/in.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/if_arp.h>
+#include <linux/mroute.h>
+#include <linux/init.h>
+#include <linux/in6.h>
+#include <linux/inetdevice.h>
+#include <linux/igmp.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/etherdevice.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/rculist.h>
+#include <linux/err.h>
+
+#include <net/sock.h>
+#include <net/ip.h>
+#include <net/icmp.h>
+#include <net/protocol.h>
+#include <net/lwtunnel.h>
+#include <net/arp.h>
+#include <net/checksum.h>
+#include <net/dsfield.h>
+#include <net/inet_ecn.h>
+#include <net/rtnetlink.h>
+#include <net/udp.h>
+
+
+struct lwtunnel_state *lwtunnel_state_alloc(int hdr_len)
+{
+    struct lwtunnel_state *lws;
+
+    lws = kzalloc(sizeof(*lws) + hdr_len, GFP_KERNEL);
+
+    return lws;
+}
+EXPORT_SYMBOL(lwtunnel_state_alloc);
+
+void lwtunnel_state_free(struct lwtunnel_state *lws)
+{
+    kfree(lws);
+}
+
+const struct lwtunnel_encap_ops __rcu *
+		lwtun_encaps[MAX_LWTUN_ENCAP_OPS] __read_mostly;
+
+int lwtunnel_encap_add_ops(const struct lwtunnel_encap_ops *ops,
+			                unsigned int num)
+{
+	if (num >= MAX_LWTUN_ENCAP_OPS)
+		return -ERANGE;
+
+	return !cmpxchg((const struct lwtunnel_encap_ops **)
+			&lwtun_encaps[num],
+			NULL, ops) ? 0 : -1;
+}
+EXPORT_SYMBOL(lwtunnel_encap_add_ops);
+
+int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *ops,
+			                unsigned int num)
+{
+	int ret;
+
+	if (num >= MAX_LWTUN_ENCAP_OPS)
+		return -ERANGE;
+
+	ret = (cmpxchg((const struct lwtunnel_encap_ops **)
+		       &lwtun_encaps[num],
+		       ops, NULL) == ops) ? 0 : -1;
+
+	synchronize_net();
+
+	return ret;
+}
+EXPORT_SYMBOL(lwtunnel_encap_del_ops);
+
+int lwtunnel_build_state(struct rtencap *encap, int len,
+                          struct lwtunnel_state **lws)
+{
+	struct lwtunnel_encap_ops *ops;
+	int ret = -EINVAL;
+
+	if (encap->type == LW_TUNNEL_ENCAP_NONE)
+		return ret;
+
+	if (encap->type == MAX_LWTUN_ENCAP_OPS)
+		return ret;
+
+	rcu_read_lock();
+	ops = rcu_dereference(lwtun_encaps[encap->type]);
+	if (likely(ops && ops->build_state))
+		ret = ops->build_state(encap, len, lws);
+	rcu_read_unlock();
+
+	return 0;
+}
+EXPORT_SYMBOL(lwtunnel_build_state);
+
+int lwtunnel_dst_set_output(struct lwtunnel_state *lwstate,
+                             struct dst_entry *dst)
+{
+	struct lwtunnel_encap_ops *ops;
+	int ret = -EINVAL;
+
+	if (lwstate->type == LW_TUNNEL_ENCAP_NONE)
+		return 0;
+
+	if (lwstate->type == MAX_LWTUN_ENCAP_OPS)
+		return 0;
+
+	rcu_read_lock();
+	ops = rcu_dereference(lwtun_encaps[lwstate->type]);
+	if (likely(ops && ops->output))
+	dst->output = ops->output;
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL(lwtunnel_dst_set_output);
+
+int lwtunnel_dump_encap(struct sk_buff *skb, struct lwtunnel_state *lwstate)
+{
+	struct lwtunnel_encap_ops *ops;
+	int ret = -EINVAL;
+
+	if (lwstate->type == LW_TUNNEL_ENCAP_NONE)
+		return 0;
+
+	if (lwstate->type == MAX_LWTUN_ENCAP_OPS)
+		return 0;
+
+	rcu_read_lock();
+	ops = rcu_dereference(lwtun_encaps[lwstate->type]);
+	if (likely(ops && ops->dump_encap_hdr))
+		ret = ops->dump_encap_hdr(skb, RTA_ENCAP, lwstate);
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL(lwtunnel_dump_encap);
+
+int lwtunnel_encap_size(struct lwtunnel_state *lwstate)
+{
+	return lwstate->tunnel.len;
+}
+EXPORT_SYMBOL(lwtunnel_encap_size);
+
+MODULE_LICENSE("GPL");
-- 
1.7.10.4
