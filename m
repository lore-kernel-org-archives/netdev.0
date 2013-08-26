From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 08/11] net: calxedaxgmac: fix various errors in xgmac_set_rx_mode
Date: Mon, 26 Aug 2013 17:45:23 -0500
Message-ID: <1377557126-10716-8-git-send-email-robherring2@gmail.com>
References: <1377557126-10716-1-git-send-email-robherring2@gmail.com>
Cc: Andreas Herrmann <andreas.herrmann@calxeda.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377557126-10716-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

Fix xgmac_set_rx_mode to handle several conditions that were not handled
correctly as Lennert Buytenhek describes:

If we have, say, 100 unicast addresses, and 5 multicast addresses, the
unicast address count check will evaluate to true, and set use_hash to
true.  The multicast address check will however evaluate to false, and
use_hash won't be set to true again, and XGMAC_FRAME_FILTER_HMC won't
be OR'd into XGMAC_FRAME_FILTER, but since use_hash was still true
from the unicast check, netdev_for_each_mc_addr() will program the
multicast addresses into the hash table instead of using the MAC
address registers, but since the HMC bit wasn't set, the hash table
won't be checked for multicast addresses on receive, and we'll stop
receiving multicast packets entirely.

Also, there is no code that zeroes out MAC address registers reg..31
at the end of this function, meaning that under the right conditions,
unicast/multicast addresses that were previously in the filter but
were then deleted won't be cleared out.

Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 385eca0..9b6eff5 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -618,10 +618,15 @@ static void xgmac_set_mac_addr(void __iomem *ioaddr, unsigned char *addr,
 {
 	u32 data;
 
-	data = (addr[5] << 8) | addr[4] | (num ? XGMAC_ADDR_AE : 0);
-	writel(data, ioaddr + XGMAC_ADDR_HIGH(num));
-	data = (addr[3] << 24) | (addr[2] << 16) | (addr[1] << 8) | addr[0];
-	writel(data, ioaddr + XGMAC_ADDR_LOW(num));
+	if (addr) {
+		data = (addr[5] << 8) | addr[4] | (num ? XGMAC_ADDR_AE : 0);
+		writel(data, ioaddr + XGMAC_ADDR_HIGH(num));
+		data = (addr[3] << 24) | (addr[2] << 16) | (addr[1] << 8) | addr[0];
+		writel(data, ioaddr + XGMAC_ADDR_LOW(num));
+	} else {
+		writel(0, ioaddr + XGMAC_ADDR_HIGH(num));
+		writel(0, ioaddr + XGMAC_ADDR_LOW(num));
+	}
 }
 
 static void xgmac_get_mac_addr(void __iomem *ioaddr, unsigned char *addr,
@@ -1297,6 +1302,8 @@ static void xgmac_set_rx_mode(struct net_device *dev)
 	if ((netdev_mc_count(dev) + reg - 1) > XGMAC_MAX_FILTER_ADDR) {
 		use_hash = true;
 		value |= XGMAC_FRAME_FILTER_HMC | XGMAC_FRAME_FILTER_HPF;
+	} else {
+		use_hash = false;
 	}
 	netdev_for_each_mc_addr(ha, dev) {
 		if (use_hash) {
@@ -1313,6 +1320,8 @@ static void xgmac_set_rx_mode(struct net_device *dev)
 	}
 
 out:
+	for (i = reg; i < XGMAC_MAX_FILTER_ADDR; i++)
+		xgmac_set_mac_addr(ioaddr, NULL, reg);
 	for (i = 0; i < XGMAC_NUM_HASH; i++)
 		writel(hash_filter[i], ioaddr + XGMAC_HASH(i));
 
-- 
1.8.1.2
