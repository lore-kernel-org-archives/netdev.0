From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/2] r8169: revert "Handle rxfifo errors on 8168 chips"
Date: Tue, 9 Nov 2010 00:23:05 +0100
Message-ID: <20101108232305.GA13720@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Andreas Radke <a.radke@arcor.de>,
	Matthew Garrett <mjg@redhat.com>,
	Daniel J Blueman <daniel.blueman@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 254.185.140-88.rev.gaoland.net ([88.140.185.254]:60179 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754646Ab0KHX2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 18:28:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original patch helps under obscure conditions (no pun) but
some 8168 do not like it. The change needs to be tightened with
a specific 8168 version.

This reverts commit 801e147cde02f04b5c2f42764cd43a89fc7400a2.

Regression at https://bugzilla.kernel.org/show_bug.cgi?id=20882

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Andreas Radke <a.radke@arcor.de>
Cc: Matthew Garrett <mjg@redhat.com>
Cc: Daniel J Blueman <daniel.blueman@gmail.com>
---
 drivers/net/r8169.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index d88ce9f..3a0877e 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2931,7 +2931,7 @@ static const struct rtl_cfg_info {
 		.hw_start	= rtl_hw_start_8168,
 		.region		= 2,
 		.align		= 8,
-		.intr_event	= SYSErr | RxFIFOOver | LinkChg | RxOverflow |
+		.intr_event	= SYSErr | LinkChg | RxOverflow |
 				  TxErr | TxOK | RxOK | RxErr,
 		.napi_event	= TxErr | TxOK | RxOK | RxOverflow,
 		.features	= RTL_FEATURE_GMII | RTL_FEATURE_MSI,
@@ -4588,7 +4588,8 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 		}
 
 		/* Work around for rx fifo overflow */
-		if (unlikely(status & RxFIFOOver)) {
+		if (unlikely(status & RxFIFOOver) &&
+		(tp->mac_version == RTL_GIGA_MAC_VER_11)) {
 			netif_stop_queue(dev);
 			rtl8169_tx_timeout(dev);
 			break;
-- 
1.7.2.3

