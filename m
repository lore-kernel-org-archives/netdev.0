From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH v3] drivers: net: cpsw: Add support to drive gpios for ethernet to be functional
Date: Mon, 7 Sep 2015 15:16:44 +0530
Message-ID: <1441619204-15403-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem@davemloft.net>,
	Tony Lindgren <tony@atomide.com>, Sekhar Nori <nsekhar@ti.com>,
	<linux-omap@vger.kernel.org>, <devicetree@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:35259 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751018AbbIGJrB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Sep 2015 05:47:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In DRA72x EVM, by default slave 1 is connected to the onboard
phy, but slave 2 pins are also muxed with video input module
which is controlled by pcf857x gpio and currently to select slave
0 to connect to phy gpio hogging is used, but with
omap2plus_defconfig the pcf857x gpio is built as module. So when
using NFS on DRA72x EVM, board doesn't boot as gpio hogging do
not set proper gpio state to connect slave 0 to phy as it is
built as module and you do not see any errors for not setting
gpio and just mentions dhcp reply not got.

To solve this issue, introducing "mode-gpios" in DT when gpio
based muxing is required. This will throw a warning when gpio
get fails and returns probe defer. When gpio-pcf857x module is
installed, cpsw probes again and ethernet becomes functional.
Verified this on DRA72x with pcf as module and ramdisk.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---

Changes from v2:
* Used mode-gpios, so that the driver is generic enough to handle
  multiple gpios

This patch is tested on DRA72x, Logs [1] and pushed a branch [2]

[1]: http://pastebin.ubuntu.com/12306224/
[2]: git://git.ti.com/~mugunthanvnm/ti-linux-kernel/linux.git cpsw-gpio-optional-v3

---
 Documentation/devicetree/bindings/net/cpsw.txt | 7 +++++++
 drivers/net/ethernet/ti/cpsw.c                 | 9 +++++++++
 2 files changed, 16 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
index a9df21a..676ecf6 100644
--- a/Documentation/devicetree/bindings/net/cpsw.txt
+++ b/Documentation/devicetree/bindings/net/cpsw.txt
@@ -30,6 +30,13 @@ Optional properties:
 - dual_emac		: Specifies Switch to act as Dual EMAC
 - syscon		: Phandle to the system control device node, which is
 			  the control module device of the am33x
+- mode-gpios		: Should be added if one/multiple gpio lines are
+			  required to be driven so that cpsw data lines
+			  can be connected to the phy via selective mux.
+			  For example in dra72x-evm, pcf gpio has to be
+			  driven low so that cpsw slave 0 and phy data
+			  lines are connected via mux.
+
 
 Slave Properties:
 Required properties:
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 8fc90f1..c670317 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -29,6 +29,7 @@
 #include <linux/workqueue.h>
 #include <linux/delay.h>
 #include <linux/pm_runtime.h>
+#include <linux/gpio.h>
 #include <linux/of.h>
 #include <linux/of_net.h>
 #include <linux/of_device.h>
@@ -2207,6 +2208,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	void __iomem			*ss_regs;
 	struct resource			*res, *ss_res;
 	const struct of_device_id	*of_id;
+	struct gpio_descs		*mode;
 	u32 slave_offset, sliver_offset, slave_size;
 	int ret = 0, i;
 	int irq;
@@ -2232,6 +2234,13 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ndev_ret;
 	}
 
+	mode = devm_gpiod_get_array_optional(&pdev->dev, "mode", GPIOD_OUT_LOW);
+	if (IS_ERR(mode)) {
+		ret = PTR_ERR(mode);
+		dev_err(&pdev->dev, "gpio request failed, ret %d\n", ret);
+		goto clean_ndev_ret;
+	}
+
 	/*
 	 * This may be required here for child devices.
 	 */
-- 
2.6.0.rc0.24.gec371ff
