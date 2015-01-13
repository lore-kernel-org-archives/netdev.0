From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/5] openvswitch: Support VXLAN Group Policy extension
Date: Tue, 13 Jan 2015 17:20:46 +0100
Message-ID: <b6443c1dfdb2d178d8c512ac3c8e7e80b1a86032.1421165078.git.tgraf@suug.ch>
References: <cover.1421165078.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: davem@davemloft.net, jesse@nicira.com, stephen@networkplumber.org,
	pshelar@nicira.com, therbert@google.com,
	alexei.starovoitov@gmail.com, nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:36303 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752676AbbAMQVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 11:21:10 -0500
In-Reply-To: <cover.1421165078.git.tgraf@suug.ch>
In-Reply-To: <cover.1421165078.git.tgraf@suug.ch>
References: <cover.1421165078.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduces support for the group policy extension to the VXLAN virtual
port. The extension is disabled by default and only enabled if the user
has provided the respective configuration.

  ovs-vsctl add-port br0 vxlan0 -- \
     set Interface vxlan0 type=vxlan options:exts=gbp

The configuration interface to enable the extension is based on a new
attribute OVS_VXLAN_EXT_GBP nested inside OVS_TUNNEL_ATTR_EXTENSION
which can carry additional extensions as needed in the future.

The group policy metadata is stored as binary blob (struct ovs_vxlan_opts)
internally just like Geneve options but transported as nested Netlink
attributes to user space.

Renames the existing TUNNEL_OPTIONS_PRESENT to TUNNEL_GENEVE_OPT with the
binary value kept intact, a new flag TUNNEL_VXLAN_OPT is introduced.

The attributes OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS and existing
OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS are implemented mutually exclusive.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
v3->v4:
 - Fixed OVS_VXLAN_EXT_MAX->OVS_VXLAN_EXT_GBP typo as spotted by Jesse
 - Only applied tunnel options if they are of the right type as
   suggested by Jesse
v2->v3:
 - No change
v1->v2:
 - Addressed Jesse's request to transport VXLAN options as Netlink
   attributes instead of a binary blob. Allows a partial transport of
   VXLAN extensions. Internally, the datapath continues to use a binary
   blob (defined in vport-vxlan.h) for performance reasons.
 - Added new TUNNEL_GENEVE_OPT and TUNNEL_VXLAN_OPT flags to mark
   tunnel option flavour
 - Correctly report VXLAN options to user space

 include/net/ip_tunnels.h         |   5 +-
 include/uapi/linux/openvswitch.h |  11 ++++
 net/openvswitch/flow_netlink.c   | 114 ++++++++++++++++++++++++++++++++++-----
 net/openvswitch/vport-geneve.c   |  15 ++++--
 net/openvswitch/vport-vxlan.c    |  82 +++++++++++++++++++++++++++-
 net/openvswitch/vport-vxlan.h    |  11 ++++
 6 files changed, 218 insertions(+), 20 deletions(-)
 create mode 100644 net/openvswitch/vport-vxlan.h

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 25a59eb..ce4db3c 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -97,7 +97,10 @@ struct ip_tunnel {
 #define TUNNEL_DONT_FRAGMENT    __cpu_to_be16(0x0100)
 #define TUNNEL_OAM		__cpu_to_be16(0x0200)
 #define TUNNEL_CRIT_OPT		__cpu_to_be16(0x0400)
-#define TUNNEL_OPTIONS_PRESENT	__cpu_to_be16(0x0800)
+#define TUNNEL_GENEVE_OPT	__cpu_to_be16(0x0800)
+#define TUNNEL_VXLAN_OPT	__cpu_to_be16(0x1000)
+
+#define TUNNEL_OPTIONS_PRESENT	(TUNNEL_GENEVE_OPT | TUNNEL_VXLAN_OPT)
 
 struct tnl_ptk_info {
 	__be16 flags;
diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 3a6dcaa..e474c95 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -248,11 +248,21 @@ enum ovs_vport_attr {
 
 #define OVS_VPORT_ATTR_MAX (__OVS_VPORT_ATTR_MAX - 1)
 
+enum {
+	OVS_VXLAN_EXT_UNSPEC,
+	OVS_VXLAN_EXT_GBP,	/* Flag or __u32 */
+	__OVS_VXLAN_EXT_MAX,
+};
+
+#define OVS_VXLAN_EXT_MAX (__OVS_VXLAN_EXT_MAX - 1)
+
+
 /* OVS_VPORT_ATTR_OPTIONS attributes for tunnels.
  */
 enum {
 	OVS_TUNNEL_ATTR_UNSPEC,
 	OVS_TUNNEL_ATTR_DST_PORT, /* 16-bit UDP port, used by L4 tunnels. */
+	OVS_TUNNEL_ATTR_EXTENSION,
 	__OVS_TUNNEL_ATTR_MAX
 };
 
@@ -324,6 +334,7 @@ enum ovs_tunnel_key_attr {
 	OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS,        /* Array of Geneve options. */
 	OVS_TUNNEL_KEY_ATTR_TP_SRC,		/* be16 src Transport Port. */
 	OVS_TUNNEL_KEY_ATTR_TP_DST,		/* be16 dst Transport Port. */
+	OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS,		/* Nested OVS_VXLAN_EXT_* */
 	__OVS_TUNNEL_KEY_ATTR_MAX
 };
 
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 518941c..d210d1b 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -49,6 +49,7 @@
 #include <net/mpls.h>
 
 #include "flow_netlink.h"
+#include "vport-vxlan.h"
 
 struct ovs_len_tbl {
 	int len;
@@ -268,6 +269,9 @@ size_t ovs_tun_key_attr_size(void)
 		+ nla_total_size(0)    /* OVS_TUNNEL_KEY_ATTR_CSUM */
 		+ nla_total_size(0)    /* OVS_TUNNEL_KEY_ATTR_OAM */
 		+ nla_total_size(256)  /* OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS */
+		/* OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS is mutually exclusive with
+		 * OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS and covered by it.
+		 */
 		+ nla_total_size(2)    /* OVS_TUNNEL_KEY_ATTR_TP_SRC */
 		+ nla_total_size(2);   /* OVS_TUNNEL_KEY_ATTR_TP_DST */
 }
@@ -308,6 +312,7 @@ static const struct ovs_len_tbl ovs_tunnel_key_lens[OVS_TUNNEL_KEY_ATTR_MAX + 1]
 	[OVS_TUNNEL_KEY_ATTR_TP_DST]	    = { .len = sizeof(u16) },
 	[OVS_TUNNEL_KEY_ATTR_OAM]	    = { .len = 0 },
 	[OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS]   = { .len = OVS_ATTR_NESTED },
+	[OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS]    = { .len = OVS_ATTR_NESTED },
 };
 
 /* The size of the argument for each %OVS_KEY_ATTR_* Netlink attribute.  */
@@ -460,6 +465,41 @@ static int genev_tun_opt_from_nlattr(const struct nlattr *a,
 	return 0;
 }
 
+static const struct nla_policy vxlan_opt_policy[OVS_VXLAN_EXT_MAX + 1] = {
+	[OVS_VXLAN_EXT_GBP]	= { .type = NLA_U32 },
+};
+
+static int vxlan_tun_opt_from_nlattr(const struct nlattr *a,
+				     struct sw_flow_match *match, bool is_mask,
+				     bool log)
+{
+	struct nlattr *tb[OVS_VXLAN_EXT_MAX+1];
+	unsigned long opt_key_offset;
+	struct ovs_vxlan_opts opts;
+	int err;
+
+	BUILD_BUG_ON(sizeof(opts) > sizeof(match->key->tun_opts));
+
+	err = nla_parse_nested(tb, OVS_VXLAN_EXT_MAX, a, vxlan_opt_policy);
+	if (err < 0)
+		return err;
+
+	memset(&opts, 0, sizeof(opts));
+
+	if (tb[OVS_VXLAN_EXT_GBP])
+		opts.gbp = nla_get_u32(tb[OVS_VXLAN_EXT_GBP]);
+
+	if (!is_mask)
+		SW_FLOW_KEY_PUT(match, tun_opts_len, sizeof(opts), false);
+	else
+		SW_FLOW_KEY_PUT(match, tun_opts_len, 0xff, true);
+
+	opt_key_offset = TUN_METADATA_OFFSET(sizeof(opts));
+	SW_FLOW_KEY_MEMCPY_OFFSET(match, opt_key_offset, &opts, sizeof(opts),
+				  is_mask);
+	return 0;
+}
+
 static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 				struct sw_flow_match *match, bool is_mask,
 				bool log)
@@ -468,6 +508,7 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 	int rem;
 	bool ttl = false;
 	__be16 tun_flags = 0;
+	int opts_type = 0;
 
 	nla_for_each_nested(a, attr, rem) {
 		int type = nla_type(a);
@@ -527,11 +568,30 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 			tun_flags |= TUNNEL_OAM;
 			break;
 		case OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS:
+			if (opts_type) {
+				OVS_NLERR(log, "Multiple metadata blocks provided");
+				return -EINVAL;
+			}
+
 			err = genev_tun_opt_from_nlattr(a, match, is_mask, log);
 			if (err)
 				return err;
 
-			tun_flags |= TUNNEL_OPTIONS_PRESENT;
+			tun_flags |= TUNNEL_GENEVE_OPT;
+			opts_type = type;
+			break;
+		case OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS:
+			if (opts_type) {
+				OVS_NLERR(log, "Multiple metadata blocks provided");
+				return -EINVAL;
+			}
+
+			err = vxlan_tun_opt_from_nlattr(a, match, is_mask, log);
+			if (err)
+				return err;
+
+			tun_flags |= TUNNEL_VXLAN_OPT;
+			opts_type = type;
 			break;
 		default:
 			OVS_NLERR(log, "Unknown IPv4 tunnel attribute %d",
@@ -560,6 +620,23 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 		}
 	}
 
+	return opts_type;
+}
+
+static int vxlan_opt_to_nlattr(struct sk_buff *skb,
+			       const void *tun_opts, int swkey_tun_opts_len)
+{
+	const struct ovs_vxlan_opts *opts = tun_opts;
+	struct nlattr *nla;
+
+	nla = nla_nest_start(skb, OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS);
+	if (!nla)
+		return -EMSGSIZE;
+
+	if (nla_put_u32(skb, OVS_VXLAN_EXT_GBP, opts->gbp) < 0)
+		return -EMSGSIZE;
+
+	nla_nest_end(skb, nla);
 	return 0;
 }
 
@@ -596,10 +673,15 @@ static int __ipv4_tun_to_nlattr(struct sk_buff *skb,
 	if ((output->tun_flags & TUNNEL_OAM) &&
 	    nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_OAM))
 		return -EMSGSIZE;
-	if (tun_opts &&
-	    nla_put(skb, OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS,
-		    swkey_tun_opts_len, tun_opts))
-		return -EMSGSIZE;
+	if (tun_opts) {
+		if (output->tun_flags & TUNNEL_GENEVE_OPT &&
+		    nla_put(skb, OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS,
+			    swkey_tun_opts_len, tun_opts))
+			return -EMSGSIZE;
+		else if (output->tun_flags & TUNNEL_VXLAN_OPT &&
+			 vxlan_opt_to_nlattr(skb, tun_opts, swkey_tun_opts_len))
+			return -EMSGSIZE;
+	}
 
 	return 0;
 }
@@ -680,7 +762,7 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 	}
 	if (*attrs & (1 << OVS_KEY_ATTR_TUNNEL)) {
 		if (ipv4_tun_from_nlattr(a[OVS_KEY_ATTR_TUNNEL], match,
-					 is_mask, log))
+					 is_mask, log) < 0)
 			return -EINVAL;
 		*attrs &= ~(1 << OVS_KEY_ATTR_TUNNEL);
 	}
@@ -1578,17 +1660,23 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	struct sw_flow_key key;
 	struct ovs_tunnel_info *tun_info;
 	struct nlattr *a;
-	int err, start;
+	int err, start, opts_type;
 
 	ovs_match_init(&match, &key, NULL);
-	err = ipv4_tun_from_nlattr(nla_data(attr), &match, false, log);
-	if (err)
-		return err;
+	opts_type = ipv4_tun_from_nlattr(nla_data(attr), &match, false, log);
+	if (opts_type < 0)
+		return opts_type;
 
 	if (key.tun_opts_len) {
-		err = validate_geneve_opts(&key);
-		if (err < 0)
-			return err;
+		switch (opts_type) {
+		case OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS:
+			err = validate_geneve_opts(&key);
+			if (err < 0)
+				return err;
+			break;
+		case OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS:
+			break;
+		}
 	};
 
 	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SET, log);
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 484864d..f01f3f8 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -90,7 +90,7 @@ static void geneve_rcv(struct geneve_sock *gs, struct sk_buff *skb)
 
 	opts_len = geneveh->opt_len * 4;
 
-	flags = TUNNEL_KEY | TUNNEL_OPTIONS_PRESENT |
+	flags = TUNNEL_KEY | TUNNEL_GENEVE_OPT |
 		(udp_hdr(skb)->check != 0 ? TUNNEL_CSUM : 0) |
 		(geneveh->oam ? TUNNEL_OAM : 0) |
 		(geneveh->critical ? TUNNEL_CRIT_OPT : 0);
@@ -180,7 +180,7 @@ static int geneve_tnl_send(struct vport *vport, struct sk_buff *skb)
 	__be16 sport;
 	struct rtable *rt;
 	struct flowi4 fl;
-	u8 vni[3];
+	u8 vni[3], opts_len, *opts;
 	__be16 df;
 	int err;
 
@@ -211,11 +211,18 @@ static int geneve_tnl_send(struct vport *vport, struct sk_buff *skb)
 	tunnel_id_to_vni(tun_key->tun_id, vni);
 	skb->ignore_df = 1;
 
+	if (tun_key->tun_flags & TUNNEL_GENEVE_OPT) {
+		opts = (u8 *)tun_info->options;
+		opts_len = tun_info->options_len;
+	} else {
+		opts = NULL;
+		opts_len = 0;
+	}
+
 	err = geneve_xmit_skb(geneve_port->gs, rt, skb, fl.saddr,
 			      tun_key->ipv4_dst, tun_key->ipv4_tos,
 			      tun_key->ipv4_ttl, df, sport, dport,
-			      tun_key->tun_flags, vni,
-			      tun_info->options_len, (u8 *)tun_info->options,
+			      tun_key->tun_flags, vni, opts_len, opts,
 			      false);
 	if (err < 0)
 		ip_rt_put(rt);
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 40a16fb..9f47c23 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -40,6 +40,7 @@
 
 #include "datapath.h"
 #include "vport.h"
+#include "vport-vxlan.h"
 
 /**
  * struct vxlan_port - Keeps track of open UDP ports
@@ -49,6 +50,7 @@
 struct vxlan_port {
 	struct vxlan_sock *vs;
 	char name[IFNAMSIZ];
+	u32 exts; /* VXLAN_EXT_* in <net/vxlan.h> */
 };
 
 static struct vport_ops ovs_vxlan_vport_ops;
@@ -63,16 +65,26 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 		      struct vxlan_metadata *md)
 {
 	struct ovs_tunnel_info tun_info;
+	struct vxlan_port *vxlan_port;
 	struct vport *vport = vs->data;
 	struct iphdr *iph;
+	struct ovs_vxlan_opts opts = {
+		.gbp = md->gbp,
+	};
 	__be64 key;
+	__be16 flags;
+
+	flags = TUNNEL_KEY;
+	vxlan_port = vxlan_vport(vport);
+	if (vxlan_port->exts & VXLAN_EXT_GBP)
+		flags |= TUNNEL_VXLAN_OPT;
 
 	/* Save outer tunnel values */
 	iph = ip_hdr(skb);
 	key = cpu_to_be64(ntohl(md->vni) >> 8);
 	ovs_flow_tun_info_init(&tun_info, iph,
 			       udp_hdr(skb)->source, udp_hdr(skb)->dest,
-			       key, TUNNEL_KEY, NULL, 0);
+			       key, flags, &opts, sizeof(opts));
 
 	ovs_vport_receive(vport, skb, &tun_info);
 }
@@ -84,6 +96,21 @@ static int vxlan_get_options(const struct vport *vport, struct sk_buff *skb)
 
 	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, ntohs(dst_port)))
 		return -EMSGSIZE;
+
+	if (vxlan_port->exts) {
+		struct nlattr *exts;
+
+		exts = nla_nest_start(skb, OVS_TUNNEL_ATTR_EXTENSION);
+		if (!exts)
+			return -EMSGSIZE;
+
+		if (vxlan_port->exts & VXLAN_EXT_GBP &&
+		    nla_put_flag(skb, OVS_VXLAN_EXT_GBP))
+			return -EMSGSIZE;
+
+		nla_nest_end(skb, exts);
+	}
+
 	return 0;
 }
 
@@ -96,6 +123,31 @@ static void vxlan_tnl_destroy(struct vport *vport)
 	ovs_vport_deferred_free(vport);
 }
 
+static const struct nla_policy exts_policy[OVS_VXLAN_EXT_MAX+1] = {
+	[OVS_VXLAN_EXT_GBP]	= { .type = NLA_FLAG, },
+};
+
+static int vxlan_configure_exts(struct vport *vport, struct nlattr *attr)
+{
+	struct nlattr *exts[OVS_VXLAN_EXT_MAX+1];
+	struct vxlan_port *vxlan_port;
+	int err;
+
+	if (nla_len(attr) < sizeof(struct nlattr))
+		return -EINVAL;
+
+	err = nla_parse_nested(exts, OVS_VXLAN_EXT_MAX, attr, exts_policy);
+	if (err < 0)
+		return err;
+
+	vxlan_port = vxlan_vport(vport);
+
+	if (exts[OVS_VXLAN_EXT_GBP])
+		vxlan_port->exts |= VXLAN_EXT_GBP;
+
+	return 0;
+}
+
 static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
 {
 	struct net *net = ovs_dp_get_net(parms->dp);
@@ -128,7 +180,17 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
 	vxlan_port = vxlan_vport(vport);
 	strncpy(vxlan_port->name, parms->name, IFNAMSIZ);
 
-	vs = vxlan_sock_add(net, htons(dst_port), vxlan_rcv, vport, true, 0, 0);
+	a = nla_find_nested(options, OVS_TUNNEL_ATTR_EXTENSION);
+	if (a) {
+		err = vxlan_configure_exts(vport, a);
+		if (err) {
+			ovs_vport_free(vport);
+			goto error;
+		}
+	}
+
+	vs = vxlan_sock_add(net, htons(dst_port), vxlan_rcv, vport, true, 0,
+			    vxlan_port->exts);
 	if (IS_ERR(vs)) {
 		ovs_vport_free(vport);
 		return (void *)vs;
@@ -141,6 +203,21 @@ error:
 	return ERR_PTR(err);
 }
 
+static int vxlan_ext_gbp(struct sk_buff *skb)
+{
+	const struct ovs_tunnel_info *tun_info;
+	const struct ovs_vxlan_opts *opts;
+
+	tun_info = OVS_CB(skb)->egress_tun_info;
+	opts = tun_info->options;
+
+	if (tun_info->tunnel.tun_flags & TUNNEL_VXLAN_OPT &&
+	    tun_info->options_len >= sizeof(*opts))
+		return opts->gbp;
+	else
+		return 0;
+}
+
 static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 {
 	struct net *net = ovs_dp_get_net(vport->dp);
@@ -181,6 +258,7 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 
 	src_port = udp_flow_src_port(net, skb, 0, 0, true);
 	md.vni = htonl(be64_to_cpu(tun_key->tun_id) << 8);
+	md.gbp = vxlan_ext_gbp(skb);
 
 	err = vxlan_xmit_skb(vxlan_port->vs, rt, skb,
 			     fl.saddr, tun_key->ipv4_dst,
diff --git a/net/openvswitch/vport-vxlan.h b/net/openvswitch/vport-vxlan.h
new file mode 100644
index 0000000..4b08233e
--- /dev/null
+++ b/net/openvswitch/vport-vxlan.h
@@ -0,0 +1,11 @@
+#ifndef VPORT_VXLAN_H
+#define VPORT_VXLAN_H 1
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+
+struct ovs_vxlan_opts {
+	__u32 gbp;
+};
+
+#endif
-- 
1.9.3
