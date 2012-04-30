From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] sky2: propogate rx hash when packet is copied
Date: Mon, 30 Apr 2012 08:49:45 -0700
Message-ID: <20120430155027.152144873@vyatta.com>
References: <20120430154944.890709139@vyatta.com>
Cc: netdev@vger.kernel.org, Mirko Lindner <mlindner@marvell.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:44365 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753134Ab2D3P4h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 11:56:37 -0400
Content-Disposition: inline; filename=sky2-rxhash.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a small packet is received, the driver copies it to a new skb to allow
reusing the full size Rx buffer. The copy was propogating the checksum offload
but not the receive hash information. The bug is impact was mostly harmless
and therefore not observed until reviewing this area of code.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ethernet/marvell/sky2.c	2012-04-30 08:19:56.225976395 -0700
+++ b/drivers/net/ethernet/marvell/sky2.c	2012-04-30 08:21:05.395136397 -0700
@@ -2494,8 +2494,11 @@ static struct sk_buff *receive_copy(stru
 		skb_copy_from_linear_data(re->skb, skb->data, length);
 		skb->ip_summed = re->skb->ip_summed;
 		skb->csum = re->skb->csum;
+		skb->rxhash = re->skb->rxhash;
+
 		pci_dma_sync_single_for_device(sky2->hw->pdev, re->data_addr,
 					       length, PCI_DMA_FROMDEVICE);
+		re->skb->rxhash = 0;
 		re->skb->ip_summed = CHECKSUM_NONE;
 		skb_put(skb, length);
 	}
