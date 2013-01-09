From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next v5 03/14] bridge: Validate that vlan is permitted on ingress
Date: Wed,  9 Jan 2013 12:17:50 -0500
Message-ID: <1357751882-8619-4-git-send-email-vyasevic@redhat.com>
References: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, stephen@redhat.com,
	bridge@lists.linux-foundation.org, shmulik.ladkani@gmail.com,
	mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62954 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932177Ab3AIRSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 12:18:11 -0500
In-Reply-To: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a frame arrives on a port or transmitted by the bridge,
if we have VLANs configured, validate that a given VLAN is allowed
to enter the bridge.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c  |    3 +++
 net/bridge/br_input.c   |   23 +++++++++++++++++++++++
 net/bridge/br_private.h |   14 ++++++++++++++
 3 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index b64b5c8..6b8f816 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -45,6 +45,9 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	brstats->tx_bytes += skb->len;
 	u64_stats_update_end(&brstats->syncp);
 
+	if (!br_allowed_ingress(&br->vlan_info, skb))
+		goto out;
+
 	BR_INPUT_SKB_CB(skb)->brdev = dev;
 
 	skb_reset_mac_header(skb);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 4b34207..306841d 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -17,6 +17,7 @@
 #include <linux/etherdevice.h>
 #include <linux/netfilter_bridge.h>
 #include <linux/export.h>
+#include <linux/rculist.h>
 #include "br_private.h"
 
 /* Hook for brouter */
@@ -41,6 +42,25 @@ static int br_pass_frame_up(struct sk_buff *skb)
 		       netif_receive_skb);
 }
 
+bool br_allowed_ingress(struct net_port_vlans *v, struct sk_buff *skb)
+{
+	struct net_port_vlan *pve;
+	u16 vid;
+
+	/* If there are no vlan in the permitted list, all packets are
+	 * permitted.
+	 */
+	if (list_empty(&v->vlan_list))
+		return true;
+
+	vid = br_get_vlan(skb);
+	pve = nbp_vlan_find(v, vid);
+	if (pve)
+		return true;
+
+	return false;
+}
+
 /* note: already called with rcu_read_lock */
 int br_handle_frame_finish(struct sk_buff *skb)
 {
@@ -54,6 +74,9 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	if (!p || p->state == BR_STATE_DISABLED)
 		goto drop;
 
+	if (!br_allowed_ingress(&p->vlan_info, skb))
+		goto drop;
+
 	/* insert into forwarding database after filtering to avoid spoofing */
 	br = p->br;
 	br_fdb_update(br, p, eth_hdr(skb)->h_source);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 01089c3..514538d 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -212,6 +212,19 @@ static inline struct net_bridge_port *vlans_to_port(struct net_port_vlans *vlans
 	return p;
 }
 
+static inline u16 br_get_vlan(const struct sk_buff *skb)
+{
+	u16 tag;
+
+	if (vlan_tx_tag_present(skb))
+		return vlan_tx_tag_get(skb) & VLAN_VID_MASK;
+
+	if (vlan_get_tag(skb, &tag))
+		return 0;
+
+	return tag & VLAN_VID_MASK;
+}
+
 struct br_cpu_netstats {
 	u64			rx_packets;
 	u64			rx_bytes;
@@ -460,6 +473,7 @@ extern struct net_port_vlan *nbp_vlan_find(const struct net_port_vlans *v,
 					   u16 vid);
 
 /* br_input.c */
+extern bool br_allowed_ingress(struct net_port_vlans *v, struct sk_buff *skb);
 extern int br_handle_frame_finish(struct sk_buff *skb);
 extern rx_handler_result_t br_handle_frame(struct sk_buff **pskb);
 
-- 
1.7.7.6
