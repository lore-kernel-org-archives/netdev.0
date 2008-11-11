From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes for 2.6.28-rc
Date: Tue, 11 Nov 2008 03:58:30 -0500
Message-ID: <20081111085830.GA24681@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:59579 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755974AbYKKI6c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 03:58:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'davem-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes

to receive the following updates:

 drivers/infiniband/hw/cxgb3/iwch_provider.c |    6 ------
 drivers/net/cxgb3/cxgb3_main.c              |    4 +++-
 drivers/net/cxgb3/t3_hw.c                   |    8 +++++++-
 drivers/net/myri10ge/myri10ge.c             |    4 +++-
 drivers/net/smc911x.c                       |    4 +++-
 5 files changed, 16 insertions(+), 10 deletions(-)

Brice Goglin (1):
      myri10ge: fix stop/go ordering even more

Dasgupta, Romit (1):
      [netdrvr] smc911x: fix for driver resume (and compilation warning)

Divy Le Ray (2):
      cxgb3 - eeprom read fixes
      cxgb3 - Limit multiqueue setting to msi-x

Steve Wise (1):
      RDMA/cxgb3: deadlock in iw_cxgb3 can cause hang when configuring interface.

diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c b/drivers/infiniband/hw/cxgb3/iwch_provider.c
index ecff980..160ef48 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -1102,9 +1102,7 @@ static u64 fw_vers_string_to_u64(struct iwch_dev *iwch_dev)
 	char *cp, *next;
 	unsigned fw_maj, fw_min, fw_mic;
 
-	rtnl_lock();
 	lldev->ethtool_ops->get_drvinfo(lldev, &info);
-	rtnl_unlock();
 
 	next = info.fw_version + 1;
 	cp = strsep(&next, ".");
@@ -1192,9 +1190,7 @@ static ssize_t show_fw_ver(struct device *dev, struct device_attribute *attr, ch
 	struct net_device *lldev = iwch_dev->rdev.t3cdev_p->lldev;
 
 	PDBG("%s dev 0x%p\n", __func__, dev);
-	rtnl_lock();
 	lldev->ethtool_ops->get_drvinfo(lldev, &info);
-	rtnl_unlock();
 	return sprintf(buf, "%s\n", info.fw_version);
 }
 
@@ -1207,9 +1203,7 @@ static ssize_t show_hca(struct device *dev, struct device_attribute *attr,
 	struct net_device *lldev = iwch_dev->rdev.t3cdev_p->lldev;
 
 	PDBG("%s dev 0x%p\n", __func__, dev);
-	rtnl_lock();
 	lldev->ethtool_ops->get_drvinfo(lldev, &info);
-	rtnl_unlock();
 	return sprintf(buf, "%s\n", info.driver);
 }
 
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 1ace41a..2c341f8 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1307,8 +1307,10 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 	u32 fw_vers = 0;
 	u32 tp_vers = 0;
 
+	spin_lock(&adapter->stats_lock);
 	t3_get_fw_version(adapter, &fw_vers);
 	t3_get_tp_version(adapter, &tp_vers);
+	spin_unlock(&adapter->stats_lock);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -2699,7 +2701,7 @@ static void set_nqsets(struct adapter *adap)
 	int hwports = adap->params.nports;
 	int nqsets = SGE_QSETS;
 
-	if (adap->params.rev > 0) {
+	if (adap->params.rev > 0 && adap->flags & USING_MSIX) {
 		if (hwports == 2 &&
 		    (hwports * nqsets > SGE_QSETS ||
 		     num_cpus >= nqsets / hwports))
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 968f64b..9a0898b 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -572,7 +572,7 @@ struct t3_vpd {
 	u32 pad;		/* for multiple-of-4 sizing and alignment */
 };
 
-#define EEPROM_MAX_POLL   4
+#define EEPROM_MAX_POLL   40
 #define EEPROM_STAT_ADDR  0x4000
 #define VPD_BASE          0xc00
 
@@ -3690,6 +3690,12 @@ int t3_prep_adapter(struct adapter *adapter, const struct adapter_info *ai,
 			;
 
 		pti = &port_types[adapter->params.vpd.port_type[j]];
+		if (!pti->phy_prep) {
+			CH_ALERT(adapter, "Invalid port type index %d\n",
+				 adapter->params.vpd.port_type[j]);
+			return -EINVAL;
+		}
+
 		ret = pti->phy_prep(&p->phy, adapter, ai->phy_base_addr + j,
 				    ai->mdio_ops);
 		if (ret)
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index a5f428b..b378670 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.4.3-1.375"
+#define MYRI10GE_VERSION_STR "1.4.3-1.378"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -1393,6 +1393,7 @@ myri10ge_tx_done(struct myri10ge_slice_state *ss, int mcp_index)
 		if (tx->req == tx->done) {
 			tx->queue_active = 0;
 			put_be32(htonl(1), tx->send_stop);
+			mb();
 			mmiowb();
 		}
 		__netif_tx_unlock(dev_queue);
@@ -2865,6 +2866,7 @@ again:
 	if ((mgp->dev->real_num_tx_queues > 1) && tx->queue_active == 0) {
 		tx->queue_active = 1;
 		put_be32(htonl(1), tx->send_go);
+		mb();
 		mmiowb();
 	}
 	tx->pkt_start++;
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 5051554..1f26ab0 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -2050,7 +2050,9 @@ err_out:
  */
 static int smc911x_drv_probe(struct platform_device *pdev)
 {
+#ifdef SMC_DYNAMIC_BUS_CONFIG
 	struct smc911x_platdata *pd = pdev->dev.platform_data;
+#endif
 	struct net_device *ndev;
 	struct resource *res;
 	struct smc911x_local *lp;
@@ -2182,9 +2184,9 @@ static int smc911x_drv_resume(struct platform_device *dev)
 
 		if (netif_running(ndev)) {
 			smc911x_reset(ndev);
-			smc911x_enable(ndev);
 			if (lp->phy_type != 0)
 				smc911x_phy_configure(&lp->phy_configure);
+			smc911x_enable(ndev);
 			netif_device_attach(ndev);
 		}
 	}
