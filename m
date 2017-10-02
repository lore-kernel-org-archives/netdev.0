From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: [PATCH v3 08/19] thunderbolt: Configure interrupt throttling for all interrupts
Date: Mon,  2 Oct 2017 13:38:35 +0300
Message-ID: <20171002103846.64602-9-mika.westerberg@linux.intel.com>
References: <20171002103846.64602-1-mika.westerberg@linux.intel.com>
Cc: Andreas Noever <andreas.noever@gmail.com>,
        Michael Jamet <michael.jamet@intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Mario.Limonciello@dell.com, Lukas Wunner <lukas@wunner.de>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171002103846.64602-1-mika.westerberg@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This will keep the interrupt delivery rate reasonable. The value used
here (128 us) is a recommendation from the hardware people.

This code is based on the work done by Amir Levy and Michael Jamet.

Signed-off-by: Michael Jamet <michael.jamet@intel.com>
Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
Reviewed-by: Yehezkel Bernat <yehezkel.bernat@intel.com>
Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/thunderbolt/nhi.c      | 23 ++++++++++++++++++++---
 drivers/thunderbolt/nhi_regs.h |  2 ++
 2 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/drivers/thunderbolt/nhi.c b/drivers/thunderbolt/nhi.c
index 05af126a2435..8a7a3d0133f9 100644
--- a/drivers/thunderbolt/nhi.c
+++ b/drivers/thunderbolt/nhi.c
@@ -651,6 +651,22 @@ static int nhi_suspend_noirq(struct device *dev)
 	return tb_domain_suspend_noirq(tb);
 }
 
+static void nhi_enable_int_throttling(struct tb_nhi *nhi)
+{
+	/* Throttling is specified in 256ns increments */
+	u32 throttle = DIV_ROUND_UP(128 * NSEC_PER_USEC, 256);
+	unsigned int i;
+
+	/*
+	 * Configure interrupt throttling for all vectors even if we
+	 * only use few.
+	 */
+	for (i = 0; i < MSIX_MAX_VECS; i++) {
+		u32 reg = REG_INT_THROTTLING_RATE + i * 4;
+		iowrite32(throttle, nhi->iobase + reg);
+	}
+}
+
 static int nhi_resume_noirq(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
@@ -663,6 +679,8 @@ static int nhi_resume_noirq(struct device *dev)
 	 */
 	if (!pci_device_is_present(pdev))
 		tb->nhi->going_away = true;
+	else
+		nhi_enable_int_throttling(tb->nhi);
 
 	return tb_domain_resume_noirq(tb);
 }
@@ -717,6 +735,8 @@ static int nhi_init_msi(struct tb_nhi *nhi)
 	/* In case someone left them on. */
 	nhi_disable_interrupts(nhi);
 
+	nhi_enable_int_throttling(nhi);
+
 	ida_init(&nhi->msix_ida);
 
 	/*
@@ -796,9 +816,6 @@ static int nhi_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	pci_set_master(pdev);
 
-	/* magic value - clock related? */
-	iowrite32(3906250 / 10000, nhi->iobase + 0x38c00);
-
 	tb = icm_probe(nhi);
 	if (!tb)
 		tb = tb_probe(nhi);
diff --git a/drivers/thunderbolt/nhi_regs.h b/drivers/thunderbolt/nhi_regs.h
index 09ed574e92ff..46eff69b19ad 100644
--- a/drivers/thunderbolt/nhi_regs.h
+++ b/drivers/thunderbolt/nhi_regs.h
@@ -95,6 +95,8 @@ struct ring_desc {
 #define REG_RING_INTERRUPT_BASE	0x38200
 #define RING_INTERRUPT_REG_COUNT(nhi) ((31 + 2 * nhi->hop_count) / 32)
 
+#define REG_INT_THROTTLING_RATE	0x38c00
+
 /* Interrupt Vector Allocation */
 #define REG_INT_VEC_ALLOC_BASE	0x38c40
 #define REG_INT_VEC_ALLOC_BITS	4
-- 
2.14.2
