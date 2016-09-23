From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next v2 1/2] i40e: remove superfluous I40E_DEBUG_USER statement
Date: Fri, 23 Sep 2016 15:30:57 +0200
Message-ID: <1474637458-5255-2-git-send-email-sassmann@kpanic.de>
References: <1474637458-5255-1-git-send-email-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com, carolyn.wyborny@intel.com,
        sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44328 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964968AbcIWNbV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 09:31:21 -0400
In-Reply-To: <1474637458-5255-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This debug statement is confusing and never set in the code. Any debug
output should be guarded by the proper I40E_DEBUG_* statement which can
be enabled via the debug module parameter or ethtool.
Remove or convert the I40E_DEBUG_USER cases to I40E_DEBUG_INIT.

v2: re-add setting the debug_mask in i40e_set_msglevel() so that the
debug level can still be altered via ethtool msglvl.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c  |  3 ---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c |  6 -----
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  3 +--
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 35 +++++++++++++-------------
 drivers/net/ethernet/intel/i40e/i40e_type.h    |  2 --
 5 files changed, 18 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 2154a34..8ccb09c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -3207,9 +3207,6 @@ static void i40e_parse_discover_capabilities(struct i40e_hw *hw, void *buff,
 			break;
 		case I40E_AQ_CAP_ID_MSIX:
 			p->num_msix_vectors = number;
-			i40e_debug(hw, I40E_DEBUG_INIT,
-				   "HW Capability: MSIX vector count = %d\n",
-				   p->num_msix_vectors);
 			break;
 		case I40E_AQ_CAP_ID_VF_MSIX:
 			p->num_msix_vectors_vf = number;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 05cf9a7..e9c6f1c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1210,12 +1210,6 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		u32 level;
 		cnt = sscanf(&cmd_buf[10], "%i", &level);
 		if (cnt) {
-			if (I40E_DEBUG_USER & level) {
-				pf->hw.debug_mask = level;
-				dev_info(&pf->pdev->dev,
-					 "set hw.debug_mask = 0x%08x\n",
-					 pf->hw.debug_mask);
-			}
 			pf->msg_enable = level;
 			dev_info(&pf->pdev->dev, "set msg_enable = 0x%08x\n",
 				 pf->msg_enable);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 1835186..02f55ab 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -987,8 +987,7 @@ static void i40e_set_msglevel(struct net_device *netdev, u32 data)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_pf *pf = np->vsi->back;
 
-	if (I40E_DEBUG_USER & data)
-		pf->hw.debug_mask = data;
+	pf->hw.debug_mask = data;
 	pf->msg_enable = data;
 }
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 61b0fc4..56369761 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6665,16 +6665,19 @@ static int i40e_get_capabilities(struct i40e_pf *pf)
 		}
 	} while (err);
 
-	if (pf->hw.debug_mask & I40E_DEBUG_USER)
-		dev_info(&pf->pdev->dev,
-			 "pf=%d, num_vfs=%d, msix_pf=%d, msix_vf=%d, fd_g=%d, fd_b=%d, pf_max_q=%d num_vsi=%d\n",
-			 pf->hw.pf_id, pf->hw.func_caps.num_vfs,
-			 pf->hw.func_caps.num_msix_vectors,
-			 pf->hw.func_caps.num_msix_vectors_vf,
-			 pf->hw.func_caps.fd_filters_guaranteed,
-			 pf->hw.func_caps.fd_filters_best_effort,
-			 pf->hw.func_caps.num_tx_qp,
-			 pf->hw.func_caps.num_vsis);
+	i40e_debug(&pf->hw, I40E_DEBUG_INIT,
+		   "HW Capabilities: PF-id[%d] num_vfs=%d, msix_pf=%d, msix_vf=%d\n",
+		   pf->hw.pf_id,
+		   pf->hw.func_caps.num_vfs,
+		   pf->hw.func_caps.num_msix_vectors,
+		   pf->hw.func_caps.num_msix_vectors_vf);
+	i40e_debug(&pf->hw, I40E_DEBUG_INIT,
+		   "HW Capabilities: PF-id[%d] fd_g=%d, fd_b=%d, pf_max_qp=%d num_vsis=%d\n",
+		   pf->hw.pf_id,
+		   pf->hw.func_caps.fd_filters_guaranteed,
+		   pf->hw.func_caps.fd_filters_best_effort,
+		   pf->hw.func_caps.num_tx_qp,
+		   pf->hw.func_caps.num_vsis);
 
 #define DEF_NUM_VSI (1 + (pf->hw.func_caps.fcoe ? 1 : 0) \
 		       + pf->hw.func_caps.num_vfs)
@@ -8495,14 +8498,10 @@ static int i40e_sw_init(struct i40e_pf *pf)
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
+					NETIF_MSG_DRV    |
+					NETIF_MSG_PROBE  |
+					NETIF_MSG_LINK);
 
 	/* Set default capability flags */
 	pf->flags = I40E_FLAG_RX_CSUM_ENABLED |
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index bd5f13b..7e88e35 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -85,8 +85,6 @@ enum i40e_debug_mask {
 	I40E_DEBUG_AQ_COMMAND		= 0x06000000,
 	I40E_DEBUG_AQ			= 0x0F000000,
 
-	I40E_DEBUG_USER			= 0xF0000000,
-
 	I40E_DEBUG_ALL			= 0xFFFFFFFF
 };
 
-- 
2.7.4
