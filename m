From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: fix the sw rx checksum is unavailable
Date: Wed, 11 Jan 2017 16:25:34 +0800
Message-ID: <1394712342-15778-232-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the hw rx checksum is always enabled, and the user couldn't switch
it to sw rx checksum.

Note that the RTL_VER_01 only support sw rx checksum only. Besides,
the hw rx checksum for RTL_VER_02 is disabled after
commit b9a321b48af4 ("r8152: Fix broken RX checksums."). Re-enable it.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index be41856..f3b48ad 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1730,7 +1730,7 @@ static u8 r8152_rx_csum(struct r8152 *tp, struct rx_desc *rx_desc)
 	u8 checksum = CHECKSUM_NONE;
 	u32 opts2, opts3;
 
-	if (tp->version == RTL_VER_01 || tp->version == RTL_VER_02)
+	if (!(tp->netdev->features & NETIF_F_RXCSUM))
 		goto return_result;
 
 	opts2 = le32_to_cpu(rx_desc->opts2);
@@ -4356,6 +4356,11 @@ static int rtl8152_probe(struct usb_interface *intf,
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
