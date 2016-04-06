From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] i40e/i40evf: Fix TSO checksum pseudo-header adjustment
Date: Tue,  5 Apr 2016 20:36:09 -0700
Message-ID: <1459913769-56510-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:27555 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760865AbcDFDga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 23:36:30 -0400
In-Reply-To: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

With IPv4 and IPv6 now using the same format for checksums based on the
length of the frame we need to update the i40e and i40evf drivers so that
they correctly account for lengths greater than or equal to 64K.

With this patch the driver should now correctly update checksums for frames
up to 16776960 in length which should be more than large enough for all
possible TSO frames in the near future.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 11 ++++-------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 11 ++++-------
 2 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5bef5b0..5d5fa53 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2304,10 +2304,8 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 			l4_offset = l4.hdr - skb->data;
 
 			/* remove payload length from outer checksum */
-			paylen = (__force u16)l4.udp->check;
-			paylen += ntohs((__force __be16)1) *
-					(u16)~(skb->len - l4_offset);
-			l4.udp->check = ~csum_fold((__force __wsum)paylen);
+			paylen = skb->len - l4_offset;
+			csum_replace_by_diff(&l4.udp->check, htonl(paylen));
 		}
 
 		/* reset pointers to inner headers */
@@ -2327,9 +2325,8 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	l4_offset = l4.hdr - skb->data;
 
 	/* remove payload length from inner checksum */
-	paylen = (__force u16)l4.tcp->check;
-	paylen += ntohs((__force __be16)1) * (u16)~(skb->len - l4_offset);
-	l4.tcp->check = ~csum_fold((__force __wsum)paylen);
+	paylen = skb->len - l4_offset;
+	csum_replace_by_diff(&l4.tcp->check, htonl(paylen));
 
 	/* compute length of segmentation header */
 	*hdr_len = (l4.tcp->doff * 4) + l4_offset;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 570348d..04aabc5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1571,10 +1571,8 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 			l4_offset = l4.hdr - skb->data;
 
 			/* remove payload length from outer checksum */
-			paylen = (__force u16)l4.udp->check;
-			paylen += ntohs((__force __be16)1) *
-					(u16)~(skb->len - l4_offset);
-			l4.udp->check = ~csum_fold((__force __wsum)paylen);
+			paylen = skb->len - l4_offset;
+			csum_replace_by_diff(&l4.udp->check, htonl(paylen));
 		}
 
 		/* reset pointers to inner headers */
@@ -1594,9 +1592,8 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	l4_offset = l4.hdr - skb->data;
 
 	/* remove payload length from inner checksum */
-	paylen = (__force u16)l4.tcp->check;
-	paylen += ntohs((__force __be16)1) * (u16)~(skb->len - l4_offset);
-	l4.tcp->check = ~csum_fold((__force __wsum)paylen);
+	paylen = skb->len - l4_offset;
+	csum_replace_by_diff(&l4.tcp->check, htonl(paylen));
 
 	/* compute length of segmentation header */
 	*hdr_len = (l4.tcp->doff * 4) + l4_offset;
-- 
2.5.5
