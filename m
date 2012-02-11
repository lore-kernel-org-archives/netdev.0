From: greearb@candelatech.com
Subject: [PATCH v3 12/16] e1000:  Support RX-FCS flag.
Date: Fri, 10 Feb 2012 17:04:30 -0800
Message-ID: <1328922274-23993-13-git-send-email-greearb@candelatech.com>
References: <1328922274-23993-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55828 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758578Ab2BKBEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 20:04:54 -0500
In-Reply-To: <1328922274-23993-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows the NIC to pass the Ethernet Frame Checksum
(FCS) up the stack.  Useful when sniffing packets.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 59b8207... f4eec77... M	drivers/net/ethernet/intel/e1000/e1000_main.c
 drivers/net/ethernet/intel/e1000/e1000_main.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 59b8207..f4eec77 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1073,6 +1073,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	netdev->features |= netdev->hw_features;
 	netdev->hw_features |= NETIF_F_RXCSUM;
 	netdev->hw_features |= NETIF_F_RXALL;
+	netdev->hw_features |= NETIF_F_RXFCS;
 
 	if (pci_using_dac) {
 		netdev->features |= NETIF_F_HIGHDMA;
@@ -4158,10 +4159,9 @@ process_skb:
 		                  ((u32)(rx_desc->errors) << 24),
 		                  le16_to_cpu(rx_desc->csum), skb);
 
-		pskb_trim(skb, skb->len - 4);
-
-		/* probably a little skewed due to removing CRC */
-		total_rx_bytes += skb->len;
+		total_rx_bytes += (skb->len - 4); /* don't count FCS */
+		if (likely(!(netdev->features & NETIF_F_RXFCS)))
+			pskb_trim(skb, skb->len - 4);
 		total_rx_packets++;
 
 		/* eth type trans needs skb->data to point to something */
@@ -4318,14 +4318,14 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		}
 
 process_skb:
-		/* adjust length to remove Ethernet CRC, this must be
-		 * done after the TBI_ACCEPT workaround above */
-		length -= 4;
-
-		/* probably a little skewed due to removing CRC */
-		total_rx_bytes += length;
+		total_rx_bytes += (length - 4); /* don't count FCS */
 		total_rx_packets++;
 
+		if (likely(!(netdev->features & NETIF_F_RXFCS)))
+			/* adjust length to remove Ethernet CRC, this must be
+			 * done after the TBI_ACCEPT workaround above */
+			length -= 4;
+
 		e1000_check_copybreak(netdev, buffer_info, length, &skb);
 
 		skb_put(skb, length);
-- 
1.7.3.4
