From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] net: caif: check return value of alloc_netdev
Date: Mon,  9 Nov 2015 13:19:10 +0100
Message-ID: <1447071550-20103-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't know if dev can actually be NULL here, but the test should be
above alloc_netdev(), to avoid leaking the struct net_device in case
dev is actually NULL. And of course the return value from alloc_netdev
should be tested.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
Maybe the existing code was supposed to be "if (!ndev)", and dev
cannot be NULL, but then -ENODEV is a slightly odd return
value. Doing both tests seems to be the safe choice.

 drivers/net/caif/caif_spi.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
index de3962014af7..4721948a92f6 100644
--- a/drivers/net/caif/caif_spi.c
+++ b/drivers/net/caif/caif_spi.c
@@ -730,11 +730,14 @@ int cfspi_spi_probe(struct platform_device *pdev)
 	int res;
 	dev = (struct cfspi_dev *)pdev->dev.platform_data;
 
-	ndev = alloc_netdev(sizeof(struct cfspi), "cfspi%d",
-			    NET_NAME_UNKNOWN, cfspi_setup);
 	if (!dev)
 		return -ENODEV;
 
+	ndev = alloc_netdev(sizeof(struct cfspi), "cfspi%d",
+			    NET_NAME_UNKNOWN, cfspi_setup);
+	if (!ndev)
+		return -ENOMEM;
+
 	cfspi = netdev_priv(ndev);
 	netif_stop_queue(ndev);
 	cfspi->ndev = ndev;
-- 
2.6.1
