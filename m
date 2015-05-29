From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 01/14] sfc: Add sysfs entry for physical port
Date: Fri, 29 May 2015 11:01:06 +0100
Message-ID: <556838E2.3040405@solarflare.com>
References: <55683895.2090408@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:21012 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755077AbbE2KBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 06:01:16 -0400
In-Reply-To: <55683895.2090408@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case where we have multiple functions (PFs and VFs), this
sysfs entry is useful to identify the physical port corresponding
to the function we are interested in.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 35 ++++++++++++++++++++++++++++-------
 1 file changed, 28 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index a547ceb..ee20d96 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -246,6 +246,18 @@ static int efx_ef10_get_mac_address_vf(struct efx_nic *efx, u8 *mac_address)
 	return 0;
 }
 
+static ssize_t efx_ef10_show_physical_port(struct device *dev,
+					   struct device_attribute *attr,
+					   char *buf)
+{
+	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+
+	return sprintf(buf, "%d\n", efx->port_num);
+}
+
+static DEVICE_ATTR(physical_port, 0444, efx_ef10_show_physical_port,
+		   NULL);
+
 static int efx_ef10_probe(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data;
@@ -326,14 +338,18 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	if (rc < 0)
 		goto fail3;
 	efx->port_num = rc;
+	rc = device_create_file(&efx->pci_dev->dev, &dev_attr_physical_port);
+	if (rc)
+		goto fail3;
 
 	rc = efx->type->get_mac_address(efx, efx->net_dev->perm_addr);
 	if (rc)
-		goto fail3;
+		goto fail4;
 
 	rc = efx_ef10_get_sysclk_freq(efx);
 	if (rc < 0)
-		goto fail3;
+		goto fail4;
+
 	efx->timer_quantum_ns = 1536000 / rc; /* 1536 cycles */
 
 	/* Check whether firmware supports bug 35388 workaround.
@@ -341,9 +357,9 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	 * ask if it's already enabled
 	 */
 	rc = efx_mcdi_set_workaround(efx, MC_CMD_WORKAROUND_BUG35388, true);
-	if (rc == 0)
+	if (rc == 0) {
 		nic_data->workaround_35388 = true;
-	else if (rc == -EPERM) {
+	} else if (rc == -EPERM) {
 		unsigned int enabled;
 
 		rc = efx_mcdi_get_workarounds(efx, NULL, &enabled);
@@ -351,21 +367,24 @@ static int efx_ef10_probe(struct efx_nic *efx)
 			goto fail3;
 		nic_data->workaround_35388 = enabled &
 			MC_CMD_GET_WORKAROUNDS_OUT_BUG35388;
+	} else if (rc != -ENOSYS && rc != -ENOENT) {
+		goto fail4;
 	}
-	else if (rc != -ENOSYS && rc != -ENOENT)
-		goto fail3;
+
 	netif_dbg(efx, probe, efx->net_dev,
 		  "workaround for bug 35388 is %sabled\n",
 		  nic_data->workaround_35388 ? "en" : "dis");
 
 	rc = efx_mcdi_mon_probe(efx);
 	if (rc && rc != -EPERM)
-		goto fail3;
+		goto fail4;
 
 	efx_ptp_probe(efx, NULL);
 
 	return 0;
 
+fail4:
+	device_remove_file(&efx->pci_dev->dev, &dev_attr_physical_port);
 fail3:
 	efx_mcdi_fini(efx);
 fail2:
@@ -608,6 +627,8 @@ static void efx_ef10_remove(struct efx_nic *efx)
 	if (!nic_data->must_restore_piobufs)
 		efx_ef10_free_piobufs(efx);
 
+	device_remove_file(&efx->pci_dev->dev, &dev_attr_physical_port);
+
 	efx_mcdi_fini(efx);
 	efx_nic_free_buffer(efx, &nic_data->mcdi_buf);
 	kfree(nic_data);
