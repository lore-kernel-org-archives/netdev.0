From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Fri, 11 Nov 2016 15:15:40 +0800
Message-ID: <1394712342-15778-227-Taiwan-albertk@realtek.com>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
        Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-226-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Fix the hw rx checksum is always enabled, and the user couldn't switch
it to sw rx checksum.

Note that the RTL_VER_01 only supports sw rx checksum only. Besides,
the hw rx checksum for RTL_VER_02 is disabled after
commit b9a321b48af4 ("r8152: Fix broken RX checksums."). Re-enable it.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 75c5168..0e42a78 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1730,7 +1730,7 @@ static u8 r8152_rx_csum(struct r8152 *tp, struct rx_desc *rx_desc)
 	u8 checksum = CHECKSUM_NONE;
 	u32 opts2, opts3;
 
-	if (tp->version == RTL_VER_01 || tp->version == RTL_VER_02)
+	if (!(tp->netdev->features & NETIF_F_RXCSUM))
 		goto return_result;
 
 	opts2 = le32_to_cpu(rx_desc->opts2);
@@ -4307,6 +4307,11 @@ static int rtl8152_probe(struct usb_interface *intf,
 				NETIF_F_HIGHDMA | NETIF_F_FRAGLIST |
 				NETIF_F_IPV6_CSUM | NETIF_F_TSO6;
 
+	if (tp->version == RTL_VER_01) {
+		netdev->features &= ~NETIF_F_RXCSUM;
+		netdev->hw_features &= ~NETIF_F_RXCSUM;
+	}
+
 	netdev->ethtool_ops = &ops;
 	netif_set_gso_max_size(netdev, RTL_LIMITED_TSO_SIZE);
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
