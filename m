From: Fugang Duan <B38611@freescale.com>
Subject: [PATCH net-next v1 1/1] net: fec: init MAC prior to mii bus probe
Date: Tue, 23 Jun 2015 15:32:51 +0800
Message-ID: <1435044771-22828-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <stephen@networkplumber.org>,
	<b38611@freescale.com>, <Frank.Li@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0114.outbound.protection.outlook.com ([157.56.111.114]:50743
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753509AbbFWHhV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2015 03:37:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Below case causes mii bus probe failed:
ifconfig eth0 down -> suspend/resume with Mega/fax mix off -> ifconfig eth0 up

In i.MX6SX/i.MX7D chip, Mega/fast mix off feature is supported that means most of
SOC power will be off including ENET MAC for power saving. Once ENET MAC power
off, all initialized MAC registers reset to default, so in the case, it must
init MAC prior to mii bus probe.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index bf4cf3f..e464aea 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2856,12 +2856,14 @@ fec_enet_open(struct net_device *ndev)
 	if (ret)
 		goto err_enet_alloc;
 
+	/* Init MAC prior to mii bus probe */
+	fec_restart(ndev);
+
 	/* Probe and connect to PHY when open the interface */
 	ret = fec_enet_mii_probe(ndev);
 	if (ret)
 		goto err_enet_mii_probe;
 
-	fec_restart(ndev);
 	napi_enable(&fep->napi);
 	phy_start(fep->phy_dev);
 	netif_tx_start_all_queues(ndev);
-- 
1.7.8
