From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/16] e1000: Support RX-FCS flag.
Date: Fri, 24 Feb 2012 02:13:01 -0800
Message-ID: <1330078389-8203-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41098 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756798Ab2BXKNR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 05:13:17 -0500
In-Reply-To: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows the NIC to pass the Ethernet Frame Checksum
(FCS) up the stack.  Useful when sniffing packets.

Signed-off-by: Ben Greear <greearb@candelatech.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index bd1d28f..8aa8097 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1071,6 +1071,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	netdev->features |= netdev->hw_features;
 	netdev->hw_features |= NETIF_F_RXCSUM;
+	netdev->hw_features |= NETIF_F_RXFCS;
 
 	if (pci_using_dac) {
 		netdev->features |= NETIF_F_HIGHDMA;
@@ -4137,10 +4138,9 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
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
@@ -4294,14 +4294,15 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			}
 		}
 
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
+			 * done after the TBI_ACCEPT workaround above
+			 */
+			length -= 4;
+
 		e1000_check_copybreak(netdev, buffer_info, length, &skb);
 
 		skb_put(skb, length);
-- 
1.7.7.6
