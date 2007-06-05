From: Patrick McHardy <kaber@trash.net>
Subject: [RFC VLAN 07/08]: Keep track of number of QoS mappings
Date: Tue,  5 Jun 2007 16:23:40 +0200 (MEST)
Message-ID: <20070605142339.20372.73006.sendpatchset@localhost.localdomain>
References: <20070605142327.20372.18108.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64174 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764444AbXFEOXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:23:42 -0400
In-Reply-To: <20070605142327.20372.18108.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Keep track of number of QoS mappings

Keep track of the number of configured ingress/egress QoS mappings to
avoid iteration while calculating the netlink attribute size.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit fba4579d0d3c365f1ff5473e905dac68c5ec62f3
tree 892fa4a95ab163960573ee6bf1430279a1d697b8
parent 24b7a56049e5e9f63e6fc5933d10b47c15294fea
author Patrick McHardy <kaber@trash.net> Tue, 29 May 2007 17:52:48 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 29 May 2007 17:52:48 +0200

 include/linux/if_vlan.h |    4 ++++
 net/8021q/vlan_dev.c    |   27 +++++++++++++++++++++------
 2 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 1889b29..ba48340 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -112,9 +112,13 @@ struct vlan_dev_info {
 	/** This will be the mapping that correlates skb->priority to
 	 * 3 bits of VLAN QOS tags...
 	 */
+	unsigned int nr_ingress_mappings;
 	unsigned int ingress_priority_map[8];
+
+	unsigned int nr_egress_mappings;
 	struct vlan_priority_tci_mapping *egress_priority_map[16]; /* hash table */
 
+
 	unsigned short vlan_id;        /*  The VLAN Identifier for this interface. */
 	unsigned short flags;          /* (1 << 0) re_order_header   This option will cause the
                                         *   VLAN code to move around the ethernet header on
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 0b7e03e..1644626 100644
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
 
