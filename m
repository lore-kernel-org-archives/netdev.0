From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 16/33] sfc: Add phy_type device attribute
Date: Fri, 12 Dec 2008 12:54:02 +0000
Message-ID: <20081212125401.GP10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:50595 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757024AbYLLMyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:54:06 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 844580f..4fb5ba2 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1496,6 +1496,14 @@ static struct notifier_block efx_netdev_notifier = {
 	.notifier_call = efx_netdev_event,
 };
 
+static ssize_t
+show_phy_type(struct device *dev, struct device_attribute *attr, char *buf)
+{
+	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+	return sprintf(buf, "%d\n", efx->phy_type);
+}
+static DEVICE_ATTR(phy_type, 0644, show_phy_type, NULL);
+
 static int efx_register_netdev(struct efx_nic *efx)
 {
 	struct net_device *net_dev = efx->net_dev;
@@ -1522,7 +1530,17 @@ static int efx_register_netdev(struct efx_nic *efx)
 	strcpy(efx->name, net_dev->name);
 	efx_set_channel_names(efx);
 
+	rc = device_create_file(&efx->pci_dev->dev, &dev_attr_phy_type);
+	if (rc) {
+		EFX_ERR(efx, "failed to init net dev attributes\n");
+		goto fail_registered;
+	}
+
 	return 0;
+
+fail_registered:
+	unregister_netdev(net_dev);
+	return rc;
 }
 
 static void efx_unregister_netdev(struct efx_nic *efx)
@@ -1542,6 +1560,7 @@ static void efx_unregister_netdev(struct efx_nic *efx)
 
 	if (efx_dev_registered(efx)) {
 		strlcpy(efx->name, pci_name(efx->pci_dev), sizeof(efx->name));
+		device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_type);
 		unregister_netdev(efx->net_dev);
 	}
 }
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
