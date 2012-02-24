From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/16] r8169: Support RX-FCS flag.
Date: Fri, 24 Feb 2012 02:13:05 -0800
Message-ID: <1330078389-8203-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43469 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756842Ab2BXKNS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 05:13:18 -0500
In-Reply-To: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows the NIC to receive the Ethernet FCS
and pass it up the stack, allowing sniffers and
other interested programs to inspect the FCS.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
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
1.7.7.6
