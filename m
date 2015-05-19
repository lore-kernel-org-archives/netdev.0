From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/4] sfc: add sysfs entry to control MCDI tracing
Date: Tue, 19 May 2015 18:36:29 +0100
Message-ID: <555B749D.40802@solarflare.com>
References: <555B7403.3060006@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:43558 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751388AbbESRgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 13:36:36 -0400
In-Reply-To: <555B7403.3060006@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MCDI tracing is enabled per-function with a sysfs file
    /sys/class/net/<NET_DEV>/device/mcdi_logging

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/Kconfig |  3 ++-
 drivers/net/ethernet/sfc/efx.c   | 49 ++++++++++++++++++++++++++++++++++------
 drivers/net/ethernet/sfc/mcdi.c  |  4 ++--
 drivers/net/ethernet/sfc/mcdi.h  |  2 ++
 4 files changed, 48 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sfc/Kconfig b/drivers/net/ethernet/sfc/Kconfig
index c4ba42b..4dd92b7 100644
--- a/drivers/net/ethernet/sfc/Kconfig
+++ b/drivers/net/ethernet/sfc/Kconfig
@@ -43,4 +43,5 @@ config SFC_MCDI_LOGGING
 	---help---
 	  This enables support for tracing of MCDI (Management-Controller-to-
 	  Driver-Interface) commands and responses, allowing debugging of
-	  driver/firmware interaction.
+	  driver/firmware interaction.  The tracing is actually enabled by
+	  a sysfs file 'mcdi_logging' under the PCI device.
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 0f127a0..86a2da5 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2298,6 +2298,28 @@ show_phy_type(struct device *dev, struct device_attribute *attr, char *buf)
 }
 static DEVICE_ATTR(phy_type, 0444, show_phy_type, NULL);
 
+#ifdef CONFIG_SFC_MCDI_LOGGING
+static ssize_t show_mcdi_log(struct device *dev, struct device_attribute *attr,
+			     char *buf)
+{
+	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
+
+	return scnprintf(buf, PAGE_SIZE, "%d\n", mcdi->logging_enabled);
+}
+static ssize_t set_mcdi_log(struct device *dev, struct device_attribute *attr,
+			    const char *buf, size_t count)
+{
+	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
+	bool enable = count > 0 && *buf != '0';
+
+	mcdi->logging_enabled = enable;
+	return count;
+}
+static DEVICE_ATTR(mcdi_logging, 0644, show_mcdi_log, set_mcdi_log);
+#endif
+
 static int efx_register_netdev(struct efx_nic *efx)
 {
 	struct net_device *net_dev = efx->net_dev;
@@ -2355,9 +2377,21 @@ static int efx_register_netdev(struct efx_nic *efx)
 			  "failed to init net dev attributes\n");
 		goto fail_registered;
 	}
+#ifdef CONFIG_SFC_MCDI_LOGGING
+	rc = device_create_file(&efx->pci_dev->dev, &dev_attr_mcdi_logging);
+	if (rc) {
+		netif_err(efx, drv, efx->net_dev,
+			  "failed to init net dev attributes\n");
+		goto fail_attr_mcdi_logging;
+	}
+#endif
 
 	return 0;
 
+#ifdef CONFIG_SFC_MCDI_LOGGING
+fail_attr_mcdi_logging:
+	device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_type);
+#endif
 fail_registered:
 	rtnl_lock();
 	efx_dissociate(efx);
@@ -2376,13 +2410,14 @@ static void efx_unregister_netdev(struct efx_nic *efx)
 
 	BUG_ON(netdev_priv(efx->net_dev) != efx);
 
-	strlcpy(efx->name, pci_name(efx->pci_dev), sizeof(efx->name));
-	device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_type);
-
-	rtnl_lock();
-	unregister_netdevice(efx->net_dev);
-	efx->state = STATE_UNINIT;
-	rtnl_unlock();
+	if (efx_dev_registered(efx)) {
+		strlcpy(efx->name, pci_name(efx->pci_dev), sizeof(efx->name));
+#ifdef CONFIG_SFC_MCDI_LOGGING
+		device_remove_file(&efx->pci_dev->dev, &dev_attr_mcdi_logging);
+#endif
+		device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_type);
+		unregister_netdev(efx->net_dev);
+	}
 }
 
 /**************************************************************************
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 255a246..a147bfc 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -188,7 +188,7 @@ static void efx_mcdi_send_request(struct efx_nic *efx, unsigned cmd,
 	}
 
 #ifdef CONFIG_SFC_MCDI_LOGGING
-	if (!WARN_ON_ONCE(!buf)) {
+	if (mcdi->logging_enabled && !WARN_ON_ONCE(!buf)) {
 		int bytes = 0;
 		int i;
 		/* Lengths should always be a whole number of dwords, so scream
@@ -274,7 +274,7 @@ static void efx_mcdi_read_response_header(struct efx_nic *efx)
 	}
 
 #ifdef CONFIG_SFC_MCDI_LOGGING
-	if (!WARN_ON_ONCE(!buf)) {
+	if (mcdi->logging_enabled && !WARN_ON_ONCE(!buf)) {
 		size_t hdr_len, data_len;
 		int bytes = 0;
 		int i;
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 2f6f032..47035a0 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -59,6 +59,7 @@ enum efx_mcdi_mode {
  * @async_list: Queue of asynchronous requests
  * @async_timer: Timer for asynchronous request timeout
  * @logging_buffer: buffer that may be used to build MCDI tracing messages
+ * @logging_enabled: whether to trace MCDI
  */
 struct efx_mcdi_iface {
 	struct efx_nic *efx;
@@ -77,6 +78,7 @@ struct efx_mcdi_iface {
 	struct timer_list async_timer;
 #ifdef CONFIG_SFC_MCDI_LOGGING
 	char *logging_buffer;
+	bool logging_enabled;
 #endif
 };
 
