From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next] net: bridge: extend MLD/IGMP query stats
Date: Wed,  6 Jul 2016 12:12:21 -0700
Message-ID: <1467832341-5355-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linus.luessing@c0d3.blue, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34995 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754706AbcGFTOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 15:14:23 -0400
Received: by mail-pf0-f194.google.com with SMTP id t190so22515941pfb.2
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 12:14:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As was suggested this patch adds support for the different versions of =
MLD
and IGMP query types. Since the user visible structure is still in net-=
next
we can augment it instead of adding netlink attributes.
The distinction between the different IGMP/MLD query types is done as
suggested in Section 7.1, RFC 3376 [1] and Section 8.1, RFC 3810 [2] ba=
sed
on query payload size and code for IGMP. Since all IGMP packets go thro=
ugh
multicast_rcv() and it uses ip_mc_check_igmp/ipv6_mc_check_mld we can b=
e
sure that at least the ip/ipv6 header can be directly used.

[1] https://tools.ietf.org/html/rfc3376#section-7
[2] https://tools.ietf.org/html/rfc3810#section-8.1

Suggested-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_bridge.h |  7 ++++--
 net/bridge/br_forward.c        |  7 ++----
 net/bridge/br_input.c          |  2 +-
 net/bridge/br_multicast.c      | 48 ++++++++++++++++++++++++++++++++--=
--------
 net/bridge/br_private.h        |  5 +++--
 5 files changed, 48 insertions(+), 21 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bri=
dge.h
index 8304fe6f0561..c186f64fffca 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -261,14 +261,17 @@ enum {
=20
 /* IGMP/MLD statistics */
 struct br_mcast_stats {
-	__u64 igmp_queries[BR_MCAST_DIR_SIZE];
+	__u64 igmp_v1queries[BR_MCAST_DIR_SIZE];
+	__u64 igmp_v2queries[BR_MCAST_DIR_SIZE];
+	__u64 igmp_v3queries[BR_MCAST_DIR_SIZE];
 	__u64 igmp_leaves[BR_MCAST_DIR_SIZE];
 	__u64 igmp_v1reports[BR_MCAST_DIR_SIZE];
 	__u64 igmp_v2reports[BR_MCAST_DIR_SIZE];
 	__u64 igmp_v3reports[BR_MCAST_DIR_SIZE];
 	__u64 igmp_parse_errors;
=20
-	__u64 mld_queries[BR_MCAST_DIR_SIZE];
+	__u64 mld_v1queries[BR_MCAST_DIR_SIZE];
+	__u64 mld_v2queries[BR_MCAST_DIR_SIZE];
 	__u64 mld_leaves[BR_MCAST_DIR_SIZE];
 	__u64 mld_v1reports[BR_MCAST_DIR_SIZE];
 	__u64 mld_v2reports[BR_MCAST_DIR_SIZE];
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 6c196037d818..d610644368b9 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -199,7 +199,6 @@ static void br_flood(struct net_bridge *br, struct =
sk_buff *skb,
 		     bool unicast)
 {
 	u8 igmp_type =3D br_multicast_igmp_type(skb);
-	__be16 proto =3D skb->protocol;
 	struct net_bridge_port *prev;
 	struct net_bridge_port *p;
=20
@@ -221,7 +220,7 @@ static void br_flood(struct net_bridge *br, struct =
sk_buff *skb,
 		if (IS_ERR(prev))
 			goto out;
 		if (prev =3D=3D p)
-			br_multicast_count(p->br, p, proto, igmp_type,
+			br_multicast_count(p->br, p, skb, igmp_type,
 					   BR_MCAST_DIR_TX);
 	}
=20
@@ -266,8 +265,6 @@ static void br_multicast_flood(struct net_bridge_md=
b_entry *mdst,
 	struct net_bridge *br =3D netdev_priv(dev);
 	struct net_bridge_port *prev =3D NULL;
 	struct net_bridge_port_group *p;
-	__be16 proto =3D skb->protocol;
-
 	struct hlist_node *rp;
=20
 	rp =3D rcu_dereference(hlist_first_rcu(&br->router_list));
@@ -286,7 +283,7 @@ static void br_multicast_flood(struct net_bridge_md=
b_entry *mdst,
 		if (IS_ERR(prev))
 			goto out;
 		if (prev =3D=3D port)
-			br_multicast_count(port->br, port, proto, igmp_type,
+			br_multicast_count(port->br, port, skb, igmp_type,
 					   BR_MCAST_DIR_TX);
=20
 		if ((unsigned long)lport >=3D (unsigned long)port)
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 786602bc0567..a7817e6f306f 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -61,7 +61,7 @@ static int br_pass_frame_up(struct sk_buff *skb)
 	if (!skb)
 		return NET_RX_DROP;
 	/* update the multicast stats if the packet is IGMP/MLD */
-	br_multicast_count(br, NULL, skb->protocol, br_multicast_igmp_type(sk=
b),
+	br_multicast_count(br, NULL, skb, br_multicast_igmp_type(skb),
 			   BR_MCAST_DIR_TX);
=20
 	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN,
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index e405eef0ae2e..a5423a1eec05 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -843,14 +843,14 @@ static void __br_multicast_send_query(struct net_=
bridge *br,
=20
 	if (port) {
 		skb->dev =3D port->dev;
-		br_multicast_count(br, port, skb->protocol, igmp_type,
+		br_multicast_count(br, port, skb, igmp_type,
 				   BR_MCAST_DIR_TX);
 		NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT,
 			dev_net(port->dev), NULL, skb, NULL, skb->dev,
 			br_dev_queue_push_xmit);
 	} else {
 		br_multicast_select_own_querier(br, ip, skb);
-		br_multicast_count(br, port, skb->protocol, igmp_type,
+		br_multicast_count(br, port, skb, igmp_type,
 				   BR_MCAST_DIR_RX);
 		netif_rx(skb);
 	}
@@ -1676,7 +1676,7 @@ static int br_multicast_ipv4_rcv(struct net_bridg=
e *br,
 	if (skb_trimmed && skb_trimmed !=3D skb)
 		kfree_skb(skb_trimmed);
=20
-	br_multicast_count(br, port, skb->protocol, BR_INPUT_SKB_CB(skb)->igm=
p,
+	br_multicast_count(br, port, skb, BR_INPUT_SKB_CB(skb)->igmp,
 			   BR_MCAST_DIR_RX);
=20
 	return err;
@@ -1725,7 +1725,7 @@ static int br_multicast_ipv6_rcv(struct net_bridg=
e *br,
 	if (skb_trimmed && skb_trimmed !=3D skb)
 		kfree_skb(skb_trimmed);
=20
-	br_multicast_count(br, port, skb->protocol, BR_INPUT_SKB_CB(skb)->igm=
p,
+	br_multicast_count(br, port, skb, BR_INPUT_SKB_CB(skb)->igmp,
 			   BR_MCAST_DIR_RX);
=20
 	return err;
@@ -2251,13 +2251,16 @@ unlock:
 EXPORT_SYMBOL_GPL(br_multicast_has_querier_adjacent);
=20
 static void br_mcast_stats_add(struct bridge_mcast_stats __percpu *sta=
ts,
-			       __be16 proto, u8 type, u8 dir)
+			       const struct sk_buff *skb, u8 type, u8 dir)
 {
 	struct bridge_mcast_stats *pstats =3D this_cpu_ptr(stats);
+	__be16 proto =3D skb->protocol;
+	unsigned int t_len;
=20
 	u64_stats_update_begin(&pstats->syncp);
 	switch (proto) {
 	case htons(ETH_P_IP):
+		t_len =3D ntohs(ip_hdr(skb)->tot_len) - ip_hdrlen(skb);
 		switch (type) {
 		case IGMP_HOST_MEMBERSHIP_REPORT:
 			pstats->mstats.igmp_v1reports[dir]++;
@@ -2269,7 +2272,21 @@ static void br_mcast_stats_add(struct bridge_mca=
st_stats __percpu *stats,
 			pstats->mstats.igmp_v3reports[dir]++;
 			break;
 		case IGMP_HOST_MEMBERSHIP_QUERY:
-			pstats->mstats.igmp_queries[dir]++;
+			if (t_len !=3D sizeof(struct igmphdr)) {
+				pstats->mstats.igmp_v3queries[dir]++;
+			} else {
+				unsigned int offset =3D skb_transport_offset(skb);
+				struct igmphdr *ih, _ihdr;
+
+				ih =3D skb_header_pointer(skb, offset,
+							sizeof(_ihdr), &_ihdr);
+				if (!ih)
+					break;
+				if (!ih->code)
+					pstats->mstats.igmp_v1queries[dir]++;
+				else
+					pstats->mstats.igmp_v2queries[dir]++;
+			}
 			break;
 		case IGMP_HOST_LEAVE_MESSAGE:
 			pstats->mstats.igmp_leaves[dir]++;
@@ -2278,6 +2295,9 @@ static void br_mcast_stats_add(struct bridge_mcas=
t_stats __percpu *stats,
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case htons(ETH_P_IPV6):
+		t_len =3D ntohs(ipv6_hdr(skb)->payload_len) +
+			sizeof(struct ipv6hdr);
+		t_len -=3D skb_network_header_len(skb);
 		switch (type) {
 		case ICMPV6_MGM_REPORT:
 			pstats->mstats.mld_v1reports[dir]++;
@@ -2286,7 +2306,10 @@ static void br_mcast_stats_add(struct bridge_mca=
st_stats __percpu *stats,
 			pstats->mstats.mld_v2reports[dir]++;
 			break;
 		case ICMPV6_MGM_QUERY:
-			pstats->mstats.mld_queries[dir]++;
+			if (t_len !=3D sizeof(struct mld_msg))
+				pstats->mstats.mld_v2queries[dir]++;
+			else
+				pstats->mstats.mld_v1queries[dir]++;
 			break;
 		case ICMPV6_MGM_REDUCTION:
 			pstats->mstats.mld_leaves[dir]++;
@@ -2299,7 +2322,7 @@ static void br_mcast_stats_add(struct bridge_mcas=
t_stats __percpu *stats,
 }
=20
 void br_multicast_count(struct net_bridge *br, const struct net_bridge=
_port *p,
-			__be16 proto, u8 type, u8 dir)
+			const struct sk_buff *skb, u8 type, u8 dir)
 {
 	struct bridge_mcast_stats __percpu *stats;
=20
@@ -2314,7 +2337,7 @@ void br_multicast_count(struct net_bridge *br, co=
nst struct net_bridge_port *p,
 	if (WARN_ON(!stats))
 		return;
=20
-	br_mcast_stats_add(stats, proto, type, dir);
+	br_mcast_stats_add(stats, skb, type, dir);
 }
=20
 int br_multicast_init_stats(struct net_bridge *br)
@@ -2359,14 +2382,17 @@ void br_multicast_get_stats(const struct net_br=
idge *br,
 			memcpy(&temp, &cpu_stats->mstats, sizeof(temp));
 		} while (u64_stats_fetch_retry_irq(&cpu_stats->syncp, start));
=20
-		mcast_stats_add_dir(tdst.igmp_queries, temp.igmp_queries);
+		mcast_stats_add_dir(tdst.igmp_v1queries, temp.igmp_v1queries);
+		mcast_stats_add_dir(tdst.igmp_v2queries, temp.igmp_v2queries);
+		mcast_stats_add_dir(tdst.igmp_v3queries, temp.igmp_v3queries);
 		mcast_stats_add_dir(tdst.igmp_leaves, temp.igmp_leaves);
 		mcast_stats_add_dir(tdst.igmp_v1reports, temp.igmp_v1reports);
 		mcast_stats_add_dir(tdst.igmp_v2reports, temp.igmp_v2reports);
 		mcast_stats_add_dir(tdst.igmp_v3reports, temp.igmp_v3reports);
 		tdst.igmp_parse_errors +=3D temp.igmp_parse_errors;
=20
-		mcast_stats_add_dir(tdst.mld_queries, temp.mld_queries);
+		mcast_stats_add_dir(tdst.mld_v1queries, temp.mld_v1queries);
+		mcast_stats_add_dir(tdst.mld_v2queries, temp.mld_v2queries);
 		mcast_stats_add_dir(tdst.mld_leaves, temp.mld_leaves);
 		mcast_stats_add_dir(tdst.mld_v1reports, temp.mld_v1reports);
 		mcast_stats_add_dir(tdst.mld_v2reports, temp.mld_v2reports);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 4dc851166ad1..40f200947ddc 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -586,7 +586,7 @@ void br_mdb_notify(struct net_device *dev, struct n=
et_bridge_port *port,
 void br_rtr_notify(struct net_device *dev, struct net_bridge_port *por=
t,
 		   int type);
 void br_multicast_count(struct net_bridge *br, const struct net_bridge=
_port *p,
-			__be16 proto, u8 type, u8 dir);
+			const struct sk_buff *skb, u8 type, u8 dir);
 int br_multicast_init_stats(struct net_bridge *br);
 void br_multicast_get_stats(const struct net_bridge *br,
 			    const struct net_bridge_port *p,
@@ -719,7 +719,8 @@ static inline void br_mdb_uninit(void)
=20
 static inline void br_multicast_count(struct net_bridge *br,
 				      const struct net_bridge_port *p,
-				      __be16 proto, u8 type, u8 dir)
+				      const struct sk_buff *skb,
+				      u8 type, u8 dir)
 {
 }
=20
--=20
2.8.2
