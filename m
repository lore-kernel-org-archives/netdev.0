From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net 2/2] r8152: fix the rx early size of RTL8153
Date: Mon, 20 Mar 2017 16:13:45 +0800
Message-ID: <1394712342-15778-258-Taiwan-albertk@realtek.com>
References: <1394712342-15778-256-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-256-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

revert commit a59e6d815226 ("r8152: correct the rx early size") and
fix the rx early size as

	(rx buffer size - rx packet size - rx desc size - alignment) / 4

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 3a892fa..800be78 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -32,7 +32,7 @@
 #define NETNEXT_VERSION		"08"
 
 /* Information for net */
-#define NET_VERSION		"8"
+#define NET_VERSION		"9"
 
 #define DRIVER_VERSION		"v1." NETNEXT_VERSION "." NET_VERSION
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>"
@@ -501,6 +501,8 @@ enum rtl_register_content {
 #define RTL8153_RMS		RTL8153_MAX_PACKET
 #define RTL8152_TX_TIMEOUT	(5 * HZ)
 #define RTL8152_NAPI_WEIGHT	64
+#define rx_reserved_size(x)	((x) + VLAN_ETH_HLEN + CRC_SIZE + \
+				 sizeof(struct rx_desc) + RX_ALIGN)
 
 /* rtl8152 flags */
 enum rtl8152_flags {
@@ -2252,8 +2254,7 @@ static void r8153_set_rx_early_timeout(struct r8152 *tp)
 
 static void r8153_set_rx_early_size(struct r8152 *tp)
 {
-	u32 mtu = tp->netdev->mtu;
-	u32 ocp_data = (agg_buf_sz - mtu - VLAN_ETH_HLEN - VLAN_HLEN) / 8;
+	u32 ocp_data = (agg_buf_sz - rx_reserved_size(tp->netdev->mtu)) / 4;
 
 	ocp_write_word(tp, MCU_TYPE_USB, USB_RX_EARLY_SIZE, ocp_data);
 }
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
