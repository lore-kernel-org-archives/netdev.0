From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 3/5] cxgb4: add user manipulation of the RSS table
Date: Sun, 11 Jul 2010 15:01:17 -0700
Message-ID: <1278885679-3738-4-git-send-email-dm@chelsio.com>
References: <1278885679-3738-1-git-send-email-dm@chelsio.com>
 <1278885679-3738-2-git-send-email-dm@chelsio.com>
 <1278885679-3738-3-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:17332 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755207Ab0GKWBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 18:01:20 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o6BM1KVT021629
	for <netdev@vger.kernel.org>; Sun, 11 Jul 2010 15:01:20 -0700
In-Reply-To: <1278885679-3738-3-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the get_rxnfc, get_rxfh_indir, and set_rxfh_indir ethtool
methods for user manipulation of the RSS table.  Besides the methods
themselves the rest of the changes here store, initialize, and write
the table contents.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4.h      |    1 +
 drivers/net/cxgb4/cxgb4_main.c |  113 ++++++++++++++++++++++++++++++++++------
 2 files changed, 98 insertions(+), 16 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index 62804bb..a614eb5 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -295,6 +295,7 @@ struct port_info {
 	u8     nqsets;                /* # of qsets */
 	u8     first_qset;            /* index of first qset */
 	struct link_config link_cfg;
+	u16   *rss;
 };
 
 /* port_info.rx_offload flags */
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 653bb54..61d4313 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -597,30 +597,47 @@ static void free_msix_queue_irqs(struct adapter *adap)
 }
 
 /**
+ *	write_rss - write the RSS table for a given port
+ *	@pi: the port
+ *	@queues: array of queue indices for RSS
+ *
+ *	Sets up the portion of the HW RSS table for the port's VI to distribute
+ *	packets to the Rx queues in @queues.
+ */
+static int write_rss(const struct port_info *pi, const u16 *queues)
+{
+	u16 *rss;
+	int i, err;
+	const struct sge_eth_rxq *q = &pi->adapter->sge.ethrxq[pi->first_qset];
+
+	rss = kmalloc(pi->rss_size * sizeof(u16), GFP_KERNEL);
+	if (!rss)
+		return -ENOMEM;
+
+	/* map the queue indices to queue ids */
+	for (i = 0; i < pi->rss_size; i++, queues++)
+		rss[i] = q[*queues].rspq.abs_id;
+
+	err = t4_config_rss_range(pi->adapter, 0, pi->viid, 0, pi->rss_size,
+				  rss, pi->rss_size);
+	kfree(rss);
+	return err;
+}
+
+/**
  *	setup_rss - configure RSS
  *	@adap: the adapter
  *
- *	Sets up RSS to distribute packets to multiple receive queues.  We
- *	configure the RSS CPU lookup table to distribute to the number of HW
- *	receive queues, and the response queue lookup table to narrow that
- *	down to the response queues actually configured for each port.
- *	We always configure the RSS mapping for all ports since the mapping
- *	table has plenty of entries.
+ *	Sets up RSS for each port.
  */
 static int setup_rss(struct adapter *adap)
 {
-	int i, j, err;
-	u16 rss[MAX_ETH_QSETS];
+	int i, err;
 
 	for_each_port(adap, i) {
 		const struct port_info *pi = adap2pinfo(adap, i);
-		const struct sge_eth_rxq *q = &adap->sge.ethrxq[pi->first_qset];
-
-		for (j = 0; j < pi->nqsets; j++)
-			rss[j] = q[j].rspq.abs_id;
 
-		err = t4_config_rss_range(adap, 0, pi->viid, 0, pi->rss_size,
-					  rss, pi->nqsets);
+		err = write_rss(pi, pi->rss);
 		if (err)
 			return err;
 	}
@@ -1802,6 +1819,46 @@ static int set_flags(struct net_device *dev, u32 flags)
 	return ethtool_op_set_flags(dev, flags, ETH_FLAG_RXHASH);
 }
 
+static int get_rss_table(struct net_device *dev, struct ethtool_rxfh_indir *p)
+{
+	const struct port_info *pi = netdev_priv(dev);
+	unsigned int n = min_t(unsigned int, p->size, pi->rss_size);
+
+	p->size = pi->rss_size;
+	while (n--)
+		p->ring_index[n] = pi->rss[n];
+	return 0;
+}
+
+static int set_rss_table(struct net_device *dev,
+			 const struct ethtool_rxfh_indir *p)
+{
+	unsigned int i;
+	struct port_info *pi = netdev_priv(dev);
+
+	if (p->size != pi->rss_size)
+		return -EINVAL;
+	for (i = 0; i < p->size; i++)
+		if (p->ring_index[i] >= pi->nqsets)
+			return -EINVAL;
+	for (i = 0; i < p->size; i++)
+		pi->rss[i] = p->ring_index[i];
+	if (pi->adapter->flags & FULL_INIT_DONE)
+		return write_rss(pi, pi->rss);
+	return 0;
+}
+
+static int get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
+		     void *rules)
+{
+	switch (info->cmd) {
+	case ETHTOOL_GRXRINGS:
+		info->data = netdev2pinfo(dev)->nqsets;
+		return 0;
+	}
+	return -EOPNOTSUPP;
+}
+
 static struct ethtool_ops cxgb_ethtool_ops = {
 	.get_settings      = get_settings,
 	.set_settings      = set_settings,
@@ -1833,6 +1890,9 @@ static struct ethtool_ops cxgb_ethtool_ops = {
 	.set_wol           = set_wol,
 	.set_tso           = set_tso,
 	.set_flags         = set_flags,
+	.get_rxnfc         = get_rxnfc,
+	.get_rxfh_indir    = get_rss_table,
+	.set_rxfh_indir    = set_rss_table,
 	.flash_device      = set_flash,
 };
 
@@ -3318,6 +3378,22 @@ static int __devinit enable_msix(struct adapter *adap)
 
 #undef EXTRA_VECS
 
+static int __devinit init_rss(struct adapter *adap)
+{
+	unsigned int i, j;
+
+	for_each_port(adap, i) {
+		struct port_info *pi = adap2pinfo(adap, i);
+
+		pi->rss = kcalloc(pi->rss_size, sizeof(u16), GFP_KERNEL);
+		if (!pi->rss)
+			return -ENOMEM;
+		for (j = 0; j < pi->rss_size; j++)
+			pi->rss[j] = j % pi->nqsets;
+	}
+	return 0;
+}
+
 static void __devinit print_port_info(struct adapter *adap)
 {
 	static const char *base[] = {
@@ -3380,9 +3456,10 @@ static void free_some_resources(struct adapter *adapter)
 	disable_msi(adapter);
 
 	for_each_port(adapter, i)
-		if (adapter->port[i])
+		if (adapter->port[i]) {
+			kfree(adap2pinfo(adapter, i)->rss);
 			free_netdev(adapter->port[i]);
-
+		}
 	if (adapter->flags & FW_OK)
 		t4_fw_bye(adapter, 0);
 }
@@ -3536,6 +3613,10 @@ static int __devinit init_one(struct pci_dev *pdev,
 	else if (msi > 0 && pci_enable_msi(pdev) == 0)
 		adapter->flags |= USING_MSI;
 
+	err = init_rss(adapter);
+	if (err)
+		goto out_free_dev;
+
 	/*
 	 * The card is now ready to go.  If any errors occur during device
 	 * registration we do not fail the whole card but rather proceed only
-- 
1.5.4

