From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: [PATCH] net: stmmac: synchronize stmmac_open and stmmac_dvr_probe
Date: Tue, 27 Dec 2016 19:44:59 +0800
Message-ID: <1482839100-20612-1-git-send-email-hock.leong.kweh@intel.com>
Cc: Alexandre TORGUE <alexandre.torgue@gmail.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Johan Hovold <johan@kernel.org>, pavel@ucw.cz,
        "Kweh, Hock Leong" <hock.leong.kweh@intel.com>,
        Ong Boon Leong <boon.leong.ong@intel.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, weifeng.voon@intel.com,
        Lars Persson <lars.persson@axis.com>
To: "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        seraphin.bonnaffe@st.com
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

The resolution used wait_for_completion_interruptible() to synchronize
stmmac_open() and stmmac_dvr_probe() to prevent the race condition
happening.

Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index eab04ae..5daf8a5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -131,6 +131,7 @@ struct stmmac_priv {
 	u32 rx_tail_addr;
 	u32 tx_tail_addr;
 	u32 mss;
+	struct completion probe_done;
 
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *dbgfs_dir;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index bb40382..28e85f6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1770,6 +1770,14 @@ static int stmmac_open(struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 	int ret;
 
+	ret = wait_for_completion_interruptible(&priv->probe_done);
+	if (ret) {
+		netdev_err(priv->dev,
+			   "%s: Interrupted while waiting probe completion\n",
+			   __func__);
+		return ret;
+	}
+
 	stmmac_check_ether_addr(priv);
 
 	if (priv->hw->pcs != STMMAC_PCS_RGMII &&
@@ -3226,6 +3234,7 @@ int stmmac_dvr_probe(struct device *device,
 	priv = netdev_priv(ndev);
 	priv->device = device;
 	priv->dev = ndev;
+	init_completion(&priv->probe_done);
 
 	stmmac_set_ethtool_ops(ndev);
 	priv->pause = pause;
@@ -3372,6 +3381,7 @@ int stmmac_dvr_probe(struct device *device,
 		}
 	}
 
+	complete_all(&priv->probe_done);
 	return 0;
 
 error_mdio_register:
-- 
1.7.9.5
