From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v3 3/8] net: mvneta: Check tx queue setup error in mvneta_change_mtu()
Date: Thu, 22 May 2014 20:06:58 -0300
Message-ID: <1400800023-1562-4-git-send-email-ezequiel.garcia@free-electrons.com>
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
Received: from top.free-electrons.com ([176.31.233.9]:49700 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751243AbaEVXID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 19:08:03 -0400
In-Reply-To: <1400800023-1562-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit checks the return code of mvneta_setup_txq() call
in mvneta_change_mtu(). Also, use the netdevice pointer directly
instead of dereferencing the port structure. While here, let's
fix a tiny comment typo.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 3034601..d28327d 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2425,24 +2425,28 @@ static int mvneta_change_mtu(struct net_device *dev, int mtu)
 		return 0;
 
 	/* The interface is running, so we have to force a
-	 * reallocation of the RXQs
+	 * reallocation of the queues
 	 */
 	mvneta_stop_dev(pp);
 
 	mvneta_cleanup_txqs(pp);
 	mvneta_cleanup_rxqs(pp);
 
-	pp->pkt_size = MVNETA_RX_PKT_SIZE(pp->dev->mtu);
+	pp->pkt_size = MVNETA_RX_PKT_SIZE(dev->mtu);
 	pp->frag_size = SKB_DATA_ALIGN(MVNETA_RX_BUF_SIZE(pp->pkt_size)) +
 	                SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
 	ret = mvneta_setup_rxqs(pp);
 	if (ret) {
-		netdev_err(pp->dev, "unable to setup rxqs after MTU change\n");
+		netdev_err(dev, "unable to setup rxqs after MTU change\n");
 		return ret;
 	}
 
-	mvneta_setup_txqs(pp);
+	ret = mvneta_setup_txqs(pp);
+	if (ret) {
+		netdev_err(dev, "unable to setup txqs after MTU change\n");
+		return ret;
+	}
 
 	mvneta_start_dev(pp);
 	mvneta_port_up(pp);
-- 
1.9.1
