From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] ravb: stop reading ECMR in ravb_emac_init()
Date: Mon, 11 Jan 2016 00:27:38 +0300
Message-ID: <1554972.rhPQTyRgNp@wasted.cogentembedded.com>
References: <5859243.yu8qorLmay@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:34171 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757359AbcAJV1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 16:27:41 -0500
Received: by mail-lb0-f170.google.com with SMTP id cl12so27919571lbc.1
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 13:27:40 -0800 (PST)
In-Reply-To: <5859243.yu8qorLmay@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code in ravb_emac_init() twiddling the ECMR bits always looked a bit
strange to me: if one intends to respect 'priv->duplex', why save old value
of the ECMR.DM bit?   As all the other bits are zeroed anyway, we don't
really need to read ECMR before writing to it.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/ravb_main.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

Index: net/drivers/net/ethernet/renesas/ravb_main.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/ravb_main.c
+++ net/drivers/net/ethernet/renesas/ravb_main.c
@@ -338,16 +338,13 @@ error:
 static void ravb_emac_init(struct net_device *ndev)
 {
 	struct ravb_private *priv = netdev_priv(ndev);
-	u32 ecmr;
 
 	/* Receive frame limit set register */
 	ravb_write(ndev, ndev->mtu + ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN, RFLR);
 
 	/* PAUSE prohibition */
-	ecmr =  ravb_read(ndev, ECMR);
-	ecmr &= ECMR_DM;
-	ecmr |= ECMR_ZPF | (priv->duplex ? ECMR_DM : 0) | ECMR_TE | ECMR_RE;
-	ravb_write(ndev, ecmr, ECMR);
+	ravb_write(ndev, ECMR_ZPF | (priv->duplex ? ECMR_DM : 0) |
+		   ECMR_TE | ECMR_RE, ECMR);
 
 	ravb_set_rate(ndev);
 
