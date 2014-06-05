From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] i40e: Allow disabling of DCB via debugfs
Date: Thu,  5 Jun 2014 00:49:15 -0700
Message-ID: <1401954567-13557-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401954567-13557-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:52024 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751821AbaFEHtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 03:49:36 -0400
In-Reply-To: <1401954567-13557-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

Diagnostic and traffic generator tests fail when DCB is enabled.
This is due to the fact that when DCB is enabled the Tx packets
from the adapter are VLAN tagged and these tests are not expecting
an extra tag in the packets.

So, allow disabling of the DCB flag via debugfs so that these tests
can proceed.

New debugfs commands
"dcb off" -- Disable DCB tagging; only works when in single TC mode
"dcb on" -- Re-enable DCB tagging

Change-ID: I14cc894e1cbf8a3b8ecfba4a3886f9861e7678ed
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  1 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 13 +++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_main.c    |  2 +-
 3 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 581898f..4598f3f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -628,4 +628,5 @@ int i40e_ptp_set_ts_config(struct i40e_pf *pf, struct ifreq *ifr);
 int i40e_ptp_get_ts_config(struct i40e_pf *pf, struct ifreq *ifr);
 void i40e_ptp_init(struct i40e_pf *pf);
 void i40e_ptp_stop(struct i40e_pf *pf);
+u8 i40e_pf_get_num_tc(struct i40e_pf *pf);
 #endif /* _I40E_H_ */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 1aaec40..ca06741 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1744,6 +1744,17 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		i40e_dbg_cmd_fd_ctrl(pf, I40E_FLAG_FD_ATR_ENABLED, false);
 	} else if (strncmp(cmd_buf, "fd-atr on", 9) == 0) {
 		i40e_dbg_cmd_fd_ctrl(pf, I40E_FLAG_FD_ATR_ENABLED, true);
+	} else if (strncmp(cmd_buf, "dcb off", 7) == 0) {
+		u8 tc = i40e_pf_get_num_tc(pf);
+		/* Allow disabling only when in single TC mode */
+		if (tc > 1) {
+			dev_info(&pf->pdev->dev, "Failed to disable DCB as TC count(%d) is greater than 1.\n",
+				 tc);
+			goto command_write_done;
+		}
+		pf->flags &= ~I40E_FLAG_DCB_ENABLED;
+	} else if (strncmp(cmd_buf, "dcb on", 6) == 0) {
+		pf->flags |= I40E_FLAG_DCB_ENABLED;
 	} else if (strncmp(cmd_buf, "lldp", 4) == 0) {
 		if (strncmp(&cmd_buf[5], "stop", 4) == 0) {
 			int ret;
@@ -1970,6 +1981,8 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		dev_info(&pf->pdev->dev, "  lldp event on\n");
 		dev_info(&pf->pdev->dev, "  lldp event off\n");
 		dev_info(&pf->pdev->dev, "  nvm read [module] [word_offset] [word_count]\n");
+		dev_info(&pf->pdev->dev, "  dcb off\n");
+		dev_info(&pf->pdev->dev, "  dcb on\n");
 	}
 
 command_write_done:
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index cef3db4..2412c71 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3622,7 +3622,7 @@ static u8 i40e_dcb_get_enabled_tc(struct i40e_dcbx_config *dcbcfg)
  *
  * Return number of traffic classes enabled for the given PF
  **/
-static u8 i40e_pf_get_num_tc(struct i40e_pf *pf)
+u8 i40e_pf_get_num_tc(struct i40e_pf *pf)
 {
 	struct i40e_hw *hw = &pf->hw;
 	u8 i, enabled_tc;
-- 
1.9.3
