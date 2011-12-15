From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 3/3] ethtool: Define and apply a default policy
 for RX flow hash indirection
Date: Thu, 15 Dec 2011 23:56:49 +0000
Message-ID: <1323993409.2773.28.camel@bwh-desktop>
References: <1323993076.2773.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	<netdev@vger.kernel.org>, "VMware, Inc." <pv-drivers@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:34894 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759859Ab1LOX4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 18:56:54 -0500
In-Reply-To: <1323993076.2773.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All drivers that support modification of the RX flow hash indirection
table initialise it in the same way: RX rings are assigned to table
entries in rotation.  Make that default policy explicit by having them
call a ethtool_rxfh_indir_default() function.

In the ethtool core, add support for a zero size value for
ETHTOOL_SRXFHINDIR, which resets the table to this default.

Partly-suggested-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
The bnx2x, cxgb4 and vmxnet3 changes are compile-tested only.

Ben.

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    3 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    2 +-
 drivers/net/ethernet/sfc/efx.c                  |    3 +-
 drivers/net/vmxnet3/vmxnet3_drv.c               |    3 +-
 include/linux/ethtool.h                         |   23 ++++++++++++++--
 net/core/ethtool.c                              |   33 ++++++++++++++---------
 6 files changed, 47 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 64f5cf5..2b731b2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1545,7 +1545,8 @@ static inline int bnx2x_init_rss_pf(struct bnx2x *bp)
 	if (bp->multi_mode != ETH_RSS_MODE_DISABLED) {
 		for (i = 0; i < sizeof(ind_table); i++)
 			ind_table[i] =
-				bp->fp->cl_id +	(i % num_eth_queues);
+				bp->fp->cl_id +
+				ethtool_rxfh_indir_default(i, num_eth_queues);
 	}
 
 	/*
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 8ffd55b..fccbe49 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3449,7 +3449,7 @@ static int __devinit init_rss(struct adapter *adap)
 		if (!pi->rss)
 			return -ENOMEM;
 		for (j = 0; j < pi->rss_size; j++)
-			pi->rss[j] = j % pi->nqsets;
+			pi->rss[j] = ethtool_rxfh_indir_default(j, pi->nqsets);
 	}
 	return 0;
 }
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 14e134d..44a82c6 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1336,7 +1336,8 @@ static int efx_probe_nic(struct efx_nic *efx)
 	if (efx->n_channels > 1)
 		get_random_bytes(&efx->rx_hash_key, sizeof(efx->rx_hash_key));
 	for (i = 0; i < ARRAY_SIZE(efx->rx_indir_table); i++)
-		efx->rx_indir_table[i] = i % efx->n_rx_channels;
+		efx->rx_indir_table[i] =
+			ethtool_rxfh_indir_default(i, efx->n_rx_channels);
 
 	efx_set_channels(efx);
 	netif_set_real_num_tx_queues(efx->net_dev, efx->n_tx_channels);
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 1c2ae11..de7fc34 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2167,7 +2167,8 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 		rssConf->indTableSize = VMXNET3_RSS_IND_TABLE_SIZE;
 		get_random_bytes(&rssConf->hashKey[0], rssConf->hashKeySize);
 		for (i = 0; i < rssConf->indTableSize; i++)
-			rssConf->indTable[i] = i % adapter->num_rx_queues;
+			rssConf->indTable[i] = ethtool_rxfh_indir_default(
+				i, adapter->num_rx_queues);
 
 		devRead->rssConfDesc.confVer = 1;
 		devRead->rssConfDesc.confLen = sizeof(*rssConf);
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 3b9f09d..7eba8f3 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -543,10 +543,15 @@ struct compat_ethtool_rxnfc {
 /**
  * struct ethtool_rxfh_indir - command to get or set RX flow hash indirection
  * @cmd: Specific command number - %ETHTOOL_GRXFHINDIR or %ETHTOOL_SRXFHINDIR
- * @size: On entry, the array size of the user buffer, which may be zero
- *	for %ETHTOOL_GRXFHINDIR.  On return from %ETHTOOL_GRXFHINDIR, the
- *	array size of the hardware indirection table.
+ * @size: On entry, the array size of the user buffer, which may be zero.
+ *	On return from %ETHTOOL_GRXFHINDIR, the array size of the hardware
+ *	indirection table. 
  * @ring_index: RX ring/queue index for each hash value
+ *
+ * For %ETHTOOL_GRXFHINDIR, a @size of zero means that only the size
+ * should be returned.  For %ETHTOOL_SRXFHINDIR, a @size of zero means
+ * the table should be reset to default values.  This last feature
+ * is not supported by the original implementations.
  */
 struct ethtool_rxfh_indir {
 	__u32	cmd;
@@ -750,6 +755,18 @@ struct net_device;
 u32 ethtool_op_get_link(struct net_device *dev);
 
 /**
+ * ethtool_rxfh_indir_default - get default value for RX flow hash indirection
+ * @index: Index in RX flow hash indirection table
+ * @n_rx_rings: Number of RX rings to use
+ *
+ * This function provides the default policy for RX flow hash indirection.
+ */
+static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
+{
+	return index % n_rx_rings;
+}
+
+/**
  * struct ethtool_ops - optional netdev operations
  * @get_settings: Get various device settings including Ethernet link
  *	settings. The @cmd parameter is expected to have been cleared
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 69f71b8..597732c 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -581,31 +581,38 @@ static noinline_for_stack int ethtool_set_rxfh_indir(struct net_device *dev,
 			   sizeof(user_size)))
 		return -EFAULT;
 
-	if (user_size != dev_size)
+	if (user_size != 0 && user_size != dev_size)
 		return -EINVAL;
 
 	indir = kcalloc(dev_size, sizeof(indir[0]), GFP_USER);
 	if (!indir)
 		return -ENOMEM;
 
-	if (copy_from_user(indir,
-			   useraddr +
-			   offsetof(struct ethtool_rxfh_indir, ring_index[0]),
-			   dev_size * sizeof(indir[0]))) {
-		ret = -EFAULT;
-		goto out;
-	}
-
-	/* Validate ring indices */
 	rx_rings.cmd = ETHTOOL_GRXRINGS;
 	ret = dev->ethtool_ops->get_rxnfc(dev, &rx_rings, NULL);
 	if (ret)
 		goto out;
-	for (i = 0; i < dev_size; i++) {
-		if (indir[i] >= rx_rings.data) {
-			ret = -EINVAL;
+
+	if (user_size == 0) {
+		for (i = 0; i < dev_size; i++)
+			indir[i] = ethtool_rxfh_indir_default(i, rx_rings.data);
+	} else {
+		if (copy_from_user(indir,
+				  useraddr +
+				  offsetof(struct ethtool_rxfh_indir,
+					   ring_index[0]),
+				  dev_size * sizeof(indir[0]))) {
+			ret = -EFAULT;
 			goto out;
 		}
+
+		/* Validate ring indices */
+		for (i = 0; i < dev_size; i++) {
+			if (indir[i] >= rx_rings.data) {
+				ret = -EINVAL;
+				goto out;
+			}
+		}
 	}
 
 	ret = dev->ethtool_ops->set_rxfh_indir(dev, indir);
-- 
1.7.4.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
