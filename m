From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/7] sfc: Fix ordering of device registration and initial
	netif_carrier_off()
Date: Wed, 26 Aug 2009 19:16:27 +0100
Message-ID: <1251310587.27345.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:34457 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752590AbZHZSQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 14:16:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We must call netif_carrier_off() after the device is registered, not
before, to set the operational state and user-space IFF_RUNNING flag
correctly.

Since we don't want observers to see an intermediate state, open-code
register_netdev() and add efx_update_name() and netif_carrier_off()
into the locked region.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   26 +++++++++++++++++---------
 1 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 343e8da..d4dc920 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1614,21 +1614,24 @@ static int efx_register_netdev(struct efx_nic *efx)
 	SET_NETDEV_DEV(net_dev, &efx->pci_dev->dev);
 	SET_ETHTOOL_OPS(net_dev, &efx_ethtool_ops);
 
-	/* Always start with carrier off; PHY events will detect the link */
-	netif_carrier_off(efx->net_dev);
-
 	/* Clear MAC statistics */
 	efx->mac_op->update_stats(efx);
 	memset(&efx->mac_stats, 0, sizeof(efx->mac_stats));
 
-	rc = register_netdev(net_dev);
-	if (rc) {
-		EFX_ERR(efx, "could not register net dev\n");
-		return rc;
-	}
-
 	rtnl_lock();
+
+	rc = dev_alloc_name(net_dev, net_dev->name);
+	if (rc < 0)
+		goto fail_locked;
 	efx_update_name(efx);
+
+	rc = register_netdevice(net_dev);
+	if (rc)
+		goto fail_locked;
+
+	/* Always start with carrier off; PHY events will detect the link */
+	netif_carrier_off(efx->net_dev);
+
 	rtnl_unlock();
 
 	rc = device_create_file(&efx->pci_dev->dev, &dev_attr_phy_type);
@@ -1639,6 +1642,11 @@ static int efx_register_netdev(struct efx_nic *efx)
 
 	return 0;
 
+fail_locked:
+	rtnl_unlock();
+	EFX_ERR(efx, "could not register net dev\n");
+	return rc;
+
 fail_registered:
 	unregister_netdev(net_dev);
 	return rc;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

