From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 13/19] net: hns: add get_coalesce_range api for hns
Date: Tue, 21 Jun 2016 11:56:33 +0800
Message-ID: <1466481399-70080-14-git-send-email-Yisen.Zhuang@huawei.com>
References: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@huawei.com>, <huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<geliangtang@163.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>, <charles.chenxin@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <yankejian@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

This patch adds get_coalesce_range api for hns, it shows
range of coalesce usecs and frames that can be set on
this interface.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.h         |  5 +++++
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c | 25 +++++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c  | 10 +++++++++
 3 files changed, 40 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index 529cb13..962e445 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -473,6 +473,11 @@ struct hnae_ae_ops {
 	int (*set_coalesce_usecs)(struct hnae_handle *handle, u32 timeout);
 	int (*set_coalesce_frames)(struct hnae_handle *handle,
 				   u32 coalesce_frames);
+	void (*get_coalesce_range)(struct hnae_handle *handle,
+				   u32 *tx_frames_low, u32 *rx_frames_low,
+				   u32 *tx_frames_high, u32 *rx_frames_high,
+				   u32 *tx_usecs_low, u32 *rx_usecs_low,
+				   u32 *tx_usecs_high, u32 *rx_usecs_high);
 	void (*set_promisc_mode)(struct hnae_handle *handle, u32 en);
 	int (*get_mac_addr)(struct hnae_handle *handle, void **p);
 	int (*set_mac_addr)(struct hnae_handle *handle, void *p);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index b97cc75..6b3796f 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -465,6 +465,30 @@ static int  hns_ae_set_coalesce_frames(struct hnae_handle *handle,
 		ring_pair->port_id_in_comm, coalesce_frames);
 }
 
+static void hns_ae_get_coalesce_range(struct hnae_handle *handle,
+				      u32 *tx_frames_low, u32 *rx_frames_low,
+				      u32 *tx_frames_high, u32 *rx_frames_high,
+				      u32 *tx_usecs_low, u32 *rx_usecs_low,
+				      u32 *tx_usecs_high, u32 *rx_usecs_high)
+{
+	struct dsaf_device *dsaf_dev;
+
+	dsaf_dev = hns_ae_get_dsaf_dev(handle->dev);
+
+	*tx_frames_low  = HNS_RCB_MIN_COALESCED_FRAMES;
+	*rx_frames_low  = HNS_RCB_MIN_COALESCED_FRAMES;
+	*tx_frames_high =
+		(dsaf_dev->desc_num - 1 > HNS_RCB_MAX_COALESCED_FRAMES) ?
+		HNS_RCB_MAX_COALESCED_FRAMES : dsaf_dev->desc_num - 1;
+	*rx_frames_high =
+		(dsaf_dev->desc_num - 1 > HNS_RCB_MAX_COALESCED_FRAMES) ?
+		 HNS_RCB_MAX_COALESCED_FRAMES : dsaf_dev->desc_num - 1;
+	*tx_usecs_low   = 0;
+	*rx_usecs_low   = 0;
+	*tx_usecs_high  = HNS_RCB_MAX_COALESCED_USECS;
+	*rx_usecs_high  = HNS_RCB_MAX_COALESCED_USECS;
+}
+
 void hns_ae_update_stats(struct hnae_handle *handle,
 			 struct net_device_stats *net_stats)
 {
@@ -798,6 +822,7 @@ static struct hnae_ae_ops hns_dsaf_ops = {
 	.get_rx_max_coalesced_frames = hns_ae_get_rx_max_coalesced_frames,
 	.set_coalesce_usecs = hns_ae_set_coalesce_usecs,
 	.set_coalesce_frames = hns_ae_set_coalesce_frames,
+	.get_coalesce_range = hns_ae_get_coalesce_range,
 	.set_promisc_mode = hns_ae_set_promisc_mode,
 	.set_mac_addr = hns_ae_set_mac_address,
 	.set_mc_addr = hns_ae_set_multicast_one,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 564ae1e..a395ca1 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -751,6 +751,16 @@ static int hns_get_coalesce(struct net_device *net_dev,
 		&ec->tx_max_coalesced_frames,
 		&ec->rx_max_coalesced_frames);
 
+	ops->get_coalesce_range(priv->ae_handle,
+				&ec->tx_max_coalesced_frames_low,
+				&ec->rx_max_coalesced_frames_low,
+				&ec->tx_max_coalesced_frames_high,
+				&ec->rx_max_coalesced_frames_high,
+				&ec->tx_coalesce_usecs_low,
+				&ec->rx_coalesce_usecs_low,
+				&ec->tx_coalesce_usecs_high,
+				&ec->rx_coalesce_usecs_high);
+
 	return 0;
 }
 
-- 
1.9.1
