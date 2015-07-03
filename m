From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 3/6] irqchip: armada-370-xp: Rework per-cpu interrupts handling
Date: Fri,  3 Jul 2015 16:25:48 +0200
Message-ID: <1435933551-28696-4-git-send-email-maxime.ripard@free-electrons.com>
References: <1435933551-28696-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: Thomas Gleixner <tglx@linutronix.de>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435933551-28696-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MPIC driver currently has a list of interrupts to handle as per-cpu.

Since the timer, fabric and neta interrupts were the only per-cpu
interrupts in the system, we can now remove the switch and just check for
the hardware irq number to determine whether a given interrupt is per-cpu
or not.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 drivers/irqchip/irq-armada-370-xp.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/irqchip/irq-armada-370-xp.c b/drivers/irqchip/irq-armada-370-xp.c
index daccc8bdbb42..42c69bd95bf8 100644
--- a/drivers/irqchip/irq-armada-370-xp.c
+++ b/drivers/irqchip/irq-armada-370-xp.c
@@ -57,9 +57,6 @@
 
 #define ARMADA_370_XP_MAX_PER_CPU_IRQS		(28)
 
-#define ARMADA_370_XP_TIMER0_PER_CPU_IRQ	(5)
-#define ARMADA_370_XP_FABRIC_IRQ		(3)
-
 #define IPI_DOORBELL_START                      (0)
 #define IPI_DOORBELL_END                        (8)
 #define IPI_DOORBELL_MASK                       0xFF
@@ -82,13 +79,10 @@ static phys_addr_t msi_doorbell_addr;
 
 static inline bool is_percpu_irq(irq_hw_number_t irq)
 {
-	switch (irq) {
-	case ARMADA_370_XP_TIMER0_PER_CPU_IRQ:
-	case ARMADA_370_XP_FABRIC_IRQ:
+	if (irq <= ARMADA_370_XP_MAX_PER_CPU_IRQS)
 		return true;
-	default:
-		return false;
-	}
+
+	return false;
 }
 
 /*
@@ -552,7 +546,7 @@ static void armada_370_xp_mpic_resume(void)
 		if (virq == 0)
 			continue;
 
-		if (irq != ARMADA_370_XP_TIMER0_PER_CPU_IRQ)
+		if (!is_percpu_irq(irq))
 			writel(irq, per_cpu_int_base +
 			       ARMADA_370_XP_INT_CLEAR_MASK_OFFS);
 		else
-- 
2.4.5
