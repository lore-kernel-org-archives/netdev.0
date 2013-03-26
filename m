From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: =?UTF-8?q?=5Bnet-next=2Egit=206/8=20=28v2=29=5D=20stmmac=3A=20add=20IEEE=20PTPv1=20and=20PTPv2=20support=2E?=
Date: Tue, 26 Mar 2013 15:43:10 +0100
Message-ID: <1364308992-27929-7-git-send-email-peppe.cavallaro@st.com>
References: <1364308992-27929-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rayagond@vayavyalabs.com, richardcochran@gmail.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:42415 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756862Ab3CZOpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 10:45:05 -0400
In-Reply-To: <1364308992-27929-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rayagond Kokatanur <rayagond@vayavyalabs.com>

This patch enhances the stmmac driver to support IEEE 1588-2002
PTP (Precision Time Protocol) version 1 and IEEE 1588-2008 PPT
version 2.

Precision Time Protocol(PTP),which enables precise synchronization
of clocks in measurement and control systems implemented with
technologies such as network communication,local computing,
& distributed objects.

Both PTPv1 and PTPv2 is selected at run-time using the HW capability
register.

The PTPv1 TimeStamp support can be used on chips that have the normal
descriptor structures and PTPv2 TimeStamp support can be used on chips
that have the Extended descriptors(DES4-5-6-7). All such sanity checks
are done and verified by using HW capability register.

V2: in this version the ethtool support has been included in this patch=
;
Koptions have been completely removed (previously added to select
PTP and PTPv2). PTPv1 and PTPv2 is now added in a single patch instead =
of
two patches.
get_timestamp() and get_systemtime() L/H have been combined into single=
 APIs.

Signed-off-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    2 +-
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |   32 ++
 drivers/net/ethernet/stmicro/stmmac/common.h       |   22 +-
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |   47 +++
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |   37 ++
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |   13 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    5 +
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   32 ++-
 .../net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c  |  108 ++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  384 ++++++++++++=
+++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h   |   74 ++++
 11 files changed, 732 insertions(+), 24 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp=
=2Ec
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h

diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net=
/ethernet/stmicro/stmmac/Makefile
index ae995a3..1aca0e6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -4,4 +4,4 @@ stmmac-$(CONFIG_STMMAC_PCI) +=3D stmmac_pci.o
 stmmac-objs:=3D stmmac_main.o stmmac_ethtool.o stmmac_mdio.o ring_mode=
=2Eo	\
 	      chain_mode.o dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o \
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
-	      mmc_core.o $(stmmac-y)
+	      mmc_core.o stmmac_hwtstamp.o $(stmmac-y)
diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers=
/net/ethernet/stmicro/stmmac/chain_mode.c
index 63b6031..37a3f93 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -122,8 +122,40 @@ static void stmmac_init_dma_chain(void *des, dma_a=
ddr_t phy_addr,
 	}
 }
=20
+static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
+{
+	struct stmmac_priv *priv =3D (struct stmmac_priv *)priv_ptr;
+
+	if (priv->hwts_rx_en && !priv->extend_desc)
+		/* NOTE: Device will overwrite des3 with timestamp value if
+		 * 1588-2002 time stamping is enabled, hence reinitialize it
+		 * to keep explicit chaining in the descriptor.
+		 */
+		p->des3 =3D (unsigned int)(priv->dma_rx_phy +
+					 (((priv->dirty_rx) + 1) %
+					 priv->dma_rx_size) *
+					 sizeof(struct dma_desc));
+}
+
+static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
+{
+	struct stmmac_priv *priv =3D (struct stmmac_priv *)priv_ptr;
+
+	if (priv->hw->desc->get_tx_ls(p) && !priv->extend_desc)
+		/* NOTE: Device will overwrite des3 with timestamp value if
+		 * 1588-2002 time stamping is enabled, hence reinitialize it
+		 * to keep explicit chaining in the descriptor.
+		 */
+		p->des3 =3D (unsigned int)(priv->dma_tx_phy +
+					 (((priv->dirty_tx + 1) %
+					 priv->dma_tx_size) *
+					 sizeof(struct dma_desc)));
+}
+
 const struct stmmac_chain_mode_ops chain_mode_ops =3D {
 	.init =3D stmmac_init_dma_chain,
 	.is_jumbo_frm =3D stmmac_is_jumbo_frm,
 	.jumbo_frm =3D stmmac_jumbo_frm,
+	.refill_desc3 =3D stmmac_refill_desc3,
+	.clean_desc3 =3D stmmac_clean_desc3,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net=
/ethernet/stmicro/stmmac/common.h
index 942fdce..6fa975c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -339,6 +339,14 @@ struct stmmac_desc_ops {
 			  struct dma_desc *p);
 	void (*rx_extended_status) (void *data, struct stmmac_extra_stats *x,
 				    struct dma_extended_desc *p);
+	/* Set tx timestamp enable bit */
+	void (*enable_tx_timestamp) (struct dma_desc *p);
+	/* get tx timestamp status */
+	int (*get_tx_timestamp_status) (struct dma_desc *p);
+	/* get timestamp value */
+	u64 (*get_timestamp) (void *desc, u32 ats);
+	/* get rx timestamp status */
+	int (*get_rx_timestamp_status) (void *desc, u32 ats);
 };
=20
 struct stmmac_dma_ops {
@@ -398,6 +406,13 @@ struct stmmac_ops {
 	void (*get_adv) (void __iomem *ioaddr, struct rgmii_adv *adv);
 };
=20
+struct stmmac_hwtimestamp {
+	void (*config_hw_tstamping) (void __iomem *ioaddr, u32 data);
+	void (*config_sub_second_increment) (void __iomem *ioaddr);
+	int (*init_systime) (void __iomem *ioaddr, u32 sec, u32 nsec);
+	int (*config_addend)(void __iomem *ioaddr, u32 addend);
+};
+
 struct mac_link {
 	int port;
 	int duplex;
@@ -412,9 +427,9 @@ struct mii_regs {
 struct stmmac_ring_mode_ops {
 	unsigned int (*is_jumbo_frm) (int len, int ehn_desc);
 	unsigned int (*jumbo_frm) (void *priv, struct sk_buff *skb, int csum)=
;
-	void (*refill_desc3) (int bfsize, struct dma_desc *p);
+	void (*refill_desc3) (void *priv, struct dma_desc *p);
 	void (*init_desc3) (struct dma_desc *p);
-	void (*clean_desc3) (struct dma_desc *p);
+	void (*clean_desc3) (void *priv, struct dma_desc *p);
 	int (*set_16kib_bfsize) (int mtu);
 };
=20
@@ -423,6 +438,8 @@ struct stmmac_chain_mode_ops {
 		      unsigned int extend_desc);
 	unsigned int (*is_jumbo_frm) (int len, int ehn_desc);
 	unsigned int (*jumbo_frm) (void *priv, struct sk_buff *skb, int csum)=
;
+	void (*refill_desc3) (void *priv, struct dma_desc *p);
+	void (*clean_desc3) (void *priv, struct dma_desc *p);
 };
=20
 struct mac_device_info {
@@ -431,6 +448,7 @@ struct mac_device_info {
 	const struct stmmac_dma_ops	*dma;
 	const struct stmmac_ring_mode_ops	*ring;
 	const struct stmmac_chain_mode_ops	*chain;
+	const struct stmmac_hwtimestamp *ptp;
 	struct mii_regs mii;	/* MII register Addresses */
 	struct mac_link link;
 	unsigned int synopsys_uid;
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/n=
et/ethernet/stmicro/stmmac/enh_desc.c
index c1b9ab2..0fbc8fa 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -378,6 +378,49 @@ static int enh_desc_get_rx_frame_len(struct dma_de=
sc *p, int rx_coe_type)
 		return p->des01.erx.frame_length;
 }
=20
+static void enh_desc_enable_tx_timestamp(struct dma_desc *p)
+{
+	p->des01.etx.time_stamp_enable =3D 1;
+}
+
+static int enh_desc_get_tx_timestamp_status(struct dma_desc *p)
+{
+	return p->des01.etx.time_stamp_status;
+}
+
+static u64 enh_desc_get_timestamp(void *desc, u32 ats)
+{
+	u64 ns;
+
+	if (ats) {
+		struct dma_extended_desc *p =3D (struct dma_extended_desc *)desc;
+		ns =3D p->des6;
+		/* convert high/sec time stamp value to nanosecond */
+		ns +=3D p->des7 * 1000000000ULL;
+	} else {
+		struct dma_desc *p =3D (struct dma_desc *)desc;
+		ns =3D p->des2;
+		ns +=3D p->des3 * 1000000000ULL;
+	}
+
+	return ns;
+}
+
+static int enh_desc_get_rx_timestamp_status(void *desc, u32 ats)
+{
+	if (ats) {
+		struct dma_extended_desc *p =3D (struct dma_extended_desc *)desc;
+		return p->basic.des01.erx.ipc_csum_error;
+	} else {
+		struct dma_desc *p =3D (struct dma_desc *)desc;
+		if ((p->des2 =3D=3D 0xffffffff) && (p->des3 =3D=3D 0xffffffff))
+			/* timestamp is corrupted, hence don't store it */
+			return 0;
+		else
+			return 1;
+	}
+}
+
 const struct stmmac_desc_ops enh_desc_ops =3D {
 	.tx_status =3D enh_desc_get_tx_status,
 	.rx_status =3D enh_desc_get_rx_status,
@@ -395,4 +438,8 @@ const struct stmmac_desc_ops enh_desc_ops =3D {
 	.set_rx_owner =3D enh_desc_set_rx_owner,
 	.get_rx_frame_len =3D enh_desc_get_rx_frame_len,
 	.rx_extended_status =3D enh_desc_get_ext_status,
+	.enable_tx_timestamp =3D enh_desc_enable_tx_timestamp,
+	.get_tx_timestamp_status =3D enh_desc_get_tx_timestamp_status,
+	.get_timestamp =3D enh_desc_get_timestamp,
+	.get_rx_timestamp_status =3D enh_desc_get_rx_timestamp_status,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/=
net/ethernet/stmicro/stmmac/norm_desc.c
index 47d5094..7cbcea3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -219,6 +219,39 @@ static int ndesc_get_rx_frame_len(struct dma_desc =
*p, int rx_coe_type)
 		return p->des01.rx.frame_length;
 }
=20
+static void ndesc_enable_tx_timestamp(struct dma_desc *p)
+{
+	p->des01.tx.time_stamp_enable =3D 1;
+}
+
+static int ndesc_get_tx_timestamp_status(struct dma_desc *p)
+{
+	return p->des01.tx.time_stamp_status;
+}
+
+static u64 ndesc_get_timestamp(void *desc, u32 ats)
+{
+	struct dma_desc *p =3D (struct dma_desc *)desc;
+	u64 ns;
+
+	ns =3D p->des2;
+	/* convert high/sec time stamp value to nanosecond */
+	ns +=3D p->des3 * 1000000000ULL;
+
+	return ns;
+}
+
+static int ndesc_get_rx_timestamp_status(void *desc, u32 ats)
+{
+	struct dma_desc *p =3D (struct dma_desc *)desc;
+
+	if ((p->des2 =3D=3D 0xffffffff) && (p->des3 =3D=3D 0xffffffff))
+		/* timestamp is corrupted, hence don't store it */
+		return 0;
+	else
+		return 1;
+}
+
 const struct stmmac_desc_ops ndesc_ops =3D {
 	.tx_status =3D ndesc_get_tx_status,
 	.rx_status =3D ndesc_get_rx_status,
@@ -235,4 +268,8 @@ const struct stmmac_desc_ops ndesc_ops =3D {
 	.set_tx_owner =3D ndesc_set_tx_owner,
 	.set_rx_owner =3D ndesc_set_rx_owner,
 	.get_rx_frame_len =3D ndesc_get_rx_frame_len,
+	.enable_tx_timestamp =3D ndesc_enable_tx_timestamp,
+	.get_tx_timestamp_status =3D ndesc_get_tx_timestamp_status,
+	.get_timestamp =3D ndesc_get_timestamp,
+	.get_rx_timestamp_status =3D ndesc_get_rx_timestamp_status,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/=
net/ethernet/stmicro/stmmac/ring_mode.c
index 43fc699..d0265a7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -87,11 +87,14 @@ static unsigned int stmmac_is_jumbo_frm(int len, in=
t enh_desc)
 	return ret;
 }
=20
-static void stmmac_refill_desc3(int bfsize, struct dma_desc *p)
+static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
 {
-	/* Fill DES3 in case of RING mode */
-	if (bfsize >=3D BUF_SIZE_8KiB)
-		p->des3 =3D p->des2 + BUF_SIZE_8KiB;
+	struct stmmac_priv *priv =3D (struct stmmac_priv *)priv_ptr;
+
+	if (unlikely(priv->plat->has_gmac))
+		/* Fill DES3 in case of RING mode */
+		if (priv->dma_buf_sz >=3D BUF_SIZE_8KiB)
+			p->des3 =3D p->des2 + BUF_SIZE_8KiB;
 }
=20
 /* In ring mode we need to fill the desc3 because it is used as buffer=
 */
@@ -100,7 +103,7 @@ static void stmmac_init_desc3(struct dma_desc *p)
 	p->des3 =3D p->des2 + BUF_SIZE_8KiB;
 }
=20
-static void stmmac_clean_desc3(struct dma_desc *p)
+static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p)
 {
 	if (unlikely(p->des3))
 		p->des3 =3D 0;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net=
/ethernet/stmicro/stmmac/stmmac.h
index 5176cae..a21d1b9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -99,6 +99,10 @@ struct stmmac_priv {
 	unsigned int mode;
 	int extend_desc;
 	int pcs;
+	int hwts_tx_en;
+	int hwts_rx_en;
+	unsigned int default_addend;
+	u32 adv_ts;
 };
=20
 extern int phyaddr;
@@ -108,6 +112,7 @@ extern int stmmac_mdio_register(struct net_device *=
ndev);
 extern void stmmac_set_ethtool_ops(struct net_device *netdev);
 extern const struct stmmac_desc_ops enh_desc_ops;
 extern const struct stmmac_desc_ops ndesc_ops;
+extern const struct stmmac_hwtimestamp stmmac_ptp;
 int stmmac_freeze(struct net_device *ndev);
 int stmmac_restore(struct net_device *ndev);
 int stmmac_resume(struct net_device *ndev);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/dri=
vers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 54e15db..5b340c2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -27,6 +27,7 @@
 #include <linux/interrupt.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/net_tstamp.h>
 #include <asm/io.h>
=20
 #include "stmmac.h"
@@ -725,6 +726,35 @@ static int stmmac_set_coalesce(struct net_device *=
dev,
 	return 0;
 }
=20
+static int stmmac_get_ts_info(struct net_device *dev,
+			      struct ethtool_ts_info *info)
+{
+	struct stmmac_priv *priv =3D netdev_priv(dev);
+
+	if ((priv->hwts_tx_en) && (priv->hwts_rx_en)) {
+
+		info->so_timestamping =3D SOF_TIMESTAMPING_TX_HARDWARE |
+					SOF_TIMESTAMPING_RX_HARDWARE |
+					SOF_TIMESTAMPING_RAW_HARDWARE;
+
+		info->tx_types =3D (1 << HWTSTAMP_TX_OFF) | (1 << HWTSTAMP_TX_ON);
+
+		info->rx_filters =3D ((1 << HWTSTAMP_FILTER_NONE) |
+				    (1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
+				    (1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
+				    (1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
+				    (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT) |
+				    (1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC) |
+				    (1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ) |
+				    (1 << HWTSTAMP_FILTER_PTP_V2_EVENT) |
+				    (1 << HWTSTAMP_FILTER_PTP_V2_SYNC) |
+				    (1 << HWTSTAMP_FILTER_PTP_V2_DELAY_REQ) |
+				    (1 << HWTSTAMP_FILTER_ALL));
+		return 0;
+	} else
+		return ethtool_op_get_ts_info(dev, info);
+}
+
 static const struct ethtool_ops stmmac_ethtool_ops =3D {
 	.begin =3D stmmac_check_if_running,
 	.get_drvinfo =3D stmmac_ethtool_getdrvinfo,
@@ -744,7 +774,7 @@ static const struct ethtool_ops stmmac_ethtool_ops =
=3D {
 	.get_eee =3D stmmac_ethtool_op_get_eee,
 	.set_eee =3D stmmac_ethtool_op_set_eee,
 	.get_sset_count	=3D stmmac_get_sset_count,
-	.get_ts_info =3D ethtool_op_get_ts_info,
+	.get_ts_info =3D stmmac_get_ts_info,
 	.get_coalesce =3D stmmac_get_coalesce,
 	.set_coalesce =3D stmmac_set_coalesce,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c b/dr=
ivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
new file mode 100644
index 0000000..380baeb
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c
@@ -0,0 +1,108 @@
+/*********************************************************************=
**********
+  Copyright (C) 2013  Vayavya Labs Pvt Ltd
+
+  This implements all the API for managing HW timestamp & PTP.
+
+  This program is free software; you can redistribute it and/or modify=
 it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHO=
UT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY o=
r
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licens=
e for
+  more details.
+
+  You should have received a copy of the GNU General Public License al=
ong with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution=
 in
+  the file called "COPYING".
+
+  Author: Rayagond Kokatanur <rayagond@vayavyalabs.com>
+  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
+**********************************************************************=
*********/
+
+#include <linux/io.h>
+#include <linux/delay.h>
+#include "common.h"
+#include "stmmac_ptp.h"
+
+static void stmmac_config_hw_tstamping(void __iomem *ioaddr, u32 data)
+{
+	writel(data, ioaddr + PTP_TCR);
+}
+
+static void stmmac_config_sub_second_increment(void __iomem *ioaddr)
+{
+	u32 value =3D readl(ioaddr + PTP_TCR);
+	unsigned long data;
+
+	/* Convert the ptp_clock to nano second
+	 * formula =3D (1/ptp_clock) * 1000000000
+	 * where, ptp_clock =3D 50MHz.
+	 */
+	data =3D (1000000000ULL / 50000000);
+
+	/* 0.465ns accuracy */
+	if (value & PTP_TCR_TSCTRLSSR)
+		data =3D (data * 100) / 465;
+
+	writel(data, ioaddr + PTP_SSIR);
+}
+
+static int stmmac_init_systime(void __iomem *ioaddr, u32 sec, u32 nsec=
)
+{
+	int limit;
+	u32 value;
+
+	writel(sec, ioaddr + PTP_STSUR);
+	writel(nsec, ioaddr + PTP_STNSUR);
+	/* issue command to initialize the system time value */
+	value =3D readl(ioaddr + PTP_TCR);
+	value |=3D PTP_TCR_TSINIT;
+	writel(value, ioaddr + PTP_TCR);
+
+	/* wait for present system time initialize to complete */
+	limit =3D 10;
+	while (limit--) {
+		if (!(readl(ioaddr + PTP_TCR) & PTP_TCR_TSINIT))
+			break;
+		mdelay(10);
+	}
+	if (limit < 0)
+		return -EBUSY;
+
+	return 0;
+}
+
+static int stmmac_config_addend(void __iomem *ioaddr, u32 addend)
+{
+	u32 value;
+	int limit;
+
+	writel(addend, ioaddr + PTP_TAR);
+	/* issue command to update the addend value */
+	value =3D readl(ioaddr + PTP_TCR);
+	value |=3D PTP_TCR_TSADDREG;
+	writel(value, ioaddr + PTP_TCR);
+
+	/* wait for present addend update to complete */
+	limit =3D 10;
+	while (limit--) {
+		if (!(readl(ioaddr + PTP_TCR) & PTP_TCR_TSADDREG))
+			break;
+		mdelay(10);
+	}
+	if (limit < 0)
+		return -EBUSY;
+
+	return 0;
+}
+
+const struct stmmac_hwtimestamp stmmac_ptp =3D {
+	.config_hw_tstamping =3D stmmac_config_hw_tstamping,
+	.init_systime =3D stmmac_init_systime,
+	.config_sub_second_increment =3D stmmac_config_sub_second_increment,
+	.config_addend =3D stmmac_config_addend,
+};
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_main.c
index 180eed7..6906772 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -47,6 +47,8 @@
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
 #endif
+#include <linux/net_tstamp.h>
+#include "stmmac_ptp.h"
 #include "stmmac.h"
=20
 #undef STMMAC_DEBUG
@@ -311,6 +313,327 @@ static void stmmac_eee_adjust(struct stmmac_priv =
*priv)
 		priv->hw->mac->set_eee_pls(priv->ioaddr, priv->phydev->link);
 }
=20
+/* stmmac_get_tx_hwtstamp:
+ * @priv : pointer to private device structure.
+ * @entry : descriptor index to be used.
+ * @skb : the socket buffer
+ * Description :
+ * This function will read timestamp from the descriptor & pass it to =
stack.
+ * and also perform some sanity checks.
+ */
+static void stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
+				   unsigned int entry,
+				   struct sk_buff *skb)
+{
+	struct skb_shared_hwtstamps shhwtstamp;
+	u64 ns;
+	void *desc =3D NULL;
+
+	if (!priv->hwts_tx_en)
+		return;
+
+	/* if skb doesn't support hw tstamp */
+	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)))
+		return;
+
+	if (priv->adv_ts)
+		desc =3D (priv->dma_etx + entry);
+	else
+		desc =3D (priv->dma_tx + entry);
+
+	/* check tx tstamp status */
+	if (!priv->hw->desc->get_tx_timestamp_status((struct dma_desc *)desc)=
)
+		return;
+
+	/* get the valid tstamp */
+	ns =3D priv->hw->desc->get_timestamp(desc, priv->adv_ts);
+
+	memset(&shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
+	shhwtstamp.hwtstamp =3D ns_to_ktime(ns);
+	/* pass tstamp to stack */
+	skb_tstamp_tx(skb, &shhwtstamp);
+
+	return;
+}
+
+/* stmmac_get_rx_hwtstamp:
+ * @priv : pointer to private device structure.
+ * @entry : descriptor index to be used.
+ * @skb : the socket buffer
+ * Description :
+ * This function will read received packet's timestamp from the descri=
ptor
+ * and pass it to stack. It also perform some sanity checks.
+ */
+static void stmmac_get_rx_hwtstamp(struct stmmac_priv *priv,
+				   unsigned int entry,
+				   struct sk_buff *skb)
+{
+	struct skb_shared_hwtstamps *shhwtstamp =3D NULL;
+	u64 ns;
+	void *desc =3D NULL;
+
+	if (!priv->hwts_rx_en)
+		return;
+
+	if (priv->adv_ts)
+		desc =3D (priv->dma_erx + entry);
+	else
+		desc =3D (priv->dma_rx + entry);
+
+	/* if rx tstamp is not valid */
+	if (!priv->hw->desc->get_rx_timestamp_status(desc, priv->adv_ts))
+		return;
+
+	/* get valid tstamp */
+	ns =3D priv->hw->desc->get_timestamp(desc, priv->adv_ts);
+	shhwtstamp =3D skb_hwtstamps(skb);
+	memset(shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
+	shhwtstamp->hwtstamp =3D ns_to_ktime(ns);
+}
+
+/**
+ *  stmmac_hwtstamp_ioctl - control hardware timestamping.
+ *  @dev: device pointer.
+ *  @ifr: An IOCTL specefic structure, that can contain a pointer to
+ *  a proprietary structure used to pass information to the driver.
+ *  Description:
+ *  This function configures the MAC to enable/disable both outgoing(T=
X)
+ *  and incoming(RX) packets time stamping based on user input.
+ *  Return Value:
+ *  0 on success and an appropriate -ve integer on failure.
+ */
+static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq =
*ifr)
+{
+	struct stmmac_priv *priv =3D netdev_priv(dev);
+	struct hwtstamp_config config;
+	struct timespec now;
+	u64 temp =3D 0;
+	u32 ptp_v2 =3D 0;
+	u32 tstamp_all =3D 0;
+	u32 ptp_over_ipv4_udp =3D 0;
+	u32 ptp_over_ipv6_udp =3D 0;
+	u32 ptp_over_ethernet =3D 0;
+	u32 snap_type_sel =3D 0;
+	u32 ts_master_en =3D 0;
+	u32 ts_event_en =3D 0;
+	u32 value =3D 0;
+
+	if (!(priv->dma_cap.time_stamp || priv->adv_ts)) {
+		netdev_alert(priv->dev, "No support for HW time stamping\n");
+		priv->hwts_tx_en =3D 0;
+		priv->hwts_rx_en =3D 0;
+
+		return -EOPNOTSUPP;
+	}
+
+	if (copy_from_user(&config, ifr->ifr_data,
+		sizeof(struct hwtstamp_config)))
+		return -EFAULT;
+
+	pr_debug("%s config flags:0x%x, tx_type:0x%x, rx_filter:0x%x\n",
+		 __func__, config.flags, config.tx_type, config.rx_filter);
+
+	/* reserved for future extensions */
+	if (config.flags)
+		return -EINVAL;
+
+	switch (config.tx_type) {
+	case HWTSTAMP_TX_OFF:
+		priv->hwts_tx_en =3D 0;
+		break;
+	case HWTSTAMP_TX_ON:
+		priv->hwts_tx_en =3D 1;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	if (priv->adv_ts) {
+		switch (config.rx_filter) {
+		/* time stamp no incoming packet at all */
+		case HWTSTAMP_FILTER_NONE:
+			config.rx_filter =3D HWTSTAMP_FILTER_NONE;
+			break;
+
+		/* PTP v1, UDP, any kind of event packet */
+		case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+			config.rx_filter =3D HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
+			/* take time stamp for all event messages */
+			snap_type_sel =3D PTP_TCR_SNAPTYPSEL_1;
+
+			ptp_over_ipv4_udp =3D PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp =3D PTP_TCR_TSIPV6ENA;
+			break;
+
+		/* PTP v1, UDP, Sync packet */
+		case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+			config.rx_filter =3D HWTSTAMP_FILTER_PTP_V1_L4_SYNC;
+			/* take time stamp for SYNC messages only */
+			ts_event_en =3D PTP_TCR_TSEVNTENA;
+
+			ptp_over_ipv4_udp =3D PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp =3D PTP_TCR_TSIPV6ENA;
+			break;
+
+		/* PTP v1, UDP, Delay_req packet */
+		case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+			config.rx_filter =3D HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ;
+			/* take time stamp for Delay_Req messages only */
+			ts_master_en =3D PTP_TCR_TSMSTRENA;
+			ts_event_en =3D PTP_TCR_TSEVNTENA;
+
+			ptp_over_ipv4_udp =3D PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp =3D PTP_TCR_TSIPV6ENA;
+			break;
+
+		/* PTP v2, UDP, any kind of event packet */
+		case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+			config.rx_filter =3D HWTSTAMP_FILTER_PTP_V2_L4_EVENT;
+			ptp_v2 =3D PTP_TCR_TSVER2ENA;
+			/* take time stamp for all event messages */
+			snap_type_sel =3D PTP_TCR_SNAPTYPSEL_1;
+
+			ptp_over_ipv4_udp =3D PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp =3D PTP_TCR_TSIPV6ENA;
+			break;
+
+		/* PTP v2, UDP, Sync packet */
+		case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+			config.rx_filter =3D HWTSTAMP_FILTER_PTP_V2_L4_SYNC;
+			ptp_v2 =3D PTP_TCR_TSVER2ENA;
+			/* take time stamp for SYNC messages only */
+			ts_event_en =3D PTP_TCR_TSEVNTENA;
+
+			ptp_over_ipv4_udp =3D PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp =3D PTP_TCR_TSIPV6ENA;
+			break;
+
+		/* PTP v2, UDP, Delay_req packet */
+		case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+			config.rx_filter =3D HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ;
+			ptp_v2 =3D PTP_TCR_TSVER2ENA;
+			/* take time stamp for Delay_Req messages only */
+			ts_master_en =3D PTP_TCR_TSMSTRENA;
+			ts_event_en =3D PTP_TCR_TSEVNTENA;
+
+			ptp_over_ipv4_udp =3D PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp =3D PTP_TCR_TSIPV6ENA;
+			break;
+
+		/* PTP v2/802.AS1, any layer, any kind of event packet */
+		case HWTSTAMP_FILTER_PTP_V2_EVENT:
+			config.rx_filter =3D HWTSTAMP_FILTER_PTP_V2_EVENT;
+			ptp_v2 =3D PTP_TCR_TSVER2ENA;
+			/* take time stamp for all event messages */
+			snap_type_sel =3D PTP_TCR_SNAPTYPSEL_1;
+
+			ptp_over_ipv4_udp =3D PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp =3D PTP_TCR_TSIPV6ENA;
+			ptp_over_ethernet =3D PTP_TCR_TSIPENA;
+			break;
+
+		/* PTP v2/802.AS1, any layer, Sync packet */
+		case HWTSTAMP_FILTER_PTP_V2_SYNC:
+			config.rx_filter =3D HWTSTAMP_FILTER_PTP_V2_SYNC;
+			ptp_v2 =3D PTP_TCR_TSVER2ENA;
+			/* take time stamp for SYNC messages only */
+			ts_event_en =3D PTP_TCR_TSEVNTENA;
+
+			ptp_over_ipv4_udp =3D PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp =3D PTP_TCR_TSIPV6ENA;
+			ptp_over_ethernet =3D PTP_TCR_TSIPENA;
+			break;
+
+		/* PTP v2/802.AS1, any layer, Delay_req packet */
+		case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+			config.rx_filter =3D HWTSTAMP_FILTER_PTP_V2_DELAY_REQ;
+			ptp_v2 =3D PTP_TCR_TSVER2ENA;
+			/* take time stamp for Delay_Req messages only */
+			ts_master_en =3D PTP_TCR_TSMSTRENA;
+			ts_event_en =3D PTP_TCR_TSEVNTENA;
+
+			ptp_over_ipv4_udp =3D PTP_TCR_TSIPV4ENA;
+			ptp_over_ipv6_udp =3D PTP_TCR_TSIPV6ENA;
+			ptp_over_ethernet =3D PTP_TCR_TSIPENA;
+			break;
+
+		/* time stamp any incoming packet */
+		case HWTSTAMP_FILTER_ALL:
+			config.rx_filter =3D HWTSTAMP_FILTER_ALL;
+			tstamp_all =3D PTP_TCR_TSENALL;
+			break;
+
+		default:
+			return -ERANGE;
+		}
+	} else {
+		switch (config.rx_filter) {
+		case HWTSTAMP_FILTER_NONE:
+			config.rx_filter =3D HWTSTAMP_FILTER_NONE;
+			break;
+		default:
+			/* PTP v1, UDP, any kind of event packet */
+			config.rx_filter =3D HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
+			break;
+		}
+	}
+	priv->hwts_rx_en =3D ((config.rx_filter =3D=3D HWTSTAMP_FILTER_NONE) =
? 0 : 1);
+
+	if (!priv->hwts_tx_en && !priv->hwts_rx_en)
+		priv->hw->ptp->config_hw_tstamping(priv->ioaddr, 0);
+	else {
+		value =3D (PTP_TCR_TSENA | PTP_TCR_TSCFUPDT | PTP_TCR_TSCTRLSSR |
+			tstamp_all | ptp_v2 | ptp_over_ethernet |
+			ptp_over_ipv6_udp | ptp_over_ipv4_udp | ts_event_en |
+			ts_master_en | snap_type_sel);
+
+		priv->hw->ptp->config_hw_tstamping(priv->ioaddr, value);
+
+		/* program Sub Second Increment reg */
+		priv->hw->ptp->config_sub_second_increment(priv->ioaddr);
+
+		/* calculate default added value:
+		 * formula is :
+		 * addend =3D (2^32)/freq_div_ratio;
+		 * where, freq_div_ratio =3D STMMAC_SYSCLOCK/50MHz
+		 * hence, addend =3D ((2^32) * 50MHz)/STMMAC_SYSCLOCK;
+		 * NOTE: STMMAC_SYSCLOCK should be >=3D 50MHz to
+		 *       achive 20ns accuracy.
+		 *
+		 * 2^x * y =3D=3D (y << x), hence
+		 * 2^32 * 50000000 =3D=3D> (50000000 << 32)
+		 */
+		temp =3D (u64)(50000000ULL << 32);
+		priv->default_addend =3D div_u64(temp, STMMAC_SYSCLOCK);
+		priv->hw->ptp->config_addend(priv->ioaddr,
+					     priv->default_addend);
+
+		/* initialize system time */
+		getnstimeofday(&now);
+		priv->hw->ptp->init_systime(priv->ioaddr, now.tv_sec,
+					    now.tv_nsec);
+	}
+
+	return copy_to_user(ifr->ifr_data, &config,
+			    sizeof(struct hwtstamp_config)) ? -EFAULT : 0;
+}
+
+static void stmmac_init_ptp(struct stmmac_priv *priv)
+{
+	if (priv->dma_cap.time_stamp) {
+		pr_debug("IEEE 1588-2002 Time Stamp supported\n");
+		priv->adv_ts =3D 0;
+	}
+	if (priv->dma_cap.atime_stamp && priv->extend_desc) {
+		pr_debug("IEEE 1588-2008 Advanced Time Stamp supported\n");
+		priv->adv_ts =3D 1;
+	}
+
+	priv->hw->ptp =3D &stmmac_ptp;
+	priv->hwts_tx_en =3D 0;
+	priv->hwts_rx_en =3D 0;
+}
+
 /**
  * stmmac_adjust_link
  * @dev: net device structure
@@ -856,6 +1179,8 @@ static void stmmac_tx_clean(struct stmmac_priv *pr=
iv)
 				priv->xstats.tx_pkt_n++;
 			} else
 				priv->dev->stats.tx_errors++;
+
+			stmmac_get_tx_hwtstamp(priv, entry, skb);
 		}
 		TX_DBG("%s: curr %d, dirty %d\n", __func__,
 			priv->cur_tx, priv->dirty_tx);
@@ -867,8 +1192,7 @@ static void stmmac_tx_clean(struct stmmac_priv *pr=
iv)
 					 DMA_TO_DEVICE);
 			priv->tx_skbuff_dma[entry] =3D 0;
 		}
-		if (priv->mode =3D=3D STMMAC_RING_MODE)
-			priv->hw->ring->clean_desc3(p);
+		priv->hw->ring->clean_desc3(priv, p);
=20
 		if (likely(skb !=3D NULL)) {
 			dev_kfree_skb(skb);
@@ -1243,6 +1567,8 @@ static int stmmac_open(struct net_device *dev)
=20
 	stmmac_mmc_setup(priv);
=20
+	stmmac_init_ptp(priv);
+
 #ifdef CONFIG_STMMAC_DEBUG_FS
 	ret =3D stmmac_init_fs(dev);
 	if (ret < 0)
@@ -1507,7 +1833,15 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *s=
kb, struct net_device *dev)
=20
 	dev->stats.tx_bytes +=3D skb->len;
=20
-	skb_tx_timestamp(skb);
+	if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+		     priv->hwts_tx_en)) {
+		/* declare that device is doing timestamping */
+		skb_shinfo(skb)->tx_flags |=3D SKBTX_IN_PROGRESS;
+		priv->hw->desc->enable_tx_timestamp(first);
+	}
+
+	if (!priv->hwts_tx_en)
+		skb_tx_timestamp(skb);
=20
 	priv->hw->dma->enable_dma_transmission(priv->ioaddr);
=20
@@ -1545,9 +1879,7 @@ static inline void stmmac_rx_refill(struct stmmac=
_priv *priv)
=20
 			p->des2 =3D priv->rx_skbuff_dma[entry];
=20
-			if (unlikely((priv->mode =3D=3D STMMAC_RING_MODE) &&
-				     (priv->plat->has_gmac)))
-				priv->hw->ring->refill_desc3(bfsize, p);
+			priv->hw->ring->refill_desc3(priv, p);
=20
 			RX_DBG(KERN_INFO "\trefill entry #%d\n", entry);
 		}
@@ -1604,9 +1936,20 @@ static int stmmac_rx(struct stmmac_priv *priv, i=
nt limit)
 							   &priv->xstats,
 							   priv->dma_erx +
 							   entry);
-		if (unlikely(status =3D=3D discard_frame))
+		if (unlikely(status =3D=3D discard_frame)) {
 			priv->dev->stats.rx_errors++;
-		else {
+			if (priv->hwts_rx_en && !priv->extend_desc) {
+				/* DESC2 & DESC3 will be overwitten by device
+				 * with timestamp value, hence reinitialize
+				 * them in stmmac_rx_refill() function so that
+				 * device can reuse it.
+				 */
+				priv->rx_skbuff[entry] =3D NULL;
+				dma_unmap_single(priv->device,
+					priv->rx_skbuff_dma[entry],
+					priv->dma_buf_sz, DMA_FROM_DEVICE);
+			}
+		} else {
 			struct sk_buff *skb;
 			int frame_len;
=20
@@ -1635,6 +1978,8 @@ static int stmmac_rx(struct stmmac_priv *priv, in=
t limit)
 			prefetch(skb->data - NET_IP_ALIGN);
 			priv->rx_skbuff[entry] =3D NULL;
=20
+			stmmac_get_rx_hwtstamp(priv, entry, skb);
+
 			skb_put(skb, frame_len);
 			dma_unmap_single(priv->device,
 					 priv->rx_skbuff_dma[entry],
@@ -1855,21 +2200,30 @@ static void stmmac_poll_controller(struct net_d=
evice *dev)
  *  a proprietary structure used to pass information to the driver.
  *  @cmd: IOCTL command
  *  Description:
- *  Currently there are no special functionality supported in IOCTL, j=
ust the
- *  phy_mii_ioctl(...) can be invoked.
+ *  Currently it supports just the phy_mii_ioctl(...) and HW time stam=
ping.
  */
 static int stmmac_ioctl(struct net_device *dev, struct ifreq *rq, int =
cmd)
 {
 	struct stmmac_priv *priv =3D netdev_priv(dev);
-	int ret;
+	int ret =3D -EOPNOTSUPP;
=20
 	if (!netif_running(dev))
 		return -EINVAL;
=20
-	if (!priv->phydev)
-		return -EINVAL;
-
-	ret =3D phy_mii_ioctl(priv->phydev, rq, cmd);
+	switch (cmd) {
+	case SIOCGMIIPHY:
+	case SIOCGMIIREG:
+	case SIOCSMIIREG:
+		if (!priv->phydev)
+			return -EINVAL;
+		ret =3D phy_mii_ioctl(priv->phydev, rq, cmd);
+		break;
+	case SIOCSHWTSTAMP:
+		ret =3D stmmac_hwtstamp_ioctl(dev, rq);
+		break;
+	default:
+		break;
+	}
=20
 	return ret;
 }
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h b/drivers=
/net/ethernet/stmicro/stmmac/stmmac_ptp.h
new file mode 100644
index 0000000..3dbc047
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
@@ -0,0 +1,74 @@
+/*********************************************************************=
*********
+  PTP Header file
+
+  Copyright (C) 2013  Vayavya Labs Pvt Ltd
+
+  This program is free software; you can redistribute it and/or modify=
 it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHO=
UT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY o=
r
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licens=
e for
+  more details.
+
+  You should have received a copy of the GNU General Public License al=
ong with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution=
 in
+  the file called "COPYING".
+
+  Author: Rayagond Kokatanur <rayagond@vayavyalabs.com>
+**********************************************************************=
********/
+
+#ifndef __STMMAC_PTP_H__
+#define __STMMAC_PTP_H__
+
+#define STMMAC_SYSCLOCK 62500000
+
+/* IEEE 1588 PTP register offsets */
+#define PTP_TCR		0x0700	/* Timestamp Control Reg */
+#define PTP_SSIR	0x0704	/* Sub-Second Increment Reg */
+#define PTP_STSR	0x0708	/* System Time =E2=80=93 Seconds Regr */
+#define PTP_STNSR	0x070C	/* System Time =E2=80=93 Nanoseconds Reg */
+#define PTP_STSUR	0x0710	/* System Time =E2=80=93 Seconds Update Reg *=
/
+#define PTP_STNSUR	0x0714	/* System Time =E2=80=93 Nanoseconds Update =
Reg */
+#define PTP_TAR		0x0718	/* Timestamp Addend Reg */
+#define PTP_TTSR	0x071C	/* Target Time Seconds Reg */
+#define PTP_TTNSR	0x0720	/* Target Time Nanoseconds Reg */
+#define	PTP_STHWSR	0x0724	/* System Time - Higher Word Seconds Reg */
+#define PTP_TSR		0x0728	/* Timestamp Status */
+
+#define PTP_STNSUR_ADDSUB_SHIFT 31
+
+/* PTP TCR defines */
+#define PTP_TCR_TSENA		0x00000001 /* Timestamp Enable */
+#define PTP_TCR_TSCFUPDT	0x00000002 /* Timestamp Fine/Coarse Update */
+#define PTP_TCR_TSINIT		0x00000004 /* Timestamp Initialize */
+#define PTP_TCR_TSUPDT		0x00000008 /* Timestamp Update */
+/* Timestamp Interrupt Trigger Enable */
+#define PTP_TCR_TSTRIG		0x00000010
+#define PTP_TCR_TSADDREG	0x00000020 /* Addend Reg Update */
+#define PTP_TCR_TSENALL		0x00000100 /* Enable Timestamp for All Frames=
 */
+/* Timestamp Digital or Binary Rollover Control */
+#define PTP_TCR_TSCTRLSSR	0x00000200
+
+/* Enable PTP packet Processing for Version 2 Format */
+#define PTP_TCR_TSVER2ENA	0x00000400
+/* Enable Processing of PTP over Ethernet Frames */
+#define PTP_TCR_TSIPENA		0x00000800
+/* Enable Processing of PTP Frames Sent over IPv6-UDP */
+#define PTP_TCR_TSIPV6ENA	0x00001000
+/* Enable Processing of PTP Frames Sent over IPv4-UDP */
+#define PTP_TCR_TSIPV4ENA	0x00002000
+/* Enable Timestamp Snapshot for Event Messages */
+#define PTP_TCR_TSEVNTENA	0x00004000
+/* Enable Snapshot for Messages Relevant to Master */
+#define PTP_TCR_TSMSTRENA	0x00008000
+/* Select PTP packets for Taking Snapshots */
+#define PTP_TCR_SNAPTYPSEL_1	0x00010000
+/* Enable MAC address for PTP Frame Filtering */
+#define PTP_TCR_TSENMACADDR	0x00040000
+
+#endif /* __STMMAC_PTP_H__ */
--=20
1.7.4.4
