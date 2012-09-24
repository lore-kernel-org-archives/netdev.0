From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 5/5] smsc95xx: enable power saving mode during system suspend
Date: Mon, 24 Sep 2012 15:40:54 +0100
Message-ID: <1348497654-9915-6-git-send-email-steve.glendinning@shawell.net>
References: <1348497654-9915-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:37743 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754135Ab2IXOq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 10:46:26 -0400
In-Reply-To: <1348497654-9915-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables the device to enter its lowest power SUSPEND2
state during system suspend, instead of staying up using full power.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |   28 ++++++++++++++++++++++++++++
 drivers/net/usb/smsc95xx.h |    6 +++++-
 2 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index f29860d..ecced91 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1018,6 +1018,31 @@ static void smsc95xx_unbind(struct usbnet *dev, struct usb_interface *intf)
 	}
 }
 
+static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+	int ret;
+	u32 val;
+
+	BUG_ON(!dev);
+
+	ret = usbnet_suspend(intf, message);
+	check_warn_return(ret, "usbnet_suspend error");
+
+	netdev_info(dev->net, "entering SUSPEND2 mode");
+
+	ret = smsc95xx_read_reg(dev, PM_CTRL, &val);
+	check_warn_return(ret, "Error reading PM_CTRL");
+
+	val &= ~(PM_CTL_SUS_MODE_ | PM_CTL_WUPS_ | PM_CTL_PHY_RST_);
+	val |= PM_CTL_SUS_MODE_2;
+
+	ret = smsc95xx_write_reg(dev, PM_CTRL, val);
+	check_warn_return(ret, "Error writing PM_CTRL");
+
+	return 0;
+}
+
 static void smsc95xx_rx_csum_offload(struct sk_buff *skb)
 {
 	skb->csum = *(u16 *)(skb_tail_pointer(skb) - 2);
@@ -1283,6 +1308,9 @@ static struct usb_driver smsc95xx_driver = {
 	.suspend	= usbnet_suspend,
 	.resume		= usbnet_resume,
 	.reset_resume	= usbnet_resume,
+	.suspend	= smsc95xx_suspend,
+	.resume		= usbnet_resume,
+	.reset_resume	= usbnet_resume,
 	.disconnect	= usbnet_disconnect,
 	.disable_hub_initiated_lpm = 1,
 };
diff --git a/drivers/net/usb/smsc95xx.h b/drivers/net/usb/smsc95xx.h
index a275b62..89ad925 100644
--- a/drivers/net/usb/smsc95xx.h
+++ b/drivers/net/usb/smsc95xx.h
@@ -84,12 +84,16 @@
 #define HW_CFG_BCE_			(0x00000002)
 #define HW_CFG_SRST_			(0x00000001)
 
+#define RX_FIFO_INF			(0x18)
+
 #define PM_CTRL				(0x20)
+#define PM_CTL_RES_CLR_WKP_STS		(0x00000200)
 #define PM_CTL_DEV_RDY_			(0x00000080)
 #define PM_CTL_SUS_MODE_		(0x00000060)
 #define PM_CTL_SUS_MODE_0		(0x00000000)
 #define PM_CTL_SUS_MODE_1		(0x00000020)
-#define PM_CTL_SUS_MODE_2		(0x00000060)
+#define PM_CTL_SUS_MODE_2		(0x00000040)
+#define PM_CTL_SUS_MODE_3		(0x00000060)
 #define PM_CTL_PHY_RST_			(0x00000010)
 #define PM_CTL_WOL_EN_			(0x00000008)
 #define PM_CTL_ED_EN_			(0x00000004)
-- 
1.7.9.5
