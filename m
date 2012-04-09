From: "Manjunathappa, Prakash" <prakash.pm@ti.com>
Subject: [PATCH] davinci_emac: Add cpu_freq support
Date: Mon, 9 Apr 2012 16:19:09 +0530
Message-ID: <1333968549-3282-1-git-send-email-prakash.pm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<davinci-linux-open-source@linux.davincidsp.com>,
	"Manjunathappa, Prakash" <prakash.pm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reconfigure interrupt coalesce parameter for changed emac bus_freq
due to DVFS.

Signed-off-by: Manjunathappa, Prakash <prakash.pm@ti.com>
---
 drivers/net/ethernet/ti/davinci_emac.c |   60 ++++++++++++++++++++++++++++++++
 1 files changed, 60 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 174a334..11d3bd7 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -50,6 +50,7 @@
 #include <linux/ctype.h>
 #include <linux/spinlock.h>
 #include <linux/dma-mapping.h>
+#include <linux/cpufreq.h>
 #include <linux/clk.h>
 #include <linux/platform_device.h>
 #include <linux/semaphore.h>
@@ -344,6 +345,9 @@ struct emac_priv {
 	/*platform specific members*/
 	void (*int_enable) (void);
 	void (*int_disable) (void);
+#ifdef CONFIG_CPU_FREQ
+	struct notifier_block	freq_transition;
+#endif
 };
 
 /* clock frequency for EMAC */
@@ -1761,6 +1765,46 @@ static const struct net_device_ops emac_netdev_ops = {
 #endif
 };
 
+#ifdef CONFIG_CPU_FREQ
+static int davinci_emac_cpufreq_transition(struct notifier_block *nb,
+				     unsigned long val, void *data)
+{
+	int ret = 0;
+	struct emac_priv *priv;
+
+	priv = container_of(nb, struct emac_priv, freq_transition);
+	if (priv->coal_intvl != 0) {
+		if (val == CPUFREQ_POSTCHANGE) {
+			if (emac_bus_frequency != clk_get_rate(emac_clk)) {
+				struct ethtool_coalesce coal;
+
+				emac_bus_frequency = clk_get_rate(emac_clk);
+
+				priv->bus_freq_mhz = (u32)(emac_bus_frequency /
+						1000000);
+				coal.rx_coalesce_usecs = (priv->coal_intvl
+						<< 4);
+				ret = emac_set_coalesce(priv->ndev, &coal);
+			}
+		}
+	}
+	return ret;
+}
+
+static inline int davinci_emac_cpufreq_register(struct emac_priv *priv)
+{
+	priv->freq_transition.notifier_call = davinci_emac_cpufreq_transition;
+	return cpufreq_register_notifier(&priv->freq_transition,
+					 CPUFREQ_TRANSITION_NOTIFIER);
+}
+
+static inline void davinci_emac_cpufreq_deregister(struct emac_priv *priv)
+{
+	cpufreq_unregister_notifier(&priv->freq_transition,
+				    CPUFREQ_TRANSITION_NOTIFIER);
+}
+#endif
+
 /**
  * davinci_emac_probe: EMAC device probe
  * @pdev: The DaVinci EMAC device that we are removing
@@ -1925,8 +1969,21 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 			   "(regs: %p, irq: %d)\n",
 			   (void *)priv->emac_base_phys, ndev->irq);
 	}
+
+#ifdef CONFIG_CPU_FREQ
+	rc = davinci_emac_cpufreq_register(priv);
+	if (rc) {
+		dev_err(&pdev->dev, "error in register_netdev\n");
+		rc = -ENODEV;
+		goto cpufreq_reg_err;
+	}
+#endif
 	return 0;
 
+#ifdef CONFIG_CPU_FREQ
+cpufreq_reg_err:
+	unregister_netdev(ndev);
+#endif
 netdev_reg_err:
 	clk_disable(emac_clk);
 no_irq_res:
@@ -1973,6 +2030,9 @@ static int __devexit davinci_emac_remove(struct platform_device *pdev)
 
 	release_mem_region(res->start, resource_size(res));
 
+#ifdef CONFIG_CPU_FREQ
+	davinci_emac_cpufreq_deregister(priv);
+#endif
 	unregister_netdev(ndev);
 	iounmap(priv->remap_addr);
 	free_netdev(ndev);
-- 
1.7.1
