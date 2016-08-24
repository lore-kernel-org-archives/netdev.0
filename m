From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V2 4/4] net/sched: Introduce act_tunnel_key
Date: Wed, 24 Aug 2016 15:27:10 +0300
Message-ID: <20160824122710.30356-5-amir@vadai.me>
References: <20160824122710.30356-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33551 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753290AbcHXMmv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 08:42:51 -0400
Received: by mail-wm0-f67.google.com with SMTP id o80so2502730wme.0
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 05:42:50 -0700 (PDT)
In-Reply-To: <20160824122710.30356-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This action could be used before redirecting packets to a shared tunnel
device, or when redirecting packets arriving from a such a device.

The action will release the metadata created by the tunnel device
(decap), or set the metadata with the specified values for encap
operation.

For example, the following flower filter will forward all ICMP packets
destined to 11.11.11.2 through the shared vxlan device 'vxlan0'. Before
redirecting, a metadata for the vxlan tunnel is created using the
tunnel_key action and it's arguments:

$ filter add dev net0 protocol ip parent ffff: \
    flower \
      ip_proto 1 \
      dst_ip 11.11.11.2 \
    action tunnel_key set\
      src_ip 11.11.0.1 \
      dst_ip 11.11.0.2 \
      id 11 \
    action mirred egress redirect dev vxlan0

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 include/net/tc_act/tc_tunnel_key.h        |  25 +++
 include/uapi/linux/tc_act/tc_tunnel_key.h |  42 ++++
 net/sched/Kconfig                         |  11 ++
 net/sched/Makefile                        |   1 +
 net/sched/act_tunnel_key.c                | 314 ++++++++++++++++++++++++++++++
 5 files changed, 393 insertions(+)
 create mode 100644 include/net/tc_act/tc_tunnel_key.h
 create mode 100644 include/uapi/linux/tc_act/tc_tunnel_key.h
 create mode 100644 net/sched/act_tunnel_key.c

diff --git a/include/net/tc_act/tc_tunnel_key.h b/include/net/tc_act/tc_tunnel_key.h
new file mode 100644
index 000000000000..18d5950059cb
--- /dev/null
+++ b/include/net/tc_act/tc_tunnel_key.h
@@ -0,0 +1,25 @@
+/*
+ * Copyright (c) 2016, Amir Vadai <amir@vadai.me>
+ * Copyright (c) 2016, Mellanox Technologies. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __NET_TC_TUNNEL_KEY_H
+#define __NET_TC_TUNNEL_KEY_H
+
+#include <net/act_api.h>
+
+struct tcf_tunnel_key {
+	struct tc_action	common;
+	int			tcft_action;
+	struct metadata_dst     *tcft_enc_metadata;
+};
+
+#define to_tunnel_key(a) ((struct tcf_tunnel_key *)a)
+
+#endif /* __NET_TC_TUNNEL_KEY_H */
+
diff --git a/include/uapi/linux/tc_act/tc_tunnel_key.h b/include/uapi/linux/tc_act/tc_tunnel_key.h
new file mode 100644
index 000000000000..f9ddf5369a45
--- /dev/null
+++ b/include/uapi/linux/tc_act/tc_tunnel_key.h
@@ -0,0 +1,42 @@
+/*
+ * Copyright (c) 2016, Amir Vadai <amir@vadai.me>
+ * Copyright (c) 2016, Mellanox Technologies. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef __LINUX_TC_TUNNEL_KEY_H
+#define __LINUX_TC_TUNNEL_KEY_H
+
+#include <linux/pkt_cls.h>
+
+#define TCA_ACT_TUNNEL_KEY 17
+
+#define TCA_TUNNEL_KEY_ACT_SET	    1
+#define TCA_TUNNEL_KEY_ACT_RELEASE  2
+
+struct tc_tunnel_key {
+	tc_gen;
+	int t_action;
+};
+
+enum {
+	TCA_TUNNEL_KEY_UNSPEC,
+	TCA_TUNNEL_KEY_TM,
+	TCA_TUNNEL_KEY_PARMS,
+	TCA_TUNNEL_KEY_ENC_IPV4_SRC,	/* be32 */
+	TCA_TUNNEL_KEY_ENC_IPV4_DST,	/* be32 */
+	TCA_TUNNEL_KEY_ENC_IPV6_SRC,	/* struct in6_addr */
+	TCA_TUNNEL_KEY_ENC_IPV6_DST,	/* struct in6_addr */
+	TCA_TUNNEL_KEY_ENC_KEY_ID,	/* be64 */
+	TCA_TUNNEL_KEY_PAD,
+	__TCA_TUNNEL_KEY_MAX,
+};
+
+#define TCA_TUNNEL_KEY_MAX (__TCA_TUNNEL_KEY_MAX - 1)
+
+#endif
+
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index ccf931b3b94c..f9f602d57f2a 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -761,6 +761,17 @@ config NET_ACT_IFE
 	  To compile this code as a module, choose M here: the
 	  module will be called act_ife.
 
+config NET_ACT_TUNNEL_KEY
+        tristate "IP tunnel metadata manipulation"
+        depends on NET_CLS_ACT
+        ---help---
+	  Say Y here to set/release ip tunnel metadata.
+
+	  If unsure, say N.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called act_tunnel.
+
 config NET_IFE_SKBMARK
         tristate "Support to encoding decoding skb mark on IFE action"
         depends on NET_ACT_IFE
diff --git a/net/sched/Makefile b/net/sched/Makefile
index ae088a5a9d95..b9d046b9535a 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -22,6 +22,7 @@ obj-$(CONFIG_NET_ACT_CONNMARK)	+= act_connmark.o
 obj-$(CONFIG_NET_ACT_IFE)	+= act_ife.o
 obj-$(CONFIG_NET_IFE_SKBMARK)	+= act_meta_mark.o
 obj-$(CONFIG_NET_IFE_SKBPRIO)	+= act_meta_skbprio.o
+obj-$(CONFIG_NET_ACT_TUNNEL_KEY)+= act_tunnel_key.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
 obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
diff --git a/net/sched/act_tunnel_key.c b/net/sched/act_tunnel_key.c
new file mode 100644
index 000000000000..e34c8606764b
--- /dev/null
+++ b/net/sched/act_tunnel_key.c
@@ -0,0 +1,314 @@
+/*
+ * Copyright (c) 2016, Amir Vadai <amir@vadai.me>
+ * Copyright (c) 2016, Mellanox Technologies. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <net/netlink.h>
+#include <net/pkt_sched.h>
+#include <net/dst.h>
+#include <net/dst_metadata.h>
+
+#include <linux/tc_act/tc_tunnel_key.h>
+#include <net/tc_act/tc_tunnel_key.h>
+
+#define TUNNEL_KEY_TAB_MASK     15
+
+static int tunnel_key_net_id;
+static struct tc_action_ops act_tunnel_key_ops;
+
+static int tunnel_key_act(struct sk_buff *skb, const struct tc_action *a,
+			  struct tcf_result *res)
+{
+	struct tcf_tunnel_key *t = to_tunnel_key(a);
+	int action;
+
+	spin_lock(&t->tcf_lock);
+	tcf_lastuse_update(&t->tcf_tm);
+	bstats_update(&t->tcf_bstats, skb);
+	action = t->tcf_action;
+
+	switch (t->tcft_action) {
+	case TCA_TUNNEL_KEY_ACT_RELEASE:
+		skb_dst_set_noref(skb, NULL);
+		break;
+	case TCA_TUNNEL_KEY_ACT_SET:
+		skb_dst_set_noref(skb, &t->tcft_enc_metadata->dst);
+
+		break;
+	default:
+		WARN_ONCE(1, "Bad tunnel_key action.\n");
+		break;
+	}
+
+	spin_unlock(&t->tcf_lock);
+	return action;
+}
+
+static const struct nla_policy tunnel_key_policy[TCA_TUNNEL_KEY_MAX + 1] = {
+	[TCA_TUNNEL_KEY_PARMS]	    = { .len = sizeof(struct tc_tunnel_key) },
+	[TCA_TUNNEL_KEY_ENC_IPV4_SRC] = { .type = NLA_U32 },
+	[TCA_TUNNEL_KEY_ENC_IPV4_DST] = { .type = NLA_U32 },
+	[TCA_TUNNEL_KEY_ENC_IPV6_SRC] = { .len = sizeof(struct in6_addr) },
+	[TCA_TUNNEL_KEY_ENC_IPV6_DST] = { .len = sizeof(struct in6_addr) },
+	[TCA_TUNNEL_KEY_ENC_KEY_ID]   = { .type = NLA_U32 },
+};
+
+static int tunnel_key_init(struct net *net, struct nlattr *nla,
+			   struct nlattr *est, struct tc_action **a,
+			   int ovr, int bind)
+{
+	struct tc_action_net *tn = net_generic(net, tunnel_key_net_id);
+	struct nlattr *tb[TCA_TUNNEL_KEY_MAX + 1];
+	struct metadata_dst *metadata = NULL;
+	struct tc_tunnel_key *parm;
+	struct tcf_tunnel_key *t;
+	__be64 key_id;
+	int encapdecap;
+	bool exists = false;
+	int ret = 0;
+	int err;
+
+	if (!nla)
+		return -EINVAL;
+
+	err = nla_parse_nested(tb, TCA_TUNNEL_KEY_MAX, nla, tunnel_key_policy);
+	if (err < 0)
+		return err;
+
+	if (!tb[TCA_TUNNEL_KEY_PARMS])
+		return -EINVAL;
+
+	parm = nla_data(tb[TCA_TUNNEL_KEY_PARMS]);
+	exists = tcf_hash_check(tn, parm->index, a, bind);
+	if (exists && bind)
+		return 0;
+
+	encapdecap = parm->t_action;
+
+	switch (encapdecap) {
+	case TCA_TUNNEL_KEY_ACT_RELEASE:
+		break;
+	case TCA_TUNNEL_KEY_ACT_SET:
+		if (!tb[TCA_TUNNEL_KEY_ENC_KEY_ID]) {
+			ret = -EINVAL;
+			goto err_out;
+		}
+
+		key_id = key32_to_tunnel_id(nla_get_be32(tb[TCA_TUNNEL_KEY_ENC_KEY_ID]));
+
+		if (tb[TCA_TUNNEL_KEY_ENC_IPV4_SRC] &&
+		    tb[TCA_TUNNEL_KEY_ENC_IPV4_DST]) {
+			__be32 saddr;
+			__be32 daddr;
+
+			saddr = nla_get_be32(tb[TCA_TUNNEL_KEY_ENC_IPV4_SRC]);
+			daddr = nla_get_be32(tb[TCA_TUNNEL_KEY_ENC_IPV4_DST]);
+
+			metadata = _ip_tun_rx_dst(saddr, daddr, 0, 0,
+						  TUNNEL_KEY, key_id, 0);
+		} else if (tb[TCA_TUNNEL_KEY_ENC_IPV6_SRC] &&
+			   tb[TCA_TUNNEL_KEY_ENC_IPV6_DST]) {
+			struct in6_addr saddr;
+			struct in6_addr daddr;
+
+			saddr = nla_get_in6_addr(tb[TCA_TUNNEL_KEY_ENC_IPV6_SRC]);
+			daddr = nla_get_in6_addr(tb[TCA_TUNNEL_KEY_ENC_IPV6_DST]);
+
+			metadata = _ipv6_tun_rx_dst(saddr, daddr, 0, 0, 0,
+						    TUNNEL_KEY, key_id, 0);
+		}
+
+		if (!metadata) {
+			ret = -EINVAL;
+			goto err_out;
+		}
+
+		metadata->u.tun_info.mode |= IP_TUNNEL_INFO_TX;
+		break;
+	default:
+		goto err_out;
+	}
+
+	if (!exists) {
+		ret = tcf_hash_create(tn, parm->index, est, a,
+				      &act_tunnel_key_ops, bind, false);
+		if (ret)
+			return ret;
+
+		ret = ACT_P_CREATED;
+	} else {
+		tcf_hash_release(*a, bind);
+		if (!ovr)
+			return -EEXIST;
+	}
+
+	t = to_tunnel_key(*a);
+
+	spin_lock_bh(&t->tcf_lock);
+
+	t->tcf_action = parm->action;
+
+	t->tcft_action = encapdecap;
+	t->tcft_enc_metadata = metadata;
+
+	spin_unlock_bh(&t->tcf_lock);
+
+	if (ret == ACT_P_CREATED)
+		tcf_hash_insert(tn, *a);
+
+	return ret;
+
+err_out:
+	if (exists)
+		tcf_hash_release(*a, bind);
+	return ret;
+}
+
+static void tunnel_key_release(struct tc_action *a, int bind)
+{
+	struct tcf_tunnel_key *t = to_tunnel_key(a);
+
+	if (t->tcft_action == TCA_TUNNEL_KEY_ACT_SET)
+		dst_release(&t->tcft_enc_metadata->dst);
+}
+
+static int tunnel_key_dump_addresses(struct sk_buff *skb,
+				     const struct ip_tunnel_info *info)
+{
+	unsigned short family = ip_tunnel_info_af(info);
+
+	if (family == AF_INET) {
+		__be32 saddr = info->key.u.ipv4.src;
+		__be32 daddr = info->key.u.ipv4.dst;
+
+		if (!nla_put_be32(skb, TCA_TUNNEL_KEY_ENC_IPV4_SRC, saddr) &&
+		    !nla_put_be32(skb, TCA_TUNNEL_KEY_ENC_IPV4_DST, daddr))
+			return 0;
+	}
+
+	if (family == AF_INET6) {
+		struct in6_addr saddr6 = info->key.u.ipv6.src;
+		struct in6_addr daddr6 = info->key.u.ipv6.dst;
+
+		if (!nla_put_in6_addr(skb, TCA_TUNNEL_KEY_ENC_IPV6_SRC, &saddr6) &&
+		    !nla_put_in6_addr(skb, TCA_TUNNEL_KEY_ENC_IPV6_DST, &daddr6))
+			return 0;
+	}
+
+	return -EINVAL;
+}
+
+static int tunnel_key_dump(struct sk_buff *skb, struct tc_action *a,
+			   int bind, int ref)
+{
+	unsigned char *b = skb_tail_pointer(skb);
+	struct tcf_tunnel_key *t = to_tunnel_key(a);
+	struct tc_tunnel_key opt = {
+		.index    = t->tcf_index,
+		.refcnt   = t->tcf_refcnt - ref,
+		.bindcnt  = t->tcf_bindcnt - bind,
+		.action   = t->tcf_action,
+		.t_action = t->tcft_action,
+	};
+	struct tcf_t tm;
+
+	if (nla_put(skb, TCA_TUNNEL_KEY_PARMS, sizeof(opt), &opt))
+		goto nla_put_failure;
+
+	if (t->tcft_action == TCA_TUNNEL_KEY_ACT_SET) {
+		struct ip_tunnel_key *key =
+			&t->tcft_enc_metadata->u.tun_info.key;
+		__be32 key_id = tunnel_id_to_key32(key->tun_id);
+
+		if (nla_put_be32(skb, TCA_TUNNEL_KEY_ENC_KEY_ID, key_id) ||
+		    tunnel_key_dump_addresses(skb, &t->tcft_enc_metadata->u.tun_info))
+			goto nla_put_failure;
+	}
+
+	tcf_tm_dump(&tm, &t->tcf_tm);
+	if (nla_put_64bit(skb, TCA_TUNNEL_KEY_TM, sizeof(tm), &tm, TCA_TUNNEL_KEY_PAD))
+		goto nla_put_failure;
+
+	return skb->len;
+
+nla_put_failure:
+	nlmsg_trim(skb, b);
+	return -1;
+}
+
+static int tunnel_key_walker(struct net *net, struct sk_buff *skb,
+			     struct netlink_callback *cb, int type,
+			     const struct tc_action_ops *ops)
+{
+	struct tc_action_net *tn = net_generic(net, tunnel_key_net_id);
+
+	return tcf_generic_walker(tn, skb, cb, type, ops);
+}
+
+static int tunnel_key_search(struct net *net, struct tc_action **a, u32 index)
+{
+	struct tc_action_net *tn = net_generic(net, tunnel_key_net_id);
+
+	return tcf_hash_search(tn, a, index);
+}
+
+static struct tc_action_ops act_tunnel_key_ops = {
+	.kind		=	"tunnel_key",
+	.type		=	TCA_ACT_TUNNEL_KEY,
+	.owner		=	THIS_MODULE,
+	.act		=	tunnel_key_act,
+	.dump		=	tunnel_key_dump,
+	.init		=	tunnel_key_init,
+	.cleanup	=	tunnel_key_release,
+	.walk		=	tunnel_key_walker,
+	.lookup		=	tunnel_key_search,
+	.size		=	sizeof(struct tcf_tunnel_key),
+};
+
+static __net_init int tunnel_key_init_net(struct net *net)
+{
+	struct tc_action_net *tn = net_generic(net, tunnel_key_net_id);
+
+	return tc_action_net_init(tn, &act_tunnel_key_ops, TUNNEL_KEY_TAB_MASK);
+}
+
+static void __net_exit tunnel_key_exit_net(struct net *net)
+{
+	struct tc_action_net *tn = net_generic(net, tunnel_key_net_id);
+
+	tc_action_net_exit(tn);
+}
+
+static struct pernet_operations tunnel_key_net_ops = {
+	.init = tunnel_key_init_net,
+	.exit = tunnel_key_exit_net,
+	.id   = &tunnel_key_net_id,
+	.size = sizeof(struct tc_action_net),
+};
+
+static int __init tunnel_key_init_module(void)
+{
+	return tcf_register_action(&act_tunnel_key_ops, &tunnel_key_net_ops);
+}
+
+static void __exit tunnel_key_cleanup_module(void)
+{
+	tcf_unregister_action(&act_tunnel_key_ops, &tunnel_key_net_ops);
+}
+
+module_init(tunnel_key_init_module);
+module_exit(tunnel_key_cleanup_module);
+
+MODULE_AUTHOR("Amir Vadai <amir@vadai.me>");
+MODULE_DESCRIPTION("ip tunnel manipulation actions");
+MODULE_LICENSE("GPL v2");
-- 
2.9.0
