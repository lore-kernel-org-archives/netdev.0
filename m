From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH V2 02/12] bridge: Validate that vlan is permitted on ingress
Date: Tue, 18 Dec 2012 14:00:53 -0500
Message-ID: <1355857263-31197-3-git-send-email-vyasevic@redhat.com>
References: <1355857263-31197-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, davem@davemloft.net, or.gerlitz@gmail.com,
	jhs@mojatatu.com, mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30920 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753400Ab2LRTB1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 14:01:27 -0500
In-Reply-To: <1355857263-31197-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a frame arrives on a port, if we have VLANs configured,
validate that a given VLAN is allowed to ingress on a given
port.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_input.c   |   23 +++++++++++++++++++++++
 net/bridge/br_private.h |   15 +++++++++++++--
 2 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 4b34207..54c0894 100644
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
 
+static bool br_allowed_ingress(struct net_bridge_port *p, struct sk_buff *skb)
+{
+	struct net_port_vlan *pve;
+	u16 vid;
+
+	/* If there are no vlan in the permitted list, all packets are
+	 * permitted.
+	 */
+	if (list_empty(&p->vlan_list))
+		return true;
+
+	vid = br_get_vlan(skb);
+	pve = nbp_vlan_find(p, vid);
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
 
+	if (!br_allowed_ingress(p, skb))
+		goto drop;
+
 	/* insert into forwarding database after filtering to avoid spoofing */
 	br = p->br;
 	br_fdb_update(br, p, eth_hdr(skb)->h_source);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 76d9fbc..1ba76b4 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -66,8 +66,6 @@ struct br_ip
 };
 
 #define BR_INVALID_VID	(1<<15)
-#define BR_UNTAGGED_VID (1<<14)
-
 #define BR_VID_HASH_SIZE (1<<6)
 #define br_vlan_hash(vid) ((vid) % (BR_VID_HASH_SIZE - 1))
 
@@ -197,6 +195,19 @@ static inline struct net_bridge_port *br_port_get_rtnl(struct net_device *dev)
 		rtnl_dereference(dev->rx_handler_data) : NULL;
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
-- 
1.7.7.6
