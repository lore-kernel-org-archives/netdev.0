From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 50/58] net: hns: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:34 -0700
Message-ID: <1508200182-104605-51-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        lipeng <lipeng321@huawei.com>,
        Lin Yun Sheng <linyunsheng@huawei.com>,
        Kejian Yan <yankejian@huawei.com>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly. Switches test of .data field to
.function, since .data will be going away.

Cc: Yisen Zhuang <yisen.zhuang@huawei.com>
Cc: Salil Mehta <salil.mehta@huawei.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: lipeng <lipeng321@huawei.com>
Cc: Lin Yun Sheng <linyunsheng@huawei.com>
Cc: Kejian Yan <yankejian@huawei.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c           |  7 +++----
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c | 13 ++++++-------
 2 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 36520634c96a..91565c8fee08 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -2159,9 +2159,9 @@ static void hns_nic_task_schedule(struct hns_nic_priv *priv)
 		(void)schedule_work(&priv->service_task);
 }
 
-static void hns_nic_service_timer(unsigned long data)
+static void hns_nic_service_timer(struct timer_list *t)
 {
-	struct hns_nic_priv *priv = (struct hns_nic_priv *)data;
+	struct hns_nic_priv *priv = from_timer(priv, t, service_timer);
 
 	(void)mod_timer(&priv->service_timer, jiffies + SERVICE_TIMER_HZ);
 
@@ -2451,8 +2451,7 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 	/* carrier off reporting is important to ethtool even BEFORE open */
 	netif_carrier_off(ndev);
 
-	setup_timer(&priv->service_timer, hns_nic_service_timer,
-		    (unsigned long)priv);
+	timer_setup(&priv->service_timer, hns_nic_service_timer, 0);
 	INIT_WORK(&priv->service_task, hns_nic_service_task);
 
 	set_bit(NIC_STATE_SERVICE_INITED, &priv->state);
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
index c322b4534148..6e93943c489a 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_main.c
@@ -2350,11 +2350,11 @@ static int hclge_get_status(struct hnae3_handle *handle)
 	return hdev->hw.mac.link;
 }
 
-static void hclge_service_timer(unsigned long data)
+static void hclge_service_timer(struct timer_list *t)
 {
-	struct hclge_dev *hdev = (struct hclge_dev *)data;
-	(void)mod_timer(&hdev->service_timer, jiffies + HZ);
+	struct hclge_dev *hdev = from_timer(hdev, t, service_timer);
 
+	mod_timer(&hdev->service_timer, jiffies + HZ);
 	hclge_task_schedule(hdev);
 }
 
@@ -3204,7 +3204,7 @@ static int hclge_ae_start(struct hnae3_handle *handle)
 	/* mac enable */
 	hclge_cfg_mac_mode(hdev, true);
 	clear_bit(HCLGE_STATE_DOWN, &hdev->state);
-	(void)mod_timer(&hdev->service_timer, jiffies + HZ);
+	mod_timer(&hdev->service_timer, jiffies + HZ);
 
 	ret = hclge_mac_start_phy(hdev);
 	if (ret)
@@ -4436,8 +4436,7 @@ static int hclge_init_ae_dev(struct hnae3_ae_dev *ae_dev)
 
 	hclge_dcb_ops_set(hdev);
 
-	setup_timer(&hdev->service_timer, hclge_service_timer,
-		    (unsigned long)hdev);
+	timer_setup(&hdev->service_timer, hclge_service_timer, 0);
 	INIT_WORK(&hdev->service_task, hclge_service_task);
 
 	set_bit(HCLGE_STATE_SERVICE_INITED, &hdev->state);
@@ -4464,7 +4463,7 @@ static void hclge_uninit_ae_dev(struct hnae3_ae_dev *ae_dev)
 	if (IS_ENABLED(CONFIG_PCI_IOV))
 		hclge_disable_sriov(hdev);
 
-	if (hdev->service_timer.data)
+	if (hdev->service_timer.function)
 		del_timer_sync(&hdev->service_timer);
 	if (hdev->service_task.func)
 		cancel_work_sync(&hdev->service_task);
-- 
2.7.4
