From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 16/18]: Keep track of number of QoS mappings
Date: Wed, 13 Jun 2007 18:51:04 +0200 (MEST)
Message-ID: <20070613165101.7780.45376.sendpatchset@localhost.localdomain>
References: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35972 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758801AbXFMQvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 12:51:05 -0400
In-Reply-To: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Keep track of number of QoS mappings

Keep track of the number of configured ingress/egress QoS mappings to
avoid iteration while calculating the netlink attribute size.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit fc3fa5f1275ec357ae719066eef18c51c186c2b9
tree c1b3f59a2404aad88854e6c1e78f38737ce90534
parent a285e1ab7cfb856fc9e503eefd507eb7958b7524
author Patrick McHardy <kaber@trash.net> Wed, 06 Jun 2007 14:47:03 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 13 Jun 2007 18:10:33 +0200

 include/linux/if_vlan.h |    3 +++
 net/8021q/vlan_dev.c    |   27 +++++++++++++++++++++------
 2 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index aeddb49..b46d422 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -112,7 +112,10 @@ struct vlan_dev_info {
 	/** This will be the mapping that correlates skb->priority to
 	 * 3 bits of VLAN QOS tags...
 	 */
+	unsigned int nr_ingress_mappings;
 	u32 ingress_priority_map[8];
+
+	unsigned int nr_egress_mappings;
 	struct vlan_priority_tci_mapping *egress_priority_map[16]; /* hash table */
 
 	unsigned short vlan_id;        /*  The VLAN Identifier for this interface. */
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 05a2360..4f6ede7 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -537,35 +537,50 @@ int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
 void vlan_dev_set_ingress_priority(const struct net_device *dev,
 				   u32 skb_prio, short vlan_prio)
 {
-	VLAN_DEV_INFO(dev)->ingress_priority_map[vlan_prio & 0x7] = skb_prio;
+	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+
+	if (vlan->ingress_priority_map[vlan_prio & 0x7] && !skb_prio)
+		vlan->nr_ingress_mappings--;
+	else if (!vlan->ingress_priority_map[vlan_prio & 0x7] && skb_prio)
+		vlan->nr_ingress_mappings++;
+
+	vlan->ingress_priority_map[vlan_prio & 0x7] = skb_prio;
 }
 
 int vlan_dev_set_egress_priority(const struct net_device *dev,
 				 u32 skb_prio, short vlan_prio)
 {
+	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
 	struct vlan_priority_tci_mapping *mp = NULL;
 	struct vlan_priority_tci_mapping *np;
+	u32 vlan_qos = (vlan_prio << 13) & 0xE000;
 
 	/* See if a priority mapping exists.. */
-	mp = VLAN_DEV_INFO(dev)->egress_priority_map[skb_prio & 0xF];
+	mp = vlan->egress_priority_map[skb_prio & 0xF];
 	while (mp) {
 		if (mp->priority == skb_prio) {
-			mp->vlan_qos = ((vlan_prio << 13) & 0xE000);
+			if (mp->vlan_qos && !vlan_qos)
+				vlan->nr_egress_mappings--;
+			else if (!mp->vlan_qos && vlan_qos)
+				vlan->nr_egress_mappings++;
+			mp->vlan_qos = vlan_qos;
 			return 0;
 		}
 		mp = mp->next;
 	}
 
 	/* Create a new mapping then. */
-	mp = VLAN_DEV_INFO(dev)->egress_priority_map[skb_prio & 0xF];
+	mp = vlan->egress_priority_map[skb_prio & 0xF];
 	np = kmalloc(sizeof(struct vlan_priority_tci_mapping), GFP_KERNEL);
 	if (!np)
 		return -ENOBUFS;
 
 	np->next = mp;
 	np->priority = skb_prio;
-	np->vlan_qos = ((vlan_prio << 13) & 0xE000);
-	VLAN_DEV_INFO(dev)->egress_priority_map[skb_prio & 0xF] = np;
+	np->vlan_qos = vlan_qos;
+	vlan->egress_priority_map[skb_prio & 0xF] = np;
+	if (vlan_qos)
+		vlan->nr_egress_mappings++;
 	return 0;
 }
 
