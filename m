From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 7/7] net: add a flexray driver
Date: Tue, 13 Aug 2013 11:08:42 +0200
Message-ID: <1376384922-8519-9-git-send-email-b.spranger@linutronix.de>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:48308 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755925Ab3HMJJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 05:09:04 -0400
In-Reply-To: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides the netlink interface support for flexray, the firs=
t
hardware based driver and a virtual flexray driver which has been
modelled after the virtual can driver.

Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
---
 drivers/net/Makefile              |    1 +
 drivers/net/flexray/Kconfig       |   41 +
 drivers/net/flexray/Makefile      |   12 +
 drivers/net/flexray/dev.c         |  700 +++++++++++
 drivers/net/flexray/flexcard_fr.c | 2480 +++++++++++++++++++++++++++++=
++++++++
 drivers/net/flexray/vflexray.c    |   99 ++
 net/flexray/Kconfig               |    2 +
 7 files changed, 3335 insertions(+)
 create mode 100644 drivers/net/flexray/Kconfig
 create mode 100644 drivers/net/flexray/Makefile
 create mode 100644 drivers/net/flexray/dev.c
 create mode 100644 drivers/net/flexray/flexcard_fr.c
 create mode 100644 drivers/net/flexray/vflexray.c

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3fef8a8..22d9018 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -35,6 +35,7 @@ obj-$(CONFIG_ETRAX_ETHERNET) +=3D cris/
 obj-$(CONFIG_NET_DSA) +=3D dsa/
 obj-$(CONFIG_ETHERNET) +=3D ethernet/
 obj-$(CONFIG_FDDI) +=3D fddi/
+obj-$(CONFIG_FLEXRAY) +=3D flexray/
 obj-$(CONFIG_HIPPI) +=3D hippi/
 obj-$(CONFIG_HAMRADIO) +=3D hamradio/
 obj-$(CONFIG_IRDA) +=3D irda/
diff --git a/drivers/net/flexray/Kconfig b/drivers/net/flexray/Kconfig
new file mode 100644
index 0000000..091e6e4
--- /dev/null
+++ b/drivers/net/flexray/Kconfig
@@ -0,0 +1,41 @@
+menu "FlexRay Device Drivers"
+	depends on FLEXRAY
+
+config FLEXRAY_VFLEXRAY
+	tristate "Virtual Local FlexRay Interface (vflexray)"
+	depends on FLEXRAY
+	---help---
+	  Similar to the network loopback devices, vflexray offers a
+	  virtual local FlexRay interface.
+
+	  This driver can also be built as a module.  If so, the module
+	  will be called vflexray.
+
+config FLEXRAY_DEV
+	tristate "Platform FlexRay drivers with Netlink support"
+	depends on FLEXRAY
+	default y
+	---help---
+	  Enables the common framework for platform FlexRay drivers with
+	  Netlink support. This is the standard library for FlexRay drivers.
+	  If unsure, say Y.
+
+config FLEXRAY_FLEXCARD
+	tristate "Support for the Flexcard FlexRay function"
+	depends on FLEXRAY_DEV
+	---help---
+	  Driver for Ebersp=C3=A4cher FlexCard PMC II, it supports Flexray an=
d
+	  CAN busses.
+	  This driver can also be built as a module. If so, the module
+	  will be called flexcard_fr.
+
+config FLEXRAY_DEBUG_DEVICES
+	bool "FlexRay devices debugging messages"
+	depends on FLEXRAY
+	---help---
+	  Say Y here if you want the Flexray device drivers to produce a bunc=
h
+	  of debug messages to the system log.  Select this if you are having
+	  a problem with FlexRay support and want to see more of what is goin=
g
+	  on.
+
+endmenu
diff --git a/drivers/net/flexray/Makefile b/drivers/net/flexray/Makefil=
e
new file mode 100644
index 0000000..97e2538
--- /dev/null
+++ b/drivers/net/flexray/Makefile
@@ -0,0 +1,12 @@
+#
+#  Makefile for the Linux FlexRay drivers.
+#
+
+obj-$(CONFIG_FLEXRAY_VFLEXRAY)		+=3D vflexray.o
+
+obj-$(CONFIG_FLEXRAY_DEV)		+=3D flexray-dev.o
+flexray-dev-y				:=3D dev.o
+
+obj-$(CONFIG_FLEXRAY_FLEXCARD)		+=3D flexcard_fr.o
+
+ccflags-$(CONFIG_FLEXRAY_DEBUG_DEVICES) :=3D -DDEBUG
diff --git a/drivers/net/flexray/dev.c b/drivers/net/flexray/dev.c
new file mode 100644
index 0000000..e882d16
--- /dev/null
+++ b/drivers/net/flexray/dev.c
@@ -0,0 +1,700 @@
+/* Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved.
+ *
+ * valid flexray paramter ranges are from
+ * FlexRay - Protocol Specification - V2.1rev A
+ * FlexRay - Protocol Specification - V3.0.1
+ * eray-specific: Bosch E-Ray FlexRay IP-Module, User's Manual,
+ *		  Revision 1.2.7 (06.02.2009)
+*/
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/flexray.h>
+#include <linux/flexray/dev.h>
+#include <linux/flexray/netlink.h>
+#include <net/rtnetlink.h>
+
+static int flexray_check_cluster_params(struct flexray_cluster_param *=
cp,
+					struct net_device *dev);
+static int flexray_check_node_params(struct flexray_node_param *np,
+				     struct net_device *dev);
+
+static void flexray_setup(struct net_device *dev)
+{
+	dev->type =3D ARPHRD_FLEXRAY;
+	dev->mtu =3D sizeof(struct flexray_frame);
+	dev->hard_header_len =3D 0;
+	dev->addr_len =3D 0;
+	dev->tx_queue_len =3D 10;
+	dev->flags =3D IFF_NOARP;
+	dev->features =3D NETIF_F_HW_CSUM;
+}
+
+struct sk_buff *alloc_flexray_skb(struct net_device *dev,
+				  struct flexray_frame **cf)
+{
+	struct sk_buff *skb;
+
+	skb =3D netdev_alloc_skb(dev, sizeof(struct flexray_frame));
+	if (unlikely(!skb))
+		return NULL;
+
+	skb->protocol =3D htons(ETH_P_FLEXRAY);
+	skb->pkt_type =3D PACKET_BROADCAST;
+	skb->ip_summed =3D CHECKSUM_UNNECESSARY;
+	*cf =3D (struct flexray_frame *)skb_put(skb,
+					      sizeof(struct flexray_frame));
+	memset(*cf, 0, sizeof(struct flexray_frame));
+
+	return skb;
+}
+EXPORT_SYMBOL_GPL(alloc_flexray_skb);
+
+/* Allocate and setup space for the FLEXRAY network device */
+struct net_device *alloc_flexraydev(int sizeof_priv, u8 version)
+{
+	struct net_device *dev;
+	struct flexray_priv *priv;
+
+	if (version !=3D 2 && version !=3D 3)
+		return NULL;
+
+	/* 3 TXs queues: Key, Fixed, Dynamic */
+	dev =3D alloc_netdev_mqs(sizeof_priv, "flexray%d", flexray_setup, 3, =
1);
+	if (!dev)
+		return NULL;
+
+	priv =3D netdev_priv(dev);
+	priv->state =3D FLEXRAY_STATE_UNSPEC;
+	priv->version =3D version;
+
+	return dev;
+}
+EXPORT_SYMBOL_GPL(alloc_flexraydev);
+
+/* Free space of the FLEXRAY network device */
+void free_flexraydev(struct net_device *dev)
+{
+	free_netdev(dev);
+}
+EXPORT_SYMBOL_GPL(free_flexraydev);
+
+int open_flexraydev(struct net_device *dev)
+{
+	/* Switch carrier on if device was stopped while in bus-off state */
+	if (!netif_carrier_ok(dev))
+		netif_carrier_on(dev);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(open_flexraydev);
+
+void close_flexraydev(struct net_device *dev)
+{
+}
+EXPORT_SYMBOL_GPL(close_flexraydev);
+
+/* debug functionality */
+
+#define PRINT_PARAM(name, p)	pr_debug(#name" =3D %d\n", p->name);
+
+void print_cluster_config(struct flexray_cluster_param *cp, int is_v3)
+{
+	pr_debug("Cluster configuration:\n");
+
+	PRINT_PARAM(gColdstartAttempts, cp);
+	PRINT_PARAM(gdActionPointOffset, cp);
+	PRINT_PARAM(gdCASRxLowMax, cp);
+	PRINT_PARAM(gdDynamicSlotIdlePhase, cp);
+	PRINT_PARAM(gdMinislot, cp);
+	PRINT_PARAM(gdMinislotActionPointOffset, cp);
+	PRINT_PARAM(gdStaticSlot, cp);
+	PRINT_PARAM(gdSymbolWindow, cp);
+	PRINT_PARAM(gdTSSTransmitter, cp);
+	PRINT_PARAM(gListenNoise, cp);
+	PRINT_PARAM(gMacroPerCycle, cp);
+	PRINT_PARAM(gMaxWithoutClockCorrectionFatal, cp);
+	PRINT_PARAM(gMaxWithoutClockCorrectionPassive, cp);
+	PRINT_PARAM(gNumberOfMinislots, cp);
+	PRINT_PARAM(gNumberOfStaticSlots, cp);
+	PRINT_PARAM(gPayloadLengthStatic, cp);
+	PRINT_PARAM(gChannels, cp);
+	PRINT_PARAM(gClusterDriftDamping, cp);
+	PRINT_PARAM(gdBit, cp);
+	PRINT_PARAM(gdCycle, cp);
+	PRINT_PARAM(gdMacrotick, cp);
+	PRINT_PARAM(gdNIT, cp);
+	PRINT_PARAM(gdSampleClockPeriod, cp);
+	PRINT_PARAM(gNetworkManagementVectorLength, cp);
+	if (!is_v3) {
+		PRINT_PARAM(v2.gAssumedPrecision, cp);
+		PRINT_PARAM(v2.gdMaxInitializationError, cp);
+		PRINT_PARAM(v2.gdMaxMicrotick, cp);
+		PRINT_PARAM(v2.gdMaxPropagationDelay, cp);
+		PRINT_PARAM(v2.gdMinPropagationDelay, cp);
+		PRINT_PARAM(v2.gdWakeupSymbolRxIdle, cp);
+		PRINT_PARAM(v2.gdWakeupSymbolRxLow, cp);
+		PRINT_PARAM(v2.gdWakeupSymbolRxWindow, cp);
+		PRINT_PARAM(v2.gdWakeupSymbolTxIdle, cp);
+		PRINT_PARAM(v2.gdWakeupSymbolTxLow, cp);
+		PRINT_PARAM(v2.gOffsetCorrectionMax, cp);
+		PRINT_PARAM(v2.gOffsetCorrectionStart, cp);
+		PRINT_PARAM(v2.gSyncNodeMax, cp);
+	} else {
+		PRINT_PARAM(v3.gClockDeviationMax, cp);
+		PRINT_PARAM(v3.gCycleCountMax, cp);
+		PRINT_PARAM(v3.gdIgnoreAfterTx, cp);
+		PRINT_PARAM(v3.gdSymbolWindowActionPointOffset, cp);
+		PRINT_PARAM(v3.gdWakeupRxIdle, cp);
+		PRINT_PARAM(v3.gdWakeupRxLow, cp);
+		PRINT_PARAM(v3.gdWakeupRxWindow, cp);
+		PRINT_PARAM(v3.gdWakeupTxActive, cp);
+		PRINT_PARAM(v3.gdWakeupTxIdle, cp);
+		PRINT_PARAM(v3.gExternOffsetCorrection, cp);
+		PRINT_PARAM(v3.gExternRateCorrection, cp);
+		PRINT_PARAM(v3.gSyncFrameIDCountMax, cp);
+	}
+}
+EXPORT_SYMBOL_GPL(print_cluster_config);
+
+void print_node_config(struct flexray_node_param *np, int is_v3)
+{
+	pr_debug("Node configuration:\n");
+
+	PRINT_PARAM(pAllowHaltDueToClock, np);
+	PRINT_PARAM(pAllowPassiveToActive, np);
+	PRINT_PARAM(pChannels, np);
+	PRINT_PARAM(pClusterDriftDamping, np);
+	PRINT_PARAM(pdAcceptedStartupRange, np);
+	PRINT_PARAM(pDecodingCorrection, np);
+	PRINT_PARAM(pDelayCompensationA, np);
+	PRINT_PARAM(pDelayCompensationB, np);
+	PRINT_PARAM(pdListenTimeout, np);
+	PRINT_PARAM(pExternOffsetCorrection, np);
+	PRINT_PARAM(pExternRateCorrection, np);
+	PRINT_PARAM(pKeySlotID, np);
+	PRINT_PARAM(pKeySlotUsedForStartup, np);
+	PRINT_PARAM(pKeySlotUsedForSync, np);
+	PRINT_PARAM(pLatestTx, np);
+	PRINT_PARAM(pMacroInitialOffsetA, np);
+	PRINT_PARAM(pMacroInitialOffsetB, np);
+	PRINT_PARAM(pMicroInitialOffsetA, np);
+	PRINT_PARAM(pMicroInitialOffsetB, np);
+	PRINT_PARAM(pMicroPerCycle, np);
+	PRINT_PARAM(vExternOffsetControl, np);
+	PRINT_PARAM(pOffsetCorrectionOut, np);
+	PRINT_PARAM(vExternRateControl, np);
+	PRINT_PARAM(pRateCorrectionOut, np);
+	PRINT_PARAM(pWakeupChannel, np);
+	PRINT_PARAM(pWakeupPattern, np);
+	PRINT_PARAM(pdMicrotick, np);
+	PRINT_PARAM(pPayloadLengthDynMax, np);
+	PRINT_PARAM(pSamplesPerMicrotick, np);
+
+	if (is_v3) {
+		PRINT_PARAM(v3.pExternalSync, np);
+		PRINT_PARAM(v3.pFallBackInternal, np);
+		PRINT_PARAM(v3.pKeySlotOnlyEnabled, np);
+		PRINT_PARAM(v3.pNMVectorEarlyUpdate, np);
+		PRINT_PARAM(v3.pOffsetCorrectionStart, np);
+		PRINT_PARAM(v3.pSecondKeySlotID, np);
+		PRINT_PARAM(v3.pTwoKeySlotMode, np);
+	} else {
+		PRINT_PARAM(v2.pdMaxDrift, np);
+		PRINT_PARAM(v2.pMicroPerMacroNom, np);
+		PRINT_PARAM(v2.pSingleSlotEnabled, np);
+	}
+}
+EXPORT_SYMBOL_GPL(print_node_config);
+
+void print_symbol_config(struct flexray_symbol_param *sp)
+{
+	pr_debug("Symbol configuration:\n");
+
+	PRINT_PARAM(pChannelsMTS, sp);
+}
+EXPORT_SYMBOL_GPL(print_symbol_config);
+
+/* Parameter check and set functions */
+
+#define FR_CHECK_PARAM(p, name, min, max)				\
+	do {								\
+		if (p->name < min || p->name > max) {			\
+			netdev_info(dev, #name" (0x%x) out of range\n",	\
+					p->name);			\
+			return -EINVAL;					\
+		}							\
+	} while (0)
+
+static int flexray_check_cluster_params(struct flexray_cluster_param *=
cp,
+					struct net_device *dev)
+{
+	struct flexray_priv *priv =3D netdev_priv(dev);
+
+	FR_CHECK_PARAM(cp, gColdstartAttempts, 2, 31);
+	FR_CHECK_PARAM(cp, gdActionPointOffset, 1, 63);
+	FR_CHECK_PARAM(cp, gdMinislot, 2, 63);
+	FR_CHECK_PARAM(cp, gdMinislotActionPointOffset, 1, 31);
+	FR_CHECK_PARAM(cp, gListenNoise, 2, 16);
+	FR_CHECK_PARAM(cp, gMacroPerCycle, 10, 16000);
+	FR_CHECK_PARAM(cp, gMaxWithoutClockCorrectionFatal, 1, 15);
+	FR_CHECK_PARAM(cp, gMaxWithoutClockCorrectionPassive, 1, 15);
+	FR_CHECK_PARAM(cp, gNumberOfMinislots, 0, 7986);
+	FR_CHECK_PARAM(cp, gNumberOfStaticSlots, 2, 1023);
+	FR_CHECK_PARAM(cp, gPayloadLengthStatic, 0, 127);
+	FR_CHECK_PARAM(cp, gClusterDriftDamping, 0, 5);
+	FR_CHECK_PARAM(cp, gdNIT, 2, 805);
+	FR_CHECK_PARAM(cp, gNetworkManagementVectorLength, 0, 12);
+	FR_CHECK_PARAM(cp, gdDynamicSlotIdlePhase, 0, 2);
+
+	if (priv->version =3D=3D 2) {
+		FR_CHECK_PARAM(cp, v2.gdMaxInitializationError, 0, 117);
+		FR_CHECK_PARAM(cp, v2.gdMinPropagationDelay, 0,
+			       cp->v2.gdMaxPropagationDelay);
+		FR_CHECK_PARAM(cp, v2.gdWakeupSymbolRxIdle, 14, 59);
+		FR_CHECK_PARAM(cp, v2.gdWakeupSymbolRxWindow, 76, 301);
+		FR_CHECK_PARAM(cp, v2.gdWakeupSymbolTxIdle, 45, 180);
+		FR_CHECK_PARAM(cp, v2.gdWakeupSymbolTxLow, 15, 60);
+		FR_CHECK_PARAM(cp, v2.gOffsetCorrectionStart, 9, 15999);
+		FR_CHECK_PARAM(cp, v2.gSyncNodeMax, 2, 15);
+		FR_CHECK_PARAM(cp, gdCASRxLowMax, 67, 99);
+		FR_CHECK_PARAM(cp, gdTSSTransmitter, 3, 15);
+#ifndef CONFIG_MFD_EBEL_FLEXCARD_PROTPARAM
+		FR_CHECK_PARAM(cp, v2.gdWakeupSymbolRxLow, 11, 59);
+		FR_CHECK_PARAM(cp, gdStaticSlot, 4, 661);
+#else
+		FR_CHECK_PARAM(cp, v2.gdWakeupSymbolRxLow, 10, 55);
+		FR_CHECK_PARAM(cp, gdStaticSlot, 4, 659);
+#endif /* CONFIG_MFD_EBEL_FLEXCARD_PROTPARAM */
+	}
+
+	if (priv->version =3D=3D 3) {
+		FR_CHECK_PARAM(cp, v3.gCycleCountMax, 7, 63);
+		FR_CHECK_PARAM(cp, v3.gdSymbolWindowActionPointOffset, 1, 63);
+		FR_CHECK_PARAM(cp, v3.gdWakeupRxIdle, 8, 59);
+		FR_CHECK_PARAM(cp, v3.gdWakeupRxLow, 8, 59);
+		FR_CHECK_PARAM(cp, v3.gdWakeupRxWindow, 76, 485);
+		FR_CHECK_PARAM(cp, v3.gdWakeupTxActive, 15, 60);
+		FR_CHECK_PARAM(cp, v3.gdWakeupTxIdle, 45, 180);
+		FR_CHECK_PARAM(cp, v3.gSyncFrameIDCountMax, 2, 15);
+		FR_CHECK_PARAM(cp, v3.gClockDeviationMax, 1, 1500);
+		FR_CHECK_PARAM(cp, v3.gExternOffsetCorrection, 0, 35);
+		FR_CHECK_PARAM(cp, v3.gdIgnoreAfterTx, 0, 15);
+		FR_CHECK_PARAM(cp, gdCASRxLowMax, 28, 254);
+		FR_CHECK_PARAM(cp, gdStaticSlot, 3, 664);
+		FR_CHECK_PARAM(cp, gdTSSTransmitter, 1, 15);
+		if (!(cp->v3.gCycleCountMax % 2)) {
+			netdev_info(dev, "gCycleCountMax is even\n");
+			return -EINVAL;
+		}
+	}
+
+	return 0;
+}
+
+static int flexray_set_cluster_params(struct flexray_cluster_param *cp=
,
+				      struct net_device *dev)
+{
+	struct flexray_priv *priv =3D netdev_priv(dev);
+
+	memcpy(&priv->cluster, cp, sizeof(*cp));
+
+	return 0;
+}
+
+static int
+flexray_check_and_set_cluster_params(struct flexray_cluster_param *cp,
+				     struct net_device *dev)
+{
+	int ret;
+
+	ret =3D flexray_check_cluster_params(cp, dev);
+	if (ret)
+		return ret;
+
+	return flexray_set_cluster_params(cp, dev);
+}
+
+static int flexray_check_node_params(struct flexray_node_param *np,
+				     struct net_device *dev)
+{
+	struct flexray_priv *priv =3D netdev_priv(dev);
+
+	FR_CHECK_PARAM(np, pAllowPassiveToActive, 0, 31);
+	FR_CHECK_PARAM(np, pClusterDriftDamping, 0, 20);
+	FR_CHECK_PARAM(np, pExternRateCorrection, 0, 28);
+	FR_CHECK_PARAM(np, vExternOffsetControl, -1, 1);
+	FR_CHECK_PARAM(np, vExternRateControl, -1, 1);
+	FR_CHECK_PARAM(np, pWakeupPattern, 2, 63);
+	FR_CHECK_PARAM(np, pPayloadLengthDynMax, 0, 254);
+	FR_CHECK_PARAM(np, pAllowPassiveToActive, 0, 31);
+	FR_CHECK_PARAM(np, pChannels, 0, 3);
+	FR_CHECK_PARAM(np, pWakeupChannel, 0, 3);
+	FR_CHECK_PARAM(np, pKeySlotUsedForStartup, 0, 1);
+	FR_CHECK_PARAM(np, pKeySlotUsedForSync, 0, 1);
+#ifndef CONFIG_MFD_EBEL_FLEXCARD_PROTPARAM
+	FR_CHECK_PARAM(np, pMacroInitialOffsetA, 2, 68);
+	FR_CHECK_PARAM(np, pMacroInitialOffsetB, 2, 68);
+	FR_CHECK_PARAM(np, pMicroInitialOffsetA, 0, 239);
+	FR_CHECK_PARAM(np, pMicroInitialOffsetB, 0, 239);
+#else
+	FR_CHECK_PARAM(np, pMacroInitialOffsetA, 2, 72);
+	FR_CHECK_PARAM(np, pMacroInitialOffsetB, 2, 72);
+	FR_CHECK_PARAM(np, pMicroInitialOffsetA, 0, 240);
+	FR_CHECK_PARAM(np, pMicroInitialOffsetB, 0, 240);
+#endif /* CONFIG_MFD_EBEL_FLEXCARD_PROTPARAM */
+
+	if (priv->version =3D=3D 2) {
+		FR_CHECK_PARAM(np, v2.pdMaxDrift, 2, 1923);
+		FR_CHECK_PARAM(np, pdAcceptedStartupRange, 0, 1875);
+		FR_CHECK_PARAM(np, pDecodingCorrection, 14, 143);
+		FR_CHECK_PARAM(np, pdListenTimeout, 1284, 1283846);
+		FR_CHECK_PARAM(np, pExternOffsetCorrection, 0, 7);
+		FR_CHECK_PARAM(np, pKeySlotID, 0, 1023);
+		FR_CHECK_PARAM(np, pMicroPerCycle, 640, 640000);
+		FR_CHECK_PARAM(np, pRateCorrectionOut, 2, 1923);
+#ifndef CONFIG_MFD_EBEL_FLEXCARD_PROTPARAM
+		FR_CHECK_PARAM(np, pLatestTx, 0, 7980);
+		FR_CHECK_PARAM(np, pOffsetCorrectionOut, 13, 15567);
+#else
+		FR_CHECK_PARAM(np, pLatestTx, 0, 7981);
+		FR_CHECK_PARAM(np, pOffsetCorrectionOut, 5, 15266);
+#endif /* CONFIG_MFD_EBEL_FLEXCARD_PROTPARAM */
+	}
+	if (priv->version =3D=3D 3) {
+		FR_CHECK_PARAM(np, v3.pOffsetCorrectionStart, 7, 15999);
+		FR_CHECK_PARAM(np, v3.pSecondKeySlotID, 0, 1023);
+		FR_CHECK_PARAM(np, pdAcceptedStartupRange, 29, 2743);
+		FR_CHECK_PARAM(np, pDecodingCorrection, 12, 136);
+		FR_CHECK_PARAM(np, pdListenTimeout, 1926, 2567692);
+		FR_CHECK_PARAM(np, pExternOffsetCorrection, 0, 28);
+		FR_CHECK_PARAM(np, pKeySlotID, 0, 1023);
+		FR_CHECK_PARAM(np, pMicroPerCycle, 960, 1280000);
+		FR_CHECK_PARAM(np, pRateCorrectionOut, 3, 3846);
+		FR_CHECK_PARAM(np, pLatestTx, 0, 7988);
+		FR_CHECK_PARAM(np, pOffsetCorrectionOut, 15, 16082);
+	}
+
+	return 0;
+}
+
+static int flexray_set_node_params(struct flexray_node_param *np,
+			    struct net_device *dev)
+{
+	struct flexray_priv *priv =3D netdev_priv(dev);
+
+	memcpy(&priv->node, np, sizeof(*np));
+
+	return 0;
+}
+
+static int flexray_check_and_set_node_params(struct flexray_node_param=
 *np,
+					     struct net_device *dev)
+{
+	int ret;
+
+	ret =3D flexray_check_node_params(np, dev);
+	if (ret)
+		return ret;
+
+	return flexray_set_node_params(np, dev);
+}
+
+static int flexray_check_symbol_params(struct flexray_symbol_param *sp=
,
+				       struct net_device *dev)
+{
+	FR_CHECK_PARAM(sp, pChannelsMTS, 0, 3);
+
+	return 0;
+}
+
+static int flexray_set_symbol_params(struct flexray_symbol_param *sp,
+				     struct net_device *dev)
+{
+	struct flexray_priv *priv =3D netdev_priv(dev);
+
+	memcpy(&priv->symbol, sp, sizeof(*sp));
+
+	return 0;
+}
+
+static int flexray_check_and_set_symbol_params(struct flexray_symbol_p=
aram *sp,
+					       struct net_device *dev)
+{
+	int ret;
+
+	ret =3D flexray_check_symbol_params(sp, dev);
+	if (ret)
+		return ret;
+
+	return flexray_set_symbol_params(sp, dev);
+}
+
+/* FLEXRAY netlink interface */
+static const struct nla_policy flexray_policy[IFLA_FLEXRAY_MAX + 1] =3D=
 {
+	[IFLA_FLEXRAY_STATE] =3D {.type =3D NLA_U32},
+	[IFLA_FLEXRAY_VERSION] =3D {.type =3D NLA_U8},
+	[IFLA_FLEXRAY_CLUSTER] =3D {.len =3D sizeof(struct flexray_cluster_pa=
ram)},
+	[IFLA_FLEXRAY_NODE] =3D {.len =3D sizeof(struct flexray_node_param)},
+	[IFLA_FLEXRAY_SYMBOL] =3D {.len =3D sizeof(struct flexray_symbol_para=
m)},
+	[IFLA_FLEXRAY_SW_FILTER] =3D {.type =3D NLA_NESTED},
+};
+
+static const struct nla_policy flexray_filt_pol[IFLA_FLEXRAY_FILTER_MA=
X + 1] =3D {
+	[IFLA_FLEXRAY_FILTER_ENTRY] =3D { .len =3D sizeof(struct flexray_filt=
er) },
+};
+
+static int validate_and_set_sw_filter(struct flexray_sw_filter *sw, u3=
2 *id)
+{
+	int i;
+
+	if (sw->pos >=3D FLEXRAY_MAX_SW_FILTER)
+		return -EINVAL;
+
+	if (sw->id !=3D 0)
+		for (i =3D 0; i < sw->pos; i++)
+			if (id[i] > sw->id)
+				return -EINVAL;
+
+	id[sw->pos] =3D sw->id;
+
+	return 0;
+}
+
+static int flexray_changelink(struct net_device *dev,
+			      struct nlattr *tb[], struct nlattr *data[])
+{
+	struct flexray_priv *priv =3D netdev_priv(dev);
+	struct nlattr *attr;
+	int rem, ret =3D 0;
+
+	/* We need synchronization with dev->stop() */
+	ASSERT_RTNL();
+
+	if (data[IFLA_FLEXRAY_STATE]) {
+		enum flexray_state state;
+
+		state =3D nla_get_u32(data[IFLA_FLEXRAY_STATE]);
+		if (priv->do_set_state)
+			ret =3D priv->do_set_state(dev, state);
+		if (ret)
+			return ret;
+		priv->state =3D state;
+	}
+
+	if (data[IFLA_FLEXRAY_CLUSTER]) {
+		struct flexray_cluster_param cp;
+
+		memcpy(&cp, nla_data(data[IFLA_FLEXRAY_CLUSTER]), sizeof(cp));
+		ret =3D flexray_check_and_set_cluster_params(&cp, dev);
+		if (ret)
+			return ret;
+	}
+
+	if (data[IFLA_FLEXRAY_NODE]) {
+		struct flexray_node_param np;
+
+		memcpy(&np, nla_data(data[IFLA_FLEXRAY_NODE]), sizeof(np));
+		ret =3D flexray_check_and_set_node_params(&np, dev);
+		if (ret)
+			return ret;
+	}
+
+	if (data[IFLA_FLEXRAY_SYMBOL]) {
+		struct flexray_symbol_param sp;
+
+		memcpy(&sp, nla_data(data[IFLA_FLEXRAY_SYMBOL]), sizeof(sp));
+		ret =3D flexray_check_and_set_symbol_params(&sp, dev);
+		if (ret)
+			return ret;
+	}
+
+	if (data[IFLA_FLEXRAY_SW_FILTER]) {
+		struct flexray_sw_filter *sw;
+
+		nla_for_each_nested(attr, data[IFLA_FLEXRAY_SW_FILTER], rem) {
+			sw =3D nla_data(attr);
+			ret =3D validate_and_set_sw_filter(sw, priv->sw_filter);
+			if (ret)
+				return ret;
+		}
+	}
+
+	return ret;
+}
+
+static inline int flexray_validate_sw_filter(struct nlattr *nest)
+{
+	struct flexray_sw_filter *sw;
+	struct nlattr *attr;
+	int rem, ret;
+	u32 id =3D 0;
+
+	if (!nest)
+		return 0;
+
+	ret =3D nla_validate_nested(nest, FLEXRAY_MAX_SW_FILTER,
+				  flexray_filt_pol);
+	if (ret)
+		return ret;
+
+	nla_for_each_nested(attr, nest, rem) {
+		sw =3D nla_data(attr);
+		if (sw->id < id)
+			return -EINVAL;
+
+		id =3D sw->id;
+	}
+
+	return 0;
+}
+
+static int flexray_validate(struct nlattr *tb[], struct nlattr *data[]=
)
+{
+	int ret;
+
+	ret =3D flexray_validate_sw_filter(data[IFLA_FLEXRAY_SW_FILTER]);
+	if (ret)
+		return ret;
+
+	return 0;
+}
+
+static size_t flexray_get_size(const struct net_device *dev)
+{
+	size_t size;
+
+	size =3D nla_total_size(sizeof(u32));
+	size +=3D nla_total_size(sizeof(struct flexray_cluster_param));
+	size +=3D nla_total_size(sizeof(struct flexray_node_param));
+
+	return size;
+}
+
+static int flexray_fill_info(struct sk_buff *skb, const struct net_dev=
ice *dev)
+{
+	struct flexray_priv *priv =3D netdev_priv(dev);
+	enum flexray_state state =3D priv->state;
+	struct flexray_cluster_param *cp =3D &priv->cluster;
+	struct flexray_node_param *np =3D &priv->node;
+	struct flexray_symbol_param *sp =3D &priv->symbol;
+	struct flexray_sw_filter sw;
+	struct nlattr *nest;
+	int i, ret =3D 0;
+
+	if (priv->do_get_state)
+		ret =3D priv->do_get_state(dev, &state);
+	if (nla_put_u32(skb, IFLA_FLEXRAY_STATE, state))
+		goto nla_put_failure;
+	if (nla_put_u8(skb, IFLA_FLEXRAY_VERSION, priv->version))
+		goto nla_put_failure;
+	if (nla_put(skb, IFLA_FLEXRAY_CLUSTER, sizeof(*cp), cp))
+		goto nla_put_failure;
+	if (nla_put(skb, IFLA_FLEXRAY_NODE, sizeof(*np), np))
+		goto nla_put_failure;
+	if (nla_put(skb, IFLA_FLEXRAY_SYMBOL, sizeof(*sp), sp))
+		goto nla_put_failure;
+
+	nest =3D nla_nest_start(skb, IFLA_FLEXRAY_SW_FILTER);
+	if (nest =3D=3D NULL)
+		goto nla_put_failure;
+
+	for (i =3D 0; i < FLEXRAY_MAX_SW_FILTER; i++) {
+		sw.pos =3D i;
+		sw.id =3D priv->sw_filter[i];
+		if (nla_put(skb, IFLA_FLEXRAY_FILTER_ENTRY, sizeof(sw), &sw))
+			goto nla_put_failure;
+
+		if (sw.id =3D=3D 0)
+			break;
+	}
+	nla_nest_end(skb, nest);
+
+	return ret;
+
+nla_put_failure:
+
+	return -EMSGSIZE;
+}
+
+static size_t flexray_get_xstats_size(const struct net_device *dev)
+{
+	return sizeof(struct flexray_device_stats);
+}
+
+static int flexray_fill_xstats(struct sk_buff *skb,
+			       const struct net_device *dev)
+{
+	struct flexray_priv *priv =3D netdev_priv(dev);
+
+	if (nla_put(skb, IFLA_INFO_XSTATS,
+		    sizeof(priv->flexray_stats), &priv->flexray_stats))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static int flexray_newlink(struct net *src_net, struct net_device *dev=
,
+		       struct nlattr *tb[], struct nlattr *data[])
+{
+	return -EOPNOTSUPP;
+}
+
+static struct rtnl_link_ops flexray_link_ops __read_mostly =3D {
+	.kind		=3D "flexray",
+	.maxtype	=3D IFLA_FLEXRAY_MAX,
+	.policy		=3D flexray_policy,
+	.setup		=3D flexray_setup,
+	.validate	=3D flexray_validate,
+	.newlink	=3D flexray_newlink,
+	.changelink	=3D flexray_changelink,
+	.get_size	=3D flexray_get_size,
+	.fill_info	=3D flexray_fill_info,
+	.get_xstats_size =3D flexray_get_xstats_size,
+	.fill_xstats	=3D flexray_fill_xstats,
+};
+
+/* Register the FLEXRAY network device */
+int register_flexraydev(struct net_device *dev)
+{
+	dev->rtnl_link_ops =3D &flexray_link_ops;
+	return register_netdev(dev);
+}
+EXPORT_SYMBOL_GPL(register_flexraydev);
+
+/* Unregister the FLEXRAY network device */
+void unregister_flexraydev(struct net_device *dev)
+{
+	unregister_netdev(dev);
+}
+EXPORT_SYMBOL_GPL(unregister_flexraydev);
+
+static __init int flexray_dev_init(void)
+{
+	int ret;
+
+	ret =3D rtnl_link_register(&flexray_link_ops);
+	if (!ret)
+		pr_info("FlexRay netlink interface\n");
+
+	return ret;
+}
+module_init(flexray_dev_init);
+
+static __exit void flexray_dev_exit(void)
+{
+	rtnl_link_unregister(&flexray_link_ops);
+}
+module_exit(flexray_dev_exit);
+
+MODULE_ALIAS_RTNL_LINK("flexray");
+
+MODULE_DESCRIPTION("FlexRay device driver interface");
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Benedikt Spranger <b.spranger@linutronix.de>");
diff --git a/drivers/net/flexray/flexcard_fr.c b/drivers/net/flexray/fl=
excard_fr.c
new file mode 100644
index 0000000..1f879ae
--- /dev/null
+++ b/drivers/net/flexray/flexcard_fr.c
@@ -0,0 +1,2480 @@
+/* Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved */
+
+#include <linux/netdevice.h>
+#include <linux/flexray.h>
+#include <linux/flexray/dev.h>
+#include <linux/clk.h>
+#include <linux/delay.h>
+#include <linux/if_arp.h>
+#include <linux/if_ether.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/module.h>
+#include <linux/platform_device.h>
+#include <linux/eray.h>
+#include <linux/flexcard.h>
+#include <linux/flexray/flexcard_netlink.h>
+#include <net/netlink.h>
+#include <net/genetlink.h>
+
+#define FC_MSGBUF_DUMP_CFG
+
+static int cc_change_state(struct eray_cc *cc, enum eray_cc_state stat=
e,
+			   int retry);
+static void cc_get_conf(struct net_device *dev);
+
+struct fc_enum2name {
+	int type;
+	char *name;
+};
+#define FC_ENUM2NAME(x)		{x, #x}
+
+static struct fc_enum2name flexray_state[] =3D {
+	FC_ENUM2NAME(FLEXRAY_STATE_UNSPEC),
+	FC_ENUM2NAME(FLEXRAY_STATE_DEFAULT_CONFIG),
+	FC_ENUM2NAME(FLEXRAY_STATE_CONFIG),
+	FC_ENUM2NAME(FLEXRAY_STATE_READY),
+	FC_ENUM2NAME(FLEXRAY_STATE_WAKEUP),
+	FC_ENUM2NAME(FLEXRAY_STATE_STARTUP),
+	FC_ENUM2NAME(FLEXRAY_STATE_NORMAL_ACTIVE),
+	FC_ENUM2NAME(FLEXRAY_STATE_NORMAL_PASSIVE),
+	FC_ENUM2NAME(FLEXRAY_STATE_HALT),
+	FC_ENUM2NAME(FLEXRAY_STATE_MONITOR_MODE),
+	FC_ENUM2NAME(FLEXRAY_STATE_COLDSTART),
+	FC_ENUM2NAME(FLEXRAY_STATE_MAX),
+};
+
+static inline char *fc_flexray_state_name(enum flexray_state cmd)
+{
+	if (cmd < 0)
+		cmd =3D FLEXRAY_STATE_UNSPEC;
+	if (cmd > FLEXRAY_STATE_MAX)
+		cmd =3D FLEXRAY_STATE_UNSPEC;
+
+	return flexray_state[cmd].name;
+}
+
+static struct fc_enum2name eray_state[] =3D {
+	FC_ENUM2NAME(ERAY_CMD_INVALID),
+	FC_ENUM2NAME(ERAY_CMD_CONFIG),
+	FC_ENUM2NAME(ERAY_CMD_READY),
+	FC_ENUM2NAME(ERAY_CMD_WAKEUP),
+	FC_ENUM2NAME(ERAY_CMD_RUN),
+	FC_ENUM2NAME(ERAY_CMD_ALL_SLOTS),
+	FC_ENUM2NAME(ERAY_CMD_HALT),
+	FC_ENUM2NAME(ERAY_CMD_FREEZE),
+	FC_ENUM2NAME(ERAY_CMD_SEND_MTS),
+	FC_ENUM2NAME(ERAY_CMD_ALLOW_COLDSTART),
+	FC_ENUM2NAME(ERAY_CMD_RESET_STATUS_INDICATORS),
+	FC_ENUM2NAME(ERAY_CMD_MONITOR_MODE),
+	FC_ENUM2NAME(ERAY_CMD_CLEAR_RAMS),
+};
+
+static inline char *fc_eray_cmd_name(enum eray_cc_state cmd)
+{
+	if (cmd < 0)
+		cmd =3D ERAY_CMD_INVALID;
+	if (cmd > ERAY_CMD_CLEAR_RAMS)
+		cmd =3D ERAY_CMD_INVALID;
+
+	return eray_state[cmd].name;
+}
+
+struct fc_msg {
+	u32 buf_id;
+	u8 data[254];
+} __packed;
+
+struct flexcard_priv {
+	struct flexray_priv flexray;
+	struct net_device *dev;
+	struct eray_cc *cc;
+	int id;
+	void __iomem *conf;
+};
+
+static int _fc_write_data(struct flexcard_priv *priv, unsigned int msg=
buf_id,
+			  unsigned char *payload, size_t byte_len);
+
+static struct nla_policy fc_msgbuf_genl_policy[__FC_MSGBUF_ATTR_MAX] =3D=
 {
+	[FC_MSGBUF_ATTR_BUF_ID] =3D {
+		.type =3D NLA_U8,
+	},
+	[FC_MSGBUF_ATTR_DEV_ID] =3D {
+		.type =3D NLA_U32,
+	},
+	[FC_MSGBUF_ATTR_DEV_NAME] =3D {
+		.type =3D NLA_NUL_STRING,
+	},
+	[FC_MSGBUF_ATTR_CFG] =3D {
+		.type =3D NLA_BINARY,
+		.len =3D sizeof(struct fc_msgbuf_cfg),
+	},
+};
+
+static struct genl_family fc_msgbuf_genl_family =3D {
+	.id =3D GENL_ID_GENERATE,
+	.hdrsize =3D 0,
+	.name =3D "FC_MSGBUF",
+	.version =3D FC_MSGBUF_VERSION,
+	.maxattr =3D FC_MSGBUF_ATTR_MAX,
+};
+
+#ifdef FC_MSGBUF_DUMP_CFG
+
+#define ERAY_MSGBUF_PRINT_FLAGS(x)			\
+	do {						\
+		if (cfg->flags & x)			\
+			pr_cont(#x " ");		\
+	} while (0)
+
+static void eray_dump_msg_cfg(struct eray_msgbuf_cfg *cfg, int buf,
+		const char *func)
+{
+	pr_debug("%s: msg. buffer dump %03d\n", func, buf);
+	pr_debug("eray_msgbuf_cfg: cfg =3D %p\n", cfg);
+	if (!cfg)
+		return;
+	pr_debug("flags   : ");
+	ERAY_MSGBUF_PRINT_FLAGS(ERAY_MSGBUF_USED);
+	ERAY_MSGBUF_PRINT_FLAGS(ERAY_MSGBUF_STARTUP);
+	ERAY_MSGBUF_PRINT_FLAGS(ERAY_MSGBUF_SYNC);
+	ERAY_MSGBUF_PRINT_FLAGS(ERAY_MSGBUF_PPIT);
+	ERAY_MSGBUF_PRINT_FLAGS(ERAY_MSGBUF_TXCONT);
+	ERAY_MSGBUF_PRINT_FLAGS(ERAY_MSGBUF_FIFOREJ_NULL);
+	ERAY_MSGBUF_PRINT_FLAGS(ERAY_MSGBUF_FIFOREJ_INSEG);
+	pr_cont("\n");
+	pr_debug("id      : %d\n", cfg->id);
+	pr_debug("cyc     : %d\n", cfg->cyc);
+	pr_debug("len     : %d\n", cfg->len);
+	pr_debug("max     : %d\n", cfg->max);
+	pr_debug("frame_id: %d\n", cfg->frame_id);
+	pr_debug("wrhs1   : 0x%08x\n", cfg->wrhs1);
+	pr_debug("wrhs2   : 0x%08x\n", cfg->wrhs2);
+	pr_debug("wrhs3   : 0x%08x\n", cfg->wrhs3);
+	pr_debug("type    : ");
+	switch (cfg->type) {
+	case eray_msgbuf_type_none:
+		pr_cont("NONE\n");
+		break;
+	case eray_msgbuf_type_fifo:
+		pr_cont("FIFO\n");
+		break;
+	case eray_msgbuf_type_rx:
+		pr_cont("RX\n");
+		break;
+	case eray_msgbuf_type_tx:
+		pr_cont("TX\n");
+		break;
+	default:
+		pr_cont("UNKNOWN (%d)\n", cfg->type);
+		break;
+	}
+	pr_debug("channel : ");
+	switch (cfg->channel) {
+	case eray_msgbuf_ch_none:
+		pr_cont("NONE\n");
+		break;
+	case eray_msgbuf_ch_a:
+		pr_cont("CH A\n");
+		break;
+	case eray_msgbuf_ch_b:
+		pr_cont("CH B\n");
+		break;
+	case eray_msgbuf_ch_both:
+		pr_cont("BOTH\n");
+		break;
+	default:
+		pr_cont("UNKNOWN (%d)\n", cfg->channel);
+		break;
+	}
+}
+#else
+static inline void eray_dump_msg_cfg(struct eray_msgbuf_cfg *cfg, int =
buf,
+		const char *func)
+{ }
+#endif
+
+static struct net_device *get_dev(struct genl_info *info)
+{
+	struct net_device *dev =3D NULL;
+	struct nlattr *nla;
+
+	nla =3D info->attrs[FC_MSGBUF_ATTR_DEV_NAME];
+	if (nla)
+		dev =3D dev_get_by_name(&init_net, nla_data(nla));
+	if (dev)
+		return dev;
+	nla =3D info->attrs[FC_MSGBUF_ATTR_DEV_ID];
+	if (nla)
+		dev =3D dev_get_by_index(&init_net, nla_get_u32(nla));
+
+	return dev;
+}
+
+static void fc2eray(struct fc_msgbuf_cfg *src, struct eray_msgbuf_cfg =
*dest)
+{
+	dest->flags =3D src->flags;
+	dest->cyc =3D src->cyc;
+	dest->len =3D src->len;
+	dest->max =3D src->max;
+	dest->frame_id =3D src->frame_id;
+	dest->reject_mask =3D src->reject_mask;
+	dest->type =3D src->type;
+	dest->channel =3D src->channel;
+}
+
+static void eray2fc(struct eray_msgbuf_cfg *src, struct fc_msgbuf_cfg =
*dest)
+{
+	dest->flags =3D src->flags;
+	dest->cyc =3D src->cyc;
+	dest->len =3D src->len;
+	dest->max =3D src->max;
+	dest->frame_id =3D src->frame_id;
+	dest->reject_mask =3D src->reject_mask;
+	dest->type =3D src->type;
+	dest->channel =3D src->channel;
+}
+
+static int remain_buffer_entries(struct eray_cc *cc)
+{
+	int i, fill;
+
+	/* calculate buffer fill value */
+	fill =3D 0;
+	for (i =3D 0; i < cc->act_cfg; i++) {
+		fill +=3D ERAY_MSGBUF_CFG_LEN;
+		if (cc->cfg[i].type =3D=3D eray_msgbuf_type_rx ||
+		    cc->cfg[i].type =3D=3D eray_msgbuf_type_tx)
+			fill +=3D DIV_ROUND_UP(cc->cfg[i].max, 2);
+		else
+			fill +=3D DIV_ROUND_UP(cc->fifo_len, 2);
+	}
+
+	return ERAY_MAX_MEM - fill;
+}
+
+static int fc_msgbuf_get_cfg(struct sk_buff *_skb, struct genl_info *i=
nfo)
+{
+	struct fc_msgbuf_cfg cfg;
+	struct fc_msgbuf_cfg *nlcfg;
+	struct flexcard_priv *priv;
+	struct net_device *dev;
+	struct eray_cc *cc;
+	struct sk_buff *skb;
+	struct nlattr *nla;
+	unsigned long flags;
+	void *msg_head;
+	int ret;
+	u8 buf_id;
+
+	dev =3D get_dev(info);
+	if (!dev)
+		return -ENODEV;
+
+	priv =3D netdev_priv(dev);
+	cc =3D priv->cc;
+
+	if (dev->type !=3D ARPHRD_FLEXRAY) {
+		ret =3D -EINVAL;
+		goto out;
+	}
+
+	nla =3D info->attrs[FC_MSGBUF_ATTR_BUF_ID];
+	if (!nla) {
+		ret =3D -ENOMSG;
+		goto out;
+	}
+	buf_id =3D nla_get_u8(nla);
+
+	nla =3D info->attrs[FC_MSGBUF_ATTR_CFG];
+	if (!nla) {
+		netdev_warn(dev, "no config\n");
+		ret =3D -ENOMSG;
+		goto out;
+	}
+	nlcfg =3D nla_data(nla);
+
+	spin_lock_irqsave(&cc->lock, flags);
+
+	if (nlcfg->flags & FC_MSGBUF_SELFSYNC) {
+		if (buf_id >=3D cc->ssync_num) {
+			netdev_warn(dev, "invalid self sync buffer id %d\n",
+					buf_id);
+			ret =3D -ENOMSG;
+			spin_unlock_irqrestore(&cc->lock, flags);
+			goto out;
+		}
+
+		eray2fc(&cc->ssync_cfg[buf_id], &cfg);
+		cfg.buf_id =3D buf_id;
+	} else {
+		if (buf_id >=3D cc->act_cfg) {
+			netdev_warn(dev, "invalid buffer id %d\n", buf_id);
+			ret =3D -ENOMSG;
+			spin_unlock_irqrestore(&cc->lock, flags);
+			goto out;
+		}
+
+		eray2fc(&cc->cfg[buf_id], &cfg);
+		cfg.buf_id =3D buf_id;
+		/* re-adjust length of fifo buffers */
+		if (cfg.type =3D=3D eray_msgbuf_type_fifo)
+			cfg.len =3D cc->fifo_len;
+	}
+	spin_unlock_irqrestore(&cc->lock, flags);
+
+	skb =3D genlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!skb) {
+		ret =3D -ENOMEM;
+		goto out;
+	}
+
+	msg_head =3D genlmsg_put_reply(skb, info, &fc_msgbuf_genl_family,
+				      0, FC_MSGBUF_CMD_GET_CFG);
+	if (!msg_head) {
+		ret =3D -ENOMEM;
+		goto free_skb_out;
+	}
+
+	ret =3D nla_put_u8(skb, FC_MSGBUF_ATTR_BUF_ID, buf_id);
+	if (ret)
+		goto free_skb_out;
+
+	ret =3D nla_put(skb, FC_MSGBUF_ATTR_CFG, sizeof(cfg), &cfg);
+	if (ret)
+		goto free_skb_out;
+
+	genlmsg_end(skb, msg_head);
+
+	ret =3D genlmsg_reply(skb, info);
+out:
+	dev_put(dev);
+
+	return ret;
+
+free_skb_out:
+	kfree_skb(skb);
+	goto out;
+}
+
+static int fc_msgbuf_reset_cfg(struct sk_buff *_skb, struct genl_info =
*info)
+{
+	struct eray_msgbuf_cfg *cfg;
+	struct fc_msgbuf_cfg *nlcfg;
+	struct flexcard_priv *priv;
+	struct net_device *dev;
+	struct nlattr *nla;
+	struct eray_cc *cc;
+	unsigned long flags;
+	int i, ret =3D -EINVAL;
+
+	dev =3D get_dev(info);
+	if (!dev)
+		return -ENODEV;
+
+	if (dev->type !=3D ARPHRD_FLEXRAY)
+		goto out;
+
+	priv =3D netdev_priv(dev);
+	cc =3D priv->cc;
+
+	nla =3D info->attrs[FC_MSGBUF_ATTR_CFG];
+	if (!nla) {
+		netdev_warn(dev, "no config\n");
+		ret =3D -ENOMSG;
+		goto out;
+	}
+	nlcfg =3D nla_data(nla);
+
+	spin_lock_irqsave(&cc->lock, flags);
+
+	if (nlcfg->flags & FC_MSGBUF_SELFSYNC) {
+		cc->ssync_start =3D 0;
+		cc->ssync_num =3D 0;
+		memset(&cc->ssync_cfg, 0x0, sizeof(cc->ssync_cfg));
+
+		ret =3D 0;
+		goto out_unlock;
+	}
+
+	cc->ready =3D 0;
+
+	for (i =3D 0; i < ERAY_MAX_BUFS; i++) {
+		cc->cfg[i].flags =3D 0;
+		cc->cfg[i].len =3D 0;
+		cc->cfg[i].max =3D 0;
+		cc->cfg[i].cyc =3D 0;
+		cc->cfg[i].channel =3D eray_msgbuf_ch_none;
+	}
+	cc->act_cfg =3D 1;
+	cc->fifo_len =3D 0;
+	cc->sync_start =3D 0;
+	cc->sync_num =3D 0;
+	memset(&cc->sync_cfg, 0x0, sizeof(cc->sync_cfg));
+
+	cc->fifo_threshold =3D ERAY_FIFO_THRESHOLD;
+
+	cfg =3D &cc->cfg[0];
+	cfg->flags |=3D ERAY_MSGBUF_USED;
+	cfg->type =3D eray_msgbuf_type_fifo;
+	cfg->max =3D 127;
+
+	/* CLEAR_RAMS can only be called in DEFAULT_CONFIG or CONFIG mode */
+	ret =3D cc_change_state(cc, ERAY_CMD_CONFIG, 5);
+	if (ret < 0) {
+		netdev_err(dev, "CC DEFAULT_CONFIG failed\n");
+		goto out_unlock;
+	}
+
+	ret =3D cc_change_state(cc, ERAY_CMD_CLEAR_RAMS, 15);
+	if (ret < 0)
+		netdev_err(dev, "%s: CC CLEAR_RAMS failed\n", __func__);
+out_unlock:
+	spin_unlock_irqrestore(&cc->lock, flags);
+out:
+	dev_put(dev);
+	return ret;
+}
+
+static int fc_msgbuf_read_cfg(struct sk_buff *_skb, struct genl_info *=
info)
+{
+	struct eray_msgbuf_cfg *cfg;
+	struct flexcard_priv *priv;
+	struct net_device *dev;
+	struct eray_cc *cc;
+	unsigned long flags;
+	u32 reg;
+	u8 fdb, ffb, lcb, splm, act =3D 1;
+	int i, ret =3D -EINVAL;
+
+	dev =3D get_dev(info);
+	if (!dev)
+		return -ENODEV;
+
+	if (dev->type !=3D ARPHRD_FLEXRAY)
+		goto out;
+
+	priv =3D netdev_priv(dev);
+	cc =3D priv->cc;
+
+	spin_lock_irqsave(&cc->lock, flags);
+
+	for (i =3D 0; i < ERAY_MAX_BUFS; i++) {
+		cc->cfg[i].flags =3D 0;
+		cc->cfg[i].len =3D 0;
+		cc->cfg[i].max =3D 0;
+		cc->cfg[i].cyc =3D 0;
+		cc->cfg[i].channel =3D eray_msgbuf_ch_both;
+	}
+
+	cc->fifo_threshold =3D ERAY_FIFO_THRESHOLD;
+
+	/* The FlexCard firmware needs one or more configured FIFO buffer
+	 * to receive FlexRay frames.
+	 */
+
+	cfg =3D &cc->cfg[0];
+	cfg->flags |=3D ERAY_MSGBUF_USED;
+	cfg->type =3D eray_msgbuf_type_fifo;
+	cfg->max =3D 127;
+
+	reg =3D eray_readl(cc, ERAY_FRF);
+	cfg->channel =3D (reg & ERAY_FRF_CH_MASK) >> ERAY_FRF_CH_SHIFT;
+	cfg->frame_id =3D (reg & ERAY_FRF_FID_MASK) >> ERAY_FRF_FID_SHIFT;
+	cfg->cyc =3D (reg & ERAY_FRF_CYC_MASK) >> ERAY_FRF_CYC_SHIFT;
+	if (reg & ERAY_FRF_RNF_MASK)
+		cfg->flags |=3D ERAY_MSGBUF_FIFOREJ_NULL;
+	if (reg & ERAY_FRF_RSS_MASK)
+		cfg->flags |=3D ERAY_MSGBUF_FIFOREJ_INSEG;
+
+	reg =3D eray_readl(cc, ERAY_FRFM);
+	cfg->reject_mask =3D (reg & ERAY_FRFM_MFID_MASK) >> ERAY_FRFM_MFID_SH=
IFT;
+
+	cc->act_cfg =3D 1;
+
+	reg =3D eray_readl(cc, ERAY_MRC);
+	lcb =3D (reg & ERAY_MRC_LCB_MASK) >> ERAY_MRC_LCB_SHIFT;
+	ffb =3D (reg & ERAY_MRC_FFB_MASK) >> ERAY_MRC_FFB_SHIFT;
+	fdb =3D (reg & ERAY_MRC_FDB_MASK) >> ERAY_MRC_FDB_SHIFT;
+	splm =3D (reg & ERAY_MRC_SPLM_MASK) >> ERAY_MRC_SPLM_SHIFT;
+
+	for (i =3D 0; i < lcb + 1; i++) {
+		eray_writel(ERAY_OBCM_RHSS_MASK, cc, ERAY_OBCM);
+		eray_writel(i | ERAY_OBCR_REQ_MASK, cc, ERAY_OBCR);
+		ret =3D eray_wait_clear(cc, ERAY_OBCR, ERAY_OBCR_OBSYS_MASK, 10);
+		if (ret)
+			goto out_unlock;
+
+		eray_writel(ERAY_OBCR_VIEW_MASK, cc, ERAY_OBCR);
+		eray_readl(cc, ERAY_OBCR);
+
+		cfg =3D &cc->cfg[act];
+
+		cfg->wrhs1 =3D eray_readl(cc, ERAY_RDHS1);
+		cfg->wrhs2 =3D eray_readl(cc, ERAY_RDHS2);
+		cfg->wrhs3 =3D eray_readl(cc, ERAY_RDHS3);
+
+		cfg->id =3D i;
+		cc->rev_id[i] =3D cfg->id;
+		cfg->flags |=3D ERAY_MSGBUF_USED;
+
+		if (i > ffb) {
+			cfg->type =3D eray_msgbuf_type_fifo;
+			cfg->max =3D (cfg->wrhs2 >> ERAY_WRHS2_PLC_SHIFT) &
+				ERAY_WRHS2_PLC_MASK;
+			if (!cc->fifo_len)
+				cc->fifo_len =3D cfg->max;
+
+			/* copy fifo reject configuration from message buffer 0
+			 */
+			cfg->channel =3D cc->cfg[0].channel;
+			cfg->frame_id =3D cc->cfg[0].frame_id;
+			cfg->cyc =3D cc->cfg[0].cyc;
+			cfg->reject_mask =3D cc->cfg[0].reject_mask;
+
+			if (cc->fifo_threshold)
+				cc->fifo_threshold--;
+		} else {
+			if (cfg->wrhs1 & ERAY_WRHS1_CFG_MASK)
+				cfg->type =3D eray_msgbuf_type_tx;
+			else
+				cfg->type =3D eray_msgbuf_type_rx;
+
+			/* WRHS1:
+			 * 31-16: MBI:TXM:PPIT:CFG:CHB:CHA:0:CYC[6..0]
+			 * 15- 0: 00000:FID[10..0]
+			 */
+			cfg->frame_id =3D (cfg->wrhs1 & ERAY_WRHS1_FID_MASK) >>
+				ERAY_WRHS1_FID_SHIFT;
+
+			if (!cfg->frame_id)
+				continue;
+
+			cfg->cyc =3D (cfg->wrhs1 & ERAY_WRHS1_CYC_MASK) >>
+				ERAY_WRHS1_CYC_SHIFT;
+			cfg->channel =3D (cfg->wrhs1 & ERAY_WRHS1_CH_MASK) >>
+				ERAY_WRHS1_CH_SHIFT;
+			if (cfg->wrhs1 & ERAY_WRHS1_PPIT_MASK)
+				cfg->flags |=3D ERAY_MSGBUF_PPIT;
+
+			/* if ERAY_WRHS1_TXM is *not* set the ERAY core
+			 * works in continous mode.
+			 */
+			if ((cfg->type =3D=3D eray_msgbuf_type_tx) &&
+			    !(cfg->wrhs1 & ERAY_WRHS1_TXM_MASK))
+				cfg->flags |=3D ERAY_MSGBUF_TXCONT;
+
+			/* WRHS2:
+			 * 31- 0: 000000000:PLC[6-0]:00000:CRC[10..0]
+			 */
+			cfg->max =3D (cfg->wrhs2 & ERAY_WRHS2_PLC_MASK) >>
+				ERAY_WRHS2_PLC_SHIFT;
+		}
+		cfg->len =3D cfg->max;
+		act++;
+
+		eray_dump_msg_cfg(cfg, i, __func__);
+	}
+
+	reg =3D eray_read_succ1(cc, 10);
+	if (reg < 0) {
+		ret =3D -EBUSY;
+		goto out_unlock;
+	}
+
+	if (reg & ERAY_SUCC1_TXST_MASK) {
+		cc->sync_start |=3D ERAY_MSGBUF_STARTUP;
+		cc->cfg[1].flags |=3D ERAY_MSGBUF_STARTUP;
+		if (splm)
+			cc->cfg[2].flags |=3D ERAY_MSGBUF_STARTUP;
+	}
+
+	if (reg & ERAY_SUCC1_TXSY_MASK) {
+		cc->sync_start |=3D ERAY_MSGBUF_SYNC;
+		cc->cfg[1].flags |=3D ERAY_MSGBUF_SYNC;
+		if (splm)
+			cc->cfg[2].flags |=3D ERAY_MSGBUF_SYNC;
+	}
+
+	cc_get_conf(dev);
+	ret =3D 0;
+	cc->ready =3D 1;
+	cc->act_cfg =3D act;
+
+out_unlock:
+	spin_unlock_irqrestore(&cc->lock, flags);
+out:
+	dev_put(dev);
+	return ret;
+}
+
+static int is_double_sync(struct fc_msgbuf_cfg *cfg,
+		struct eray_msgbuf_cfg *sync_cfg, int sync_num)
+{
+	if (!sync_num)
+		return 0;
+
+	if (sync_num > 1)
+		return 1;
+
+	if ((cfg->cyc !=3D sync_cfg->cyc) ||
+	    (cfg->len !=3D sync_cfg->len) ||
+	    (cfg->max !=3D sync_cfg->max) ||
+	    (cfg->frame_id !=3D sync_cfg->frame_id))
+		return 1;
+
+	if (cfg->channel =3D=3D eray_msgbuf_ch_both)
+		return 1;
+
+	if ((sync_cfg->channel =3D=3D eray_msgbuf_ch_a) &&
+	    (cfg->channel =3D=3D eray_msgbuf_ch_a))
+		return 1;
+
+	if ((sync_cfg->channel =3D=3D eray_msgbuf_ch_b) &&
+	    (cfg->channel =3D=3D eray_msgbuf_ch_b))
+		return 1;
+
+	return 0;
+}
+
+static int fc_msgbuf_set_cfg_ssync(struct net_device *dev,
+		struct fc_msgbuf_cfg *cfg, struct eray_cc *cc, int aquire)
+{
+	u8 buf_id;
+
+	if (aquire) {
+		buf_id =3D cc->ssync_num;
+	} else {
+		buf_id =3D cfg->buf_id;
+
+		if (!(cc->ssync_start & ERAY_MSGBUF_SYNC)) {
+			netdev_warn(dev, "self sync not yet configured\n");
+			return -ENOMSG;
+		}
+
+		if (buf_id > cc->ssync_num) {
+			netdev_warn(dev, "unused buffer id %d\n", buf_id);
+			return -ENOMSG;
+		}
+	}
+
+	if (buf_id > ERAY_MAX_BUFS_SSYNC) {
+		netdev_warn(dev, "invalid buffer id %d\n", buf_id);
+		return -EINVAL;
+	}
+
+	if (!(cfg->flags & ERAY_MSGBUF_SYNC) ||
+	    !(cfg->flags & ERAY_MSGBUF_STARTUP)) {
+		netdev_warn(dev, "no sync/start frame\n");
+		return -EINVAL;
+	}
+
+	if (cfg->type !=3D eray_msgbuf_type_tx) {
+		netdev_warn(dev, "wrong type (!tx)\n");
+		return -EINVAL;
+	}
+
+	if (cfg->cyc > 1) {
+		netdev_warn(dev, "cycle counter filter not valid\n");
+		return -EINVAL;
+	}
+
+	if (cfg->channel =3D=3D eray_msgbuf_ch_none) {
+		netdev_warn(dev, "channel not valid for sync (none)\n");
+		return -EINVAL;
+	}
+
+	/* cc->ssync_num =3D=3D 0 is coverd by is_double_sync() */
+	if (is_double_sync(cfg, &cc->ssync_cfg[0], cc->ssync_num)) {
+		netdev_warn(dev, "double sync frame\n");
+		return -EINVAL;
+	}
+
+	if (cfg->frame_id > cc->static_id) {
+		netdev_warn(dev, "sync frame not in static segment\n");
+		return -EINVAL;
+	}
+
+	cfg->buf_id =3D buf_id;
+
+	cc->ssync_start |=3D ERAY_MSGBUF_SYNC;
+	cc->ssync_start |=3D ERAY_MSGBUF_STARTUP;
+
+	fc2eray(cfg, &cc->ssync_cfg[buf_id]);
+	cc->ssync_cfg[buf_id].flags |=3D ERAY_MSGBUF_USED;
+
+	if (aquire)
+		cc->ssync_num++;
+
+	return 0;
+}
+
+static int fc_msgbuf_set_cfg(struct sk_buff *_skb, struct genl_info *i=
nfo)
+{
+	struct fc_msgbuf_cfg *cfg;
+	struct flexcard_priv *priv;
+	struct net_device *dev;
+	struct eray_cc *cc;
+	struct sk_buff *skb;
+	struct nlattr *nla;
+	unsigned long flags;
+	void *msg_head;
+	int aquire, ret;
+	int i;
+	u8 buf_id;
+
+	dev =3D get_dev(info);
+	if (!dev)
+		return -ENODEV;
+
+	if (dev->type !=3D ARPHRD_FLEXRAY) {
+		netdev_warn(dev, "device is not a FlexRay device\n");
+		ret =3D -EINVAL;
+		goto out;
+	}
+	priv =3D netdev_priv(dev);
+	cc =3D priv->cc;
+
+	spin_lock_irqsave(&cc->lock, flags);
+	cc->ready =3D 0;
+	nla =3D info->attrs[FC_MSGBUF_ATTR_BUF_ID];
+	if (nla) {
+		buf_id =3D nla_get_u8(nla);
+		aquire =3D 0;
+	} else {
+		buf_id =3D cc->act_cfg;
+		aquire =3D 1;
+	}
+
+	nla =3D info->attrs[FC_MSGBUF_ATTR_CFG];
+	if (!nla) {
+		netdev_warn(dev, "no config\n");
+		ret =3D -ENOMSG;
+		goto out_unlock;
+	}
+	cfg =3D nla_data(nla);
+
+	if (cfg->flags & FC_MSGBUF_SELFSYNC) {
+		ret =3D fc_msgbuf_set_cfg_ssync(dev, cfg, cc, aquire);
+		if (ret)
+			goto out_unlock;
+
+		buf_id =3D cfg->buf_id;
+		goto nlreply_unlock;
+	}
+
+	if (aquire) {
+		/* The ERAY core can only allocate memory in 32-bit chunks,
+		 * while FlexRay is based on 16-bit words. To allocate a
+		 * proper amount of chunks use M =3D (N + 1)/2
+		 * M =3D number of chunks (32bit)
+		 * N =3D number of FlexRay words (16bit)
+		 */
+
+		if (remain_buffer_entries(cc) < 0) {
+			netdev_warn(dev, "no room for header\n");
+			ret =3D -ENOMEM;
+			goto out_unlock;
+		}
+	}
+
+	if (buf_id >=3D ERAY_MAX_BUFS) {
+		netdev_warn(dev, "invalid buffer id %d\n", buf_id);
+		ret =3D -ERANGE;
+		goto out_unlock;
+	}
+
+	if (!aquire && !(cc->cfg[buf_id].flags & ERAY_MSGBUF_USED)) {
+		netdev_warn(dev, "buffer %d not in use\n", buf_id);
+		ret =3D -ENOMSG;
+		goto out_unlock;
+	}
+
+	if (cfg->max > 254) {
+		netdev_warn(dev,
+			  "payload len %d no valid\n", cfg->max);
+		ret =3D -EINVAL;
+		goto out_unlock;
+	}
+
+	if (cfg->type =3D=3D eray_msgbuf_type_fifo) {
+		cfg->flags &=3D ~ERAY_MSGBUF_STARTUP;
+		cfg->flags &=3D ~ERAY_MSGBUF_SYNC;
+
+		if (cc->fifo_threshold)
+			cc->fifo_threshold--;
+	}
+
+	if ((cc->act_cfg + cc->fifo_threshold) >=3D ERAY_MAX_BUFS) {
+		netdev_warn(dev, "min fifo limit reached\n");
+		ret =3D -E2BIG;
+		goto out_unlock;
+	}
+
+	if (cfg->flags & ERAY_MSGBUF_SYNC) {
+		if (cfg->channel =3D=3D eray_msgbuf_ch_none) {
+			netdev_warn(dev,
+				    "channel not valid for sync (none)\n");
+			ret =3D -EINVAL;
+			goto out_unlock;
+		}
+		if (is_double_sync(cfg, &cc->sync_cfg, cc->sync_num)) {
+			netdev_warn(dev, "double sync frame\n");
+			ret =3D -EINVAL;
+			goto out_unlock;
+		}
+		cc->sync_start |=3D ERAY_MSGBUF_SYNC;
+		cc->sync_num++;
+		fc2eray(cfg, &cc->sync_cfg);
+	}
+
+	if (cfg->flags & ERAY_MSGBUF_STARTUP) {
+		if (!(cfg->flags & ERAY_MSGBUF_SYNC)) {
+			netdev_warn(dev,
+				    "startup frame is not sync frame\n");
+			ret =3D -EINVAL;
+			goto out_unlock;
+		}
+		cc->sync_start |=3D ERAY_MSGBUF_STARTUP;
+	}
+
+	if ((cfg->flags & ERAY_MSGBUF_SYNC) &&
+	    (cfg->frame_id > cc->static_id)) {
+		netdev_warn(dev, "sync frame not in static segment\n");
+		ret =3D -EINVAL;
+		goto out_unlock;
+	}
+
+
+	/* avoid duplicate configuration */
+	if (aquire && cfg->type !=3D eray_msgbuf_type_fifo) {
+		for (i =3D 0; i < cc->act_cfg; i++) {
+			if ((cc->cfg[i].frame_id =3D=3D cfg->frame_id) &&
+			    (cc->cfg[i].channel & cfg->channel) &&
+			    (cc->cfg[i].cyc =3D=3D  cfg->cyc)) {
+				netdev_warn(dev, "duplicate configuration\n");
+				ret =3D -EINVAL;
+				goto out_unlock;
+			}
+		}
+	}
+
+	if (cfg->type =3D=3D eray_msgbuf_type_fifo) {
+		if (!cc->fifo_len)
+			cc->fifo_len =3D cfg->max;
+		else if (cfg->max !=3D cc->fifo_len) {
+			netdev_warn(dev, "payload len %d !=3D %d\n",
+				  cfg->max, cc->fifo_len);
+			ret =3D -EINVAL;
+			goto out_unlock;
+		}
+		/* copy fifo reject configuration to message buffer 0 */
+		cc->cfg[0].channel =3D cfg->channel;
+		cc->cfg[0].frame_id =3D cfg->frame_id;
+		cc->cfg[0].cyc =3D cfg->cyc;
+		cc->cfg[0].reject_mask =3D cfg->reject_mask;
+	}
+
+	if (cfg->type =3D=3D eray_msgbuf_type_tx) {
+		if (cfg->len > cfg->max) {
+			netdev_warn(dev, "payload len %d > payload len %d\n",
+					cfg->len, cfg->max);
+			ret =3D -EINVAL;
+			goto out_unlock;
+		}
+		/* reject messagebuffer if it's static and the length is bigger
+		 * than the cluster wide static messagebuffer length
+		 */
+		if (cfg->frame_id <=3D cc->static_id &&
+				cfg->len > cc->static_len) {
+			netdev_warn(dev, "payload len %d > static_len %d\n",
+					cfg->len, cc->static_len);
+			ret =3D -EINVAL;
+			goto out_unlock;
+		}
+		if (cfg->channel =3D=3D eray_msgbuf_ch_both &&
+				cfg->frame_id > cc->static_id) {
+			netdev_warn(dev, "both channel in dynamic frame\n");
+			ret =3D -EINVAL;
+			goto out_unlock;
+		}
+	}
+
+	if ((remain_buffer_entries(cc) - ERAY_MSGBUF_CFG_LEN -
+				DIV_ROUND_UP(cfg->max, 2)) < 0) {
+		netdev_warn(dev, "no room for buffer\n");
+		ret =3D -EINVAL;
+		goto out_unlock;
+	}
+
+	fc2eray(cfg, &cc->cfg[buf_id]);
+
+	cc->cfg[buf_id].flags |=3D ERAY_MSGBUF_USED;
+	if (aquire)
+		cc->act_cfg++;
+nlreply_unlock:
+	spin_unlock_irqrestore(&cc->lock, flags);
+
+	skb =3D genlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!skb) {
+		netdev_warn(dev, "could not allocate skb\n");
+		ret =3D -ENOMEM;
+		goto out;
+	}
+
+	msg_head =3D genlmsg_put_reply(skb, info, &fc_msgbuf_genl_family, 0,
+			FC_MSGBUF_CMD_SET_CFG);
+	if (!msg_head) {
+		netdev_warn(dev, "generating NL reply failed\n");
+		ret =3D -ENOMEM;
+		goto out_free_skb;
+	}
+	ret =3D nla_put_u8(skb, FC_MSGBUF_ATTR_BUF_ID, buf_id);
+	if (ret) {
+		netdev_warn(dev, "could not add buffer id\n");
+		ret =3D -EINVAL;
+		goto out_free_skb;
+	}
+	genlmsg_end(skb, msg_head);
+
+	ret =3D genlmsg_reply(skb, info);
+out:
+	dev_put(dev);
+	return ret;
+
+out_free_skb:
+	kfree(skb);
+	goto out;
+
+out_unlock:
+	spin_unlock_irqrestore(&cc->lock, flags);
+	dev_put(dev);
+	return ret;
+}
+
+static struct genl_ops fc_msgbuf_genl_ops[] =3D {
+	{
+		.cmd =3D FC_MSGBUF_CMD_GET_CFG,
+		.policy =3D fc_msgbuf_genl_policy,
+		.doit =3D fc_msgbuf_get_cfg,
+	},
+	{
+		.cmd =3D FC_MSGBUF_CMD_SET_CFG,
+		.policy =3D fc_msgbuf_genl_policy,
+		.doit =3D fc_msgbuf_set_cfg,
+	},
+	{
+		.cmd =3D FC_MSGBUF_CMD_RESET_CFG,
+		.policy =3D fc_msgbuf_genl_policy,
+		.doit =3D fc_msgbuf_reset_cfg,
+	},
+	{
+		.cmd =3D FC_MSGBUF_CMD_READ_CFG,
+		.policy =3D fc_msgbuf_genl_policy,
+		.doit =3D fc_msgbuf_read_cfg,
+	},
+};
+
+/* calculate header CRC as specified in FlexRay Protocol Specification=
 V2.1
+ * Rev.A chapter 4.2.8
+ */
+static u32 crc_header(struct eray_msgbuf_cfg *cfg)
+{
+	u32 val =3D 0x1a;
+	u32 crc_next;
+	u32 next_bit;
+	u32 data;
+	int i;
+
+	data =3D cfg->len & (ERAY_WRHS2_PLC_MASK >> ERAY_WRHS2_PLC_SHIFT);
+	data |=3D (cfg->frame_id & ERAY_WRHS1_FID_MASK) << 7;
+	if (cfg->flags & ERAY_MSGBUF_STARTUP)
+		data |=3D 1 << 18;
+	if (cfg->flags & ERAY_MSGBUF_SYNC)
+		data |=3D 1 << 19;
+
+	for (i =3D 19; i >=3D 0; i--) {
+		next_bit =3D (data >> i) & 0x1;
+		crc_next =3D next_bit ^ ((val >> 10) & 0x1);
+
+		val <<=3D 1;
+		val &=3D 0xfffffffe;
+
+		if (crc_next)
+			val ^=3D 0x385;
+
+		val &=3D 0x7ff;
+	}
+
+	return val & ERAY_WRHS2_CRC_MASK;
+}
+
+static int fc_wait_for_ram_offset(struct eray_cc *cc, uint32_t offset)
+{
+	int ret;
+
+	/* wait until host and shadow RAM actions are finished */
+	ret =3D eray_wait_clear(cc, ERAY_IBCR + offset, ERAY_IBCR_IBSYH_MASK,=
 10);
+	if (ret)
+		goto out;
+
+	ret =3D eray_wait_clear(cc, ERAY_IBCR + offset, ERAY_IBCR_IBSYS_MASK,=
 10);
+out:
+	return ret;
+}
+
+static int fc_wait_for_ram(struct eray_cc *cc)
+{
+	return fc_wait_for_ram_offset(cc, 0);
+}
+
+static int fc_prepare_msgbuf_data_ssync(struct net_device *dev)
+{
+	struct flexcard_priv *priv =3D netdev_priv(dev);
+	struct eray_cc *cc =3D priv->cc;
+	struct eray_msgbuf_cfg *cfg;
+	u8 fdb, ffb, lcb, splm;
+	u32 reg, dp =3D ERAY_MAX_MEM;
+	int i, ret;
+
+	if (!cc->ssync_num)
+		return 0;
+
+	fdb =3D 0x80;	/* only static msgbuf in self sync */
+	ffb =3D 0x80;	/* non FIFO in self sync */
+	lcb =3D cc->ssync_num ? cc->ssync_num - 1 : 0x80;
+	splm =3D (cc->ssync_num > 1) ? 1 : 0;
+
+	eray_chg_reg(fdb, cc, ERAY_MRC + FC_SSYNC_OFFSET,
+		     ERAY_MRC_FDB_MASK, ERAY_MRC_FDB_SHIFT);
+	eray_chg_reg(ffb, cc, ERAY_MRC + FC_SSYNC_OFFSET,
+		     ERAY_MRC_FFB_MASK, ERAY_MRC_FFB_SHIFT);
+	eray_chg_reg(lcb, cc, ERAY_MRC + FC_SSYNC_OFFSET,
+		     ERAY_MRC_LCB_MASK, ERAY_MRC_LCB_SHIFT);
+	eray_chg_reg(splm, cc, ERAY_MRC + FC_SSYNC_OFFSET,
+		     ERAY_MRC_SPLM_MASK, ERAY_MRC_SPLM_SHIFT);
+
+	for (i =3D 0; i < cc->ssync_num; i++) {
+		cfg =3D &cc->ssync_cfg[i];
+
+		/* self sync need no mapping */
+		cfg->id =3D i;
+
+		cfg->len =3D cc->static_len;
+
+		/* WRHS1 */
+		reg =3D (cfg->frame_id << ERAY_WRHS1_FID_SHIFT) &
+			ERAY_WRHS1_FID_MASK;
+		reg |=3D (cfg->cyc << ERAY_WRHS1_CYC_SHIFT) &
+			ERAY_WRHS1_CYC_MASK;
+		reg |=3D (cfg->channel << ERAY_WRHS1_CH_SHIFT) &
+			ERAY_WRHS1_CH_MASK;
+		reg |=3D ERAY_WRHS1_CFG_MASK;
+		if (cfg->flags & ERAY_MSGBUF_PPIT)
+			reg |=3D ERAY_WRHS1_PPIT_MASK;
+		if (cfg->flags & FC_MSGBUF_ACK)
+			reg |=3D ERAY_WRHS1_MBI_MASK;
+
+		/* if ERAY_WRHS1_TXM is *not* set the ERAY core
+		 * works in continous mode.
+		 */
+		if (!(cfg->flags & ERAY_MSGBUF_TXCONT))
+			reg |=3D ERAY_WRHS1_TXM_MASK;
+		cfg->wrhs1 =3D reg;
+
+		/* WRHS2 */
+		reg =3D crc_header(cfg) & ERAY_WRHS2_CRC_MASK;
+		reg |=3D (cfg->max << ERAY_WRHS2_PLC_SHIFT) &
+			ERAY_WRHS2_PLC_MASK;
+		cfg->wrhs2 =3D reg;
+
+		/* WRHS3 */
+		dp -=3D DIV_ROUND_UP(cfg->max, 2);
+		reg =3D dp & ERAY_WRHS3_DP_MASK;
+		cfg->wrhs3 =3D reg;
+
+		eray_dump_msg_cfg(cfg, i, __func__);
+
+		ret =3D fc_wait_for_ram_offset(cc, FC_SSYNC_OFFSET);
+		if (ret)
+			goto out;
+
+		eray_writel(cfg->wrhs1, cc, ERAY_WRHS1 + FC_SSYNC_OFFSET);
+		eray_writel(cfg->wrhs2, cc, ERAY_WRHS2 + FC_SSYNC_OFFSET);
+		eray_writel(cfg->wrhs3, cc, ERAY_WRHS3 + FC_SSYNC_OFFSET);
+		eray_writel(ERAY_IBCM_LHSH_MASK, cc,
+				ERAY_IBCM + FC_SSYNC_OFFSET);
+
+		/* set the new configuration */
+		eray_writel(cfg->id, cc, ERAY_IBCR + FC_SSYNC_OFFSET);
+
+		ret =3D fc_wait_for_ram_offset(cc, FC_SSYNC_OFFSET);
+		if (ret)
+			goto out;
+
+		reg =3D 0x0;
+		if (cfg->flags & FC_MSGBUF_ACK) {
+			reg |=3D cfg->cyc << FC_BUF_INFO_CYC_SHIFT;
+			reg |=3D cfg->channel << FC_BUF_INFO_CHANNEL_SHIFT;
+			reg |=3D cfg->frame_id;
+
+			if (cfg->flags & FC_MSGBUF_ACK_PAYLOAD)
+				reg |=3D FC_BUF_INFO_ENABLE_PAYLOAD;
+			if (cfg->flags & FC_MSGBUF_ACK_NULL)
+				reg |=3D FC_BUF_INFO_ENABLE_NULLFRAMES;
+			if (cfg->type =3D=3D eray_msgbuf_type_tx)
+				reg |=3D FC_BUF_INFO_IS_TX;
+		}
+
+		eray_writel(reg, cc, (FC_BUFFER_INFO_TABLE + i * 4) +
+				FC_SSYNC_TXACK_OFFSET);
+	}
+
+	for (i =3D 0; i < cc->ssync_num; i++) {
+		int tx_buf_id;
+
+		cfg =3D &cc->ssync_cfg[i];
+		if (cfg->flags & ERAY_MSGBUF_TXCONT) {
+			tx_buf_id =3D i | FC_FLEX_ID_SSYNC_FLAG;
+			ret =3D _fc_write_data(priv, tx_buf_id,
+					     cfg->tx_cont_data,
+					     cfg->tx_cont_len);
+			if (ret)
+				goto out;
+		}
+	}
+
+out:
+	return ret;
+}
+
+static int fc_prepare_msgbuf_data(struct net_device *dev)
+{
+	struct flexcard_priv *priv =3D netdev_priv(dev);
+	struct eray_cc *cc =3D priv->cc;
+	struct eray_msgbuf_cfg *cfg;
+	unsigned long flags;
+	u32 reg, sum_flags =3D 0, dp =3D ERAY_MAX_MEM;
+	u8 fdb, ffb, lcb, splm, ndyn =3D 0, nfifo =3D 0;
+	int i, remain, ret =3D -EINVAL, map_i =3D 0;
+	unsigned int remain_nr;
+
+	spin_lock_irqsave(&cc->lock, flags);
+
+	if (cc->act_cfg > ERAY_MAX_BUFS) {
+		netdev_err(dev, "too many msg buffers (%d)\n", cc->act_cfg);
+		goto out;
+	}
+
+	for (i =3D 0; i < cc->act_cfg; i++) {
+		cc->cfg[i].id =3D 0xff;
+		cc->cfg[i].len =3D 0;
+	}
+
+	if (!cc->fifo_len)
+		cc->fifo_len =3D 127;
+
+	remain =3D remain_buffer_entries(cc);
+	if (remain < 0) {
+		netdev_err(dev, "buffer memory exhausted (%d)\n",
+			   ERAY_MAX_MEM + remain);
+		goto out;
+	}
+
+	/* map all remaining message buffers as fifo buffer */
+	remain_nr =3D DIV_ROUND_UP(cc->fifo_len, 2) + ERAY_MSGBUF_CFG_LEN;
+	remain_nr =3D remain / remain_nr;
+	if (remain_nr)
+		remain_nr--;
+
+	if (cc->act_cfg + remain_nr > ERAY_MAX_BUFS)
+		remain_nr =3D ERAY_MAX_BUFS - cc->act_cfg;
+
+	for (i =3D cc->act_cfg; i < cc->act_cfg + remain_nr; i++) {
+		cc->cfg[i].flags |=3D ERAY_MSGBUF_USED;
+		cc->cfg[i].id =3D 0xff;
+		cc->cfg[i].type =3D eray_msgbuf_type_fifo;
+
+		/* copy fifo reject configuration from message buffer 0 */
+		cc->cfg[i].channel =3D cc->cfg[0].channel;
+		cc->cfg[i].frame_id =3D cc->cfg[0].frame_id;
+		cc->cfg[i].cyc =3D cc->cfg[0].cyc;
+		cc->cfg[i].reject_mask =3D cc->cfg[0].reject_mask;
+	}
+	cc->act_cfg +=3D remain_nr;
+
+	eray_get_val16(&cc->static_id, cc,
+		      ERAY_GTUC7, ERAY_GTUC7_NSS_MASK, ERAY_GTUC7_NSS_SHIFT);
+
+	eray_get_val8(&cc->static_len, cc,
+		      ERAY_MHDC, ERAY_MHDC_SFDL_MASK, ERAY_MHDC_SFDL_SHIFT);
+
+	/* Map sync buffers first */
+	for (i =3D 0; i < cc->act_cfg; i++) {
+		cfg =3D &cc->cfg[i];
+
+		if (cfg->type !=3D eray_msgbuf_type_tx)
+			continue;
+		if (cfg->frame_id =3D=3D 0)
+			continue;
+		if (!(cfg->flags & ERAY_MSGBUF_SYNC))
+			continue;
+
+		cfg->id =3D map_i;
+		cc->rev_id[map_i] =3D cfg->id;
+		map_i++;
+		ndyn++;
+	}
+
+	/* then map tx buffers */
+	for (i =3D 0; i < cc->act_cfg; i++) {
+		cfg =3D &cc->cfg[i];
+
+		if (cfg->type !=3D eray_msgbuf_type_tx)
+			continue;
+		if (cfg->frame_id =3D=3D 0)
+			continue;
+		if (cfg->flags & ERAY_MSGBUF_SYNC)
+			continue;
+
+		cfg->id =3D map_i;
+		cc->rev_id[map_i] =3D cfg->id;
+		map_i++;
+		ndyn++;
+	}
+
+	/* then map RX buffers */
+	for (i =3D 0; i < cc->act_cfg; i++) {
+		cfg =3D &cc->cfg[i];
+
+		if (cfg->type !=3D eray_msgbuf_type_rx)
+			continue;
+
+		cfg->id =3D map_i;
+		cc->rev_id[map_i] =3D cfg->id;
+		map_i++;
+		ndyn++;
+	}
+
+	/* then map fifo buffers */
+	for (i =3D 0; i < cc->act_cfg; i++) {
+
+		cfg =3D &cc->cfg[i];
+
+		if (cfg->type !=3D eray_msgbuf_type_fifo)
+			continue;
+
+		/* assign mapping */
+		cfg->len =3D cfg->max =3D cc->fifo_len;
+		cfg->id =3D map_i;
+
+		/* summarize all flags */
+		cc->rev_id[map_i] =3D cfg->id;
+		sum_flags |=3D cfg->flags;
+
+		map_i++;
+		nfifo++;
+	}
+
+	/* CLEAR_RAMS can only be called in DEFAULT_CONFIG or CONFIG mode */
+	ret =3D cc_change_state(cc, ERAY_CMD_CONFIG, 5);
+	if (ret < 0) {
+		netdev_err(dev, "CC DEFAULT_CONFIG failed\n");
+		goto out;
+	}
+
+	ret =3D cc_change_state(cc, ERAY_CMD_CLEAR_RAMS, 15);
+	if (ret < 0)
+		netdev_err(dev, "%s: CC CLEAR_RAMS failed\n", __func__);
+
+	fdb =3D ndyn ? 0 : 0x80;
+	ffb =3D nfifo ? ndyn : 0x80;
+	lcb =3D map_i ? map_i - 1 : 0x80;
+	splm =3D (cc->sync_num > 1) ? 1 : 0;
+
+	if (ndyn + nfifo !=3D map_i)
+		netdev_warn(dev, "invalid msg buffer configuration\n");
+
+	eray_chg_reg(fdb, cc, ERAY_MRC, ERAY_MRC_FDB_MASK, ERAY_MRC_FDB_SHIFT=
);
+	eray_chg_reg(ffb, cc, ERAY_MRC, ERAY_MRC_FFB_MASK, ERAY_MRC_FFB_SHIFT=
);
+	eray_chg_reg(lcb, cc, ERAY_MRC, ERAY_MRC_LCB_MASK, ERAY_MRC_LCB_SHIFT=
);
+	eray_chg_reg(splm, cc, ERAY_MRC, ERAY_MRC_SPLM_MASK,
+			ERAY_MRC_SPLM_SHIFT);
+	/* setup data for registers */
+	for (i =3D 0; i < cc->act_cfg; i++) {
+		cfg =3D &cc->cfg[i];
+
+		switch (cfg->type) {
+		case eray_msgbuf_type_none:
+			continue;
+
+		case eray_msgbuf_type_fifo:
+			cfg->wrhs1 =3D 0;
+			cfg->wrhs2 =3D (cc->fifo_len << ERAY_WRHS2_PLC_SHIFT) &
+				ERAY_WRHS2_PLC_MASK;
+
+			reg =3D (cfg->frame_id << ERAY_FRF_FID_SHIFT) &
+				ERAY_FRF_FID_MASK;
+			reg |=3D (cfg->cyc << ERAY_FRF_CYC_SHIFT) &
+				ERAY_FRF_CYC_MASK;
+			reg |=3D (cfg->channel << ERAY_FRF_CH_SHIFT) &
+				ERAY_FRF_CH_MASK;
+			if (sum_flags & ERAY_MSGBUF_FIFOREJ_NULL)
+				reg |=3D ERAY_FRF_RNF_MASK;
+			if (sum_flags & ERAY_MSGBUF_FIFOREJ_INSEG)
+				reg |=3D ERAY_FRF_RSS_MASK;
+
+			eray_writel(reg, cc, ERAY_FRF);
+
+			reg =3D (cfg->reject_mask << ERAY_FRFM_MFID_SHIFT) &
+				ERAY_FRFM_MFID_MASK;
+
+			eray_writel(reg, cc, ERAY_FRFM);
+
+			break;
+
+		case eray_msgbuf_type_rx:
+			reg =3D (cfg->frame_id << ERAY_WRHS1_FID_SHIFT) &
+				ERAY_WRHS1_FID_MASK;
+			reg |=3D (cfg->cyc << ERAY_WRHS1_CYC_SHIFT) &
+				ERAY_WRHS1_CYC_MASK;
+			reg |=3D (cfg->channel << ERAY_WRHS1_CH_SHIFT) &
+				ERAY_WRHS1_CH_MASK;
+			cfg->wrhs1 =3D reg;
+
+			reg =3D (cfg->max << ERAY_WRHS2_PLC_SHIFT) &
+				ERAY_WRHS2_PLC_MASK;
+			cfg->wrhs2 =3D reg;
+			break;
+
+		case eray_msgbuf_type_tx:
+			reg =3D (cfg->frame_id << ERAY_WRHS1_FID_SHIFT) &
+				ERAY_WRHS1_FID_MASK;
+			reg |=3D (cfg->cyc << ERAY_WRHS1_CYC_SHIFT) &
+				ERAY_WRHS1_CYC_MASK;
+			reg |=3D (cfg->channel << ERAY_WRHS1_CH_SHIFT) &
+				ERAY_WRHS1_CH_MASK;
+			reg |=3D ERAY_WRHS1_CFG_MASK;
+			if (cfg->flags & ERAY_MSGBUF_PPIT)
+				reg |=3D ERAY_WRHS1_PPIT_MASK;
+			if (cfg->flags & FC_MSGBUF_ACK)
+				reg |=3D ERAY_WRHS1_MBI_MASK;
+
+			/* if ERAY_WRHS1_TXM is *not* set the ERAY core
+			 * works in continous mode.
+			 */
+			if (!(cfg->flags & ERAY_MSGBUF_TXCONT))
+				reg |=3D ERAY_WRHS1_TXM_MASK;
+			cfg->wrhs1 =3D reg;
+
+			if (cfg->frame_id <=3D cc->static_id)
+				cfg->len =3D cc->static_len;
+			else
+				cfg->len =3D cfg->max;
+
+			reg =3D crc_header(cfg) & ERAY_WRHS2_CRC_MASK;
+			reg |=3D (cfg->max << ERAY_WRHS2_PLC_SHIFT) &
+				ERAY_WRHS2_PLC_MASK;
+			cfg->wrhs2 =3D reg;
+			break;
+
+		default:
+			netdev_warn(dev, "unknown msgbuf type %d ignored\n",
+				    cfg->type);
+			continue;
+		}
+
+		/* WRHS3 */
+		dp -=3D DIV_ROUND_UP(cfg->max, 2);
+		reg =3D dp & ERAY_WRHS3_DP_MASK;
+		cfg->wrhs3 =3D reg;
+
+		eray_dump_msg_cfg(cfg, i, __func__);
+
+		ret =3D fc_wait_for_ram(cc);
+		if (ret)
+			goto out;
+
+		eray_writel(cfg->wrhs1, cc, ERAY_WRHS1);
+		eray_writel(cfg->wrhs2, cc, ERAY_WRHS2);
+		eray_writel(cfg->wrhs3, cc, ERAY_WRHS3);
+		eray_writel(ERAY_IBCM_LHSH_MASK, cc, ERAY_IBCM);
+
+		/* set the new configuration */
+		eray_writel(cfg->id, cc, ERAY_IBCR);
+
+		ret =3D fc_wait_for_ram(cc);
+		if (ret)
+			goto out;
+
+		reg =3D 0x0;
+		if (cfg->flags & FC_MSGBUF_ACK) {
+			reg |=3D cfg->cyc << FC_BUF_INFO_CYC_SHIFT;
+			reg |=3D cfg->channel << FC_BUF_INFO_CHANNEL_SHIFT;
+			reg |=3D cfg->frame_id;
+
+			if (cfg->flags & FC_MSGBUF_ACK_PAYLOAD)
+				reg |=3D FC_BUF_INFO_ENABLE_PAYLOAD;
+			if (cfg->flags & FC_MSGBUF_ACK_NULL)
+				reg |=3D FC_BUF_INFO_ENABLE_NULLFRAMES;
+			if (cfg->type =3D=3D eray_msgbuf_type_tx)
+				reg |=3D FC_BUF_INFO_IS_TX;
+		}
+
+		eray_writel(reg, cc, FC_BUFFER_INFO_TABLE + i*4);
+	}
+
+	/* To setup E-Ray to send startup/sync frames the appropriate
+	 * bits in the SUCC1 must be set. To carry out the configuration
+	 * a ALLOW_COLDSTART command must be executed.
+	 */
+	if ((cc->sync_start & ERAY_MSGBUF_STARTUP) ||
+	    (cc->sync_start & ERAY_MSGBUF_SYNC)) {
+		reg =3D eray_read_succ1(cc, 10);
+		if (reg < 0) {
+			ret =3D -EBUSY;
+			goto out;
+		}
+
+		if (cc->sync_start & ERAY_MSGBUF_STARTUP)
+			reg |=3D ERAY_SUCC1_TXST_MASK;
+
+		if (cc->sync_start & ERAY_MSGBUF_SYNC)
+			reg |=3D ERAY_SUCC1_TXSY_MASK;
+
+		reg &=3D ~ERAY_SUCC1_CMD_MASK;
+		reg |=3D ERAY_CMD_ALLOW_COLDSTART;
+
+		eray_writel(reg, cc, ERAY_SUCC1);
+	}
+
+	cc->ready =3D 1;
+
+	for (i =3D 0; i < cc->act_cfg; i++) {
+		cfg =3D &cc->cfg[i];
+
+		if ((cfg->type =3D=3D eray_msgbuf_type_tx) &&
+		    cfg->flags & ERAY_MSGBUF_TXCONT) {
+			ret =3D _fc_write_data(priv, i, cfg->tx_cont_data,
+					     cfg->tx_cont_len);
+			if (ret)
+				goto out;
+		}
+	}
+
+	ret =3D fc_prepare_msgbuf_data_ssync(dev);
+	if (ret)
+		goto out;
+
+	ret =3D 0;
+out:
+	spin_unlock_irqrestore(&cc->lock, flags);
+
+	return ret;
+}
+
+static int fc_write_data(struct flexcard_priv *priv, unsigned int msgb=
uf_id,
+			 unsigned char *payload, size_t byte_len)
+{
+	struct eray_cc *cc =3D priv->cc;
+	int ret;
+
+	spin_lock(&cc->lock);
+	ret =3D _fc_write_data(priv, msgbuf_id, payload, byte_len);
+	spin_unlock(&cc->lock);
+
+	return ret;
+}
+
+static int _fc_write_data(struct flexcard_priv *priv, unsigned int msg=
buf_id,
+			  unsigned char *payload, size_t byte_len)
+{
+	struct eray_cc *cc =3D priv->cc;
+	struct eray_msgbuf_cfg *cfg;
+	u32 txrq, *data =3D (u32 *) payload;
+	int i, count, rem, err;
+	u32 offset =3D 0;
+	int ssync;
+
+	ssync =3D (msgbuf_id & FC_FLEX_ID_SSYNC_FLAG) ? 1 : 0;
+	msgbuf_id &=3D ~(FC_FLEX_ID_SSYNC_FLAG);
+	if (ssync) {
+		offset =3D FC_SSYNC_OFFSET;
+		cfg =3D &cc->ssync_cfg[msgbuf_id];
+	} else
+		cfg =3D &cc->cfg[msgbuf_id];
+
+	if (cfg->flags & ERAY_MSGBUF_TXCONT) {
+		if (byte_len > 256)
+			byte_len =3D 256;
+		cfg->tx_cont_len =3D byte_len;
+
+		memcpy(cfg->tx_cont_data, payload, cfg->tx_cont_len);
+	}
+
+	if (!cc->ready) {
+		/* Discard packets if CC is not ready. If we return an error
+		 * here we never make progress and recover from this state.
+		 */
+		err =3D 0;
+		goto out;
+	}
+
+	/* ignore TXRQ bit in continous mode since it is allways set */
+	if (!(cfg->flags & ERAY_MSGBUF_TXCONT)) {
+		txrq =3D eray_readl(cc, (ERAY_TXRQ1 + cfg->id/32) + offset);
+		if (txrq & 1 << (cfg->id%32)) {
+			err =3D -EBUSY;
+			goto out;
+		}
+	}
+
+	err =3D fc_wait_for_ram_offset(cc, offset);
+	if (err)
+		goto out;
+
+	/* check packet length to decide if message buffer configuration
+	 * needs to be reprogrammed.
+	 */
+	if (((byte_len + 1) / 2) !=3D cfg->len) {
+		u32 reg;
+
+		/* setup wrhs2 again */
+		cfg->len  =3D (byte_len + 1) / 2;
+
+		if (cfg->frame_id < cc->static_id)
+			reg =3D cfg->wrhs2 & ERAY_WRHS2_CRC_MASK;
+		else
+			reg =3D crc_header(cfg) & ERAY_WRHS2_CRC_MASK;
+		reg |=3D (cfg->len << ERAY_WRHS2_PLC_SHIFT) &
+			ERAY_WRHS2_PLC_MASK;
+		cfg->wrhs2 =3D reg;
+
+		/* write msgbuf config */
+		eray_writel(cfg->wrhs1, cc, ERAY_WRHS1 + offset);
+		eray_writel(cfg->wrhs2, cc, ERAY_WRHS2 + offset);
+		eray_writel(cfg->wrhs3, cc, ERAY_WRHS3 + offset);
+
+		eray_writel(ERAY_IBCM_LHSH_MASK, cc, ERAY_IBCM + offset);
+		eray_writel(cfg->id & ERAY_IBCR_IBRH_MASK, cc,
+				ERAY_IBCR + offset);
+		err =3D fc_wait_for_ram_offset(cc, offset);
+		if (err)
+			goto out;
+
+	}
+
+	count =3D byte_len >> 2;
+	rem =3D byte_len & 0x3;
+
+	/* write 32-bit data words */
+	for (i =3D 0; i < count; i++)
+		eray_writel(cpu_to_le32(data[i]), cc, ERAY_WRDS(i) + offset);
+
+	/* write remaining data bytes */
+	if (rem) {
+		u32 wrd =3D 0;
+		memcpy(&wrd, &payload[byte_len - rem], rem);
+		eray_writel(cpu_to_le32(wrd), cc, ERAY_WRDS(i) + offset);
+	}
+
+	eray_writel(ERAY_IBCM_LDSH_MASK | ERAY_IBCM_STXRH_MASK, cc,
+			ERAY_IBCM + offset);
+	eray_writel(cfg->id & ERAY_IBCR_IBRH_MASK, cc, ERAY_IBCR + offset);
+
+	err =3D fc_wait_for_ram_offset(cc, offset);
+	if (!err) {
+		spin_lock(&cfg->lock);
+		cfg->queued =3D 0;
+		spin_unlock(&cfg->lock);
+	}
+out:
+	return err;
+}
+
+static enum eray_cc_state e_state(enum flexray_state state)
+{
+	switch (state) {
+	case FLEXRAY_STATE_DEFAULT_CONFIG:
+		return ERAY_CMD_FREEZE;
+	case FLEXRAY_STATE_CONFIG:
+		return ERAY_CMD_CONFIG;
+	case FLEXRAY_STATE_READY:
+		return ERAY_CMD_READY;
+	case FLEXRAY_STATE_WAKEUP:
+		return ERAY_CMD_WAKEUP;
+	case FLEXRAY_STATE_STARTUP:
+		return ERAY_CMD_RUN;
+	case FLEXRAY_STATE_HALT:
+		return ERAY_CMD_HALT;
+	case FLEXRAY_STATE_MONITOR_MODE:
+		return ERAY_CMD_MONITOR_MODE;
+	case FLEXRAY_STATE_COLDSTART:
+		return ERAY_CMD_ALLOW_COLDSTART;
+	case FLEXRAY_STATE_NORMAL_ACTIVE:
+	case FLEXRAY_STATE_NORMAL_PASSIVE:
+	case FLEXRAY_STATE_MAX:
+	case FLEXRAY_STATE_UNSPEC:
+	default:
+		return ERAY_CMD_INVALID;
+	}
+}
+
+static int cc_change_state(struct eray_cc *cc, enum eray_cc_state stat=
e,
+			   int retry)
+{
+	u32 stat;
+
+	stat =3D eray_read_succ1(cc, 10);
+	if (stat < 0)
+		return -EBUSY;
+
+	stat &=3D ~ERAY_SUCC1_CMD_MASK;
+	stat |=3D state;
+
+	if (state =3D=3D ERAY_CMD_READY || state =3D=3D ERAY_CMD_MONITOR_MODE=
) {
+		eray_writel(0xCE, cc, ERAY_LCK);
+		eray_writel(0x31, cc, ERAY_LCK);
+	}
+
+	eray_writel(stat, cc, ERAY_SUCC1);
+
+	stat =3D eray_read_succ1(cc, retry);
+	if (!(stat & ERAY_SUCC1_CMD_MASK))
+		return -EINVAL;
+
+	if (state =3D=3D ERAY_CMD_FREEZE) {
+		stat &=3D ~ERAY_SUCC1_CMD_MASK;
+		stat |=3D ERAY_CMD_CONFIG;
+		eray_writel(stat, cc, ERAY_SUCC1);
+
+		stat =3D eray_read_succ1(cc, retry);
+		if (!(stat & ERAY_SUCC1_CMD_MASK))
+			return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int cc_reset(struct net_device *dev)
+{
+	struct flexcard_priv *priv =3D netdev_priv(dev);
+	struct eray_cc *cc =3D priv->cc;
+	int ret;
+
+	/* Set FR CCs to a well-defined state,
+	 * because the cc reset doesn't work always
+	 * 1. send freeze command
+	 * 2. wait for halt state
+	 * 3. send config command
+	 * 4. wait for default config state
+	 * 5. send clear_rams command
+	 * 6. wait max. 150 us for end of ram initialization
+	 * (calculated time 62 us)
+	 * 7. Flexcard reset (50us settle time)
+	 * 8 Flexcard Filter reset (70us settle time)
+	 */
+
+	ret =3D cc_change_state(cc, ERAY_CMD_FREEZE, 5);
+	if (ret < 0) {
+		dev_err(&dev->dev, "CC FREEZE failed\n");
+		goto out;
+	}
+
+	ret =3D cc_change_state(cc, ERAY_CMD_CONFIG, 5);
+	if (ret < 0) {
+		dev_err(&dev->dev, "CC DEFAULT_CONFIG failed\n");
+		goto out;
+	}
+
+	ret =3D cc_change_state(cc, ERAY_CMD_CLEAR_RAMS, 15);
+	if (ret < 0) {
+		netdev_err(dev, "%s: CC CLEAR_RAMS failed\n", __func__);
+		goto out;
+	}
+
+	writel(1<<priv->id, priv->conf + FC_FC_RESET);
+	udelay(50);
+
+	eray_writel(0, cc, FC_RXFILTID);
+	eray_writel(3, cc, FC_RXFILTCH);
+	eray_writel(0, cc, FC_TXFILTID);
+	eray_writel(0, cc, FC_TXFILTCH);
+	udelay(70);
+
+	ret =3D cc_change_state(cc, ERAY_CMD_CONFIG, 5);
+	if (ret < 0) {
+		dev_err(&dev->dev, "CC CONFIG failed\n");
+		goto out;
+	}
+
+	eray_writel(0, cc, ERAY_MHDC);
+	eray_writel(0, cc, ERAY_GTUC7);
+
+out:
+	return ret;
+}
+
+static void cc_get_conf(struct net_device *dev)
+{
+	struct flexcard_priv *priv =3D netdev_priv(dev);
+	struct eray_cc *cc =3D priv->cc;
+	struct flexray_priv *flexray =3D &priv->flexray;
+	u8 BRP, EOCC, ERCC;
+
+	eray_get_val16(&cc->static_id, cc,
+		      ERAY_GTUC7, ERAY_GTUC7_NSS_MASK, ERAY_GTUC7_NSS_SHIFT);
+
+	eray_get_val8(&cc->static_len, cc,
+		      ERAY_MHDC, ERAY_MHDC_SFDL_MASK, ERAY_MHDC_SFDL_SHIFT);
+
+	/* cluster */
+	eray_get_val8(&flexray->cluster.gColdstartAttempts, cc,
+		      ERAY_SUCC1, ERAY_SUCC1_CSA_MASK, ERAY_SUCC1_CSA_SHIFT);
+	eray_get_val8(&flexray->cluster.gdCASRxLowMax, cc,
+		      ERAY_PRTC1, ERAY_PRTC1_CASM_MASK, ERAY_PRTC1_CASM_SHIFT);
+	eray_get_val8(&flexray->cluster.gdTSSTransmitter, cc,
+		      ERAY_PRTC1, ERAY_PRTC1_TSST_MASK, ERAY_PRTC1_TSST_SHIFT);
+	eray_get_val8(&flexray->cluster.gListenNoise, cc,
+		      ERAY_SUCC2, ERAY_SUCC2_LTN_MASK, ERAY_SUCC2_LTN_SHIFT);
+	flexray->cluster.gListenNoise +=3D 1;
+	eray_get_val8(&flexray->cluster.gMaxWithoutClockCorrectionFatal, cc,
+		      ERAY_SUCC3, ERAY_SUCC3_WCF_MASK, ERAY_SUCC3_WCF_SHIFT);
+	eray_get_val8(&flexray->cluster.gMaxWithoutClockCorrectionPassive, cc=
,
+		      ERAY_SUCC3, ERAY_SUCC3_WCP_MASK, ERAY_SUCC3_WCP_SHIFT);
+	eray_get_val8(&BRP, cc,
+		      ERAY_PRTC1, ERAY_PRTC1_BRP_MASK, ERAY_PRTC1_BRP_SHIFT);
+	switch (BRP) {
+	case 0:
+		flexray->cluster.gdSampleClockPeriod =3D 1;
+		flexray->node.pSamplesPerMicrotick =3D 2;
+		break;
+	case 1:
+		flexray->cluster.gdSampleClockPeriod =3D 2;
+		flexray->node.pSamplesPerMicrotick =3D 1;
+		break;
+	case 2:
+	case 3:
+		flexray->cluster.gdSampleClockPeriod =3D 4;
+		flexray->node.pSamplesPerMicrotick =3D 1;
+		break;
+	}
+	eray_get_val8(&flexray->cluster.gNetworkManagementVectorLength, cc,
+		      ERAY_NEMC, ERAY_NEMC_NML_MASK, ERAY_NEMC_NML_SHIFT);
+	eray_get_val16(&flexray->cluster.v2.gdWakeupSymbolRxWindow, cc,
+		       ERAY_PRTC1, ERAY_PRTC1_RXW_MASK, ERAY_PRTC1_RXW_SHIFT);
+	eray_get_val8(&flexray->cluster.v2.gdWakeupSymbolRxIdle, cc,
+		      ERAY_PRTC2, ERAY_PRTC2_RXI_MASK, ERAY_PRTC2_RXI_SHIFT);
+	eray_get_val8(&flexray->cluster.v2.gdWakeupSymbolRxLow, cc,
+		      ERAY_PRTC2, ERAY_PRTC2_RXL_MASK, ERAY_PRTC2_RXL_SHIFT);
+	eray_get_val8(&flexray->cluster.v2.gdWakeupSymbolTxIdle, cc,
+		      ERAY_PRTC2, ERAY_PRTC2_TXI_MASK, ERAY_PRTC2_TXI_SHIFT);
+	eray_get_val8(&flexray->cluster.v2.gdWakeupSymbolTxLow, cc,
+		      ERAY_PRTC2, ERAY_PRTC2_TXL_MASK, ERAY_PRTC2_TXL_SHIFT);
+	eray_get_val8(&flexray->cluster.gPayloadLengthStatic, cc,
+		      ERAY_MHDC, ERAY_MHDC_SFDL_MASK, ERAY_MHDC_SFDL_SHIFT);
+	eray_get_val16(&flexray->cluster.gMacroPerCycle, cc,
+		       ERAY_GTUC2, ERAY_GTUC2_MPC_MASK, ERAY_GTUC2_MPC_SHIFT);
+	eray_get_val8(&flexray->cluster.v2.gSyncNodeMax, cc,
+		      ERAY_GTUC2, ERAY_GTUC2_SNM_MASK, ERAY_GTUC2_SNM_SHIFT);
+	eray_get_val16(&flexray->cluster.gdNIT, cc,
+		      ERAY_GTUC4, ERAY_GTUC4_NIT_MASK, ERAY_GTUC4_NIT_SHIFT);
+	flexray->cluster.gdNIT =3D flexray->cluster.gMacroPerCycle - 1 -
+		flexray->cluster.gdNIT;
+	eray_get_val16(&flexray->cluster.v2.gOffsetCorrectionStart, cc,
+		       ERAY_GTUC4, ERAY_GTUC4_OCS_MASK, ERAY_GTUC4_OCS_SHIFT);
+	flexray->cluster.v2.gOffsetCorrectionStart +=3D 1;
+	eray_get_val16(&flexray->cluster.gdStaticSlot, cc,
+		       ERAY_GTUC7, ERAY_GTUC7_SSL_MASK, ERAY_GTUC7_SSL_SHIFT);
+	eray_get_val16(&flexray->cluster.gNumberOfStaticSlots, cc,
+		       ERAY_GTUC7, ERAY_GTUC7_NSS_MASK, ERAY_GTUC7_NSS_SHIFT);
+	eray_get_val8(&flexray->cluster.gdMinislot, cc,
+		      ERAY_GTUC8, ERAY_GTUC8_MSL_MASK, ERAY_GTUC8_MSL_SHIFT);
+	eray_get_val16(&flexray->cluster.gNumberOfMinislots, cc,
+		       ERAY_GTUC8, ERAY_GTUC8_NMS_MASK, ERAY_GTUC8_NMS_SHIFT);
+	eray_get_val8(&flexray->cluster.gdActionPointOffset, cc,
+		      ERAY_GTUC9, ERAY_GTUC9_APO_MASK, ERAY_GTUC9_APO_SHIFT);
+	eray_get_val8(&flexray->cluster.gdMinislotActionPointOffset, cc,
+		      ERAY_GTUC9, ERAY_GTUC9_MAPO_MASK, ERAY_GTUC9_MAPO_SHIFT);
+	eray_get_val8(&flexray->cluster.gdDynamicSlotIdlePhase, cc,
+		     ERAY_GTUC9, ERAY_GTUC9_DSI_MASK, ERAY_GTUC9_DSI_SHIFT);
+
+	/* node */
+	eray_get_val8(&flexray->node.pAllowHaltDueToClock, cc,
+		      ERAY_SUCC1, ERAY_SUCC1_HCSE_MASK, ERAY_SUCC1_HCSE_SHIFT);
+	eray_get_val8(&flexray->node.pAllowPassiveToActive, cc,
+		      ERAY_SUCC1, ERAY_SUCC1_PTA_MASK, ERAY_SUCC1_PTA_SHIFT);
+	eray_get_val8(&flexray->node.pChannels, cc,
+		      ERAY_SUCC1, ERAY_SUCC1_CCH_MASK, ERAY_SUCC1_CCH_SHIFT);
+	eray_get_val32(&flexray->node.pdListenTimeout, cc,
+		       ERAY_SUCC2, ERAY_SUCC2_LT_MASK, ERAY_SUCC2_LT_SHIFT);
+	eray_get_val8(&flexray->node.v2.pSingleSlotEnabled, cc,
+		      ERAY_SUCC1, ERAY_SUCC1_TSM_MASK, ERAY_SUCC1_TSM_SHIFT);
+	eray_get_val8(&flexray->node.pKeySlotUsedForStartup, cc,
+		      ERAY_SUCC1, ERAY_SUCC1_TXST_MASK, ERAY_SUCC1_TXST_SHIFT);
+	eray_get_val8(&flexray->node.pKeySlotUsedForSync, cc,
+		      ERAY_SUCC1, ERAY_SUCC1_TXSY_MASK, ERAY_SUCC1_TXSY_SHIFT);
+	eray_get_val8(&flexray->node.pWakeupChannel, cc,
+		      ERAY_SUCC1, ERAY_SUCC1_WUCS_MASK, ERAY_SUCC1_WUCS_SHIFT);
+	eray_get_val8(&flexray->node.pWakeupPattern, cc,
+		      ERAY_PRTC1, ERAY_PRTC1_RWP_MASK, ERAY_PRTC1_RWP_SHIFT);
+	eray_get_val16(&flexray->node.pLatestTx, cc,
+		       ERAY_MHDC, ERAY_MHDC_SLT_MASK, ERAY_MHDC_SLT_SHIFT);
+	eray_get_val32(&flexray->node.pMicroPerCycle, cc,
+		       ERAY_GTUC1, ERAY_GTUC1_UT_MASK, ERAY_GTUC1_UT_SHIFT);
+	eray_get_val16(&flexray->node.pMicroInitialOffsetA, cc,
+		       ERAY_GTUC3, ERAY_GTUC3_UIOA_MASK, ERAY_GTUC3_UIOA_SHIFT);
+	eray_get_val16(&flexray->node.pMicroInitialOffsetB, cc,
+		       ERAY_GTUC3, ERAY_GTUC3_UIOB_MASK, ERAY_GTUC3_UIOB_SHIFT);
+	eray_get_val8(&flexray->node.pMacroInitialOffsetA, cc,
+		      ERAY_GTUC3, ERAY_GTUC3_MIOA_MASK, ERAY_GTUC3_MIOA_SHIFT);
+	eray_get_val8(&flexray->node.pMacroInitialOffsetB, cc,
+		      ERAY_GTUC3, ERAY_GTUC3_MIOB_MASK, ERAY_GTUC3_MIOB_SHIFT);
+	eray_get_val8(&flexray->node.pDelayCompensationA, cc,
+		      ERAY_GTUC5, ERAY_GTUC5_DCA_MASK, ERAY_GTUC5_DCA_SHIFT);
+	eray_get_val8(&flexray->node.pDelayCompensationB, cc,
+		      ERAY_GTUC5, ERAY_GTUC5_DCB_MASK, ERAY_GTUC5_DCB_SHIFT);
+	eray_get_val8(&flexray->node.pClusterDriftDamping, cc,
+		      ERAY_GTUC5, ERAY_GTUC5_CDD_MASK, ERAY_GTUC5_CDD_SHIFT);
+	eray_get_val8(&flexray->node.pDecodingCorrection, cc,
+		      ERAY_GTUC5, ERAY_GTUC5_DEC_MASK, ERAY_GTUC5_DEC_SHIFT);
+	eray_get_val16(&flexray->node.pdAcceptedStartupRange, cc,
+		       ERAY_GTUC6, ERAY_GTUC6_ASR_MASK, ERAY_GTUC6_ASR_SHIFT);
+	eray_get_val16(&flexray->node.v2.pdMaxDrift, cc,
+		       ERAY_GTUC6, ERAY_GTUC6_MOD_MASK, ERAY_GTUC6_MOD_SHIFT);
+	eray_get_val16(&flexray->node.pOffsetCorrectionOut, cc, ERAY_GTUC10,
+			ERAY_GTUC10_MOC_MASK, ERAY_GTUC10_MOC_SHIFT);
+	eray_get_val16(&flexray->node.pRateCorrectionOut, cc, ERAY_GTUC10,
+			ERAY_GTUC10_MRC_MASK, ERAY_GTUC10_MRC_SHIFT);
+	eray_get_val8(&flexray->node.pExternOffsetCorrection, cc,
+		      ERAY_GTUC11, ERAY_GTUC11_EOC_MASK, ERAY_GTUC11_EOC_SHIFT);
+	eray_get_val8(&flexray->node.pExternRateCorrection, cc,
+		      ERAY_GTUC11, ERAY_GTUC11_ERC_MASK, ERAY_GTUC11_ERC_SHIFT);
+	eray_get_val8(&EOCC, cc, ERAY_GTUC11, ERAY_GTUC11_EOCC_MASK,
+			ERAY_GTUC11_EOCC_SHIFT);
+
+	/* symbol */
+	eray_get_val8(&flexray->symbol.pChannelsMTS, cc,
+		      ERAY_SUCC1, ERAY_SUCC1_MTS_MASK, ERAY_SUCC1_MTS_SHIFT);
+
+	switch (EOCC) {
+	case 3:
+		flexray->node.vExternOffsetControl =3D 1;
+		break;
+	case 2:
+		flexray->node.vExternOffsetControl =3D -1;
+		break;
+	default:
+		flexray->node.vExternOffsetControl =3D 0;
+	}
+	eray_get_val8(&ERCC, cc, ERAY_GTUC11, ERAY_GTUC11_ERCC_MASK,
+			ERAY_GTUC11_ERCC_SHIFT);
+	switch (ERCC) {
+	case 3:
+		flexray->node.vExternRateControl =3D 1;
+		break;
+	case 2:
+		flexray->node.vExternRateControl =3D -1;
+		break;
+	default:
+		flexray->node.vExternRateControl =3D 0;
+	}
+}
+
+static void cc_irq_setup(struct net_device *dev)
+{
+	struct flexcard_priv *priv =3D netdev_priv(dev);
+	struct eray_cc *cc =3D priv->cc;
+
+	/* error eray_int0 */
+	eray_writel(0, cc, ERAY_EILS);
+
+	/* status eray_int1 */
+	eray_writel(ERAY_SIR_MASK, cc, ERAY_SILS);
+
+	/* disable error interrupts */
+	eray_writel(0, cc, ERAY_EIES);
+
+	/* enable receive interrupts */
+	eray_writel(ERAY_SIR_RXI, cc, ERAY_SIES);
+
+	/* enable eray_int0 and eray_int1 line */
+	eray_writel(ERAY_ILE_MASK, cc, ERAY_ILE);
+}
+
+static void cc_stopwatch_setup(struct net_device *dev, u32 reg)
+{
+	struct flexcard_priv *priv =3D netdev_priv(dev);
+	struct eray_cc *cc =3D priv->cc;
+
+	eray_writel(reg & 0x3f, cc, ERAY_STPW1);
+}
+
+static struct sk_buff *alloc_flexcard_skb(struct net_device *dev,
+					  struct fc_packet_buf **cf,
+					  size_t len)
+{
+	struct sk_buff *skb;
+
+	skb =3D netdev_alloc_skb(dev, len);
+	if (unlikely(!skb))
+		return NULL;
+
+	skb->protocol =3D htons(ETH_P_FLEXRAY);
+	skb->pkt_type =3D PACKET_BROADCAST;
+	skb->ip_summed =3D CHECKSUM_UNNECESSARY;
+	*cf =3D (struct fc_packet_buf *)skb_put(skb, len);
+
+	return skb;
+}
+
+static int fc_rx_pkt(void *p, void *data, size_t len)
+{
+	struct net_device *dev =3D p;
+	struct net_device_stats *stats =3D &dev->stats;
+	struct flexcard_priv *priv =3D netdev_priv(dev);
+	struct eray_cc *cc =3D priv->cc;
+	struct fc_packet_buf *pb =3D data;
+	union fc_packet_types *pt =3D &pb->packet;
+	struct fc_packet_buf *frf;
+	struct sk_buff *skb;
+	u32 l;
+
+	switch (le32_to_cpu(pb->header.type)) {
+	case fc_packet_type_flexray_frame:
+		l =3D fc_get_packet_len(pt->flexray_frame.header);
+		break;
+	case fc_packet_type_tx_ack:
+		/* The buffer id is visible to userspace. Msg. buffer in
+		 * kernel starts with 0, in oposite to userspace starting
+		 * with 1. Add 1 to buffer id make it even.
+		 */
+		pt->tx_ack_packet.bufferid =3D
+			cc->rev_id[pt->tx_ack_packet.bufferid] + 1;
+		l =3D fc_get_packet_len(pt->tx_ack_packet.header);
+		break;
+	default:
+		l =3D 0;
+	}
+
+	if (len > sizeof(struct fc_packet_buf) + l) {
+		len =3D sizeof(struct fc_packet_buf) + l;
+		WARN(1, "FlexRay payload to large: truncate.");
+	}
+
+	skb =3D alloc_flexcard_skb(dev, &frf, len);
+	if (!skb)
+		return -ENOMEM;
+
+	memcpy(frf, data, len);
+	netif_receive_skb(skb);
+
+	stats->rx_packets++;
+	stats->rx_bytes +=3D len;
+
+	return 0;
+}
+
+static int flexcard_open(struct net_device *dev)
+{
+	int ret =3D -ENOMEM;
+
+	ret =3D cc_reset(dev);
+	if (ret < 0) {
+		netdev_err(dev, "CC reset failed\n");
+		goto out;
+	}
+
+	cc_stopwatch_setup(dev, 0);
+
+	ret =3D open_flexraydev(dev);
+	if (ret) {
+		netdev_err(dev, "open flexray device failed\n");
+		goto out;
+	}
+
+	cc_irq_setup(dev);
+
+	return 0;
+
+out:
+	return ret;
+}
+
+static int flexcard_close(struct net_device *dev)
+{
+	struct flexcard_priv *priv =3D netdev_priv(dev);
+	struct eray_cc *cc =3D priv->cc;
+
+	cc_change_state(cc, ERAY_CMD_FREEZE, 10);
+	netif_stop_queue(dev);
+
+	close_flexraydev(dev);
+
+	return 0;
+}
+
+static int flexcard_get_state(const struct net_device *dev,
+			       enum flexray_state *state)
+{
+	struct flexcard_priv *priv =3D netdev_priv(dev);
+	struct eray_cc *cc =3D priv->cc;
+	int pocs;
+
+	pocs =3D eray_readl(cc, ERAY_CCSV) & 0x3f;
+	switch (pocs) {
+	case 0x00:
+		*state =3D FLEXRAY_STATE_DEFAULT_CONFIG;
+		break;
+	case 0x01:
+		*state =3D FLEXRAY_STATE_READY;
+		break;
+	case 0x02:
+		*state =3D FLEXRAY_STATE_NORMAL_ACTIVE;
+		break;
+	case 0x03:
+		*state =3D FLEXRAY_STATE_NORMAL_PASSIVE;
+		break;
+	case 0x04:
+		*state =3D FLEXRAY_STATE_HALT;
+		break;
+	case 0x05:
+		*state =3D FLEXRAY_STATE_MONITOR_MODE;
+		break;
+	case 0x0f:
+		*state =3D FLEXRAY_STATE_CONFIG;
+		break;
+	case 0x10:
+	case 0x11:
+	case 0x12:
+	case 0x13:
+		*state =3D FLEXRAY_STATE_WAKEUP;
+		break;
+	case 0x20:
+	case 0x21:
+	case 0x22:
+	case 0x24:
+	case 0x25:
+	case 0x26:
+	case 0x27:
+	case 0x28:
+	case 0x29:
+	case 0x2a:
+	case 0x2b:
+		*state =3D FLEXRAY_STATE_STARTUP;
+		break;
+	default:
+		*state =3D FLEXRAY_STATE_UNSPEC;
+	}
+
+	return 0;
+}
+
+static int flexcard_set_state(struct net_device *dev,
+			      enum flexray_state state)
+{
+	struct flexcard_priv *priv =3D netdev_priv(dev);
+	struct eray_cc *cc =3D priv->cc;
+	int ret;
+
+	switch (state) {
+	case FLEXRAY_STATE_READY:
+		ret =3D fc_prepare_msgbuf_data(dev);
+		if (ret)
+			return ret;
+	case FLEXRAY_STATE_WAKEUP:
+	case FLEXRAY_STATE_STARTUP:
+	case FLEXRAY_STATE_NORMAL_ACTIVE:
+	case FLEXRAY_STATE_NORMAL_PASSIVE:
+	case FLEXRAY_STATE_MONITOR_MODE:
+	case FLEXRAY_STATE_COLDSTART:
+		netif_start_queue(dev);
+		break;
+	default:
+		cc->ready =3D 0;
+	}
+
+	return cc_change_state(cc, e_state(state), 10);
+}
+
+static int flexcard_validate(struct sk_buff *skb)
+{
+	struct fc_msg *fcm =3D (struct fc_msg *)skb->data;
+	struct eray_msgbuf_cfg *cfg;
+	struct flexcard_priv *priv =3D netdev_priv(skb->dev);
+	struct eray_cc *cc =3D priv->cc;
+	unsigned long flags;
+	u32 txrq;
+	int ret =3D 0;
+	u32 buf_id;
+	int ssync;
+
+	ssync =3D (fcm->buf_id & FC_FLEX_ID_SSYNC_FLAG) ? 1 : 0;
+	buf_id =3D fcm->buf_id & ~(FC_FLEX_ID_SSYNC_FLAG);
+
+	if (ssync) {
+		if (buf_id >=3D cc->ssync_num)
+			return -EFAULT;
+		cfg =3D &cc->ssync_cfg[buf_id];
+	} else {
+		if (buf_id >=3D cc->act_cfg)
+			return -EFAULT;
+		cfg =3D &cc->cfg[buf_id];
+	}
+
+	if (!(cfg->flags & ERAY_MSGBUF_USED))
+		return -EFAULT;
+
+	if (cfg->type !=3D eray_msgbuf_type_tx)
+		return -EINVAL;
+
+	if (cfg->channel =3D=3D eray_msgbuf_ch_none)
+		return -EINVAL;
+
+	if (skb->len > (2 * cfg->max + 4))
+		return -EINVAL;
+
+	/* queue frame, if message buffer is in continuos mode */
+	if (cfg->flags & ERAY_MSGBUF_TXCONT)
+		return 0;
+
+	if ((cfg->frame_id <=3D cc->static_id) &&
+	    ((skb->len - 4) / 2 !=3D cc->static_len))
+		return -EINVAL;
+
+	if (!cc->ready)
+		return -EBUSY;
+
+	spin_lock_irqsave(&cfg->lock, flags);
+	if (!ssync) {
+		txrq =3D eray_readl(cc, ERAY_TXRQ1 + cfg->id/32);
+
+		if (txrq & (1 << (cfg->id%32)))
+			ret =3D -ENOBUFS;
+	}
+
+	if (cfg->queued)
+		ret =3D -ENOBUFS;
+
+	if (!ret)
+		cfg->queued =3D 1;
+
+	spin_unlock_irqrestore(&cfg->lock, flags);
+
+	return ret;
+}
+
+static int flexcard_start_xmit(struct sk_buff *skb, struct net_device =
*dev)
+{
+	struct net_device_stats *stats =3D &dev->stats;
+	struct flexcard_priv *priv =3D netdev_priv(dev);
+	struct fc_msg *fcm =3D (struct fc_msg *)skb->data;
+
+	if (fc_write_data(priv, fcm->buf_id, fcm->data,
+			  skb->len - sizeof(fcm->buf_id))) {
+		net_info_ratelimited("%s() fc_write_data() failed.\n",
+				dev->name);
+		return NETDEV_TX_BUSY;
+	}
+
+	stats->tx_bytes +=3D skb->len - sizeof(fcm->buf_id);
+
+	kfree_skb(skb);
+
+	return NETDEV_TX_OK;
+}
+
+static const struct net_device_ops flexcard_netdev_ops =3D {
+	.ndo_open       =3D flexcard_open,
+	.ndo_stop       =3D flexcard_close,
+	.ndo_start_xmit =3D flexcard_start_xmit,
+};
+
+static ssize_t fw_ver_show(struct device *dev, struct device_attribute=
 *attr,
+			   char *buf)
+{
+	struct platform_device *pdev =3D to_platform_device(dev);
+	struct net_device *ndev =3D platform_get_drvdata(pdev);
+	struct flexcard_priv *priv =3D netdev_priv(ndev);
+	struct eray_cc *cc =3D priv->cc;
+	u32 fw_ver;
+
+	fw_ver =3D eray_readl(cc, ERAY_CREL);
+
+	return sprintf(buf, "%x.%02x %02x.%02x.200%x\n",
+		       fw_ver >> 28 & 0xf, fw_ver >> 20 & 0xff,
+		       fw_ver & 0xff, fw_ver >> 8 & 0xff, fw_ver >> 16 & 0xf);
+}
+
+static ssize_t succ1_show(struct device *dev, struct device_attribute =
*attr,
+			  char *buf)
+{
+	struct platform_device *pdev =3D to_platform_device(dev);
+	struct net_device *ndev =3D platform_get_drvdata(pdev);
+	struct flexcard_priv *priv =3D netdev_priv(ndev);
+	struct eray_cc *cc =3D priv->cc;
+	u32 reg;
+
+	reg =3D eray_read_succ1(cc, 20);
+
+	return sprintf(buf, "0x%08x\n", reg);
+}
+
+#define FC_SHOW_REG(x, y)						\
+	static ssize_t x##_show(struct device *dev,			\
+				struct device_attribute *attr,		\
+				char *buf)				\
+	{								\
+		struct platform_device *pdev =3D to_platform_device(dev);	\
+		struct net_device *ndev =3D platform_get_drvdata(pdev);	\
+		struct flexcard_priv *priv =3D netdev_priv(ndev);		\
+		struct eray_cc *cc =3D priv->cc;				\
+		u32 reg;						\
+		reg =3D eray_readl(cc, y);				\
+									\
+		return sprintf(buf, "0x%08x\n", reg);			\
+	}
+
+#define FC_SHOW_REGS(x, y) \
+	static ssize_t x##_show(struct device *dev,			\
+				struct device_attribute *attr,		\
+				char *buf)				\
+	{								\
+		struct platform_device *pdev =3D to_platform_device(dev);	\
+		struct net_device *ndev =3D platform_get_drvdata(pdev);	\
+		struct flexcard_priv *priv =3D netdev_priv(ndev);		\
+		struct eray_cc *cc =3D priv->cc;				\
+		u32 reg[4];						\
+									\
+		reg[0] =3D eray_readl(cc, y);				\
+		reg[1] =3D eray_readl(cc, y + 4);				\
+		reg[2] =3D eray_readl(cc, y + 8);				\
+		reg[3] =3D eray_readl(cc, y + 12);			\
+									\
+		return sprintf(buf, "0x%08x%08x%08x%08x\n",		\
+			       reg[0], reg[1], reg[2], reg[3]);		\
+	}
+
+FC_SHOW_REG(ccsv, ERAY_CCSV);
+FC_SHOW_REG(eir, ERAY_EIR);
+FC_SHOW_REG(sir, ERAY_SIR);
+FC_SHOW_REGS(txrq, ERAY_TXRQ1);
+FC_SHOW_REGS(ndat, ERAY_NDAT1);
+FC_SHOW_REGS(mbsc, ERAY_MBSC1);
+
+static struct device_attribute flex_dev_attrs[] =3D {
+	__ATTR_RO(fw_ver),
+	__ATTR_RO(succ1),
+	__ATTR_RO(ccsv),
+	__ATTR_RO(eir),
+	__ATTR_RO(sir),
+	__ATTR_RO(txrq),
+	__ATTR_RO(ndat),
+	__ATTR_RO(mbsc),
+	__ATTR_NULL,
+};
+
+static int device_add_attributes(struct device *dev,
+				 struct device_attribute *attrs)
+{
+	int error =3D 0;
+	int i;
+
+	for (i =3D 0; attr_name(attrs[i]); i++) {
+		error =3D device_create_file(dev, &attrs[i]);
+		if (error)
+			break;
+	}
+	if (error)
+		while (--i >=3D 0)
+			device_remove_file(dev, &attrs[i]);
+	return error;
+}
+
+static void device_remove_attributes(struct device *dev,
+				     struct device_attribute *attrs)
+{
+	int i;
+
+	for (i =3D 0; attr_name(attrs[i]); i++)
+		device_remove_file(dev, &attrs[i]);
+}
+
+static int flexcard_probe(struct platform_device *pdev)
+{
+	struct eray_msgbuf_cfg *cfg;
+	struct flexcard_priv *priv;
+	struct eray_cc *cc;
+	struct net_device *dev;
+	struct resource *res, *res_conf;
+	int i, irq, ret =3D -ENXIO;
+	u32 fw_ver;
+
+	irq =3D platform_get_irq(pdev, 0);
+	if (irq < 0) {
+		dev_err(&pdev->dev, "failed to get IRQ number\n");
+		goto out;
+	}
+
+	res_conf =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res_conf) {
+		dev_err(&pdev->dev, "failed to get conf I/O memory\n");
+		goto out;
+	}
+	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	if (!res) {
+		dev_err(&pdev->dev, "failed to get mmio I/O memory\n");
+		goto out;
+	}
+
+	cc =3D kzalloc(sizeof(*cc), GFP_KERNEL);
+	if (!cc) {
+		dev_err(&pdev->dev, "failed to alloc memory\n");
+		goto out_release;
+	}
+
+	spin_lock_init(&cc->lock);
+	for (i =3D 0; i < ERAY_MAX_BUFS; i++)
+		spin_lock_init(&cc->cfg[i].lock);
+
+	cc->fifo_threshold =3D ERAY_FIFO_THRESHOLD;
+
+	dev =3D alloc_flexraydev(sizeof(struct flexcard_priv), 2);
+	if (!dev) {
+		dev_err(&pdev->dev, "failed to alloc netdevice\n");
+		goto out_free;
+	}
+
+	dev->netdev_ops =3D &flexcard_netdev_ops;
+	dev->irq =3D irq;
+	dev->flags |=3D IFF_ECHO;
+
+	priv =3D netdev_priv(dev);
+	priv->cc =3D cc;
+	priv->dev =3D dev;
+	priv->id =3D pdev->id;
+	priv->flexray.do_get_state =3D flexcard_get_state;
+	priv->flexray.do_set_state =3D flexcard_set_state;
+	priv->flexray.do_validate =3D flexcard_validate;
+
+	cfg =3D &cc->cfg[0];
+	cfg->flags |=3D ERAY_MSGBUF_USED;
+	cfg->type =3D eray_msgbuf_type_fifo;
+	cfg->max =3D 127;
+
+	dev_set_drvdata(&pdev->dev, dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
+
+	priv->conf =3D ioremap_nocache(res_conf->start, resource_size(res_con=
f));
+	if (!priv->conf) {
+		dev_err(&pdev->dev, "failed to remap conf I/O memory\n");
+		goto out_free_dev;
+	}
+
+	cc->base =3D ioremap_nocache(res->start, resource_size(res));
+	if (!cc->base) {
+		dev_err(&pdev->dev, "failed to remap mmio I/O memory\n");
+		goto out_unmap_conf;
+	}
+
+	ret =3D register_flexraydev(dev);
+	if (ret < 0) {
+		dev_err(&pdev->dev, "failed to register netdevice\n");
+		goto out_unmap_mmio;
+	}
+
+	ret =3D device_add_attributes(&pdev->dev, flex_dev_attrs);
+	if (ret)
+		goto out_unregister;
+
+	ret =3D fc_register_rx_pkt(priv->id, dev, fc_rx_pkt);
+	if (ret) {
+		netdev_err(dev, "register RX DMA callback failed: %d\n", ret);
+		goto out_add_attr;
+	}
+
+	fw_ver =3D eray_readl(cc, ERAY_CREL);
+	dev_info(&pdev->dev, "E-Ray FW ver.%x.%02x %02x.%02x.200%x\n",
+		 fw_ver >> 28 & 0xf, fw_ver >> 20 & 0xff,
+		 fw_ver & 0xff, fw_ver >> 8 & 0xff, fw_ver >> 16 & 0xf);
+
+	return 0;
+out_add_attr:
+	device_remove_attributes(&pdev->dev, flex_dev_attrs);
+out_unregister:
+	unregister_flexraydev(dev);
+out_unmap_mmio:
+	iounmap(cc->base);
+out_unmap_conf:
+	iounmap(priv->conf);
+out_free_dev:
+	free_flexraydev(dev);
+out_free:
+	kfree(cc);
+out_release:
+	release_mem_region(res->start, resource_size(res));
+out:
+	return ret;
+}
+
+static int flexcard_remove(struct platform_device *pdev)
+{
+	struct net_device *dev =3D platform_get_drvdata(pdev);
+	struct flexcard_priv *priv =3D netdev_priv(dev);
+	struct eray_cc *cc =3D priv->cc;
+
+	fc_unregister_rx_pkt(priv->id);
+	device_remove_attributes(&pdev->dev, flex_dev_attrs);
+
+	unregister_flexraydev(dev);
+	free_flexraydev(dev);
+	iounmap(cc->base);
+	iounmap(priv->conf);
+	kfree(cc);
+
+	platform_set_drvdata(pdev, NULL);
+
+	return 0;
+}
+
+static struct platform_driver flexcard_driver =3D {
+	.probe =3D flexcard_probe,
+	.remove =3D flexcard_remove,
+	.driver =3D {
+		.name =3D "flexcard-eray",
+		.owner =3D THIS_MODULE,
+	},
+};
+MODULE_ALIAS("platform:flexcard-eray");
+
+static int __init flexcard_init(void)
+{
+	int ret;
+
+	ret =3D genl_register_family_with_ops(&fc_msgbuf_genl_family,
+					    fc_msgbuf_genl_ops,
+					    ARRAY_SIZE(fc_msgbuf_genl_ops));
+	if (ret) {
+		pr_err("flexcard: register genl failed %d\n", ret);
+		goto out;
+	}
+
+	ret =3D platform_driver_register(&flexcard_driver);
+out:
+	return ret;
+}
+module_init(flexcard_init);
+
+static void __exit flexcard_exit(void)
+{
+	genl_unregister_family(&fc_msgbuf_genl_family);
+	platform_driver_unregister(&flexcard_driver);
+}
+module_exit(flexcard_exit);
+
+MODULE_AUTHOR("Benedikt Spranger <b.spranger@linutronix.de>");
+MODULE_LICENSE("GPL v2");
+MODULE_DESCRIPTION("Ebersp=C3=A4cher Flexcard FlexRay driver");
diff --git a/drivers/net/flexray/vflexray.c b/drivers/net/flexray/vflex=
ray.c
new file mode 100644
index 0000000..6b73624
--- /dev/null
+++ b/drivers/net/flexray/vflexray.c
@@ -0,0 +1,99 @@
+/* Copyright 2012 Ebersp=C3=A4cher Electronics GmbH & Co. KG. All Righ=
ts Reserved */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/if_ether.h>
+#include <linux/flexray.h>
+#include <linux/flexray/dev.h>
+#include <linux/slab.h>
+#include <net/rtnetlink.h>
+
+static void vflexray_rx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct flexray_frame *frf =3D (struct flexray_frame *)skb->data;
+	struct net_device_stats *stats =3D &dev->stats;
+
+	stats->rx_packets++;
+	stats->rx_bytes +=3D flexray_get_pl(frf->head);
+
+	skb->protocol  =3D htons(ETH_P_FLEXRAY);
+	skb->pkt_type  =3D PACKET_BROADCAST;
+	skb->dev       =3D dev;
+	skb->ip_summed =3D CHECKSUM_UNNECESSARY;
+
+	netif_rx_ni(skb);
+}
+
+static netdev_tx_t vflexray_tx(struct sk_buff *skb, struct net_device =
*dev)
+{
+	struct flexray_frame *frf =3D (struct flexray_frame *)skb->data;
+	struct net_device_stats *stats =3D &dev->stats;
+	int loop;
+
+	if (flexray_dropped_invalid_skb(dev, skb))
+		return NETDEV_TX_OK;
+
+	stats->tx_packets++;
+	stats->tx_bytes +=3D flexray_get_pl(frf->head);
+
+	/* set flag whether this packet has to be looped back */
+	loop =3D skb->pkt_type =3D=3D PACKET_LOOPBACK;
+	if (loop) {
+		struct sock *srcsk =3D skb->sk;
+
+		skb =3D skb_share_check(skb, GFP_ATOMIC);
+		if (!skb)
+			return NETDEV_TX_OK;
+
+		/* receive with packet counting */
+		skb->sk =3D srcsk;
+		vflexray_rx(skb, dev);
+	} else {
+		kfree_skb(skb);
+	}
+
+	return NETDEV_TX_OK;
+}
+
+static const struct net_device_ops vflexray_netdev_ops =3D {
+	.ndo_start_xmit =3D vflexray_tx,
+};
+
+static void vflexray_setup(struct net_device *dev)
+{
+	dev->type		=3D ARPHRD_FLEXRAY;
+	dev->mtu		=3D sizeof(struct flexray_frame);
+	dev->hard_header_len	=3D 0;
+	dev->addr_len		=3D 0;
+	dev->tx_queue_len	=3D 0;
+	dev->flags		=3D IFF_NOARP;
+
+	dev->netdev_ops		=3D &vflexray_netdev_ops;
+	dev->destructor		=3D free_netdev;
+}
+
+static struct rtnl_link_ops vflexray_link_ops __read_mostly =3D {
+	.kind   =3D "vflexray",
+	.setup  =3D vflexray_setup,
+};
+
+static __init int vflexray_init_module(void)
+{
+	pr_info("vflexray: Virtual FlexRay interface driver\n");
+
+	return rtnl_link_register(&vflexray_link_ops);
+}
+
+static __exit void vflexray_cleanup_module(void)
+{
+	rtnl_link_unregister(&vflexray_link_ops);
+}
+
+module_init(vflexray_init_module);
+module_exit(vflexray_cleanup_module);
+
+MODULE_DESCRIPTION("virtual FlexRay interface");
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Benedikt Spranger <b.spranger@linutronix.de>");
diff --git a/net/flexray/Kconfig b/net/flexray/Kconfig
index 18d9d69..1f497e5 100644
--- a/net/flexray/Kconfig
+++ b/net/flexray/Kconfig
@@ -26,3 +26,5 @@ config FLEXRAY_RAW
 	  most cases where no higher level protocol is being used.
 	  To receive/send raw FLEXRAY messages, use AF_FLEXRAY with protocol
 	  FLEXRAY_RAW.
+
+source "drivers/net/flexray/Kconfig"
--=20
1.8.4.rc2
