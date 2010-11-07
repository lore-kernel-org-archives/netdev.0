From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 1/5] Staging: ath6kl: Fix pointer casts on 64-bit
 architectures
Date: Sun, 07 Nov 2010 17:19:39 +0000
Message-ID: <1289150379.2816.72.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Vipin Mehta <vmehta@atheros.com>, devel@driverdev.osuosl.org,
	netdev <netdev@vger.kernel.org>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37927 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751894Ab0KGRTr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Nov 2010 12:19:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unnecessary cast of firmware base address to integer before
adding an offset.

Fix direct use of sk_buff::network_header which is an offset rather
than a pointer on 64-bit architectures.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
Compile-tested only.  This should be 2.6.37 material.

Ben.

 drivers/staging/ath6kl/os/linux/ar6000_drv.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/ath6kl/os/linux/ar6000_drv.c b/drivers/staging/ath6kl/os/linux/ar6000_drv.c
index c5a6d6c..a659f70 100644
--- a/drivers/staging/ath6kl/os/linux/ar6000_drv.c
+++ b/drivers/staging/ath6kl/os/linux/ar6000_drv.c
@@ -1126,7 +1126,7 @@ ar6000_transfer_bin_file(AR_SOFTC_T *ar, AR6K_BIN_FILE file, A_UINT32 address, A
         if ((board_ext_address) && (fw_entry->size == (board_data_size + board_ext_data_size))) {
             A_UINT32 param;
 
-            status = BMIWriteMemory(ar->arHifDevice, board_ext_address, (A_UCHAR *)(((A_UINT32)fw_entry->data) + board_data_size), board_ext_data_size);
+            status = BMIWriteMemory(ar->arHifDevice, board_ext_address, (A_UCHAR *)(fw_entry->data + board_data_size), board_ext_data_size);
 
             if (status != A_OK) {
                 AR_DEBUG_PRINTF(ATH_DEBUG_ERR, ("BMI operation failed: %d\n", __LINE__));
@@ -3030,7 +3030,8 @@ ar6000_data_tx(struct sk_buff *skb, struct net_device *dev)
         A_UINT8 csumDest=0;
         A_UINT8 csum=skb->ip_summed;
         if(csumOffload && (csum==CHECKSUM_PARTIAL)){
-            csumStart=skb->csum_start-(skb->network_header-skb->head)+sizeof(ATH_LLC_SNAP_HDR);
+            csumStart = (skb->head + skb->csum_start - skb_network_header(skb) +
+			 sizeof(ATH_LLC_SNAP_HDR));
             csumDest=skb->csum_offset+csumStart;
         }
 #endif
-- 
1.7.2.3



