From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: [PATCH v2] net: stmmac: bug fix to synchronize stmmac_open and stmmac_dvr_probe
Date: Tue, 27 Dec 2016 22:42:36 +0800
Message-ID: <1482849756-21817-1-git-send-email-hock.leong.kweh@intel.com>
Cc: Alexandre TORGUE <alexandre.torgue@gmail.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Johan Hovold <johan@kernel.org>, pavel@ucw.cz,
        Ong Boon Leong <boon.leong.ong@intel.com>,
        "Kweh, Hock Leong" <hock.leong.kweh@intel.com>,
        weifeng.voon@intel.com, lars.persson@axis.com,
        netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        seraphin.bonnaffe@st.com, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>

If kernel module stmmac driver being loaded after OS booted, there is a
race condition between stmmac_open() and stmmac_mdio_register(), which is
invoked inside stmmac_dvr_probe(), and the error is showed in dmesg log as
PHY not found and stmmac_open() failed:
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

The resolution moved the register_netdev() function call to the end of
stmmac_dvr_probe() after stmmac_mdio_register().

Suggested-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>
---
changelog v2:
* Re-implemented the fix base on David & Florian suggestion and tested.

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index bb40382..263ac53 100644
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
@@ -3372,11 +3365,18 @@ int stmmac_dvr_probe(struct device *device,
 		}
 	}
 
+	ret = register_netdev(ndev);
+	if (ret) {
+		netdev_err(priv->dev, "%s: ERROR %i registering the device\n",
+			   __func__, ret);
+		goto error_netdev_register;
+	}
+
 	return 0;
 
-error_mdio_register:
-	unregister_netdev(ndev);
 error_netdev_register:
+	stmmac_mdio_unregister(ndev);
+error_mdio_register:
 	netif_napi_del(&priv->napi);
 error_hw_init:
 	clk_disable_unprepare(priv->pclk);
-- 
1.7.9.5
