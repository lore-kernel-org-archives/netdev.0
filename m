From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 2/6] openvswitch: Extend packet attribute for egress tunnel info
Date: Sun,  9 Nov 2014 19:59:09 -0800
Message-ID: <1415591949-1593-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Wenyu Zhang <wenyuz@vmware.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:44972 "HELO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752088AbaKJD7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 22:59:12 -0500
Received: by mail-pa0-f52.google.com with SMTP id fa1so7375531pad.11
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 19:59:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wenyu Zhang <wenyuz@vmware.com>

OVS vswitch has extended IPFIX exporter to export tunnel headers
to improve network visibility.
To export this information userspace needs to know egress tunnel
for given packet. By extending packet attributes datapath can
export egress tunnel info for given packet. So that userspace
can ask for egress tunnel info in userspace action. This
information is used to build IPFIX data for given flow.

Signed-off-by: Wenyu Zhang <wenyuz@vmware.com>
Acked-by: Romain Lenglet <rlenglet@vmware.com>
Acked-by: Ben Pfaff <blp@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/uapi/linux/openvswitch.h | 13 +++++++++
 net/openvswitch/actions.c        | 19 ++++++++++++
 net/openvswitch/datapath.c       | 21 +++++++++++---
 net/openvswitch/datapath.h       |  2 ++
 net/openvswitch/flow.h           | 62 +++++++++++++++++++++++++++++++---------
 net/openvswitch/flow_netlink.c   | 54 +++++++++++++++++++++++++++-------
 net/openvswitch/flow_netlink.h   |  3 ++
 net/openvswitch/vport-geneve.c   | 21 +++++++++++++-
 net/openvswitch/vport-gre.c      | 12 +++++++-
 net/openvswitch/vport-vxlan.c    | 24 +++++++++++++++-
 net/openvswitch/vport.c          | 61 +++++++++++++++++++++++++++++++++++++++
 net/openvswitch/vport.h          | 14 +++++++++
 12 files changed, 275 insertions(+), 31 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 26c36c4..cf81856 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -157,6 +157,11 @@ enum ovs_packet_cmd {
  * notification if the %OVS_ACTION_ATTR_USERSPACE action specified an
  * %OVS_USERSPACE_ATTR_USERDATA attribute, with the same length and content
  * specified there.
+ * @OVS_PACKET_ATTR_EGRESS_TUN_KEY: Present for an %OVS_PACKET_CMD_ACTION
+ * notification if the %OVS_ACTION_ATTR_USERSPACE action specified an
+ * %OVS_USERSPACE_ATTR_EGRESS_TUN_PORT attribute, which is sent only if the
+ * output port is actually a tunnel port. Contains the output tunnel key
+ * extracted from the packet as nested %OVS_TUNNEL_KEY_ATTR_* attributes.
  *
  * These attributes follow the &struct ovs_header within the Generic Netlink
  * payload for %OVS_PACKET_* commands.
@@ -167,6 +172,8 @@ enum ovs_packet_attr {
 	OVS_PACKET_ATTR_KEY,         /* Nested OVS_KEY_ATTR_* attributes. */
 	OVS_PACKET_ATTR_ACTIONS,     /* Nested OVS_ACTION_ATTR_* attributes. */
 	OVS_PACKET_ATTR_USERDATA,    /* OVS_ACTION_ATTR_USERSPACE arg. */
+	OVS_PACKET_ATTR_EGRESS_TUN_KEY,  /* Nested OVS_TUNNEL_KEY_ATTR_*
+					    attributes. */
 	__OVS_PACKET_ATTR_MAX
 };
 
@@ -315,6 +322,8 @@ enum ovs_tunnel_key_attr {
 	OVS_TUNNEL_KEY_ATTR_CSUM,               /* No argument. CSUM packet. */
 	OVS_TUNNEL_KEY_ATTR_OAM,                /* No argument. OAM frame.  */
 	OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS,        /* Array of Geneve options. */
+	OVS_TUNNEL_KEY_ATTR_TP_SRC,		/* be16 src Transport Port. */
+	OVS_TUNNEL_KEY_ATTR_TP_DST,		/* be16 dst Transport Port. */
 	__OVS_TUNNEL_KEY_ATTR_MAX
 };
 
@@ -480,11 +489,15 @@ enum ovs_sample_attr {
  * message should be sent.  Required.
  * @OVS_USERSPACE_ATTR_USERDATA: If present, its variable-length argument is
  * copied to the %OVS_PACKET_CMD_ACTION message as %OVS_PACKET_ATTR_USERDATA.
+ * @OVS_USERSPACE_ATTR_EGRESS_TUN_PORT: If present, u32 output port to get
+ * tunnel info.
  */
 enum ovs_userspace_attr {
 	OVS_USERSPACE_ATTR_UNSPEC,
 	OVS_USERSPACE_ATTR_PID,	      /* u32 Netlink PID to receive upcalls. */
 	OVS_USERSPACE_ATTR_USERDATA,  /* Optional user-specified cookie. */
+	OVS_USERSPACE_ATTR_EGRESS_TUN_PORT,  /* Optional, u32 output port
+					      * to get tunnel info. */
 	__OVS_USERSPACE_ATTR_MAX
 };
 
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index f7e5891..ceb618c 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -564,6 +564,7 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
 static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 			    struct sw_flow_key *key, const struct nlattr *attr)
 {
+	struct ovs_tunnel_info info;
 	struct dp_upcall_info upcall;
 	const struct nlattr *a;
 	int rem;
@@ -572,6 +573,7 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 	upcall.key = key;
 	upcall.userdata = NULL;
 	upcall.portid = 0;
+	upcall.egress_tun_info = NULL;
 
 	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
 		 a = nla_next(a, &rem)) {
@@ -583,7 +585,24 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 		case OVS_USERSPACE_ATTR_PID:
 			upcall.portid = nla_get_u32(a);
 			break;
+
+		case OVS_USERSPACE_ATTR_EGRESS_TUN_PORT: {
+			/* Get out tunnel info. */
+			struct vport *vport;
+
+			vport = ovs_vport_rcu(dp, nla_get_u32(a));
+			if (vport) {
+				int err;
+
+				err = ovs_vport_get_egress_tun_info(vport, skb,
+								    &info);
+				if (!err)
+					upcall.egress_tun_info = &info;
+			}
+			break;
 		}
+
+		} /* End of switch. */
 	}
 
 	return ovs_dp_upcall(dp, skb, &upcall);
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 6cfb44f..c2ac340 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -274,6 +274,7 @@ void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key)
 		upcall.key = key;
 		upcall.userdata = NULL;
 		upcall.portid = ovs_vport_find_upcall_portid(p, skb);
+		upcall.egress_tun_info = NULL;
 		error = ovs_dp_upcall(dp, skb, &upcall);
 		if (unlikely(error))
 			kfree_skb(skb);
@@ -375,7 +376,7 @@ static int queue_gso_packets(struct datapath *dp, struct sk_buff *skb,
 	return err;
 }
 
-static size_t upcall_msg_size(const struct nlattr *userdata,
+static size_t upcall_msg_size(const struct dp_upcall_info *upcall_info,
 			      unsigned int hdrlen)
 {
 	size_t size = NLMSG_ALIGN(sizeof(struct ovs_header))
@@ -383,8 +384,12 @@ static size_t upcall_msg_size(const struct nlattr *userdata,
 		+ nla_total_size(ovs_key_attr_size()); /* OVS_PACKET_ATTR_KEY */
 
 	/* OVS_PACKET_ATTR_USERDATA */
-	if (userdata)
-		size += NLA_ALIGN(userdata->nla_len);
+	if (upcall_info->userdata)
+		size += NLA_ALIGN(upcall_info->userdata->nla_len);
+
+	/* OVS_PACKET_ATTR_EGRESS_TUN_KEY */
+	if (upcall_info->egress_tun_info)
+		size += nla_total_size(ovs_tun_key_attr_size());
 
 	return size;
 }
@@ -440,7 +445,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 	else
 		hlen = skb->len;
 
-	len = upcall_msg_size(upcall_info->userdata, hlen);
+	len = upcall_msg_size(upcall_info, hlen);
 	user_skb = genlmsg_new_unicast(len, &info, GFP_ATOMIC);
 	if (!user_skb) {
 		err = -ENOMEM;
@@ -461,6 +466,14 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 			  nla_len(upcall_info->userdata),
 			  nla_data(upcall_info->userdata));
 
+	if (upcall_info->egress_tun_info) {
+		nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_EGRESS_TUN_KEY);
+		err = ovs_nla_put_egress_tunnel_key(user_skb,
+						    upcall_info->egress_tun_info);
+		BUG_ON(err);
+		nla_nest_end(user_skb, nla);
+	}
+
 	/* Only reserve room for attribute header, packet data is added
 	 * in skb_zerocopy() */
 	if (!(nla = nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, 0))) {
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 1c56a80..2bc577b 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -114,12 +114,14 @@ struct ovs_skb_cb {
  * @pid: Netlink PID to which packet should be sent.  If @pid is 0 then no
  * packet is sent and the packet is accounted in the datapath's @n_lost
  * counter.
+ * @egress_tun_info: If nonnull, becomes %OVS_PACKET_ATTR_EGRESS_TUN_KEY.
  */
 struct dp_upcall_info {
 	u8 cmd;
 	const struct sw_flow_key *key;
 	const struct nlattr *userdata;
 	u32 portid;
+	const struct ovs_tunnel_info *egress_tun_info;
 };
 
 /**
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 4962bee..543b358 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -37,8 +37,8 @@ struct sk_buff;
 
 /* Used to memset ovs_key_ipv4_tunnel padding. */
 #define OVS_TUNNEL_KEY_SIZE					\
-	(offsetof(struct ovs_key_ipv4_tunnel, ipv4_ttl) +	\
-	FIELD_SIZEOF(struct ovs_key_ipv4_tunnel, ipv4_ttl))
+	(offsetof(struct ovs_key_ipv4_tunnel, tp_dst) +		\
+	 FIELD_SIZEOF(struct ovs_key_ipv4_tunnel, tp_dst))
 
 struct ovs_key_ipv4_tunnel {
 	__be64 tun_id;
@@ -47,6 +47,8 @@ struct ovs_key_ipv4_tunnel {
 	__be16 tun_flags;
 	u8   ipv4_tos;
 	u8   ipv4_ttl;
+	__be16 tp_src;
+	__be16 tp_dst;
 } __packed __aligned(4); /* Minimize padding. */
 
 struct ovs_tunnel_info {
@@ -64,27 +66,59 @@ struct ovs_tunnel_info {
 			       FIELD_SIZEOF(struct sw_flow_key, tun_opts) - \
 			       opt_len))
 
-static inline void ovs_flow_tun_info_init(struct ovs_tunnel_info *tun_info,
-					  const struct iphdr *iph,
-					  __be64 tun_id, __be16 tun_flags,
-					  struct geneve_opt *opts,
-					  u8 opts_len)
+static inline void __ovs_flow_tun_info_init(struct ovs_tunnel_info *tun_info,
+					    __be32 saddr, __be32 daddr,
+					    u8 tos, u8 ttl,
+					    __be16 tp_src,
+					    __be16 tp_dst,
+					    __be64 tun_id,
+					    __be16 tun_flags,
+					    struct geneve_opt *opts,
+					    u8 opts_len)
 {
 	tun_info->tunnel.tun_id = tun_id;
-	tun_info->tunnel.ipv4_src = iph->saddr;
-	tun_info->tunnel.ipv4_dst = iph->daddr;
-	tun_info->tunnel.ipv4_tos = iph->tos;
-	tun_info->tunnel.ipv4_ttl = iph->ttl;
+	tun_info->tunnel.ipv4_src = saddr;
+	tun_info->tunnel.ipv4_dst = daddr;
+	tun_info->tunnel.ipv4_tos = tos;
+	tun_info->tunnel.ipv4_ttl = ttl;
 	tun_info->tunnel.tun_flags = tun_flags;
 
-	/* clear struct padding. */
-	memset((unsigned char *)&tun_info->tunnel + OVS_TUNNEL_KEY_SIZE, 0,
-	       sizeof(tun_info->tunnel) - OVS_TUNNEL_KEY_SIZE);
+	/* For the tunnel types on the top of IPsec, the tp_src and tp_dst of
+	 * the upper tunnel are used.
+	 * E.g: GRE over IPSEC, the tp_src and tp_port are zero.
+	 */
+	tun_info->tunnel.tp_src = tp_src;
+	tun_info->tunnel.tp_dst = tp_dst;
+
+	/* Clear struct padding. */
+	if (sizeof(tun_info->tunnel) != OVS_TUNNEL_KEY_SIZE)
+		memset((unsigned char *)&tun_info->tunnel + OVS_TUNNEL_KEY_SIZE,
+		       0, sizeof(tun_info->tunnel) - OVS_TUNNEL_KEY_SIZE);
 
 	tun_info->options = opts;
 	tun_info->options_len = opts_len;
 }
 
+static inline void ovs_flow_tun_info_init(struct ovs_tunnel_info *tun_info,
+					  const struct iphdr *iph,
+					  __be16 tp_src,
+					  __be16 tp_dst,
+					  __be64 tun_id,
+					  __be16 tun_flags,
+					  struct geneve_opt *opts,
+					  u8 opts_len)
+{
+	__ovs_flow_tun_info_init(tun_info, iph->saddr, iph->daddr,
+				 iph->tos, iph->ttl,
+				 tp_src, tp_dst,
+				 tun_id, tun_flags,
+				 opts, opts_len);
+}
+
+#define OVS_SW_FLOW_KEY_METADATA_SIZE			\
+	(offsetof(struct sw_flow_key, recirc_id) +	\
+	FIELD_SIZEOF(struct sw_flow_key, recirc_id))
+
 struct sw_flow_key {
 	u8 tun_opts[255];
 	u8 tun_opts_len;
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index ed31097..98a3e96 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -245,6 +245,24 @@ static bool match_validate(const struct sw_flow_match *match,
 	return true;
 }
 
+size_t ovs_tun_key_attr_size(void)
+{
+	/* Whenever adding new OVS_TUNNEL_KEY_ FIELDS, we should consider
+	 * updating this function.
+	 */
+	return    nla_total_size(8)    /* OVS_TUNNEL_KEY_ATTR_ID */
+		+ nla_total_size(4)    /* OVS_TUNNEL_KEY_ATTR_IPV4_SRC */
+		+ nla_total_size(4)    /* OVS_TUNNEL_KEY_ATTR_IPV4_DST */
+		+ nla_total_size(1)    /* OVS_TUNNEL_KEY_ATTR_TOS */
+		+ nla_total_size(1)    /* OVS_TUNNEL_KEY_ATTR_TTL */
+		+ nla_total_size(0)    /* OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT */
+		+ nla_total_size(0)    /* OVS_TUNNEL_KEY_ATTR_CSUM */
+		+ nla_total_size(0)    /* OVS_TUNNEL_KEY_ATTR_OAM */
+		+ nla_total_size(256)  /* OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS */
+		+ nla_total_size(2)    /* OVS_TUNNEL_KEY_ATTR_TP_SRC */
+		+ nla_total_size(2);   /* OVS_TUNNEL_KEY_ATTR_TP_DST */
+}
+
 size_t ovs_key_attr_size(void)
 {
 	/* Whenever adding new OVS_KEY_ FIELDS, we should consider
@@ -254,15 +272,7 @@ size_t ovs_key_attr_size(void)
 
 	return    nla_total_size(4)   /* OVS_KEY_ATTR_PRIORITY */
 		+ nla_total_size(0)   /* OVS_KEY_ATTR_TUNNEL */
-		  + nla_total_size(8)   /* OVS_TUNNEL_KEY_ATTR_ID */
-		  + nla_total_size(4)   /* OVS_TUNNEL_KEY_ATTR_IPV4_SRC */
-		  + nla_total_size(4)   /* OVS_TUNNEL_KEY_ATTR_IPV4_DST */
-		  + nla_total_size(1)   /* OVS_TUNNEL_KEY_ATTR_TOS */
-		  + nla_total_size(1)   /* OVS_TUNNEL_KEY_ATTR_TTL */
-		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT */
-		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_CSUM */
-		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_OAM */
-		  + nla_total_size(256) /* OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS */
+		  + ovs_tun_key_attr_size()
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_IN_PORT */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_SKB_MARK */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_DP_HASH */
@@ -393,6 +403,8 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 			[OVS_TUNNEL_KEY_ATTR_TTL] = 1,
 			[OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT] = 0,
 			[OVS_TUNNEL_KEY_ATTR_CSUM] = 0,
+			[OVS_TUNNEL_KEY_ATTR_TP_SRC] = sizeof(u16),
+			[OVS_TUNNEL_KEY_ATTR_TP_DST] = sizeof(u16),
 			[OVS_TUNNEL_KEY_ATTR_OAM] = 0,
 			[OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS] = -1,
 		};
@@ -440,6 +452,14 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 		case OVS_TUNNEL_KEY_ATTR_CSUM:
 			tun_flags |= TUNNEL_CSUM;
 			break;
+		case OVS_TUNNEL_KEY_ATTR_TP_SRC:
+			SW_FLOW_KEY_PUT(match, tun_key.tp_src,
+					nla_get_be16(a), is_mask);
+			break;
+		case OVS_TUNNEL_KEY_ATTR_TP_DST:
+			SW_FLOW_KEY_PUT(match, tun_key.tp_dst,
+					nla_get_be16(a), is_mask);
+			break;
 		case OVS_TUNNEL_KEY_ATTR_OAM:
 			tun_flags |= TUNNEL_OAM;
 			break;
@@ -548,6 +568,12 @@ static int __ipv4_tun_to_nlattr(struct sk_buff *skb,
 	if ((output->tun_flags & TUNNEL_CSUM) &&
 	    nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_CSUM))
 		return -EMSGSIZE;
+	if (output->tp_src &&
+	    nla_put_be16(skb, OVS_TUNNEL_KEY_ATTR_TP_SRC, output->tp_src))
+		return -EMSGSIZE;
+	if (output->tp_dst &&
+	    nla_put_be16(skb, OVS_TUNNEL_KEY_ATTR_TP_DST, output->tp_dst))
+		return -EMSGSIZE;
 	if ((output->tun_flags & TUNNEL_OAM) &&
 	    nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_OAM))
 		return -EMSGSIZE;
@@ -559,7 +585,6 @@ static int __ipv4_tun_to_nlattr(struct sk_buff *skb,
 	return 0;
 }
 
-
 static int ipv4_tun_to_nlattr(struct sk_buff *skb,
 			      const struct ovs_key_ipv4_tunnel *output,
 			      const struct geneve_opt *tun_opts,
@@ -580,6 +605,14 @@ static int ipv4_tun_to_nlattr(struct sk_buff *skb,
 	return 0;
 }
 
+int ovs_nla_put_egress_tunnel_key(struct sk_buff *skb,
+				  const struct ovs_tunnel_info *egress_tun_info)
+{
+	return __ipv4_tun_to_nlattr(skb, &egress_tun_info->tunnel,
+				    egress_tun_info->options,
+				    egress_tun_info->options_len);
+}
+
 static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 				 const struct nlattr **a, bool is_mask)
 {
@@ -1653,6 +1686,7 @@ static int validate_userspace(const struct nlattr *attr)
 	static const struct nla_policy userspace_policy[OVS_USERSPACE_ATTR_MAX + 1] = {
 		[OVS_USERSPACE_ATTR_PID] = {.type = NLA_U32 },
 		[OVS_USERSPACE_ATTR_USERDATA] = {.type = NLA_UNSPEC },
+		[OVS_USERSPACE_ATTR_EGRESS_TUN_PORT] = {.type = NLA_U32 },
 	};
 	struct nlattr *a[OVS_USERSPACE_ATTR_MAX + 1];
 	int error;
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index eb0b177..90bbe37 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -37,6 +37,7 @@
 
 #include "flow.h"
 
+size_t ovs_tun_key_attr_size(void);
 size_t ovs_key_attr_size(void);
 
 void ovs_match_init(struct sw_flow_match *match,
@@ -49,6 +50,8 @@ int ovs_nla_get_flow_metadata(const struct nlattr *, struct sw_flow_key *);
 int ovs_nla_get_match(struct sw_flow_match *match,
 		      const struct nlattr *,
 		      const struct nlattr *);
+int ovs_nla_put_egress_tunnel_key(struct sk_buff *,
+				  const struct ovs_tunnel_info *);
 
 int ovs_nla_copy_actions(const struct nlattr *attr,
 			 const struct sw_flow_key *key,
diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
index 70c9765..e31f19c 100644
--- a/net/openvswitch/vport-geneve.c
+++ b/net/openvswitch/vport-geneve.c
@@ -97,7 +97,9 @@ static void geneve_rcv(struct geneve_sock *gs, struct sk_buff *skb)
 
 	key = vni_to_tunnel_id(geneveh->vni);
 
-	ovs_flow_tun_info_init(&tun_info, ip_hdr(skb), key, flags,
+	ovs_flow_tun_info_init(&tun_info, ip_hdr(skb),
+			       udp_hdr(skb)->source, udp_hdr(skb)->dest,
+			       key, flags,
 			       geneveh->options, opts_len);
 
 	ovs_vport_receive(vport, skb, &tun_info);
@@ -228,6 +230,22 @@ static const char *geneve_get_name(const struct vport *vport)
 	return geneve_port->name;
 }
 
+static int geneve_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
+				      struct ovs_tunnel_info *egress_tun_info)
+{
+	struct geneve_port *geneve_port = geneve_vport(vport);
+	struct net *net = ovs_dp_get_net(vport->dp);
+	__be16 dport = inet_sk(geneve_port->gs->sock->sk)->inet_sport;
+	__be16 sport = udp_flow_src_port(net, skb, 1, USHRT_MAX, true);
+
+	/* Get tp_src and tp_dst, refert to geneve_build_header().
+	 */
+	return ovs_tunnel_get_egress_info(egress_tun_info,
+					  ovs_dp_get_net(vport->dp),
+					  OVS_CB(skb)->egress_tun_info,
+					  IPPROTO_UDP, skb->mark, sport, dport);
+}
+
 static struct vport_ops ovs_geneve_vport_ops = {
 	.type		= OVS_VPORT_TYPE_GENEVE,
 	.create		= geneve_tnl_create,
@@ -236,6 +254,7 @@ static struct vport_ops ovs_geneve_vport_ops = {
 	.get_options	= geneve_get_options,
 	.send		= geneve_tnl_send,
 	.owner          = THIS_MODULE,
+	.get_egress_tun_info	= geneve_get_egress_tun_info,
 };
 
 static int __init ovs_geneve_tnl_init(void)
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 00270b6..8e61a5c 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -108,7 +108,7 @@ static int gre_rcv(struct sk_buff *skb,
 		return PACKET_REJECT;
 
 	key = key_to_tunnel_id(tpi->key, tpi->seq);
-	ovs_flow_tun_info_init(&tun_info, ip_hdr(skb), key,
+	ovs_flow_tun_info_init(&tun_info, ip_hdr(skb), 0, 0, key,
 			       filter_tnl_flags(tpi->flags), NULL, 0);
 
 	ovs_vport_receive(vport, skb, &tun_info);
@@ -284,12 +284,22 @@ static void gre_tnl_destroy(struct vport *vport)
 	gre_exit();
 }
 
+static int gre_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
+				   struct ovs_tunnel_info *egress_tun_info)
+{
+	return ovs_tunnel_get_egress_info(egress_tun_info,
+					  ovs_dp_get_net(vport->dp),
+					  OVS_CB(skb)->egress_tun_info,
+					  IPPROTO_GRE, skb->mark, 0, 0);
+}
+
 static struct vport_ops ovs_gre_vport_ops = {
 	.type		= OVS_VPORT_TYPE_GRE,
 	.create		= gre_create,
 	.destroy	= gre_tnl_destroy,
 	.get_name	= gre_get_name,
 	.send		= gre_tnl_send,
+	.get_egress_tun_info	= gre_get_egress_tun_info,
 	.owner		= THIS_MODULE,
 };
 
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index 965e750..38f95a5 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -69,7 +69,9 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb, __be32 vx_vni)
 	/* Save outer tunnel values */
 	iph = ip_hdr(skb);
 	key = cpu_to_be64(ntohl(vx_vni) >> 8);
-	ovs_flow_tun_info_init(&tun_info, iph, key, TUNNEL_KEY, NULL, 0);
+	ovs_flow_tun_info_init(&tun_info, iph,
+			       udp_hdr(skb)->source, udp_hdr(skb)->dest,
+			       key, TUNNEL_KEY, NULL, 0);
 
 	ovs_vport_receive(vport, skb, &tun_info);
 }
@@ -189,6 +191,25 @@ error:
 	return err;
 }
 
+static int vxlan_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
+				     struct ovs_tunnel_info *egress_tun_info)
+{
+	struct net *net = ovs_dp_get_net(vport->dp);
+	struct vxlan_port *vxlan_port = vxlan_vport(vport);
+	__be16 dst_port = inet_sk(vxlan_port->vs->sock->sk)->inet_sport;
+	__be16 src_port;
+	int port_min;
+	int port_max;
+
+	inet_get_local_port_range(net, &port_min, &port_max);
+	src_port = udp_flow_src_port(net, skb, 0, 0, true);
+
+	return ovs_tunnel_get_egress_info(egress_tun_info, net,
+					  OVS_CB(skb)->egress_tun_info,
+					  IPPROTO_UDP, skb->mark,
+					  src_port, dst_port);
+}
+
 static const char *vxlan_get_name(const struct vport *vport)
 {
 	struct vxlan_port *vxlan_port = vxlan_vport(vport);
@@ -202,6 +223,7 @@ static struct vport_ops ovs_vxlan_vport_ops = {
 	.get_name	= vxlan_get_name,
 	.get_options	= vxlan_get_options,
 	.send		= vxlan_tnl_send,
+	.get_egress_tun_info	= vxlan_get_egress_tun_info,
 	.owner		= THIS_MODULE,
 };
 
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 4b5dd18..630e819 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -573,3 +573,64 @@ void ovs_vport_deferred_free(struct vport *vport)
 	call_rcu(&vport->rcu, free_vport_rcu);
 }
 EXPORT_SYMBOL_GPL(ovs_vport_deferred_free);
+
+int ovs_tunnel_get_egress_info(struct ovs_tunnel_info *egress_tun_info,
+			       struct net *net,
+			       const struct ovs_tunnel_info *tun_info,
+			       u8 ipproto,
+			       u32 skb_mark,
+			       __be16 tp_src,
+			       __be16 tp_dst)
+{
+	const struct ovs_key_ipv4_tunnel *tun_key;
+	struct rtable *rt;
+	struct flowi4 fl;
+
+	if (unlikely(!tun_info))
+		return -EINVAL;
+
+	tun_key = &tun_info->tunnel;
+
+	/* Route lookup to get srouce IP address.
+	 * The process may need to be changed if the corresponding process
+	 * in vports ops changed.
+	 */
+	memset(&fl, 0, sizeof(fl));
+	fl.daddr = tun_key->ipv4_dst;
+	fl.saddr = tun_key->ipv4_src;
+	fl.flowi4_tos = RT_TOS(tun_key->ipv4_tos);
+	fl.flowi4_mark = skb_mark;
+	fl.flowi4_proto = IPPROTO_GRE;
+
+	rt = ip_route_output_key(net, &fl);
+	if (IS_ERR(rt))
+		return PTR_ERR(rt);
+
+	ip_rt_put(rt);
+
+	/* Generate egress_tun_info based on tun_info,
+	 * saddr, tp_src and tp_dst
+	 */
+	__ovs_flow_tun_info_init(egress_tun_info,
+				 fl.saddr, tun_key->ipv4_dst,
+				 tun_key->ipv4_tos,
+				 tun_key->ipv4_ttl,
+				 tp_src, tp_dst,
+				 tun_key->tun_id,
+				 tun_key->tun_flags,
+				 tun_info->options,
+				 tun_info->options_len);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ovs_tunnel_get_egress_info);
+
+int ovs_vport_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
+				  struct ovs_tunnel_info *info)
+{
+	/* get_egress_tun_info() is only implemented on tunnel ports. */
+	if (unlikely(!vport->ops->get_egress_tun_info))
+		return -EINVAL;
+
+	return vport->ops->get_egress_tun_info(vport, skb, info);
+}
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index e41c3fa..0635d1d 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -58,6 +58,16 @@ u32 ovs_vport_find_upcall_portid(const struct vport *, struct sk_buff *);
 
 int ovs_vport_send(struct vport *, struct sk_buff *);
 
+int ovs_tunnel_get_egress_info(struct ovs_tunnel_info *egress_tun_info,
+			       struct net *net,
+			       const struct ovs_tunnel_info *tun_info,
+			       u8 ipproto,
+			       u32 skb_mark,
+			       __be16 tp_src,
+			       __be16 tp_dst);
+int ovs_vport_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
+				  struct ovs_tunnel_info *info);
+
 /* The following definitions are for implementers of vport devices: */
 
 struct vport_err_stats {
@@ -146,6 +156,8 @@ struct vport_parms {
  * @get_name: Get the device's name.
  * @send: Send a packet on the device.  Returns the length of the packet sent,
  * zero for dropped packets or negative for error.
+ * @get_egress_tun_info: Get the egress tunnel 5-tuple and other info for
+ * a packet.
  */
 struct vport_ops {
 	enum ovs_vport_type type;
@@ -161,6 +173,8 @@ struct vport_ops {
 	const char *(*get_name)(const struct vport *);
 
 	int (*send)(struct vport *, struct sk_buff *);
+	int (*get_egress_tun_info)(struct vport *, struct sk_buff *,
+				   struct ovs_tunnel_info *);
 
 	struct module *owner;
 	struct list_head list;
-- 
1.9.3
