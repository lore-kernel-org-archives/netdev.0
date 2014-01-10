From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/17] i40e: check for possible incorrect ipv6 checksum
Date: Fri, 10 Jan 2014 12:30:32 -0800
Message-ID: <1389385839-11996-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389385839-11996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20038 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758216AbaAJUaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 15:30:46 -0500
In-Reply-To: <1389385839-11996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

If the IPV6EXADD bit is set in the Rx descriptor status, there
was an optional extension header with an alternate IP address
detected.  The HW checksum offload doesn't handle the alternate
IP address correctly so likely comes up with the wrong answer.
Thus, if the bit is set we ignore the checksum offload value.

Change-ID: I70ff8d38cdcddccf44107691cae13d0c07c284c8
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 4 ++++
 drivers/net/ethernet/intel/i40e/i40e_type.h | 4 +++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 43d88dd..946d8b1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -892,6 +892,10 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	      rx_status & (1 << I40E_RX_DESC_STATUS_L3L4P_SHIFT)))
 		return;
 
+	/* likely incorrect csum if alternate IP extention headers found */
+	if (rx_status & (1 << I40E_RX_DESC_STATUS_IPV6EXADD_SHIFT))
+		return;
+
 	/* IP or L4 or outmost IP checksum error */
 	if (rx_error & ((1 << I40E_RX_DESC_ERROR_IPE_SHIFT) |
 			(1 << I40E_RX_DESC_ERROR_L4E_SHIFT) |
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 072c850..80cf240 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -499,7 +499,9 @@ enum i40e_rx_desc_status_bits {
 	I40E_RX_DESC_STATUS_FLM_SHIFT		= 11,
 	I40E_RX_DESC_STATUS_FLTSTAT_SHIFT	= 12, /* 2 BITS */
 	I40E_RX_DESC_STATUS_LPBK_SHIFT		= 14,
-	I40E_RX_DESC_STATUS_UDP_0_SHIFT		= 16
+	I40E_RX_DESC_STATUS_IPV6EXADD_SHIFT	= 15,
+	I40E_RX_DESC_STATUS_RESERVED_SHIFT	= 16, /* 2 BITS */
+	I40E_RX_DESC_STATUS_UDP_0_SHIFT		= 18
 };
 
 #define I40E_RXD_QW1_STATUS_TSYNINDX_SHIFT   I40E_RX_DESC_STATUS_TSYNINDX_SHIFT
-- 
1.8.3.1
