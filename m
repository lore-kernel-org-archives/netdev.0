From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v2 3/7] irqchip: armada-370-xp: Rework per-cpu interrupts handling
Date: Fri, 25 Sep 2015 18:09:34 +0200
Message-ID: <1443197378-30717-4-git-send-email-gregory.clement@free-electrons.com>
References: <1443197378-30717-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Willy Tarreau <w@1wt.eu>, linux-arm-kernel@lists.infradead.org
To: Thomas Gleixner <tglx@linutronix.de>,
	Jason Cooper <jason@lakedaemon.net>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443197378-30717-1-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxime Ripard <maxime.ripard@free-electrons.com>

The MPIC driver currently has a list of interrupts to handle as per-cpu.

Since the timer, fabric and neta interrupts were the only per-cpu
interrupts in the system, we can now remove the switch and just check for
the hardware irq number to determine whether a given interrupt is per-cpu
or not.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
Acked-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/irqchip/irq-armada-370-xp.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/irqchip/irq-armada-370-xp.c b/drivers/irqchip/irq-armada-370-xp.c
index 39b72da0c143..117848b46eaa 100644
--- a/drivers/irqchip/irq-armada-370-xp.c
+++ b/drivers/irqchip/irq-armada-370-xp.c
@@ -56,9 +56,6 @@
 
 #define ARMADA_370_XP_MAX_PER_CPU_IRQS		(28)
 
-#define ARMADA_370_XP_TIMER0_PER_CPU_IRQ	(5)
-#define ARMADA_370_XP_FABRIC_IRQ		(3)
-
 #define IPI_DOORBELL_START                      (0)
 #define IPI_DOORBELL_END                        (8)
 #define IPI_DOORBELL_MASK                       0xFF
@@ -81,13 +78,10 @@ static phys_addr_t msi_doorbell_addr;
 
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
@@ -551,7 +545,7 @@ static void armada_370_xp_mpic_resume(void)
 		if (virq == 0)
 			continue;
 
-		if (irq != ARMADA_370_XP_TIMER0_PER_CPU_IRQ)
+		if (!is_percpu_irq(irq))
 			writel(irq, per_cpu_int_base +
 			       ARMADA_370_XP_INT_CLEAR_MASK_OFFS);
 		else
-- 
2.1.0
