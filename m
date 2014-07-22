From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 10/10] openvswitch: Add support for Geneve tunneling.
Date: Tue, 22 Jul 2014 03:19:53 -0700
Message-ID: <1406024393-6778-11-git-send-email-azhou@nicira.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:37447 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751195AbaGVKcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 06:32:10 -0400
Received: by mail-pa0-f48.google.com with SMTP id et14so11584197pad.21
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 03:32:09 -0700 (PDT)
In-Reply-To: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>

The Openvswitch implementation is completely agnostic to the options
that are in use and can handle newly defined options without
further work. It does this by simply matching on a byte array
of options and allowing userspace to setup flows on this array.

Userspace currently implements only support for basic version of
Geneve. It can work with the base header (including the VNI) and
is capable of parsing options but does not currently support any
particular option definitions. Over time, the intention is to
allow options to be matched through OpenFlow without requiring
explicit support in OVS userspace.

Signed-off-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/uapi/linux/openvswitch.h |    2 +
 net/openvswitch/Makefile         |    5 +
 net/openvswitch/datapath.c       |   32 +++--
 net/openvswitch/flow.c           |   10 ++
 net/openvswitch/flow.h           |   19 ++-
 net/openvswitch/flow_netlink.c   |  143 ++++++++++++++++++---
 net/openvswitch/flow_netlink.h   |    2 +-
 net/openvswitch/vport-geneve.c   |  258 ++++++++++++++++++++++++++++++++++++++
 net/openvswitch/vport-gre.c      |    2 +-
 net/openvswitch/vport-vxlan.c    |    2 +-
 net/openvswitch/vport.c          |    1 +
 net/openvswitch/vport.h          |    1 +
 12 files changed, 446 insertions(+), 31 deletions(-)
 create mode 100644 net/openvswitch/vport-geneve.c

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 3b72277..0c6e846 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -189,6 +189,7 @@ enum ovs_vport_type {
 	OVS_VPORT_TYPE_INTERNAL, /* network device implemented by datapath */
 	OVS_VPORT_TYPE_GRE,      /* GRE tunnel. */
 	OVS_VPORT_TYPE_VXLAN,	 /* VXLAN tunnel. */
+	OVS_VPORT_TYPE_GENEVE = 6,   /* Geneve tunnel. */
 	__OVS_VPORT_TYPE_MAX
 };
 
@@ -302,6 +303,7 @@ enum ovs_tunnel_key_attr {
 	OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT,      /* No argument, set DF. */
 	OVS_TUNNEL_KEY_ATTR_CSUM,               /* No argument. CSUM packet. */
 	OVS_TUNNEL_KEY_ATTR_OAM,                /* No argument. OAM frame.  */
+	OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS,        /* Array of Geneve options.  */
 	__OVS_TUNNEL_KEY_ATTR_MAX
 };
 
diff --git a/net/openvswitch/Makefile b/net/openvswitch/Makefile
index 3591cb5..2bbfc32 100644
--- a/net/openvswitch/Makefile
+++ b/net/openvswitch/Makefile
@@ -13,6 +13,7 @@ openvswitch-y := \
 	flow_table.o \
 	vport.o \
 	vport-internal_dev.o \
+	vport-geneve.o  \
 	vport-netdev.o
 
 ifneq ($(CONFIG_OPENVSWITCH_VXLAN),)
@@ -22,3 +23,7 @@ endif
 ifneq ($(CONFIG_OPENVSWITCH_GRE),)
 openvswitch-y += vport-gre.o
 endif
+
+ifneq ($(CONFIG_OPENVSWITCH_GENEVE),)
+openvswitch-y += vport-geneve.o
+endif
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index daa935f..29f877e 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -376,6 +376,7 @@ static size_t key_attr_size(void)
 		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT */
 		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_CSUM */
 		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_OAM */
+		  + nla_total_size(256) /* OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_IN_PORT */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_SKB_MARK */
 		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
@@ -465,7 +466,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 	upcall->dp_ifindex = dp_ifindex;
 
 	nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_KEY);
-	ovs_nla_put_flow(upcall_info->key, upcall_info->key, user_skb);
+	ovs_nla_put_flow(dp, upcall_info->key, upcall_info->key, user_skb);
 	nla_nest_end(user_skb, nla);
 
 	if (upcall_info->userdata)
@@ -662,7 +663,8 @@ static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts)
 }
 
 /* Called with ovs_mutex or RCU read lock. */
-static int ovs_flow_cmd_fill_info(const struct sw_flow *flow, int dp_ifindex,
+static int ovs_flow_cmd_fill_info(struct datapath *dp,
+				  const struct sw_flow *flow, int dp_ifindex,
 				  struct sk_buff *skb, u32 portid,
 				  u32 seq, u32 flags, u8 cmd)
 {
@@ -686,7 +688,8 @@ static int ovs_flow_cmd_fill_info(const struct sw_flow *flow, int dp_ifindex,
 	if (!nla)
 		goto nla_put_failure;
 
-	err = ovs_nla_put_flow(&flow->unmasked_key, &flow->unmasked_key, skb);
+	err = ovs_nla_put_flow(dp, &flow->unmasked_key,
+			       &flow->unmasked_key, skb);
 	if (err)
 		goto error;
 	nla_nest_end(skb, nla);
@@ -695,7 +698,7 @@ static int ovs_flow_cmd_fill_info(const struct sw_flow *flow, int dp_ifindex,
 	if (!nla)
 		goto nla_put_failure;
 
-	err = ovs_nla_put_flow(&flow->key, &flow->mask->key, skb);
+	err = ovs_nla_put_flow(dp, &flow->key, &flow->mask->key, skb);
 	if (err)
 		goto error;
 
@@ -771,7 +774,8 @@ static struct sk_buff *ovs_flow_cmd_alloc_info(const struct sw_flow_actions *act
 }
 
 /* Called with ovs_mutex. */
-static struct sk_buff *ovs_flow_cmd_build_info(const struct sw_flow *flow,
+static struct sk_buff *ovs_flow_cmd_build_info(struct datapath *dp,
+					       const struct sw_flow *flow,
 					       int dp_ifindex,
 					       struct genl_info *info, u8 cmd,
 					       bool always)
@@ -784,7 +788,7 @@ static struct sk_buff *ovs_flow_cmd_build_info(const struct sw_flow *flow,
 	if (!skb || IS_ERR(skb))
 		return skb;
 
-	retval = ovs_flow_cmd_fill_info(flow, dp_ifindex, skb,
+	retval = ovs_flow_cmd_fill_info(dp, flow, dp_ifindex, skb,
 					info->snd_portid, info->snd_seq, 0,
 					cmd);
 	BUG_ON(retval < 0);
@@ -866,7 +870,7 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		}
 
 		if (unlikely(reply)) {
-			error = ovs_flow_cmd_fill_info(new_flow,
+			error = ovs_flow_cmd_fill_info(dp, new_flow,
 						       ovs_header->dp_ifindex,
 						       reply, info->snd_portid,
 						       info->snd_seq, 0,
@@ -901,7 +905,7 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 		rcu_assign_pointer(flow->sf_acts, acts);
 
 		if (unlikely(reply)) {
-			error = ovs_flow_cmd_fill_info(flow,
+			error = ovs_flow_cmd_fill_info(dp, flow,
 						       ovs_header->dp_ifindex,
 						       reply, info->snd_portid,
 						       info->snd_seq, 0,
@@ -1013,7 +1017,7 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 		rcu_assign_pointer(flow->sf_acts, acts);
 
 		if (unlikely(reply)) {
-			error = ovs_flow_cmd_fill_info(flow,
+			error = ovs_flow_cmd_fill_info(dp, flow,
 						       ovs_header->dp_ifindex,
 						       reply, info->snd_portid,
 						       info->snd_seq, 0,
@@ -1022,7 +1026,8 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 		}
 	} else {
 		/* Could not alloc without acts before locking. */
-		reply = ovs_flow_cmd_build_info(flow, ovs_header->dp_ifindex,
+		reply = ovs_flow_cmd_build_info(dp, flow,
+						ovs_header->dp_ifindex,
 						info, OVS_FLOW_CMD_NEW, false);
 		if (unlikely(IS_ERR(reply))) {
 			error = PTR_ERR(reply);
@@ -1085,7 +1090,7 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
-	reply = ovs_flow_cmd_build_info(flow, ovs_header->dp_ifindex, info,
+	reply = ovs_flow_cmd_build_info(dp, flow, ovs_header->dp_ifindex, info,
 					OVS_FLOW_CMD_NEW, true);
 	if (IS_ERR(reply)) {
 		err = PTR_ERR(reply);
@@ -1143,7 +1148,8 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	if (likely(reply)) {
 		if (likely(!IS_ERR(reply))) {
 			rcu_read_lock();	/*To keep RCU checker happy. */
-			err = ovs_flow_cmd_fill_info(flow, ovs_header->dp_ifindex,
+			err = ovs_flow_cmd_fill_info(dp, flow,
+						     ovs_header->dp_ifindex,
 						     reply, info->snd_portid,
 						     info->snd_seq, 0,
 						     OVS_FLOW_CMD_DEL);
@@ -1187,7 +1193,7 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		if (!flow)
 			break;
 
-		if (ovs_flow_cmd_fill_info(flow, ovs_header->dp_ifindex, skb,
+		if (ovs_flow_cmd_fill_info(dp, flow, ovs_header->dp_ifindex, skb,
 					   NETLINK_CB(cb->skb).portid,
 					   cb->nlh->nlmsg_seq, NLM_F_MULTI,
 					   OVS_FLOW_CMD_NEW) < 0)
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 3d0adc5..b487cab 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -454,7 +454,17 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 		struct ovs_tunnel_info *tun_info = OVS_CB(skb)->tun_info;
 		memcpy(&key->tun_key, &tun_info->tunnel,
 			sizeof(key->tun_key));
+		if (tun_info->options) {
+			BUILD_BUG_ON((1 << (sizeof(tun_info->options_len) * 8)) - 1
+					> sizeof(key->tun_opts));
+			memcpy(GENEVE_OPTS(key, tun_info->options_len),
+				tun_info->options, tun_info->options_len);
+			key->tun_opts_len = tun_info->options_len;
+		} else {
+			key->tun_opts_len = 0;
+		}
 	} else {
+		key->tun_opts_len = 0;
 		memset(&key->tun_key, 0, sizeof(key->tun_key));
 	}
 
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 6261ad0..216aa1b 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -51,11 +51,23 @@ struct ovs_key_ipv4_tunnel {
 
 struct ovs_tunnel_info {
 	struct ovs_key_ipv4_tunnel tunnel;
+	struct geneve_opt *options;
+	u8 options_len;
 };
 
+/* Store options at the end of the array if they are less than the
+ * maximum size. This allows us to get the benefits of variable length
+ * matching for small options.
+ */
+#define GENEVE_OPTS(flow_key, opt_len) (struct geneve_opt *) \
+					((flow_key)->tun_opts + \
+					FIELD_SIZEOF(struct sw_flow_key, tun_opts) - \
+					   opt_len)
 static inline void ovs_flow_tun_info_init(struct ovs_tunnel_info *tun_info,
 					 const struct iphdr *iph, __be64 tun_id,
-					 __be16 tun_flags)
+					 __be16 tun_flags,
+					 struct geneve_opt *opts,
+					 u8 opts_len)
 {
 	tun_info->tunnel.tun_id = tun_id;
 	tun_info->tunnel.ipv4_src = iph->saddr;
@@ -67,9 +79,14 @@ static inline void ovs_flow_tun_info_init(struct ovs_tunnel_info *tun_info,
 	/* clear struct padding. */
 	memset((unsigned char *) &tun_info->tunnel + OVS_TUNNEL_KEY_SIZE, 0,
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
index aa7c3d5..e0399c9 100644
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
@@ -88,18 +89,21 @@ static void update_range__(struct sw_flow_match *match,
 		}                                                           \
 	} while (0)
 
-#define SW_FLOW_KEY_MEMCPY(match, field, value_p, len, is_mask) \
+#define SW_FLOW_KEY_MEMCPY_OFFSET(match, offset, value_p, len, is_mask) \
 	do { \
-		update_range__(match, offsetof(struct sw_flow_key, field),  \
-				len, is_mask);                              \
+		update_range__(match, offset, len, is_mask);                \
 		if (is_mask) {						    \
 			if ((match)->mask)				    \
-				memcpy(&(match)->mask->key.field, value_p, len);\
+				memcpy((u8 *)&(match)->mask->key + offset, value_p, len);\
 		} else {                                                    \
-			memcpy(&(match)->key->field, value_p, len);         \
+			memcpy((u8 *)(match)->key + offset, value_p, len);         \
 		}                                                           \
 	} while (0)
 
+#define SW_FLOW_KEY_MEMCPY(match, field, value_p, len, is_mask) \
+	SW_FLOW_KEY_MEMCPY_OFFSET(match, offsetof(struct sw_flow_key, field), \
+				  value_p, len, is_mask)
+
 static u16 range_n_bytes(const struct sw_flow_key_range *range)
 {
 	return range->end - range->start;
@@ -345,6 +349,7 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 			[OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT] = 0,
 			[OVS_TUNNEL_KEY_ATTR_CSUM] = 0,
 			[OVS_TUNNEL_KEY_ATTR_OAM] = 0,
+			[OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS] = -1,
 		};
 
 		if (type > OVS_TUNNEL_KEY_ATTR_MAX) {
@@ -353,7 +358,8 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 			return -EINVAL;
 		}
 
-		if (ovs_tunnel_key_lens[type] != nla_len(a)) {
+		if (ovs_tunnel_key_lens[type] != nla_len(a) &&
+		    ovs_tunnel_key_lens[type] != -1) {
 			OVS_NLERR("IPv4 tunnel attribute type has unexpected "
 				  " length (type=%d, length=%d, expected=%d).\n",
 				  type, nla_len(a), ovs_tunnel_key_lens[type]);
@@ -392,6 +398,56 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 		case OVS_TUNNEL_KEY_ATTR_OAM:
 			tun_flags |= TUNNEL_OAM;
 			break;
+		case OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS:
+			if (nla_len(a) > sizeof(match->key->tun_opts)) {
+				OVS_NLERR("Geneve option length exceeds "
+					  "maximum size (len %d, max %zu).\n",
+					  nla_len(a),
+					  sizeof(match->key->tun_opts));
+				return -EINVAL;
+			}
+
+			if (nla_len(a) % 4 != 0) {
+				OVS_NLERR("Geneve option length is not "
+					  "a multiple of 4 (len %d).\n",
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
+					OVS_NLERR("Geneve option key length (%d)"
+					   " is different from mask length (%d).",
+					   match->key->tun_opts_len, nla_len(a));
+					return -EINVAL;
+				}
+
+				SW_FLOW_KEY_PUT(match, tun_opts_len, 0xff,
+						true);
+			}
+
+			SW_FLOW_KEY_MEMCPY_OFFSET(match,
+				(unsigned long)GENEVE_OPTS((struct sw_flow_key *)0,
+							   nla_len(a)),
+				nla_data(a), nla_len(a), is_mask);
+			break;
 		default:
 			return -EINVAL;
 		}
@@ -420,8 +476,9 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 }
 
 static int ipv4_tun_to_nlattr(struct sk_buff *skb,
-			      const struct ovs_key_ipv4_tunnel *tun_key,
-			      const struct ovs_key_ipv4_tunnel *output)
+			      const struct ovs_key_ipv4_tunnel *output,
+			      const struct geneve_opt *tun_opts,
+			      int swkey_tun_opts_len)
 {
 	struct nlattr *nla;
 
@@ -452,6 +509,9 @@ static int ipv4_tun_to_nlattr(struct sk_buff *skb,
 	if ((output->tun_flags & TUNNEL_OAM) &&
 		nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_OAM))
 		return -EMSGSIZE;
+	if (tun_opts &&
+	    nla_put(skb, OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS,
+		    swkey_tun_opts_len, tun_opts));
 
 	nla_nest_end(skb, nla);
 	return 0;
@@ -881,7 +941,7 @@ int ovs_nla_get_flow_metadata(struct sw_flow *flow,
 	return 0;
 }
 
-int ovs_nla_put_flow(const struct sw_flow_key *swkey,
+int ovs_nla_put_flow(struct datapath *dp, const struct sw_flow_key *swkey,
 		     const struct sw_flow_key *output, struct sk_buff *skb)
 {
 	struct ovs_key_ethernet *eth_key;
@@ -891,9 +951,24 @@ int ovs_nla_put_flow(const struct sw_flow_key *swkey,
 	if (nla_put_u32(skb, OVS_KEY_ATTR_PRIORITY, output->phy.priority))
 		goto nla_put_failure;
 
-	if ((swkey->tun_key.ipv4_dst || is_mask) &&
-	    ipv4_tun_to_nlattr(skb, &swkey->tun_key, &output->tun_key))
-		goto nla_put_failure;
+	if ((swkey->tun_key.ipv4_dst || is_mask)) {
+		const struct geneve_opt *opts = NULL;
+
+		if (!is_mask) {
+			struct vport *in_port;
+
+			in_port = ovs_vport_ovsl_rcu(dp, swkey->phy.in_port);
+			if (in_port->ops->type == OVS_VPORT_TYPE_GENEVE)
+				opts = GENEVE_OPTS(output, swkey->tun_opts_len);
+		} else {
+			if (output->tun_opts_len)
+				opts = GENEVE_OPTS(output, swkey->tun_opts_len);
+		}
+
+		if (ipv4_tun_to_nlattr(skb, &output->tun_key, opts,
+					swkey->tun_opts_len))
+			goto nla_put_failure;
+	}
 
 	if (swkey->phy.in_port == DP_MAX_PORTS) {
 		if (is_mask && (output->phy.in_port == 0xffff))
@@ -1276,17 +1351,55 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
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
-			sizeof(*tun_info));
+			sizeof(*tun_info) + key.tun_opts_len);
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
+		tun_info->options = (struct geneve_opt *)(tun_info + 1);
+		memcpy(tun_info->options, GENEVE_OPTS(&key, key.tun_opts_len),
+			key.tun_opts_len);
+	} else {
+		tun_info->options = NULL;
+	}
 
 	add_nested_action_end(*sfa, start);
 
@@ -1561,7 +1674,9 @@ static int set_action_to_attr(const struct nlattr *a, struct sk_buff *skb)
 			return -EMSGSIZE;
 
 		err = ipv4_tun_to_nlattr(skb, &tun_info->tunnel,
-					 &tun_info->tunnel);
+					 tun_info->options_len ?
+						tun_info->options : NULL,
+					 tun_info->options_len);
 		if (err)
 			return err;
 		nla_nest_end(skb, start);
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index 4401510..42de456 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -40,7 +40,7 @@
 void ovs_match_init(struct sw_flow_match *match,
 		    struct sw_flow_key *key, struct sw_flow_mask *mask);
 
-int ovs_nla_put_flow(const struct sw_flow_key *,
+int ovs_nla_put_flow(struct datapath *dp, const struct sw_flow_key *,
 		     const struct sw_flow_key *, struct sk_buff *);
 int ovs_nla_get_flow_metadata(struct sw_flow *flow,
 			      const struct nlattr *attr);
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
new file mode 100644
index 0000000..b1b0a3b
--- /dev/null
+++ b/net/openvswitch/vport-geneve.c
@@ -0,0 +1,258 @@
+/*
+ * Copyright (c) 2014 Nicira, Inc.
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
+	struct vport *vport = gs->uts.data;
+	struct genevehdr *geneveh;
+	int opts_len;
+	struct ovs_tunnel_info tun_info;
+	__be64 key;
+	__be16 flags;
+
+	if (unlikely(!pskb_may_pull(skb, GENEVE_BASE_HLEN)))
+		goto error;
+
+	geneveh = geneve_hdr(skb);
+
+	if (unlikely(geneveh->ver != GENEVE_VER))
+		goto error;
+
+	if (unlikely(geneveh->proto_type != htons(ETH_P_TEB)))
+		goto error;
+
+	opts_len = geneveh->opt_len * 4;
+
+	flags = TUNNEL_KEY |
+		(udp_hdr(skb)->check != 0 ? TUNNEL_CSUM : 0) |
+		(geneveh->oam ? TUNNEL_OAM : 0) |
+		(geneveh->critical ? TUNNEL_CRIT_OPT : 0);
+
+	key = vni_to_tunnel_id(geneveh->vni);
+	ovs_flow_tun_info_init(&tun_info, ip_hdr(skb), key, flags,
+			       geneveh->options, opts_len);
+
+	ovs_vport_receive(vport, skb, &tun_info);
+	return;
+
+error:
+	kfree_skb(skb);
+}
+
+static int geneve_get_options(const struct vport *vport,
+			      struct sk_buff *skb)
+{
+	struct geneve_port *geneve_port = geneve_vport(vport);
+	__be16 sport;
+
+	sport = ntohs(inet_sk(geneve_port->gs->uts.sock->sk)->inet_sport);
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
+static int geneve_send(struct vport *vport, struct sk_buff *skb)
+{
+	struct ovs_key_ipv4_tunnel *tun_key;
+	struct ovs_tunnel_info *tun_info = OVS_CB(skb)->tun_info;
+	struct net *net = ovs_dp_get_net(vport->dp);
+	struct geneve_port *geneve_port = geneve_vport(vport);
+	__be16 dport = inet_sk(geneve_port->gs->uts.sock->sk)->inet_sport;
+	__be16 sport;
+	struct rtable *rt;
+	struct flowi4 fl;
+	u8 vni[3];
+	__be16 df;
+	int err;
+	int sent;
+
+	if (unlikely(!tun_info))
+		return -EINVAL;
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
+
+	sent = geneve_xmit_skb(geneve_port->gs, rt, skb, fl.saddr,
+			       tun_key->ipv4_dst, tun_key->ipv4_tos,
+			       tun_key->ipv4_ttl, df, sport, dport,
+			       tun_key->tun_flags, vni,
+			       tun_info->options_len, (u8 *)tun_info->options,
+			       false);
+	if (!sent)
+		ip_rt_put(rt);
+
+	return sent;
+
+error:
+	return err;
+}
+
+static const char *geneve_get_name(const struct vport *vport)
+{
+	struct geneve_port *geneve_port = geneve_vport(vport);
+	return geneve_port->name;
+}
+
+const struct vport_ops ovs_geneve_vport_ops = {
+	.type		= OVS_VPORT_TYPE_GENEVE,
+	.create		= geneve_tnl_create,
+	.destroy	= geneve_tnl_destroy,
+	.get_name	= geneve_get_name,
+	.get_options	= geneve_get_options,
+	.send		= geneve_send,
+};
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index d4fcbb2..1aeeed6 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -104,7 +104,7 @@ static int gre_rcv(struct sk_buff *skb,
 
 	key = key_to_tunnel_id(tpi->key, tpi->seq);
 	ovs_flow_tun_info_init(&tun_info, ip_hdr(skb), key,
-			       filter_tnl_flags(tpi->flags));
+			       filter_tnl_flags(tpi->flags), NULL, 0);
 
 	ovs_vport_receive(vport, skb, &tun_info);
 	return PACKET_RCVD;
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 3835143..eded300 100644
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
index 39e2c9c..038d14a 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -41,6 +41,7 @@ static void ovs_vport_record_error(struct vport *,
 static const struct vport_ops *vport_ops_list[] = {
 	&ovs_netdev_vport_ops,
 	&ovs_internal_vport_ops,
+	&ovs_geneve_vport_ops,
 
 #ifdef CONFIG_OPENVSWITCH_GRE
 	&ovs_gre_vport_ops,
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 400cd1e..d2eb700 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -197,6 +197,7 @@ void ovs_vport_receive(struct vport *, struct sk_buff *,
  * add yours to the list at the top of vport.c. */
 extern const struct vport_ops ovs_netdev_vport_ops;
 extern const struct vport_ops ovs_internal_vport_ops;
+extern const struct vport_ops ovs_geneve_vport_ops;
 extern const struct vport_ops ovs_gre_vport_ops;
 extern const struct vport_ops ovs_vxlan_vport_ops;
 
-- 
1.7.9.5
