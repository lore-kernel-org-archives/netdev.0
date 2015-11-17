From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net v2] rtnetlink: fix frame size warning in rtnl_fill_ifinfo
Date: Tue, 17 Nov 2015 14:16:52 +0100
Message-ID: <1447766212-26339-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:60645 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751918AbbKQNQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 08:16:59 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 1FCC020774
	for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 08:16:59 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix the following warning:

  CC      net/core/rtnetlink.o
net/core/rtnetlink.c: In function =E2=80=98rtnl_fill_ifinfo=E2=80=99:
net/core/rtnetlink.c:1308:1: warning: the frame size of 2864 bytes is l=
arger than 2048 bytes [-Wframe-larger-than=3D]
 }
 ^
by splitting up the huge rtnl_fill_ifinfo into some smaller ones, so we
don't have the huge frame allocations at the same time.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/core/rtnetlink.c | 274 ++++++++++++++++++++++++++++---------------=
--------
 1 file changed, 152 insertions(+), 122 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 504bd17..34ba7a0 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1045,15 +1045,156 @@ static int rtnl_phys_switch_id_fill(struct sk_=
buff *skb, struct net_device *dev)
 	return 0;
 }
=20
+static noinline_for_stack int rtnl_fill_stats(struct sk_buff *skb,
+					      struct net_device *dev)
+{
+	const struct rtnl_link_stats64 *stats;
+	struct rtnl_link_stats64 temp;
+	struct nlattr *attr;
+
+	stats =3D dev_get_stats(dev, &temp);
+
+	attr =3D nla_reserve(skb, IFLA_STATS,
+			   sizeof(struct rtnl_link_stats));
+	if (!attr)
+		return -EMSGSIZE;
+
+	copy_rtnl_link_stats(nla_data(attr), stats);
+
+	attr =3D nla_reserve(skb, IFLA_STATS64,
+			   sizeof(struct rtnl_link_stats64));
+	if (!attr)
+		return -EMSGSIZE;
+
+	copy_rtnl_link_stats64(nla_data(attr), stats);
+
+	return 0;
+}
+
+static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
+					       struct net_device *dev,
+					       int vfs_num,
+					       struct nlattr *vfinfo)
+{
+	struct ifla_vf_rss_query_en vf_rss_query_en;
+	struct ifla_vf_link_state vf_linkstate;
+	struct ifla_vf_spoofchk vf_spoofchk;
+	struct ifla_vf_tx_rate vf_tx_rate;
+	struct ifla_vf_stats vf_stats;
+	struct ifla_vf_trust vf_trust;
+	struct ifla_vf_vlan vf_vlan;
+	struct ifla_vf_rate vf_rate;
+	struct nlattr *vf, *vfstats;
+	struct ifla_vf_mac vf_mac;
+	struct ifla_vf_info ivi;
+
+	/* Not all SR-IOV capable drivers support the
+	 * spoofcheck and "RSS query enable" query.  Preset to
+	 * -1 so the user space tool can detect that the driver
+	 * didn't report anything.
+	 */
+	ivi.spoofchk =3D -1;
+	ivi.rss_query_en =3D -1;
+	ivi.trusted =3D -1;
+	memset(ivi.mac, 0, sizeof(ivi.mac));
+	/* The default value for VF link state is "auto"
+	 * IFLA_VF_LINK_STATE_AUTO which equals zero
+	 */
+	ivi.linkstate =3D 0;
+	if (dev->netdev_ops->ndo_get_vf_config(dev, vfs_num, &ivi))
+		return 0;
+
+	vf_mac.vf =3D
+		vf_vlan.vf =3D
+		vf_rate.vf =3D
+		vf_tx_rate.vf =3D
+		vf_spoofchk.vf =3D
+		vf_linkstate.vf =3D
+		vf_rss_query_en.vf =3D
+		vf_trust.vf =3D ivi.vf;
+
+	memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
+	vf_vlan.vlan =3D ivi.vlan;
+	vf_vlan.qos =3D ivi.qos;
+	vf_tx_rate.rate =3D ivi.max_tx_rate;
+	vf_rate.min_tx_rate =3D ivi.min_tx_rate;
+	vf_rate.max_tx_rate =3D ivi.max_tx_rate;
+	vf_spoofchk.setting =3D ivi.spoofchk;
+	vf_linkstate.link_state =3D ivi.linkstate;
+	vf_rss_query_en.setting =3D ivi.rss_query_en;
+	vf_trust.setting =3D ivi.trusted;
+	vf =3D nla_nest_start(skb, IFLA_VF_INFO);
+	if (!vf) {
+		nla_nest_cancel(skb, vfinfo);
+		return -EMSGSIZE;
+	}
+	if (nla_put(skb, IFLA_VF_MAC, sizeof(vf_mac), &vf_mac) ||
+	    nla_put(skb, IFLA_VF_VLAN, sizeof(vf_vlan), &vf_vlan) ||
+	    nla_put(skb, IFLA_VF_RATE, sizeof(vf_rate),
+		    &vf_rate) ||
+	    nla_put(skb, IFLA_VF_TX_RATE, sizeof(vf_tx_rate),
+		    &vf_tx_rate) ||
+	    nla_put(skb, IFLA_VF_SPOOFCHK, sizeof(vf_spoofchk),
+		    &vf_spoofchk) ||
+	    nla_put(skb, IFLA_VF_LINK_STATE, sizeof(vf_linkstate),
+		    &vf_linkstate) ||
+	    nla_put(skb, IFLA_VF_RSS_QUERY_EN,
+		    sizeof(vf_rss_query_en),
+		    &vf_rss_query_en) ||
+	    nla_put(skb, IFLA_VF_TRUST,
+		    sizeof(vf_trust), &vf_trust))
+		return -EMSGSIZE;
+	memset(&vf_stats, 0, sizeof(vf_stats));
+	if (dev->netdev_ops->ndo_get_vf_stats)
+		dev->netdev_ops->ndo_get_vf_stats(dev, vfs_num,
+						&vf_stats);
+	vfstats =3D nla_nest_start(skb, IFLA_VF_STATS);
+	if (!vfstats) {
+		nla_nest_cancel(skb, vf);
+		nla_nest_cancel(skb, vfinfo);
+		return -EMSGSIZE;
+	}
+	if (nla_put_u64(skb, IFLA_VF_STATS_RX_PACKETS,
+			vf_stats.rx_packets) ||
+	    nla_put_u64(skb, IFLA_VF_STATS_TX_PACKETS,
+			vf_stats.tx_packets) ||
+	    nla_put_u64(skb, IFLA_VF_STATS_RX_BYTES,
+			vf_stats.rx_bytes) ||
+	    nla_put_u64(skb, IFLA_VF_STATS_TX_BYTES,
+			vf_stats.tx_bytes) ||
+	    nla_put_u64(skb, IFLA_VF_STATS_BROADCAST,
+			vf_stats.broadcast) ||
+	    nla_put_u64(skb, IFLA_VF_STATS_MULTICAST,
+			vf_stats.multicast))
+		return -EMSGSIZE;
+	nla_nest_end(skb, vfstats);
+	nla_nest_end(skb, vf);
+	return 0;
+}
+
+static int rtnl_fill_link_ifmap(struct sk_buff *skb, struct net_device=
 *dev)
+{
+	struct rtnl_link_ifmap map =3D {
+		.mem_start   =3D dev->mem_start,
+		.mem_end     =3D dev->mem_end,
+		.base_addr   =3D dev->base_addr,
+		.irq         =3D dev->irq,
+		.dma         =3D dev->dma,
+		.port        =3D dev->if_port,
+	};
+	if (nla_put(skb, IFLA_MAP, sizeof(map), &map))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *de=
v,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags, u32 ext_filter_mask)
 {
 	struct ifinfomsg *ifm;
 	struct nlmsghdr *nlh;
-	struct rtnl_link_stats64 temp;
-	const struct rtnl_link_stats64 *stats;
-	struct nlattr *attr, *af_spec;
+	struct nlattr *af_spec;
 	struct rtnl_af_ops *af_ops;
 	struct net_device *upper_dev =3D netdev_master_upper_dev_get(dev);
=20
@@ -1096,18 +1237,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb,=
 struct net_device *dev,
 	    nla_put_u8(skb, IFLA_PROTO_DOWN, dev->proto_down))
 		goto nla_put_failure;
=20
-	if (1) {
-		struct rtnl_link_ifmap map =3D {
-			.mem_start   =3D dev->mem_start,
-			.mem_end     =3D dev->mem_end,
-			.base_addr   =3D dev->base_addr,
-			.irq         =3D dev->irq,
-			.dma         =3D dev->dma,
-			.port        =3D dev->if_port,
-		};
-		if (nla_put(skb, IFLA_MAP, sizeof(map), &map))
-			goto nla_put_failure;
-	}
+	if (rtnl_fill_link_ifmap(skb, dev))
+		goto nla_put_failure;
=20
 	if (dev->addr_len) {
 		if (nla_put(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr) ||
@@ -1124,128 +1255,27 @@ static int rtnl_fill_ifinfo(struct sk_buff *sk=
b, struct net_device *dev,
 	if (rtnl_phys_switch_id_fill(skb, dev))
 		goto nla_put_failure;
=20
-	attr =3D nla_reserve(skb, IFLA_STATS,
-			sizeof(struct rtnl_link_stats));
-	if (attr =3D=3D NULL)
-		goto nla_put_failure;
-
-	stats =3D dev_get_stats(dev, &temp);
-	copy_rtnl_link_stats(nla_data(attr), stats);
-
-	attr =3D nla_reserve(skb, IFLA_STATS64,
-			sizeof(struct rtnl_link_stats64));
-	if (attr =3D=3D NULL)
+	if (rtnl_fill_stats(skb, dev))
 		goto nla_put_failure;
-	copy_rtnl_link_stats64(nla_data(attr), stats);
=20
 	if (dev->dev.parent && (ext_filter_mask & RTEXT_FILTER_VF) &&
 	    nla_put_u32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent)))
 		goto nla_put_failure;
=20
-	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent
-	    && (ext_filter_mask & RTEXT_FILTER_VF)) {
+	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent &&
+	    ext_filter_mask & RTEXT_FILTER_VF) {
 		int i;
-
-		struct nlattr *vfinfo, *vf, *vfstats;
+		struct nlattr *vfinfo;
 		int num_vfs =3D dev_num_vf(dev->dev.parent);
=20
 		vfinfo =3D nla_nest_start(skb, IFLA_VFINFO_LIST);
 		if (!vfinfo)
 			goto nla_put_failure;
 		for (i =3D 0; i < num_vfs; i++) {
-			struct ifla_vf_info ivi;
-			struct ifla_vf_mac vf_mac;
-			struct ifla_vf_vlan vf_vlan;
-			struct ifla_vf_rate vf_rate;
-			struct ifla_vf_tx_rate vf_tx_rate;
-			struct ifla_vf_spoofchk vf_spoofchk;
-			struct ifla_vf_link_state vf_linkstate;
-			struct ifla_vf_rss_query_en vf_rss_query_en;
-			struct ifla_vf_stats vf_stats;
-			struct ifla_vf_trust vf_trust;
-
-			/*
-			 * Not all SR-IOV capable drivers support the
-			 * spoofcheck and "RSS query enable" query.  Preset to
-			 * -1 so the user space tool can detect that the driver
-			 * didn't report anything.
-			 */
-			ivi.spoofchk =3D -1;
-			ivi.rss_query_en =3D -1;
-			ivi.trusted =3D -1;
-			memset(ivi.mac, 0, sizeof(ivi.mac));
-			/* The default value for VF link state is "auto"
-			 * IFLA_VF_LINK_STATE_AUTO which equals zero
-			 */
-			ivi.linkstate =3D 0;
-			if (dev->netdev_ops->ndo_get_vf_config(dev, i, &ivi))
-				break;
-			vf_mac.vf =3D
-				vf_vlan.vf =3D
-				vf_rate.vf =3D
-				vf_tx_rate.vf =3D
-				vf_spoofchk.vf =3D
-				vf_linkstate.vf =3D
-				vf_rss_query_en.vf =3D
-				vf_trust.vf =3D ivi.vf;
-
-			memcpy(vf_mac.mac, ivi.mac, sizeof(ivi.mac));
-			vf_vlan.vlan =3D ivi.vlan;
-			vf_vlan.qos =3D ivi.qos;
-			vf_tx_rate.rate =3D ivi.max_tx_rate;
-			vf_rate.min_tx_rate =3D ivi.min_tx_rate;
-			vf_rate.max_tx_rate =3D ivi.max_tx_rate;
-			vf_spoofchk.setting =3D ivi.spoofchk;
-			vf_linkstate.link_state =3D ivi.linkstate;
-			vf_rss_query_en.setting =3D ivi.rss_query_en;
-			vf_trust.setting =3D ivi.trusted;
-			vf =3D nla_nest_start(skb, IFLA_VF_INFO);
-			if (!vf) {
-				nla_nest_cancel(skb, vfinfo);
-				goto nla_put_failure;
-			}
-			if (nla_put(skb, IFLA_VF_MAC, sizeof(vf_mac), &vf_mac) ||
-			    nla_put(skb, IFLA_VF_VLAN, sizeof(vf_vlan), &vf_vlan) ||
-			    nla_put(skb, IFLA_VF_RATE, sizeof(vf_rate),
-				    &vf_rate) ||
-			    nla_put(skb, IFLA_VF_TX_RATE, sizeof(vf_tx_rate),
-				    &vf_tx_rate) ||
-			    nla_put(skb, IFLA_VF_SPOOFCHK, sizeof(vf_spoofchk),
-				    &vf_spoofchk) ||
-			    nla_put(skb, IFLA_VF_LINK_STATE, sizeof(vf_linkstate),
-				    &vf_linkstate) ||
-			    nla_put(skb, IFLA_VF_RSS_QUERY_EN,
-				    sizeof(vf_rss_query_en),
-				    &vf_rss_query_en) ||
-			    nla_put(skb, IFLA_VF_TRUST,
-				    sizeof(vf_trust), &vf_trust))
+			if (rtnl_fill_vfinfo(skb, dev, i, vfinfo))
 				goto nla_put_failure;
-			memset(&vf_stats, 0, sizeof(vf_stats));
-			if (dev->netdev_ops->ndo_get_vf_stats)
-				dev->netdev_ops->ndo_get_vf_stats(dev, i,
-								  &vf_stats);
-			vfstats =3D nla_nest_start(skb, IFLA_VF_STATS);
-			if (!vfstats) {
-				nla_nest_cancel(skb, vf);
-				nla_nest_cancel(skb, vfinfo);
-				goto nla_put_failure;
-			}
-			if (nla_put_u64(skb, IFLA_VF_STATS_RX_PACKETS,
-					vf_stats.rx_packets) ||
-			    nla_put_u64(skb, IFLA_VF_STATS_TX_PACKETS,
-					vf_stats.tx_packets) ||
-			    nla_put_u64(skb, IFLA_VF_STATS_RX_BYTES,
-					vf_stats.rx_bytes) ||
-			    nla_put_u64(skb, IFLA_VF_STATS_TX_BYTES,
-					vf_stats.tx_bytes) ||
-			    nla_put_u64(skb, IFLA_VF_STATS_BROADCAST,
-					vf_stats.broadcast) ||
-			    nla_put_u64(skb, IFLA_VF_STATS_MULTICAST,
-					vf_stats.multicast))
-				goto nla_put_failure;
-			nla_nest_end(skb, vfstats);
-			nla_nest_end(skb, vf);
 		}
+
 		nla_nest_end(skb, vfinfo);
 	}
=20
--=20
2.5.0
