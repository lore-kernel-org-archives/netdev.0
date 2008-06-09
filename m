From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 3/4] tg3: Fix 5761 WOL
Date: Mon, 9 Jun 2008 11:39:05 -0700
Message-ID: <1213046689.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2226 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754197AbYFIVUr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2008 17:20:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5761 non-e devices, two problems prevent the administrator from
overriding the WOL settings in the device's NVRAM.

The first problem is that GPIO 0 and GPIO 2 have been swapped.  This
change prevented the administrator from turning on WOL when it is
disabled in NVRAM.  The fix is to add a new path for the 5761 that
swaps the two GPIOs in the code as well.

The second problem is that GPIO 1 could not be toggled by the driver
because the GPIO is shared with the debug UART GPIO.  This will prevent
the administrator from being able to turn WOL off if it was enabled in
NVRAM.  The fix is to always disable the debug UART after a GRC reset.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

---
 drivers/net/tg3.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index c129318..f8ce873 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1295,6 +1295,21 @@ static void tg3_frob_aux_power(struct tg3 *tp)
 				     GRC_LCLCTRL_GPIO_OUTPUT0 |
 				     GRC_LCLCTRL_GPIO_OUTPUT1),
 				    100);
+		} else if (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5761) {
+			/* The 5761 non-e device swaps GPIO 0 and GPIO 2. */
+			u32 grc_local_ctrl = GRC_LCLCTRL_GPIO_OE0 |
+					     GRC_LCLCTRL_GPIO_OE1 |
+					     GRC_LCLCTRL_GPIO_OE2 |
+					     GRC_LCLCTRL_GPIO_OUTPUT0 |
+					     GRC_LCLCTRL_GPIO_OUTPUT1 |
+					     tp->grc_local_ctrl;
+			tw32_wait_f(GRC_LOCAL_CTRL, grc_local_ctrl, 100);
+
+			grc_local_ctrl |= GRC_LCLCTRL_GPIO_OUTPUT2;
+			tw32_wait_f(GRC_LOCAL_CTRL, grc_local_ctrl, 100);
+
+			grc_local_ctrl &= ~GRC_LCLCTRL_GPIO_OUTPUT0;
+			tw32_wait_f(GRC_LOCAL_CTRL, grc_local_ctrl, 100);
 		} else {
 			u32 no_gpio2;
 			u32 grc_local_ctrl = 0;
@@ -11767,6 +11782,15 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755)
 		tp->grc_local_ctrl |= GRC_LCLCTRL_GPIO_UART_SEL;
 
+	if (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5761) {
+		/* Turn off the debug UART. */
+		tp->grc_local_ctrl |= GRC_LCLCTRL_GPIO_UART_SEL;
+		if (tp->tg3_flags2 & TG3_FLG2_IS_NIC)
+			/* Keep VMain power. */
+			tp->grc_local_ctrl |= GRC_LCLCTRL_GPIO_OE0 |
+					      GRC_LCLCTRL_GPIO_OUTPUT0;
+	}
+
 	/* Force the chip into D0. */
 	err = tg3_set_power_state(tp, PCI_D0);
 	if (err) {
-- 
1.5.2.5



