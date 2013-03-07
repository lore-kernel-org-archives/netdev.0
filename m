From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: =?UTF-8?q?=5Bnet-next=2Egit=202/9=5D=20stmmac=3A=20add=20IEEE=201588-2002=20PTP=20support?=
Date: Thu,  7 Mar 2013 11:50:12 +0100
Message-ID: <1362653419-1047-3-git-send-email-peppe.cavallaro@st.com>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bh74.an@samsung.com, ayagond@vayavyalabs.com,
	Rayagond Kokatanur <rayagond@vayavyalabs.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from beta.dmz-us.st.com ([167.4.1.35]:56633 "EHLO beta.dmz-us.st.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932414Ab3CGLrH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 06:47:07 -0500
In-Reply-To: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Rayagond Kokatanur <rayagond@vayavyalabs.com>

This patch enhances the stmmac driver to support IEEE 1588-2002
PTP (Precision Time Protocol) version 1.

IEEE 1588-2002 standard defines a protocol, Precision Time
Protocol(PTP),
which enables precise synchronization of clocks in measurement and
control systems implemented with technologies such as network
communication,local computing, & distributed objects.

HW Timestamp support can be enabled while configuring the Kernel and
the Koption is: STMMAC_USE_HWSTAMP
At runtime, the support is verified by looking at the HW capability
register.

Signed-off-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Hacked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |   11 +
 drivers/net/ethernet/stmicro/stmmac/Makefile       |    1 +
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c   |   23 ++-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   27 ++-
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c    |    1 -
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |   37 +++
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |   34 +++
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c    |   14 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    8 +
 .../net/ethernet/stmicro/stmmac/stmmac_hwstamp.c   |  129 ++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  255 ++++++++++++=
+++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h   |   72 ++++++
 12 files changed, 588 insertions(+), 24 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_hwstamp.=
c
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/=
ethernet/stmicro/stmmac/Kconfig
index c0ea838..ef703b3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -71,5 +71,16 @@ config STMMAC_CHAINED
=20
 endchoice
=20
+config STMMAC_USE_HWSTAMP
+	bool "Use IEEE 1588 Precision Time Protocol"
+	depends on STMMAC_ETH
+	select PTP_1588_CLOCK
+	default n
+	---help---
+	  Enable this option to support the IEEE 1588 Precision Time Protocol
+	  (PTP) and HW Timestamps.
+	  At runtime, on new chip generations, the hardware capability
+	  register will be used to verify if either the IEEE 1588-2008 Advanc=
ed
+	  Timestamping (PTPv2) or IEEE 1588-2002 (PTPv1) is actually supporte=
d.
=20
 endif
diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net=
/ethernet/stmicro/stmmac/Makefile
index c8e8ea6..cc97c07 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Makefile
+++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
@@ -3,6 +3,7 @@ stmmac-$(CONFIG_STMMAC_RING) +=3D ring_mode.o
 stmmac-$(CONFIG_STMMAC_CHAINED) +=3D chain_mode.o
 stmmac-$(CONFIG_STMMAC_PLATFORM) +=3D stmmac_platform.o
 stmmac-$(CONFIG_STMMAC_PCI) +=3D stmmac_pci.o
+stmmac-$(CONFIG_STMMAC_USE_HWSTAMP) +=3D stmmac_hwstamp.o
 stmmac-objs:=3D stmmac_main.o stmmac_ethtool.o stmmac_mdio.o	\
 	      dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o	\
 	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
diff --git a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c b/drivers=
/net/ethernet/stmicro/stmmac/chain_mode.c
index ad3d75f..dd60f6b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/chain_mode.c
@@ -92,16 +92,35 @@ static unsigned int stmmac_is_jumbo_frm(int len, in=
t enh_desc)
 	return ret;
 }
=20
-static void stmmac_refill_desc3(int bfsize, struct dma_desc *p)
+static void stmmac_refill_desc3(void *priv_ptr, struct dma_desc *p)
 {
+	struct stmmac_priv *priv =3D (struct stmmac_priv *)priv_ptr;
+
+	if (priv->hwts_rx_en)
+		/* NOTE: Device will overwrite des3 with timestamp value if
+		 * 1588-2002 time stamping is enabled, hence reinitialize it
+		 * to keep explicit chaining in the descriptor.
+		 */
+		p->des3 =3D (unsigned int)(priv->dma_rx +
+			((priv->dirty_rx) + 1) % priv->dma_rx_size);
 }
=20
 static void stmmac_init_desc3(int des3_as_data_buf, struct dma_desc *p=
)
 {
 }
=20
-static void stmmac_clean_desc3(struct dma_desc *p)
+static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p,
+				int tstamp_taken)
 {
+	struct stmmac_priv *priv =3D (struct stmmac_priv *)priv_ptr;
+
+	if (tstamp_taken && priv->hw->desc->get_tx_ls(p))
+		/* NOTE: Device will overwrite des3 with timestamp value if
+		 * 1588-2002 time stamping is enabled, hence reinitialize it
+		 * to keep explicit chaining in the descriptor.
+		 */
+		p->des3 =3D (unsigned int)(priv->dma_tx +
+			((priv->dirty_tx + 1) % priv->dma_tx_size));
 }
=20
 static void stmmac_init_dma_chain(struct dma_desc *des, dma_addr_t phy=
_addr,
diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net=
/ethernet/stmicro/stmmac/common.h
index 186d148..fa8ff9b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -290,6 +290,16 @@ struct stmmac_desc_ops {
 	/* Return the reception status looking at the RDES1 */
 	int (*rx_status) (void *data, struct stmmac_extra_stats *x,
 			  struct dma_desc *p);
+	/* Set tx timestamp enable bit */
+	void (*enable_tx_timestamp) (struct dma_desc *p);
+	/* get tx timestamp status */
+	int (*get_tx_timestamp_status) (struct dma_desc *p);
+	/* get tx/rx timestamp low value */
+	u32 (*get_timestamp_low) (struct dma_desc *p);
+	/* get tx/rx timestamp high value */
+	u32 (*get_timestamp_high) (struct dma_desc *p);
+	/* get rx timestamp status */
+	int (*get_rx_timestamp_status) (struct dma_desc *p);
 };
=20
 struct stmmac_dma_ops {
@@ -346,6 +356,15 @@ struct stmmac_ops {
 	void (*set_eee_pls) (void __iomem *ioaddr, int link);
 };
=20
+#ifdef CONFIG_STMMAC_USE_HWSTAMP
+struct stmmac_hwtimestamp {
+	void (*config_hw_tstamping) (void __iomem *ioaddr, u32 data);
+	void (*config_sub_second_increment) (void __iomem *ioaddr);
+	int (*init_systime) (void __iomem *ioaddr, u32 sec, u32 nsec);
+	int (*config_addend)(void __iomem *ioaddr, u32 addend);
+};
+#endif
+
 struct mac_link {
 	int port;
 	int duplex;
@@ -360,11 +379,11 @@ struct mii_regs {
 struct stmmac_ring_mode_ops {
 	unsigned int (*is_jumbo_frm) (int len, int ehn_desc);
 	unsigned int (*jumbo_frm) (void *priv, struct sk_buff *skb, int csum)=
;
-	void (*refill_desc3) (int bfsize, struct dma_desc *p);
+	void (*refill_desc3) (void *priv, struct dma_desc *p);
 	void (*init_desc3) (int des3_as_data_buf, struct dma_desc *p);
 	void (*init_dma_chain) (struct dma_desc *des, dma_addr_t phy_addr,
 				unsigned int size);
-	void (*clean_desc3) (struct dma_desc *p);
+	void (*clean_desc3) (void *priv, struct dma_desc *p, int tstamp_taken=
);
 	int (*set_16kib_bfsize) (int mtu);
 };
=20
@@ -373,6 +392,9 @@ struct mac_device_info {
 	const struct stmmac_desc_ops	*desc;
 	const struct stmmac_dma_ops	*dma;
 	const struct stmmac_ring_mode_ops	*ring;
+#ifdef CONFIG_STMMAC_USE_HWSTAMP
+	const struct stmmac_hwtimestamp	*ptp;
+#endif
 	struct mii_regs mii;	/* MII register Addresses */
 	struct mac_link link;
 	unsigned int synopsys_uid;
@@ -390,5 +412,4 @@ extern void stmmac_set_mac(void __iomem *ioaddr, bo=
ol enable);
=20
 extern void dwmac_dma_flush_tx_fifo(void __iomem *ioaddr);
 extern const struct stmmac_ring_mode_ops ring_mode_ops;
-
 #endif /* __COMMON_H__ */
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/=
net/ethernet/stmicro/stmmac/dwmac_lib.c
index 491d7e9..8c4ea93 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
@@ -286,4 +286,3 @@ void stmmac_get_mac_addr(void __iomem *ioaddr, unsi=
gned char *addr,
 	addr[4] =3D hi_addr & 0xff;
 	addr[5] =3D (hi_addr >> 8) & 0xff;
 }
-
diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/n=
et/ethernet/stmicro/stmmac/enh_desc.c
index 2fc8ef9..4d635d5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -323,6 +323,38 @@ static int enh_desc_get_rx_frame_len(struct dma_de=
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
+static u32 enh_desc_get_timestamp_low(struct dma_desc *p)
+{
+	/* FIXME if Enhance descriptor with 8 DWORDS is enabled */
+	return p->des2;
+}
+
+static u32 enh_desc_get_timestamp_high(struct dma_desc *p)
+{
+	/* FIXME if Enhance descriptor with 8 DWORDS is enabled */
+	return p->des3;
+}
+
+static int enh_desc_get_rx_timestamp_status(struct dma_desc *p)
+{
+	/* FIXME if Enhance descriptor with 8 DWORDS is enabled */
+	if ((p->des2 =3D=3D 0xffffffff) && (p->des3 =3D=3D 0xffffffff))
+		/* timestamp is currupted, hence don't store it */
+		return 0;
+	else
+		return 1;
+}
+
 const struct stmmac_desc_ops enh_desc_ops =3D {
 	.tx_status =3D enh_desc_get_tx_status,
 	.rx_status =3D enh_desc_get_rx_status,
@@ -339,4 +371,9 @@ const struct stmmac_desc_ops enh_desc_ops =3D {
 	.set_tx_owner =3D enh_desc_set_tx_owner,
 	.set_rx_owner =3D enh_desc_set_rx_owner,
 	.get_rx_frame_len =3D enh_desc_get_rx_frame_len,
+	.enable_tx_timestamp =3D enh_desc_enable_tx_timestamp,
+	.get_tx_timestamp_status =3D enh_desc_get_tx_timestamp_status,
+	.get_timestamp_low =3D enh_desc_get_timestamp_low,
+	.get_timestamp_high =3D enh_desc_get_timestamp_high,
+	.get_rx_timestamp_status =3D enh_desc_get_rx_timestamp_status,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/=
net/ethernet/stmicro/stmmac/norm_desc.c
index 68962c5..edb5e88 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -215,6 +215,35 @@ static int ndesc_get_rx_frame_len(struct dma_desc =
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
+static u32 ndesc_get_timestamp_low(struct dma_desc *p)
+{
+	return p->des2;
+}
+
+static u32 ndesc_get_timestamp_high(struct dma_desc *p)
+{
+	return p->des3;
+}
+
+static int ndesc_get_rx_timestamp_status(struct dma_desc *p)
+{
+	if ((p->des2 =3D=3D 0xffffffff) && (p->des3 =3D=3D 0xffffffff))
+		/* timestamp is currupted, hence don't store it */
+		return 0;
+	else
+		return 1;
+}
+
 const struct stmmac_desc_ops ndesc_ops =3D {
 	.tx_status =3D ndesc_get_tx_status,
 	.rx_status =3D ndesc_get_rx_status,
@@ -231,4 +260,9 @@ const struct stmmac_desc_ops ndesc_ops =3D {
 	.set_tx_owner =3D ndesc_set_tx_owner,
 	.set_rx_owner =3D ndesc_set_rx_owner,
 	.get_rx_frame_len =3D ndesc_get_rx_frame_len,
+	.enable_tx_timestamp =3D ndesc_enable_tx_timestamp,
+	.get_tx_timestamp_status =3D ndesc_get_tx_timestamp_status,
+	.get_timestamp_low =3D ndesc_get_timestamp_low,
+	.get_timestamp_high =3D ndesc_get_timestamp_high,
+	.get_rx_timestamp_status =3D ndesc_get_rx_timestamp_status,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c b/drivers/=
net/ethernet/stmicro/stmmac/ring_mode.c
index 839e349..94a1c2f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
+++ b/drivers/net/ethernet/stmicro/stmmac/ring_mode.c
@@ -85,11 +85,14 @@ static unsigned int stmmac_is_jumbo_frm(int len, in=
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
 /* In ring mode we need to fill the desc3 because it is used
@@ -105,7 +108,8 @@ static void stmmac_init_dma_chain(struct dma_desc *=
des, dma_addr_t phy_addr,
 {
 }
=20
-static void stmmac_clean_desc3(struct dma_desc *p)
+static void stmmac_clean_desc3(void *priv_ptr, struct dma_desc *p,
+				int tstamp_taken)
 {
 	if (unlikely(p->des3))
 		p->des3 =3D 0;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net=
/ethernet/stmicro/stmmac/stmmac.h
index 013a7d5..665f2a2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -94,6 +94,11 @@ struct stmmac_priv {
 	u32 tx_coal_timer;
 	int use_riwt;
 	u32 rx_riwt;
+#ifdef CONFIG_STMMAC_USE_HWSTAMP
+	int hwts_tx_en;
+	int hwts_rx_en;
+	unsigned int default_addend;
+#endif
 };
=20
 extern int phyaddr;
@@ -103,6 +108,9 @@ extern int stmmac_mdio_register(struct net_device *=
ndev);
 extern void stmmac_set_ethtool_ops(struct net_device *netdev);
 extern const struct stmmac_desc_ops enh_desc_ops;
 extern const struct stmmac_desc_ops ndesc_ops;
+#ifdef CONFIG_STMMAC_USE_HWSTAMP
+extern const struct stmmac_hwtimestamp stmmac_ptp;
+#endif
 int stmmac_freeze(struct net_device *ndev);
 int stmmac_restore(struct net_device *ndev);
 int stmmac_resume(struct net_device *ndev);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_hwstamp.c b/dri=
vers/net/ethernet/stmicro/stmmac/stmmac_hwstamp.c
new file mode 100644
index 0000000..be9e399
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_hwstamp.c
@@ -0,0 +1,129 @@
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
+	 * where, ptp_clock =3D 50MHz for FINE correction method &
+	 * ptp_clock =3D STMMAC_SYSCLOCK for COARSE correction method
+	 */
+	if (value & PTP_TCR_TSCFUPDT)
+		data =3D (1000000000ULL / 50000000);
+	else
+		data =3D (1000000000ULL / STMMAC_SYSCLOCK);
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
+	/* wait for previous(if any) system time initialize to complete */
+	limit =3D 100;
+	while (limit--) {
+		if (!(readl(ioaddr + PTP_TCR) & PTP_TCR_TSINIT))
+			break;
+		mdelay(10);
+	}
+
+	if (limit < 0)
+		return -EBUSY;
+
+	writel(sec, ioaddr + PTP_STSUR);
+	writel(nsec, ioaddr + PTP_STNSUR);
+	/* issue command to initialize the system time value */
+	value =3D readl(ioaddr + PTP_TCR);
+	value |=3D PTP_TCR_TSINIT;
+	writel(value, ioaddr + PTP_TCR);
+
+	/* wait for present system time initialize to complete */
+	limit =3D 100;
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
+	/* wait for previous (if any) addend update to complete */
+	limit =3D 100;
+	while (limit--) {
+		if (!(readl(ioaddr + PTP_TCR) & PTP_TCR_TSADDREG))
+			break;
+		mdelay(10);
+	}
+	if (limit < 0)
+		return -EBUSY;
+
+	writel(addend, ioaddr + PTP_TAR);
+	/* issue command to update the addend value */
+	value =3D readl(ioaddr + PTP_TCR);
+	value |=3D PTP_TCR_TSADDREG;
+	writel(value, ioaddr + PTP_TCR);
+
+	/* wait for present addend update to complete */
+	limit =3D 100;
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
index 260af93..3bbd554 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -47,6 +47,10 @@
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
 #endif
+#ifdef CONFIG_STMMAC_USE_HWSTAMP
+#include <linux/net_tstamp.h>
+#include "stmmac_ptp.h"
+#endif
 #include "stmmac.h"
=20
 #undef STMMAC_DEBUG
@@ -304,6 +308,192 @@ static void stmmac_eee_adjust(struct stmmac_priv =
*priv)
 		priv->hw->mac->set_eee_pls(priv->ioaddr, priv->phydev->link);
 }
=20
+#ifdef CONFIG_STMMAC_USE_HWSTAMP
+/* stmmac_get_tx_hwtstamp:
+ * @priv : pointer to private device structure.
+ * @p : pointer to desc structure.
+ * @skb : the socket buffer
+ * Description :
+ * This function will read timestamp from the descriptor & pass it to =
stack.
+ * and also perform some sanity checks.
+ * Return value :
+ * 1 if time stamp is taken & 0 if time stamp is not taken.
+ */
+static unsigned int stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
+					   struct dma_desc *p,
+					   struct sk_buff *skb)
+{
+	struct skb_shared_hwtstamps shhwtstamp;
+	u64 ns;
+
+	if (!priv->hwts_tx_en)
+		return 0;
+
+	/* if skb doesn't support hw tstamp */
+	if (likely(!(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS)))
+		return 0;
+
+	/* check tx tstamp status */
+	if (!priv->hw->desc->get_tx_timestamp_status(p))
+		return 0;
+
+	/* get the valid tstamp */
+	ns =3D priv->hw->desc->get_timestamp_low(p);
+	/* convert high/sec time stamp value to nanosecond */
+	ns +=3D priv->hw->desc->get_timestamp_high(p) * 1000000000ULL;
+
+	memset(&shhwtstamp, 0, sizeof(struct skb_shared_hwtstamps));
+	shhwtstamp.hwtstamp =3D ns_to_ktime(ns);
+	/* pass tstamp to stack */
+	skb_tstamp_tx(skb, &shhwtstamp);
+
+	return 1;
+}
+
+/* stmmac_get_rx_hwtstamp:
+ * @priv : pointer to private device structure.
+ * @p : pointer to desc structure.
+ * @skb : the socket buffer
+ * Description :
+ * This function will read received packet's timestamp from the descri=
ptor
+ * and pass it to stack. It also perform some sanity checks.
+ */
+static void stmmac_get_rx_hwtstamp(struct stmmac_priv *priv, struct dm=
a_desc *p,
+				   struct sk_buff *skb)
+{
+	struct skb_shared_hwtstamps *shhwtstamp =3D NULL;
+	u64 ns;
+
+	if (!priv->hwts_rx_en)
+		return;
+
+	/* if rx tstamp is not valid */
+	if (!priv->hw->desc->get_rx_timestamp_status(p))
+		return;
+
+	/* get valid tstamp */
+	ns =3D priv->hw->desc->get_timestamp_low(p);
+	/* convert high/sec time stamp value to nanosecond */
+	ns +=3D priv->hw->desc->get_timestamp_high(p) * 1000000000ULL;
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
+
+	if (!priv->dma_cap.time_stamp) {
+		netdev_alert(priv->dev, "No HW time stamping supported\n");
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
+	switch (config.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		config.rx_filter =3D HWTSTAMP_FILTER_NONE;
+		break;
+	default:
+		/* PTP v1, UDP, any kind of event packet */
+		config.rx_filter =3D HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
+		break;
+	}
+	priv->hwts_rx_en =3D ((config.rx_filter =3D=3D HWTSTAMP_FILTER_NONE) =
? 0 : 1);
+
+	if (!priv->hwts_tx_en && !priv->hwts_rx_en)
+		priv->hw->ptp->config_hw_tstamping(priv->ioaddr, 0);
+	else {
+		priv->hw->ptp->config_hw_tstamping(priv->ioaddr,
+			(PTP_TCR_TSENA | PTP_TCR_TSCFUPDT));
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
+	if (priv->dma_cap.time_stamp)
+		pr_debug("IEEE 1588-2002 Time Stamp supported\n");
+	if (priv->dma_cap.atime_stamp)
+		pr_debug("IEEE 1588-2008 Advanced Time Stamp supported\n");
+
+	priv->hw->ptp =3D &stmmac_ptp;
+
+	priv->hwts_tx_en =3D 0;
+	priv->hwts_rx_en =3D 0;
+
+}
+#else
+#define stmmac_hwtstamp_ioctl(dev, ifr)	(-EOPNOTSUPP)
+#define stmmac_get_rx_hwtstamp(priv, p, skb)
+#define stmmac_get_tx_hwtstamp(priv, p, skb) 0
+#define stmmac_init_ptp(priv)
+#endif /* CONFIG_STMMAC_USE_HWSTAMP */
+
 /**
  * stmmac_adjust_link
  * @dev: net device structure
@@ -712,6 +902,7 @@ static void stmmac_tx_clean(struct stmmac_priv *pri=
v)
=20
 	while (priv->dirty_tx !=3D priv->cur_tx) {
 		int last;
+		unsigned int ts =3D 0;
 		unsigned int entry =3D priv->dirty_tx % txsize;
 		struct sk_buff *skb =3D priv->tx_skbuff[entry];
 		struct dma_desc *p =3D priv->dma_tx + entry;
@@ -732,6 +923,8 @@ static void stmmac_tx_clean(struct stmmac_priv *pri=
v)
 				priv->xstats.tx_pkt_n++;
 			} else
 				priv->dev->stats.tx_errors++;
+
+			ts =3D stmmac_get_tx_hwtstamp(priv, p, skb);
 		}
 		TX_DBG("%s: curr %d, dirty %d\n", __func__,
 			priv->cur_tx, priv->dirty_tx);
@@ -743,7 +936,7 @@ static void stmmac_tx_clean(struct stmmac_priv *pri=
v)
 					 DMA_TO_DEVICE);
 			priv->tx_skbuff_dma[entry] =3D 0;
 		}
-		priv->hw->ring->clean_desc3(p);
+		priv->hw->ring->clean_desc3(priv, p, ts);
=20
 		if (likely(skb !=3D NULL)) {
 			dev_kfree_skb(skb);
@@ -1027,6 +1220,7 @@ static int stmmac_open(struct net_device *dev)
 		goto open_error;
 	}
=20
+
 	/* Create and initialize the TX/RX descriptors chains. */
 	priv->dma_tx_size =3D STMMAC_ALIGN(dma_txsize);
 	priv->dma_rx_size =3D STMMAC_ALIGN(dma_rxsize);
@@ -1093,6 +1287,8 @@ static int stmmac_open(struct net_device *dev)
=20
 	stmmac_mmc_setup(priv);
=20
+	stmmac_init_ptp(priv);
+
 #ifdef CONFIG_STMMAC_DEBUG_FS
 	ret =3D stmmac_init_fs(dev);
 	if (ret < 0)
@@ -1325,7 +1521,17 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *s=
kb, struct net_device *dev)
=20
 	dev->stats.tx_bytes +=3D skb->len;
=20
-	skb_tx_timestamp(skb);
+#ifdef CONFIG_STMMAC_USE_HWSTAMP
+	if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+		     priv->hwts_tx_en)) {
+		/* declare that device is doing timestamping */
+		skb_shinfo(skb)->tx_flags |=3D SKBTX_IN_PROGRESS;
+		priv->hw->desc->enable_tx_timestamp(first);
+	}
+
+	if (!priv->hwts_tx_en)
+#endif /* CONFIG_STMMAC_USE_HWSTAMP */
+		skb_tx_timestamp(skb);
=20
 	priv->hw->dma->enable_dma_transmission(priv->ioaddr);
=20
@@ -1357,8 +1563,7 @@ static inline void stmmac_rx_refill(struct stmmac=
_priv *priv)
=20
 			(p + entry)->des2 =3D priv->rx_skbuff_dma[entry];
=20
-			if (unlikely(priv->plat->has_gmac))
-				priv->hw->ring->refill_desc3(bfsize, p + entry);
+			priv->hw->ring->refill_desc3(priv, p + entry);
=20
 			RX_DBG(KERN_INFO "\trefill entry #%d\n", entry);
 		}
@@ -1398,9 +1603,22 @@ static int stmmac_rx(struct stmmac_priv *priv, i=
nt limit)
 		/* read the status of the incoming frame */
 		status =3D (priv->hw->desc->rx_status(&priv->dev->stats,
 						    &priv->xstats, p));
-		if (unlikely(status =3D=3D discard_frame))
+		if (unlikely(status =3D=3D discard_frame)) {
 			priv->dev->stats.rx_errors++;
-		else {
+#ifdef CONFIG_STMMAC_USE_HWSTAMP
+			if (priv->hwts_rx_en) {
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
+#endif /* CONFIG_STMMAC_USE_HWSTAMP */
+		} else {
 			struct sk_buff *skb;
 			int frame_len;
=20
@@ -1429,6 +1647,8 @@ static int stmmac_rx(struct stmmac_priv *priv, in=
t limit)
 			prefetch(skb->data - NET_IP_ALIGN);
 			priv->rx_skbuff[entry] =3D NULL;
=20
+			stmmac_get_rx_hwtstamp(priv, p, skb);
+
 			skb_put(skb, frame_len);
 			dma_unmap_single(priv->device,
 					 priv->rx_skbuff_dma[entry],
@@ -1666,21 +1886,30 @@ static void stmmac_poll_controller(struct net_d=
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
index 0000000..d557696
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
@@ -0,0 +1,72 @@
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
