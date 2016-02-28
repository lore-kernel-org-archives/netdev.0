From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 12/32] net: dsa: Add slave component matches based on a phandle to the slave.
Date: Sun, 28 Feb 2016 17:41:20 +0100
Message-ID: <1456677700-23027-13-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44922 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758779AbcB1QmV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:42:21 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch devices are component slaves. Such devices have a "switch"
property in the DSA device tree which is a phandle to the switch
device. Add a component match on the device node.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index f2af801554ec..73a3fd561ef3 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -886,18 +886,25 @@ static void dsa_finish_dst(struct dsa_switch_tree *dst, struct device *parent,
 	}
 }
 
+static int compare_of(struct device *dev, void *data)
+{
+	return dev->of_node == data;
+}
+
 static int dsa_probe(struct platform_device *pdev)
 {
 	struct dsa_platform_data *pd = pdev->dev.platform_data;
+	struct device_node *np = pdev->dev.of_node;
 	struct component_match *match = NULL;
+	struct device_node *chip;
 	struct net_device *dev;
 	struct dsa_switch_tree *dst;
-	int ret;
+	int i, ret;
 
 	pr_notice_once("Distributed Switch Architecture driver version %s\n",
 		       dsa_driver_version);
 
-	if (pdev->dev.of_node) {
+	if (np) {
 		pd = devm_kzalloc(&pdev->dev, sizeof(*pd), GFP_KERNEL);
 		if (!pd)
 			return -ENOMEM;
@@ -941,6 +948,12 @@ static int dsa_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, dst);
 
+	for (i = 0; i < pd->nr_chips; i++) {
+		chip = pd->chip[i].of_chip;
+		if (chip)
+			component_match_add(&pdev->dev, &match, compare_of,
+					    chip);
+	}
 
 	return component_master_add_with_match(&pdev->dev, &dsa_ops, match);
 
-- 
2.7.0
