From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] i40e: reduce wait time for adminq command completion
Date: Wed, 19 Apr 2017 18:57:46 -0700
Message-ID: <20170420015750.6828-11-jeffrey.t.kirsher@intel.com>
References: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:47224 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S939105AbdDTB6C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 21:58:02 -0400
In-Reply-To: <20170420015750.6828-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When sending an adminq command, we wait for the command to complete in
a loop. This loop waits for an entire millisecond, when in practice the
adminq command is processed often much faster.

Change the loop to use i40e_usec_delay instead, and wait for 50 usecs
each time instead. This appears to be about the minimum time required,
based on some manual observation and testing.

The primary benefit of this change is reducing latency of various
operations in the PF driver, especially when related to having a large
number of VFs enabled.

For example, on Linux, when instantiating 128 VFs, the time to finish
the operation dropped from about 9 seconds down to under 6 seconds.
Additionally, the time it takes to finish a PF reset with 128 VFs
dropped from 5.1 seconds down to 0.7 seconds.

As the examples above show, a significant portion of the delay is wasted
waiting for admiqn operations which have already finished.

This patch shouldn't cause impact to functionality, as we still check
and keep waiting until the command does get processed. The only expected
change is an increase in CPU utilization as we now check for completion
far more times. However, in practice the commands appear to generally be
complete within the first delay window anyways.

Change-ID: If8af8388e100da0a14eaf9e1af3afadf73a958cf
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   | 4 ++--
 drivers/net/ethernet/intel/i40e/i40e_adminq.h   | 2 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c | 4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h | 2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 56fb27298936..ba04988e0598 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -850,8 +850,8 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
 			 */
 			if (i40e_asq_done(hw))
 				break;
-			usleep_range(1000, 2000);
-			total_delay++;
+			udelay(50);
+			total_delay += 50;
 		} while (total_delay < hw->aq.asq_cmd_timeout);
 	}
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
index d92aad38afdc..2349fbe04bd2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
@@ -151,7 +151,7 @@ static inline int i40e_aq_rc_to_posix(int aq_ret, int aq_rc)
 
 /* general information */
 #define I40E_AQ_LARGE_BUF	512
-#define I40E_ASQ_CMD_TIMEOUT	250  /* msecs */
+#define I40E_ASQ_CMD_TIMEOUT	250000  /* usecs */
 
 void i40e_fill_default_direct_cmd_desc(struct i40e_aq_desc *desc,
 				       u16 opcode);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index 96385156b824..8b0d4b255dea 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -797,8 +797,8 @@ i40e_status i40evf_asq_send_command(struct i40e_hw *hw,
 			 */
 			if (i40evf_asq_done(hw))
 				break;
-			usleep_range(1000, 2000);
-			total_delay++;
+			udelay(50);
+			total_delay += 50;
 		} while (total_delay < hw->aq.asq_cmd_timeout);
 	}
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
index 1f9b3b5d946d..e0bfaa3d4a21 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
@@ -151,7 +151,7 @@ static inline int i40e_aq_rc_to_posix(int aq_ret, int aq_rc)
 
 /* general information */
 #define I40E_AQ_LARGE_BUF	512
-#define I40E_ASQ_CMD_TIMEOUT	250  /* msecs */
+#define I40E_ASQ_CMD_TIMEOUT	250000  /* usecs */
 
 void i40evf_fill_default_direct_cmd_desc(struct i40e_aq_desc *desc,
 				       u16 opcode);
-- 
2.12.2
