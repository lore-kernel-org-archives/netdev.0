From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: add more PM methods
Date: Thu, 22 Jan 2015 01:19:48 +0300
Message-ID: <2238953.qWhbSccAbj@wasted.cogentembedded.com>
References: <5608250.lrFkJTjgSf@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org, mikhail.ulyanov@cogentembedded.com
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <5608250.lrFkJTjgSf@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mikhail Ulyanov <mikhail.ulyanov@cogentembedded.com>

Add sh_eth_{suspend|resume}() implementing {suspend|resume|freeze|thaw|poweroff|
restore}() PM methods to make it possible to restore from hibernation not only
in Linux  but also in e.g. U-Boot and  to have more determined state on resume/
restore.

Signed-off-by: Mikhail Ulyanov <mikhail.ulyanov@cogentembedded.com>
[Sergei: moved sh_eth_{suspend|resume}() before sh_eth_runtime_nop(), enclosed
them with #ifdef CONFIG_PM_SLEEP, reordered the local variables, got rid of
*goto* and label, reordered macro invocations, renamed, modified the changelog.]
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -2947,6 +2947,36 @@ static int sh_eth_drv_remove(struct plat
 }
 
 #ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
+static int sh_eth_suspend(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+	int ret = 0;
+
+	if (netif_running(ndev)) {
+		netif_device_detach(ndev);
+		ret = sh_eth_close(ndev);
+	}
+
+	return ret;
+}
+
+static int sh_eth_resume(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+	int ret = 0;
+
+	if (netif_running(ndev)) {
+		ret = sh_eth_open(ndev);
+		if (ret < 0)
+			return ret;
+		netif_device_attach(ndev);
+	}
+
+	return ret;
+}
+#endif
+
 static int sh_eth_runtime_nop(struct device *dev)
 {
 	/* Runtime PM callback shared between ->runtime_suspend()
@@ -2960,6 +2990,7 @@ static int sh_eth_runtime_nop(struct dev
 }
 
 static const struct dev_pm_ops sh_eth_dev_pm_ops = {
+	SET_SYSTEM_SLEEP_PM_OPS(sh_eth_suspend, sh_eth_resume)
 	SET_RUNTIME_PM_OPS(sh_eth_runtime_nop, sh_eth_runtime_nop, NULL)
 };
 #define SH_ETH_PM_OPS (&sh_eth_dev_pm_ops)

