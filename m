From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 5/7] net: mvneta: Use prepare/commit API to simplify MAC address setting
Date: Sat,  3 May 2014 15:27:00 -0300
Message-ID: <1399141622-30654-6-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1399141622-30654-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:60650 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752410AbaECS21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 14:28:27 -0400
In-Reply-To: <1399141622-30654-1-git-send-email-ezequiel.garcia@free-electrons.com>
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
index 9a444a0..0dcce29 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2323,22 +2323,19 @@ static void mvneta_get_mac_addr(struct mvneta_port *pp, unsigned char *addr)
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
 
@@ -2433,8 +2430,6 @@ static int mvneta_open(struct net_device *dev)
 	struct mvneta_port *pp = netdev_priv(dev);
 	int ret;
 
-	mvneta_mac_addr_set(pp, dev->dev_addr, rxq_def);
-
 	pp->pkt_size = MVNETA_RX_PKT_SIZE(pp->dev->mtu);
 	pp->frag_size = SKB_DATA_ALIGN(MVNETA_RX_BUF_SIZE(pp->pkt_size)) +
 	                SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
-- 
1.9.1
