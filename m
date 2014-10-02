From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net] r8152: autoresume before setting MAC address
Date: Thu, 2 Oct 2014 16:26:06 +0800
Message-ID: <1394712342-15778-55-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Resume the device before setting the MAC address.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 604ef21..e823358 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1007,9 +1007,16 @@ static int rtl8152_set_mac_address(struct net_device *netdev, void *p)
 {
 	struct r8152 *tp = netdev_priv(netdev);
 	struct sockaddr *addr = p;
+	int ret;
+
+	ret = usb_autopm_get_interface(tp->intf);
+	if (ret < 0)
+		goto out1;
 
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
+	if (!is_valid_ether_addr(addr->sa_data)) {
+		ret = -EADDRNOTAVAIL;
+		goto out2;
+	}
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
 
@@ -1017,7 +1024,10 @@ static int rtl8152_set_mac_address(struct net_device *netdev, void *p)
 	pla_ocp_write(tp, PLA_IDR, BYTE_EN_SIX_BYTES, 8, addr->sa_data);
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_NORAML);
 
-	return 0;
+out2:
+	usb_autopm_put_interface(tp->intf);
+out1:
+	return ret;
 }
 
 static void read_bulk_callback(struct urb *urb)
-- 
1.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
