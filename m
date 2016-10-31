From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/22] i40e: correct check for reading TSYNINDX from the receive descriptor
Date: Mon, 31 Oct 2016 15:29:43 -0700
Message-ID: <1477952992-125662-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477952992-125662-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:28490 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034507AbcJaW37 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 18:29:59 -0400
In-Reply-To: <1477952992-125662-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When hardware has taken a timestamp for a received packet, it indicates
which RXTIME register the timestamp was placed in by some bits in the
receive descriptor. It uses 3 bits, one to indicate if the descriptor
index is valid (ie: there was a timestamp) and 2 bits to indicate which
of the 4 registers to read. However, the driver currently does not check
the TSYNVALID bit and only checks the index. It assumes a zero index
means no timestamp, and a non zero index means a timestamp occurred.
While this appears to be true, it prevents ever reading a timestamp in
RXTIME[0], and causes the first timestamp the device captures to be
ignored.

Fix this by using the TSYNVALID bit correctly as the true indicator of
whether the packet has an associated timestamp.

Also rename the variable rsyn to tsyn as this is more descriptive and
matches the register names.

Change-ID: I4437e8f3a3df2c2ddb458b0fb61420f3dafc4c12
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index daade4fe..c9eb6b8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1410,11 +1410,12 @@ void i40e_process_skb_fields(struct i40e_ring *rx_ring,
 	u64 qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
 	u32 rx_status = (qword & I40E_RXD_QW1_STATUS_MASK) >>
 			I40E_RXD_QW1_STATUS_SHIFT;
-	u32 rsyn = (rx_status & I40E_RXD_QW1_STATUS_TSYNINDX_MASK) >>
+	u32 tsynvalid = rx_status & I40E_RXD_QW1_STATUS_TSYNVALID_MASK;
+	u32 tsyn = (rx_status & I40E_RXD_QW1_STATUS_TSYNINDX_MASK) >>
 		   I40E_RXD_QW1_STATUS_TSYNINDX_SHIFT;
 
-	if (unlikely(rsyn)) {
-		i40e_ptp_rx_hwtstamp(rx_ring->vsi->back, skb, rsyn);
+	if (unlikely(tsynvalid)) {
+		i40e_ptp_rx_hwtstamp(rx_ring->vsi->back, skb, tsyn);
 		rx_ring->last_rx_timestamp = jiffies;
 	}
 
-- 
2.7.4
