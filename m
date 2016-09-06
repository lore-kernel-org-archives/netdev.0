From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2] ptp: ixp46x: remove NO_IRQ handling
Date: Tue,  6 Sep 2016 21:20:36 +0200
Message-ID: <20160906192053.1061021-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Richard Cochran <richardcochran@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:59088 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755902AbcIFTUc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 15:20:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gpio_to_irq does not return NO_IRQ but instead returns a negative
error code on failure. Returning NO_IRQ from the function has no
negative effects as we only compare the result to the expected
interrupt number, but it's better to return a proper failure
code for consistency, and we should remove NO_IRQ from the kernel
entirely.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/ptp/ptp_ixp46x.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

v2: fix trivial typo

diff --git a/drivers/ptp/ptp_ixp46x.c b/drivers/ptp/ptp_ixp46x.c
index ee4f183ef9ee..344a3bac210b 100644
--- a/drivers/ptp/ptp_ixp46x.c
+++ b/drivers/ptp/ptp_ixp46x.c
@@ -268,18 +268,19 @@ static int setup_interrupt(int gpio)
 		return err;
 
 	irq = gpio_to_irq(gpio);
+	if (irq < 0)
+		return irq;
 
-	if (NO_IRQ == irq)
-		return NO_IRQ;
-
-	if (irq_set_irq_type(irq, IRQF_TRIGGER_FALLING)) {
+	err = irq_set_irq_type(irq, IRQF_TRIGGER_FALLING);
+	if (err) {
 		pr_err("cannot set trigger type for irq %d\n", irq);
-		return NO_IRQ;
+		return err;
 	}
 
-	if (request_irq(irq, isr, 0, DRIVER, &ixp_clock)) {
+	err = request_irq(irq, isr, 0, DRIVER, &ixp_clock);
+	if (err) {
 		pr_err("request_irq failed for irq %d\n", irq);
-		return NO_IRQ;
+		return err;
 	}
 
 	return irq;
-- 
2.9.0
