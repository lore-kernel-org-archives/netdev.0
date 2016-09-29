From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 for-next 5/8] net: hns: fix port not available after testing loopback
Date: Thu, 29 Sep 2016 18:09:13 +0100
Message-ID: <20160929170916.631972-6-salil.mehta@huawei.com>
References: <20160929170916.631972-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <xavier.huwei@huawei.com>, <oulijun@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <linux-rdma@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, Kejian Yan <yankejian@huawei.com>
To: <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160929170916.631972-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

After running command "ethtool -t eth0", eth0 can not be connected to
network. It is caused by the changing the inner loopback register and
this register cannot be changed when hns connected to network. The
routine of setting this register needs to be removed and using promisc
mode to let the packet looped back pass by dsaf mode.

Reported-by: Jun He <hjat2005@huawei.com>
Signed-off-by: Kejian Yan <yankejian@huawei.com>
Reviewed-by: Yisen Zhaung <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |    3 ---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   10 ----------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |    1 -
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   |    7 +++++++
 4 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index e28d960..e0f9cdc 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -678,9 +678,6 @@ static int hns_ae_config_loopback(struct hnae_handle *handle,
 		ret = -EINVAL;
 	}
 
-	if (!ret)
-		hns_dsaf_set_inner_lb(mac_cb->dsaf_dev, mac_cb->mac_id, en);
-
 	return ret;
 }
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 9283bc6..827d8fb 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -768,16 +768,6 @@ void hns_dsaf_set_promisc_mode(struct dsaf_device *dsaf_dev, u32 en)
 				 DSAF_CFG_MIX_MODE_S, !!en);
 }
 
-void hns_dsaf_set_inner_lb(struct dsaf_device *dsaf_dev, u32 mac_id, u32 en)
-{
-	if (AE_IS_VER1(dsaf_dev->dsaf_ver) ||
-	    dsaf_dev->mac_cb[mac_id]->mac_type == HNAE_PORT_DEBUG)
-		return;
-
-	dsaf_set_dev_bit(dsaf_dev, DSAFV2_SERDES_LBK_0_REG + 4 * mac_id,
-			 DSAFV2_SERDES_LBK_EN_B, !!en);
-}
-
 /**
  * hns_dsaf_tbl_stat_en - tbl
  * @dsaf_id: dsa fabric id
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index 35df187..c494fc5 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -466,6 +466,5 @@ void hns_dsaf_get_rx_mac_pause_en(struct dsaf_device *dsaf_dev, int mac_id,
 				  u32 *en);
 int hns_dsaf_set_rx_mac_pause_en(struct dsaf_device *dsaf_dev, int mac_id,
 				 u32 en);
-void hns_dsaf_set_inner_lb(struct dsaf_device *dsaf_dev, u32 mac_id, u32 en);
 
 #endif /* __HNS_DSAF_MAIN_H__ */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index ab33487..fa91ce3 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -342,6 +342,13 @@ static int __lb_setup(struct net_device *ndev,
 		break;
 	}
 
+	if (!ret) {
+		if (loop == MAC_LOOP_NONE)
+			h->dev->ops->set_promisc_mode(
+				h, ndev->flags & IFF_PROMISC);
+		else
+			h->dev->ops->set_promisc_mode(h, 1);
+	}
 	return ret;
 }
 
-- 
1.7.9.5
