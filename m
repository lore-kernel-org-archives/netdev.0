From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 3/4] MIPS: Octeon: Do proper acknowledgment of CIU timer interrupts.
Date: Mon, 15 Feb 2010 12:13:18 -0800
Message-ID: <1266264799-3510-3-git-send-email-ddaney@caviumnetworks.com>
References: <4B79AAA6.60005@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:19977 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756326Ab0BOUNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 15:13:34 -0500
In-Reply-To: <4B79AAA6.60005@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 arch/mips/cavium-octeon/octeon-irq.c |   67 ++++++++++++++++++++++++++++++++--
 1 files changed, 63 insertions(+), 4 deletions(-)

diff --git a/arch/mips/cavium-octeon/octeon-irq.c b/arch/mips/cavium-octeon/octeon-irq.c
index 1460d08..0bc79dc 100644
--- a/arch/mips/cavium-octeon/octeon-irq.c
+++ b/arch/mips/cavium-octeon/octeon-irq.c
@@ -51,9 +51,6 @@ static void octeon_irq_core_eoi(unsigned int irq)
 	 */
 	if (desc->status & IRQ_DISABLED)
 		return;
-
-	/* There is a race here.  We should fix it.  */
-
 	/*
 	 * We don't need to disable IRQs to make these atomic since
 	 * they are already disabled earlier in the low level
@@ -202,6 +199,29 @@ static void octeon_irq_ciu0_ack_v2(unsigned int irq)
 }
 
 /*
+ * CIU timer type interrupts must be acknoleged by writing a '1' bit
+ * to their sum0 bit.
+ */
+static void octeon_irq_ciu0_timer_ack(unsigned int irq)
+{
+	int index = cvmx_get_core_num() * 2;
+	uint64_t mask = 1ull << (irq - OCTEON_IRQ_WORKQ0);
+	cvmx_write_csr(CVMX_CIU_INTX_SUM0(index), mask);
+}
+
+static void octeon_irq_ciu0_timer_ack_v1(unsigned int irq)
+{
+	octeon_irq_ciu0_timer_ack(irq);
+	octeon_irq_ciu0_ack(irq);
+}
+
+static void octeon_irq_ciu0_timer_ack_v2(unsigned int irq)
+{
+	octeon_irq_ciu0_timer_ack(irq);
+	octeon_irq_ciu0_ack_v2(irq);
+}
+
+/*
  * Enable the irq on the current core for chips that have the EN*_W1{S,C}
  * registers.
  */
@@ -304,6 +324,28 @@ static struct irq_chip octeon_irq_chip_ciu0 = {
 #endif
 };
 
+static struct irq_chip octeon_irq_chip_ciu0_timer_v2 = {
+	.name = "CIU0-T",
+	.enable = octeon_irq_ciu0_enable_v2,
+	.disable = octeon_irq_ciu0_disable_all_v2,
+	.ack = octeon_irq_ciu0_timer_ack_v2,
+	.eoi = octeon_irq_ciu0_eoi_v2,
+#ifdef CONFIG_SMP
+	.set_affinity = octeon_irq_ciu0_set_affinity_v2,
+#endif
+};
+
+static struct irq_chip octeon_irq_chip_ciu0_timer = {
+	.name = "CIU0-T",
+	.enable = octeon_irq_ciu0_enable,
+	.disable = octeon_irq_ciu0_disable,
+	.ack = octeon_irq_ciu0_timer_ack_v1,
+	.eoi = octeon_irq_ciu0_eoi,
+#ifdef CONFIG_SMP
+	.set_affinity = octeon_irq_ciu0_set_affinity,
+#endif
+};
+
 
 static void octeon_irq_ciu1_ack(unsigned int irq)
 {
@@ -587,6 +629,7 @@ void __init arch_init_irq(void)
 {
 	int irq;
 	struct irq_chip *chip0;
+	struct irq_chip *chip0_timer;
 	struct irq_chip *chip1;
 
 #ifdef CONFIG_SMP
@@ -602,9 +645,11 @@ void __init arch_init_irq(void)
 	    OCTEON_IS_MODEL(OCTEON_CN56XX_PASS2_X) ||
 	    OCTEON_IS_MODEL(OCTEON_CN52XX_PASS2_X)) {
 		chip0 = &octeon_irq_chip_ciu0_v2;
+		chip0_timer = &octeon_irq_chip_ciu0_timer_v2;
 		chip1 = &octeon_irq_chip_ciu1_v2;
 	} else {
 		chip0 = &octeon_irq_chip_ciu0;
+		chip0_timer = &octeon_irq_chip_ciu0_timer;
 		chip1 = &octeon_irq_chip_ciu1;
 	}
 
@@ -618,7 +663,21 @@ void __init arch_init_irq(void)
 
 	/* 24 - 87 CIU_INT_SUM0 */
 	for (irq = OCTEON_IRQ_WORKQ0; irq <= OCTEON_IRQ_BOOTDMA; irq++) {
-		set_irq_chip_and_handler(irq, chip0, handle_percpu_irq);
+		switch (irq) {
+		case OCTEON_IRQ_GMX_DRP0:
+		case OCTEON_IRQ_GMX_DRP1:
+		case OCTEON_IRQ_IPD_DRP:
+		case OCTEON_IRQ_KEY_ZERO:
+		case OCTEON_IRQ_TIMER0:
+		case OCTEON_IRQ_TIMER1:
+		case OCTEON_IRQ_TIMER2:
+		case OCTEON_IRQ_TIMER3:
+			set_irq_chip_and_handler(irq, chip0_timer, handle_percpu_irq);
+			break;
+		default:
+			set_irq_chip_and_handler(irq, chip0, handle_percpu_irq);
+			break;
+		}
 	}
 
 	/* 88 - 151 CIU_INT_SUM1 */
-- 
1.6.6

