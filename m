From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] enc28j60: fix RX buffer overflow
Date: Tue, 30 Dec 2008 15:55:39 +0200
Message-ID: <20081230135539.GA10015@diamond.tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:39711 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752136AbYL3N4E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Dec 2008 08:56:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The enc28j60 driver doesn't check whether the length of the packet as reported 
by the hardware fits into the preallocated buffer. When stressed, the hardware 
may report insanely large packets even tough the "Receive OK" bit is set. Fix 
this.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---

--- drivers/net/enc28j60.c-git	2008-12-30 15:43:21.000000000 +0200
+++ drivers/net/enc28j60.c	2008-12-30 15:42:58.000000000 +0200
@@ -944,7 +944,7 @@ static void enc28j60_hw_rx(struct net_de
 	if (netif_msg_rx_status(priv))
 		enc28j60_dump_rsv(priv, __func__, next_packet, len, rxstat);
 
-	if (!RSV_GETBIT(rxstat, RSV_RXOK)) {
+	if (!RSV_GETBIT(rxstat, RSV_RXOK) || len > MAX_FRAMELEN) {
 		if (netif_msg_rx_err(priv))
 			dev_err(&ndev->dev, "Rx Error (%04x)\n", rxstat);
 		ndev->stats.rx_errors++;
@@ -952,6 +952,8 @@ static void enc28j60_hw_rx(struct net_de
 			ndev->stats.rx_crc_errors++;
 		if (RSV_GETBIT(rxstat, RSV_LENCHECKERR))
 			ndev->stats.rx_frame_errors++;
+		if (len > MAX_FRAMELEN)
+			ndev->stats.rx_over_errors++;
 	} else {
 		skb = dev_alloc_skb(len + NET_IP_ALIGN);
 		if (!skb) {

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
