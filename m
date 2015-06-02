From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 03/15] sfc: Add sysfs entry for flags (link control
 and primary)
Date: Tue, 2 Jun 2015 11:37:58 +0100
Message-ID: <556D8786.2090906@solarflare.com>
References: <556D8710.6060706@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:4447 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752923AbbFBKiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 06:38:08 -0400
In-Reply-To: <556D8710.6060706@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On  every adapter there will be one primary PF per adaptor and
one link control PF per port.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 58 ++++++++++++++++++++++++++++++++++++-----
 1 file changed, 51 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 14c5205..e659da8 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -246,6 +246,34 @@ static int efx_ef10_get_mac_address_vf(struct efx_nic *efx, u8 *mac_address)
 	return 0;
 }
 
+static ssize_t efx_ef10_show_link_control_flag(struct device *dev,
+					       struct device_attribute *attr,
+					       char *buf)
+{
+	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+
+	return sprintf(buf, "%d\n",
+		       ((efx->mcdi->fn_flags) &
+			(1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_LINKCTRL))
+		       ? 1 : 0);
+}
+
+static ssize_t efx_ef10_show_primary_flag(struct device *dev,
+					  struct device_attribute *attr,
+					  char *buf)
+{
+	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+
+	return sprintf(buf, "%d\n",
+		       ((efx->mcdi->fn_flags) &
+			(1 << MC_CMD_DRV_ATTACH_EXT_OUT_FLAG_PRIMARY))
+		       ? 1 : 0);
+}
+
+static DEVICE_ATTR(link_control_flag, 0444, efx_ef10_show_link_control_flag,
+		   NULL);
+static DEVICE_ATTR(primary_flag, 0444, efx_ef10_show_primary_flag, NULL);
+
 static int efx_ef10_probe(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data;
@@ -315,30 +343,39 @@ static int efx_ef10_probe(struct efx_nic *efx)
 	if (rc)
 		goto fail3;
 
-	rc = efx_ef10_get_pf_index(efx);
+	rc = device_create_file(&efx->pci_dev->dev,
+				&dev_attr_link_control_flag);
 	if (rc)
 		goto fail3;
 
+	rc = device_create_file(&efx->pci_dev->dev, &dev_attr_primary_flag);
+	if (rc)
+		goto fail4;
+
+	rc = efx_ef10_get_pf_index(efx);
+	if (rc)
+		goto fail5;
+
 	rc = efx_ef10_init_datapath_caps(efx);
 	if (rc < 0)
-		goto fail3;
+		goto fail5;
 
 	efx->rx_packet_len_offset =
 		ES_DZ_RX_PREFIX_PKTLEN_OFST - ES_DZ_RX_PREFIX_SIZE;
 
 	rc = efx_mcdi_port_get_number(efx);
 	if (rc < 0)
-		goto fail3;
+		goto fail5;
 	efx->port_num = rc;
 	net_dev->dev_port = rc;
 
 	rc = efx->type->get_mac_address(efx, efx->net_dev->perm_addr);
 	if (rc)
-		goto fail3;
+		goto fail5;
 
 	rc = efx_ef10_get_sysclk_freq(efx);
 	if (rc < 0)
-		goto fail3;
+		goto fail5;
 	efx->timer_quantum_ns = 1536000 / rc; /* 1536 cycles */
 
 	/* Check whether firmware supports bug 35388 workaround.
@@ -357,7 +394,7 @@ static int efx_ef10_probe(struct efx_nic *efx)
 		nic_data->workaround_35388 = enabled &
 			MC_CMD_GET_WORKAROUNDS_OUT_BUG35388;
 	} else if (rc != -ENOSYS && rc != -ENOENT) {
-		goto fail3;
+		goto fail5;
 	}
 	netif_dbg(efx, probe, efx->net_dev,
 		  "workaround for bug 35388 is %sabled\n",
@@ -365,12 +402,16 @@ static int efx_ef10_probe(struct efx_nic *efx)
 
 	rc = efx_mcdi_mon_probe(efx);
 	if (rc && rc != -EPERM)
-		goto fail3;
+		goto fail5;
 
 	efx_ptp_probe(efx, NULL);
 
 	return 0;
 
+fail5:
+	device_remove_file(&efx->pci_dev->dev, &dev_attr_primary_flag);
+fail4:
+	device_remove_file(&efx->pci_dev->dev, &dev_attr_link_control_flag);
 fail3:
 	efx_mcdi_fini(efx);
 fail2:
@@ -613,6 +654,9 @@ static void efx_ef10_remove(struct efx_nic *efx)
 	if (!nic_data->must_restore_piobufs)
 		efx_ef10_free_piobufs(efx);
 
+	device_remove_file(&efx->pci_dev->dev, &dev_attr_primary_flag);
+	device_remove_file(&efx->pci_dev->dev, &dev_attr_link_control_flag);
+
 	efx_mcdi_fini(efx);
 	efx_nic_free_buffer(efx, &nic_data->mcdi_buf);
 	kfree(nic_data);
