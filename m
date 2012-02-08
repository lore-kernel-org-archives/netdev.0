From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 34/50] xilinx ll_temac: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:41 +0100
Message-ID: <1328735457-29986-35-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	"Ricardo Ribalda Delgado" <ricardo.ribalda@gmail.com>,
	Thomas Meyer <thomas@m3y3r.de>,
	Richard Cochran <richard.cochran@omicron.at>
To: "David S. Miller" <davem@davemloft.net>
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
 drivers/net/ethernet/xilinx/ll_temac_main.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index f21addb..d687620 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -322,12 +322,19 @@ out:
 static int temac_set_mac_address(struct net_device *ndev, void *address)
 {
 	struct temac_local *lp = netdev_priv(ndev);
+	bool set_random = false;
 
 	if (address)
 		memcpy(ndev->dev_addr, address, ETH_ALEN);
 
-	if (!is_valid_ether_addr(ndev->dev_addr))
-		random_ether_addr(ndev->dev_addr);
+	if (!is_valid_ether_addr(ndev->dev_addr)) {
+		dev_hw_addr_random(ndev, ndev->dev_addr);
+		set_random = true;
+	}
+	if (!set_random) {
+		if (ndev->addr_assign_type & NET_ADDR_RANDOM)
+			ndev->addr_assign_type ^= NET_ADDR_RANDOM;
+	}
 
 	/* set up unicast MAC address filter set its mac address */
 	mutex_lock(&lp->indirect_mutex);
-- 
1.7.7.3
