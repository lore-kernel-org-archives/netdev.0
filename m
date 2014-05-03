From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 3/7] net: mvneta: Check tx queue setup error in mvneta_change_mtu()
Date: Sat,  3 May 2014 15:26:58 -0300
Message-ID: <1399141622-30654-4-git-send-email-ezequiel.garcia@free-electrons.com>
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
Received: from top.free-electrons.com ([176.31.233.9]:60632 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752218AbaECS2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 14:28:16 -0400
In-Reply-To: <1399141622-30654-1-git-send-email-ezequiel.garcia@free-electrons.com>
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
index d73ed91..743503a 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2275,24 +2275,28 @@ static int mvneta_change_mtu(struct net_device *dev, int mtu)
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
