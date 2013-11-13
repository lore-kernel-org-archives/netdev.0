From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 2/3] bridge: Call vlan_vid_del for all vids at nbp_vlan_flush
Date: Wed, 13 Nov 2013 17:26:13 +0900
Message-ID: <1384331175-4136-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1384331175-4136-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:40660 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758464Ab3KMI2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 03:28:22 -0500
In-Reply-To: <1384331175-4136-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should call vlan_vid_del for all vids at nbp_vlan_flush to prevent
vid_info->refcount from being leaked when detaching a bridge port.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
Without patch 1/3, refcount leak will occurs on slave devices if the
bridge port is a bonding device.

 net/bridge/br_vlan.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 57074be..af5ebd1 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -390,6 +390,7 @@ int nbp_vlan_delete(struct net_bridge_port *port, u16 vid)
 void nbp_vlan_flush(struct net_bridge_port *port)
 {
 	struct net_port_vlans *pv;
+	u16 vid;
 
 	ASSERT_RTNL();
 
@@ -397,6 +398,9 @@ void nbp_vlan_flush(struct net_bridge_port *port)
 	if (!pv)
 		return;
 
+	for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID)
+		vlan_vid_del(port->dev, htons(ETH_P_8021Q), vid);
+
 	__vlan_flush(pv);
 }
 
-- 
1.8.1.2
