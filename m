From: Simon Wunderlich <simon.wunderlich@saxnet.de>
Subject: [PATCH 2.6.32-rc5] r8169: fix Ethernet Hangup for RTL8110SC rev d
Date: Thu, 22 Oct 2009 08:48:54 +0200
Message-ID: <66ae97b70910212348o6c32da21s906da4770ebc6f80@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Bernhard Schmidt <bernhard.schmidt@saxnet.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:57725 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbZJVGsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 02:48:51 -0400
Received: by ewy3 with SMTP id 3so227088ewy.17
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 23:48:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 8110SC rev d chip on our board shows a regression which the 8110SB chip
did not have. When inbound traffic is overflowing the receive descriptor queue,
"holes" in the ring buffer may occur which lead to a hangup until the buffer
is filled again. The packets are than completely processed, but the ring
remains porous and no packets are processed until the next overflow. Setting
the interface down and up can fix the problem temporary from userspace.

For some reason we don't know, this behaviour is not occuring if the RxVlan
bit for hardware VLAN untagging is set. There is another "Work around for
AMD plateform" in the current code which checks the VLAN status
word in receive descriptors, but does never come to effect when hardware
VLAN support is enabled. We assume that this is a bug in the chip.

The following patch fixes the problem. Without the patch we could reproduce
the hang within minutes (given other devices also generating lots of
interrupts), without we couldn't reproduce within a few days of long term
testing.

Signed-off-by: Bernhard Schmidt <bernhard.schmidt@saxnet.de>
Signed-off-by: Simon Wunderlich <simon.wunderlich@saxnet.de>
Acked-by: Francois Romieu <romieu@zoreil.com>

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 83c47d9..0908c50 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1029,7 +1029,10 @@ static void rtl8169_vlan_rx_register(struct
net_device *dev,

    spin_lock_irqsave(&tp->lock, flags);
    tp->vlgrp = grp;
-   if (tp->vlgrp)
+   /*
+    * Do not disable RxVlan on 8110SCd.
+    */
+   if (tp->vlgrp || (tp->mac_version == RTL_GIGA_MAC_VER_05))
        tp->cp_cmd |= RxVlan;
    else
        tp->cp_cmd &= ~RxVlan;
@@ -3197,6 +3200,15 @@ rtl8169_init_one(struct pci_dev *pdev, const
struct pci_device_id *ent)
    }

    rtl8169_init_phy(dev, tp);
+
+   /*
+    * Pretend we are using VLANs; This bypasses a nasty bug where
+    * Interrupts stop flowing on high load on 8110SCd controllers.
+    */
+   if (tp->mac_version == RTL_GIGA_MAC_VER_05)
+       RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) | RxVlan);
+
+
    device_set_wakeup_enable(&pdev->dev, tp->features & RTL_FEATURE_WOL);

 out:
