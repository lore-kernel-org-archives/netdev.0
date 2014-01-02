From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 6/6] r8152: support RTL8153
Date: Thu, 2 Jan 2014 11:25:10 +0800
Message-ID: <1388633110-1435-1-git-send-email-hayeswang@realtek.com>
References: <1388632963-1341-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <oliver@neukum.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388632963-1341-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Support new chip RTL8153 which is the USB 3.0 giga ethernet adapter.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/cdc_ether.c |  10 +
 drivers/net/usb/r8152.c     | 615 +++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/usb/r815x.c     |   2 +-
 3 files changed, 621 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 4b1c0f3..640406a 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -486,6 +486,7 @@ static const struct driver_info wwan_info = {
 #define ZTE_VENDOR_ID		0x19D2
 #define DELL_VENDOR_ID		0x413C
 #define REALTEK_VENDOR_ID	0x0bda
+#define SAMSUNG_VENDOR_ID	0x04e8
 
 static const struct usb_device_id	products[] = {
 /* BLACKLIST !!
@@ -652,6 +653,15 @@ static const struct usb_device_id	products[] = {
 	.driver_info = 0,
 },
 
+#if defined(CONFIG_USB_RTL8152) || defined(CONFIG_USB_RTL8152_MODULE)
+/* Samsung USB Ethernet Adapters */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(SAMSUNG_VENDOR_ID, 0xa101, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+#endif
+
 /* WHITELIST!!!
  *
  * CDC Ether uses two interfaces, not necessarily consecutive.
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index bc5d569..e3d878c 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -24,7 +24,7 @@
 #include <linux/ipv6.h>
 
 /* Version Information */
-#define DRIVER_VERSION "v1.02.0 (2013/10/28)"
+#define DRIVER_VERSION "v1.03.0 (2013/12/26)"
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
 #define DRIVER_DESC "Realtek RTL8152 Based USB 2.0 Ethernet Adapters"
 #define MODULENAME "r8152"
@@ -39,15 +39,24 @@
 #define PLA_RXFIFO_CTRL2	0xc0a8
 #define PLA_FMC			0xc0b4
 #define PLA_CFG_WOL		0xc0b6
+#define PLA_TEREDO_CFG		0xc0bc
 #define PLA_MAR			0xcd00
+#define PLA_BACKUP		0xd000
 #define PAL_BDC_CR		0xd1a0
+#define PLA_TEREDO_TIMER	0xd2cc
+#define PLA_REALWOW_TIMER	0xd2e8
 #define PLA_LEDSEL		0xdd90
 #define PLA_LED_FEATURE		0xdd92
 #define PLA_PHYAR		0xde00
+#define PLA_BOOT_CTRL		0xe004
 #define PLA_GPHY_INTR_IMR	0xe022
 #define PLA_EEE_CR		0xe040
 #define PLA_EEEP_CR		0xe080
 #define PLA_MAC_PWR_CTRL	0xe0c0
+#define PLA_MAC_PWR_CTRL2	0xe0ca
+#define PLA_MAC_PWR_CTRL3	0xe0cc
+#define PLA_MAC_PWR_CTRL4	0xe0ce
+#define PLA_WDT6_CTRL		0xe428
 #define PLA_TCR0		0xe610
 #define PLA_TCR1		0xe612
 #define PLA_TXFIFO_CTRL		0xe618
@@ -73,16 +82,25 @@
 #define PLA_BP_5		0xfc32
 #define PLA_BP_6		0xfc34
 #define PLA_BP_7		0xfc36
+#define PLA_BP_EN		0xfc38
 
+#define USB_U2P3_CTRL		0xb460
 #define USB_DEV_STAT		0xb808
 #define USB_USB_CTRL		0xd406
 #define USB_PHY_CTRL		0xd408
 #define USB_TX_AGG		0xd40a
 #define USB_RX_BUF_TH		0xd40c
 #define USB_USB_TIMER		0xd428
+#define USB_RX_EARLY_AGG	0xd42c
 #define USB_PM_CTRL_STATUS	0xd432
 #define USB_TX_DMA		0xd434
+#define USB_TOLERANCE		0xd490
+#define USB_LPM_CTRL		0xd41a
 #define USB_UPS_CTRL		0xd800
+#define USB_MISC_0		0xd81a
+#define USB_POWER_CUT		0xd80a
+#define USB_AFE_CTRL2		0xd824
+#define USB_WDT11_CTRL		0xe43c
 #define USB_BP_BA		0xfc26
 #define USB_BP_0		0xfc28
 #define USB_BP_1		0xfc2a
@@ -92,6 +110,7 @@
 #define USB_BP_5		0xfc32
 #define USB_BP_6		0xfc34
 #define USB_BP_7		0xfc36
+#define USB_BP_EN		0xfc38
 
 /* OCP Registers */
 #define OCP_ALDPS_CONFIG	0x2010
@@ -101,6 +120,20 @@
 #define OCP_BASE_MII		0xa400
 #define OCP_EEE_AR		0xa41a
 #define OCP_EEE_DATA		0xa41c
+#define OCP_PHY_STATUS		0xa420
+#define OCP_POWER_CFG		0xa430
+#define OCP_EEE_CFG		0xa432
+#define OCP_SRAM_ADDR		0xa436
+#define OCP_SRAM_DATA		0xa438
+#define OCP_DOWN_SPEED		0xa442
+#define OCP_EEE_CFG2		0xa5d0
+#define OCP_ADC_CFG		0xbc06
+
+/* SRAM Register */
+#define SRAM_LPF_CFG		0x8012
+#define SRAM_10M_AMP1		0x8080
+#define SRAM_10M_AMP2		0x8082
+#define SRAM_IMPEDANCE		0x8084
 
 /* PLA_RCR */
 #define RCR_AAP			0x00000001
@@ -117,14 +150,17 @@
 #define RXFIFO_THR2_FULL	0x00000060
 #define RXFIFO_THR2_HIGH	0x00000038
 #define RXFIFO_THR2_OOB		0x0000004a
+#define RXFIFO_THR2_NORMAL	0x00a0
 
 /* PLA_RXFIFO_CTRL2 */
 #define RXFIFO_THR3_FULL	0x00000078
 #define RXFIFO_THR3_HIGH	0x00000048
 #define RXFIFO_THR3_OOB		0x0000005a
+#define RXFIFO_THR3_NORMAL	0x0110
 
 /* PLA_TXFIFO_CTRL */
 #define TXFIFO_THR_NORMAL	0x00400008
+#define TXFIFO_THR_NORMAL2	0x01000008
 
 /* PLA_FMC */
 #define FMC_FCR_MCU_EN		0x0001
@@ -132,6 +168,9 @@
 /* PLA_EEEP_CR */
 #define EEEP_CR_EEEP_TX		0x0002
 
+/* PLA_WDT6_CTRL */
+#define WDT6_SET_MODE		0x0010
+
 /* PLA_TCR0 */
 #define TCR0_TX_EMPTY		0x0800
 #define TCR0_AUTO_FIFO		0x0080
@@ -169,6 +208,12 @@
 /* PLA_CFG_WOL */
 #define MAGIC_EN		0x0001
 
+/* PLA_TEREDO_CFG */
+#define TEREDO_SEL		0x8000
+#define TEREDO_WAKE_MASK	0x7f00
+#define TEREDO_RS_EVENT_MASK	0x00fe
+#define OOB_TEREDO_EN		0x0001
+
 /* PAL_BDC_CR */
 #define ALDPS_PROXY_MODE	0x0001
 
@@ -186,6 +231,25 @@
 #define D3_CLK_GATED_EN		0x00004000
 #define MCU_CLK_RATIO		0x07010f07
 #define MCU_CLK_RATIO_MASK	0x0f0f0f0f
+#define ALDPS_SPDWN_RATIO	0x0f87
+
+/* PLA_MAC_PWR_CTRL2 */
+#define EEE_SPDWN_RATIO		0x8007
+
+/* PLA_MAC_PWR_CTRL3 */
+#define PKT_AVAIL_SPDWN_EN	0x0100
+#define SUSPEND_SPDWN_EN	0x0004
+#define U1U2_SPDWN_EN		0x0002
+#define L1_SPDWN_EN		0x0001
+
+/* PLA_MAC_PWR_CTRL4 */
+#define PWRSAVE_SPDWN_EN	0x1000
+#define RXDV_SPDWN_EN		0x0800
+#define TX10MIDLE_EN		0x0100
+#define TP100_SPDWN_EN		0x0020
+#define TP500_SPDWN_EN		0x0010
+#define TP1000_SPDWN_EN		0x0008
+#define EEE_SPDWN_EN		0x0001
 
 /* PLA_GPHY_INTR_IMR */
 #define GPHY_STS_MSK		0x0001
@@ -200,6 +264,9 @@
 #define EEE_RX_EN		0x0001
 #define EEE_TX_EN		0x0002
 
+/* PLA_BOOT_CTRL */
+#define AUTOLOAD_DONE		0x0002
+
 /* USB_DEV_STAT */
 #define STAT_SPEED_MASK		0x0006
 #define STAT_SPEED_HIGH		0x0000
@@ -209,7 +276,9 @@
 #define TX_AGG_MAX_THRESHOLD	0x03
 
 /* USB_RX_BUF_TH */
+#define RX_THR_SUPPER		0x0c350180
 #define RX_THR_HIGH		0x7a120180
+#define RX_THR_SLOW		0xffff0180
 
 /* USB_TX_DMA */
 #define TEST_MODE_DISABLE	0x00000001
@@ -224,12 +293,50 @@
 /* USB_USB_CTRL */
 #define RX_AGG_DISABLE		0x0010
 
+/* USB_U2P3_CTRL */
+#define U2P3_ENABLE		0x0001
+
+/* USB_POWER_CUT */
+#define PWR_EN			0x0001
+#define PHASE2_EN		0x0008
+
+/* USB_MISC_0 */
+#define PCUT_STATUS		0x0001
+
+/* USB_RX_EARLY_AGG */
+#define EARLY_AGG_SUPPER	0x0e832981
+#define EARLY_AGG_HIGH		0x0e837a12
+#define EARLY_AGG_SLOW		0x0e83ffff
+
+/* USB_WDT11_CTRL */
+#define TIMER11_EN		0x0001
+
+/* USB_LPM_CTRL */
+#define LPM_TIMER_MASK		0x0c
+#define LPM_TIMER_500MS		0x04	/* 500 ms */
+#define LPM_TIMER_500US		0x0c	/* 500 us */
+
+/* USB_AFE_CTRL2 */
+#define SEN_VAL_MASK		0xf800
+#define SEN_VAL_NORMAL		0xa000
+#define SEL_RXIDLE		0x0100
+
 /* OCP_ALDPS_CONFIG */
 #define ENPWRSAVE		0x8000
 #define ENPDNPS			0x0200
 #define LINKENA			0x0100
 #define DIS_SDSAVE		0x0010
 
+/* OCP_PHY_STATUS */
+#define PHY_STAT_MASK		0x0007
+#define PHY_STAT_LAN_ON		3
+#define PHY_STAT_PWRDN		5
+
+/* OCP_POWER_CFG */
+#define EEE_CLKDIV_EN		0x8000
+#define EN_ALDPS		0x0004
+#define EN_10M_PLLOFF		0x0001
+
 /* OCP_EEE_CONFIG1 */
 #define RG_TXLPI_MSK_HFDUP	0x8000
 #define RG_MATCLR_EN		0x4000
@@ -264,7 +371,36 @@
 #define EEE_ADDR		0x003C
 #define EEE_DATA		0x0002
 
+/* OCP_EEE_CFG */
+#define CTAP_SHORT_EN		0x0040
+#define EEE10_EN		0x0010
+
+/* OCP_DOWN_SPEED */
+#define EN_10M_BGOFF		0x0080
+
+/* OCP_EEE_CFG2 */
+#define MY1000_EEE		0x0004
+#define MY100_EEE		0x0002
+
+/* OCP_ADC_CFG */
+#define CKADSEL_L		0x0100
+#define ADC_EN			0x0080
+#define EN_EMI_L		0x0040
+
+/* SRAM_LPF_CFG */
+#define LPF_AUTO_TUNE		0x8000
+
+/* SRAM_10M_AMP1 */
+#define GDAC_IB_UPALL		0x0008
+
+/* SRAM_10M_AMP2 */
+#define AMP_DN			0x0200
+
+/* SRAM_IMPEDANCE */
+#define RX_DRIVING_MASK		0x6000
+
 enum rtl_register_content {
+	_1000bps	= 0x10,
 	_100bps		= 0x08,
 	_10bps		= 0x04,
 	LINK_STATUS	= 0x02,
@@ -306,6 +442,10 @@ enum rtl8152_flags {
 /* Define these values to match your device */
 #define VENDOR_ID_REALTEK		0x0bda
 #define PRODUCT_ID_RTL8152		0x8152
+#define PRODUCT_ID_RTL8153		0x8153
+
+#define VENDOR_ID_SAMSUNG		0x04e8
+#define PRODUCT_ID_SAMSUNG		0xa101
 
 #define MCU_TYPE_PLA			0x0100
 #define MCU_TYPE_USB			0x0000
@@ -388,7 +528,11 @@ struct r8152 {
 enum rtl_version {
 	RTL_VER_UNKNOWN = 0,
 	RTL_VER_01,
-	RTL_VER_02
+	RTL_VER_02,
+	RTL_VER_03,
+	RTL_VER_04,
+	RTL_VER_05,
+	RTL_VER_MAX
 };
 
 /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
@@ -704,6 +848,18 @@ static inline int r8152_mdio_read(struct r8152 *tp, u32 reg_addr)
 	return ocp_reg_read(tp, OCP_BASE_MII + reg_addr * 2);
 }
 
+static void sram_write(struct r8152 *tp, u16 addr, u16 data)
+{
+	ocp_reg_write(tp, OCP_SRAM_ADDR, addr);
+	ocp_reg_write(tp, OCP_SRAM_DATA, data);
+}
+
+static u16 sram_read(struct r8152 *tp, u16 addr)
+{
+	ocp_reg_write(tp, OCP_SRAM_ADDR, addr);
+	return ocp_reg_read(tp, OCP_SRAM_DATA);
+}
+
 static int read_mii_word(struct net_device *netdev, int phy_id, int reg)
 {
 	struct r8152 *tp = netdev_priv(netdev);
@@ -1497,6 +1653,39 @@ static int rtl8152_enable(struct r8152 *tp)
 	return rtl_enable(tp);
 }
 
+static void r8153_set_rx_agg(struct r8152 *tp)
+{
+	u8 speed;
+
+	speed = rtl8152_get_speed(tp);
+	if (speed & _1000bps) {
+		if (tp->udev->speed == USB_SPEED_SUPER) {
+			ocp_write_dword(tp, MCU_TYPE_USB, USB_RX_BUF_TH,
+					RX_THR_SUPPER);
+			ocp_write_dword(tp, MCU_TYPE_USB, USB_RX_EARLY_AGG,
+					EARLY_AGG_SUPPER);
+		} else {
+			ocp_write_dword(tp, MCU_TYPE_USB, USB_RX_BUF_TH,
+					RX_THR_HIGH);
+			ocp_write_dword(tp, MCU_TYPE_USB, USB_RX_EARLY_AGG,
+					EARLY_AGG_HIGH);
+		}
+	} else {
+		ocp_write_dword(tp, MCU_TYPE_USB, USB_RX_BUF_TH, RX_THR_SLOW);
+		ocp_write_dword(tp, MCU_TYPE_USB, USB_RX_EARLY_AGG,
+				EARLY_AGG_SLOW);
+	}
+}
+
+static int rtl8153_enable(struct r8152 *tp)
+{
+	set_tx_qlen(tp);
+	rtl_set_eee_plus(tp);
+	r8153_set_rx_agg(tp);
+
+	return rtl_enable(tp);
+}
+
 static void rtl8152_disable(struct r8152 *tp)
 {
 	struct net_device_stats *stats = rtl8152_get_stats(tp->netdev);
@@ -1695,15 +1884,269 @@ static inline void r8152b_enable_aldps(struct r8152 *tp)
 					    LINKENA | DIS_SDSAVE);
 }
 
+static void r8153_hw_phy_cfg(struct r8152 *tp)
+{
+	u32 ocp_data;
+	u16 data;
+
+	ocp_reg_write(tp, OCP_ADC_CFG, CKADSEL_L | ADC_EN | EN_EMI_L);
+	r8152_mdio_write(tp, MII_BMCR, BMCR_ANENABLE);
+
+	if (tp->version == RTL_VER_03) {
+		data = ocp_reg_read(tp, OCP_EEE_CFG);
+		data &= ~CTAP_SHORT_EN;
+		ocp_reg_write(tp, OCP_EEE_CFG, data);
+	}
+
+	data = ocp_reg_read(tp, OCP_POWER_CFG);
+	data |= EEE_CLKDIV_EN;
+	ocp_reg_write(tp, OCP_POWER_CFG, data);
+
+	data = ocp_reg_read(tp, OCP_DOWN_SPEED);
+	data |= EN_10M_BGOFF;
+	ocp_reg_write(tp, OCP_DOWN_SPEED, data);
+	data = ocp_reg_read(tp, OCP_POWER_CFG);
+	data |= EN_10M_PLLOFF;
+	ocp_reg_write(tp, OCP_POWER_CFG, data);
+	data = sram_read(tp, SRAM_IMPEDANCE);
+	data &= ~RX_DRIVING_MASK;
+	sram_write(tp, SRAM_IMPEDANCE, data);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_PHY_PWR);
+	ocp_data |= PFM_PWM_SWITCH;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_PHY_PWR, ocp_data);
+
+	data = sram_read(tp, SRAM_LPF_CFG);
+	data |= LPF_AUTO_TUNE;
+	sram_write(tp, SRAM_LPF_CFG, data);
+
+	data = sram_read(tp, SRAM_10M_AMP1);
+	data |= GDAC_IB_UPALL;
+	sram_write(tp, SRAM_10M_AMP1, data);
+	data = sram_read(tp, SRAM_10M_AMP2);
+	data |= AMP_DN;
+	sram_write(tp, SRAM_10M_AMP2, data);
+}
+
+static void r8153_u1u2en(struct r8152 *tp, int enable)
+{
+	u8 u1u2[8];
+
+	if (enable)
+		memset(u1u2, 0xff, sizeof(u1u2));
+	else
+		memset(u1u2, 0x00, sizeof(u1u2));
+
+	usb_ocp_write(tp, USB_TOLERANCE, BYTE_EN_SIX_BYTES, sizeof(u1u2), u1u2);
+}
+
+static void r8153_u2p3en(struct r8152 *tp, int enable)
+{
+	u32 ocp_data;
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_U2P3_CTRL);
+	if (enable)
+		ocp_data |= U2P3_ENABLE;
+	else
+		ocp_data &= ~U2P3_ENABLE;
+	ocp_write_word(tp, MCU_TYPE_USB, USB_U2P3_CTRL, ocp_data);
+}
+
+static void r8153_power_cut_en(struct r8152 *tp, int enable)
+{
+	u32 ocp_data;
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_POWER_CUT);
+	if (enable)
+		ocp_data |= PWR_EN | PHASE2_EN;
+	else
+		ocp_data &= ~(PWR_EN | PHASE2_EN);
+	ocp_write_word(tp, MCU_TYPE_USB, USB_POWER_CUT, ocp_data);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_MISC_0);
+	ocp_data &= ~PCUT_STATUS;
+	ocp_write_word(tp, MCU_TYPE_USB, USB_MISC_0, ocp_data);
+}
+
+static void r8153_teredo_off(struct r8152 *tp)
+{
+	u32 ocp_data;
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_TEREDO_CFG);
+	ocp_data &= ~(TEREDO_SEL | TEREDO_RS_EVENT_MASK | OOB_TEREDO_EN);
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_TEREDO_CFG, ocp_data);
+
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_WDT6_CTRL, WDT6_SET_MODE);
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_REALWOW_TIMER, 0);
+	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_TEREDO_TIMER, 0);
+}
+
+static void r8153_first_init(struct r8152 *tp)
+{
+	u32 ocp_data;
+	int i;
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_MISC_1);
+	ocp_data |= RXDY_GATED_EN;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MISC_1, ocp_data);
+
+	r8153_teredo_off(tp);
+
+	ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_RCR);
+	ocp_data &= ~RCR_ACPT_ALL;
+	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
+
+	r8153_hw_phy_cfg(tp);
+
+	rtl8152_nic_reset(tp);
+
+	ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
+	ocp_data &= ~NOW_IS_OOB;
+	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL, ocp_data);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_SFF_STS_7);
+	ocp_data &= ~MCU_BORW_EN;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_SFF_STS_7, ocp_data);
+
+	for (i = 0; i < 1000; i++) {
+		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
+		if (ocp_data & LINK_LIST_READY)
+			break;
+		mdelay(1);
+	}
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_SFF_STS_7);
+	ocp_data |= RE_INIT_LL;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_SFF_STS_7, ocp_data);
+
+	for (i = 0; i < 1000; i++) {
+		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
+		if (ocp_data & LINK_LIST_READY)
+			break;
+		mdelay(1);
+	}
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CPCR);
+	ocp_data &= ~CPCR_RX_VLAN;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CPCR, ocp_data);
+
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, RTL8152_RMS);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_TCR0);
+	ocp_data |= TCR0_AUTO_FIFO;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_TCR0, ocp_data);
+
+	rtl8152_nic_reset(tp);
+
+	/* rx share fifo credit full threshold */
+	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RXFIFO_CTRL0, RXFIFO_THR1_NORMAL);
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RXFIFO_CTRL1, RXFIFO_THR2_NORMAL);
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RXFIFO_CTRL2, RXFIFO_THR3_NORMAL);
+	/* TX share fifo free credit full threshold */
+	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_TXFIFO_CTRL, TXFIFO_THR_NORMAL2);
+
+	// rx aggregation
+	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_USB_CTRL);
+	ocp_data &= ~RX_AGG_DISABLE;
+	ocp_write_word(tp, MCU_TYPE_USB, USB_USB_CTRL, ocp_data);
+}
+
+static void r8153_enter_oob(struct r8152 *tp)
+{
+	u32 ocp_data;
+	int i;
+
+	ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
+	ocp_data &= ~NOW_IS_OOB;
+	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL, ocp_data);
+
+	rtl8152_disable(tp);
+
+	for (i = 0; i < 1000; i++) {
+		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
+		if (ocp_data & LINK_LIST_READY)
+			break;
+		mdelay(1);
+	}
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_SFF_STS_7);
+	ocp_data |= RE_INIT_LL;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_SFF_STS_7, ocp_data);
+
+	for (i = 0; i < 1000; i++) {
+		ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
+		if (ocp_data & LINK_LIST_READY)
+			break;
+		mdelay(1);
+	}
+
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RMS, RTL8152_RMS);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CFG_WOL);
+	ocp_data |= MAGIC_EN;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CFG_WOL, ocp_data);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_TEREDO_CFG);
+	ocp_data &= ~TEREDO_WAKE_MASK;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_TEREDO_CFG, ocp_data);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_CPCR);
+	ocp_data |= CPCR_RX_VLAN;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_CPCR, ocp_data);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PAL_BDC_CR);
+	ocp_data |= ALDPS_PROXY_MODE;
+	ocp_write_word(tp, MCU_TYPE_PLA, PAL_BDC_CR, ocp_data);
+
+	ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
+	ocp_data |= NOW_IS_OOB | DIS_MCU_CLROOB;
+	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL, ocp_data);
+
+	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CONFIG5, LAN_WAKE_EN);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_MISC_1);
+	ocp_data &= ~RXDY_GATED_EN;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MISC_1, ocp_data);
+
+	ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_RCR);
+	ocp_data |= RCR_APM | RCR_AM | RCR_AB;
+	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
+}
+
+static void r8153_disable_aldps(struct r8152 *tp)
+{
+	u16 data;
+
+	data = ocp_reg_read(tp, OCP_POWER_CFG);
+	data &= ~EN_ALDPS;
+	ocp_reg_write(tp, OCP_POWER_CFG, data);
+	msleep(20);
+}
+
+static void r8153_enable_aldps(struct r8152 *tp)
+{
+	u16 data;
+
+	data = ocp_reg_read(tp, OCP_POWER_CFG);
+	data |= EN_ALDPS;
+	ocp_reg_write(tp, OCP_POWER_CFG, data);
+}
+
 static int rtl8152_set_speed(struct r8152 *tp, u8 autoneg, u16 speed, u8 duplex)
 {
-	u16 bmcr, anar;
+	u16 bmcr, anar, gbcr;
 	int ret = 0;
 
 	cancel_delayed_work_sync(&tp->schedule);
 	anar = r8152_mdio_read(tp, MII_ADVERTISE);
 	anar &= ~(ADVERTISE_10HALF | ADVERTISE_10FULL |
 		  ADVERTISE_100HALF | ADVERTISE_100FULL);
+	if (tp->mii.supports_gmii) {
+		gbcr = r8152_mdio_read(tp, MII_CTRL1000);
+		gbcr &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
+	} else {
+		gbcr = 0;
+	}
 
 	if (autoneg == AUTONEG_DISABLE) {
 		if (speed == SPEED_10) {
@@ -1712,6 +2155,9 @@ static int rtl8152_set_speed(struct r8152 *tp, u8 autoneg, u16 speed, u8 duplex)
 		} else if (speed == SPEED_100) {
 			bmcr = BMCR_SPEED100;
 			anar |= ADVERTISE_100HALF | ADVERTISE_100FULL;
+		} else if (speed == SPEED_1000 && tp->mii.supports_gmii) {
+			bmcr = BMCR_SPEED1000;
+			gbcr |= ADVERTISE_1000FULL | ADVERTISE_1000HALF;
 		} else {
 			ret = -EINVAL;
 			goto out;
@@ -1733,6 +2179,16 @@ static int rtl8152_set_speed(struct r8152 *tp, u8 autoneg, u16 speed, u8 duplex)
 				anar |= ADVERTISE_10HALF;
 				anar |= ADVERTISE_100HALF;
 			}
+		} else if (speed == SPEED_1000 && tp->mii.supports_gmii) {
+			if (duplex == DUPLEX_FULL) {
+				anar |= ADVERTISE_10HALF | ADVERTISE_10FULL;
+				anar |= ADVERTISE_100HALF | ADVERTISE_100FULL;
+				gbcr |= ADVERTISE_1000FULL | ADVERTISE_1000HALF;
+			} else {
+				anar |= ADVERTISE_10HALF;
+				anar |= ADVERTISE_100HALF;
+				gbcr |= ADVERTISE_1000HALF;
+			}
 		} else {
 			ret = -EINVAL;
 			goto out;
@@ -1741,6 +2197,9 @@ static int rtl8152_set_speed(struct r8152 *tp, u8 autoneg, u16 speed, u8 duplex)
 		bmcr = BMCR_ANENABLE | BMCR_ANRESTART;
 	}
 
+	if (tp->mii.supports_gmii)
+		r8152_mdio_write(tp, MII_CTRL1000, gbcr);
+
 	r8152_mdio_write(tp, MII_ADVERTISE, anar);
 	r8152_mdio_write(tp, MII_BMCR, bmcr);
 
@@ -1762,6 +2221,15 @@ static void rtl8152_down(struct r8152 *tp)
 	r8152b_enable_aldps(tp);
 }
 
+static void rtl8153_down(struct r8152 *tp)
+{
+	r8153_u1u2en(tp, 0);
+	r8153_power_cut_en(tp, 0);
+	r8153_disable_aldps(tp);
+	r8153_enter_oob(tp);
+	r8153_enable_aldps(tp);
+}
+
 static void set_carrier(struct r8152 *tp)
 {
 	struct net_device *netdev = tp->netdev;
@@ -1821,7 +2289,9 @@ static int rtl8152_open(struct net_device *netdev)
 		return res;
 	}
 
-	rtl8152_set_speed(tp, AUTONEG_ENABLE, SPEED_100, DUPLEX_FULL);
+	rtl8152_set_speed(tp, AUTONEG_ENABLE,
+			  tp->mii.supports_gmii ? SPEED_1000 : SPEED_100,
+			  DUPLEX_FULL);
 	tp->speed = 0;
 	netif_carrier_off(netdev);
 	netif_start_queue(netdev);
@@ -1861,6 +2331,13 @@ static void rtl_clear_bp(struct r8152 *tp)
 	ocp_write_word(tp, MCU_TYPE_USB, USB_BP_BA, 0);
 }
 
+static void r8153_clear_bp(struct r8152 *tp)
+{
+	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_BP_EN, 0);
+	ocp_write_byte(tp, MCU_TYPE_USB, USB_BP_EN, 0);
+	rtl_clear_bp(tp);
+}
+
 static void r8152b_enable_eee(struct r8152 *tp)
 {
 	u32	ocp_data;
@@ -1884,6 +2361,22 @@ static void r8152b_enable_eee(struct r8152 *tp)
 	ocp_reg_write(tp, OCP_EEE_AR, 0x0000);
 }
 
+static void r8153_enable_eee(struct r8152 *tp)
+{
+	u32 ocp_data;
+	u16 data;
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEE_CR);
+	ocp_data |= EEE_RX_EN | EEE_TX_EN;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_EEE_CR, ocp_data);
+	data = ocp_reg_read(tp, OCP_EEE_CFG);
+	data |= EEE10_EN;
+	ocp_reg_write(tp, OCP_EEE_CFG, data);
+	data = ocp_reg_read(tp, OCP_EEE_CFG2);
+	data |= MY1000_EEE | MY100_EEE;
+	ocp_reg_write(tp, OCP_EEE_CFG2, data);
+}
+
 static void r8152b_enable_fc(struct r8152 *tp)
 {
 	u16 anar;
@@ -1953,6 +2446,75 @@ static void r8152b_init(struct r8152 *tp)
 	ocp_write_word(tp, MCU_TYPE_USB, USB_USB_CTRL, ocp_data);
 }
 
+static void r8153_init(struct r8152 *tp)
+{
+	u32 ocp_data;
+	int i;
+
+	r8153_u1u2en(tp, 0);
+
+	for (i = 0; i < 500; i++) {
+		if (ocp_read_word(tp, MCU_TYPE_PLA, PLA_BOOT_CTRL) &
+		    AUTOLOAD_DONE)
+			break;
+		msleep(20);
+	}
+
+	for (i = 0; i < 500; i++) {
+		ocp_data = ocp_reg_read(tp, OCP_PHY_STATUS) & PHY_STAT_MASK;
+		if (ocp_data == PHY_STAT_LAN_ON || ocp_data == PHY_STAT_PWRDN)
+			break;
+		msleep(20);
+	}
+
+	r8153_u2p3en(tp, 0);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_WDT11_CTRL);
+	ocp_data &= ~TIMER11_EN;
+	ocp_write_word(tp, MCU_TYPE_USB, USB_WDT11_CTRL, ocp_data);
+
+	r8153_clear_bp(tp);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_LED_FEATURE);
+	ocp_data &= ~LED_MODE_MASK;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_LED_FEATURE, ocp_data);
+
+	ocp_data = ocp_read_byte(tp, MCU_TYPE_USB, USB_LPM_CTRL);
+	ocp_data &= ~LPM_TIMER_MASK;
+	if (tp->udev->speed == USB_SPEED_SUPER)
+		ocp_data |= LPM_TIMER_500US;
+	else
+		ocp_data |= LPM_TIMER_500MS;
+	ocp_write_byte(tp, MCU_TYPE_USB, USB_LPM_CTRL, ocp_data);
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_AFE_CTRL2);
+	ocp_data &= ~SEN_VAL_MASK;
+	ocp_data |= SEN_VAL_NORMAL | SEL_RXIDLE;
+	ocp_write_word(tp, MCU_TYPE_USB, USB_AFE_CTRL2, ocp_data);
+
+	r8153_power_cut_en(tp, 0);
+	r8153_u1u2en(tp, 1);
+
+	r8153_first_init(tp);
+
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL, ALDPS_SPDWN_RATIO);
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL2, EEE_SPDWN_RATIO);
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL3,
+		       PKT_AVAIL_SPDWN_EN | SUSPEND_SPDWN_EN |
+		       U1U2_SPDWN_EN | L1_SPDWN_EN);
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_MAC_PWR_CTRL4,
+		       PWRSAVE_SPDWN_EN | RXDV_SPDWN_EN | TX10MIDLE_EN |
+		       TP100_SPDWN_EN | TP500_SPDWN_EN | TP1000_SPDWN_EN |
+		       EEE_SPDWN_EN);
+
+	r8153_enable_eee(tp);
+	r8153_enable_aldps(tp);
+	r8152b_enable_fc(tp);
+
+	r8152_mdio_write(tp, MII_BMCR, BMCR_RESET | BMCR_ANENABLE |
+				       BMCR_ANRESTART);
+}
+
 static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
@@ -1978,7 +2540,9 @@ static int rtl8152_resume(struct usb_interface *intf)
 	tp->rtl_ops.init(tp);
 	netif_device_attach(tp->netdev);
 	if (netif_running(tp->netdev)) {
-		rtl8152_set_speed(tp, AUTONEG_ENABLE, SPEED_100, DUPLEX_FULL);
+		rtl8152_set_speed(tp, AUTONEG_ENABLE,
+				tp->mii.supports_gmii ? SPEED_1000 : SPEED_100,
+				DUPLEX_FULL);
 		tp->speed = 0;
 		netif_carrier_off(tp->netdev);
 		set_bit(WORK_ENABLE, &tp->flags);
@@ -2082,6 +2646,18 @@ static void r8152b_get_version(struct r8152 *tp)
 	case 0x4c10:
 		tp->version = RTL_VER_02;
 		break;
+	case 0x5c00:
+		tp->version = RTL_VER_03;
+		tp->mii.supports_gmii = 1;
+		break;
+	case 0x5c10:
+		tp->version = RTL_VER_04;
+		tp->mii.supports_gmii = 1;
+		break;
+	case 0x5c20:
+		tp->version = RTL_VER_05;
+		tp->mii.supports_gmii = 1;
+		break;
 	default:
 		netif_info(tp, probe, tp->netdev,
 			   "Unknown version 0x%04x\n", version);
@@ -2104,6 +2680,11 @@ static void rtl8152_unload(struct r8152 *tp)
 	ocp_write_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS, ocp_data);
 }
 
+static void rtl8153_unload(struct r8152 *tp)
+{
+	r8153_power_cut_en(tp, 1);
+}
+
 static bool rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 {
 	struct rtl_ops *ops = &tp->rtl_ops;
@@ -2119,6 +2700,28 @@ static bool rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 			ops->down		= rtl8152_down;
 			ops->unload		= rtl8152_unload;
 			break;
+		case PRODUCT_ID_RTL8153:
+			ops->init		= r8153_init;
+			ops->enable		= rtl8153_enable;
+			ops->disable		= rtl8152_disable;
+			ops->down		= rtl8153_down;
+			ops->unload		= rtl8153_unload;
+			break;
+		default:
+			ret = -EFAULT;
+			break;
+		}
+		break;
+
+	case VENDOR_ID_SAMSUNG:
+		switch (id->idProduct) {
+		case PRODUCT_ID_SAMSUNG:
+			ops->init		= r8153_init;
+			ops->enable		= rtl8153_enable;
+			ops->disable		= rtl8152_disable;
+			ops->down		= rtl8153_down;
+			ops->unload		= rtl8153_unload;
+			break;
 		default:
 			ret = false;
 			break;
@@ -2227,6 +2830,8 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 /* table of devices that work with this driver */
 static struct usb_device_id rtl8152_table[] = {
 	{USB_DEVICE(VENDOR_ID_REALTEK, PRODUCT_ID_RTL8152)},
+	{USB_DEVICE(VENDOR_ID_REALTEK, PRODUCT_ID_RTL8153)},
+	{USB_DEVICE(VENDOR_ID_SAMSUNG, PRODUCT_ID_SAMSUNG)},
 	{}
 };
 
diff --git a/drivers/net/usb/r815x.c b/drivers/net/usb/r815x.c
index 2df2f4f..5fd2ca6 100644
--- a/drivers/net/usb/r815x.c
+++ b/drivers/net/usb/r815x.c
@@ -226,7 +226,7 @@ static const struct usb_device_id products[] = {
 {
 	USB_DEVICE_AND_INTERFACE_INFO(REALTEK_VENDOR_ID, 0x8153, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
-#if defined(CONFIG_USB_RTL8153) || defined(CONFIG_USB_RTL8153_MODULE)
+#if defined(CONFIG_USB_RTL8152) || defined(CONFIG_USB_RTL8152_MODULE)
 	.driver_info = 0,
 #else
 	.driver_info = (unsigned long) &r8153_info,
-- 
1.8.3.1
