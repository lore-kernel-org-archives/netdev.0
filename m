From: Joe Stringer <joestringer@nicira.com>
Subject: [RFC net-next 3/4] openvswitch: Add conntrack action.
Date: Sat, 14 Feb 2015 00:13:52 -0800
Message-ID: <1423901633-53789-4-git-send-email-joestringer@nicira.com>
References: <1423901633-53789-1-git-send-email-joestringer@nicira.com>
Cc: Justin Pettit <jpettit@nicira.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:53803 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753519AbbBNIOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2015 03:14:05 -0500
Received: by mail-ig0-f170.google.com with SMTP id l13so20793585iga.1
        for <netdev@vger.kernel.org>; Sat, 14 Feb 2015 00:14:04 -0800 (PST)
In-Reply-To: <1423901633-53789-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Justin Pettit <jpettit@nicira.com>

Expose the kernel connection tracker to OVS. Userspace components can
make use of the "conntrack()" action, followed by "recirculate", to
populate the conntracking state in the OVS flow key, and subsequently
match on that state.

IP fragment handling is yet to be addressed, for the time being we pass
fragments through to conntrack directly, which I expect will result in
the connection being identified as "invalid".

Zone support added by Thomas Graf <tgraf@noironetworks.com>

Signed-off-by: Justin Pettit <jpettit@nicira.com>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
This is mostly a tidyup and port across to net-next from the previous
version of this patch. Newly added is ability to match on zones, adding
support for matching connections that cannot be identified ("invalid"),
and more testing in the userspace component which is available here:

https://www.github.com/justinpettit/openvswitch conntrack

Changes since RFC:
- Rebase to net-next.
- Add conn_zone field to the flow key.
- Add explicit dependencies on conn_zone, conn_mark.
- Refactor conntrack changes into net/openvswitch/ovs_conntrack.*.
- Don't allow set_field() actions to change conn_state, conn_zone.
- Add OVS_CS_F_* flags to indicate connection state.
- Add "invalid" connection state.
---
 include/uapi/linux/openvswitch.h |   36 +++++
 net/openvswitch/Kconfig          |   11 ++
 net/openvswitch/Makefile         |    1 +
 net/openvswitch/actions.c        |    5 +
 net/openvswitch/conntrack.c      |  280 ++++++++++++++++++++++++++++++++++++++
 net/openvswitch/conntrack.h      |   71 ++++++++++
 net/openvswitch/datapath.c       |   18 ++-
 net/openvswitch/flow.c           |    3 +
 net/openvswitch/flow.h           |    2 +
 net/openvswitch/flow_netlink.c   |   79 +++++++++--
 net/openvswitch/flow_netlink.h   |    4 +-
 11 files changed, 487 insertions(+), 23 deletions(-)
 create mode 100644 net/openvswitch/conntrack.c
 create mode 100644 net/openvswitch/conntrack.h

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index bbd49a0..3c5cfef 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -317,6 +317,8 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_MPLS,      /* array of struct ovs_key_mpls.
 				 * The implementation may restrict
 				 * the accepted length of the array. */
+	OVS_KEY_ATTR_CONN_STATE,/* u8 of OVS_CS_F_* */
+	OVS_KEY_ATTR_CONN_ZONE, /* u16 connection tracking zone. */
 
 #ifdef __KERNEL__
 	OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ovs_tunnel_info */
@@ -429,6 +431,15 @@ struct ovs_key_nd {
 	__u8	nd_tll[ETH_ALEN];
 };
 
+/* OVS_KEY_ATTR_CONN_STATE flags */
+#define OVS_CS_F_NEW               BIT(0) /* Beginning of a new connection. */
+#define OVS_CS_F_ESTABLISHED       BIT(1) /* Part of an existing connection. */
+#define OVS_CS_F_RELATED           BIT(2) /* Related to an established
+					     connection. */
+#define OVS_CS_F_INVALID           BIT(5) /* Could not track connection. */
+#define OVS_CS_F_REPLY_DIR         BIT(6) /* Flow is in the reply direction. */
+#define OVS_CS_F_TRACKED           BIT(7) /* Conntrack has occurred. */
+
 /**
  * enum ovs_flow_attr - attributes for %OVS_FLOW_* commands.
  * @OVS_FLOW_ATTR_KEY: Nested %OVS_KEY_ATTR_* attributes specifying the flow
@@ -591,6 +602,28 @@ struct ovs_action_hash {
 };
 
 /**
+ * enum ovs_ct_attr - Attributes for %OVS_ACTION_ATTR_CT action.
+ * @OVS_CT_ATTR_FLAGS: u32 connection tracking flags.
+ * @OVS_CT_ATTR_ZONE: u16 connection tracking zone.
+ */
+enum ovs_ct_attr {
+	OVS_CT_ATTR_UNSPEC,
+	OVS_CT_ATTR_FLAGS,      /* u8 of OVS_CT_F_*. */
+	OVS_CT_ATTR_ZONE,       /* u16 number. */
+	__OVS_CT_ATTR_MAX
+};
+
+#define OVS_CT_ATTR_MAX (__OVS_CT_ATTR_MAX - 1)
+
+/*
+ * OVS_CT_ATTR_FLAGS flags - bitmask of %OVS_CT_F_*
+ * @OVS_CT_F_COMMIT: Commits the the flow to the conntrack hashtable in the
+ * specified zone. Future packets for the current connection will no longer
+ * be considered as 'new'.
+ */
+#define OVS_CT_F_COMMIT BIT(0)
+
+/**
  * enum ovs_action_attr - Action types.
  *
  * @OVS_ACTION_ATTR_OUTPUT: Output packet to port.
@@ -619,6 +652,8 @@ struct ovs_action_hash {
  * indicate the new packet contents. This could potentially still be
  * %ETH_P_MPLS if the resulting MPLS label stack is not empty.  If there
  * is no MPLS label stack, as determined by ethertype, no action is taken.
+ * @OVS_ACTION_ATTR_CT: Track the connection. Populate the conntrack-related
+ * entries in the flow key.
  *
  * Only a single header can be set with a single %OVS_ACTION_ATTR_SET.  Not all
  * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
@@ -644,6 +679,7 @@ enum ovs_action_attr {
 				       * data immediately followed by a mask.
 				       * The data must be zero for the unmasked
 				       * bits. */
+	OVS_ACTION_ATTR_CT,           /* One nested OVS_CT_ATTR_* . */
 
 	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
 				       * from userspace. */
diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index b7d818c..b108dca 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -30,6 +30,17 @@ config OPENVSWITCH
 
 	  If unsure, say N.
 
+config OPENVSWITCH_CONNTRACK
+	bool "Open vSwitch conntrack action support"
+	depends on OPENVSWITCH
+	depends on NF_CONNTRACK
+	default OPENVSWITCH
+	---help---
+	  If you say Y here, then Open vSwitch module will be able to pass
+	  packets through conntrack.
+
+	  Say N to exclude this support and reduce the binary size.
+
 config OPENVSWITCH_GRE
 	tristate "Open vSwitch GRE tunneling support"
 	depends on OPENVSWITCH
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 91b9478..7e7e2c6 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -15,6 +15,7 @@ openvswitch-y := \
 	vport-internal_dev.o \
 	vport-netdev.o
 
+openvswitch-$(CONFIG_OPENVSWITCH_CONNTRACK) += conntrack.o
 obj-$(CONFIG_OPENVSWITCH_GENEVE)+= vport-geneve.o
 obj-$(CONFIG_OPENVSWITCH_VXLAN)	+= vport-vxlan.o
 obj-$(CONFIG_OPENVSWITCH_GRE)	+= vport-gre.o
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index ed3cb56..2d801f6 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -38,6 +38,7 @@
 
 #include "datapath.h"
 #include "flow.h"
+#include "conntrack.h"
 #include "vport.h"
 
 static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
@@ -916,6 +917,10 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 		case OVS_ACTION_ATTR_SAMPLE:
 			err = sample(dp, skb, key, a);
 			break;
+
+		case OVS_ACTION_ATTR_CT:
+			err = ovs_ct_execute(skb, key, nla_data(a));
+			break;
 		}
 
 		if (unlikely(err)) {
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
new file mode 100644
index 0000000..a7c5203
--- /dev/null
+++ b/net/openvswitch/conntrack.c
@@ -0,0 +1,280 @@
+/*
+ * Copyright (c) 2015 Nicira, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ */
+
+#include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_zones.h>
+#include <uapi/linux/openvswitch.h>
+
+#include "datapath.h"
+#include "conntrack.h"
+#include "flow.h"
+#include "flow_netlink.h"
+
+struct ovs_conntrack_info {
+	u32 flags;
+	u16 zone;
+	struct nf_conn *ct;
+};
+
+/* Determine whether skb->nfct is equal to the result of conntrack lookup. */
+static bool skb_has_valid_nfct(const struct net *net, u16 zone,
+			       const struct sk_buff *skb)
+{
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
+
+	if (!ct)
+		return false;
+	if (!net_eq(net, ct->ct_net))
+		return false;
+	if (zone != nf_ct_zone(ct))
+		return false;
+	return true;
+}
+
+static struct net *ovs_get_net(struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_NS
+	struct vport *vport;
+
+	vport = OVS_CB(skb)->input_vport;
+	if (!vport)
+		return ERR_PTR(-EINVAL);
+
+	return vport->dp->net;
+#else
+	return &init_net;
+#endif
+}
+
+/* Map SKB connection state into the values used by flow definition. */
+u8 ovs_ct_get_state(const struct sk_buff *skb)
+{
+	enum ip_conntrack_info ctinfo;
+	u8 cstate = OVS_CS_F_TRACKED;
+
+	if (!nf_ct_get(skb, &ctinfo))
+		return 0;
+
+	switch (ctinfo) {
+	case IP_CT_ESTABLISHED_REPLY:
+	case IP_CT_RELATED_REPLY:
+	case IP_CT_NEW_REPLY:
+		cstate |= OVS_CS_F_REPLY_DIR;
+		break;
+	default:
+		break;
+	}
+
+	switch (ctinfo) {
+	case IP_CT_ESTABLISHED:
+	case IP_CT_ESTABLISHED_REPLY:
+		cstate |= OVS_CS_F_ESTABLISHED;
+		break;
+	case IP_CT_RELATED:
+	case IP_CT_RELATED_REPLY:
+		cstate |= OVS_CS_F_RELATED;
+		break;
+	case IP_CT_NEW:
+	case IP_CT_NEW_REPLY:
+		cstate |= OVS_CS_F_NEW;
+		break;
+	default:
+		break;
+	}
+
+	return cstate;
+}
+
+u16 ovs_ct_get_zone(const struct sk_buff *skb)
+{
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+
+	ct = nf_ct_get(skb, &ctinfo);
+
+	return ct ? nf_ct_zone(ct) : NF_CT_DEFAULT_ZONE;
+}
+
+bool ovs_ct_state_valid(const struct sw_flow_key *key)
+{
+	return (key->phy.conn_state &&
+		key->phy.conn_state != OVS_CS_F_INVALID);
+}
+
+static int ovs_ct_lookup(struct nf_conn *tmpl, struct sw_flow_key *key,
+			 struct sk_buff *skb)
+{
+	struct net *net;
+	u16 zone = tmpl ? nf_ct_zone(tmpl) : NF_CT_DEFAULT_ZONE;
+
+	net = ovs_get_net(skb);
+	if (IS_ERR(net))
+		return PTR_ERR(net);
+
+	if (!skb_has_valid_nfct(net, zone, skb)) {
+		/* Associate skb with specified zone. */
+		if (tmpl) {
+			atomic_inc(&tmpl->ct_general.use);
+			skb->nfct = &tmpl->ct_general;
+			skb->nfctinfo = IP_CT_NEW;
+		}
+
+		if (nf_conntrack_in(net, PF_INET, NF_INET_PRE_ROUTING, skb) !=
+		    NF_ACCEPT)
+			return -ENOENT;
+	}
+
+	if (skb->nfct) {
+		key->phy.conn_state = ovs_ct_get_state(skb);
+		key->phy.conn_zone = ovs_ct_get_zone(skb);
+	} else {
+		key->phy.conn_state = OVS_CS_F_INVALID;
+		key->phy.conn_zone = zone;
+	}
+
+	return 0;
+}
+
+int ovs_ct_execute(struct sk_buff *skb, struct sw_flow_key *key,
+		   const struct ovs_conntrack_info *info)
+{
+	int nh_ofs = skb_network_offset(skb);
+	struct nf_conn *tmpl = info->ct;
+	int err = -EINVAL;
+
+	/* The conntrack module expects to be working at L3. */
+	skb_pull(skb, nh_ofs);
+
+	if (ovs_ct_lookup(tmpl, key, skb))
+		goto err_push_skb;
+
+	if (!ovs_ct_state_valid(key))
+		goto err_push_skb;
+
+	if (info->flags & OVS_CT_F_COMMIT &&
+	    nf_conntrack_confirm(skb) != NF_ACCEPT)
+		goto err_push_skb;
+
+	err = 0;
+err_push_skb:
+	/* Point back to L2, which OVS expects. */
+	skb_push(skb, nh_ofs);
+	return err;
+}
+
+int ovs_ct_copy_action(struct net *net, const struct nlattr *attr,
+		       const struct sw_flow_key *key,
+		       struct sw_flow_actions **sfa,  bool log)
+{
+	struct ovs_conntrack_info ct_info;
+	struct nf_conntrack_tuple t;
+	struct nlattr *a;
+	int rem;
+
+	memset(&ct_info, 0, sizeof(ct_info));
+
+	nla_for_each_nested(a, attr, rem) {
+		int type = nla_type(a);
+		static const u32 ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
+			[OVS_CT_ATTR_FLAGS] = sizeof(u32),
+			[OVS_CT_ATTR_ZONE] = sizeof(u16),
+		};
+
+		if (type > OVS_CT_ATTR_MAX) {
+			OVS_NLERR(log,
+				  "Unknown conntrack attr (type=%d, max=%d)\n",
+				  type, OVS_CT_ATTR_MAX);
+			return -EINVAL;
+		}
+
+		if (ovs_ct_attr_lens[type] != nla_len(a) &&
+		    ovs_ct_attr_lens[type] != -1) {
+			OVS_NLERR(log,
+				  "Conntrack attr type has unexpected length (type=%d, length=%d, expected=%d)\n",
+				  type, nla_len(a), ovs_ct_attr_lens[type]);
+			return -EINVAL;
+		}
+
+		switch (type) {
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+		case OVS_CT_ATTR_ZONE:
+			memset(&t, 0, sizeof(t));
+			ct_info.zone = nla_get_u16(a);
+			ct_info.ct = nf_conntrack_alloc(net,
+					ct_info.zone, &t, &t,
+					GFP_KERNEL);
+			if (IS_ERR(ct_info.ct))
+				return PTR_ERR(ct_info.ct);
+
+			nf_conntrack_tmpl_insert(net, ct_info.ct);
+			break;
+#endif
+		case OVS_CT_ATTR_FLAGS:
+			ct_info.flags = nla_get_u32(a);
+			break;
+		default:
+			OVS_NLERR(log, "Unknown conntrack attr (%d)\n",
+				  type);
+			return -EINVAL;
+		}
+	}
+
+	if (rem > 0) {
+		OVS_NLERR(log, "Conntrack attr has %d unknown bytes\n", rem);
+		return -EINVAL;
+	}
+
+	return ovs_nla_add_action(sfa, OVS_ACTION_ATTR_CT, &ct_info,
+				  sizeof(ct_info), log);
+}
+
+int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
+			  struct sk_buff *skb)
+{
+	struct nlattr *start;
+
+	start = nla_nest_start(skb, OVS_ACTION_ATTR_CT);
+	if (!start)
+		return -EMSGSIZE;
+
+	if (nla_put_u32(skb, OVS_CT_ATTR_FLAGS, ct_info->flags))
+		return -EMSGSIZE;
+
+	if (nla_put_u16(skb, OVS_CT_ATTR_ZONE, ct_info->zone))
+		return -EMSGSIZE;
+
+	nla_nest_end(skb, start);
+
+	return 0;
+}
+
+void ovs_ct_free_acts(struct sw_flow_actions *sf_acts)
+{
+	if (sf_acts) {
+		struct ovs_conntrack_info *ct_info;
+		struct nlattr *a;
+		int rem, len = sf_acts->actions_len;
+
+		for (a = sf_acts->actions, rem = len; rem > 0;
+		     a = nla_next(a, &rem)) {
+			switch (nla_type(a)) {
+			case OVS_ACTION_ATTR_CT:
+				ct_info = nla_data(a);
+				if (ct_info->ct)
+					nf_ct_put(ct_info->ct);
+				break;
+			}
+		}
+	}
+}
diff --git a/net/openvswitch/conntrack.h b/net/openvswitch/conntrack.h
new file mode 100644
index 0000000..af7ec31
--- /dev/null
+++ b/net/openvswitch/conntrack.h
@@ -0,0 +1,71 @@
+/*
+ * Copyright (c) 2015 Nicira, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ */
+
+#ifndef OVS_CONNTRACK_H
+#define OVS_CONNTRACK_H 1
+
+struct ovs_conntrack_info;
+
+#if defined(CONFIG_OPENVSWITCH_CONNTRACK)
+int ovs_ct_copy_action(struct net *, const struct nlattr *,
+		       const struct sw_flow_key *, struct sw_flow_actions **,
+		       bool log);
+int ovs_ct_action_to_attr(const struct ovs_conntrack_info *, struct sk_buff *);
+
+int ovs_ct_execute(struct sk_buff *, struct sw_flow_key *,
+		   const struct ovs_conntrack_info *);
+
+u8 ovs_ct_get_state(const struct sk_buff *skb);
+u16 ovs_ct_get_zone(const struct sk_buff *skb);
+bool ovs_ct_state_valid(const struct sw_flow_key *key);
+void ovs_ct_free_acts(struct sw_flow_actions *sf_acts);
+#else
+#include <linux/errno.h>
+
+static inline int ovs_ct_copy_action(struct net *net, const struct nlattr *nla,
+				     const struct sw_flow_key *key,
+				     struct sw_flow_actions **acts, bool log)
+{
+	return -ENOTSUPP;
+}
+
+static inline int ovs_ct_action_to_attr(const struct ovs_conntrack_info *info,
+					struct sk_buff *skb)
+{
+	return -ENOTSUPP;
+}
+
+static inline int ovs_ct_execute(struct sk_buff *skb, struct sw_flow_key *key,
+				 const struct ovs_conntrack_info *info)
+{
+	return -ENOTSUPP;
+}
+
+static inline u8 ovs_ct_get_state(const struct sk_buff *skb)
+{
+	return 0;
+}
+
+static inline u16 ovs_ct_get_zone(const struct sk_buff *skb)
+{
+	return 0;
+}
+
+static inline bool ovs_ct_state_valid(const struct sw_flow_key *key)
+{
+	return false;
+}
+
+static inline void ovs_ct_free_acts(struct sw_flow_actions *sf_acts) { }
+#endif
+#endif /* ovs_conntrack.h */
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index c8c60c5..46f67ee 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -519,6 +519,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	struct sk_buff *packet;
 	struct sw_flow *flow;
 	struct sw_flow_actions *sf_acts;
+	struct net *net = sock_net(skb->sk);
 	struct datapath *dp;
 	struct ethhdr *eth;
 	struct vport *input_vport;
@@ -562,7 +563,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto err_flow_free;
 
-	err = ovs_nla_copy_actions(a[OVS_PACKET_ATTR_ACTIONS],
+	err = ovs_nla_copy_actions(net, a[OVS_PACKET_ATTR_ACTIONS],
 				   &flow->key, &acts, log);
 	if (err)
 		goto err_flow_free;
@@ -867,6 +868,7 @@ static struct sk_buff *ovs_flow_cmd_build_info(const struct sw_flow *flow,
 
 static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 {
+	struct net *net = sock_net(skb->sk);
 	struct nlattr **a = info->attrs;
 	struct ovs_header *ovs_header = info->userhdr;
 	struct sw_flow *flow = NULL, *new_flow;
@@ -916,8 +918,8 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		goto err_kfree_flow;
 
 	/* Validate actions. */
-	error = ovs_nla_copy_actions(a[OVS_FLOW_ATTR_ACTIONS], &new_flow->key,
-				     &acts, log);
+	error = ovs_nla_copy_actions(net, a[OVS_FLOW_ATTR_ACTIONS],
+				     &new_flow->key, &acts, log);
 	if (error) {
 		OVS_NLERR(log, "Flow actions may not be safe on all matching packets.");
 		goto err_kfree_flow;
@@ -1025,7 +1027,8 @@ error:
 }
 
 /* Factor out action copy to avoid "Wframe-larger-than=1024" warning. */
-static struct sw_flow_actions *get_flow_actions(const struct nlattr *a,
+static struct sw_flow_actions *get_flow_actions(struct net *net,
+						const struct nlattr *a,
 						const struct sw_flow_key *key,
 						const struct sw_flow_mask *mask,
 						bool log)
@@ -1035,7 +1038,7 @@ static struct sw_flow_actions *get_flow_actions(const struct nlattr *a,
 	int error;
 
 	ovs_flow_mask_key(&masked_key, key, mask);
-	error = ovs_nla_copy_actions(a, &masked_key, &acts, log);
+	error = ovs_nla_copy_actions(net, a, &masked_key, &acts, log);
 	if (error) {
 		OVS_NLERR(log,
 			  "Actions may not be safe on all matching packets");
@@ -1047,6 +1050,7 @@ static struct sw_flow_actions *get_flow_actions(const struct nlattr *a,
 
 static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 {
+	struct net *net = sock_net(skb->sk);
 	struct nlattr **a = info->attrs;
 	struct ovs_header *ovs_header = info->userhdr;
 	struct sw_flow_key key;
@@ -1078,8 +1082,8 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 
 	/* Validate actions. */
 	if (a[OVS_FLOW_ATTR_ACTIONS]) {
-		acts = get_flow_actions(a[OVS_FLOW_ATTR_ACTIONS], &key, &mask,
-					log);
+		acts = get_flow_actions(net, a[OVS_FLOW_ATTR_ACTIONS], &key,
+					&mask, log);
 		if (IS_ERR(acts)) {
 			error = PTR_ERR(acts);
 			goto error;
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index e2c348b..c8544f5 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -49,6 +49,7 @@
 #include "datapath.h"
 #include "flow.h"
 #include "flow_netlink.h"
+#include "conntrack.h"
 
 u64 ovs_flow_used_time(unsigned long flow_jiffies)
 {
@@ -705,6 +706,8 @@ int ovs_flow_key_extract(const struct ovs_tunnel_info *tun_info,
 	key->phy.priority = skb->priority;
 	key->phy.in_port = OVS_CB(skb)->input_vport->port_no;
 	key->phy.skb_mark = skb->mark;
+	key->phy.conn_state = ovs_ct_get_state(skb);
+	key->phy.conn_zone = ovs_ct_get_zone(skb);
 	key->ovs_flow_hash = 0;
 	key->recirc_id = 0;
 
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 998401a..ad3779a 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -127,6 +127,8 @@ struct sw_flow_key {
 		u32	priority;	/* Packet QoS priority. */
 		u32	skb_mark;	/* SKB mark. */
 		u16	in_port;	/* Input switch port (or DP_MAX_PORTS). */
+		u16	conn_zone;	/* Conntrack zone. */
+		u8	conn_state;	/* Connection state. */
 	} __packed phy; /* Safe when right after 'tun_key'. */
 	u32 ovs_flow_hash;		/* Datapath computed hash value.  */
 	u32 recirc_id;			/* Recirculation ID.  */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 4d9eecf..4c668c7 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -49,6 +49,7 @@
 #include <net/mpls.h>
 
 #include "flow_netlink.h"
+#include "conntrack.h"
 #include "vport-vxlan.h"
 
 struct ovs_len_tbl {
@@ -281,7 +282,7 @@ size_t ovs_key_attr_size(void)
 	/* Whenever adding new OVS_KEY_ FIELDS, we should consider
 	 * updating this function.
 	 */
-	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 22);
+	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 24);
 
 	return    nla_total_size(4)   /* OVS_KEY_ATTR_PRIORITY */
 		+ nla_total_size(0)   /* OVS_KEY_ATTR_TUNNEL */
@@ -290,6 +291,8 @@ size_t ovs_key_attr_size(void)
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_SKB_MARK */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_DP_HASH */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_RECIRC_ID */
+		+ nla_total_size(1)   /* OVS_KEY_ATTR_CONN_STATE */
+		+ nla_total_size(2)   /* OVS_KEY_ATTR_CONN_ZONE */
 		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
 		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_VLAN */
@@ -339,6 +342,8 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_TUNNEL]	 = { .len = OVS_ATTR_NESTED,
 				     .next = ovs_tunnel_key_lens, },
 	[OVS_KEY_ATTR_MPLS]	 = { .len = sizeof(struct ovs_key_mpls) },
+	[OVS_KEY_ATTR_CONN_STATE] = { .len = sizeof(u8) },
+	[OVS_KEY_ATTR_CONN_ZONE] = { .len = sizeof(u16) },
 };
 
 static bool is_all_zero(const u8 *fp, size_t size)
@@ -766,6 +771,19 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 			return -EINVAL;
 		*attrs &= ~(1 << OVS_KEY_ATTR_TUNNEL);
 	}
+
+	if (*attrs & (1ULL << OVS_KEY_ATTR_CONN_STATE)) {
+		uint8_t conn_state = nla_get_u8(a[OVS_KEY_ATTR_CONN_STATE]);
+
+		SW_FLOW_KEY_PUT(match, phy.conn_state, conn_state, is_mask);
+		*attrs &= ~(1ULL << OVS_KEY_ATTR_CONN_STATE);
+	}
+	if (*attrs & (1ULL << OVS_KEY_ATTR_CONN_ZONE)) {
+		uint16_t conn_zone = nla_get_u16(a[OVS_KEY_ATTR_CONN_ZONE]);
+
+		SW_FLOW_KEY_PUT(match, phy.conn_zone, conn_zone, is_mask);
+		*attrs &= ~(1ULL << OVS_KEY_ATTR_CONN_ZONE);
+	}
 	return 0;
 }
 
@@ -1312,6 +1330,12 @@ static int __ovs_nla_put_key(const struct sw_flow_key *swkey,
 	if (nla_put_u32(skb, OVS_KEY_ATTR_SKB_MARK, output->phy.skb_mark))
 		goto nla_put_failure;
 
+	if (nla_put_u8(skb, OVS_KEY_ATTR_CONN_STATE, output->phy.conn_state))
+		goto nla_put_failure;
+
+	if (nla_put_u16(skb, OVS_KEY_ATTR_CONN_ZONE, output->phy.conn_zone))
+		goto nla_put_failure;
+
 	nla = nla_reserve(skb, OVS_KEY_ATTR_ETHERNET, sizeof(*eth_key));
 	if (!nla)
 		goto nla_put_failure;
@@ -1547,11 +1571,21 @@ static struct sw_flow_actions *nla_alloc_flow_actions(int size, bool log)
 	return sfa;
 }
 
+/* RCU callback used by ovs_nla_free_flow_actions. */
+static void rcu_free_acts_callback(struct rcu_head *rcu)
+{
+	struct sw_flow_actions *sf_acts = container_of(rcu,
+			struct sw_flow_actions, rcu);
+
+	ovs_ct_free_acts(sf_acts);
+	kfree(sf_acts);
+}
+
 /* Schedules 'sf_acts' to be freed after the next RCU grace period.
  * The caller must hold rcu_read_lock for this to be sensible. */
 void ovs_nla_free_flow_actions(struct sw_flow_actions *sf_acts)
 {
-	kfree_rcu(sf_acts, rcu);
+	call_rcu(&sf_acts->rcu, rcu_free_acts_callback);
 }
 
 static struct nlattr *reserve_sfa_size(struct sw_flow_actions **sfa,
@@ -1608,8 +1642,8 @@ static struct nlattr *__add_action(struct sw_flow_actions **sfa,
 	return a;
 }
 
-static int add_action(struct sw_flow_actions **sfa, int attrtype,
-		      void *data, int len, bool log)
+int ovs_nla_add_action(struct sw_flow_actions **sfa, int attrtype, void *data,
+		       int len, bool log)
 {
 	struct nlattr *a;
 
@@ -1624,7 +1658,7 @@ static inline int add_nested_action_start(struct sw_flow_actions **sfa,
 	int used = (*sfa)->actions_len;
 	int err;
 
-	err = add_action(sfa, attrtype, NULL, 0, log);
+	err = ovs_nla_add_action(sfa, attrtype, NULL, 0, log);
 	if (err)
 		return err;
 
@@ -1640,12 +1674,12 @@ static inline void add_nested_action_end(struct sw_flow_actions *sfa,
 	a->nla_len = sfa->actions_len - st_offset;
 }
 
-static int __ovs_nla_copy_actions(const struct nlattr *attr,
+static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 				  const struct sw_flow_key *key,
 				  int depth, struct sw_flow_actions **sfa,
 				  __be16 eth_type, __be16 vlan_tci, bool log);
 
-static int validate_and_copy_sample(const struct nlattr *attr,
+static int validate_and_copy_sample(struct net *net, const struct nlattr *attr,
 				    const struct sw_flow_key *key, int depth,
 				    struct sw_flow_actions **sfa,
 				    __be16 eth_type, __be16 vlan_tci, bool log)
@@ -1677,15 +1711,15 @@ static int validate_and_copy_sample(const struct nlattr *attr,
 	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SAMPLE, log);
 	if (start < 0)
 		return start;
-	err = add_action(sfa, OVS_SAMPLE_ATTR_PROBABILITY,
-			 nla_data(probability), sizeof(u32), log);
+	err = ovs_nla_add_action(sfa, OVS_SAMPLE_ATTR_PROBABILITY,
+				 nla_data(probability), sizeof(u32), log);
 	if (err)
 		return err;
 	st_acts = add_nested_action_start(sfa, OVS_SAMPLE_ATTR_ACTIONS, log);
 	if (st_acts < 0)
 		return st_acts;
 
-	err = __ovs_nla_copy_actions(actions, key, depth + 1, sfa,
+	err = __ovs_nla_copy_actions(net, actions, key, depth + 1, sfa,
 				     eth_type, vlan_tci, log);
 	if (err)
 		return err;
@@ -2007,7 +2041,7 @@ static int copy_action(const struct nlattr *from,
 	return 0;
 }
 
-static int __ovs_nla_copy_actions(const struct nlattr *attr,
+static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 				  const struct sw_flow_key *key,
 				  int depth, struct sw_flow_actions **sfa,
 				  __be16 eth_type, __be16 vlan_tci, bool log)
@@ -2031,7 +2065,8 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 			[OVS_ACTION_ATTR_SET] = (u32)-1,
 			[OVS_ACTION_ATTR_SET_MASKED] = (u32)-1,
 			[OVS_ACTION_ATTR_SAMPLE] = (u32)-1,
-			[OVS_ACTION_ATTR_HASH] = sizeof(struct ovs_action_hash)
+			[OVS_ACTION_ATTR_HASH] = sizeof(struct ovs_action_hash),
+			[OVS_ACTION_ATTR_CT] = (u32)-1,
 		};
 		const struct ovs_action_push_vlan *vlan;
 		int type = nla_type(a);
@@ -2138,13 +2173,20 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 			break;
 
 		case OVS_ACTION_ATTR_SAMPLE:
-			err = validate_and_copy_sample(a, key, depth, sfa,
+			err = validate_and_copy_sample(net, a, key, depth, sfa,
 						       eth_type, vlan_tci, log);
 			if (err)
 				return err;
 			skip_copy = true;
 			break;
 
+		case OVS_ACTION_ATTR_CT:
+			err = ovs_ct_copy_action(net, a, key, sfa, log);
+			if (err)
+				return err;
+			skip_copy = true;
+			break;
+
 		default:
 			OVS_NLERR(log, "Unknown Action type %d", type);
 			return -EINVAL;
@@ -2163,7 +2205,7 @@ static int __ovs_nla_copy_actions(const struct nlattr *attr,
 }
 
 /* 'key' must be the masked key. */
-int ovs_nla_copy_actions(const struct nlattr *attr,
+int ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			 const struct sw_flow_key *key,
 			 struct sw_flow_actions **sfa, bool log)
 {
@@ -2173,7 +2215,7 @@ int ovs_nla_copy_actions(const struct nlattr *attr,
 	if (IS_ERR(*sfa))
 		return PTR_ERR(*sfa);
 
-	err = __ovs_nla_copy_actions(attr, key, 0, sfa, key->eth.type,
+	err = __ovs_nla_copy_actions(net, attr, key, 0, sfa, key->eth.type,
 				     key->eth.tci, log);
 	if (err)
 		kfree(*sfa);
@@ -2291,6 +2333,13 @@ int ovs_nla_put_actions(const struct nlattr *attr, int len, struct sk_buff *skb)
 			if (err)
 				return err;
 			break;
+
+		case OVS_ACTION_ATTR_CT:
+			err = ovs_ct_action_to_attr(nla_data(a), skb);
+			if (err)
+				return err;
+			break;
+
 		default:
 			if (nla_put(skb, type, nla_len(a), nla_data(a)))
 				return -EMSGSIZE;
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index 5c3d75b..f699dca1 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -62,9 +62,11 @@ int ovs_nla_get_identifier(struct sw_flow_id *sfid, const struct nlattr *ufid,
 			   const struct sw_flow_key *key, bool log);
 u32 ovs_nla_get_ufid_flags(const struct nlattr *attr);
 
-int ovs_nla_copy_actions(const struct nlattr *attr,
+int ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			 const struct sw_flow_key *key,
 			 struct sw_flow_actions **sfa, bool log);
+int ovs_nla_add_action(struct sw_flow_actions **sfa, int attrtype,
+		       void *data, int len, bool log);
 int ovs_nla_put_actions(const struct nlattr *attr,
 			int len, struct sk_buff *skb);
 
-- 
1.7.10.4
