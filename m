From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/6] openvswitch: Support VXLAN Group Policy extension
Date: Wed,  7 Jan 2015 03:05:41 +0100
Message-ID: <9c1b0b0acde09019acb61b9b1a4eb4b18c62642a.1420594925.git.tgraf@suug.ch>
References: <cover.1420594925.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: davem@davemloft.net, jesse@nicira.com, stephen@networkplumber.org,
	pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42910 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756246AbbAGCF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 21:05:58 -0500
In-Reply-To: <cover.1420594925.git.tgraf@suug.ch>
In-Reply-To: <cover.1420594925.git.tgraf@suug.ch>
References: <cover.1420594925.git.tgraf@suug.ch>
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

The group policy metadata is handled in the same way as Geneve options
and transported as binary blob in a new Netlink attribute
OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS which is mutually exclusive to the
existing OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/uapi/linux/openvswitch.h | 19 ++++++++++
 net/openvswitch/flow_netlink.c   | 78 +++++++++++++++++++++++++--------------
 net/openvswitch/vport-vxlan.c    | 80 +++++++++++++++++++++++++++++++++++++++-
 3 files changed, 148 insertions(+), 29 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 3a6dcaa..676a89e 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -248,11 +248,29 @@ enum ovs_vport_attr {
 
 #define OVS_VPORT_ATTR_MAX (__OVS_VPORT_ATTR_MAX - 1)
 
+/**
+ * struct ovs_vxlan_opts - VXLAN tunnel options
+ * @gbp: Group policy bits
+ */
+struct ovs_vxlan_opts {
+	__u32 gbp;
+};
+
+enum {
+	OVS_VXLAN_EXT_UNSPEC,
+	OVS_VXLAN_EXT_GBP,
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
 
@@ -324,6 +342,7 @@ enum ovs_tunnel_key_attr {
 	OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS,        /* Array of Geneve options. */
 	OVS_TUNNEL_KEY_ATTR_TP_SRC,		/* be16 src Transport Port. */
 	OVS_TUNNEL_KEY_ATTR_TP_DST,		/* be16 dst Transport Port. */
+	OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS,		/* struct ovs_vxlan_opts. */
 	__OVS_TUNNEL_KEY_ATTR_MAX
 };
 
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index c60ae3f..1528709 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -446,6 +446,7 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 	int rem;
 	bool ttl = false;
 	__be16 tun_flags = 0;
+	int opts_type = 0;
 
 	nla_for_each_nested(a, attr, rem) {
 		int type = nla_type(a);
@@ -463,6 +464,7 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 			[OVS_TUNNEL_KEY_ATTR_TP_DST] = sizeof(u16),
 			[OVS_TUNNEL_KEY_ATTR_OAM] = 0,
 			[OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS] = -1,
+			[OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS] = -1,
 		};
 
 		if (type > OVS_TUNNEL_KEY_ATTR_MAX) {
@@ -519,11 +521,18 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 			tun_flags |= TUNNEL_OAM;
 			break;
 		case OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS:
+		case OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS:
+			if (opts_type) {
+				OVS_NLERR(log, "Multiple metadata blocks provided");
+				return -EINVAL;
+			}
+
 			err = tun_md_opt_from_nlattr(a, match, is_mask, log);
 			if (err)
 				return err;
 
 			tun_flags |= TUNNEL_OPTIONS_PRESENT;
+			opts_type = type;
 			break;
 		default:
 			OVS_NLERR(log, "Unknown IPv4 tunnel attribute %d",
@@ -552,7 +561,7 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 		}
 	}
 
-	return 0;
+	return opts_type;
 }
 
 static int __ipv4_tun_to_nlattr(struct sk_buff *skb,
@@ -1537,6 +1546,34 @@ void ovs_match_init(struct sw_flow_match *match,
 	}
 }
 
+static int validate_and_copy_geneve_opts(struct sw_flow_key *key)
+{
+	struct geneve_opt *option;
+	int opts_len = key->tun_opts_len;
+	bool crit_opt = false;
+
+	option = (struct geneve_opt *) TUN_METADATA_OPTS(key, key->tun_opts_len);
+	while (opts_len > 0) {
+		int len;
+
+		if (opts_len < sizeof(*option))
+			return -EINVAL;
+
+		len = sizeof(*option) + option->length * 4;
+		if (len > opts_len)
+			return -EINVAL;
+
+		crit_opt |= !!(option->type & GENEVE_CRIT_OPT_TYPE);
+
+		option = (struct geneve_opt *)((u8 *)option + len);
+		opts_len -= len;
+	};
+
+	key->tun_key.tun_flags |= crit_opt ? TUNNEL_CRIT_OPT : 0;
+
+	return 0;
+}
+
 static int validate_and_copy_set_tun(const struct nlattr *attr,
 				     struct sw_flow_actions **sfa, bool log)
 {
@@ -1544,36 +1581,23 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
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
-		struct geneve_opt *option;
-		int opts_len = key.tun_opts_len;
-		bool crit_opt = false;
-
-		option = (struct geneve_opt *) TUN_METADATA_OPTS(&key, key.tun_opts_len);
-		while (opts_len > 0) {
-			int len;
-
-			if (opts_len < sizeof(*option))
-				return -EINVAL;
-
-			len = sizeof(*option) + option->length * 4;
-			if (len > opts_len)
-				return -EINVAL;
-
-			crit_opt |= !!(option->type & GENEVE_CRIT_OPT_TYPE);
-
-			option = (struct geneve_opt *)((u8 *)option + len);
-			opts_len -= len;
-		};
-
-		key.tun_key.tun_flags |= crit_opt ? TUNNEL_CRIT_OPT : 0;
+		switch (opts_type) {
+		case OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS:
+			err = validate_and_copy_geneve_opts(&key);
+			if (err < 0)
+				return err;
+			break;
+		case OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS:
+			break;
+		}
 	};
 
 	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SET, log);
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 266c595..8ed7163 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -49,6 +49,7 @@
 struct vxlan_port {
 	struct vxlan_sock *vs;
 	char name[IFNAMSIZ];
+	u32 exts; /* VXLAN_EXT_* in <net/vxlan.h> */
 };
 
 static struct vport_ops ovs_vxlan_vport_ops;
@@ -63,16 +64,26 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
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
+		flags |= TUNNEL_OPTIONS_PRESENT;
 
 	/* Save outer tunnel values */
 	iph = ip_hdr(skb);
 	key = cpu_to_be64(ntohl(md->vni) >> 8);
 	ovs_flow_tun_info_init(&tun_info, iph,
 			       udp_hdr(skb)->source, udp_hdr(skb)->dest,
-			       key, TUNNEL_KEY, NULL, 0);
+			       key, flags, &opts, sizeof(opts));
 
 	ovs_vport_receive(vport, skb, &tun_info);
 }
@@ -84,6 +95,21 @@ static int vxlan_get_options(const struct vport *vport, struct sk_buff *skb)
 
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
 
@@ -96,6 +122,31 @@ static void vxlan_tnl_destroy(struct vport *vport)
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
@@ -128,7 +179,17 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
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
@@ -141,6 +202,20 @@ error:
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
+	if (tun_info->options_len >= sizeof(*opts))
+		return opts->gbp;
+	else
+		return 0;
+}
+
 static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 {
 	struct net *net = ovs_dp_get_net(vport->dp);
@@ -181,6 +256,7 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 
 	src_port = udp_flow_src_port(net, skb, 0, 0, true);
 	md.vni = htonl(be64_to_cpu(tun_key->tun_id) << 8);
+	md.gbp = vxlan_ext_gbp(skb);
 
 	err = vxlan_xmit_skb(vxlan_port->vs, rt, skb,
 			     fl.saddr, tun_key->ipv4_dst,
-- 
1.9.3
