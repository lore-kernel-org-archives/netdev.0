From: greearb@candelatech.com
Subject: [PATCH v3 16/16] r8169:  Support RX-FCS flag.
Date: Fri, 10 Feb 2012 17:04:34 -0800
Message-ID: <1328922274-23993-17-git-send-email-greearb@candelatech.com>
References: <1328922274-23993-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55824 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755210Ab2BKBEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 20:04:49 -0500
In-Reply-To: <1328922274-23993-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows the NIC to receive the Ethernet FCS
and pass it up the stack, allowing sniffers and
other interested programs to inspect the FCS.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 0517a6a... fbd855b... M	drivers/net/ethernet/realtek/r8169.c
 drivers/net/ethernet/realtek/r8169.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 0517a6a..fbd855b 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4186,6 +4186,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev->hw_features &= ~NETIF_F_HW_VLAN_RX;
 
 	dev->hw_features |= NETIF_F_RXALL;
+	dev->hw_features |= NETIF_F_RXFCS;
 
 	tp->hw_start = cfg->hw_start;
 	tp->event_slow = cfg->event_slow;
@@ -5773,7 +5774,10 @@ static int rtl_rx(struct net_device *dev, struct rtl8169_private *tp, u32 budget
 
 process_pkt:
 			addr = le64_to_cpu(desc->addr);
-			pkt_size = (status & 0x00003fff) - 4;
+			if (likely(!(dev->features & NETIF_F_RXFCS)))
+				pkt_size = (status & 0x00003fff) - 4;
+			else
+				pkt_size = status & 0x00003fff;
 
 			/*
 			 * The driver does not support incoming fragmented
-- 
1.7.3.4
