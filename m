From: John Crispin <blogic@openwrt.org>
Subject: [RFC 8/8] net-next: ralink: add Kconfig and Makefile
Date: Sun, 22 Nov 2015 09:40:58 +0100
Message-ID: <1448181658-38111-8-git-send-email-blogic@openwrt.org>
References: <1448181658-38111-1-git-send-email-blogic@openwrt.org>
Cc: netdev@vger.kernel.org, Michael Lee <igvtee@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>,
	=?UTF-8?q?Steven=20Liu=20=28=E5=8A=89=E4=BA=BA=E8=B1=AA=29?=
	<steven.liu@mediatek.com>,
	=?UTF-8?q?Fred=20Chang=20=28=E5=BC=B5=E5=98=89=E5=AE=8F=29?=
	<Fred.Chang@mediatek.com>, John Crispin <blogic@openwrt.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:46204 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751405AbbKVIli (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Nov 2015 03:41:38 -0500
In-Reply-To: <1448181658-38111-1-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the Makefile and Kconfig required to make the driver build.

Signed-off-by: John Crispin <blogic@openwrt.org>
Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Michael Lee <igvtee@gmail.com>
---
 drivers/net/ethernet/Kconfig         |    1 +
 drivers/net/ethernet/Makefile        |    1 +
 drivers/net/ethernet/ralink/Kconfig  |   49 ++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/ralink/Makefile |   19 +++++++++++++
 4 files changed, 70 insertions(+)
 create mode 100644 drivers/net/ethernet/ralink/Kconfig
 create mode 100644 drivers/net/ethernet/ralink/Makefile

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 955d06b..2d24101 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -153,6 +153,7 @@ source "drivers/net/ethernet/packetengines/Kconfig"
 source "drivers/net/ethernet/pasemi/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/qualcomm/Kconfig"
+source "drivers/net/ethernet/ralink/Kconfig"
 source "drivers/net/ethernet/realtek/Kconfig"
 source "drivers/net/ethernet/renesas/Kconfig"
 source "drivers/net/ethernet/rdc/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 4a2ee98..fba816c 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -63,6 +63,7 @@ obj-$(CONFIG_NET_PACKET_ENGINE) += packetengines/
 obj-$(CONFIG_NET_VENDOR_PASEMI) += pasemi/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_QUALCOMM) += qualcomm/
+obj-$(CONFIG_NET_RALINK) += ralink/
 obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
 obj-$(CONFIG_NET_VENDOR_RENESAS) += renesas/
 obj-$(CONFIG_NET_VENDOR_RDC) += rdc/
diff --git a/drivers/net/ethernet/ralink/Kconfig b/drivers/net/ethernet/ralink/Kconfig
new file mode 100644
index 0000000..09639cd
--- /dev/null
+++ b/drivers/net/ethernet/ralink/Kconfig
@@ -0,0 +1,49 @@
+config NET_RALINK
+	tristate "Ralink ethernet driver"
+	depends on RALINK
+	help
+	  This driver supports the ethernet mac inside the ralink wisocs
+
+if NET_RALINK
+choice
+	prompt "MAC type"
+
+config NET_RALINK_RT2880
+	bool "RT2882"
+	depends on SOC_RT288X
+
+config NET_RALINK_RT3050
+	bool "RT3050/MT7628"
+	depends on (SOC_RT305X || SOC_MT7620)
+
+config NET_RALINK_RT3883
+	bool "RT3883"
+	depends on SOC_RT3883
+
+config NET_RALINK_MT7620
+	bool "MT7620"
+	depends on (SOC_MT7620 || SOC_MT7621)
+
+endchoice
+
+config NET_RALINK_MDIO
+	def_bool NET_RALINK
+	depends on (NET_RALINK_RT2880 || NET_RALINK_RT3883 || NET_RALINK_MT7620 || NET_RALINK_MT7621)
+	select PHYLIB
+
+config NET_RALINK_MDIO_RT2880
+	def_bool NET_RALINK
+	depends on (NET_RALINK_RT2880 || NET_RALINK_RT3883)
+	select NET_RALINK_MDIO
+
+config NET_RALINK_ESW_RT3050
+	def_bool NET_RALINK
+	depends on NET_RALINK_RT3050
+	select PHYLIB
+
+config NET_RALINK_GSW_MT7620
+	def_bool NET_RALINK
+	depends on NET_RALINK_MT7620 || NET_RALINK_MT7621
+	select NET_RALINK_MDIO
+	select PHYLIB
+endif
diff --git a/drivers/net/ethernet/ralink/Makefile b/drivers/net/ethernet/ralink/Makefile
new file mode 100644
index 0000000..eb90c56
--- /dev/null
+++ b/drivers/net/ethernet/ralink/Makefile
@@ -0,0 +1,19 @@
+#
+# Makefile for the Ralink SoCs built-in ethernet macs
+#
+
+ralink-eth-y					+= ralink_soc_eth.o ralink_ethtool.o
+
+ralink-eth-$(CONFIG_NET_RALINK_MDIO)		+= mdio.o
+ralink-eth-$(CONFIG_NET_RALINK_MDIO_RT2880)	+= mdio_rt2880.o
+
+ralink-eth-$(CONFIG_NET_RALINK_ESW_RT3050)	+= esw_rt3050.o
+ralink-eth-$(CONFIG_NET_RALINK_GSW_MT7620)	+= gsw_mt7620.o
+
+ralink-eth-$(CONFIG_NET_RALINK_RT2880)		+= soc_rt2880.o
+ralink-eth-$(CONFIG_NET_RALINK_RT3050)		+= soc_rt3050.o
+ralink-eth-$(CONFIG_NET_RALINK_RT3883)		+= soc_rt3883.o
+ralink-eth-$(CONFIG_NET_RALINK_MT7620)		+= soc_mt7620.o
+ralink-eth-$(CONFIG_NET_RALINK_MT7621)		+= soc_mt7621.o
+
+obj-$(CONFIG_NET_RALINK)			+= ralink-eth.o
-- 
1.7.10.4
