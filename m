From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net] net: br: Fix igmp snooping offload with CONFIG_BRIDGE_VLAN_FILTERING
Date: Tue,  3 Oct 2017 02:55:11 +0200
Message-ID: <1506992111-25004-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:36362 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751101AbdJCAzk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 20:55:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With CONFIG_BRIDGE_VLAN_FILTERING enabled, but the feature not enabled
via /sys/class/net/brX/bridge/vlan_filtering, mdb offloaded to the
kernel have the wrong VID.

When an interface is added to the bridge, switchdev is first used to
notify the hardware that a port has joined a bridge. This is
immediately followed by the default_pvid, 1, being added to the
interface via another switchdev call.

The bridge will then perform IGMP snooping, and offload an mdb entries
to the switch as needed. With vlan filtering disabled, the vid is left
as 0. This causes the switch to put the static mdb into the wrong
vlan, and so frames are not forwarded by the mdb entry.

If vlan filtering is disable, use the default_pvid, not 0.

Fixes: f1fecb1d10ec ("bridge: Reflect MDB entries to hardware")
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/bridge/br_vlan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 233a30040c91..aa3589891797 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -492,6 +492,7 @@ bool br_allowed_ingress(const struct net_bridge *br,
 	 */
 	if (!br->vlan_enabled) {
 		BR_INPUT_SKB_CB(skb)->vlan_filtered = false;
+		*vid = br_get_pvid(vg);
 		return true;
 	}
 
-- 
2.14.1
