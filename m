From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 11/28] net: dsa: Add slave component matches based on a phandle to the slave.
Date: Wed, 23 Dec 2015 13:56:25 +0100
Message-ID: <1450875402-20740-12-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48758 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751962AbbLWM6U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:58:20 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
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
index be8e181f161b..8b89eece6b52 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -871,18 +871,25 @@ static int dsa_bind(struct device *dev)
 	return dsa_setup_dst(dst, dst->master_netdev, dev);
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
@@ -926,6 +933,12 @@ static int dsa_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, dst);
 
+	for (i = 0; i < pd->nr_chips; i++) {
+		chip = pd->chip[i].of_chip;
+		if (chip)
+			component_match_add(&pdev->dev, &match, compare_of,
+					    chip);
+	}
 
 	return component_master_add_with_match(&pdev->dev, &dsa_ops, match);
 
-- 
2.6.3
