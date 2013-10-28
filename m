From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH] bridge: pass correct vlan id to multicast code
Date: Mon, 28 Oct 2013 15:45:07 -0400
Message-ID: <1382989507-23061-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, makita.toshiaki@lab.ntt.co.jp,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45099 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755323Ab3J1Tpa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Oct 2013 15:45:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently multicast code attempts to extrace the vlan id from
the skb even when vlan filtering is disabled.  This can lead
to mdb entries being created with the wrong vlan id.
Pass the already extracted vlan id to the multicast
filtering code to make the correct id is used in
creation as well as lookup.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c    |  2 +-
 net/bridge/br_input.c     |  2 +-
 net/bridge/br_multicast.c | 44 +++++++++++++++++++-------------------------
 net/bridge/br_private.h   |  6 ++++--
 4 files changed, 25 insertions(+), 29 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index ca04163..e6b7fec 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -64,7 +64,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 			br_flood_deliver(br, skb, false);
 			goto out;
 		}
-		if (br_multicast_rcv(br, NULL, skb)) {
+		if (br_multicast_rcv(br, NULL, skb, vid)) {
 			kfree_skb(skb);
 			goto out;
 		}
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index a2fd37e..7e73c32 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -80,7 +80,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 		br_fdb_update(br, p, eth_hdr(skb)->h_source, vid);
 
 	if (!is_broadcast_ether_addr(dest) && is_multicast_ether_addr(dest) &&
-	    br_multicast_rcv(br, p, skb))
+	    br_multicast_rcv(br, p, skb, vid))
 		goto drop;
 
 	if (p->state == BR_STATE_LEARNING)
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 8b0b610..686284f 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -947,7 +947,8 @@ void br_multicast_disable_port(struct net_bridge_port *port)
 
 static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
 					 struct net_bridge_port *port,
-					 struct sk_buff *skb)
+					 struct sk_buff *skb,
+					 u16 vid)
 {
 	struct igmpv3_report *ih;
 	struct igmpv3_grec *grec;
@@ -957,12 +958,10 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
 	int type;
 	int err = 0;
 	__be32 group;
-	u16 vid = 0;
 
 	if (!pskb_may_pull(skb, sizeof(*ih)))
 		return -EINVAL;
 
-	br_vlan_get_tag(skb, &vid);
 	ih = igmpv3_report_hdr(skb);
 	num = ntohs(ih->ngrec);
 	len = sizeof(*ih);
@@ -1005,7 +1004,8 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
 #if IS_ENABLED(CONFIG_IPV6)
 static int br_ip6_multicast_mld2_report(struct net_bridge *br,
 					struct net_bridge_port *port,
-					struct sk_buff *skb)
+					struct sk_buff *skb,
+					u16 vid)
 {
 	struct icmp6hdr *icmp6h;
 	struct mld2_grec *grec;
@@ -1013,12 +1013,10 @@ static int br_ip6_multicast_mld2_report(struct net_bridge *br,
 	int len;
 	int num;
 	int err = 0;
-	u16 vid = 0;
 
 	if (!pskb_may_pull(skb, sizeof(*icmp6h)))
 		return -EINVAL;
 
-	br_vlan_get_tag(skb, &vid);
 	icmp6h = icmp6_hdr(skb);
 	num = ntohs(icmp6h->icmp6_dataun.un_data16[1]);
 	len = sizeof(*icmp6h);
@@ -1141,7 +1139,8 @@ static void br_multicast_query_received(struct net_bridge *br,
 
 static int br_ip4_multicast_query(struct net_bridge *br,
 				  struct net_bridge_port *port,
-				  struct sk_buff *skb)
+				  struct sk_buff *skb,
+				  u16 vid)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct igmphdr *ih = igmp_hdr(skb);
@@ -1153,7 +1152,6 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 	unsigned long now = jiffies;
 	__be32 group;
 	int err = 0;
-	u16 vid = 0;
 
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) ||
@@ -1189,7 +1187,6 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 	if (!group)
 		goto out;
 
-	br_vlan_get_tag(skb, &vid);
 	mp = br_mdb_ip4_get(mlock_dereference(br->mdb, br), group, vid);
 	if (!mp)
 		goto out;
@@ -1219,7 +1216,8 @@ out:
 #if IS_ENABLED(CONFIG_IPV6)
 static int br_ip6_multicast_query(struct net_bridge *br,
 				  struct net_bridge_port *port,
-				  struct sk_buff *skb)
+				  struct sk_buff *skb,
+				  u16 vid)
 {
 	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
 	struct mld_msg *mld;
@@ -1231,7 +1229,6 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 	unsigned long now = jiffies;
 	const struct in6_addr *group = NULL;
 	int err = 0;
-	u16 vid = 0;
 
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) ||
@@ -1265,7 +1262,6 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 	if (!group)
 		goto out;
 
-	br_vlan_get_tag(skb, &vid);
 	mp = br_mdb_ip6_get(mlock_dereference(br->mdb, br), group, vid);
 	if (!mp)
 		goto out;
@@ -1439,7 +1435,8 @@ static void br_ip6_multicast_leave_group(struct net_bridge *br,
 
 static int br_multicast_ipv4_rcv(struct net_bridge *br,
 				 struct net_bridge_port *port,
-				 struct sk_buff *skb)
+				 struct sk_buff *skb,
+				 u16 vid)
 {
 	struct sk_buff *skb2 = skb;
 	const struct iphdr *iph;
@@ -1447,7 +1444,6 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 	unsigned int len;
 	unsigned int offset;
 	int err;
-	u16 vid = 0;
 
 	/* We treat OOM as packet loss for now. */
 	if (!pskb_may_pull(skb, sizeof(*iph)))
@@ -1508,7 +1504,6 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 
 	err = 0;
 
-	br_vlan_get_tag(skb2, &vid);
 	BR_INPUT_SKB_CB(skb)->igmp = 1;
 	ih = igmp_hdr(skb2);
 
@@ -1519,10 +1514,10 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 		err = br_ip4_multicast_add_group(br, port, ih->group, vid);
 		break;
 	case IGMPV3_HOST_MEMBERSHIP_REPORT:
-		err = br_ip4_multicast_igmp3_report(br, port, skb2);
+		err = br_ip4_multicast_igmp3_report(br, port, skb2, vid);
 		break;
 	case IGMP_HOST_MEMBERSHIP_QUERY:
-		err = br_ip4_multicast_query(br, port, skb2);
+		err = br_ip4_multicast_query(br, port, skb2, vid);
 		break;
 	case IGMP_HOST_LEAVE_MESSAGE:
 		br_ip4_multicast_leave_group(br, port, ih->group, vid);
@@ -1540,7 +1535,8 @@ err_out:
 #if IS_ENABLED(CONFIG_IPV6)
 static int br_multicast_ipv6_rcv(struct net_bridge *br,
 				 struct net_bridge_port *port,
-				 struct sk_buff *skb)
+				 struct sk_buff *skb,
+				 u16 vid)
 {
 	struct sk_buff *skb2;
 	const struct ipv6hdr *ip6h;
@@ -1550,7 +1546,6 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 	unsigned int len;
 	int offset;
 	int err;
-	u16 vid = 0;
 
 	if (!pskb_may_pull(skb, sizeof(*ip6h)))
 		return -EINVAL;
@@ -1640,7 +1635,6 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 
 	err = 0;
 
-	br_vlan_get_tag(skb, &vid);
 	BR_INPUT_SKB_CB(skb)->igmp = 1;
 
 	switch (icmp6_type) {
@@ -1657,10 +1651,10 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 		break;
 	    }
 	case ICMPV6_MLD2_REPORT:
-		err = br_ip6_multicast_mld2_report(br, port, skb2);
+		err = br_ip6_multicast_mld2_report(br, port, skb2, vid);
 		break;
 	case ICMPV6_MGM_QUERY:
-		err = br_ip6_multicast_query(br, port, skb2);
+		err = br_ip6_multicast_query(br, port, skb2, vid);
 		break;
 	case ICMPV6_MGM_REDUCTION:
 	    {
@@ -1681,7 +1675,7 @@ out:
 #endif
 
 int br_multicast_rcv(struct net_bridge *br, struct net_bridge_port *port,
-		     struct sk_buff *skb)
+		     struct sk_buff *skb, u16 vid)
 {
 	BR_INPUT_SKB_CB(skb)->igmp = 0;
 	BR_INPUT_SKB_CB(skb)->mrouters_only = 0;
@@ -1691,10 +1685,10 @@ int br_multicast_rcv(struct net_bridge *br, struct net_bridge_port *port,
 
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
-		return br_multicast_ipv4_rcv(br, port, skb);
+		return br_multicast_ipv4_rcv(br, port, skb, vid);
 #if IS_ENABLED(CONFIG_IPV6)
 	case htons(ETH_P_IPV6):
-		return br_multicast_ipv6_rcv(br, port, skb);
+		return br_multicast_ipv6_rcv(br, port, skb, vid);
 #endif
 	}
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index e14c33b..2e8244e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -451,7 +451,8 @@ extern int br_ioctl_deviceless_stub(struct net *net, unsigned int cmd, void __us
 extern unsigned int br_mdb_rehash_seq;
 extern int br_multicast_rcv(struct net_bridge *br,
 			    struct net_bridge_port *port,
-			    struct sk_buff *skb);
+			    struct sk_buff *skb,
+			    u16 vid);
 extern struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
 					       struct sk_buff *skb, u16 vid);
 extern void br_multicast_add_port(struct net_bridge_port *port);
@@ -522,7 +523,8 @@ static inline bool br_multicast_querier_exists(struct net_bridge *br,
 #else
 static inline int br_multicast_rcv(struct net_bridge *br,
 				   struct net_bridge_port *port,
-				   struct sk_buff *skb)
+				   struct sk_buff *skb,
+				   u16 vid)
 {
 	return 0;
 }
-- 
1.8.3.1
