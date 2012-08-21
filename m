From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 6/8] netdev: octeon_mgmt: Cleanup and modernize MAC address handling.
Date: Tue, 21 Aug 2012 11:45:10 -0700
Message-ID: <1345574712-21444-7-git-send-email-ddaney.cavm@gmail.com>
References: <1345574712-21444-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>
To: linux-mips@linux-mips.org, ralf@linux-mips.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345574712-21444-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

Use eth_mac_addr(), and generate a random address if none is otherwise
assigned.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/ethernet/octeon/octeon_mgmt.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index 3bae01f..9b526da 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -648,12 +648,10 @@ static void octeon_mgmt_set_rx_filtering(struct net_device *netdev)
 
 static int octeon_mgmt_set_mac_address(struct net_device *netdev, void *addr)
 {
-	struct sockaddr *sa = addr;
+	int r = eth_mac_addr(netdev, addr);
 
-	if (!is_valid_ether_addr(sa->sa_data))
-		return -EADDRNOTAVAIL;
-
-	memcpy(netdev->dev_addr, sa->sa_data, ETH_ALEN);
+	if (r)
+		return r;
 
 	octeon_mgmt_set_rx_filtering(netdev);
 
@@ -1545,8 +1543,12 @@ static int __devinit octeon_mgmt_probe(struct platform_device *pdev)
 
 	mac = of_get_mac_address(pdev->dev.of_node);
 
-	if (mac)
-		memcpy(netdev->dev_addr, mac, 6);
+	if (mac && is_valid_ether_addr(mac)) {
+		memcpy(netdev->dev_addr, mac, ETH_ALEN);
+		netdev->addr_assign_type &= ~NET_ADDR_RANDOM;
+	} else {
+		eth_hw_addr_random(netdev);
+	}
 
 	p->phy_np = of_parse_phandle(pdev->dev.of_node, "phy-handle", 0);
 
-- 
1.7.11.4
