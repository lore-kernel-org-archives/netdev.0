From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 1/3] bridge: Use vlan_vid_[add/del] instead of direct ndo_vlan_rx_[add/kill]_vid calls
Date: Wed, 13 Nov 2013 17:26:12 +0900
Message-ID: <1384331175-4136-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1384331175-4136-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:40661 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758676Ab3KMI2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 03:28:24 -0500
In-Reply-To: <1384331175-4136-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should use wrapper functions vlan_vid_[add/del] instead of
ndo_vlan_rx_[add/kill]_vid. Otherwise, we might be not able to communicate
using vlan interface in a certain situation.

Example of problematic case:
  vconfig add eth0 10
  brctl addif br0 eth0
  bridge vlan add dev eth0 vid 10
  bridge vlan del dev eth0 vid 10
  brctl delif br0 eth0
In this case, we cannot communicate via eth0.10 because vlan 10 is
filtered by NIC that has the vlan filtering feature.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_vlan.c | 20 ++++++--------------
 1 file changed, 6 insertions(+), 14 deletions(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 53f0990..57074be 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -34,7 +34,6 @@ static void __vlan_add_flags(struct net_port_vlans *v, u16 vid, u16 flags)
 
 static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 {
-	const struct net_device_ops *ops;
 	struct net_bridge_port *p = NULL;
 	struct net_bridge *br;
 	struct net_device *dev;
@@ -53,17 +52,15 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 		br = v->parent.br;
 		dev = br->dev;
 	}
-	ops = dev->netdev_ops;
 
-	if (p && (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)) {
+	if (p) {
 		/* Add VLAN to the device filter if it is supported.
 		 * Stricly speaking, this is not necessary now, since
 		 * devices are made promiscuous by the bridge, but if
 		 * that ever changes this code will allow tagged
 		 * traffic to enter the bridge.
 		 */
-		err = ops->ndo_vlan_rx_add_vid(dev, htons(ETH_P_8021Q),
-					       vid);
+		err = vlan_vid_add(dev, htons(ETH_P_8021Q), vid);
 		if (err)
 			return err;
 	}
@@ -82,8 +79,8 @@ static int __vlan_add(struct net_port_vlans *v, u16 vid, u16 flags)
 	return 0;
 
 out_filt:
-	if (p && (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER))
-		ops->ndo_vlan_rx_kill_vid(dev, htons(ETH_P_8021Q), vid);
+	if (p)
+		vlan_vid_del(dev, htons(ETH_P_8021Q), vid);
 	return err;
 }
 
@@ -95,13 +92,8 @@ static int __vlan_del(struct net_port_vlans *v, u16 vid)
 	__vlan_delete_pvid(v, vid);
 	clear_bit(vid, v->untagged_bitmap);
 
-	if (v->port_idx) {
-		struct net_device *dev = v->parent.port->dev;
-		const struct net_device_ops *ops = dev->netdev_ops;
-
-		if (dev->features & NETIF_F_HW_VLAN_CTAG_FILTER)
-			ops->ndo_vlan_rx_kill_vid(dev, htons(ETH_P_8021Q), vid);
-	}
+	if (v->port_idx)
+		vlan_vid_del(v->parent.port->dev, htons(ETH_P_8021Q), vid);
 
 	clear_bit(vid, v->vlan_bitmap);
 	v->num_vlans--;
-- 
1.8.1.2
