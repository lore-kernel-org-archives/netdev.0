From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 14/19] net: hns: delete redundancy ring enable
 operations
Date: Tue, 21 Jun 2016 11:56:34 +0800
Message-ID: <1466481399-70080-15-git-send-email-Yisen.Zhuang@huawei.com>
References: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ivecera@redhat.com, andrew@lunn.ch, fengguang.wu@intel.com,
 liguozhu@huawei.com, arnd@arndb.de, charles.chenxin@huawei.com,
 linux-kernel@vger.kernel.org, linuxarm@huawei.com, geliangtang@163.com,
 huangdaode@hisilicon.com, netdev@vger.kernel.org,
 andriy.shevchenko@linux.intel.com, linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
 <yankejian@huawei.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Daode Huang <huangdaode@hisilicon.com>

When network interface is enabled, the ring enable operation is
conducted twice. This patch deletes the redundancy code of ring enable,
and integrates hnae_ae_ops.toggle_queue_status other functions to
hns_ae_start.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.c         |  1 -
 drivers/net/ethernet/hisilicon/hns/hnae.h         |  1 -
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c | 22 +++++++++-------------
 drivers/net/ethernet/hisilicon/hns/hns_enet.c     |  7 +------
 4 files changed, 10 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
index 5d3047c..c54c6fa 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.c
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
@@ -400,7 +400,6 @@ int hnae_ae_register(struct hnae_ae_dev *hdev, struct module *owner)
 
 	if (!hdev->ops || !hdev->ops->get_handle ||
 	    !hdev->ops->toggle_ring_irq ||
-	    !hdev->ops->toggle_queue_status ||
 	    !hdev->ops->get_status || !hdev->ops->adjust_link)
 		return -EINVAL;
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index 962e445..3869322 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -454,7 +454,6 @@ struct hnae_ae_ops {
 	int (*get_info)(struct hnae_handle *handle,
 			u8 *auto_neg, u16 *speed, u8 *duplex);
 	void (*toggle_ring_irq)(struct hnae_ring *ring, u32 val);
-	void (*toggle_queue_status)(struct hnae_queue *queue, u32 val);
 	void (*adjust_link)(struct hnae_handle *handle, int speed, int duplex);
 	int (*set_loopback)(struct hnae_handle *handle,
 			    enum hnae_loop loop_mode, int en);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 6b3796f..835521b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -247,12 +247,21 @@ static void hns_ae_set_tso_stats(struct hnae_handle *handle, int enable)
 static int hns_ae_start(struct hnae_handle *handle)
 {
 	int ret;
+	int k;
 	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
 
 	ret = hns_mac_vm_config_bc_en(mac_cb, 0, true);
 	if (ret)
 		return ret;
 
+	for (k = 0; k < handle->q_num; k++) {
+		if (AE_IS_VER1(mac_cb->dsaf_dev->dsaf_ver))
+			hns_rcb_int_clr_hw(handle->qs[k],
+					   RCB_INT_FLAG_TX | RCB_INT_FLAG_RX);
+		else
+			hns_rcbv2_int_clr_hw(handle->qs[k],
+					     RCB_INT_FLAG_TX | RCB_INT_FLAG_RX);
+	}
 	hns_ae_ring_enable_all(handle, 1);
 	msleep(100);
 
@@ -313,18 +322,6 @@ static void hns_aev2_toggle_ring_irq(struct hnae_ring *ring, u32 mask)
 	hns_rcbv2_int_ctrl_hw(ring->q, flag, mask);
 }
 
-static void hns_ae_toggle_queue_status(struct hnae_queue *queue, u32 val)
-{
-	struct dsaf_device *dsaf_dev = hns_ae_get_dsaf_dev(queue->dev);
-
-	if (AE_IS_VER1(dsaf_dev->dsaf_ver))
-		hns_rcb_int_clr_hw(queue, RCB_INT_FLAG_TX | RCB_INT_FLAG_RX);
-	else
-		hns_rcbv2_int_clr_hw(queue, RCB_INT_FLAG_TX | RCB_INT_FLAG_RX);
-
-	hns_rcb_start(queue, val);
-}
-
 static int hns_ae_get_link_status(struct hnae_handle *handle)
 {
 	u32 link_status;
@@ -808,7 +805,6 @@ static struct hnae_ae_ops hns_dsaf_ops = {
 	.stop = hns_ae_stop,
 	.reset = hns_ae_reset,
 	.toggle_ring_irq = hns_ae_toggle_ring_irq,
-	.toggle_queue_status = hns_ae_toggle_queue_status,
 	.get_status = hns_ae_get_link_status,
 	.get_info = hns_ae_get_mac_info,
 	.adjust_link = hns_ae_adjust_link,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index cef9d12..f49246d 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1200,7 +1200,7 @@ static int hns_nic_net_up(struct net_device *ndev)
 {
 	struct hns_nic_priv *priv = netdev_priv(ndev);
 	struct hnae_handle *h = priv->ae_handle;
-	int i, j, k;
+	int i, j;
 	int ret;
 
 	ret = hns_nic_init_irq(priv);
@@ -1215,9 +1215,6 @@ static int hns_nic_net_up(struct net_device *ndev)
 			goto out_has_some_queues;
 	}
 
-	for (k = 0; k < h->q_num; k++)
-		h->dev->ops->toggle_queue_status(h->qs[k], 1);
-
 	ret = h->dev->ops->set_mac_addr(h, ndev->dev_addr);
 	if (ret)
 		goto out_set_mac_addr_err;
@@ -1237,8 +1234,6 @@ static int hns_nic_net_up(struct net_device *ndev)
 out_start_err:
 	netif_stop_queue(ndev);
 out_set_mac_addr_err:
-	for (k = 0; k < h->q_num; k++)
-		h->dev->ops->toggle_queue_status(h->qs[k], 0);
 out_has_some_queues:
 	for (j = i - 1; j >= 0; j--)
 		hns_nic_ring_close(ndev, j);
-- 
1.9.1
