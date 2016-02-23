From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] bnx2x: add a separate GENEVE Kconfig symbol
Date: Tue, 23 Feb 2016 11:36:02 +0100
Message-ID: <1456223774-1383513-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ariel Elior <ariel.elior@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CONFIG_GENEVE is built as a loadable module, and bnx2x is built-in,
we get this link error:

drivers/net/built-in.o: In function `bnx2x_open':
:(.text+0x33322): undefined reference to `geneve_get_rx_port'
drivers/net/built-in.o: In function `bnx2x_sp_rtnl_task':
:(.text+0x3e632): undefined reference to `geneve_get_rx_port'

This avoids the problem by adding a separate Kconfig symbol named
CONFIG_BNX2X_GENEVE that is only enabled when the code is
reachable from the driver.

This is the same trick that BNX2X does for VXLAN support, and
is similar to how I40E handles both.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 883ce97d25b0 ("bnx2x: Add Geneve inner-RSS support")
---
 drivers/net/ethernet/broadcom/Kconfig            | 10 ++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 14 +++++++-------
 2 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 19f7cd02e085..18042c2460bd 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -149,6 +149,16 @@ config BNX2X_VXLAN
 	  Say Y here if you want to enable hardware offload support for
 	  Virtual eXtensible Local Area Network (VXLAN) in the driver.
 
+config BNX2X_GENEVE
+	bool "Generic Network Virtualization Encapsulation (GENEVE) support"
+	depends on BNX2X && GENEVE && !(BNX2X=y && GENEVE=m)
+	---help---
+          This allows one to create GENEVE virtual interfaces that provide
+          Layer 2 Networks over Layer 3 Networks. GENEVE is often used
+          to tunnel virtual network infrastructure in virtualized environments.
+	  Say Y here if you want to enable hardware offload support for
+	  Generic Network Virtualization Encapsulation (GENEVE) in the driver.
+
 config BGMAC
 	tristate "BCMA bus GBit core support"
 	depends on BCMA && BCMA_HOST_SOC
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 81fc51c4ec2b..5c95d0c3b076 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -59,7 +59,7 @@
 #include <linux/semaphore.h>
 #include <linux/stringify.h>
 #include <linux/vmalloc.h>
-#if IS_ENABLED(CONFIG_GENEVE)
+#if IS_ENABLED(CONFIG_BNX2X_GENEVE)
 #include <net/geneve.h>
 #endif
 #include "bnx2x.h"
@@ -10078,7 +10078,7 @@ static void bnx2x_parity_recover(struct bnx2x *bp)
 	}
 }
 
-#if defined(CONFIG_BNX2X_VXLAN) || IS_ENABLED(CONFIG_GENEVE)
+#if defined(CONFIG_BNX2X_VXLAN) || IS_ENABLED(CONFIG_BNX2X_GENEVE)
 static int bnx2x_udp_port_update(struct bnx2x *bp)
 {
 	struct bnx2x_func_switch_update_params *switch_update_params;
@@ -10201,7 +10201,7 @@ static void bnx2x_del_vxlan_port(struct net_device *netdev,
 }
 #endif
 
-#if IS_ENABLED(CONFIG_GENEVE)
+#if IS_ENABLED(CONFIG_BNX2X_GENEVE)
 static void bnx2x_add_geneve_port(struct net_device *netdev,
 				  sa_family_t sa_family, __be16 port)
 {
@@ -10327,7 +10327,7 @@ sp_rtnl_not_reset:
 			       &bp->sp_rtnl_state))
 		bnx2x_update_mng_version(bp);
 
-#if defined(CONFIG_BNX2X_VXLAN) || IS_ENABLED(CONFIG_GENEVE)
+#if defined(CONFIG_BNX2X_VXLAN) || IS_ENABLED(CONFIG_BNX2X_GENEVE)
 	if (test_and_clear_bit(BNX2X_SP_RTNL_CHANGE_UDP_PORT,
 			       &bp->sp_rtnl_state)) {
 		if (bnx2x_udp_port_update(bp)) {
@@ -10344,7 +10344,7 @@ sp_rtnl_not_reset:
 			if (!bp->udp_tunnel_ports[BNX2X_UDP_PORT_VXLAN].count)
 				vxlan_get_rx_port(bp->dev);
 #endif
-#if IS_ENABLED(CONFIG_GENEVE)
+#if IS_ENABLED(CONFIG_BNX2X_GENEVE)
 			if (!bp->udp_tunnel_ports[BNX2X_UDP_PORT_GENEVE].count)
 				geneve_get_rx_port(bp->dev);
 #endif
@@ -12557,7 +12557,7 @@ static int bnx2x_open(struct net_device *dev)
 	if (IS_PF(bp))
 		vxlan_get_rx_port(dev);
 #endif
-#if IS_ENABLED(CONFIG_GENEVE)
+#if IS_ENABLED(CONFIG_BNX2X_GENEVE)
 	if (IS_PF(bp))
 		geneve_get_rx_port(dev);
 #endif
@@ -13078,7 +13078,7 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 	.ndo_add_vxlan_port	= bnx2x_add_vxlan_port,
 	.ndo_del_vxlan_port	= bnx2x_del_vxlan_port,
 #endif
-#if IS_ENABLED(CONFIG_GENEVE)
+#if IS_ENABLED(CONFIG_BNX2X_GENEVE)
 	.ndo_add_geneve_port	= bnx2x_add_geneve_port,
 	.ndo_del_geneve_port	= bnx2x_del_geneve_port,
 #endif
-- 
2.7.0
