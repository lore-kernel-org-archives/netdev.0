From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 1/3] r8152: move the settings of PHY to a work queue
Date: Mon, 13 Jun 2016 17:49:36 +0800
Message-ID: <1394712342-15778-176-Taiwan-albertk@realtek.com>
References: <1394712342-15778-175-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-175-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the settings of PHY to a work queue and schedule it after
rtl_ops.init().

There are some reasons for this. First, the settings are only
needed for the first time initialization or after the power
down occurs.

Second, the settings are independent with the others.

Last, the settings may take more time than the others. Leave
they in probe() or open() may delay the following flows.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 32 +++++++++++++++++++++++++++-----
 1 file changed, 27 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 161c25e..46fe9a7 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -602,7 +602,7 @@ struct r8152 {
 	struct list_head rx_done, tx_free;
 	struct sk_buff_head tx_queue, rx_queue;
 	spinlock_t rx_lock, tx_lock;
-	struct delayed_work schedule;
+	struct delayed_work schedule, hw_phy_work;
 	struct mii_if_info mii;
 	struct mutex control;	/* use for hw setting */
 #ifdef CONFIG_PM_SLEEP
@@ -619,6 +619,7 @@ struct r8152 {
 		int (*eee_get)(struct r8152 *, struct ethtool_eee *);
 		int (*eee_set)(struct r8152 *, struct ethtool_eee *);
 		bool (*in_nway)(struct r8152 *);
+		void (*hw_phy_cfg)(struct r8152 *);
 	} rtl_ops;
 
 	int intr_interval;
@@ -2499,8 +2500,6 @@ static void r8152b_exit_oob(struct r8152 *tp)
 
 	rxdy_gated_en(tp, true);
 	r8153_teredo_off(tp);
-	r8152b_hw_phy_cfg(tp);
-
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_NORAML);
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CR, 0x00);
 
@@ -2678,8 +2677,6 @@ static void r8153_first_init(struct r8152 *tp)
 	ocp_data &= ~RCR_ACPT_ALL;
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
 
-	r8153_hw_phy_cfg(tp);
-
 	rtl8152_nic_reset(tp);
 
 	ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
@@ -3040,6 +3037,25 @@ out1:
 	usb_autopm_put_interface(tp->intf);
 }
 
+static void rtl_hw_phy_work_func_t(struct work_struct *work)
+{
+	struct r8152 *tp = container_of(work, struct r8152, hw_phy_work.work);
+
+	if (test_bit(RTL8152_UNPLUG, &tp->flags))
+		return;
+
+	if (usb_autopm_get_interface(tp->intf) < 0)
+		return;
+
+	mutex_lock(&tp->control);
+
+	tp->rtl_ops.hw_phy_cfg(tp);
+
+	mutex_unlock(&tp->control);
+
+	usb_autopm_put_interface(tp->intf);
+}
+
 #ifdef CONFIG_PM_SLEEP
 static int rtl_notifier(struct notifier_block *nb, unsigned long action,
 			void *data)
@@ -3518,6 +3534,7 @@ static int rtl8152_resume(struct usb_interface *intf)
 
 	if (!test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
 		tp->rtl_ops.init(tp);
+		queue_delayed_work(system_long_wq, &tp->hw_phy_work, 0);
 		netif_device_attach(tp->netdev);
 	}
 
@@ -4122,6 +4139,7 @@ static int rtl_ops_init(struct r8152 *tp)
 		ops->eee_get		= r8152_get_eee;
 		ops->eee_set		= r8152_set_eee;
 		ops->in_nway		= rtl8152_in_nway;
+		ops->hw_phy_cfg		= r8152b_hw_phy_cfg;
 		break;
 
 	case RTL_VER_03:
@@ -4137,6 +4155,7 @@ static int rtl_ops_init(struct r8152 *tp)
 		ops->eee_get		= r8153_get_eee;
 		ops->eee_set		= r8153_set_eee;
 		ops->in_nway		= rtl8153_in_nway;
+		ops->hw_phy_cfg		= r8153_hw_phy_cfg;
 		break;
 
 	default:
@@ -4183,6 +4202,7 @@ static int rtl8152_probe(struct usb_interface *intf,
 
 	mutex_init(&tp->control);
 	INIT_DELAYED_WORK(&tp->schedule, rtl_work_func_t);
+	INIT_DELAYED_WORK(&tp->hw_phy_work, rtl_hw_phy_work_func_t);
 
 	netdev->netdev_ops = &rtl8152_netdev_ops;
 	netdev->watchdog_timeo = RTL8152_TX_TIMEOUT;
@@ -4225,6 +4245,7 @@ static int rtl8152_probe(struct usb_interface *intf,
 	intf->needs_remote_wakeup = 1;
 
 	tp->rtl_ops.init(tp);
+	queue_delayed_work(system_long_wq, &tp->hw_phy_work, 0);
 	set_ethernet_addr(tp);
 
 	usb_set_intfdata(intf, tp);
@@ -4270,6 +4291,7 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 
 		netif_napi_del(&tp->napi);
 		unregister_netdev(tp->netdev);
+		cancel_delayed_work_sync(&tp->hw_phy_work);
 		tp->rtl_ops.unload(tp);
 		free_netdev(tp->netdev);
 	}
-- 
2.4.11
