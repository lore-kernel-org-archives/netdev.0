From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] i40e: check multi-bit state correctly
Date: Fri,  6 Dec 2013 18:17:11 -0800
Message-ID: <1386382643-29055-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:23891 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755196Ab3LGCR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 21:17:27 -0500
In-Reply-To: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The hash is reported correctly in the rss field if and only if
the filter status is 3.  Other values of filter status mean
different things and we shouldn't depend on a bitwise result.

The issue was that
a & b --> returns true for b={1,2,3}
the fix is
a & b == b

Also refactor this function to use constant operations because we
are in fast path.

Change-Id: I4e29be87439c1cf8b60bc31bea29dff89596c013
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index f1f03bc..01d0334 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -891,13 +891,15 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 static inline u32 i40e_rx_hash(struct i40e_ring *ring,
 			       union i40e_rx_desc *rx_desc)
 {
-	if (ring->netdev->features & NETIF_F_RXHASH) {
-		if ((le64_to_cpu(rx_desc->wb.qword1.status_error_len) >>
-		     I40E_RX_DESC_STATUS_FLTSTAT_SHIFT) &
-		    I40E_RX_DESC_FLTSTAT_RSS_HASH)
-			return le32_to_cpu(rx_desc->wb.qword0.hi_dword.rss);
-	}
-	return 0;
+	const __le64 rss_mask =
+		cpu_to_le64((u64)I40E_RX_DESC_FLTSTAT_RSS_HASH <<
+			    I40E_RX_DESC_STATUS_FLTSTAT_SHIFT);
+
+	if ((ring->netdev->features & NETIF_F_RXHASH) &&
+	    (rx_desc->wb.qword1.status_error_len & rss_mask) == rss_mask)
+		return le32_to_cpu(rx_desc->wb.qword0.hi_dword.rss);
+	else
+		return 0;
 }
 
 /**
-- 
1.8.3.1
