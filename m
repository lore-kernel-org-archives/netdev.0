From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/13] i40e: mark the value passed to csum_replace_by_diff as __wsum
Date: Sat, 18 Feb 2017 22:33:39 -0800
Message-ID: <20170219063341.8039-12-jeffrey.t.kirsher@intel.com>
References: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:19155 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751183AbdBSGeO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Feb 2017 01:34:14 -0500
In-Reply-To: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Fix, or rather, avoid a sparse warning caused by the fact that
csum_replace_by_diff expects to receive a __wsum value. Since the
calculation appears to work, simply typecast the passed paylen value to
__wsum to avoid the warning.

This seems pretty fishy since __wsum was obviously annotated as
a separate type on purpose, so this throws the entire calculation into
question. Since it currently appears to behave as expected, the typecast
is probably safe.

Change-ID: I4fdc5cddd589abc16098176e8a61127e761488f4
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 5 +++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 4dc993bb16bf..97d46058d71d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2335,7 +2335,8 @@ static int i40e_tso(struct i40e_tx_buffer *first, u8 *hdr_len,
 
 			/* remove payload length from outer checksum */
 			paylen = skb->len - l4_offset;
-			csum_replace_by_diff(&l4.udp->check, htonl(paylen));
+			csum_replace_by_diff(&l4.udp->check,
+					     (__force __wsum)htonl(paylen));
 		}
 
 		/* reset pointers to inner headers */
@@ -2356,7 +2357,7 @@ static int i40e_tso(struct i40e_tx_buffer *first, u8 *hdr_len,
 
 	/* remove payload length from inner checksum */
 	paylen = skb->len - l4_offset;
-	csum_replace_by_diff(&l4.tcp->check, htonl(paylen));
+	csum_replace_by_diff(&l4.tcp->check, (__force __wsum)htonl(paylen));
 
 	/* compute length of segmentation header */
 	*hdr_len = (l4.tcp->doff * 4) + l4_offset;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 7cd28ef6e714..c91fcf43ccbc 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1629,7 +1629,8 @@ static int i40e_tso(struct i40e_tx_buffer *first, u8 *hdr_len,
 
 			/* remove payload length from outer checksum */
 			paylen = skb->len - l4_offset;
-			csum_replace_by_diff(&l4.udp->check, htonl(paylen));
+			csum_replace_by_diff(&l4.udp->check,
+					     (__force __wsum)htonl(paylen));
 		}
 
 		/* reset pointers to inner headers */
@@ -1650,7 +1651,7 @@ static int i40e_tso(struct i40e_tx_buffer *first, u8 *hdr_len,
 
 	/* remove payload length from inner checksum */
 	paylen = skb->len - l4_offset;
-	csum_replace_by_diff(&l4.tcp->check, htonl(paylen));
+	csum_replace_by_diff(&l4.tcp->check, (__force __wsum)htonl(paylen));
 
 	/* compute length of segmentation header */
 	*hdr_len = (l4.tcp->doff * 4) + l4_offset;
-- 
2.11.0
