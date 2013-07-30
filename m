From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH v3 2/3] net/usb/r8152: replace USB buffer from stack to DMA-able
Date: Tue, 30 Jul 2013 16:28:55 +0800
Message-ID: <1375172936-4145-2-git-send-email-hayeswang@realtek.com>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
 <1375172936-4145-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1375172936-4145-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allocate the required transfer buffer for usb_control_msg.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 91 +++++++++++++++++++++++++++++++++++--------------
 1 file changed, 66 insertions(+), 25 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ee13f9e..93a7baa 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -282,6 +282,8 @@ enum rtl_register_content {
 #define RTL8152_RMS		(VLAN_ETH_FRAME_LEN + VLAN_HLEN)
 #define RTL8152_TX_TIMEOUT	(HZ)
 
+#define RTL8152_MAX_TRANSFER_SIZE	8
+
 /* rtl8152 flags */
 enum rtl8152_flags {
 	RTL8152_UNPLUG = 0,
@@ -324,8 +326,10 @@ struct r8152 {
 	struct sk_buff *tx_skb, *rx_skb;
 	struct delayed_work schedule;
 	struct mii_if_info mii;
+	struct mutex transfer_mutex;
 	u32 msg_enable;
 	u16 ocp_base;
+	u8 *transfer_buf;
 	u8 version;
 	u8 speed;
 };
@@ -344,17 +348,59 @@ static const int multicast_filter_limit = 32;
 static
 int get_registers(struct r8152 *tp, u16 value, u16 index, u16 size, void *data)
 {
-	return usb_control_msg(tp->udev, usb_rcvctrlpipe(tp->udev, 0),
+	int ret;
+	void *tmp;
+
+	if (size > RTL8152_MAX_TRANSFER_SIZE || !tp->transfer_buf) {
+		tmp = kmalloc(size, GFP_KERNEL);
+		if (!tmp)
+			return -ENOMEM;
+	} else {
+		mutex_lock(&tp->transfer_mutex);
+		tmp = tp->transfer_buf;
+	}
+
+	ret = usb_control_msg(tp->udev, usb_rcvctrlpipe(tp->udev, 0),
 			       RTL8152_REQ_GET_REGS, RTL8152_REQT_READ,
-			       value, index, data, size, 500);
+			       value, index, tmp, size, 500);
+
+	memcpy(data, tmp, size);
+
+	if (tmp == tp->transfer_buf)
+		mutex_unlock(&tp->transfer_mutex);
+	else
+		kfree(tmp);
+
+	return ret;
 }
 
 static
 int set_registers(struct r8152 *tp, u16 value, u16 index, u16 size, void *data)
 {
-	return usb_control_msg(tp->udev, usb_sndctrlpipe(tp->udev, 0),
+	int ret;
+	void *tmp;
+
+	if (size > RTL8152_MAX_TRANSFER_SIZE || !tp->transfer_buf) {
+		tmp = kmalloc(size, GFP_KERNEL);
+		if (!tmp)
+			return -ENOMEM;
+	} else {
+		mutex_lock(&tp->transfer_mutex);
+		tmp = tp->transfer_buf;
+	}
+
+	memcpy(tmp, data, size);
+
+	ret = usb_control_msg(tp->udev, usb_sndctrlpipe(tp->udev, 0),
 			       RTL8152_REQ_SET_REGS, RTL8152_REQT_WRITE,
-			       value, index, data, size, 500);
+			       value, index, tmp, size, 500);
+
+	if (tmp == tp->transfer_buf)
+		mutex_unlock(&tp->transfer_mutex);
+	else
+		kfree(tmp);
+
+	return ret;
 }
 
 static int generic_ocp_read(struct r8152 *tp, u16 index, u16 size,
@@ -685,21 +731,14 @@ static void ocp_reg_write(struct r8152 *tp, u16 addr, u16 data)
 static inline void set_ethernet_addr(struct r8152 *tp)
 {
 	struct net_device *dev = tp->netdev;
-	u8 *node_id;
-
-	node_id = kmalloc(sizeof(u8) * 8, GFP_KERNEL);
-	if (!node_id) {
-		netif_err(tp, probe, dev, "out of memory");
-		return;
-	}
+	u8 node_id[8] = {0};
 
-	if (pla_ocp_read(tp, PLA_IDR, sizeof(u8) * 8, node_id) < 0)
+	if (pla_ocp_read(tp, PLA_IDR, sizeof(node_id), node_id) < 0)
 		netif_notice(tp, probe, dev, "inet addr fail\n");
 	else {
 		memcpy(dev->dev_addr, node_id, dev->addr_len);
 		memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 	}
-	kfree(node_id);
 }
 
 static int rtl8152_set_mac_address(struct net_device *netdev, void *p)
@@ -882,15 +921,10 @@ static void rtl8152_set_rx_mode(struct net_device *netdev)
 static void _rtl8152_set_rx_mode(struct net_device *netdev)
 {
 	struct r8152 *tp = netdev_priv(netdev);
-	u32 tmp, *mc_filter;	/* Multicast hash filter */
+	u32 mc_filter[2];	/* Multicast hash filter */
+	__le32 tmp[2];
 	u32 ocp_data;
 
-	mc_filter = kmalloc(sizeof(u32) * 2, GFP_KERNEL);
-	if (!mc_filter) {
-		netif_err(tp, link, netdev, "out of memory");
-		return;
-	}
-
 	clear_bit(RTL8152_SET_RX_MODE, &tp->flags);
 	netif_stop_queue(netdev);
 	ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_RCR);
@@ -918,14 +952,12 @@ static void _rtl8152_set_rx_mode(struct net_device *netdev)
 		}
 	}
 
-	tmp = mc_filter[0];
-	mc_filter[0] = __cpu_to_le32(swab32(mc_filter[1]));
-	mc_filter[1] = __cpu_to_le32(swab32(tmp));
+	tmp[0] = __cpu_to_le32(swab32(mc_filter[1]));
+	tmp[1] = __cpu_to_le32(swab32(mc_filter[0]));
 
-	pla_ocp_write(tp, PLA_MAR, BYTE_EN_DWORD, sizeof(u32) * 2, mc_filter);
+	pla_ocp_write(tp, PLA_MAR, BYTE_EN_DWORD, sizeof(tmp), tmp);
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
 	netif_wake_queue(netdev);
-	kfree(mc_filter);
 }
 
 static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
@@ -1644,6 +1676,7 @@ static int rtl8152_probe(struct usb_interface *intf,
 	tp = netdev_priv(netdev);
 	tp->msg_enable = 0x7FFF;
 
+	mutex_init (&tp->transfer_mutex);
 	tasklet_init(&tp->tl, rx_fixup, (unsigned long)tp);
 	INIT_DELAYED_WORK(&tp->schedule, rtl_work_func_t);
 
@@ -1655,6 +1688,12 @@ static int rtl8152_probe(struct usb_interface *intf,
 	SET_ETHTOOL_OPS(netdev, &ops);
 	tp->speed = 0;
 
+	tp->transfer_buf = kmalloc(RTL8152_MAX_TRANSFER_SIZE, GFP_KERNEL);
+	if (!tp->transfer_buf) {
+		netif_err(tp, probe, netdev, "out of memory");
+		goto out;
+	}
+
 	tp->mii.dev = netdev;
 	tp->mii.mdio_read = read_mii_word;
 	tp->mii.mdio_write = write_mii_word;
@@ -1728,6 +1767,8 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 		free_all_urbs(tp);
 		if (tp->rx_skb)
 			dev_kfree_skb(tp->rx_skb);
+		if (tp->transfer_buf)
+			kfree(tp->transfer_buf);
 		free_netdev(tp->netdev);
 	}
 }
-- 
1.8.3.1
