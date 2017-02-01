From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2 4/5] bridge: per vlan dst_metadata netlink support
Date: Tue, 31 Jan 2017 22:59:54 -0800
Message-ID: <1485932395-58422-5-git-send-email-roopa@cumulusnetworks.com>
References: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
        nikolay@cumulusnetworks.com, tgraf@suug.ch,
        hannes@stressinduktion.org, jbenc@redhat.com, pshelar@ovn.org,
        dsa@cumulusnetworks.com, hadi@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:33395 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751273AbdBAHAG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 02:00:06 -0500
Received: by mail-pg0-f53.google.com with SMTP id 204so106935506pge.0
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 23:00:05 -0800 (PST)
In-Reply-To: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support to attach per vlan tunnel info dst
metadata. This enables bridge driver to map vlan to tunnel_info
at ingress and egress. It uses the kernel dst_metadata infrastructure.

The initial use case is vlan to vni bridging, but the api is generic
to extend to any tunnel_info in the future:
    - Uapi to configure/unconfigure/dump per vlan tunnel data
    - netlink functions to configure vlan and tunnel_info mapping
    - Introduces bridge port flag BR_LWT_VLAN to enable attach/detach
    dst_metadata to bridged packets on ports. off by default.
    - changes to existing code is mainly refactor some existing vlan
    handling netlink code + hooks for new vlan tunnel code
    - I have kept the vlan tunnel code isolated in separate files.
    - most of the netlink vlan tunnel code is handling of vlan-tunid
    ranges (follows the vlan range handling code). To conserve space
    vlan-tunid by default are always dumped in ranges if applicable.

Use case:
example use for this is a vxlan bridging gateway or vtep
which maps vlans to vn-segments (or vnis).

iproute2 example (patched and pruned iproute2 output to just show
relevant fdb entries):
example shows same host mac learnt on two vni's and
vlan 100 maps to vni 1000, vlan 101 maps to vni 1001

before (netdev per vni):
$bridge fdb show | grep "00:02:00:00:00:03"
00:02:00:00:00:03 dev vxlan1001 vlan 101 master bridge
00:02:00:00:00:03 dev vxlan1001 dst 12.0.0.8 self
00:02:00:00:00:03 dev vxlan1000 vlan 100 master bridge
00:02:00:00:00:03 dev vxlan1000 dst 12.0.0.8 self

after this patch with collect metdata in bridged mode (single netdev):
$bridge fdb show | grep "00:02:00:00:00:03"
00:02:00:00:00:03 dev vxlan0 vlan 101 master bridge
00:02:00:00:00:03 dev vxlan0 src_vni 1001 dst 12.0.0.8 self
00:02:00:00:00:03 dev vxlan0 vlan 100 master bridge
00:02:00:00:00:03 dev vxlan0 src_vni 1000 dst 12.0.0.8 self

CC: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/Makefile            |    5 +-
 net/bridge/br_netlink.c        |  140 +++++++++++++------
 net/bridge/br_netlink_tunnel.c |  296 ++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_private.h        |   10 ++
 net/bridge/br_private_tunnel.h |   72 ++++++++++
 net/bridge/br_vlan.c           |   17 ++-
 net/bridge/br_vlan_tunnel.c    |  149 ++++++++++++++++++++
 7 files changed, 641 insertions(+), 48 deletions(-)
 create mode 100644 net/bridge/br_netlink_tunnel.c
 create mode 100644 net/bridge/br_private_tunnel.h
 create mode 100644 net/bridge/br_vlan_tunnel.c

diff --git a/net/bridge/Makefile b/net/bridge/Makefile
index 0aefc01..40b1ede 100644
--- a/net/bridge/Makefile
+++ b/net/bridge/Makefile
@@ -6,7 +6,8 @@ obj-$(CONFIG_BRIDGE) += bridge.o
 
 bridge-y	:= br.o br_device.o br_fdb.o br_forward.o br_if.o br_input.o \
 			br_ioctl.o br_stp.o br_stp_bpdu.o \
-			br_stp_if.o br_stp_timer.o br_netlink.o
+			br_stp_if.o br_stp_timer.o br_netlink.o \
+			br_netlink_tunnel.o
 
 bridge-$(CONFIG_SYSFS) += br_sysfs_if.o br_sysfs_br.o
 
@@ -18,7 +19,7 @@ obj-$(CONFIG_BRIDGE_NETFILTER) += br_netfilter.o
 
 bridge-$(CONFIG_BRIDGE_IGMP_SNOOPING) += br_multicast.o br_mdb.o
 
-bridge-$(CONFIG_BRIDGE_VLAN_FILTERING) += br_vlan.o
+bridge-$(CONFIG_BRIDGE_VLAN_FILTERING) += br_vlan.o br_vlan_tunnel.o
 
 bridge-$(CONFIG_NET_SWITCHDEV) += br_switchdev.o
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 6c087cd..6dbfc2f 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -20,6 +20,7 @@
 
 #include "br_private.h"
 #include "br_private_stp.h"
+#include "br_private_tunnel.h"
 
 static int __get_num_vlan_infos(struct net_bridge_vlan_group *vg,
 				u32 filter_mask)
@@ -95,9 +96,10 @@ static size_t br_get_link_af_size_filtered(const struct net_device *dev,
 					   u32 filter_mask)
 {
 	struct net_bridge_vlan_group *vg = NULL;
-	struct net_bridge_port *p;
+	struct net_bridge_port *p = NULL;
 	struct net_bridge *br;
 	int num_vlan_infos;
+	size_t vinfo_sz = 0;
 
 	rcu_read_lock();
 	if (br_port_exists(dev)) {
@@ -110,8 +112,13 @@ static size_t br_get_link_af_size_filtered(const struct net_device *dev,
 	num_vlan_infos = br_get_num_vlan_infos(vg, filter_mask);
 	rcu_read_unlock();
 
+	if (p && (p->flags & BR_VLAN_TUNNEL))
+		vinfo_sz += br_get_vlan_tunnel_info_size(vg);
+
 	/* Each VLAN is returned in bridge_vlan_info along with flags */
-	return num_vlan_infos * nla_total_size(sizeof(struct bridge_vlan_info));
+	vinfo_sz += num_vlan_infos * nla_total_size(sizeof(struct bridge_vlan_info));
+
+	return vinfo_sz;
 }
 
 static inline size_t br_port_info_size(void)
@@ -128,6 +135,7 @@ static inline size_t br_port_info_size(void)
 		+ nla_total_size(1)	/* IFLA_BRPORT_UNICAST_FLOOD */
 		+ nla_total_size(1)	/* IFLA_BRPORT_PROXYARP */
 		+ nla_total_size(1)	/* IFLA_BRPORT_PROXYARP_WIFI */
+		+ nla_total_size(1)	/* IFLA_BRPORT_VLAN_TUNNEL */
 		+ nla_total_size(sizeof(struct ifla_bridge_id))	/* IFLA_BRPORT_ROOT_ID */
 		+ nla_total_size(sizeof(struct ifla_bridge_id))	/* IFLA_BRPORT_BRIDGE_ID */
 		+ nla_total_size(sizeof(u16))	/* IFLA_BRPORT_DESIGNATED_PORT */
@@ -194,7 +202,9 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	    nla_put_u16(skb, IFLA_BRPORT_NO, p->port_no) ||
 	    nla_put_u8(skb, IFLA_BRPORT_TOPOLOGY_CHANGE_ACK,
 		       p->topology_change_ack) ||
-	    nla_put_u8(skb, IFLA_BRPORT_CONFIG_PENDING, p->config_pending))
+	    nla_put_u8(skb, IFLA_BRPORT_CONFIG_PENDING, p->config_pending) ||
+	    nla_put_u8(skb, IFLA_BRPORT_VLAN_TUNNEL, !!(p->flags &
+							BR_VLAN_TUNNEL)))
 		return -EMSGSIZE;
 
 	timerval = br_timer_value(&p->message_age_timer);
@@ -417,6 +427,9 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 			err = br_fill_ifvlaninfo_compressed(skb, vg);
 		else
 			err = br_fill_ifvlaninfo(skb, vg);
+
+		if (port && (port->flags & BR_VLAN_TUNNEL))
+			err = br_fill_vlan_tunnel_info(skb, vg);
 		rcu_read_unlock();
 		if (err)
 			goto nla_put_failure;
@@ -517,60 +530,91 @@ static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
 	return err;
 }
 
+static int br_process_vlan_info(struct net_bridge *br,
+				struct net_bridge_port *p, int cmd,
+				struct bridge_vlan_info *vinfo_curr,
+				struct bridge_vlan_info **vinfo_last)
+{
+	if (!vinfo_curr->vid || vinfo_curr->vid >= VLAN_VID_MASK)
+		return -EINVAL;
+
+	if (vinfo_curr->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
+		/* check if we are already processing a range */
+		if (*vinfo_last)
+			return -EINVAL;
+		*vinfo_last = vinfo_curr;
+		/* don't allow range of pvids */
+		if ((*vinfo_last)->flags & BRIDGE_VLAN_INFO_PVID)
+			return -EINVAL;
+		return 0;
+	}
+
+	if (*vinfo_last) {
+		struct bridge_vlan_info tmp_vinfo;
+		int v, err;
+
+		if (!(vinfo_curr->flags & BRIDGE_VLAN_INFO_RANGE_END))
+			return -EINVAL;
+
+		if (vinfo_curr->vid <= (*vinfo_last)->vid)
+			return -EINVAL;
+
+		memcpy(&tmp_vinfo, *vinfo_last,
+		       sizeof(struct bridge_vlan_info));
+		for (v = (*vinfo_last)->vid; v <= vinfo_curr->vid; v++) {
+			tmp_vinfo.vid = v;
+			err = br_vlan_info(br, p, cmd, &tmp_vinfo);
+			if (err)
+				break;
+		}
+		*vinfo_last = NULL;
+
+		return 0;
+	}
+
+	return br_vlan_info(br, p, cmd, vinfo_curr);
+}
+
 static int br_afspec(struct net_bridge *br,
 		     struct net_bridge_port *p,
 		     struct nlattr *af_spec,
 		     int cmd)
 {
-	struct bridge_vlan_info *vinfo_start = NULL;
-	struct bridge_vlan_info *vinfo = NULL;
+	struct bridge_vlan_info *vinfo_curr = NULL;
+	struct bridge_vlan_info *vinfo_last = NULL;
 	struct nlattr *attr;
-	int err = 0;
-	int rem;
+	struct vtunnel_info tinfo_last = {};
+	struct vtunnel_info tinfo_curr = {};
+	int err = 0, rem;
 
 	nla_for_each_nested(attr, af_spec, rem) {
-		if (nla_type(attr) != IFLA_BRIDGE_VLAN_INFO)
-			continue;
-		if (nla_len(attr) != sizeof(struct bridge_vlan_info))
-			return -EINVAL;
-		vinfo = nla_data(attr);
-		if (!vinfo->vid || vinfo->vid >= VLAN_VID_MASK)
-			return -EINVAL;
-		if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
-			if (vinfo_start)
+		err = 0;
+		switch (nla_type(attr)) {
+		case IFLA_BRIDGE_VLAN_TUNNEL_INFO:
+			if (!(p->flags & BR_VLAN_TUNNEL))
 				return -EINVAL;
-			vinfo_start = vinfo;
-			/* don't allow range of pvids */
-			if (vinfo_start->flags & BRIDGE_VLAN_INFO_PVID)
+			err = br_parse_vlan_tunnel_info(attr, &tinfo_curr);
+			if (err)
+				return err;
+			err = br_process_vlan_tunnel_info(br, p, cmd,
+							  &tinfo_curr,
+							  &tinfo_last);
+			if (err)
+				return err;
+			break;
+		case IFLA_BRIDGE_VLAN_INFO:
+			if (nla_len(attr) != sizeof(struct bridge_vlan_info))
 				return -EINVAL;
-			continue;
+			vinfo_curr = nla_data(attr);
+			err = br_process_vlan_info(br, p, cmd, vinfo_curr,
+						   &vinfo_last);
+			if (err)
+				return err;
+			break;
 		}
 
-		if (vinfo_start) {
-			struct bridge_vlan_info tmp_vinfo;
-			int v;
-
-			if (!(vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END))
-				return -EINVAL;
-
-			if (vinfo->vid <= vinfo_start->vid)
-				return -EINVAL;
-
-			memcpy(&tmp_vinfo, vinfo_start,
-			       sizeof(struct bridge_vlan_info));
-
-			for (v = vinfo_start->vid; v <= vinfo->vid; v++) {
-				tmp_vinfo.vid = v;
-				err = br_vlan_info(br, p, cmd, &tmp_vinfo);
-				if (err)
-					break;
-			}
-			vinfo_start = NULL;
-		} else {
-			err = br_vlan_info(br, p, cmd, vinfo);
-		}
 		if (err)
-			break;
+			return err;
 	}
 
 	return err;
@@ -630,8 +674,9 @@ static void br_set_port_flag(struct net_bridge_port *p, struct nlattr *tb[],
 /* Process bridge protocol info on port */
 static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 {
-	int err;
 	unsigned long old_flags = p->flags;
+	bool br_vlan_tunnel_old = false;
+	int err;
 
 	br_set_port_flag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
 	br_set_port_flag(p, tb, IFLA_BRPORT_GUARD, BR_BPDU_GUARD);
@@ -644,6 +689,11 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP, BR_PROXYARP);
 	br_set_port_flag(p, tb, IFLA_BRPORT_PROXYARP_WIFI, BR_PROXYARP_WIFI);
 
+	br_vlan_tunnel_old = (p->flags & BR_VLAN_TUNNEL) ? true : false;
+	br_set_port_flag(p, tb, IFLA_BRPORT_VLAN_TUNNEL, BR_VLAN_TUNNEL);
+	if (br_vlan_tunnel_old && !(p->flags & BR_VLAN_TUNNEL))
+		nbp_vlan_tunnel_info_flush(p);
+
 	if (tb[IFLA_BRPORT_COST]) {
 		err = br_stp_set_path_cost(p, nla_get_u32(tb[IFLA_BRPORT_COST]));
 		if (err)
diff --git a/net/bridge/br_netlink_tunnel.c b/net/bridge/br_netlink_tunnel.c
new file mode 100644
index 0000000..99c6801
--- /dev/null
+++ b/net/bridge/br_netlink_tunnel.c
@@ -0,0 +1,296 @@
+/*
+ *	Bridge per vlan tunnel port dst_metadata netlink control interface
+ *
+ *	Authors:
+ *	Roopa Prabhu		<roopa@cumulusnetworks.com>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/etherdevice.h>
+#include <net/rtnetlink.h>
+#include <net/net_namespace.h>
+#include <net/sock.h>
+#include <uapi/linux/if_bridge.h>
+#include <net/dst_metadata.h>
+
+#include "br_private.h"
+#include "br_private_tunnel.h"
+
+static size_t __get_vlan_tinfo_size(void)
+{
+	return nla_total_size(0) + /* nest IFLA_BRIDGE_VLAN_TUNNEL_INFO */
+		  nla_total_size(sizeof(u32)) + /* IFLA_BRIDGE_VLAN_TUNNEL_ID */
+		  nla_total_size(sizeof(u16)) + /* IFLA_BRIDGE_VLAN_TUNNEL_VID */
+		  nla_total_size(sizeof(u16)); /* IFLA_BRIDGE_VLAN_TUNNEL_FLAGS */
+}
+
+static bool vlan_tunnel_id_isrange(struct net_bridge_vlan *v,
+				   struct net_bridge_vlan *v_end)
+{
+	__be32 tunid_curr = tunnel_id_to_key32(v->tinfo.tunnel_id);
+	__be32 tunid_end = tunnel_id_to_key32(v_end->tinfo.tunnel_id);
+
+	return (be32_to_cpu(tunid_curr) - be32_to_cpu(tunid_end)) == 1;
+}
+
+static int __get_num_vlan_tunnel_infos(struct net_bridge_vlan_group *vg)
+{
+	struct net_bridge_vlan *v, *v_start = NULL, *v_end = NULL;
+	int num_tinfos = 0;
+
+	/* Count number of vlan infos */
+	list_for_each_entry_rcu(v, &vg->vlan_list, vlist) {
+		/* only a context, bridge vlan not activated */
+		if (!br_vlan_should_use(v) || !v->tinfo.tunnel_id)
+			continue;
+
+		if (!v_start) {
+			goto initvars;
+		} else if ((v->vid - v_end->vid) == 1 &&
+			   vlan_tunnel_id_isrange(v_end, v) == 1) {
+			v_end = v;
+			continue;
+		} else {
+			if ((v_end->vid - v->vid) > 0 &&
+			    vlan_tunnel_id_isrange(v_end, v) > 0)
+				num_tinfos += 2;
+			else
+				num_tinfos += 1;
+		}
+initvars:
+		v_start = v;
+		v_end = v;
+	}
+
+	if (v_start) {
+		if ((v_end->vid - v->vid) > 0 &&
+		    vlan_tunnel_id_isrange(v_end, v) > 0)
+			num_tinfos += 2;
+		else
+			num_tinfos += 1;
+	}
+
+	return num_tinfos;
+}
+
+int br_get_vlan_tunnel_info_size(struct net_bridge_vlan_group *vg)
+{
+	int num_tinfos;
+
+	if (!vg)
+		return 0;
+
+	rcu_read_lock();
+	num_tinfos = __get_num_vlan_tunnel_infos(vg);
+	rcu_read_unlock();
+
+	return num_tinfos * __get_vlan_tinfo_size();
+}
+
+static int br_fill_vlan_tinfo(struct sk_buff *skb, u16 vid,
+			      __be64 tunnel_id, u16 flags)
+{
+	__be32 tid = tunnel_id_to_key32(tunnel_id);
+	struct nlattr *tmap;
+
+	tmap = nla_nest_start(skb, IFLA_BRIDGE_VLAN_TUNNEL_INFO);
+	if (!tmap)
+		return -EMSGSIZE;
+	if (nla_put_u32(skb, IFLA_BRIDGE_VLAN_TUNNEL_ID,
+			be32_to_cpu(tid)))
+		goto nla_put_failure;
+	if (nla_put_u16(skb, IFLA_BRIDGE_VLAN_TUNNEL_VID,
+			vid))
+		goto nla_put_failure;
+	if (nla_put_u16(skb, IFLA_BRIDGE_VLAN_TUNNEL_FLAGS,
+			flags))
+		goto nla_put_failure;
+	nla_nest_end(skb, tmap);
+
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, tmap);
+
+	return -EMSGSIZE;
+}
+
+static int br_fill_vlan_tinfo_range(struct sk_buff *skb,
+				    struct net_bridge_vlan *vtbegin,
+				    struct net_bridge_vlan *vtend)
+{
+	int err;
+
+	if (vtbegin && vtend && (vtend->vid - vtbegin->vid) > 0) {
+		/* add range to skb */
+		err = br_fill_vlan_tinfo(skb, vtbegin->vid,
+					 vtbegin->tinfo.tunnel_id,
+					 BRIDGE_VLAN_INFO_RANGE_BEGIN);
+		if (err)
+			return err;
+
+		err = br_fill_vlan_tinfo(skb, vtend->vid,
+					 vtend->tinfo.tunnel_id,
+					 BRIDGE_VLAN_INFO_RANGE_END);
+		if (err)
+			return err;
+	} else {
+		err = br_fill_vlan_tinfo(skb, vtbegin->vid,
+					 vtbegin->tinfo.tunnel_id,
+					 0);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+int br_fill_vlan_tunnel_info(struct sk_buff *skb,
+			     struct net_bridge_vlan_group *vg)
+{
+	struct net_bridge_vlan *vtbegin = NULL;
+	struct net_bridge_vlan *vtend = NULL;
+	struct net_bridge_vlan *v;
+	int err;
+
+	/* Count number of vlan infos */
+	list_for_each_entry_rcu(v, &vg->vlan_list, vlist) {
+		/* only a context, bridge vlan not activated */
+		if (!br_vlan_should_use(v))
+			continue;
+
+		if (!v->tinfo.tunnel_dst)
+			continue;
+
+		if (!vtbegin) {
+			goto initvars;
+		} else if ((v->vid - vtend->vid) == 1 &&
+			    vlan_tunnel_id_isrange(v, vtend)) {
+			vtend = v;
+			continue;
+		} else {
+			err = br_fill_vlan_tinfo_range(skb, vtbegin, vtend);
+			if (err)
+				return err;
+		}
+initvars:
+		vtbegin = v;
+		vtend = v;
+	}
+
+	if (vtbegin) {
+		err = br_fill_vlan_tinfo_range(skb, vtbegin, vtend);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static const struct nla_policy vlan_tunnel_policy[IFLA_BRIDGE_VLAN_TUNNEL_MAX + 1] = {
+	[IFLA_BRIDGE_VLAN_TUNNEL_ID] = { .type = NLA_U32 },
+	[IFLA_BRIDGE_VLAN_TUNNEL_VID] = { .type = NLA_U16 },
+	[IFLA_BRIDGE_VLAN_TUNNEL_FLAGS] = { .type = NLA_U16 },
+};
+
+static int br_vlan_tunnel_info(struct net_bridge_port *p, int cmd,
+			       u16 vid, u32 tun_id)
+{
+	int err = 0;
+
+	if (!p)
+		return -EINVAL;
+
+	switch (cmd) {
+	case RTM_SETLINK:
+		err = nbp_vlan_tunnel_info_add(p, vid, tun_id);
+		break;
+	case RTM_DELLINK:
+		nbp_vlan_tunnel_info_delete(p, vid);
+		break;
+	}
+
+	return err;
+}
+
+int br_parse_vlan_tunnel_info(struct nlattr *attr,
+			      struct vtunnel_info *tinfo)
+{
+	struct nlattr *tb[IFLA_BRIDGE_VLAN_TUNNEL_MAX + 1];
+	u32 tun_id;
+	u16 vid, flags = 0;
+	int err;
+
+	memset(tinfo, 0, sizeof(*tinfo));
+
+	if (!tb[IFLA_BRIDGE_VLAN_TUNNEL_ID] ||
+	    !tb[IFLA_BRIDGE_VLAN_TUNNEL_VID])
+		return -EINVAL;
+
+	err = nla_parse_nested(tb, IFLA_BRIDGE_VLAN_TUNNEL_MAX,
+			       attr, vlan_tunnel_policy);
+	if (err < 0)
+		return err;
+
+	tun_id = nla_get_u32(tb[IFLA_BRIDGE_VLAN_TUNNEL_ID]);
+	vid = nla_get_u16(tb[IFLA_BRIDGE_VLAN_TUNNEL_VID]);
+	if (vid >= VLAN_VID_MASK)
+		return -ERANGE;
+
+	if (tb[IFLA_BRIDGE_VLAN_TUNNEL_FLAGS])
+		flags = nla_get_u16(tb[IFLA_BRIDGE_VLAN_TUNNEL_FLAGS]);
+
+	tinfo->tunid = tun_id;
+	tinfo->vid = vid;
+	tinfo->flags = flags;
+
+	return 0;
+}
+
+int br_process_vlan_tunnel_info(struct net_bridge *br,
+				struct net_bridge_port *p, int cmd,
+				struct vtunnel_info *tinfo_curr,
+				struct vtunnel_info *tinfo_last)
+{
+	int err;
+
+	if (tinfo_curr->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
+		if (tinfo_last->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN)
+			return -EINVAL;
+		memcpy(tinfo_last, tinfo_curr, sizeof(struct vtunnel_info));
+	} else if (tinfo_curr->flags & BRIDGE_VLAN_INFO_RANGE_END) {
+		int t, v;
+
+		if (!(tinfo_last->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN))
+			return -EINVAL;
+		if ((tinfo_curr->vid - tinfo_last->vid) !=
+		    (tinfo_curr->tunid - tinfo_last->tunid))
+			return -EINVAL;
+		t = tinfo_last->tunid;
+		for (v = tinfo_last->vid; v <= tinfo_curr->vid; v++) {
+			err = br_vlan_tunnel_info(p, cmd, v, t);
+			if (err)
+				return err;
+			t++;
+		}
+		memset(tinfo_last, 0, sizeof(struct vtunnel_info));
+		memset(tinfo_curr, 0, sizeof(struct vtunnel_info));
+	} else {
+		if (tinfo_last->flags)
+			return -EINVAL;
+		err = br_vlan_tunnel_info(p, cmd, tinfo_curr->vid,
+					  tinfo_curr->tunid);
+		if (err)
+			return err;
+		memset(tinfo_last, 0, sizeof(struct vtunnel_info));
+		memset(tinfo_curr, 0, sizeof(struct vtunnel_info));
+	}
+
+	return 0;
+}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 0b82a22..61de90f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -91,6 +91,11 @@ struct br_vlan_stats {
 	struct u64_stats_sync syncp;
 };
 
+struct br_tunnel_info {
+	__be64			tunnel_id;
+	struct metadata_dst	*tunnel_dst;
+};
+
 /**
  * struct net_bridge_vlan - per-vlan entry
  *
@@ -113,6 +118,7 @@ struct br_vlan_stats {
  */
 struct net_bridge_vlan {
 	struct rhash_head		vnode;
+	struct rhash_head		tnode;
 	u16				vid;
 	u16				flags;
 	struct br_vlan_stats __percpu	*stats;
@@ -124,6 +130,9 @@ struct net_bridge_vlan {
 		atomic_t		refcnt;
 		struct net_bridge_vlan	*brvlan;
 	};
+
+	struct br_tunnel_info		tinfo;
+
 	struct list_head		vlist;
 
 	struct rcu_head			rcu;
@@ -145,6 +154,7 @@ struct net_bridge_vlan {
  */
 struct net_bridge_vlan_group {
 	struct rhashtable		vlan_hash;
+	struct rhashtable		tunnel_hash;
 	struct list_head		vlan_list;
 	u16				num_vlans;
 	u16				pvid;
diff --git a/net/bridge/br_private_tunnel.h b/net/bridge/br_private_tunnel.h
new file mode 100644
index 0000000..1c8d0d5
--- /dev/null
+++ b/net/bridge/br_private_tunnel.h
@@ -0,0 +1,72 @@
+/*
+ *	Bridge per vlan tunnels
+ *
+ *	Authors:
+ *	Roopa Prabhu		<roopa@cumulusnetworks.com>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#ifndef _BR_PRIVATE_TUNNEL_H
+#define _BR_PRIVATE_TUNNEL_H
+
+struct vtunnel_info {
+	u32	tunid;
+	u16	vid;
+	u16	flags;
+};
+
+/* br_netlink_tunnel.c */
+int br_parse_vlan_tunnel_info(struct nlattr *attr,
+			      struct vtunnel_info *tinfo);
+int br_process_vlan_tunnel_info(struct net_bridge *br,
+				struct net_bridge_port *p,
+				int cmd,
+				struct vtunnel_info *tinfo_curr,
+				struct vtunnel_info *tinfo_last);
+int br_get_vlan_tunnel_info_size(struct net_bridge_vlan_group *vg);
+int br_fill_vlan_tunnel_info(struct sk_buff *skb,
+			     struct net_bridge_vlan_group *vg);
+
+#ifdef CONFIG_BRIDGE_VLAN_FILTERING
+/* br_vlan_tunnel.c */
+int vlan_tunnel_init(struct net_bridge_vlan_group *vg);
+void vlan_tunnel_deinit(struct net_bridge_vlan_group *vg);
+int nbp_vlan_tunnel_info_delete(struct net_bridge_port *port, u16 vid);
+int nbp_vlan_tunnel_info_add(struct net_bridge_port *port, u16 vid, u32 tun_id);
+void nbp_vlan_tunnel_info_flush(struct net_bridge_port *port);
+void vlan_tunnel_info_del(struct net_bridge_vlan_group *vg,
+			  struct net_bridge_vlan *vlan);
+#else
+static inline int vlan_tunnel_init(struct net_bridge_vlan_group *vg)
+{
+	return 0;
+}
+
+static inline int nbp_vlan_tunnel_info_delete(struct net_bridge_port *port,
+					      u16 vid)
+{
+	return 0;
+}
+
+static inline int nbp_vlan_tunnel_info_add(struct net_bridge_port *port,
+					   u16 vid, u32 tun_id)
+{
+	return 0;
+}
+
+static inline void nbp_vlan_tunnel_info_flush(struct net_bridge_port *port)
+{
+}
+
+static inline void vlan_tunnel_info_del(struct net_bridge_vlan_group *vg,
+					struct net_bridge_vlan *vlan)
+{
+}
+
+#endif
+
+#endif
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index b6de4f4..64002e3 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -5,6 +5,7 @@
 #include <net/switchdev.h>
 
 #include "br_private.h"
+#include "br_private_tunnel.h"
 
 static inline int br_vlan_cmp(struct rhashtable_compare_arg *arg,
 			      const void *ptr)
@@ -310,6 +311,7 @@ static int __vlan_del(struct net_bridge_vlan *v)
 	}
 
 	if (masterv != v) {
+		vlan_tunnel_info_del(vg, v);
 		rhashtable_remove_fast(&vg->vlan_hash, &v->vnode,
 				       br_vlan_rht_params);
 		__vlan_del_list(v);
@@ -325,6 +327,7 @@ static void __vlan_group_free(struct net_bridge_vlan_group *vg)
 {
 	WARN_ON(!list_empty(&vg->vlan_list));
 	rhashtable_destroy(&vg->vlan_hash);
+	vlan_tunnel_deinit(vg);
 	kfree(vg);
 }
 
@@ -613,6 +616,8 @@ int br_vlan_delete(struct net_bridge *br, u16 vid)
 	br_fdb_find_delete_local(br, NULL, br->dev->dev_addr, vid);
 	br_fdb_delete_by_port(br, NULL, vid, 0);
 
+	vlan_tunnel_info_del(vg, v);
+
 	return __vlan_del(v);
 }
 
@@ -918,6 +923,9 @@ int br_vlan_init(struct net_bridge *br)
 	ret = rhashtable_init(&vg->vlan_hash, &br_vlan_rht_params);
 	if (ret)
 		goto err_rhtbl;
+	ret = vlan_tunnel_init(vg);
+	if (ret)
+		goto err_tunnel_init;
 	INIT_LIST_HEAD(&vg->vlan_list);
 	br->vlan_proto = htons(ETH_P_8021Q);
 	br->default_pvid = 1;
@@ -932,6 +940,8 @@ int br_vlan_init(struct net_bridge *br)
 	return ret;
 
 err_vlan_add:
+	vlan_tunnel_deinit(vg);
+err_tunnel_init:
 	rhashtable_destroy(&vg->vlan_hash);
 err_rhtbl:
 	kfree(vg);
@@ -961,6 +971,9 @@ int nbp_vlan_init(struct net_bridge_port *p)
 	ret = rhashtable_init(&vg->vlan_hash, &br_vlan_rht_params);
 	if (ret)
 		goto err_rhtbl;
+	ret = vlan_tunnel_init(vg);
+	if (ret)
+		goto err_tunnel_init;
 	INIT_LIST_HEAD(&vg->vlan_list);
 	rcu_assign_pointer(p->vlgrp, vg);
 	if (p->br->default_pvid) {
@@ -976,8 +989,10 @@ int nbp_vlan_init(struct net_bridge_port *p)
 err_vlan_add:
 	RCU_INIT_POINTER(p->vlgrp, NULL);
 	synchronize_rcu();
-	rhashtable_destroy(&vg->vlan_hash);
+	vlan_tunnel_deinit(vg);
 err_vlan_enabled:
+err_tunnel_init:
+	rhashtable_destroy(&vg->vlan_hash);
 err_rhtbl:
 	kfree(vg);
 
diff --git a/net/bridge/br_vlan_tunnel.c b/net/bridge/br_vlan_tunnel.c
new file mode 100644
index 0000000..b3fd29d
--- /dev/null
+++ b/net/bridge/br_vlan_tunnel.c
@@ -0,0 +1,149 @@
+/*
+ *	Bridge per vlan tunnel port dst_metadata handling code
+ *
+ *	Authors:
+ *	Roopa Prabhu		<roopa@cumulusnetworks.com>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
+#include <linux/slab.h>
+#include <net/switchdev.h>
+#include <net/dst_metadata.h>
+
+#include "br_private.h"
+#include "br_private_tunnel.h"
+
+static inline int br_vlan_tunid_cmp(struct rhashtable_compare_arg *arg,
+				    const void *ptr)
+{
+	const struct net_bridge_vlan *vle = ptr;
+	__be64 tunid = *(__be64 *)arg->key;
+
+	return vle->tinfo.tunnel_id != tunid;
+}
+
+static const struct rhashtable_params br_vlan_tunnel_rht_params = {
+	.head_offset = offsetof(struct net_bridge_vlan, tnode),
+	.key_offset = offsetof(struct net_bridge_vlan, tinfo.tunnel_id),
+	.key_len = sizeof(__be64),
+	.nelem_hint = 3,
+	.locks_mul = 1,
+	.obj_cmpfn = br_vlan_tunid_cmp,
+	.automatic_shrinking = true,
+};
+
+void vlan_tunnel_info_del(struct net_bridge_vlan_group *vg,
+			  struct net_bridge_vlan *vlan)
+{
+	if (!vlan->tinfo.tunnel_dst)
+		return;
+	rhashtable_remove_fast(&vg->tunnel_hash, &vlan->tnode,
+			       br_vlan_tunnel_rht_params);
+	vlan->tinfo.tunnel_id = 0;
+	dst_release(&vlan->tinfo.tunnel_dst->dst);
+	vlan->tinfo.tunnel_dst = NULL;
+}
+
+static int __vlan_tunnel_info_add(struct net_bridge_vlan_group *vg,
+				  struct net_bridge_vlan *vlan, u32 tun_id)
+{
+	struct metadata_dst *metadata = NULL;
+	__be64 key = key32_to_tunnel_id(cpu_to_be32(tun_id));
+	int err;
+
+	if (vlan->tinfo.tunnel_dst)
+		return -EEXIST;
+
+	metadata = __ip_tun_set_dst(0, 0, 0, 0, 0, TUNNEL_KEY,
+				    key, 0);
+	if (!metadata)
+		return -EINVAL;
+
+	metadata->u.tun_info.mode |= IP_TUNNEL_INFO_TX | IP_TUNNEL_INFO_BRIDGE;
+	vlan->tinfo.tunnel_dst = metadata;
+	vlan->tinfo.tunnel_id = key;
+
+	err = rhashtable_lookup_insert_fast(&vg->tunnel_hash, &vlan->tnode,
+					    br_vlan_tunnel_rht_params);
+	if (err)
+		goto out;
+
+	return 0;
+out:
+	dst_release(&vlan->tinfo.tunnel_dst->dst);
+
+	return err;
+}
+
+/* Must be protected by RTNL.
+ * Must be called with vid in range from 1 to 4094 inclusive.
+ */
+int nbp_vlan_tunnel_info_add(struct net_bridge_port *port, u16 vid, u32 tun_id)
+{
+	struct net_bridge_vlan_group *vg;
+	struct net_bridge_vlan *vlan;
+
+	ASSERT_RTNL();
+
+	vg = nbp_vlan_group(port);
+	vlan = br_vlan_find(vg, vid);
+	if (!vlan)
+		return -EINVAL;
+
+	return __vlan_tunnel_info_add(vg, vlan, tun_id);
+}
+
+/* Must be protected by RTNL.
+ * Must be called with vid in range from 1 to 4094 inclusive.
+ */
+int nbp_vlan_tunnel_info_delete(struct net_bridge_port *port, u16 vid)
+{
+	struct net_bridge_vlan_group *vg;
+	struct net_bridge_vlan *v;
+
+	ASSERT_RTNL();
+
+	vg = nbp_vlan_group(port);
+	v = br_vlan_find(vg, vid);
+	if (!v)
+		return -ENOENT;
+
+	vlan_tunnel_info_del(vg, v);
+
+	return 0;
+}
+
+static void __vlan_tunnel_info_flush(struct net_bridge_vlan_group *vg)
+{
+	struct net_bridge_vlan *vlan, *tmp;
+
+	list_for_each_entry_safe(vlan, tmp, &vg->vlan_list, vlist)
+		vlan_tunnel_info_del(vg, vlan);
+}
+
+void nbp_vlan_tunnel_info_flush(struct net_bridge_port *port)
+{
+	struct net_bridge_vlan_group *vg;
+
+	ASSERT_RTNL();
+
+	vg = nbp_vlan_group(port);
+	__vlan_tunnel_info_flush(vg);
+}
+
+int vlan_tunnel_init(struct net_bridge_vlan_group *vg)
+{
+	return rhashtable_init(&vg->tunnel_hash, &br_vlan_tunnel_rht_params);
+}
+
+void vlan_tunnel_deinit(struct net_bridge_vlan_group *vg)
+{
+	rhashtable_destroy(&vg->tunnel_hash);
+}
-- 
1.7.10.4
