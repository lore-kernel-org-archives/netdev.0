From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v3 2/5] bgmac: initialize the DMA controller of core rev >= 4
Date: Sun,  5 Jan 2014 01:10:44 +0100
Message-ID: <1388880647-7611-3-git-send-email-hauke@hauke-m.de>
References: <1388880647-7611-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:60060 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755139AbaAEALC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 19:11:02 -0500
In-Reply-To: <1388880647-7611-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA controller used in the device supported by GMAC with core rev
>=3D 4 has some new options which are now set to the default values use=
d
in the Broadcom SDK.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c |   23 +++++++++++++++
 drivers/net/ethernet/broadcom/bgmac.h |   50 +++++++++++++++++++++++++=
++++++++
 2 files changed, 73 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index 39efb86..aa5e289 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -96,6 +96,19 @@ static void bgmac_dma_tx_enable(struct bgmac *bgmac,
 	u32 ctl;
=20
 	ctl =3D bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_TX_CTL);
+	if (bgmac->core->id.rev >=3D 4) {
+		ctl &=3D ~BGMAC_DMA_TX_BL_MASK;
+		ctl |=3D BGMAC_DMA_TX_BL_128 << BGMAC_DMA_TX_BL_SHIFT;
+
+		ctl &=3D ~BGMAC_DMA_TX_MR_MASK;
+		ctl |=3D BGMAC_DMA_TX_MR_2 << BGMAC_DMA_TX_MR_SHIFT;
+
+		ctl &=3D ~BGMAC_DMA_TX_PC_MASK;
+		ctl |=3D BGMAC_DMA_TX_PC_16 << BGMAC_DMA_TX_PC_SHIFT;
+
+		ctl &=3D ~BGMAC_DMA_TX_PT_MASK;
+		ctl |=3D BGMAC_DMA_TX_PT_8 << BGMAC_DMA_TX_PT_SHIFT;
+	}
 	ctl |=3D BGMAC_DMA_TX_ENABLE;
 	ctl |=3D BGMAC_DMA_TX_PARITY_DISABLE;
 	bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_TX_CTL, ctl);
@@ -240,6 +253,16 @@ static void bgmac_dma_rx_enable(struct bgmac *bgma=
c,
 	u32 ctl;
=20
 	ctl =3D bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_RX_CTL);
+	if (bgmac->core->id.rev >=3D 4) {
+		ctl &=3D ~BGMAC_DMA_RX_BL_MASK;
+		ctl |=3D BGMAC_DMA_RX_BL_128 << BGMAC_DMA_RX_BL_SHIFT;
+
+		ctl &=3D ~BGMAC_DMA_RX_PC_MASK;
+		ctl |=3D BGMAC_DMA_RX_PC_8 << BGMAC_DMA_RX_PC_SHIFT;
+
+		ctl &=3D ~BGMAC_DMA_RX_PT_MASK;
+		ctl |=3D BGMAC_DMA_RX_PT_1 << BGMAC_DMA_RX_PT_SHIFT;
+	}
 	ctl &=3D BGMAC_DMA_RX_ADDREXT_MASK;
 	ctl |=3D BGMAC_DMA_RX_ENABLE;
 	ctl |=3D BGMAC_DMA_RX_PARITY_DISABLE;
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethern=
et/broadcom/bgmac.h
index 130b16b..71adac9 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -237,9 +237,34 @@
 #define  BGMAC_DMA_TX_SUSPEND			0x00000002
 #define  BGMAC_DMA_TX_LOOPBACK			0x00000004
 #define  BGMAC_DMA_TX_FLUSH			0x00000010
+#define  BGMAC_DMA_TX_MR_MASK			0x000000C0	/* Multiple outstanding rea=
ds */
+#define  BGMAC_DMA_TX_MR_SHIFT			6
+#define   BGMAC_DMA_TX_MR_1			0
+#define   BGMAC_DMA_TX_MR_2			1
 #define  BGMAC_DMA_TX_PARITY_DISABLE		0x00000800
 #define  BGMAC_DMA_TX_ADDREXT_MASK		0x00030000
 #define  BGMAC_DMA_TX_ADDREXT_SHIFT		16
+#define  BGMAC_DMA_TX_BL_MASK			0x001C0000	/* BurstLen bits */
+#define  BGMAC_DMA_TX_BL_SHIFT			18
+#define   BGMAC_DMA_TX_BL_16			0
+#define   BGMAC_DMA_TX_BL_32			1
+#define   BGMAC_DMA_TX_BL_64			2
+#define   BGMAC_DMA_TX_BL_128			3
+#define   BGMAC_DMA_TX_BL_256			4
+#define   BGMAC_DMA_TX_BL_512			5
+#define   BGMAC_DMA_TX_BL_1024			6
+#define  BGMAC_DMA_TX_PC_MASK			0x00E00000	/* Prefetch control */
+#define  BGMAC_DMA_TX_PC_SHIFT			21
+#define   BGMAC_DMA_TX_PC_0			0
+#define   BGMAC_DMA_TX_PC_4			1
+#define   BGMAC_DMA_TX_PC_8			2
+#define   BGMAC_DMA_TX_PC_16			3
+#define  BGMAC_DMA_TX_PT_MASK			0x03000000	/* Prefetch threshold */
+#define  BGMAC_DMA_TX_PT_SHIFT			24
+#define   BGMAC_DMA_TX_PT_1			0
+#define   BGMAC_DMA_TX_PT_2			1
+#define   BGMAC_DMA_TX_PT_4			2
+#define   BGMAC_DMA_TX_PT_8			3
 #define BGMAC_DMA_TX_INDEX			0x04
 #define BGMAC_DMA_TX_RINGLO			0x08
 #define BGMAC_DMA_TX_RINGHI			0x0C
@@ -267,8 +292,33 @@
 #define  BGMAC_DMA_RX_DIRECT_FIFO		0x00000100
 #define  BGMAC_DMA_RX_OVERFLOW_CONT		0x00000400
 #define  BGMAC_DMA_RX_PARITY_DISABLE		0x00000800
+#define  BGMAC_DMA_RX_MR_MASK			0x000000C0	/* Multiple outstanding rea=
ds */
+#define  BGMAC_DMA_RX_MR_SHIFT			6
+#define   BGMAC_DMA_TX_MR_1			0
+#define   BGMAC_DMA_TX_MR_2			1
 #define  BGMAC_DMA_RX_ADDREXT_MASK		0x00030000
 #define  BGMAC_DMA_RX_ADDREXT_SHIFT		16
+#define  BGMAC_DMA_RX_BL_MASK			0x001C0000	/* BurstLen bits */
+#define  BGMAC_DMA_RX_BL_SHIFT			18
+#define   BGMAC_DMA_RX_BL_16			0
+#define   BGMAC_DMA_RX_BL_32			1
+#define   BGMAC_DMA_RX_BL_64			2
+#define   BGMAC_DMA_RX_BL_128			3
+#define   BGMAC_DMA_RX_BL_256			4
+#define   BGMAC_DMA_RX_BL_512			5
+#define   BGMAC_DMA_RX_BL_1024			6
+#define  BGMAC_DMA_RX_PC_MASK			0x00E00000	/* Prefetch control */
+#define  BGMAC_DMA_RX_PC_SHIFT			21
+#define   BGMAC_DMA_RX_PC_0			0
+#define   BGMAC_DMA_RX_PC_4			1
+#define   BGMAC_DMA_RX_PC_8			2
+#define   BGMAC_DMA_RX_PC_16			3
+#define  BGMAC_DMA_RX_PT_MASK			0x03000000	/* Prefetch threshold */
+#define  BGMAC_DMA_RX_PT_SHIFT			24
+#define   BGMAC_DMA_RX_PT_1			0
+#define   BGMAC_DMA_RX_PT_2			1
+#define   BGMAC_DMA_RX_PT_4			2
+#define   BGMAC_DMA_RX_PT_8			3
 #define BGMAC_DMA_RX_INDEX			0x24
 #define BGMAC_DMA_RX_RINGLO			0x28
 #define BGMAC_DMA_RX_RINGHI			0x2C
--=20
1.7.10.4
