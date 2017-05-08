From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH] net: mdio-mux: bcm-iproc: call mdiobus_free() in error path
Date: Mon,  8 May 2017 17:48:35 -0400
Message-ID: <1494280115-9252-1-git-send-email-jon.mason@broadcom.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If an error is encountered in mdio_mux_init(), the error path will call
mdiobus_free().  Since mdiobus_register() has been called prior to
mdio_mux_init(), the bus->state will not be MDIOBUS_UNREGISTERED.  This
causes a BUG_ON() in mdiobus_free().  To correct this issue, add an
error path for mdio_mux_init() which calls mdiobus_unregister() prior to
mdiobus_free().

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
Fixes: 98bc865a1ec8 ("net: mdio-mux: Add MDIO mux driver for iProc SoCs")
---
 drivers/net/phy/mdio-mux-bcm-iproc.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio-mux-bcm-iproc.c b/drivers/net/phy/mdio-mux-bcm-iproc.c
index 0a0412524cec..0a5f62e0efcc 100644
--- a/drivers/net/phy/mdio-mux-bcm-iproc.c
+++ b/drivers/net/phy/mdio-mux-bcm-iproc.c
@@ -203,11 +203,14 @@ static int mdio_mux_iproc_probe(struct platform_device *pdev)
 			   &md->mux_handle, md, md->mii_bus);
 	if (rc) {
 		dev_info(md->dev, "mdiomux initialization failed\n");
-		goto out;
+		goto out_register;
 	}
 
 	dev_info(md->dev, "iProc mdiomux registered\n");
 	return 0;
+
+out_register:
+	mdiobus_unregister(bus);
 out:
 	mdiobus_free(bus);
 	return rc;
-- 
2.7.4
