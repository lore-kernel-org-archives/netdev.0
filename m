From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH] i40e: Clean up handling of msg_enable flags and
 debug parameter
Date: Thu, 29 Sep 2016 08:05:53 -0400
Message-ID: <20160929115832.42066.71367.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linville@tuxdriver.com
To: sassmann@kpanic.de, intel-wired-lan@lists.osuosl.org,
        jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:58095 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934465AbcI2SFx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Sep 2016 14:05:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So the i40e driver had a really convoluted configuration for how to handle
the debug flags contained in msg_enable.  Part of the issue is that the
driver has its own 32 bit mask that it was using to track a separate set of
debug features.  From what I can tell it was trying to use the upper 4 bits
to determine if the value was meant to represent a bit-mask or the numeric
value provided by debug level.

What this patch does is clean this up by compressing those 4 bits into bit
31, as a result we just have to perform a check against the value being
negative to determine if we are looking at a debug level (positive), or a
debug mask (negative).  The debug level will populate the msg_level, and
the debug mask will populate the debug_mask in the hardware struct.

I added similar logic for ethtool.  If the value being provided has bit 31
set we assume the value being provided is a debug mask, otherwise we assume
it is a msg_enable mask.  For displaying we only provide the msg_enable,
and if debug_mask is in use we will print it to the dmesg log.

Lastly I removed the debugfs interface.  It is redundant with what we
already have in ethtool and really doesn't belong anyway.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

So I am running this through a slightly different process than standard
because there are some items here that might be objectionable so I want to
have that ironed out before I deal with the out-of-tree Intel driver.

I just want to verify if this fix for this will work for net-next or if I
need to look at taking a different approach.  Once I get the go-no-go, I
will back-port this into the out-of-tree i40e driver.

 drivers/net/ethernet/intel/i40e/i40e_debugfs.c |   18 ---------------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |    7 +++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c    |   28 ++++++++++++------------
 3 files changed, 20 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 0c1875b..acb0f13 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1210,24 +1210,6 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			dev_info(&pf->pdev->dev,
 				 "dump debug fwdata <cluster_id> <table_id> <index>\n");
 		}
-
-	} else if (strncmp(cmd_buf, "msg_enable", 10) == 0) {
-		u32 level;
-		cnt = sscanf(&cmd_buf[10], "%i", &level);
-		if (cnt) {
-			if (I40E_DEBUG_USER & level) {
-				pf->hw.debug_mask = level;
-				dev_info(&pf->pdev->dev,
-					 "set hw.debug_mask = 0x%08x\n",
-					 pf->hw.debug_mask);
-			}
-			pf->msg_enable = level;
-			dev_info(&pf->pdev->dev, "set msg_enable = 0x%08x\n",
-				 pf->msg_enable);
-		} else {
-			dev_info(&pf->pdev->dev, "msg_enable = 0x%08x\n",
-				 pf->msg_enable);
-		}
 	} else if (strncmp(cmd_buf, "pfr", 3) == 0) {
 		dev_info(&pf->pdev->dev, "debugfs: forcing PFR\n");
 		i40e_do_reset_safe(pf, BIT(__I40E_PF_RESET_REQUESTED));
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index e79a920..b133a77 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -978,6 +978,10 @@ static u32 i40e_get_msglevel(struct net_device *netdev)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_pf *pf = np->vsi->back;
+	u32 debug_mask = pf->hw.debug_mask;
+
+	if (debug_mask)
+		netdev_info(netdev, "i40e debug_mask: 0x%08X\n", debug_mask);
 
 	return pf->msg_enable;
 }
@@ -989,7 +993,8 @@ static void i40e_set_msglevel(struct net_device *netdev, u32 data)
 
 	if (I40E_DEBUG_USER & data)
 		pf->hw.debug_mask = data;
-	pf->msg_enable = data;
+	else
+		pf->msg_enable = data;
 }
 
 static int i40e_get_regs_len(struct net_device *netdev)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b93fa2a..b24c6eb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -93,8 +93,8 @@ MODULE_DEVICE_TABLE(pci, i40e_pci_tbl);
 
 #define I40E_MAX_VF_COUNT 128
 static int debug = -1;
-module_param(debug, int, 0);
-MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
+module_param(debug, uint, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all), Debug mask (0x8XXXXXXX)");
 
 MODULE_AUTHOR("Intel Corporation, <e1000-devel@lists.sourceforge.net>");
 MODULE_DESCRIPTION("Intel(R) Ethernet Connection XL710 Network Driver");
@@ -8481,14 +8481,12 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	int err = 0;
 	int size;
 
-	pf->msg_enable = netif_msg_init(I40E_DEFAULT_MSG_ENABLE,
-				(NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK));
-	if (debug != -1 && debug != I40E_DEFAULT_MSG_ENABLE) {
-		if (I40E_DEBUG_USER & debug)
-			pf->hw.debug_mask = debug;
-		pf->msg_enable = netif_msg_init((debug & ~I40E_DEBUG_USER),
-						I40E_DEFAULT_MSG_ENABLE);
-	}
+	pf->msg_enable = netif_msg_init(debug,
+					NETIF_MSG_DRV |
+					NETIF_MSG_PROBE |
+					NETIF_MSG_LINK);
+	if (debug < -1)
+		pf->hw.debug_mask = debug;
 
 	/* Set default capability flags */
 	pf->flags = I40E_FLAG_RX_CSUM_ENABLED |
@@ -10790,10 +10788,12 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	mutex_init(&hw->aq.asq_mutex);
 	mutex_init(&hw->aq.arq_mutex);
 
-	if (debug != -1) {
-		pf->msg_enable = pf->hw.debug_mask;
-		pf->msg_enable = debug;
-	}
+	pf->msg_enable = netif_msg_init(debug,
+					NETIF_MSG_DRV |
+					NETIF_MSG_PROBE |
+					NETIF_MSG_LINK);
+	if (debug < -1)
+		pf->hw.debug_mask = debug;
 
 	/* do a special CORER for clearing PXE mode once at init */
 	if (hw->revision_id == 0 &&
