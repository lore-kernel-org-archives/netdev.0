From: Roy Pledge <Roy.Pledge@freescale.com>
Subject: [PATCH 10/11] soc/qman: Add HOTPLUG_CPU support to the QMan driver
Date: Thu, 9 Jul 2015 16:22:01 -0400
Message-ID: <1436473322-21247-11-git-send-email-Roy.Pledge@freescale.com>
References: <1436473322-21247-1-git-send-email-Roy.Pledge@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <linuxppc-dev@lists.ozlabs.org>, <scottwood@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436473322-21247-1-git-send-email-Roy.Pledge@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hai-Ying Wang <Haiying.Wang@freescale.com>

Add support for CPU hotplug for the DPAA 1.0 Queue Manager
driver.

Signed-off-by: Hai-Ying Wang <Haiying.Wang@freescale.com>
Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
Signed-off-by: Roy Pledge <Roy.Pledge@freescale.com>
---
 drivers/soc/fsl/qbman/qman_portal.c |   43 +++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/drivers/soc/fsl/qbman/qman_portal.c b/drivers/soc/fsl/qbman/qman_portal.c
index 9f53f0e..ad740e5 100644
--- a/drivers/soc/fsl/qbman/qman_portal.c
+++ b/drivers/soc/fsl/qbman/qman_portal.c
@@ -475,6 +475,46 @@ static void qman_offline_cpu(unsigned int cpu)
 	}
 }
 
+#ifdef CONFIG_HOTPLUG_CPU
+static void qman_online_cpu(unsigned int cpu)
+{
+	struct qman_portal *p;
+	const struct qm_portal_config *pcfg;
+
+	p = (struct qman_portal *)affine_portals[cpu];
+	if (p) {
+		pcfg = qman_get_qm_portal_config(p);
+		if (pcfg) {
+			irq_set_affinity(pcfg->public_cfg.irq, cpumask_of(cpu));
+			qman_portal_update_sdest(pcfg, cpu);
+		}
+	}
+}
+
+static int qman_hotplug_cpu_callback(struct notifier_block *nfb,
+				     unsigned long action, void *hcpu)
+{
+	unsigned int cpu = (unsigned long)hcpu;
+
+	switch (action) {
+	case CPU_ONLINE:
+	case CPU_ONLINE_FROZEN:
+		qman_online_cpu(cpu);
+		break;
+	case CPU_DOWN_PREPARE:
+	case CPU_DOWN_PREPARE_FROZEN:
+		qman_offline_cpu(cpu);
+	default:
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block qman_hotplug_cpu_notifier = {
+	.notifier_call = qman_hotplug_cpu_callback,
+};
+#endif /* CONFIG_HOTPLUG_CPU */
+
 __init int qman_init(void)
 {
 	struct cpumask slave_cpus;
@@ -598,6 +638,9 @@ __init int qman_init(void)
 	cpumask_andnot(&offline_cpus, cpu_possible_mask, cpu_online_mask);
 	for_each_cpu(cpu, &offline_cpus)
 		qman_offline_cpu(cpu);
+#ifdef CONFIG_HOTPLUG_CPU
+	register_hotcpu_notifier(&qman_hotplug_cpu_notifier);
+#endif
 	return 0;
 }
 
-- 
1.7.9.5
