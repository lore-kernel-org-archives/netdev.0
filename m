From: hayeswang <hayeswang@realtek.com>
Subject: [PATCH 2/3] net/usb/r8152: make sure the USB buffer is DMA-able
Date: Tue, 23 Jul 2013 17:26:04 +0800
Message-ID: <210AAC5346804B4C8C3F3CBD25C16EFA@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
References: 
In-Reply-To: 
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allocate the required memory before calling usb_control_msg. And
the additional memory copy is necessary.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 60 ++++++++++++++++++++++++++++---------------------
 1 file changed, 35 insertions(+), 25 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ee13f9e..ef033ab 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -344,17 +344,41 @@ static const int multicast_filter_limit = 32;
 static
 int get_registers(struct r8152 *tp, u16 value, u16 index, u16 size, void *data)
 {
-	return usb_control_msg(tp->udev, usb_rcvctrlpipe(tp->udev, 0),
+	int ret;
+	void *tmp;
+
+	tmp = kmalloc(size, GFP_KERNEL);
+	if (!tmp)
+		return -ENOMEM;
+
+	ret = usb_control_msg(tp->udev, usb_rcvctrlpipe(tp->udev, 0),
 			       RTL8152_REQ_GET_REGS, RTL8152_REQT_READ,
-			       value, index, data, size, 500);
+			       value, index, tmp, size, 500);
+
+	memcpy(data, tmp, size);
+	kfree(tmp);
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
+	tmp = kmalloc(size, GFP_KERNEL);
+	if (!tmp)
+		return -ENOMEM;
+
+	memcpy(tmp, data, size);
+
+	ret = usb_control_msg(tp->udev, usb_sndctrlpipe(tp->udev, 0),
 			       RTL8152_REQ_SET_REGS, RTL8152_REQT_WRITE,
-			       value, index, data, size, 500);
+			       value, index, tmp, size, 500);
+
+	kfree(tmp);
+	return ret;
 }
 
 static int generic_ocp_read(struct r8152 *tp, u16 index, u16 size,
@@ -685,21 +709,14 @@ static void ocp_reg_write(struct r8152 *tp, u16 addr, u16 data)
 static inline void set_ethernet_addr(struct r8152 *tp)
 {
 	struct net_device *dev = tp->netdev;
-	u8 *node_id;
+	u8 node_id[8] = {0};
 
-	node_id = kmalloc(sizeof(u8) * 8, GFP_KERNEL);
-	if (!node_id) {
-		netif_err(tp, probe, dev, "out of memory");
-		return;
-	}
-
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
@@ -882,15 +899,10 @@ static void rtl8152_set_rx_mode(struct net_device *netdev)
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
@@ -918,14 +930,12 @@ static void _rtl8152_set_rx_mode(struct net_device *netdev)
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
-- 
1.8.3.1
