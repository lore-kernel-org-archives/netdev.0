From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net-next] drivers: net: cpsw: make cpsw_ale.c a module to allow re-use on Keystone
Date: Thu, 29 Jan 2015 18:15:51 -0500
Message-ID: <1422573351-5603-2-git-send-email-m-karicheri2@ti.com>
References: <1422573351-5603-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Murali Karicheri <m-karicheri2@ti.com>
To: <w-kwok2@ti.com>, <davem@davemloft.net>, <mugunthanvnm@ti.com>,
	<tony@atomide.com>, <prabhakar.csengg@gmail.com>,
	<grygorii.strashko@ti.com>, <lokeshvutla@ti.com>,
	<mpa@pengutronix.de>, <lsorense@csclub.uwaterloo.ca>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422573351-5603-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetCP on Keystone has cpsw ale function similar to other TI SoCs
and this driver is re-used. To allow both ti cpsw and keystone netcp
to re-use the driver, convert the cpsw ale to a module and configure
it through Kconfig option CONFIG_TI_CPSW_ALE. Currently it is statically
linked to both TI CPSW and NetCP and this causes issues when the above
drivers are built as dynamic modules. This patch addresses this issue

While at it, fix the Makefile and code to build both netcp_core and
netcp_ethss as dynamic modules. This is needed to support arm allmodconfig.
This also requires exporting of API calls provided by netcp_core so that
both the above can be dynamic modules.

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/net/ethernet/ti/Kconfig       |   19 +++++++++++++++++--
 drivers/net/ethernet/ti/Makefile      |    8 +++++---
 drivers/net/ethernet/ti/cpsw_ale.c    |   26 ++++++++++++++++++++++++--
 drivers/net/ethernet/ti/netcp_core.c  |    8 ++++++++
 drivers/net/ethernet/ti/netcp_ethss.c |    5 +++++
 5 files changed, 59 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index 4ea1663..3bc992c 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -56,12 +56,18 @@ config TI_CPSW_PHY_SEL
 	  This driver supports configuring of the phy mode connected to
 	  the CPSW.
 
+config TI_CPSW_ALE
+	tristate "TI CPSW ALE Support"
+	---help---
+	  This driver supports TI's CPSW ALE module.
+
 config TI_CPSW
 	tristate "TI CPSW Switch Support"
 	depends on ARCH_DAVINCI || ARCH_OMAP2PLUS
 	select TI_DAVINCI_CPDMA
 	select TI_DAVINCI_MDIO
 	select TI_CPSW_PHY_SEL
+	select TI_CPSW_ALE
 	select MFD_SYSCON
 	select REGMAP
 	---help---
@@ -80,15 +86,24 @@ config TI_CPTS
 	  and Layer 2 packets, and the driver offers a PTP Hardware Clock.
 
 config TI_KEYSTONE_NETCP
-	tristate "TI Keystone NETCP Ethernet subsystem Support"
+	tristate "TI Keystone NETCP Core Support"
+	select TI_CPSW_ALE
 	depends on OF
 	depends on KEYSTONE_NAVIGATOR_DMA && KEYSTONE_NAVIGATOR_QMSS
 	---help---
-	  This driver supports TI's Keystone NETCP Ethernet subsystem.
+	  This driver supports TI's Keystone NETCP Core.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called keystone_netcp.
 
+config TI_KEYSTONE_NETCP_ETHSS
+	depends on TI_KEYSTONE_NETCP
+	tristate "TI Keystone NETCP Ethernet subsystem Support"
+	---help---
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called keystone_netcp_ethss.
+
 config TLAN
 	tristate "TI ThunderLAN support"
 	depends on (PCI || EISA)
diff --git a/drivers/net/ethernet/ti/Makefile b/drivers/net/ethernet/ti/Makefile
index 0a9813b..02ddad5 100644
--- a/drivers/net/ethernet/ti/Makefile
+++ b/drivers/net/ethernet/ti/Makefile
@@ -8,9 +8,11 @@ obj-$(CONFIG_TI_DAVINCI_EMAC) += davinci_emac.o
 obj-$(CONFIG_TI_DAVINCI_MDIO) += davinci_mdio.o
 obj-$(CONFIG_TI_DAVINCI_CPDMA) += davinci_cpdma.o
 obj-$(CONFIG_TI_CPSW_PHY_SEL) += cpsw-phy-sel.o
+obj-$(CONFIG_TI_CPSW_ALE) += cpsw_ale.o
 obj-$(CONFIG_TI_CPSW) += ti_cpsw.o
-ti_cpsw-y := cpsw_ale.o cpsw.o cpts.o
+ti_cpsw-y := cpsw.o cpts.o
 
 obj-$(CONFIG_TI_KEYSTONE_NETCP) += keystone_netcp.o
-keystone_netcp-y := netcp_core.o netcp_ethss.o	netcp_sgmii.o \
-			netcp_xgbepcsr.o cpsw_ale.o
+keystone_netcp-y := netcp_core.o
+obj-$(CONFIG_TI_KEYSTONE_NETCP_ETHSS) += keystone_netcp_ethss.o
+keystone_netcp_ethss-y := netcp_ethss.o netcp_sgmii.o netcp_xgbepcsr.o
diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
index 5246b3a..6e927b4 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.c
+++ b/drivers/net/ethernet/ti/cpsw_ale.c
@@ -13,6 +13,7 @@
  * GNU General Public License for more details.
  */
 #include <linux/kernel.h>
+#include <linux/module.h>
 #include <linux/platform_device.h>
 #include <linux/seq_file.h>
 #include <linux/slab.h>
@@ -146,7 +147,7 @@ static int cpsw_ale_write(struct cpsw_ale *ale, int idx, u32 *ale_entry)
 	return idx;
 }
 
-int cpsw_ale_match_addr(struct cpsw_ale *ale, u8 *addr, u16 vid)
+static int cpsw_ale_match_addr(struct cpsw_ale *ale, u8 *addr, u16 vid)
 {
 	u32 ale_entry[ALE_ENTRY_WORDS];
 	int type, idx;
@@ -167,7 +168,7 @@ int cpsw_ale_match_addr(struct cpsw_ale *ale, u8 *addr, u16 vid)
 	return -ENOENT;
 }
 
-int cpsw_ale_match_vlan(struct cpsw_ale *ale, u16 vid)
+static int cpsw_ale_match_vlan(struct cpsw_ale *ale, u16 vid)
 {
 	u32 ale_entry[ALE_ENTRY_WORDS];
 	int type, idx;
@@ -265,6 +266,7 @@ int cpsw_ale_flush_multicast(struct cpsw_ale *ale, int port_mask, int vid)
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpsw_ale_flush_multicast);
 
 static void cpsw_ale_flush_ucast(struct cpsw_ale *ale, u32 *ale_entry,
 				 int port_mask)
@@ -297,6 +299,7 @@ int cpsw_ale_flush(struct cpsw_ale *ale, int port_mask)
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpsw_ale_flush);
 
 static inline void cpsw_ale_set_vlan_entry_type(u32 *ale_entry,
 						int flags, u16 vid)
@@ -334,6 +337,7 @@ int cpsw_ale_add_ucast(struct cpsw_ale *ale, u8 *addr, int port,
 	cpsw_ale_write(ale, idx, ale_entry);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpsw_ale_add_ucast);
 
 int cpsw_ale_del_ucast(struct cpsw_ale *ale, u8 *addr, int port,
 		       int flags, u16 vid)
@@ -349,6 +353,7 @@ int cpsw_ale_del_ucast(struct cpsw_ale *ale, u8 *addr, int port,
 	cpsw_ale_write(ale, idx, ale_entry);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpsw_ale_del_ucast);
 
 int cpsw_ale_add_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
 		       int flags, u16 vid, int mcast_state)
@@ -380,6 +385,7 @@ int cpsw_ale_add_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
 	cpsw_ale_write(ale, idx, ale_entry);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpsw_ale_add_mcast);
 
 int cpsw_ale_del_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
 		       int flags, u16 vid)
@@ -401,6 +407,7 @@ int cpsw_ale_del_mcast(struct cpsw_ale *ale, u8 *addr, int port_mask,
 	cpsw_ale_write(ale, idx, ale_entry);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpsw_ale_del_mcast);
 
 int cpsw_ale_add_vlan(struct cpsw_ale *ale, u16 vid, int port, int untag,
 		      int reg_mcast, int unreg_mcast)
@@ -430,6 +437,7 @@ int cpsw_ale_add_vlan(struct cpsw_ale *ale, u16 vid, int port, int untag,
 	cpsw_ale_write(ale, idx, ale_entry);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpsw_ale_add_vlan);
 
 int cpsw_ale_del_vlan(struct cpsw_ale *ale, u16 vid, int port_mask)
 {
@@ -450,6 +458,7 @@ int cpsw_ale_del_vlan(struct cpsw_ale *ale, u16 vid, int port_mask)
 	cpsw_ale_write(ale, idx, ale_entry);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpsw_ale_del_vlan);
 
 void cpsw_ale_set_allmulti(struct cpsw_ale *ale, int allmulti)
 {
@@ -479,6 +488,7 @@ void cpsw_ale_set_allmulti(struct cpsw_ale *ale, int allmulti)
 		cpsw_ale_write(ale, idx, ale_entry);
 	}
 }
+EXPORT_SYMBOL_GPL(cpsw_ale_set_allmulti);
 
 struct ale_control_info {
 	const char	*name;
@@ -704,6 +714,7 @@ int cpsw_ale_control_set(struct cpsw_ale *ale, int port, int control,
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpsw_ale_control_set);
 
 int cpsw_ale_control_get(struct cpsw_ale *ale, int port, int control)
 {
@@ -727,6 +738,7 @@ int cpsw_ale_control_get(struct cpsw_ale *ale, int port, int control)
 	tmp = __raw_readl(ale->params.ale_regs + offset) >> shift;
 	return tmp & BITMASK(info->bits);
 }
+EXPORT_SYMBOL_GPL(cpsw_ale_control_get);
 
 static void cpsw_ale_timer(unsigned long arg)
 {
@@ -750,6 +762,7 @@ int cpsw_ale_set_ageout(struct cpsw_ale *ale, int ageout)
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpsw_ale_set_ageout);
 
 void cpsw_ale_start(struct cpsw_ale *ale)
 {
@@ -769,11 +782,13 @@ void cpsw_ale_start(struct cpsw_ale *ale)
 		add_timer(&ale->timer);
 	}
 }
+EXPORT_SYMBOL_GPL(cpsw_ale_start);
 
 void cpsw_ale_stop(struct cpsw_ale *ale)
 {
 	del_timer_sync(&ale->timer);
 }
+EXPORT_SYMBOL_GPL(cpsw_ale_stop);
 
 struct cpsw_ale *cpsw_ale_create(struct cpsw_ale_params *params)
 {
@@ -788,6 +803,7 @@ struct cpsw_ale *cpsw_ale_create(struct cpsw_ale_params *params)
 
 	return ale;
 }
+EXPORT_SYMBOL_GPL(cpsw_ale_create);
 
 int cpsw_ale_destroy(struct cpsw_ale *ale)
 {
@@ -797,6 +813,7 @@ int cpsw_ale_destroy(struct cpsw_ale *ale)
 	kfree(ale);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpsw_ale_destroy);
 
 void cpsw_ale_dump(struct cpsw_ale *ale, u32 *data)
 {
@@ -807,3 +824,8 @@ void cpsw_ale_dump(struct cpsw_ale *ale, u32 *data)
 		data += ALE_ENTRY_WORDS;
 	}
 }
+EXPORT_SYMBOL_GPL(cpsw_ale_dump);
+
+MODULE_LICENSE("GPL v2");
+MODULE_DESCRIPTION("TI CPSW ALE driver");
+MODULE_AUTHOR("Texas Instruments");
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index ba3002e..a31a8c3 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -354,6 +354,7 @@ fail:
 	netcp_unregister_module(module);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(netcp_register_module);
 
 static void netcp_release_module(struct netcp_device *netcp_device,
 				 struct netcp_module *module)
@@ -414,6 +415,7 @@ void netcp_unregister_module(struct netcp_module *module)
 
 	mutex_unlock(&netcp_modules_lock);
 }
+EXPORT_SYMBOL_GPL(netcp_unregister_module);
 
 void *netcp_module_get_intf_data(struct netcp_module *module,
 				 struct netcp_intf *intf)
@@ -425,6 +427,7 @@ void *netcp_module_get_intf_data(struct netcp_module *module,
 			return intf_modpriv->module_priv;
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(netcp_module_get_intf_data);
 
 /* Module TX and RX Hook management */
 struct netcp_hook_list {
@@ -459,6 +462,7 @@ int netcp_register_txhook(struct netcp_intf *netcp_priv, int order,
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(netcp_register_txhook);
 
 int netcp_unregister_txhook(struct netcp_intf *netcp_priv, int order,
 			    netcp_hook_rtn *hook_rtn, void *hook_data)
@@ -480,6 +484,7 @@ int netcp_unregister_txhook(struct netcp_intf *netcp_priv, int order,
 	spin_unlock_irqrestore(&netcp_priv->lock, flags);
 	return -ENOENT;
 }
+EXPORT_SYMBOL_GPL(netcp_unregister_txhook);
 
 int netcp_register_rxhook(struct netcp_intf *netcp_priv, int order,
 			  netcp_hook_rtn *hook_rtn, void *hook_data)
@@ -1226,6 +1231,7 @@ int netcp_txpipe_close(struct netcp_tx_pipe *tx_pipe)
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(netcp_txpipe_close);
 
 int netcp_txpipe_open(struct netcp_tx_pipe *tx_pipe)
 {
@@ -1267,6 +1273,7 @@ err:
 	tx_pipe->dma_channel = NULL;
 	return ret;
 }
+EXPORT_SYMBOL_GPL(netcp_txpipe_open);
 
 int netcp_txpipe_init(struct netcp_tx_pipe *tx_pipe,
 		      struct netcp_device *netcp_device,
@@ -1278,6 +1285,7 @@ int netcp_txpipe_init(struct netcp_tx_pipe *tx_pipe,
 	tx_pipe->dma_queue_id = dma_queue_id;
 	return 0;
 }
+EXPORT_SYMBOL_GPL(netcp_txpipe_init);
 
 static struct netcp_addr *netcp_addr_find(struct netcp_intf *netcp,
 					  const u8 *addr,
diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index fa1041a..345cd25 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -19,6 +19,7 @@
  */
 
 #include <linux/io.h>
+#include <linux/module.h>
 #include <linux/of_mdio.h>
 #include <linux/of_address.h>
 #include <linux/if_vlan.h>
@@ -2154,3 +2155,7 @@ static void __exit keystone_gbe_exit(void)
 	netcp_unregister_module(&xgbe_module);
 }
 module_exit(keystone_gbe_exit);
+
+MODULE_LICENSE("GPL v2");
+MODULE_DESCRIPTION("TI NETCP ETHSS driver for Keystone SOCs");
+MODULE_AUTHOR("Sandeep Nair <sandeep_n@ti.com");
-- 
1.7.9.5
