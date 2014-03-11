From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next] r8152: support dumping the hw counters
Date: Tue, 11 Mar 2014 16:24:19 +0800
Message-ID: <1394526259-5513-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add dumping the tally counter by ethtool.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 95 +++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 93 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index a90a7eb9..aa1d5b2 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -60,7 +60,7 @@
 #define PLA_TCR0		0xe610
 #define PLA_TCR1		0xe612
 #define PLA_TXFIFO_CTRL		0xe618
-#define PLA_RSTTELLY		0xe800
+#define PLA_RSTTALLY		0xe800
 #define PLA_CR			0xe813
 #define PLA_CRWECR		0xe81c
 #define PLA_CONFIG12		0xe81e	/* CONFIG1, CONFIG2 */
@@ -72,7 +72,7 @@
 #define PLA_MISC_0		0xe858
 #define PLA_MISC_1		0xe85a
 #define PLA_OCP_GPHY_BASE	0xe86c
-#define PLA_TELLYCNT		0xe890
+#define PLA_TALLYCNT		0xe890
 #define PLA_SFF_STS_7		0xe8de
 #define PLA_PHYSTATUS		0xe908
 #define PLA_BP_BA		0xfc26
@@ -180,6 +180,9 @@
 /* PLA_TCR1 */
 #define VERSION_MASK		0x7cf0
 
+/* PLA_RSTTALLY */
+#define TALLY_RESET		0x0001
+
 /* PLA_CR */
 #define CR_RST			0x10
 #define CR_RE			0x08
@@ -465,6 +468,22 @@ enum rtl8152_flags {
 #define REALTEK_USB_DEVICE(vend, prod)	\
 	USB_DEVICE_INTERFACE_CLASS(vend, prod, USB_CLASS_VENDOR_SPEC)
 
+struct tally_counter {
+	__le64	tx_packets;
+	__le64	rx_packets;
+	__le64	tx_errors;
+	__le32	rx_errors;
+	__le16	rx_missed;
+	__le16	align_errors;
+	__le32	tx_one_collision;
+	__le32	tx_multi_collision;
+	__le64	rx_unicast;
+	__le64	rx_broadcast;
+	__le32	rx_multicast;
+	__le16	tx_aborted;
+	__le16	tx_underun;
+};
+
 struct rx_desc {
 	__le32 opts1;
 #define RX_LEN_MASK			0x7fff
@@ -2872,6 +2891,15 @@ static void r8152b_enable_fc(struct r8152 *tp)
 	r8152_mdio_write(tp, MII_ADVERTISE, anar);
 }
 
+static void rtl_tally_reset(struct r8152 *tp)
+{
+	u32 ocp_data;
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_RSTTALLY);
+	ocp_data |= TALLY_RESET;
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_RSTTALLY, ocp_data);
+}
+
 static void r8152b_init(struct r8152 *tp)
 {
 	u32 ocp_data;
@@ -2898,6 +2926,7 @@ static void r8152b_init(struct r8152 *tp)
 	r8152b_enable_eee(tp);
 	r8152b_enable_aldps(tp);
 	r8152b_enable_fc(tp);
+	rtl_tally_reset(tp);
 
 	/* enable rx aggregation */
 	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_USB_CTRL);
@@ -2965,6 +2994,7 @@ static void r8153_init(struct r8152 *tp)
 	r8153_enable_eee(tp);
 	r8153_enable_aldps(tp);
 	r8152b_enable_fc(tp);
+	rtl_tally_reset(tp);
 }
 
 static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
@@ -3105,6 +3135,64 @@ out:
 	return ret;
 }
 
+static const char rtl8152_gstrings[][ETH_GSTRING_LEN] = {
+	"tx_packets",
+	"rx_packets",
+	"tx_errors",
+	"rx_errors",
+	"rx_missed",
+	"align_errors",
+	"tx_single_collisions",
+	"tx_multi_collisions",
+	"rx_unicast",
+	"rx_broadcast",
+	"rx_multicast",
+	"tx_aborted",
+	"tx_underrun",
+};
+
+static int rtl8152_get_sset_count(struct net_device *dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(rtl8152_gstrings);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void rtl8152_get_ethtool_stats(struct net_device *dev,
+				      struct ethtool_stats *stats, u64 *data)
+{
+	struct r8152 *tp = netdev_priv(dev);
+	struct tally_counter tally;
+
+	generic_ocp_read(tp, PLA_TALLYCNT, sizeof(tally), &tally, MCU_TYPE_PLA);
+
+	data[0] = le64_to_cpu(tally.tx_packets);
+	data[1] = le64_to_cpu(tally.rx_packets);
+	data[2] = le64_to_cpu(tally.tx_errors);
+	data[3] = le32_to_cpu(tally.rx_errors);
+	data[4] = le16_to_cpu(tally.rx_missed);
+	data[5] = le16_to_cpu(tally.align_errors);
+	data[6] = le32_to_cpu(tally.tx_one_collision);
+	data[7] = le32_to_cpu(tally.tx_multi_collision);
+	data[8] = le64_to_cpu(tally.rx_unicast);
+	data[9] = le64_to_cpu(tally.rx_broadcast);
+	data[10] = le32_to_cpu(tally.rx_multicast);
+	data[11] = le16_to_cpu(tally.tx_aborted);
+	data[12] = le16_to_cpu(tally.tx_underun);
+}
+
+static void rtl8152_get_strings(struct net_device *dev, u32 stringset, u8 *data)
+{
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(data, *rtl8152_gstrings, sizeof(rtl8152_gstrings));
+		break;
+	}
+}
+
 static struct ethtool_ops ops = {
 	.get_drvinfo = rtl8152_get_drvinfo,
 	.get_settings = rtl8152_get_settings,
@@ -3114,6 +3202,9 @@ static struct ethtool_ops ops = {
 	.set_msglevel = rtl8152_set_msglevel,
 	.get_wol = rtl8152_get_wol,
 	.set_wol = rtl8152_set_wol,
+	.get_strings = rtl8152_get_strings,
+	.get_sset_count = rtl8152_get_sset_count,
+	.get_ethtool_stats = rtl8152_get_ethtool_stats,
 };
 
 static int rtl8152_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
-- 
1.8.4.2

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
