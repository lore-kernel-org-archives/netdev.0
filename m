From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/3] ethtool: Centralise validation of
 ETHTOOL_{G,S}RXFHINDIR parameters
Date: Thu, 15 Dec 2011 23:55:01 +0000
Message-ID: <1323993301.2773.26.camel@bwh-desktop>
References: <1323993076.2773.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:34860 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751917Ab1LOXzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 18:55:06 -0500
In-Reply-To: <1323993076.2773.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new ethtool operation (get_rxfh_indir_size) to get the
indirectional table size.  Use this to validate the user buffer size
before calling get_rxfh_indir or set_rxfh_indir.  Use get_rxnfc to get
the number of RX rings, and validate the contents of the new
indirection table before calling set_rxfh_indir.  Remove this
validation from drivers.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
The bnx2x, cxgb4 and vmxnet3 changes are compile-tested only.

Ben.

 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   39 ++++------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   27 ++++---
 drivers/net/ethernet/sfc/ethtool.c                 |   35 +++------
 drivers/net/vmxnet3/vmxnet3_ethtool.c              |   35 ++++-----
 include/linux/ethtool.h                            |   11 ++-
 net/core/ethtool.c                                 |   81 +++++++++++++------
 6 files changed, 117 insertions(+), 111 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 90d44af..a688b9d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2302,18 +2302,20 @@ static int bnx2x_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
 	}
 }
 
-static int bnx2x_get_rxfh_indir(struct net_device *dev,
-				struct ethtool_rxfh_indir *indir)
+static u32 bnx2x_get_rxfh_indir_size(struct net_device *dev)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+
+	return (bp->multi_mode == ETH_RSS_MODE_DISABLED ?
+		0 : T_ETH_INDIRECTION_TABLE_SIZE);
+}
+
+static int bnx2x_get_rxfh_indir(struct net_device *dev, u32 *indir)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	size_t copy_size =
-		min_t(size_t, indir->size, T_ETH_INDIRECTION_TABLE_SIZE);
 	u8 ind_table[T_ETH_INDIRECTION_TABLE_SIZE] = {0};
 	size_t i;
 
-	if (bp->multi_mode == ETH_RSS_MODE_DISABLED)
-		return -EOPNOTSUPP;
-
 	/* Get the current configuration of the RSS indirection table */
 	bnx2x_get_rss_ind_table(&bp->rss_conf_obj, ind_table);
 
@@ -2326,33 +2328,19 @@ static int bnx2x_get_rxfh_indir(struct net_device *dev,
 	 * align the returned table to the Client ID of the leading RSS
 	 * queue.
 	 */
-	for (i = 0; i < copy_size; i++)
-		indir->ring_index[i] = ind_table[i] - bp->fp->cl_id;
-
-	indir->size = T_ETH_INDIRECTION_TABLE_SIZE;
+	for (i = 0; i < T_ETH_INDIRECTION_TABLE_SIZE; i++)
+		indir[i] = ind_table[i] - bp->fp->cl_id;
 
 	return 0;
 }
 
-static int bnx2x_set_rxfh_indir(struct net_device *dev,
-				const struct ethtool_rxfh_indir *indir)
+static int bnx2x_set_rxfh_indir(struct net_device *dev, const u32 *indir)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	size_t i;
 	u8 ind_table[T_ETH_INDIRECTION_TABLE_SIZE] = {0};
-	u32 num_eth_queues = BNX2X_NUM_ETH_QUEUES(bp);
-
-	if (bp->multi_mode == ETH_RSS_MODE_DISABLED)
-		return -EOPNOTSUPP;
-
-	/* validate the size */
-	if (indir->size != T_ETH_INDIRECTION_TABLE_SIZE)
-		return -EINVAL;
 
 	for (i = 0; i < T_ETH_INDIRECTION_TABLE_SIZE; i++) {
-		/* validate the indices */
-		if (indir->ring_index[i] >= num_eth_queues)
-			return -EINVAL;
 		/*
 		 * The same as in bnx2x_get_rxfh_indir: we can't use a memcpy()
 		 * as an internal storage of an indirection table is a u8 array
@@ -2362,7 +2350,7 @@ static int bnx2x_set_rxfh_indir(struct net_device *dev,
 		 * align the received table to the Client ID of the leading RSS
 		 * queue
 		 */
-		ind_table[i] = indir->ring_index[i] + bp->fp->cl_id;
+		ind_table[i] = indir[i] + bp->fp->cl_id;
 	}
 
 	return bnx2x_config_rss_pf(bp, ind_table, false);
@@ -2395,6 +2383,7 @@ static const struct ethtool_ops bnx2x_ethtool_ops = {
 	.set_phys_id		= bnx2x_set_phys_id,
 	.get_ethtool_stats	= bnx2x_get_ethtool_stats,
 	.get_rxnfc		= bnx2x_get_rxnfc,
+	.get_rxfh_indir_size	= bnx2x_get_rxfh_indir_size,
 	.get_rxfh_indir		= bnx2x_get_rxfh_indir,
 	.set_rxfh_indir		= bnx2x_set_rxfh_indir,
 };
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index a34e7ce..8ffd55b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1871,30 +1871,30 @@ static int cxgb_set_features(struct net_device *dev, netdev_features_t features)
 	return err;
 }
 
-static int get_rss_table(struct net_device *dev, struct ethtool_rxfh_indir *p)
+static u32 get_rss_table_size(struct net_device *dev)
 {
 	const struct port_info *pi = netdev_priv(dev);
-	unsigned int n = min_t(unsigned int, p->size, pi->rss_size);
 
-	p->size = pi->rss_size;
+	return pi->rss_size;
+}
+
+static int get_rss_table(struct net_device *dev, u32 *p)
+{
+	const struct port_info *pi = netdev_priv(dev);
+	unsigned int n = pi->rss_size;
+
 	while (n--)
-		p->ring_index[n] = pi->rss[n];
+		p[n] = pi->rss[n];
 	return 0;
 }
 
-static int set_rss_table(struct net_device *dev,
-			 const struct ethtool_rxfh_indir *p)
+static int set_rss_table(struct net_device *dev, const u32 *p)
 {
 	unsigned int i;
 	struct port_info *pi = netdev_priv(dev);
 
-	if (p->size != pi->rss_size)
-		return -EINVAL;
-	for (i = 0; i < p->size; i++)
-		if (p->ring_index[i] >= pi->nqsets)
-			return -EINVAL;
-	for (i = 0; i < p->size; i++)
-		pi->rss[i] = p->ring_index[i];
+	for (i = 0; i < pi->rss_size; i++)
+		pi->rss[i] = p[i];
 	if (pi->adapter->flags & FULL_INIT_DONE)
 		return write_rss(pi, pi->rss);
 	return 0;
@@ -1989,6 +1989,7 @@ static struct ethtool_ops cxgb_ethtool_ops = {
 	.get_wol           = get_wol,
 	.set_wol           = set_wol,
 	.get_rxnfc         = get_rxnfc,
+	.get_rxfh_indir_size = get_rss_table_size,
 	.get_rxfh_indir    = get_rss_table,
 	.set_rxfh_indir    = set_rss_table,
 	.flash_device      = set_flash,
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index f3cd96d..1be51b2 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -956,40 +956,28 @@ static int efx_ethtool_set_rx_ntuple(struct net_device *net_dev,
 	return rc < 0 ? rc : 0;
 }
 
-static int efx_ethtool_get_rxfh_indir(struct net_device *net_dev,
-				      struct ethtool_rxfh_indir *indir)
+static u32 efx_ethtool_get_rxfh_indir_size(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	size_t copy_size =
-		min_t(size_t, indir->size, ARRAY_SIZE(efx->rx_indir_table));
 
-	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0)
-		return -EOPNOTSUPP;
+	return (efx_nic_rev(efx) < EFX_REV_FALCON_B0 ?
+		0 : ARRAY_SIZE(efx->rx_indir_table));
+}
+
+static int efx_ethtool_get_rxfh_indir(struct net_device *net_dev, u32 *indir)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
 
-	indir->size = ARRAY_SIZE(efx->rx_indir_table);
-	memcpy(indir->ring_index, efx->rx_indir_table,
-	       copy_size * sizeof(indir->ring_index[0]));
+	memcpy(indir, efx->rx_indir_table, sizeof(efx->rx_indir_table));
 	return 0;
 }
 
 static int efx_ethtool_set_rxfh_indir(struct net_device *net_dev,
-				      const struct ethtool_rxfh_indir *indir)
+				      const u32 *indir)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	size_t i;
-
-	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0)
-		return -EOPNOTSUPP;
-
-	/* Validate size and indices */
-	if (indir->size != ARRAY_SIZE(efx->rx_indir_table))
-		return -EINVAL;
-	for (i = 0; i < ARRAY_SIZE(efx->rx_indir_table); i++)
-		if (indir->ring_index[i] >= efx->n_rx_channels)
-			return -EINVAL;
 
-	memcpy(efx->rx_indir_table, indir->ring_index,
-	       sizeof(efx->rx_indir_table));
+	memcpy(efx->rx_indir_table, indir, sizeof(efx->rx_indir_table));
 	efx_nic_push_rx_indir_table(efx);
 	return 0;
 }
@@ -1020,6 +1008,7 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.reset			= efx_ethtool_reset,
 	.get_rxnfc		= efx_ethtool_get_rxnfc,
 	.set_rx_ntuple		= efx_ethtool_set_rx_ntuple,
+	.get_rxfh_indir_size	= efx_ethtool_get_rxfh_indir_size,
 	.get_rxfh_indir		= efx_ethtool_get_rxfh_indir,
 	.set_rxfh_indir		= efx_ethtool_set_rxfh_indir,
 };
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index b492ee1..a3eb75a 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -565,44 +565,38 @@ vmxnet3_get_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *info,
 }
 
 #ifdef VMXNET3_RSS
+static u32
+vmxnet3_get_rss_indir_size(struct net_device *netdev)
+{
+	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
+	struct UPT1_RSSConf *rssConf = adapter->rss_conf;
+
+	return rssConf->indTableSize;
+}
+
 static int
-vmxnet3_get_rss_indir(struct net_device *netdev,
-		      struct ethtool_rxfh_indir *p)
+vmxnet3_get_rss_indir(struct net_device *netdev, u32 *p)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 	struct UPT1_RSSConf *rssConf = adapter->rss_conf;
-	unsigned int n = min_t(unsigned int, p->size, rssConf->indTableSize);
+	unsigned int n = rssConf->indTableSize;
 
-	p->size = rssConf->indTableSize;
 	while (n--)
-		p->ring_index[n] = rssConf->indTable[n];
+		p[n] = rssConf->indTable[n];
 	return 0;
 
 }
 
 static int
-vmxnet3_set_rss_indir(struct net_device *netdev,
-		      const struct ethtool_rxfh_indir *p)
+vmxnet3_set_rss_indir(struct net_device *netdev, const u32 *p)
 {
 	unsigned int i;
 	unsigned long flags;
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 	struct UPT1_RSSConf *rssConf = adapter->rss_conf;
 
-	if (p->size != rssConf->indTableSize)
-		return -EINVAL;
-	for (i = 0; i < rssConf->indTableSize; i++) {
-		/*
-		 * Return with error code if any of the queue indices
-		 * is out of range
-		 */
-		if (p->ring_index[i] < 0 ||
-		    p->ring_index[i] >= adapter->num_rx_queues)
-			return -EINVAL;
-	}
-
 	for (i = 0; i < rssConf->indTableSize; i++)
-		rssConf->indTable[i] = p->ring_index[i];
+		rssConf->indTable[i] = p[i];
 
 	spin_lock_irqsave(&adapter->cmd_lock, flags);
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
@@ -629,6 +623,7 @@ static struct ethtool_ops vmxnet3_ethtool_ops = {
 	.set_ringparam     = vmxnet3_set_ringparam,
 	.get_rxnfc         = vmxnet3_get_rxnfc,
 #ifdef VMXNET3_RSS
+	.get_rxfh_indir_size = vmxnet3_get_rss_indir_size,
 	.get_rxfh_indir    = vmxnet3_get_rss_indir,
 	.set_rxfh_indir    = vmxnet3_set_rss_indir,
 #endif
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 0ec2fd4..3b9f09d 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -828,9 +828,13 @@ u32 ethtool_op_get_link(struct net_device *dev);
  *	error code or zero.
  * @set_rx_ntuple: Set an RX n-tuple rule.  Returns a negative error code
  *	or zero.
+ * @get_rxfh_indir_size: Get the size of the RX flow hash indirection table.
+ *	Returns zero if not supported for this specific device.
  * @get_rxfh_indir: Get the contents of the RX flow hash indirection table.
+ *	Will not be called if @get_rxfh_indir_size returns zero.
  *	Returns a negative error code or zero.
  * @set_rxfh_indir: Set the contents of the RX flow hash indirection table.
+ *	Will not be called if @get_rxfh_indir_size returns zero.
  *	Returns a negative error code or zero.
  * @get_channels: Get number of channels.
  * @set_channels: Set number of channels.  Returns a negative error code or
@@ -894,10 +898,9 @@ struct ethtool_ops {
 	int	(*reset)(struct net_device *, u32 *);
 	int	(*set_rx_ntuple)(struct net_device *,
 				 struct ethtool_rx_ntuple *);
-	int	(*get_rxfh_indir)(struct net_device *,
-				  struct ethtool_rxfh_indir *);
-	int	(*set_rxfh_indir)(struct net_device *,
-				  const struct ethtool_rxfh_indir *);
+	u32	(*get_rxfh_indir_size)(struct net_device *);
+	int	(*get_rxfh_indir)(struct net_device *, u32 *);
+	int	(*set_rxfh_indir)(struct net_device *, const u32 *);
 	void	(*get_channels)(struct net_device *, struct ethtool_channels *);
 	int	(*set_channels)(struct net_device *, struct ethtool_channels *);
 	int	(*get_dump_flag)(struct net_device *, struct ethtool_dump *);
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 31b0b7f..69f71b8 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -515,34 +515,44 @@ err_out:
 static noinline_for_stack int ethtool_get_rxfh_indir(struct net_device *dev,
 						     void __user *useraddr)
 {
-	struct ethtool_rxfh_indir *indir;
-	u32 table_size;
-	size_t full_size;
+	u32 user_size, dev_size;
+	u32 *indir;
 	int ret;
 
-	if (!dev->ethtool_ops->get_rxfh_indir)
+	if (!dev->ethtool_ops->get_rxfh_indir_size ||
+	    !dev->ethtool_ops->get_rxfh_indir)
+		return -EOPNOTSUPP;
+	dev_size = dev->ethtool_ops->get_rxfh_indir_size(dev);
+	if (dev_size == 0)
 		return -EOPNOTSUPP;
 
-	if (copy_from_user(&table_size,
+	if (copy_from_user(&user_size,
 			   useraddr + offsetof(struct ethtool_rxfh_indir, size),
-			   sizeof(table_size)))
+			   sizeof(user_size)))
 		return -EFAULT;
 
-	if (table_size >
-	    (KMALLOC_MAX_SIZE - sizeof(*indir)) / sizeof(*indir->ring_index))
-		return -ENOMEM;
-	full_size = sizeof(*indir) + sizeof(*indir->ring_index) * table_size;
-	indir = kzalloc(full_size, GFP_USER);
+	if (copy_to_user(useraddr + offsetof(struct ethtool_rxfh_indir, size),
+			 &dev_size, sizeof(dev_size)))
+		return -EFAULT;
+
+	/* If the user buffer size is 0, this is just a query for the
+	 * device table size.  Otherwise, if it's smaller than the
+	 * device table size it's an error.
+	 */
+	if (user_size < dev_size)
+		return user_size == 0 ? 0 : -EINVAL;
+
+	indir = kcalloc(dev_size, sizeof(indir[0]), GFP_USER);
 	if (!indir)
 		return -ENOMEM;
 
-	indir->cmd = ETHTOOL_GRXFHINDIR;
-	indir->size = table_size;
 	ret = dev->ethtool_ops->get_rxfh_indir(dev, indir);
 	if (ret)
 		goto out;
 
-	if (copy_to_user(useraddr, indir, full_size))
+	if (copy_to_user(useraddr +
+			 offsetof(struct ethtool_rxfh_indir, ring_index[0]),
+			 indir, dev_size * sizeof(indir[0])))
 		ret = -EFAULT;
 
 out:
@@ -553,32 +563,51 @@ out:
 static noinline_for_stack int ethtool_set_rxfh_indir(struct net_device *dev,
 						     void __user *useraddr)
 {
-	struct ethtool_rxfh_indir *indir;
-	u32 table_size;
-	size_t full_size;
+	struct ethtool_rxnfc rx_rings;
+	u32 user_size, dev_size, i;
+	u32 *indir;
 	int ret;
 
-	if (!dev->ethtool_ops->set_rxfh_indir)
+	if (!dev->ethtool_ops->get_rxfh_indir_size ||
+	    !dev->ethtool_ops->set_rxfh_indir ||
+	    !dev->ethtool_ops->get_rxnfc)
+		return -EOPNOTSUPP;
+	dev_size = dev->ethtool_ops->get_rxfh_indir_size(dev);
+	if (dev_size == 0)
 		return -EOPNOTSUPP;
 
-	if (copy_from_user(&table_size,
+	if (copy_from_user(&user_size,
 			   useraddr + offsetof(struct ethtool_rxfh_indir, size),
-			   sizeof(table_size)))
+			   sizeof(user_size)))
 		return -EFAULT;
 
-	if (table_size >
-	    (KMALLOC_MAX_SIZE - sizeof(*indir)) / sizeof(*indir->ring_index))
-		return -ENOMEM;
-	full_size = sizeof(*indir) + sizeof(*indir->ring_index) * table_size;
-	indir = kmalloc(full_size, GFP_USER);
+	if (user_size != dev_size)
+		return -EINVAL;
+
+	indir = kcalloc(dev_size, sizeof(indir[0]), GFP_USER);
 	if (!indir)
 		return -ENOMEM;
 
-	if (copy_from_user(indir, useraddr, full_size)) {
+	if (copy_from_user(indir,
+			   useraddr +
+			   offsetof(struct ethtool_rxfh_indir, ring_index[0]),
+			   dev_size * sizeof(indir[0]))) {
 		ret = -EFAULT;
 		goto out;
 	}
 
+	/* Validate ring indices */
+	rx_rings.cmd = ETHTOOL_GRXRINGS;
+	ret = dev->ethtool_ops->get_rxnfc(dev, &rx_rings, NULL);
+	if (ret)
+		goto out;
+	for (i = 0; i < dev_size; i++) {
+		if (indir[i] >= rx_rings.data) {
+			ret = -EINVAL;
+			goto out;
+		}
+	}
+
 	ret = dev->ethtool_ops->set_rxfh_indir(dev, indir);
 
 out:
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
