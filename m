From: John Crispin <blogic@openwrt.org>
Subject: [PATCH 11/12] net-next: mediatek: add Kconfig and Makefile
Date: Sun,  3 Jan 2016 16:26:14 +0100
Message-ID: <1451834775-15789-11-git-send-email-blogic@openwrt.org>
References: <1451834775-15789-1-git-send-email-blogic@openwrt.org>
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	linux-mediatek@lists.infradead.org,
	John Crispin <blogic@openwrt.org>,
	Felix Fietkau <nbd@nbd.name>, Michael Lee <igvtee@gmail.com>,
	=?UTF-8?q?Steven=20Liu=20=28=E5=8A=89=E4=BA=BA=E8=B1=AA=29?=
	<steven.liu@mediatek.com>,
	=?UTF-8?q?Fred=20Chang=20=28=E5=BC=B5=E5=98=89=E5=AE=8F=29?=
	<Fred.Chang@mediatek.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:55388 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752073AbcACP12 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jan 2016 10:27:28 -0500
In-Reply-To: <1451834775-15789-1-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the Makefile and Kconfig required to make the driver build.

Signed-off-by: John Crispin <blogic@openwrt.org>
Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Michael Lee <igvtee@gmail.com>
---
 drivers/net/ethernet/Kconfig           |    1 +
 drivers/net/ethernet/Makefile          |    1 +
 drivers/net/ethernet/mediatek/Kconfig  |   62 ++++++++++++++++++++++++++++++++
 drivers/net/ethernet/mediatek/Makefile |   20 +++++++++++
 4 files changed, 84 insertions(+)
 create mode 100644 drivers/net/ethernet/mediatek/Kconfig
 create mode 100644 drivers/net/ethernet/mediatek/Makefile

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 955d06b..5302f81 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -105,6 +105,7 @@ config LANTIQ_ETOP
 	  Support for the MII0 inside the Lantiq SoC
 
 source "drivers/net/ethernet/marvell/Kconfig"
+source "drivers/net/ethernet/mediatek/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/micrel/Kconfig"
 source "drivers/net/ethernet/microchip/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 4a2ee98..ecc16c2 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -45,6 +45,7 @@ obj-$(CONFIG_JME) += jme.o
 obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_LANTIQ_ETOP) += lantiq_etop.o
 obj-$(CONFIG_NET_VENDOR_MARVELL) += marvell/
+obj-$(CONFIG_NET_VENDOR_MEDIATEK) += mediatek/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
 obj-$(CONFIG_NET_VENDOR_MICROCHIP) += microchip/
diff --git a/drivers/net/ethernet/mediatek/Kconfig b/drivers/net/ethernet/mediatek/Kconfig
new file mode 100644
index 0000000..cf883c4
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/Kconfig
@@ -0,0 +1,62 @@
+config NET_VENDOR_MEDIATEK
+	tristate "Mediatek/Ralink ethernet driver"
+	depends on RALINK
+	help
+	  This driver supports the ethernet mac inside the Mediatek and Ralink WiSoCs
+
+config NET_MEDIATEK_SOC
+	def_tristate NET_VENDOR_MEDIATEK
+
+if NET_MEDIATEK_SOC
+choice
+	prompt "MAC type"
+
+config NET_MEDIATEK_RT2880
+	bool "RT2882"
+	depends on MIPS && SOC_RT288X
+
+config NET_MEDIATEK_RT3050
+	bool "RT3050/MT7628"
+	depends on MIPS && (SOC_RT305X || SOC_MT7620)
+
+config NET_MEDIATEK_RT3883
+	bool "RT3883"
+	depends on MIPS && SOC_RT3883
+
+config NET_MEDIATEK_MT7620
+	bool "MT7620"
+	depends on MIPS && SOC_MT7620
+
+config NET_MEDIATEK_MT7621
+	bool "MT7621"
+	depends on MIPS && SOC_MT7621
+
+endchoice
+
+config NET_MEDIATEK_MDIO
+	def_bool NET_MEDIATEK_SOC
+	depends on (NET_MEDIATEK_RT2880 || NET_MEDIATEK_RT3883 || NET_MEDIATEK_MT7620 || NET_MEDIATEK_MT7621)
+	select PHYLIB
+
+config NET_MEDIATEK_MDIO_RT2880
+	def_bool NET_MEDIATEK_SOC
+	depends on (NET_MEDIATEK_RT2880 || NET_MEDIATEK_RT3883)
+	select NET_MEDIATEK_MDIO
+
+config NET_MEDIATEK_MDIO_MT7620
+	def_bool NET_MEDIATEK_SOC
+	depends on (NET_MEDIATEK_MT7620 || NET_MEDIATEK_MT7621)
+	select NET_MEDIATEK_MDIO
+
+config NET_MEDIATEK_ESW_RT3050
+	def_tristate NET_MEDIATEK_SOC
+	depends on NET_MEDIATEK_RT3050
+
+config NET_MEDIATEK_GSW_MT7620
+	def_tristate NET_MEDIATEK_SOC
+	depends on NET_MEDIATEK_MT7620
+
+config NET_MEDIATEK_GSW_MT7621
+	def_tristate NET_MEDIATEK_SOC
+	depends on NET_MEDIATEK_MT7621
+endif
diff --git a/drivers/net/ethernet/mediatek/Makefile b/drivers/net/ethernet/mediatek/Makefile
new file mode 100644
index 0000000..c4d2dfb
--- /dev/null
+++ b/drivers/net/ethernet/mediatek/Makefile
@@ -0,0 +1,20 @@
+#
+# Makefile for the Ralink SoCs built-in ethernet macs
+#
+
+mtk-eth-soc-y					+= mtk_eth_soc.o ethtool.o
+
+mtk-eth-soc-$(CONFIG_NET_MEDIATEK_MDIO)		+= mdio.o
+mtk-eth-soc-$(CONFIG_NET_MEDIATEK_MDIO_RT2880)	+= mdio_rt2880.o
+mtk-eth-soc-$(CONFIG_NET_MEDIATEK_MDIO_MT7620)	+= mdio_mt7620.o
+
+mtk-eth-soc-$(CONFIG_NET_MEDIATEK_RT2880)	+= soc_rt2880.o
+mtk-eth-soc-$(CONFIG_NET_MEDIATEK_RT3050)	+= soc_rt3050.o
+mtk-eth-soc-$(CONFIG_NET_MEDIATEK_RT3883)	+= soc_rt3883.o
+mtk-eth-soc-$(CONFIG_NET_MEDIATEK_MT7620)	+= soc_mt7620.o
+mtk-eth-soc-$(CONFIG_NET_MEDIATEK_MT7621)	+= soc_mt7621.o
+
+obj-$(CONFIG_NET_MEDIATEK_ESW_RT3050)		+= esw_rt3050.o
+obj-$(CONFIG_NET_MEDIATEK_GSW_MT7620)		+= gsw_mt7620.o
+obj-$(CONFIG_NET_MEDIATEK_GSW_MT7621)		+= gsw_mt7621.o
+obj-$(CONFIG_NET_MEDIATEK_SOC)			+= mtk-eth-soc.o
-- 
1.7.10.4
