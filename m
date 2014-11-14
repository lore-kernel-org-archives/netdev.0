From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] ieee802154: fix error handling in ieee802154fake_probe()
Date: Sat, 15 Nov 2014 02:11:59 +0300
Message-ID: <1416006719-3450-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexander Aring <alex.aring@gmail.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case of any failure ieee802154fake_probe() just calls unregister_netdev().
But it does not look safe to unregister netdevice before it was registered.

The patch implements straightforward resource deallocation in case of
failure in ieee802154fake_probe().

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/ieee802154/fakehard.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ieee802154/fakehard.c b/drivers/net/ieee802154/fakehard.c
index 9ce854f43917..6cbc56ad9ff4 100644
--- a/drivers/net/ieee802154/fakehard.c
+++ b/drivers/net/ieee802154/fakehard.c
@@ -377,17 +377,20 @@ static int ieee802154fake_probe(struct platform_device *pdev)
 
 	err = wpan_phy_register(phy);
 	if (err)
-		goto out;
+		goto err_phy_reg;
 
 	err = register_netdev(dev);
-	if (err < 0)
-		goto out;
+	if (err)
+		goto err_netdev_reg;
 
 	dev_info(&pdev->dev, "Added ieee802154 HardMAC hardware\n");
 	return 0;
 
-out:
-	unregister_netdev(dev);
+err_netdev_reg:
+	wpan_phy_unregister(phy);
+err_phy_reg:
+	free_netdev(dev);
+	wpan_phy_free(phy);
 	return err;
 }
 
-- 
1.9.1
