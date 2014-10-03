From: Andy Zhou <azhou@nicira.com>
Subject: [net-next v2 6/6] openvswitch: Add support for Geneve tunneling.
Date: Fri,  3 Oct 2014 15:35:33 -0700
Message-ID: <1412375733-30981-7-git-send-email-azhou@nicira.com>
References: <1412375733-30981-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog122.obsmtp.com ([74.125.149.147]:52016 "HELO
	na3sys009aog122.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757863AbaJCWmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:42:36 -0400
Received: by mail-pa0-f44.google.com with SMTP id et14so2191750pad.31
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 15:42:35 -0700 (PDT)
In-Reply-To: <1412375733-30981-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>

The Openvswitch implementation is completely agnostic to the options
that are in use and can handle newly defined options without
further work. It does this by simply matching on a byte array
of options and allowing userspace to setup flows on this array.

Signed-off-by: Jesse Gross <jesse@nicira.com>
Singed-off-by: Ansis Atteka <aatteka@nicira.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
Acked-by: Thomas Graf <tgraf@noironetworks.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/ip_tunnels.h         |   21 ++--
 include/uapi/linux/openvswitch.h |    2 +
 net/openvswitch/Kconfig          |   11 ++
 net/openvswitch/Makefile         |    4 +
 net/openvswitch/datapath.c       |    5 +-
 net/openvswitch/flow.c           |   20 +++-
 net/openvswitch/flow.h           |   20 +++-
 net/openvswitch/flow_netlink.c   |  176 +++++++++++++++++++++++-----
 net/openvswitch/vport-geneve.c   |  236 ++++++++++++++++++++++++++++++++++++++
 net/openvswitch/vport-gre.c      |    2 +-
 net/openvswitch/vport-vxlan.c    |    2 +-
 net/openvswitch/vport.c          |    3 +
 net/openvswitch/vport.h          |    1 +
 13 files changed, 461 insertions(+), 42 deletions(-)
 create mode 100644 net/openvswitch/vport-geneve.c

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index a9ce155..5bc6ede 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -86,17 +86,18 @@ struct ip_tunnel {
 	struct gro_cells	gro_cells;
 };
 
-#define TUNNEL_CSUM	__cpu_to_be16(0x01)
-#define TUNNEL_ROUTING	__cpu_to_be16(0x02)
-#define TUNNEL_KEY	__cpu_to_be16(0x04)
-#define TUNNEL_SEQ	__cpu_to_be16(0x08)
-#define TUNNEL_STRICT	__cpu_to_be16(0x10)
-#define TUNNEL_REC	__cpu_to_be16(0x20)
-#define TUNNEL_VERSION	__cpu_to_be16(0x40)
-#define TUNNEL_NO_KEY	__cpu_to_be16(0x80)
+#define TUNNEL_CSUM		__cpu_to_be16(0x01)
+#define TUNNEL_ROUTING		__cpu_to_be16(0x02)
+#define TUNNEL_KEY		__cpu_to_be16(0x04)
+#define TUNNEL_SEQ		__cpu_to_be16(0x08)
+#define TUNNEL_STRICT		__cpu_to_be16(0x10)
+#define TUNNEL_REC		__cpu_to_be16(0x20)
+#define TUNNEL_VERSION		__cpu_to_be16(0x40)
+#define TUNNEL_NO_KEY		__cpu_to_be16(0x80)
 #define TUNNEL_DONT_FRAGMENT    __cpu_to_be16(0x0100)
-#define TUNNEL_OAM	__cpu_to_be16(0x0200)
-#define TUNNEL_CRIT_OPT	__cpu_to_be16(0x0400)
+#define TUNNEL_OAM		__cpu_to_be16(0x0200)
+#define TUNNEL_CRIT_OPT		__cpu_to_be16(0x0400)
+#define TUNNEL_OPTIONS_PRESENT	__cpu_to_be16(0x0800)
 
 struct tnl_ptk_info {
 	__be16 flags;
diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 6753032..435eabc 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -192,6 +192,7 @@ enum ovs_vport_type {
 	OVS_VPORT_TYPE_INTERNAL, /* network device implemented by datapath */
 	OVS_VPORT_TYPE_GRE,      /* GRE tunnel. */
 	OVS_VPORT_TYPE_VXLAN,	 /* VXLAN tunnel. */
+	OVS_VPORT_TYPE_GENEVE,	 /* Geneve tunnel. */
 	__OVS_VPORT_TYPE_MAX
 };
 
@@ -310,6 +311,7 @@ enum ovs_tunnel_key_attr {
 	OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT,      /* No argument, set DF. */
 	OVS_TUNNEL_KEY_ATTR_CSUM,               /* No argument. CSUM packet. */
 	OVS_TUNNEL_KEY_ATTR_OAM,                /* No argument. OAM frame.  */
+	OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS,        /* Array of Geneve options. */
 	__OVS_TUNNEL_KEY_ATTR_MAX
 };
 
diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index 6ecf491..ba3bb82 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -54,3 +54,14 @@ config OPENVSWITCH_VXLAN
 	  Say N to exclude this support and reduce the binary size.
 
 	  If unsure, say Y.
+
+config OPENVSWITCH_GENEVE
+	bool "Open vSwitch Geneve tunneling support"
+	depends on INET
+	depends on OPENVSWITCH
+	depends on GENEVE && !(OPENVSWITCH=y && GENEVE=m)
+	default y
+	---help---
+	  If you say Y here, then the Open vSwitch will be able create geneve vport.
+
+	  Say N to exclude this support and reduce the binary size.
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 3591cb5..9a33a27 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -15,6 +15,10 @@ openvswitch-y := \
 	vport-internal_dev.o \
 	vport-netdev.o
 
+ifneq ($(CONFIG_OPENVSWITCH_GENEVE),)
+openvswitch-y += vport-geneve.o
+endif
+
 ifneq ($(CONFIG_OPENVSWITCH_VXLAN),)
 openvswitch-y += vport-vxlan.o
 endif
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 010125c..2e31d9e 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -370,6 +370,7 @@ static size_t key_attr_size(void)
 		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT */
 		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_CSUM */
 		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_OAM */
+		  + nla_total_size(256)   /* OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_IN_PORT */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_SKB_MARK */
 		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
@@ -556,10 +557,12 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 
 	err = ovs_nla_copy_actions(a[OVS_PACKET_ATTR_ACTIONS],
 				   &flow->key, 0, &acts);
-	rcu_assign_pointer(flow->sf_acts, acts);
 	if (err)
 		goto err_flow_free;
 
+	rcu_assign_pointer(flow->sf_acts, acts);
+
+	OVS_CB(packet)->egress_tun_info = NULL;
 	OVS_CB(packet)->flow = flow;
 	packet->priority = flow->key.phy.priority;
 	packet->mark = flow->key.phy.skb_mark;
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 2924cb3..62db02b 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -448,6 +448,9 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 	int error;
 	struct ethhdr *eth;
 
+	/* Flags are always used as part of stats */
+	key->tp.flags = 0;
+
 	skb_reset_mac_header(skb);
 
 	/* Link layer.  We are guaranteed to have at least the 14 byte Ethernet
@@ -646,10 +649,23 @@ int ovs_flow_key_extract(struct ovs_tunnel_info *tun_info,
 			 struct sk_buff *skb, struct sw_flow_key *key)
 {
 	/* Extract metadata from packet. */
-	if (tun_info)
+	if (tun_info) {
 		memcpy(&key->tun_key, &tun_info->tunnel, sizeof(key->tun_key));
-	else
+
+		if (tun_info->options) {
+			BUILD_BUG_ON((1 << (sizeof(tun_info->options_len) *
+						   8)) - 1
+					> sizeof(key->tun_opts));
+			memcpy(GENEVE_OPTS(key, tun_info->options_len),
+			       tun_info->options, tun_info->options_len);
+			key->tun_opts_len = tun_info->options_len;
+		} else {
+			key->tun_opts_len = 0;
+		}
+	} else  {
+		key->tun_opts_len = 0;
 		memset(&key->tun_key, 0, sizeof(key->tun_key));
+	}
 
 	key->phy.priority = skb->priority;
 	key->phy.in_port = OVS_CB(skb)->input_vport->port_no;
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index fe5a71b..7181331 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -51,11 +51,24 @@ struct ovs_key_ipv4_tunnel {
 
 struct ovs_tunnel_info {
 	struct ovs_key_ipv4_tunnel tunnel;
+	struct geneve_opt *options;
+	u8 options_len;
 };
 
+/* Store options at the end of the array if they are less than the
+ * maximum size. This allows us to get the benefits of variable length
+ * matching for small options.
+ */
+#define GENEVE_OPTS(flow_key, opt_len)	\
+	((struct geneve_opt *)((flow_key)->tun_opts + \
+			       FIELD_SIZEOF(struct sw_flow_key, tun_opts) - \
+			       opt_len))
+
 static inline void ovs_flow_tun_info_init(struct ovs_tunnel_info *tun_info,
 					  const struct iphdr *iph,
-					  __be64 tun_id, __be16 tun_flags)
+					  __be64 tun_id, __be16 tun_flags,
+					  struct geneve_opt *opts,
+					  u8 opts_len)
 {
 	tun_info->tunnel.tun_id = tun_id;
 	tun_info->tunnel.ipv4_src = iph->saddr;
@@ -67,9 +80,14 @@ static inline void ovs_flow_tun_info_init(struct ovs_tunnel_info *tun_info,
 	/* clear struct padding. */
 	memset((unsigned char *)&tun_info->tunnel + OVS_TUNNEL_KEY_SIZE, 0,
 	       sizeof(tun_info->tunnel) - OVS_TUNNEL_KEY_SIZE);
+
+	tun_info->options = opts;
+	tun_info->options_len = opts_len;
 }
 
 struct sw_flow_key {
+	u8 tun_opts[255];
+	u8 tun_opts_len;
 	struct ovs_key_ipv4_tunnel tun_key;  /* Encapsulating tunnel key. */
 	struct {
 		u32	priority;	/* Packet QoS priority. */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 5d6194d..368f233 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -42,6 +42,7 @@
 #include <linux/icmp.h>
 #include <linux/icmpv6.h>
 #include <linux/rculist.h>
+#include <net/geneve.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/ndisc.h>
@@ -88,18 +89,20 @@ static void update_range__(struct sw_flow_match *match,
 		}                                                           \
 	} while (0)
 
-#define SW_FLOW_KEY_MEMCPY(match, field, value_p, len, is_mask) \
-	do { \
-		update_range__(match, offsetof(struct sw_flow_key, field),  \
-				len, is_mask);                              \
-		if (is_mask) {						    \
-			if ((match)->mask)				    \
-				memcpy(&(match)->mask->key.field, value_p, len);\
-		} else {                                                    \
-			memcpy(&(match)->key->field, value_p, len);         \
-		}                                                           \
+#define SW_FLOW_KEY_MEMCPY_OFFSET(match, offset, value_p, len, is_mask)	    \
+	do {								    \
+		update_range__(match, offset, len, is_mask);		    \
+		if (is_mask)						    \
+			memcpy((u8 *)&(match)->mask->key + offset, value_p, \
+			       len);					    \
+		else							    \
+			memcpy((u8 *)(match)->key + offset, value_p, len);  \
 	} while (0)
 
+#define SW_FLOW_KEY_MEMCPY(match, field, value_p, len, is_mask)		      \
+	SW_FLOW_KEY_MEMCPY_OFFSET(match, offsetof(struct sw_flow_key, field), \
+				  value_p, len, is_mask)
+
 static u16 range_n_bytes(const struct sw_flow_key_range *range)
 {
 	return range->end - range->start;
@@ -335,6 +338,7 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 	int rem;
 	bool ttl = false;
 	__be16 tun_flags = 0;
+	unsigned long opt_key_offset;
 
 	nla_for_each_nested(a, attr, rem) {
 		int type = nla_type(a);
@@ -347,6 +351,7 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 			[OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT] = 0,
 			[OVS_TUNNEL_KEY_ATTR_CSUM] = 0,
 			[OVS_TUNNEL_KEY_ATTR_OAM] = 0,
+			[OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS] = -1,
 		};
 
 		if (type > OVS_TUNNEL_KEY_ATTR_MAX) {
@@ -355,7 +360,8 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 			return -EINVAL;
 		}
 
-		if (ovs_tunnel_key_lens[type] != nla_len(a)) {
+		if (ovs_tunnel_key_lens[type] != nla_len(a) &&
+		    ovs_tunnel_key_lens[type] != -1) {
 			OVS_NLERR("IPv4 tunnel attribute type has unexpected "
 				  " length (type=%d, length=%d, expected=%d).\n",
 				  type, nla_len(a), ovs_tunnel_key_lens[type]);
@@ -394,7 +400,60 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 		case OVS_TUNNEL_KEY_ATTR_OAM:
 			tun_flags |= TUNNEL_OAM;
 			break;
+		case OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS:
+			tun_flags |= TUNNEL_OPTIONS_PRESENT;
+			if (nla_len(a) > sizeof(match->key->tun_opts)) {
+				OVS_NLERR("Geneve option length exceeds maximum size (len %d, max %zu).\n",
+					  nla_len(a),
+					  sizeof(match->key->tun_opts));
+				return -EINVAL;
+			}
+
+			if (nla_len(a) % 4 != 0) {
+				OVS_NLERR("Geneve option length is not a multiple of 4 (len %d).\n",
+					  nla_len(a));
+				return -EINVAL;
+			}
+
+			/* We need to record the length of the options passed
+			 * down, otherwise packets with the same format but
+			 * additional options will be silently matched.
+			 */
+			if (!is_mask) {
+				SW_FLOW_KEY_PUT(match, tun_opts_len, nla_len(a),
+						false);
+			} else {
+				/* This is somewhat unusual because it looks at
+				 * both the key and mask while parsing the
+				 * attributes (and by extension assumes the key
+				 * is parsed first). Normally, we would verify
+				 * that each is the correct length and that the
+				 * attributes line up in the validate function.
+				 * However, that is difficult because this is
+				 * variable length and we won't have the
+				 * information later.
+				 */
+				if (match->key->tun_opts_len != nla_len(a)) {
+					OVS_NLERR("Geneve option key length (%d) is different from mask length (%d).",
+						  match->key->tun_opts_len,
+						  nla_len(a));
+					return -EINVAL;
+				}
+
+				SW_FLOW_KEY_PUT(match, tun_opts_len, 0xff,
+						true);
+			}
+
+			opt_key_offset = (unsigned long)GENEVE_OPTS(
+					  (struct sw_flow_key *)0,
+					  nla_len(a));
+			SW_FLOW_KEY_MEMCPY_OFFSET(match, opt_key_offset,
+						  nla_data(a), nla_len(a),
+						  is_mask);
+			break;
 		default:
+			OVS_NLERR("Unknown IPv4 tunnel attribute (%d).\n",
+				  type);
 			return -EINVAL;
 		}
 	}
@@ -421,16 +480,11 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 	return 0;
 }
 
-static int ipv4_tun_to_nlattr(struct sk_buff *skb,
-			      const struct ovs_key_ipv4_tunnel *tun_key,
-			      const struct ovs_key_ipv4_tunnel *output)
+static int __ipv4_tun_to_nlattr(struct sk_buff *skb,
+				const struct ovs_key_ipv4_tunnel *output,
+				const struct geneve_opt *tun_opts,
+				int swkey_tun_opts_len)
 {
-	struct nlattr *nla;
-
-	nla = nla_nest_start(skb, OVS_KEY_ATTR_TUNNEL);
-	if (!nla)
-		return -EMSGSIZE;
-
 	if (output->tun_flags & TUNNEL_KEY &&
 	    nla_put_be64(skb, OVS_TUNNEL_KEY_ATTR_ID, output->tun_id))
 		return -EMSGSIZE;
@@ -454,12 +508,35 @@ static int ipv4_tun_to_nlattr(struct sk_buff *skb,
 	if ((output->tun_flags & TUNNEL_OAM) &&
 	    nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_OAM))
 		return -EMSGSIZE;
+	if (tun_opts &&
+	    nla_put(skb, OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS,
+		    swkey_tun_opts_len, tun_opts))
+		return -EMSGSIZE;
 
-	nla_nest_end(skb, nla);
 	return 0;
 }
 
 
+static int ipv4_tun_to_nlattr(struct sk_buff *skb,
+			      const struct ovs_key_ipv4_tunnel *output,
+			      const struct geneve_opt *tun_opts,
+			      int swkey_tun_opts_len)
+{
+	struct nlattr *nla;
+	int err;
+
+	nla = nla_nest_start(skb, OVS_KEY_ATTR_TUNNEL);
+	if (!nla)
+		return -EMSGSIZE;
+
+	err = __ipv4_tun_to_nlattr(skb, output, tun_opts, swkey_tun_opts_len);
+	if (err)
+		return err;
+
+	nla_nest_end(skb, nla);
+	return 0;
+}
+
 static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 				 const struct nlattr **a, bool is_mask)
 {
@@ -905,9 +982,16 @@ int ovs_nla_put_flow(const struct sw_flow_key *swkey,
 	if (nla_put_u32(skb, OVS_KEY_ATTR_PRIORITY, output->phy.priority))
 		goto nla_put_failure;
 
-	if ((swkey->tun_key.ipv4_dst || is_mask) &&
-	    ipv4_tun_to_nlattr(skb, &swkey->tun_key, &output->tun_key))
-		goto nla_put_failure;
+	if ((swkey->tun_key.ipv4_dst || is_mask)) {
+		const struct geneve_opt *opts = NULL;
+
+		if (output->tun_key.tun_flags & TUNNEL_OPTIONS_PRESENT)
+			opts = GENEVE_OPTS(output, swkey->tun_opts_len);
+
+		if (ipv4_tun_to_nlattr(skb, &output->tun_key, opts,
+				       swkey->tun_opts_len))
+			goto nla_put_failure;
+	}
 
 	if (swkey->phy.in_port == DP_MAX_PORTS) {
 		if (is_mask && (output->phy.in_port == 0xffff))
@@ -1290,17 +1374,55 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 	if (err)
 		return err;
 
+	if (key.tun_opts_len) {
+		struct geneve_opt *option = GENEVE_OPTS(&key,
+							key.tun_opts_len);
+		int opts_len = key.tun_opts_len;
+		bool crit_opt = false;
+
+		while (opts_len > 0) {
+			int len;
+
+			if (opts_len < sizeof(*option))
+				return -EINVAL;
+
+			len = sizeof(*option) + option->length * 4;
+			if (len > opts_len)
+				return -EINVAL;
+
+			crit_opt |= !!(option->type & GENEVE_CRIT_OPT_TYPE);
+
+			option = (struct geneve_opt *)((u8 *)option + len);
+			opts_len -= len;
+		};
+
+		key.tun_key.tun_flags |= crit_opt ? TUNNEL_CRIT_OPT : 0;
+	};
+
 	start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SET);
 	if (start < 0)
 		return start;
 
 	a = __add_action(sfa, OVS_KEY_ATTR_TUNNEL_INFO, NULL,
-			 sizeof(*tun_info));
+			 sizeof(*tun_info) + key.tun_opts_len);
 	if (IS_ERR(a))
 		return PTR_ERR(a);
 
 	tun_info = nla_data(a);
 	tun_info->tunnel = key.tun_key;
+	tun_info->options_len = key.tun_opts_len;
+
+	if (tun_info->options_len) {
+		/* We need to store the options in the action itself since
+		 * everything else will go away after flow setup. We can append
+		 * it to tun_info and then point there.
+		 */
+		memcpy((tun_info + 1), GENEVE_OPTS(&key, key.tun_opts_len),
+		       key.tun_opts_len);
+		tun_info->options = (struct geneve_opt *)(tun_info + 1);
+	} else {
+		tun_info->options = NULL;
+	}
 
 	add_nested_action_end(*sfa, start);
 
@@ -1592,7 +1714,9 @@ static int set_action_to_attr(const struct nlattr *a, struct sk_buff *skb)
 			return -EMSGSIZE;
 
 		err = ipv4_tun_to_nlattr(skb, &tun_info->tunnel,
-					 nla_data(ovs_key));
+					 tun_info->options_len ?
+						tun_info->options : NULL,
+					 tun_info->options_len);
 		if (err)
 			return err;
 		nla_nest_end(skb, start);
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
new file mode 100644
index 0000000..5572d48
--- /dev/null
+++ b/net/openvswitch/vport-geneve.c
@@ -0,0 +1,236 @@
+/*
+ * Copyright (c) 2014 Nicira, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/version.h>
+
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/net.h>
+#include <linux/rculist.h>
+#include <linux/udp.h>
+#include <linux/if_vlan.h>
+
+#include <net/geneve.h>
+#include <net/icmp.h>
+#include <net/ip.h>
+#include <net/route.h>
+#include <net/udp.h>
+#include <net/xfrm.h>
+
+#include "datapath.h"
+#include "vport.h"
+
+/**
+ * struct geneve_port - Keeps track of open UDP ports
+ * @sock: The socket created for this port number.
+ * @name: vport name.
+ */
+struct geneve_port {
+	struct geneve_sock *gs;
+	char name[IFNAMSIZ];
+};
+
+static LIST_HEAD(geneve_ports);
+
+static inline struct geneve_port *geneve_vport(const struct vport *vport)
+{
+	return vport_priv(vport);
+}
+
+static inline struct genevehdr *geneve_hdr(const struct sk_buff *skb)
+{
+	return (struct genevehdr *)(udp_hdr(skb) + 1);
+}
+
+/* Convert 64 bit tunnel ID to 24 bit VNI. */
+static void tunnel_id_to_vni(__be64 tun_id, __u8 *vni)
+{
+#ifdef __BIG_ENDIAN
+	vni[0] = (__force __u8)(tun_id >> 16);
+	vni[1] = (__force __u8)(tun_id >> 8);
+	vni[2] = (__force __u8)tun_id;
+#else
+	vni[0] = (__force __u8)((__force u64)tun_id >> 40);
+	vni[1] = (__force __u8)((__force u64)tun_id >> 48);
+	vni[2] = (__force __u8)((__force u64)tun_id >> 56);
+#endif
+}
+
+/* Convert 24 bit VNI to 64 bit tunnel ID. */
+static __be64 vni_to_tunnel_id(__u8 *vni)
+{
+#ifdef __BIG_ENDIAN
+	return (vni[0] << 16) | (vni[1] << 8) | vni[2];
+#else
+	return (__force __be64)(((__force u64)vni[0] << 40) |
+				((__force u64)vni[1] << 48) |
+				((__force u64)vni[2] << 56));
+#endif
+}
+
+static void geneve_rcv(struct geneve_sock *gs, struct sk_buff *skb)
+{
+	struct vport *vport = gs->rcv_data;
+	struct genevehdr *geneveh = geneve_hdr(skb);
+	int opts_len;
+	struct ovs_tunnel_info tun_info;
+	__be64 key;
+	__be16 flags;
+
+	opts_len = geneveh->opt_len * 4;
+
+	flags = TUNNEL_KEY | TUNNEL_OPTIONS_PRESENT |
+		(udp_hdr(skb)->check != 0 ? TUNNEL_CSUM : 0) |
+		(geneveh->oam ? TUNNEL_OAM : 0) |
+		(geneveh->critical ? TUNNEL_CRIT_OPT : 0);
+
+	key = vni_to_tunnel_id(geneveh->vni);
+
+	ovs_flow_tun_info_init(&tun_info, ip_hdr(skb), key, flags,
+			       geneveh->options, opts_len);
+
+	ovs_vport_receive(vport, skb, &tun_info);
+}
+
+static int geneve_get_options(const struct vport *vport,
+			      struct sk_buff *skb)
+{
+	struct geneve_port *geneve_port = geneve_vport(vport);
+	__be16 sport;
+
+	sport = ntohs(inet_sk(geneve_port->gs->sock->sk)->inet_sport);
+	if (nla_put_u16(skb, OVS_TUNNEL_ATTR_DST_PORT, sport))
+		return -EMSGSIZE;
+	return 0;
+}
+
+static void geneve_tnl_destroy(struct vport *vport)
+{
+	struct geneve_port *geneve_port = geneve_vport(vport);
+
+	geneve_sock_release(geneve_port->gs);
+
+	ovs_vport_deferred_free(vport);
+}
+
+static struct vport *geneve_tnl_create(const struct vport_parms *parms)
+{
+	struct net *net = ovs_dp_get_net(parms->dp);
+	struct nlattr *options = parms->options;
+	struct geneve_port *geneve_port;
+	struct geneve_sock *gs;
+	struct vport *vport;
+	struct nlattr *a;
+	int err;
+	u16 dst_port;
+
+	if (!options) {
+		err = -EINVAL;
+		goto error;
+	}
+
+	a = nla_find_nested(options, OVS_TUNNEL_ATTR_DST_PORT);
+	if (a && nla_len(a) == sizeof(u16)) {
+		dst_port = nla_get_u16(a);
+	} else {
+		/* Require destination port from userspace. */
+		err = -EINVAL;
+		goto error;
+	}
+
+	vport = ovs_vport_alloc(sizeof(struct geneve_port),
+				&ovs_geneve_vport_ops, parms);
+	if (IS_ERR(vport))
+		return vport;
+
+	geneve_port = geneve_vport(vport);
+	strncpy(geneve_port->name, parms->name, IFNAMSIZ);
+
+	gs = geneve_sock_add(net, htons(dst_port), geneve_rcv, vport, true, 0);
+	if (IS_ERR(gs)) {
+		ovs_vport_free(vport);
+		return (void *)gs;
+	}
+	geneve_port->gs = gs;
+
+	return vport;
+error:
+	return ERR_PTR(err);
+}
+
+static int geneve_tnl_send(struct vport *vport, struct sk_buff *skb)
+{
+	struct ovs_key_ipv4_tunnel *tun_key;
+	struct ovs_tunnel_info *tun_info;
+	struct net *net = ovs_dp_get_net(vport->dp);
+	struct geneve_port *geneve_port = geneve_vport(vport);
+	__be16 dport = inet_sk(geneve_port->gs->sock->sk)->inet_sport;
+	__be16 sport;
+	struct rtable *rt;
+	struct flowi4 fl;
+	u8 vni[3];
+	__be16 df;
+	int err;
+
+	tun_info = OVS_CB(skb)->egress_tun_info;
+	if (unlikely(!tun_info)) {
+		err = -EINVAL;
+		goto error;
+	}
+
+	tun_key = &tun_info->tunnel;
+
+	/* Route lookup */
+	memset(&fl, 0, sizeof(fl));
+	fl.daddr = tun_key->ipv4_dst;
+	fl.saddr = tun_key->ipv4_src;
+	fl.flowi4_tos = RT_TOS(tun_key->ipv4_tos);
+	fl.flowi4_mark = skb->mark;
+	fl.flowi4_proto = IPPROTO_UDP;
+
+	rt = ip_route_output_key(net, &fl);
+	if (IS_ERR(rt)) {
+		err = PTR_ERR(rt);
+		goto error;
+	}
+
+	df = tun_key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
+	sport = udp_flow_src_port(net, skb, 1, USHRT_MAX, true);
+	tunnel_id_to_vni(tun_key->tun_id, vni);
+	skb->ignore_df = 1;
+
+	err = geneve_xmit_skb(geneve_port->gs, rt, skb, fl.saddr,
+			      tun_key->ipv4_dst, tun_key->ipv4_tos,
+			      tun_key->ipv4_ttl, df, sport, dport,
+			      tun_key->tun_flags, vni,
+			      tun_info->options_len, (u8 *)tun_info->options,
+			      false);
+	if (err < 0)
+		ip_rt_put(rt);
+error:
+	return err;
+}
+
+static const char *geneve_get_name(const struct vport *vport)
+{
+	struct geneve_port *geneve_port = geneve_vport(vport);
+
+	return geneve_port->name;
+}
+
+const struct vport_ops ovs_geneve_vport_ops = {
+	.type		= OVS_VPORT_TYPE_GENEVE,
+	.create		= geneve_tnl_create,
+	.destroy	= geneve_tnl_destroy,
+	.get_name	= geneve_get_name,
+	.get_options	= geneve_get_options,
+	.send		= geneve_tnl_send,
+};
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index fe768bd..108b82d 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -106,7 +106,7 @@ static int gre_rcv(struct sk_buff *skb,
 
 	key = key_to_tunnel_id(tpi->key, tpi->seq);
 	ovs_flow_tun_info_init(&tun_info, ip_hdr(skb), key,
-			       filter_tnl_flags(tpi->flags));
+			       filter_tnl_flags(tpi->flags), NULL, 0);
 
 	ovs_vport_receive(vport, skb, &tun_info);
 	return PACKET_RCVD;
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 5fbff2c..2735e01 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -66,7 +66,7 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb, __be32 vx_vni)
 	/* Save outer tunnel values */
 	iph = ip_hdr(skb);
 	key = cpu_to_be64(ntohl(vx_vni) >> 8);
-	ovs_flow_tun_info_init(&tun_info, iph, key, TUNNEL_KEY);
+	ovs_flow_tun_info_init(&tun_info, iph, key, TUNNEL_KEY, NULL, 0);
 
 	ovs_vport_receive(vport, skb, &tun_info);
 }
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 3e50ee8..53001b0 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -48,6 +48,9 @@ static const struct vport_ops *vport_ops_list[] = {
 #ifdef CONFIG_OPENVSWITCH_VXLAN
 	&ovs_vxlan_vport_ops,
 #endif
+#ifdef CONFIG_OPENVSWITCH_GENEVE
+	&ovs_geneve_vport_ops,
+#endif
 };
 
 /* Protected by RCU read lock for reading, ovs_mutex for writing. */
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index e28964a..8942125 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -215,6 +215,7 @@ extern const struct vport_ops ovs_netdev_vport_ops;
 extern const struct vport_ops ovs_internal_vport_ops;
 extern const struct vport_ops ovs_gre_vport_ops;
 extern const struct vport_ops ovs_vxlan_vport_ops;
+extern const struct vport_ops ovs_geneve_vport_ops;
 
 static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
 				      const void *start, unsigned int len)
-- 
1.7.9.5
