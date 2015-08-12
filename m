From: Roy Pledge <Roy.Pledge@freescale.com>
Subject: [v2 09/11] soc/bman: Add HOTPLUG_CPU support to the BMan driver
Date: Wed, 12 Aug 2015 16:14:55 -0400
Message-ID: <1439410497-19039-10-git-send-email-Roy.Pledge@freescale.com>
References: <1439410497-19039-1-git-send-email-Roy.Pledge@freescale.com>
Reply-To: <Roy.Pledge@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <linuxppc-dev@lists.ozlabs.org>, <scottwood@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439410497-19039-1-git-send-email-Roy.Pledge@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hai-Ying Wang <Haiying.Wang@freescale.com>

Add support for CPU hotplug for the DPAA 1.0 Buffer Manager
driver

Signed-off-by: Hai-Ying Wang <Haiying.Wang@freescale.com>
Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
Signed-off-by: Roy Pledge <Roy.Pledge@freescale.com>
---
 drivers/soc/fsl/qbman/bman_portal.c |   40 +++++++++++++++++++++++++++++++++++
 drivers/soc/fsl/qbman/dpaa_sys.h    |    3 +++
 2 files changed, 43 insertions(+)

diff --git a/drivers/soc/fsl/qbman/bman_portal.c b/drivers/soc/fsl/qbman/bman_portal.c
index 62d8f64..f33d671 100644
--- a/drivers/soc/fsl/qbman/bman_portal.c
+++ b/drivers/soc/fsl/qbman/bman_portal.c
@@ -129,6 +129,42 @@ static void __cold bman_offline_cpu(unsigned int cpu)
 	}
 }
 
+#ifdef CONFIG_HOTPLUG_CPU
+static void __cold bman_online_cpu(unsigned int cpu)
+{
+	struct bman_portal *p = (struct bman_portal *)affine_bportals[cpu];
+	const struct bm_portal_config *pcfg;
+
+	if (p) {
+		pcfg = bman_get_bm_portal_config(p);
+		if (pcfg)
+			irq_set_affinity(pcfg->public_cfg.irq, cpumask_of(cpu));
+	}
+}
+
+static int __cold bman_hotplug_cpu_callback(struct notifier_block *nfb,
+					    unsigned long action, void *hcpu)
+{
+	unsigned int cpu = (unsigned long)hcpu;
+
+	switch (action) {
+	case CPU_ONLINE:
+	case CPU_ONLINE_FROZEN:
+		bman_online_cpu(cpu);
+		break;
+	case CPU_DOWN_PREPARE:
+	case CPU_DOWN_PREPARE_FROZEN:
+		bman_offline_cpu(cpu);
+	}
+
+	return NOTIFY_OK;
+}
+
+static struct notifier_block bman_hotplug_cpu_notifier = {
+	.notifier_call = bman_hotplug_cpu_callback,
+};
+#endif /* CONFIG_HOTPLUG_CPU */
+
 static int __cold bman_portal_probe(struct platform_device *of_dev)
 {
 	struct device *dev = &of_dev->dev;
@@ -342,6 +378,10 @@ static int __init bman_portal_driver_register(struct platform_driver *drv)
 	for_each_cpu(cpu, &offline_cpus)
 		bman_offline_cpu(cpu);
 
+#ifdef CONFIG_HOTPLUG_CPU
+	register_hotcpu_notifier(&bman_hotplug_cpu_notifier);
+#endif
+
 	bman_seed_bpid_range(0, bman_pool_max);
 
 	return 0;
diff --git a/drivers/soc/fsl/qbman/dpaa_sys.h b/drivers/soc/fsl/qbman/dpaa_sys.h
index 0dd341c..d1da092 100644
--- a/drivers/soc/fsl/qbman/dpaa_sys.h
+++ b/drivers/soc/fsl/qbman/dpaa_sys.h
@@ -43,6 +43,9 @@
 #include <linux/vmalloc.h>
 #include <linux/platform_device.h>
 #include <linux/ctype.h>
+#ifdef CONFIG_HOTPLUG_CPU
+#include <linux/cpu.h>
+#endif
 
 #include <asm/pgtable.h>
 
-- 
1.7.9.5
