From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v3 5/8] net: mvneta: Use prepare/commit API to simplify MAC address setting
Date: Thu, 22 May 2014 20:07:00 -0300
Message-ID: <1400800023-1562-6-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1400800023-1562-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:49715 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753169AbaEVXIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 19:08:12 -0400
In-Reply-To: <1400800023-1562-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use eth_prepare_mac_addr_change and eth_commit_mac_addr_change, instead
of manually checking and storing the MAC address, which makes the
code slightly more robust. This fixes the lack of valid MAC address check
in the driver's .ndo_set_mac_address hook.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 19 +++++++------------
 1 file changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 66e4631..dd84b6a 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2473,22 +2473,19 @@ static void mvneta_get_mac_addr(struct mvneta_port *pp, unsigned char *addr)
 static int mvneta_set_mac_addr(struct net_device *dev, void *addr)
 {
 	struct mvneta_port *pp = netdev_priv(dev);
-	u8 *mac = addr + 2;
-	int i;
-
-	if (netif_running(dev))
-		return -EBUSY;
+	struct sockaddr *sockaddr = addr;
+	int ret;
 
+	ret = eth_prepare_mac_addr_change(dev, addr);
+	if (ret < 0)
+		return ret;
 	/* Remove previous address table entry */
 	mvneta_mac_addr_set(pp, dev->dev_addr, -1);
 
 	/* Set new addr in hw */
-	mvneta_mac_addr_set(pp, mac, rxq_def);
-
-	/* Set addr in the device */
-	for (i = 0; i < ETH_ALEN; i++)
-		dev->dev_addr[i] = mac[i];
+	mvneta_mac_addr_set(pp, sockaddr->sa_data, rxq_def);
 
+	eth_commit_mac_addr_change(dev, addr);
 	return 0;
 }
 
@@ -2583,8 +2580,6 @@ static int mvneta_open(struct net_device *dev)
 	struct mvneta_port *pp = netdev_priv(dev);
 	int ret;
 
-	mvneta_mac_addr_set(pp, dev->dev_addr, rxq_def);
-
 	pp->pkt_size = MVNETA_RX_PKT_SIZE(pp->dev->mtu);
 	pp->frag_size = SKB_DATA_ALIGN(MVNETA_RX_BUF_SIZE(pp->pkt_size)) +
 	                SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
-- 
1.9.1
