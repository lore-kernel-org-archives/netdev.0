From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 1/5] vxlan: implement GPE in L2 mode
Date: Fri, 26 Feb 2016 08:48:37 +0100
Message-ID: <6fe53252314d644e994950522d4320bc54ced928.1456472746.git.jbenc@redhat.com>
References: <cover.1456472746.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53281 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753383AbcBZHs4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 02:48:56 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 394DE85545
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 07:48:56 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-33.brq.redhat.com [10.40.204.33])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u1Q7mrUu021506
	for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 02:48:55 -0500
In-Reply-To: <cover.1456472746.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement VXLAN-GPE. Only L2 mode (i.e. encapsulated Ethernet frame) is
supported by this patch.

L3 mode will be added by subsequent patches.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c          | 68 ++++++++++++++++++++++++++++++++++++++++++--
 include/net/vxlan.h          | 62 +++++++++++++++++++++++++++++++++++++++-
 include/uapi/linux/if_link.h |  8 ++++++
 3 files changed, 135 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 775ddb48388d..c7844bae339d 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1192,6 +1192,33 @@ out:
 	unparsed->vx_flags &= ~VXLAN_GBP_USED_BITS;
 }
 
+static bool vxlan_parse_gpe_hdr(struct vxlanhdr *unparsed,
+				struct sk_buff *skb, u32 vxflags)
+{
+	struct vxlanhdr_gpe *gpe = (struct vxlanhdr_gpe *)unparsed;
+
+	/* Need to have Next Protocol set for interfaces in GPE mode. */
+	if (!gpe->np_applied)
+		return false;
+	/* "The initial version is 0. If a receiver does not support the
+	 * version indicated it MUST drop the packet.
+	 */
+	if (gpe->version != 0)
+		return false;
+	/* "When the O bit is set to 1, the packet is an OAM packet and OAM
+	 * processing MUST occur." However, we don't implement OAM
+	 * processing, thus drop the packet.
+	 */
+	if (gpe->oam_flag)
+		return false;
+
+	if (gpe->next_protocol != VXLAN_GPE_NP_ETHERNET)
+		return false;
+
+	unparsed->vx_flags &= ~VXLAN_GPE_USED_BITS;
+	return true;
+}
+
 static bool vxlan_set_mac(struct vxlan_dev *vxlan,
 			  struct vxlan_sock *vs,
 			  struct sk_buff *skb)
@@ -1307,6 +1334,9 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 	/* For backwards compatibility, only allow reserved fields to be
 	 * used by VXLAN extensions if explicitly requested.
 	 */
+	if (vs->flags & VXLAN_F_GPE)
+		if (!vxlan_parse_gpe_hdr(&unparsed, skb, vs->flags))
+			goto drop;
 	if (vs->flags & VXLAN_F_REMCSUM_RX)
 		if (!vxlan_remcsum(&unparsed, skb, vs->flags))
 			goto drop;
@@ -1685,6 +1715,14 @@ static void vxlan_build_gbp_hdr(struct vxlanhdr *vxh, u32 vxflags,
 	gbp->policy_id = htons(md->gbp & VXLAN_GBP_ID_MASK);
 }
 
+static void vxlan_build_gpe_hdr(struct vxlanhdr *vxh, u32 vxflags)
+{
+	struct vxlanhdr_gpe *gpe = (struct vxlanhdr_gpe *)vxh;
+
+	gpe->np_applied = 1;
+	gpe->next_protocol = VXLAN_GPE_NP_ETHERNET;
+}
+
 static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 			   int iphdr_len, __be32 vni,
 			   struct vxlan_metadata *md, u32 vxflags,
@@ -1744,6 +1782,8 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 
 	if (vxflags & VXLAN_F_GBP)
 		vxlan_build_gbp_hdr(vxh, vxflags, md);
+	if (vxflags & VXLAN_F_GPE)
+		vxlan_build_gpe_hdr(vxh, vxflags);
 
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 	return 0;
@@ -2515,6 +2555,7 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_REMCSUM_RX]	= { .type = NLA_U8 },
 	[IFLA_VXLAN_GBP]	= { .type = NLA_FLAG, },
 	[IFLA_VXLAN_REMCSUM_NOPARTIAL]	= { .type = NLA_FLAG },
+	[IFLA_VXLAN_GPE_MODE]	= { .type = NLA_U8, },
 };
 
 static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -2714,6 +2755,10 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	__be16 default_port = vxlan->cfg.dst_port;
 	struct net_device *lowerdev = NULL;
 
+	if (((conf->flags & VXLAN_F_LEARN) && (conf->flags & VXLAN_F_GPE)) ||
+	    ((conf->flags & VXLAN_F_GBP) && (conf->flags & VXLAN_F_GPE)))
+		return -EINVAL;
+
 	vxlan->net = src_net;
 
 	dst->remote_vni = conf->vni;
@@ -2770,8 +2815,12 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 	dev->needed_headroom = needed_headroom;
 
 	memcpy(&vxlan->cfg, conf, sizeof(*conf));
-	if (!vxlan->cfg.dst_port)
-		vxlan->cfg.dst_port = default_port;
+	if (!vxlan->cfg.dst_port) {
+		if (conf->flags & VXLAN_F_GPE)
+			vxlan->cfg.dst_port = 4790; /* IANA assigned VXLAN-GPE port */
+		else
+			vxlan->cfg.dst_port = default_port;
+	}
 	vxlan->flags |= conf->flags;
 
 	if (!vxlan->cfg.age_interval)
@@ -2941,6 +2990,13 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	if (data[IFLA_VXLAN_REMCSUM_NOPARTIAL])
 		conf.flags |= VXLAN_F_REMCSUM_NOPARTIAL;
 
+	if (data[IFLA_VXLAN_GPE_MODE]) {
+		u8 mode = nla_get_u8(data[IFLA_VXLAN_GPE_MODE]);
+
+		if (mode > 0 && mode <= VXLAN_GPE_MODE_MAX)
+			conf.flags |= VXLAN_F_GPE;
+	}
+
 	err = vxlan_dev_configure(src_net, dev, &conf);
 	switch (err) {
 	case -ENODEV:
@@ -2954,6 +3010,10 @@ static int vxlan_newlink(struct net *src_net, struct net_device *dev,
 	case -EEXIST:
 		pr_info("duplicate VNI %u\n", be32_to_cpu(conf.vni));
 		break;
+
+	case -EINVAL:
+		pr_info("unsupported combination of extensions\n");
+		break;
 	}
 
 	return err;
@@ -3083,6 +3143,10 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_flag(skb, IFLA_VXLAN_REMCSUM_NOPARTIAL))
 		goto nla_put_failure;
 
+	if (vxlan->flags & VXLAN_F_GPE &&
+	    nla_put_u8(skb, IFLA_VXLAN_GPE_MODE, VXLAN_GPE_MODE_L2))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 6eda4ed4d78b..7c5f1385bdfd 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -119,6 +119,64 @@ struct vxlanhdr_gbp {
 #define VXLAN_GBP_POLICY_APPLIED	(BIT(3) << 16)
 #define VXLAN_GBP_ID_MASK		(0xFFFF)
 
+/*
+ * VXLAN Generic Protocol Extension (VXLAN_F_GPE):
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |R|R|Ver|I|P|R|O|       Reserved                |Next Protocol  |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                VXLAN Network Identifier (VNI) |   Reserved    |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * Ver = Version. Indicates VXLAN GPE protocol version.
+ *
+ * P = Next Protocol Bit. The P bit is set to indicate that the
+ *     Next Protocol field is present.
+ *
+ * O = OAM Flag Bit. The O bit is set to indicate that the packet
+ *     is an OAM packet.
+ *
+ * Next Protocol = This 8 bit field indicates the protocol header
+ * immediately following the VXLAN GPE header.
+ *
+ * https://tools.ietf.org/html/draft-ietf-nvo3-vxlan-gpe-01
+ */
+
+struct vxlanhdr_gpe {
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	u8	oam_flag:1,
+		reserved_flags1:1,
+		np_applied:1,
+		instance_applied:1,
+		version:2,
+reserved_flags2:2;
+#elif defined(__BIG_ENDIAN_BITFIELD)
+	u8	reserved_flags2:2,
+		version:2,
+		instance_applied:1,
+		np_applied:1,
+		reserved_flags1:1,
+		oam_flag:1;
+#endif
+	u8	reserved_flags3;
+	u8	reserved_flags4;
+	u8	next_protocol;
+	__be32	vx_vni;
+};
+
+/* VXLAN-GPE header flags. */
+#define VXLAN_HF_VER	cpu_to_be32(BIT(29) | BIT(28))
+#define VXLAN_HF_NP	cpu_to_be32(BIT(26))
+#define VXLAN_HF_OAM	cpu_to_be32(BIT(24))
+
+#define VXLAN_GPE_USED_BITS (VXLAN_HF_VER | VXLAN_HF_NP | VXLAN_HF_OAM | \
+			     cpu_to_be32(0xff))
+
+/* VXLAN-GPE header Next Protocol. */
+#define VXLAN_GPE_NP_IPV4      0x01
+#define VXLAN_GPE_NP_IPV6      0x02
+#define VXLAN_GPE_NP_ETHERNET  0x03
+#define VXLAN_GPE_NP_NSH       0x04
+
 struct vxlan_metadata {
 	u32		gbp;
 };
@@ -205,6 +263,7 @@ struct vxlan_dev {
 #define VXLAN_F_GBP			0x800
 #define VXLAN_F_REMCSUM_NOPARTIAL	0x1000
 #define VXLAN_F_COLLECT_METADATA	0x2000
+#define VXLAN_F_GPE			0x4000
 
 /* Flags that are used in the receive path. These flags must match in
  * order for a socket to be shareable
@@ -213,7 +272,8 @@ struct vxlan_dev {
 					 VXLAN_F_UDP_ZERO_CSUM6_RX |	\
 					 VXLAN_F_REMCSUM_RX |		\
 					 VXLAN_F_REMCSUM_NOPARTIAL |	\
-					 VXLAN_F_COLLECT_METADATA)
+					 VXLAN_F_COLLECT_METADATA |	\
+					 VXLAN_F_GPE)
 
 struct net_device *vxlan_dev_create(struct net *net, const char *name,
 				    u8 name_assign_type, struct vxlan_config *conf);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index d452cea59020..c2b2b7462731 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -456,10 +456,18 @@ enum {
 	IFLA_VXLAN_GBP,
 	IFLA_VXLAN_REMCSUM_NOPARTIAL,
 	IFLA_VXLAN_COLLECT_METADATA,
+	IFLA_VXLAN_GPE_MODE,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
 
+enum vxlan_gpe_mode {
+	VXLAN_GPE_MODE_DISABLED = 0,
+	VXLAN_GPE_MODE_L2,
+	__VXLAN_GPE_MODE_MAX
+};
+#define VXLAN_GPE_MODE_MAX (__VXLAN_GPE_MODE_MAX - 1)
+
 struct ifla_vxlan_port_range {
 	__be16	low;
 	__be16	high;
-- 
1.8.3.1
