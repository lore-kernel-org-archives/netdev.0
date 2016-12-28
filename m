From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: stmmac: Fix race between stmmac_drv_probe and stmmac_open
Date: Tue, 27 Dec 2016 18:23:06 -0800
Message-ID: <20161228022306.14442-1-f.fainelli@gmail.com>
References: <F54AEECA5E2B9541821D670476DAE19C5A916C0E@PGSMSX102.gar.corp.intel.com>
Cc: pavel@ucw.cz, Joao.Pinto@synopsys.com, seraphin.bonnaffe@st.com,
        alexandre.torgue@gmail.com, manabian@gmail.com,
        niklas.cassel@axis.com, johan@kernel.org, boon.leong.ong@intel.com,
        weifeng.voon@intel.com, lars.persson@axis.com,
        linux-kernel@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F54AEECA5E2B9541821D670476DAE19C5A916C0E@PGSMSX102.gar.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is currently a small window during which the network device registered by
stmmac can be made visible, yet all resources, including and clock and MDIO bus
have not had a chance to be set up, this can lead to the following error to
occur:

[  473.919358] stmmaceth 0000:01:00.0 (unnamed net_device) (uninitialized):
                stmmac_dvr_probe: warning: cannot get CSR clock
[  473.919382] stmmaceth 0000:01:00.0: no reset control found
[  473.919412] stmmac - user ID: 0x10, Synopsys ID: 0x42
[  473.919429] stmmaceth 0000:01:00.0: DMA HW capability register supported
[  473.919436] stmmaceth 0000:01:00.0: RX Checksum Offload Engine supported
[  473.919443] stmmaceth 0000:01:00.0: TX Checksum insertion supported
[  473.919451] stmmaceth 0000:01:00.0 (unnamed net_device) (uninitialized):
                Enable RX Mitigation via HW Watchdog Timer
[  473.921395] libphy: PHY stmmac-1:00 not found
[  473.921417] stmmaceth 0000:01:00.0 eth0: Could not attach to PHY
[  473.921427] stmmaceth 0000:01:00.0 eth0: stmmac_open: Cannot attach to
                PHY (error: -19)
[  473.959710] libphy: stmmac: probed
[  473.959724] stmmaceth 0000:01:00.0 eth0: PHY ID 01410cc2 at 0 IRQ POLL
                (stmmac-1:00) active
[  473.959728] stmmaceth 0000:01:00.0 eth0: PHY ID 01410cc2 at 1 IRQ POLL
                (stmmac-1:01)
[  473.959731] stmmaceth 0000:01:00.0 eth0: PHY ID 01410cc2 at 2 IRQ POLL
                (stmmac-1:02)
[  473.959734] stmmaceth 0000:01:00.0 eth0: PHY ID 01410cc2 at 3 IRQ POLL
                (stmmac-1:03)

Fix this by making sure that register_netdev() is the last thing being done,
which guarantees that the clock and the MDIO bus are available.

Fixes: 4bfcbd7abce2 ("stmmac: Move the mdio_register/_unregister in probe/remove")
Reported-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index bb40382e205d..5910ea51f8f6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3339,13 +3339,6 @@ int stmmac_dvr_probe(struct device *device,
 
 	spin_lock_init(&priv->lock);
 
-	ret = register_netdev(ndev);
-	if (ret) {
-		netdev_err(priv->dev, "%s: ERROR %i registering the device\n",
-			   __func__, ret);
-		goto error_netdev_register;
-	}
-
 	/* If a specific clk_csr value is passed from the platform
 	 * this means that the CSR Clock Range selection cannot be
 	 * changed at run-time and it is fixed. Viceversa the driver'll try to
@@ -3372,11 +3365,14 @@ int stmmac_dvr_probe(struct device *device,
 		}
 	}
 
-	return 0;
+	ret = register_netdev(ndev);
+	if (ret)
+		netdev_err(priv->dev, "%s: ERROR %i registering the device\n",
+			   __func__, ret);
+
+	return ret;
 
 error_mdio_register:
-	unregister_netdev(ndev);
-error_netdev_register:
 	netif_napi_del(&priv->napi);
 error_hw_init:
 	clk_disable_unprepare(priv->pclk);
-- 
2.9.3
