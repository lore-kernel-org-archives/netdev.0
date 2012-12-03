From: Jan Luebbe <jlu@pengutronix.de>
Subject: [PATCH 2/3] net: cpsw: verify correct number of slaves in DT
Date: Mon,  3 Dec 2012 14:49:28 +0100
Message-ID: <1354542569-6165-2-git-send-email-jlu@pengutronix.de>
References: <1354542569-6165-1-git-send-email-jlu@pengutronix.de>
Cc: "David S. Miller" <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	Jan Luebbe <jlu@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1354542569-6165-1-git-send-email-jlu@pengutronix.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check that the number of available slaves passed from DT matches the
value of the "slaves" property in the cpsw node. Otherwise, priv->slaves
would be the wrong size.

Signed-off-by: Jan Luebbe <jlu@pengutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c0e676a..8de3e92 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -832,6 +832,16 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		const char *phy_id = NULL;
 		const void *mac_addr = NULL;
 
+		if (!of_device_is_available(slave_node))
+			continue;
+
+		if (i >= data->slaves) {
+			dev_err(&pdev->dev, "Too many slaves in the DT (> %d).\n",
+				data->slaves);
+			ret = -EINVAL;
+			goto error_ret;
+		}
+
 		if (of_property_read_string(slave_node, "phy_id", &phy_id)) {
 			dev_err(&pdev->dev, "Missing slave[%d] phy_id property.\n", i);
 			ret = -EINVAL;
@@ -861,6 +871,13 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 		i++;
 	}
 
+	if (i < data->slaves) {
+		dev_err(&pdev->dev, "Not enough slaves in the DT (< %d).\n",
+			data->slaves);
+		ret = -EINVAL;
+		goto error_ret;
+	}
+
 	/*
 	 * Populate all the child nodes here...
 	 */
-- 
1.7.10.4

