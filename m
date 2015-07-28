From: WingMan Kwok <w-kwok2@ti.com>
Subject: [net-next PATCH] net: netcp: Fixes efuse mac addr swap on k2e and k2l
Date: Tue, 28 Jul 2015 16:01:11 -0400
Message-ID: <1438113671-6098-1-git-send-email-w-kwok2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: WingMan Kwok <w-kwok2@ti.com>
To: <davem@davemloft.net>, <m-karicheri2@ti.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On some of the K2E and K2L platforms, the two DWORDs in
efuse occupied by the pre-programmed mac address for
slave port 1 are swapped.  To workaround this issue,
this patch adds a new define NETCP_EFUSE_ADDR_SWAP (2)
which signifies the occurrence of such swapping so that
the driver can take proper action.  The flag can be
enabled in the corresponding netcp interface dts binding
as efuse-mac = <2>  under the corresponding netcp
interface node.

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
---
 .../devicetree/bindings/net/keystone-netcp.txt     |    6 +++++-
 drivers/net/ethernet/ti/netcp_core.c               |   15 +++++++++++++--
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/keystone-netcp.txt b/Documentation/devicetree/bindings/net/keystone-netcp.txt
index d0e6fa3..b30ab6b 100644
--- a/Documentation/devicetree/bindings/net/keystone-netcp.txt
+++ b/Documentation/devicetree/bindings/net/keystone-netcp.txt
@@ -130,7 +130,11 @@ Required properties:
 
 Optional properties:
 - efuse-mac:	If this is 1, then the MAC address for the interface is
-		obtained from the device efuse mac address register
+		obtained from the device efuse mac address register.
+		If this is 2, the two DWORDs occupied by the MAC address
+		are swapped.  The netcp driver will swap the two DWORDs
+		back to the proper order when this property is set to 2
+		when it obtains the mac address from efuse.
 - local-mac-address:	the driver is designed to use the of_get_mac_address api
 			only if efuse-mac is 0. When efuse-mac is 0, the MAC
 			address is obtained from local-mac-address. If this
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 3ca87f2..6f2e151 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -51,6 +51,8 @@
 		    NETIF_MSG_PKTDATA	| NETIF_MSG_TX_QUEUED	|	\
 		    NETIF_MSG_RX_STATUS)
 
+#define NETCP_EFUSE_ADDR_SWAP	2
+
 #define knav_queue_get_id(q)	knav_queue_device_control(q, \
 				KNAV_QUEUE_GET_ID, (unsigned long)NULL)
 
@@ -172,13 +174,22 @@ static void set_words(u32 *words, int num_words, u32 *desc)
 }
 
 /* Read the e-fuse value as 32 bit values to be endian independent */
-static int emac_arch_get_mac_addr(char *x, void __iomem *efuse_mac)
+static int emac_arch_get_mac_addr(char *x, void __iomem *efuse_mac, u32 swap)
 {
 	unsigned int addr0, addr1;
 
 	addr1 = readl(efuse_mac + 4);
 	addr0 = readl(efuse_mac);
 
+	switch (swap) {
+	case NETCP_EFUSE_ADDR_SWAP:
+		addr0 = addr1;
+		addr1 = readl(efuse_mac);
+		break;
+	default:
+		break;
+	}
+
 	x[0] = (addr1 & 0x0000ff00) >> 8;
 	x[1] = addr1 & 0x000000ff;
 	x[2] = (addr0 & 0xff000000) >> 24;
@@ -1902,7 +1913,7 @@ static int netcp_create_interface(struct netcp_device *netcp_device,
 			goto quit;
 		}
 
-		emac_arch_get_mac_addr(efuse_mac_addr, efuse);
+		emac_arch_get_mac_addr(efuse_mac_addr, efuse, efuse_mac);
 		if (is_valid_ether_addr(efuse_mac_addr))
 			ether_addr_copy(ndev->dev_addr, efuse_mac_addr);
 		else
-- 
1.7.9.5
