From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next v2 3/3] r8152: add mutex for hw settings
Date: Thu, 9 Oct 2014 18:00:26 +0800
Message-ID: <1394712342-15778-63-Taiwan-albertk@realtek.com>
References: <1394712342-15778-58-Taiwan-albertk@realtek.com>
 <1394712342-15778-60-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-60-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use the mutex to avoid the settings are interrupted by other ones.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 64 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 63 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 1d2fc8e..864159e 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -26,7 +26,7 @@
 #include <linux/mdio.h>
 
 /* Version Information */
-#define DRIVER_VERSION "v1.06.1 (2014/10/01)"
+#define DRIVER_VERSION "v1.07.0 (2014/10/09)"
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>"
 #define DRIVER_DESC "Realtek RTL8152/RTL8153 Based USB Ethernet Adapters"
 #define MODULENAME "r8152"
@@ -566,6 +566,7 @@ struct r8152 {
 	spinlock_t rx_lock, tx_lock;
 	struct delayed_work schedule;
 	struct mii_if_info mii;
+	struct mutex control;	/* use for hw setting */
 
 	struct rtl_ops {
 		void (*init)(struct r8152 *);
@@ -977,12 +978,16 @@ static int rtl8152_set_mac_address(struct net_device *netdev, void *p)
 	if (ret < 0)
 		goto out1;
 
+	mutex_lock(&tp->control);
+
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_CONFIG);
 	pla_ocp_write(tp, PLA_IDR, BYTE_EN_SIX_BYTES, 8, addr->sa_data);
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_NORAML);
 
+	mutex_unlock(&tp->control);
+
 	usb_autopm_put_interface(tp->intf);
 out1:
 	return ret;
@@ -2139,6 +2144,8 @@ static int rtl8152_set_features(struct net_device *dev,
 	if (ret < 0)
 		goto out;
 
+	mutex_lock(&tp->control);
+
 	if (changed & NETIF_F_HW_VLAN_CTAG_RX) {
 		if (features & NETIF_F_HW_VLAN_CTAG_RX)
 			rtl_rx_vlan_en(tp, true);
@@ -2146,6 +2153,8 @@ static int rtl8152_set_features(struct net_device *dev,
 			rtl_rx_vlan_en(tp, false);
 	}
 
+	mutex_unlock(&tp->control);
+
 	usb_autopm_put_interface(tp->intf);
 
 out:
@@ -2847,6 +2856,11 @@ static void rtl_work_func_t(struct work_struct *work)
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		goto out1;
 
+	if (!mutex_trylock(&tp->control)) {
+		schedule_delayed_work(&tp->schedule, 0);
+		goto out1;
+	}
+
 	if (test_bit(RTL8152_LINK_CHG, &tp->flags))
 		set_carrier(tp);
 
@@ -2862,6 +2876,8 @@ static void rtl_work_func_t(struct work_struct *work)
 	if (test_bit(PHY_RESET, &tp->flags))
 		rtl_phy_reset(tp);
 
+	mutex_unlock(&tp->control);
+
 out1:
 	usb_autopm_put_interface(tp->intf);
 }
@@ -2881,6 +2897,8 @@ static int rtl8152_open(struct net_device *netdev)
 		goto out;
 	}
 
+	mutex_lock(&tp->control);
+
 	/* The WORK_ENABLE may be set when autoresume occurs */
 	if (test_bit(WORK_ENABLE, &tp->flags)) {
 		clear_bit(WORK_ENABLE, &tp->flags);
@@ -2909,6 +2927,8 @@ static int rtl8152_open(struct net_device *netdev)
 		free_all_mem(tp);
 	}
 
+	mutex_unlock(&tp->control);
+
 	usb_autopm_put_interface(tp->intf);
 
 out:
@@ -2929,6 +2949,8 @@ static int rtl8152_close(struct net_device *netdev)
 	if (res < 0) {
 		rtl_drop_queued_tx(tp);
 	} else {
+		mutex_lock(&tp->control);
+
 		/* The autosuspend may have been enabled and wouldn't
 		 * be disable when autoresume occurs, because the
 		 * netif_running() would be false.
@@ -2941,6 +2963,9 @@ static int rtl8152_close(struct net_device *netdev)
 		tasklet_disable(&tp->tl);
 		tp->rtl_ops.down(tp);
 		tasklet_enable(&tp->tl);
+
+		mutex_unlock(&tp->control);
+
 		usb_autopm_put_interface(tp->intf);
 	}
 
@@ -3165,6 +3190,8 @@ static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
 
+	mutex_lock(&tp->control);
+
 	if (PMSG_IS_AUTO(message))
 		set_bit(SELECTIVE_SUSPEND, &tp->flags);
 	else
@@ -3184,6 +3211,8 @@ static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 		tasklet_enable(&tp->tl);
 	}
 
+	mutex_unlock(&tp->control);
+
 	return 0;
 }
 
@@ -3191,6 +3220,8 @@ static int rtl8152_resume(struct usb_interface *intf)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
 
+	mutex_lock(&tp->control);
+
 	if (!test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
 		tp->rtl_ops.init(tp);
 		netif_device_attach(tp->netdev);
@@ -3216,6 +3247,8 @@ static int rtl8152_resume(struct usb_interface *intf)
 		usb_submit_urb(tp->intr_urb, GFP_KERNEL);
 	}
 
+	mutex_unlock(&tp->control);
+
 	return 0;
 }
 
@@ -3226,9 +3259,13 @@ static void rtl8152_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	if (usb_autopm_get_interface(tp->intf) < 0)
 		return;
 
+	mutex_lock(&tp->control);
+
 	wol->supported = WAKE_ANY;
 	wol->wolopts = __rtl_get_wol(tp);
 
+	mutex_unlock(&tp->control);
+
 	usb_autopm_put_interface(tp->intf);
 }
 
@@ -3241,9 +3278,13 @@ static int rtl8152_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	if (ret < 0)
 		goto out_set_wol;
 
+	mutex_lock(&tp->control);
+
 	__rtl_set_wol(tp, wol->wolopts);
 	tp->saved_wolopts = wol->wolopts & WAKE_ANY;
 
+	mutex_unlock(&tp->control);
+
 	usb_autopm_put_interface(tp->intf);
 
 out_set_wol:
@@ -3287,8 +3328,12 @@ int rtl8152_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 	if (ret < 0)
 		goto out;
 
+	mutex_lock(&tp->control);
+
 	ret = mii_ethtool_gset(&tp->mii, cmd);
 
+	mutex_unlock(&tp->control);
+
 	usb_autopm_put_interface(tp->intf);
 
 out:
@@ -3304,8 +3349,12 @@ static int rtl8152_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (ret < 0)
 		goto out;
 
+	mutex_lock(&tp->control);
+
 	ret = rtl8152_set_speed(tp, cmd->autoneg, cmd->speed, cmd->duplex);
 
+	mutex_unlock(&tp->control);
+
 	usb_autopm_put_interface(tp->intf);
 
 out:
@@ -3465,8 +3514,12 @@ rtl_ethtool_get_eee(struct net_device *net, struct ethtool_eee *edata)
 	if (ret < 0)
 		goto out;
 
+	mutex_lock(&tp->control);
+
 	ret = tp->rtl_ops.eee_get(tp, edata);
 
+	mutex_unlock(&tp->control);
+
 	usb_autopm_put_interface(tp->intf);
 
 out:
@@ -3483,10 +3536,14 @@ rtl_ethtool_set_eee(struct net_device *net, struct ethtool_eee *edata)
 	if (ret < 0)
 		goto out;
 
+	mutex_lock(&tp->control);
+
 	ret = tp->rtl_ops.eee_set(tp, edata);
 	if (!ret)
 		ret = mii_nway_restart(&tp->mii);
 
+	mutex_unlock(&tp->control);
+
 	usb_autopm_put_interface(tp->intf);
 
 out:
@@ -3528,7 +3585,9 @@ static int rtl8152_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
 		break;
 
 	case SIOCGMIIREG:
+		mutex_lock(&tp->control);
 		data->val_out = r8152_mdio_read(tp, data->reg_num);
+		mutex_unlock(&tp->control);
 		break;
 
 	case SIOCSMIIREG:
@@ -3536,7 +3595,9 @@ static int rtl8152_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
 			res = -EPERM;
 			break;
 		}
+		mutex_lock(&tp->control);
 		r8152_mdio_write(tp, data->reg_num, data->val_in);
+		mutex_unlock(&tp->control);
 		break;
 
 	default:
@@ -3729,6 +3790,7 @@ static int rtl8152_probe(struct usb_interface *intf,
 		goto out;
 
 	tasklet_init(&tp->tl, bottom_half, (unsigned long)tp);
+	mutex_init(&tp->control);
 	INIT_DELAYED_WORK(&tp->schedule, rtl_work_func_t);
 
 	netdev->netdev_ops = &rtl8152_netdev_ops;
-- 
1.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
