From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] ptp: ixp46x: remove NO_IRQ handling
Date: Tue,  6 Sep 2016 16:28:30 +0200
Message-ID: <20160906142849.3297250-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Kefeng Wang <wangkefeng.wang@huawei.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gpio_to_irq does not return NO_IRQ but instead returns a negative
error code on failure. Returning NO_IRQ from the function has no
negative effects as we only compare the result to the expected
interrupt number, but it's better to return a proper failure
code for consistency, and we should remove NO_IRQ from the kernel
entirely.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/ptp/ptp_ixp46x.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/ptp/ptp_ixp46x.c b/drivers/ptp/ptp_ixp46x.c
index ee4f183ef9ee..fbcb940b6348 100644
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
+	if (err)
 		pr_err("request_irq failed for irq %d\n", irq);
-		return NO_IRQ;
+		return err;
 	}
 
 	return irq;
-- 
2.9.0
