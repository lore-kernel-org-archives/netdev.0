From: Daniel Hellstrom <daniel@gaisler.com>
Subject: [PATCH 09/10] GRETH: handle frame error interrupts
Date: Thu, 13 Jan 2011 09:25:34 +0100
Message-ID: <1294907135-24884-9-git-send-email-daniel@gaisler.com>
References: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail201c2.megamailservers.com ([69.49.111.102]:39241 "EHLO
	mail201c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932703Ab1AMJAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 04:00:06 -0500
In-Reply-To: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frame error interrupts must also be handled since the RX flag only indicates
successful reception, it is unlikely but the old code may lead to dead lock
if 128 error frames are recieved in a row.

Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
---
 drivers/net/greth.c |    9 +++++----
 drivers/net/greth.h |    2 ++
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index fea1e20..b9623d2 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -596,12 +596,13 @@ static irqreturn_t greth_interrupt(int irq, void *dev_id)
 	status = GRETH_REGLOAD(greth->regs->status);
 
 	/* Handle rx and tx interrupts through poll */
-	if (status & (GRETH_INT_RX | GRETH_INT_TX)) {
+	if (status & (GRETH_INT_RE | GRETH_INT_RX |
+		      GRETH_INT_TE | GRETH_INT_TX)) {
 
 		/* Clear interrupt status */
-		GRETH_REGORIN(greth->regs->status,
-			      status & (GRETH_INT_RX | GRETH_INT_TX));
-
+		GRETH_REGSAVE(greth->regs->status,
+			      status & (GRETH_INT_RE | GRETH_INT_RX |
+					GRETH_INT_TE | GRETH_INT_TX));
 		retval = IRQ_HANDLED;
 
 		/* Disable interrupts and schedule poll() */
diff --git a/drivers/net/greth.h b/drivers/net/greth.h
index 9414169..f97f553 100644
--- a/drivers/net/greth.h
+++ b/drivers/net/greth.h
@@ -23,6 +23,7 @@
 #define GRETH_BD_LEN 0x7FF
 
 #define GRETH_TXEN 0x1
+#define GRETH_INT_TE 0x2
 #define GRETH_INT_TX 0x8
 #define GRETH_TXI 0x4
 #define GRETH_TXBD_STATUS 0x0001C000
@@ -35,6 +36,7 @@
 #define GRETH_TXBD_ERR_UE 0x4000
 #define GRETH_TXBD_ERR_AL 0x8000
 
+#define GRETH_INT_RE         0x1
 #define GRETH_INT_RX         0x4
 #define GRETH_RXEN           0x2
 #define GRETH_RXI            0x8
-- 
1.5.4

