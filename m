From: Matthew Garrett <mjg@redhat.com>
Subject: [PATCH] r8169: Handle rxfifo errors on 8168 chips
Date: Tue, 14 Sep 2010 17:57:11 -0400
Message-ID: <1284501431-23263-1-git-send-email-mjg@redhat.com>
Cc: netdev@vger.kernel.org, jglisse@redhat.com,
	Matthew Garrett <mjg@redhat.com>
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52472 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751485Ab0INV5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Sep 2010 17:57:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Thinkpad X100e seems to have some odd behaviour when the display is
powered off - the onboard r8169 starts generating rxfifo overflow errors.
The root cause of this has not yet been identified and may well be a
hardware design bug on the platform, but r8169 should be more resiliant to
this. This patch enables the rxfifo interrupt on 8168 devices and removes
the MAC version check in the interrupt handler, and the machine no longer
crashes when under network load while the screen turns off.

Signed-off-by: Matthew Garrett <mjg@redhat.com>
---
 drivers/net/r8169.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 078bbf4..a0da4a1 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2934,7 +2934,7 @@ static const struct rtl_cfg_info {
 		.hw_start	= rtl_hw_start_8168,
 		.region		= 2,
 		.align		= 8,
-		.intr_event	= SYSErr | LinkChg | RxOverflow |
+		.intr_event	= SYSErr | RxFIFOOver | LinkChg | RxOverflow |
 				  TxErr | TxOK | RxOK | RxErr,
 		.napi_event	= TxErr | TxOK | RxOK | RxOverflow,
 		.features	= RTL_FEATURE_GMII | RTL_FEATURE_MSI,
@@ -4625,8 +4625,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 		}
 
 		/* Work around for rx fifo overflow */
-		if (unlikely(status & RxFIFOOver) &&
-		(tp->mac_version == RTL_GIGA_MAC_VER_11)) {
+		if (unlikely(status & RxFIFOOver)) {
 			netif_stop_queue(dev);
 			rtl8169_tx_timeout(dev);
 			break;
-- 
1.7.2.3

