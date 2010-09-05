From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] r8169: fix rx checksum offload
Date: Sun, 05 Sep 2010 22:03:16 +0200
Message-ID: <1283716996.3402.342.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35080 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795Ab0IEUDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Sep 2010 16:03:24 -0400
Received: by fxm13 with SMTP id 13so2191344fxm.19
        for <netdev@vger.kernel.org>; Sun, 05 Sep 2010 13:03:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While porting GRO to r8169, I found this driver has a bug in its rx
path.

All skbs given to network stack had their ip_summed set to
CHECKSUM_NONE, while hardware said they had correct TCP/UDP checksums.

The reason is driver sets skb->ip_summed on the original skb before the
copy eventually done by copybreak. The fresh skb gets the ip_summed =
CHECKSUM_NONE value, forcing network stack to recompute checksum, and
preventing my GRO patch to work.

Fix is to make the ip_summed setting after skb copy.

Note : rx_copybreak current value is 16383, so all frames are copied...

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/r8169.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3554041..b589914 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4458,9 +4458,8 @@ static inline int rtl8169_fragmented_frame(u32 status)
 	return (status & (FirstFrag | LastFrag)) != (FirstFrag | LastFrag);
 }
 
-static inline void rtl8169_rx_csum(struct sk_buff *skb, struct RxDesc *desc)
+static inline void rtl8169_rx_csum(struct sk_buff *skb, u32 opts1)
 {
-	u32 opts1 = le32_to_cpu(desc->opts1);
 	u32 status = opts1 & RxProtoMask;
 
 	if (((status == RxProtoTCP) && !(opts1 & TCPFail)) ||
@@ -4541,6 +4540,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 			dma_addr_t addr = le64_to_cpu(desc->addr);
 			int pkt_size = (status & 0x00001FFF) - 4;
 			struct pci_dev *pdev = tp->pci_dev;
+			u32 opts1;
 
 			/*
 			 * The driver does not support incoming fragmented
@@ -4554,8 +4554,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 				continue;
 			}
 
-			rtl8169_rx_csum(skb, desc);
-
+			opts1 = le32_to_cpu(desc->opts1);
 			if (rtl8169_try_rx_copy(&skb, tp, pkt_size, addr)) {
 				pci_dma_sync_single_for_device(pdev, addr,
 					pkt_size, PCI_DMA_FROMDEVICE);
@@ -4566,6 +4565,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 				tp->Rx_skbuff[entry] = NULL;
 			}
 
+			rtl8169_rx_csum(skb, opts1);
 			skb_put(skb, pkt_size);
 			skb->protocol = eth_type_trans(skb, dev);
 


