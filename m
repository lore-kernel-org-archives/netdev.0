From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/15] fm10k: add statistics for actual DWORD count of mbmem mailbox
Date: Sun,  6 Dec 2015 00:01:26 -0800
Message-ID: <1449388894-128573-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449388894-128573-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24651 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752215AbbLFIBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2015 03:01:37 -0500
In-Reply-To: <1449388894-128573-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

A previous bug was uncovered by addition of a debug stat to indicate the
actual number of DWORDS we pulled from the mbmem. It turned out this was
not the same as the tx_dwords counter. While the previous bug fix should
have corrected this in all cases, add some debug stats that count the
number of DWORDs pushed or pulled from the mbmem. A future debugger may
take advantage of this statistic for debugging purposes. Since we're
modifying fm10k_mbx.h, update the copyright year as well.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 2 ++
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c     | 4 ++++
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.h     | 4 +++-
 3 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 2ce0eba..7c01561 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -114,9 +114,11 @@ static const struct fm10k_stats fm10k_gstrings_mbx_stats[] = {
 	FM10K_MBX_STAT("mbx_tx_oversized", tx_dropped),
 	FM10K_MBX_STAT("mbx_tx_messages", tx_messages),
 	FM10K_MBX_STAT("mbx_tx_dwords", tx_dwords),
+	FM10K_MBX_STAT("mbx_tx_mbmem_pulled", tx_mbmem_pulled),
 	FM10K_MBX_STAT("mbx_rx_messages", rx_messages),
 	FM10K_MBX_STAT("mbx_rx_dwords", rx_dwords),
 	FM10K_MBX_STAT("mbx_rx_parse_err", rx_parse_err),
+	FM10K_MBX_STAT("mbx_rx_mbmem_pushed", rx_mbmem_pushed),
 };
 
 #define FM10K_GLOBAL_STATS_LEN ARRAY_SIZE(fm10k_gstrings_global_stats)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
index af09a1b..2bce474 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
@@ -375,6 +375,8 @@ static void fm10k_mbx_write_copy(struct fm10k_hw *hw,
 			if (!tail)
 				tail++;
 
+			mbx->tx_mbmem_pulled++;
+
 			/* write message to hardware FIFO */
 			fm10k_write_reg(hw, mbmem + tail++, *(head++));
 		} while (--len && --end);
@@ -459,6 +461,8 @@ static void fm10k_mbx_read_copy(struct fm10k_hw *hw,
 			if (!head)
 				head++;
 
+			mbx->rx_mbmem_pushed++;
+
 			/* read message from hardware FIFO */
 			*(tail++) = fm10k_read_reg(hw, mbmem + head++);
 		} while (--len && --end);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h
index 0419a7f..c4f18a8 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -291,8 +291,10 @@ struct fm10k_mbx_info {
 	u64 tx_dropped;
 	u64 tx_messages;
 	u64 tx_dwords;
+	u64 tx_mbmem_pulled;
 	u64 rx_messages;
 	u64 rx_dwords;
+	u64 rx_mbmem_pushed;
 	u64 rx_parse_err;
 
 	/* Buffer to store messages */
-- 
2.5.0
