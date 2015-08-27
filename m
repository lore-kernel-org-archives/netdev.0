From: sfeldma@gmail.com
Subject: [RFC PATCH net-next 2/2] rocker: register each switch as a switchdev
Date: Thu, 27 Aug 2015 00:16:46 -0700
Message-ID: <1440659806-56582-3-git-send-email-sfeldma@gmail.com>
References: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, davem@davemloft.net, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36730 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbbH0HON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 03:14:13 -0400
Received: by padfo6 with SMTP id fo6so915296pad.3
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 00:14:13 -0700 (PDT)
In-Reply-To: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index a7cb74a..9555ae4 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -233,6 +233,7 @@ struct rocker {
 	struct pci_dev *pdev;
 	u8 __iomem *hw_addr;
 	struct msix_entry *msix_entries;
+	struct switchdev switchdev;
 	unsigned int port_count;
 	struct rocker_port **ports;
 	struct {
@@ -5090,6 +5091,19 @@ static void rocker_msix_fini(const struct rocker *rocker)
 	kfree(rocker->msix_entries);
 }
 
+static int rocker_probe_register_switchdev(struct rocker *rocker)
+{
+	char name[sizeof(rocker->hw.id) * 2 + 1];
+
+	sprintf(name, "%*phN", (int)sizeof(rocker->hw.id), &rocker->hw.id);
+	return register_switchdev(&rocker->switchdev, name);
+}
+
+static void rocker_probe_unregister_switchdev(struct rocker *rocker)
+{
+	unregister_switchdev(&rocker->switchdev);
+}
+
 static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	struct rocker *rocker;
@@ -5194,11 +5208,19 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto err_probe_ports;
 	}
 
+	err = rocker_probe_register_switchdev(rocker);
+	if (err) {
+		dev_err(&pdev->dev, "cannot register switchdev\n");
+		goto err_register_switchdev;
+	}
+
 	dev_info(&pdev->dev, "Rocker switch with id %*phN\n",
 		 (int)sizeof(rocker->hw.id), &rocker->hw.id);
 
 	return 0;
 
+err_register_switchdev:
+	rocker_remove_ports(rocker);
 err_probe_ports:
 	rocker_free_tbls(rocker);
 err_init_tbls:
@@ -5227,6 +5249,7 @@ static void rocker_remove(struct pci_dev *pdev)
 {
 	struct rocker *rocker = pci_get_drvdata(pdev);
 
+	rocker_probe_unregister_switchdev(rocker);
 	rocker_free_tbls(rocker);
 	rocker_write32(rocker, CONTROL, ROCKER_CONTROL_RESET);
 	rocker_remove_ports(rocker);
-- 
1.7.10.4
