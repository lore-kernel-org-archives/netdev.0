From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 32/33] sfc: Fix synchronisation of efx_mtd_{probe,rename,remove}
Date: Fri, 12 Dec 2008 13:00:51 +0000
Message-ID: <20081212130050.GF10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:52702 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758026AbYLLNAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 08:00:54 -0500
Content-Disposition: inline
In-Reply-To: <cover.1229085672.git.bhutchings@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently efx_mtd_rename() can race with the probe() and remove()
functions.

Move probe() before device registration and remove() after
unregistration.  Move initialisation/update of all names based on the
netdev name into a new function and call it under the RTNL immediately
after registration.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   33 ++++++++++++++++++---------------
 1 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 0d57c6d..8d9d0b4 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1517,18 +1517,21 @@ static const struct net_device_ops efx_netdev_ops = {
 #endif
 };
 
+static void efx_update_name(struct efx_nic *efx)
+{
+	strcpy(efx->name, efx->net_dev->name);
+	efx_mtd_rename(efx);
+	efx_set_channel_names(efx);
+}
+
 static int efx_netdev_event(struct notifier_block *this,
 			    unsigned long event, void *ptr)
 {
 	struct net_device *net_dev = ptr;
 
-	if (net_dev->netdev_ops == &efx_netdev_ops && event == NETDEV_CHANGENAME) {
-		struct efx_nic *efx = netdev_priv(net_dev);
-
-		strcpy(efx->name, net_dev->name);
-		efx_mtd_rename(efx);
-		efx_set_channel_names(efx);
-	}
+	if (net_dev->netdev_ops == &efx_netdev_ops &&
+	    event == NETDEV_CHANGENAME)
+		efx_update_name(netdev_priv(net_dev));
 
 	return NOTIFY_DONE;
 }
@@ -1568,8 +1571,10 @@ static int efx_register_netdev(struct efx_nic *efx)
 		EFX_ERR(efx, "could not register net dev\n");
 		return rc;
 	}
-	strcpy(efx->name, net_dev->name);
-	efx_set_channel_names(efx);
+
+	rtnl_lock();
+	efx_update_name(efx);
+	rtnl_unlock();
 
 	rc = device_create_file(&efx->pci_dev->dev, &dev_attr_phy_type);
 	if (rc) {
@@ -1981,8 +1986,6 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 	if (!efx)
 		return;
 
-	efx_mtd_remove(efx);
-
 	/* Mark the NIC as fini, then stop the interface */
 	rtnl_lock();
 	efx->state = STATE_FINI;
@@ -1996,6 +1999,8 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 
 	efx_unregister_netdev(efx);
 
+	efx_mtd_remove(efx);
+
 	/* Wait for any scheduled resets to complete. No more will be
 	 * scheduled from this point because efx_stop_all() has been
 	 * called, we are no longer registered with driverlink, and
@@ -2149,17 +2154,15 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	/* Switch to the running state before we expose the device to
 	 * the OS.  This is to ensure that the initial gathering of
 	 * MAC stats succeeds. */
-	rtnl_lock();
 	efx->state = STATE_RUNNING;
-	rtnl_unlock();
+
+	efx_mtd_probe(efx); /* allowed to fail */
 
 	rc = efx_register_netdev(efx);
 	if (rc)
 		goto fail5;
 
 	EFX_LOG(efx, "initialisation successful\n");
-
-	efx_mtd_probe(efx); /* allowed to fail */
 	return 0;
 
  fail5:
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
