From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v4 4/5] net/usb/r8152: make sure the USB buffer is DMA-able
Date: Wed, 31 Jul 2013 17:21:25 +0800
Message-ID: <1375262486-5373-4-git-send-email-hayeswang@realtek.com>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
 <1375262486-5373-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375262486-5373-1-git-send-email-hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Allocate the required memory before calling usb_control_msg. And
the additional memory copy is necessary.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
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
