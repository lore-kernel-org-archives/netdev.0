From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 47/50] bridge: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:54 +0100
Message-ID: <1328735457-29986-48-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bridge@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Reset the state to NET_ADDR_PERM as soon as the MAC get
changed via .ndo_set_mac_address.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 net/bridge/br_device.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 71773b0..a25ed22 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -172,6 +172,10 @@ static int br_set_mac_address(struct net_device *dev, void *p)
 	spin_lock_bh(&br->lock);
 	if (compare_ether_addr(dev->dev_addr, addr->sa_data)) {
 		memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+		if (dev->addr_assign_type & NET_ADDR_RANDOM) {
+			/* set back to NET_ADDR_PERM */
+			dev->addr_assign_type ^= NET_ADDR_RANDOM;
+		}
 		br_fdb_change_mac_address(br, addr->sa_data);
 		br_stp_change_bridge_id(br, addr->sa_data);
 	}
@@ -334,7 +338,7 @@ void br_dev_setup(struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
 
-	random_ether_addr(dev->dev_addr);
+	dev_hw_addr_random(dev, dev->dev_addr);
 	ether_setup(dev);
 
 	dev->netdev_ops = &br_netdev_ops;
-- 
1.7.7.3
