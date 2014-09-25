From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 3/3] r8152: support ethtool eee
Date: Thu, 25 Sep 2014 20:54:02 +0800
Message-ID: <1394712342-15778-49-Taiwan-albertk@realtek.com>
References: <1394712342-15778-46-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-46-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support get_eee() and set_eee() of ethtool_ops.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 128 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 128 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 887b6a2..a4d4c4a 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -131,7 +131,9 @@
 #define OCP_SRAM_ADDR		0xa436
 #define OCP_SRAM_DATA		0xa438
 #define OCP_DOWN_SPEED		0xa442
+#define OCP_EEE_ABLE		0xa5c4
 #define OCP_EEE_ADV		0xa5d0
+#define OCP_EEE_LPABLE		0xa5d2
 #define OCP_ADC_CFG		0xbc06
 
 /* SRAM Register */
@@ -572,6 +574,8 @@ struct r8152 {
 		void (*up)(struct r8152 *);
 		void (*down)(struct r8152 *);
 		void (*unload)(struct r8152 *);
+		int (*eee_get)(struct r8152 *, struct ethtool_eee *);
+		int (*eee_set)(struct r8152 *, struct ethtool_eee *);
 	} rtl_ops;
 
 	int intr_interval;
@@ -3366,6 +3370,122 @@ static void rtl8152_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 	}
 }
 
+static int r8152_get_eee(struct r8152 *tp, struct ethtool_eee *eee)
+{
+	u32 ocp_data, lp, adv, supported = 0;
+	u16 val;
+
+	val = r8152_mmd_read(tp, MDIO_MMD_PCS, MDIO_PCS_EEE_ABLE);
+	supported = mmd_eee_cap_to_ethtool_sup_t(val);
+
+	val = r8152_mmd_read(tp, MDIO_MMD_AN, MDIO_AN_EEE_ADV);
+	adv = mmd_eee_adv_to_ethtool_adv_t(val);
+
+	val = r8152_mmd_read(tp, MDIO_MMD_AN, MDIO_AN_EEE_LPABLE);
+	lp = mmd_eee_adv_to_ethtool_adv_t(val);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEE_CR);
+	ocp_data &= EEE_RX_EN | EEE_TX_EN;
+
+	eee->eee_enabled = !!ocp_data;
+	eee->eee_active = !!(supported & adv & lp);
+	eee->supported = supported;
+	eee->advertised = adv;
+	eee->lp_advertised = lp;
+
+	return 0;
+}
+
+static int r8152_set_eee(struct r8152 *tp, struct ethtool_eee *eee)
+{
+	u16 val = ethtool_adv_to_mmd_eee_adv_t(eee->advertised);
+
+	r8152_eee_en(tp, eee->eee_enabled);
+
+	if (!eee->eee_enabled)
+		val = 0;
+
+	r8152_mmd_write(tp, MDIO_MMD_AN, MDIO_AN_EEE_ADV, val);
+
+	return 0;
+}
+
+static int r8153_get_eee(struct r8152 *tp, struct ethtool_eee *eee)
+{
+	u32 ocp_data, lp, adv, supported = 0;
+	u16 val;
+
+	val = ocp_reg_read(tp, OCP_EEE_ABLE);
+	supported = mmd_eee_cap_to_ethtool_sup_t(val);
+
+	val = ocp_reg_read(tp, OCP_EEE_ADV);
+	adv = mmd_eee_adv_to_ethtool_adv_t(val);
+
+	val = ocp_reg_read(tp, OCP_EEE_LPABLE);
+	lp = mmd_eee_adv_to_ethtool_adv_t(val);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEE_CR);
+	ocp_data &= EEE_RX_EN | EEE_TX_EN;
+
+	eee->eee_enabled = !!ocp_data;
+	eee->eee_active = !!(supported & adv & lp);
+	eee->supported = supported;
+	eee->advertised = adv;
+	eee->lp_advertised = lp;
+
+	return 0;
+}
+
+static int r8153_set_eee(struct r8152 *tp, struct ethtool_eee *eee)
+{
+	u16 val = ethtool_adv_to_mmd_eee_adv_t(eee->advertised);
+
+	r8153_eee_en(tp, eee->eee_enabled);
+
+	if (!eee->eee_enabled)
+		val = 0;
+
+	ocp_reg_write(tp, OCP_EEE_ADV, val);
+
+	return 0;
+}
+
+static int
+rtl_ethtool_get_eee(struct net_device *net, struct ethtool_eee *edata)
+{
+	struct r8152 *tp = netdev_priv(net);
+	int ret;
+
+	ret = usb_autopm_get_interface(tp->intf);
+	if (ret < 0)
+		goto out;
+
+	ret = tp->rtl_ops.eee_get(tp, edata);
+
+	usb_autopm_put_interface(tp->intf);
+
+out:
+	return ret;
+}
+
+static int
+rtl_ethtool_set_eee(struct net_device *net, struct ethtool_eee *edata)
+{
+	struct r8152 *tp = netdev_priv(net);
+	int ret;
+
+	ret = usb_autopm_get_interface(tp->intf);
+	if (ret < 0)
+		goto out;
+
+	ret = tp->rtl_ops.eee_set(tp, edata);
+
+	usb_autopm_put_interface(tp->intf);
+
+out:
+	return ret;
+}
+
 static struct ethtool_ops ops = {
 	.get_drvinfo = rtl8152_get_drvinfo,
 	.get_settings = rtl8152_get_settings,
@@ -3378,6 +3498,8 @@ static struct ethtool_ops ops = {
 	.get_strings = rtl8152_get_strings,
 	.get_sset_count = rtl8152_get_sset_count,
 	.get_ethtool_stats = rtl8152_get_ethtool_stats,
+	.get_eee = rtl_ethtool_get_eee,
+	.set_eee = rtl_ethtool_set_eee,
 };
 
 static int rtl8152_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
@@ -3519,6 +3641,8 @@ static int rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 			ops->up			= rtl8152_up;
 			ops->down		= rtl8152_down;
 			ops->unload		= rtl8152_unload;
+			ops->eee_get		= r8152_get_eee;
+			ops->eee_set		= r8152_set_eee;
 			ret = 0;
 			break;
 		case PRODUCT_ID_RTL8153:
@@ -3528,6 +3652,8 @@ static int rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 			ops->up			= rtl8153_up;
 			ops->down		= rtl8153_down;
 			ops->unload		= rtl8153_unload;
+			ops->eee_get		= r8153_get_eee;
+			ops->eee_set		= r8153_set_eee;
 			ret = 0;
 			break;
 		default:
@@ -3544,6 +3670,8 @@ static int rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 			ops->up			= rtl8153_up;
 			ops->down		= rtl8153_down;
 			ops->unload		= rtl8153_unload;
+			ops->eee_get		= r8153_get_eee;
+			ops->eee_set		= r8153_set_eee;
 			ret = 0;
 			break;
 		default:
-- 
1.9.3
