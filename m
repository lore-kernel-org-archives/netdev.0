From: Lisheng <lisheng011@huawei.com>
Subject: [PATCH net 3/3] net: hns: fixed set-coalesce-usecs return void bug
Date: Fri, 4 Mar 2016 12:38:16 +0800
Message-ID: <1457066296-66202-4-git-send-email-lisheng011@huawei.com>
References: <1457066296-66202-1-git-send-email-lisheng011@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei@huawei.com>, <kenneth-lee-2012@foxmail.com>,
	<xuwei5@hisilicon.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <liguozhu@huawei.com>,
	<huangdaode@hisilicon.com>, <lisheng011@huawei.com>,
	<yankejian@huawei.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<chenny.xu@huawei.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457066296-66202-1-git-send-email-lisheng011@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Seting coalesce time maybe return err,
and ethtool should process the err.

Signed-off-by: Lisheng <lisheng011@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.h         | 2 +-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c | 6 +++---
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c  | 6 ++++--
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index 1cbcb9f..f622899 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -467,7 +467,7 @@ struct hnae_ae_ops {
 				   u32 *tx_usecs, u32 *rx_usecs);
 	void (*get_rx_max_coalesced_frames)(struct hnae_handle *handle,
 					    u32 *tx_frames, u32 *rx_frames);
-	void (*set_coalesce_usecs)(struct hnae_handle *handle, u32 timeout);
+	int (*set_coalesce_usecs)(struct hnae_handle *handle, u32 timeout);
 	int (*set_coalesce_frames)(struct hnae_handle *handle,
 				   u32 coalesce_frames);
 	void (*set_promisc_mode)(struct hnae_handle *handle, u32 en);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 4d657f5..487d6e2 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -465,13 +465,13 @@ static void hns_ae_get_rx_max_coalesced_frames(struct hnae_handle *handle,
 						  ring_pair->port_id_in_comm);
 }
 
-static void hns_ae_set_coalesce_usecs(struct hnae_handle *handle,
-				      u32 timeout)
+static int hns_ae_set_coalesce_usecs(struct hnae_handle *handle,
+				     u32 timeout)
 {
 	struct ring_pair_cb *ring_pair =
 		container_of(handle->qs[0], struct ring_pair_cb, q);
 
-	(void)hns_rcb_set_coalesce_usecs(
+	return hns_rcb_set_coalesce_usecs(
 		ring_pair->rcb_common, ring_pair->port_id_in_comm, timeout);
 }
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 3df2284..4086e91 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -781,8 +781,10 @@ static int hns_set_coalesce(struct net_device *net_dev,
 	    (!ops->set_coalesce_frames))
 		return -ESRCH;
 
-	ops->set_coalesce_usecs(priv->ae_handle,
-					ec->rx_coalesce_usecs);
+	ret = ops->set_coalesce_usecs(priv->ae_handle,
+				      ec->rx_coalesce_usecs);
+	if (ret)
+		return ret;
 
 	ret = ops->set_coalesce_frames(
 		priv->ae_handle,
-- 
1.9.1
