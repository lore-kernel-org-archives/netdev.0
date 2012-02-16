From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH v2 2/2] adi: adapt to eth_hw_addr_random() and changes in arch/blackfin
Date: Thu, 16 Feb 2012 18:09:31 +0100
Message-ID: <1329412171-20704-3-git-send-email-danny.kukawka@bisect.de>
References: <1329412171-20704-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Mike Frysinger <vapier@gentoo.org>,
	Sonic Zhang <sonic.zhang@analog.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bob Liu <bob.liu@analog.com>,
	uclinux-dist-devel@blackfin.uclinux.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wp188.webpack.hosteurope.de ([80.237.132.195]:41804 "EHLO
	wp188.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752000Ab2BPRJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 12:09:52 -0500
In-Reply-To: <1329412171-20704-1-git-send-email-danny.kukawka@bisect.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adapt adi ethernet driver to changes in bfin_get_ether_addr()
from arch/blackfin. bfin_get_ether_addr() returns now a state.
Set a random mac address via new eth_hw_addr_random() in case
the return value is not 0.

Reset the state to NET_ADDR_PERM as soon as the MAC get
changed via .ndo_set_mac_address.

v2: change the logic to reduce unneeded checks

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/adi/bfin_mac.c |   15 +++++++++------
 drivers/net/ethernet/adi/bfin_mac.h |    2 +-
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index d812a10..905f0e1 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -621,6 +621,7 @@ static int bfin_mac_set_mac_address(struct net_device *dev, void *p)
 	if (netif_running(dev))
 		return -EBUSY;
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	setup_mac_addr(dev->dev_addr);
 	return 0;
 }
@@ -1496,12 +1497,14 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 	 * Grab the MAC from the board somehow
 	 * this is done in the arch/blackfin/mach-bfxxx/boards/eth_mac.c
 	 */
-	if (!is_valid_ether_addr(ndev->dev_addr))
-		bfin_get_ether_addr(ndev->dev_addr);
-
-	/* If still not valid, get a random one */
-	if (!is_valid_ether_addr(ndev->dev_addr))
-		random_ether_addr(ndev->dev_addr);
+	if (!is_valid_ether_addr(ndev->dev_addr)) {
+		if (bfin_get_ether_addr(ndev->dev_addr) || 
+		     !is_valid_ether_addr(ndev->dev_addr)) {
+			/* Still not valid, get a random one */
+			netdev_warn(ndev, "Setting Ethernet MAC to a random one\n");
+			eth_hw_addr_random(ndev);
+		}
+	}
 
 	setup_mac_addr(ndev->dev_addr);
 
diff --git a/drivers/net/ethernet/adi/bfin_mac.h b/drivers/net/ethernet/adi/bfin_mac.h
index f8559ac..960905c 100644
--- a/drivers/net/ethernet/adi/bfin_mac.h
+++ b/drivers/net/ethernet/adi/bfin_mac.h
@@ -101,6 +101,6 @@ struct bfin_mac_local {
 #endif
 };
 
-extern void bfin_get_ether_addr(char *addr);
+extern int bfin_get_ether_addr(char *addr);
 
 #endif
-- 
1.7.8.3
