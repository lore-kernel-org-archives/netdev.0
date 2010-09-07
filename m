From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] r8169: add gro support
Date: Tue, 07 Sep 2010 06:46:39 +0200
Message-ID: <1283834799.2585.476.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35082 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944Ab0IGEqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 00:46:44 -0400
Received: by wwj40 with SMTP id 40so7544174wwj.1
        for <netdev@vger.kernel.org>; Mon, 06 Sep 2010 21:46:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Use napi_gro_receive() and vlan_gro_receive()
- Enable GRO by default

Tested on a RTL8111/8168 adapter

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 56a11e2..ddff42b 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1076,7 +1076,12 @@ static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
 	int ret;
 
 	if (vlgrp && (opts2 & RxVlanTag)) {
-		__vlan_hwaccel_rx(skb, vlgrp, swab16(opts2 & 0xffff), polling);
+		u16 vtag = swab16(opts2 & 0xffff);
+
+		if (polling)
+			vlan_gro_receive(&tp->napi, vlgrp, vtag, skb);
+		else
+			__vlan_hwaccel_rx(skb, vlgrp, vtag, polling);
 		ret = 0;
 	} else
 		ret = -1;
@@ -3186,6 +3191,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 #ifdef CONFIG_R8169_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 #endif
+	dev->features |= NETIF_F_GRO;
 
 	tp->intr_mask = 0xffff;
 	tp->align = cfg->align;
@@ -4561,7 +4567,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 
 			if (rtl8169_rx_vlan_skb(tp, desc, skb, polling) < 0) {
 				if (likely(polling))
-					netif_receive_skb(skb);
+					napi_gro_receive(&tp->napi, skb);
 				else
 					netif_rx(skb);
 			}


