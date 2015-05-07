From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [RFC,v3 06/12] fsl/fman: Add the FMan MAC FLIB
Date: Thu, 7 May 2015 16:05:37 +0300
Message-ID: <1431003943-14906-6-git-send-email-madalin.bucur@freescale.com>
References: <1431003943-14906-1-git-send-email-madalin.bucur@freescale.com>
 <1431003943-14906-2-git-send-email-madalin.bucur@freescale.com>
 <1431003943-14906-3-git-send-email-madalin.bucur@freescale.com>
 <1431003943-14906-4-git-send-email-madalin.bucur@freescale.com>
 <1431003943-14906-5-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Igal Liberman <Igal.Liberman@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0105.outbound.protection.outlook.com ([157.56.110.105]:10554
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751907AbbEGNFz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 09:05:55 -0400
In-Reply-To: <1431003943-14906-5-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igal Liberman <Igal.Liberman@freescale.com>

The FMan MAC FLib provides basic API used by the drivers to
configure and control the FMan MAC hardware.

Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
---
 drivers/net/ethernet/freescale/fman/Makefile       |   1 +
 drivers/net/ethernet/freescale/fman/mac/Makefile   |   5 +
 .../net/ethernet/freescale/fman/mac/fman_crc32.c   | 116 +++++
 .../net/ethernet/freescale/fman/mac/fman_crc32.h   |  39 ++
 .../net/ethernet/freescale/fman/mac/fman_dtsec.c   | 571 +++++++++++++++++++++
 .../freescale/fman/mac/fman_dtsec_mii_acc.c        | 168 ++++++
 .../net/ethernet/freescale/fman/mac/fman_memac.c   | 365 +++++++++++++
 .../freescale/fman/mac/fman_memac_mii_acc.c        | 217 ++++++++
 .../net/ethernet/freescale/fman/mac/fman_tgec.c    | 217 ++++++++
 9 files changed, 1699 insertions(+)
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/Makefile
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_crc32.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_crc32.h
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_dtsec.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_dtsec_mii_acc.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_memac.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_memac_mii_acc.c
 create mode 100644 drivers/net/ethernet/freescale/fman/mac/fman_tgec.c

diff --git a/drivers/net/ethernet/freescale/fman/Makefile b/drivers/net/ethernet/freescale/fman/Makefile
index a9ae0aa..534d1ed 100644
--- a/drivers/net/ethernet/freescale/fman/Makefile
+++ b/drivers/net/ethernet/freescale/fman/Makefile
@@ -5,3 +5,4 @@ obj-y		+= fsl_fman.o
 fsl_fman-objs			:= fman.o
 
 obj-y	+= port/
+obj-y	+= mac/
diff --git a/drivers/net/ethernet/freescale/fman/mac/Makefile b/drivers/net/ethernet/freescale/fman/mac/Makefile
new file mode 100644
index 0000000..80b7048
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/Makefile
@@ -0,0 +1,5 @@
+obj-$(CONFIG_FSL_FMAN_MAC)	+= fsl_fman_mac.o
+
+fsl_fman_mac-objs		:= fman_dtsec.o fman_dtsec_mii_acc.o	\
+				   fman_memac.o fman_tgec.o		\
+				   fman_crc32.o fman_memac_mii_acc.o
diff --git a/drivers/net/ethernet/freescale/fman/mac/fman_crc32.c b/drivers/net/ethernet/freescale/fman/mac/fman_crc32.c
new file mode 100644
index 0000000..1536d12
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/fman_crc32.c
@@ -0,0 +1,116 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "fman_crc32.h"
+#include "common/general.h"
+
+/* precomputed CRC values for address hashing */
+static const uint32_t crc_tbl[256] = {
+	0x00000000, 0x77073096, 0xee0e612c, 0x990951ba, 0x076dc419, 0x706af48f,
+	0xe963a535, 0x9e6495a3, 0x0edb8832, 0x79dcb8a4, 0xe0d5e91e, 0x97d2d988,
+	0x09b64c2b, 0x7eb17cbd, 0xe7b82d07, 0x90bf1d91, 0x1db71064, 0x6ab020f2,
+	0xf3b97148, 0x84be41de, 0x1adad47d, 0x6ddde4eb, 0xf4d4b551, 0x83d385c7,
+	0x136c9856, 0x646ba8c0, 0xfd62f97a, 0x8a65c9ec, 0x14015c4f, 0x63066cd9,
+	0xfa0f3d63, 0x8d080df5, 0x3b6e20c8, 0x4c69105e, 0xd56041e4, 0xa2677172,
+	0x3c03e4d1, 0x4b04d447, 0xd20d85fd, 0xa50ab56b, 0x35b5a8fa, 0x42b2986c,
+	0xdbbbc9d6, 0xacbcf940, 0x32d86ce3, 0x45df5c75, 0xdcd60dcf, 0xabd13d59,
+	0x26d930ac, 0x51de003a, 0xc8d75180, 0xbfd06116, 0x21b4f4b5, 0x56b3c423,
+	0xcfba9599, 0xb8bda50f, 0x2802b89e, 0x5f058808, 0xc60cd9b2, 0xb10be924,
+	0x2f6f7c87, 0x58684c11, 0xc1611dab, 0xb6662d3d, 0x76dc4190, 0x01db7106,
+	0x98d220bc, 0xefd5102a, 0x71b18589, 0x06b6b51f, 0x9fbfe4a5, 0xe8b8d433,
+	0x7807c9a2, 0x0f00f934, 0x9609a88e, 0xe10e9818, 0x7f6a0dbb, 0x086d3d2d,
+	0x91646c97, 0xe6635c01, 0x6b6b51f4, 0x1c6c6162, 0x856530d8, 0xf262004e,
+	0x6c0695ed, 0x1b01a57b, 0x8208f4c1, 0xf50fc457, 0x65b0d9c6, 0x12b7e950,
+	0x8bbeb8ea, 0xfcb9887c, 0x62dd1ddf, 0x15da2d49, 0x8cd37cf3, 0xfbd44c65,
+	0x4db26158, 0x3ab551ce, 0xa3bc0074, 0xd4bb30e2, 0x4adfa541, 0x3dd895d7,
+	0xa4d1c46d, 0xd3d6f4fb, 0x4369e96a, 0x346ed9fc, 0xad678846, 0xda60b8d0,
+	0x44042d73, 0x33031de5, 0xaa0a4c5f, 0xdd0d7cc9, 0x5005713c, 0x270241aa,
+	0xbe0b1010, 0xc90c2086, 0x5768b525, 0x206f85b3, 0xb966d409, 0xce61e49f,
+	0x5edef90e, 0x29d9c998, 0xb0d09822, 0xc7d7a8b4, 0x59b33d17, 0x2eb40d81,
+	0xb7bd5c3b, 0xc0ba6cad, 0xedb88320, 0x9abfb3b6, 0x03b6e20c, 0x74b1d29a,
+	0xead54739, 0x9dd277af, 0x04db2615, 0x73dc1683, 0xe3630b12, 0x94643b84,
+	0x0d6d6a3e, 0x7a6a5aa8, 0xe40ecf0b, 0x9309ff9d, 0x0a00ae27, 0x7d079eb1,
+	0xf00f9344, 0x8708a3d2, 0x1e01f268, 0x6906c2fe, 0xf762575d, 0x806567cb,
+	0x196c3671, 0x6e6b06e7, 0xfed41b76, 0x89d32be0, 0x10da7a5a, 0x67dd4acc,
+	0xf9b9df6f, 0x8ebeeff9, 0x17b7be43, 0x60b08ed5, 0xd6d6a3e8, 0xa1d1937e,
+	0x38d8c2c4, 0x4fdff252, 0xd1bb67f1, 0xa6bc5767, 0x3fb506dd, 0x48b2364b,
+	0xd80d2bda, 0xaf0a1b4c, 0x36034af6, 0x41047a60, 0xdf60efc3, 0xa867df55,
+	0x316e8eef, 0x4669be79, 0xcb61b38c, 0xbc66831a, 0x256fd2a0, 0x5268e236,
+	0xcc0c7795, 0xbb0b4703, 0x220216b9, 0x5505262f, 0xc5ba3bbe, 0xb2bd0b28,
+	0x2bb45a92, 0x5cb36a04, 0xc2d7ffa7, 0xb5d0cf31, 0x2cd99e8b, 0x5bdeae1d,
+	0x9b64c2b0, 0xec63f226, 0x756aa39c, 0x026d930a, 0x9c0906a9, 0xeb0e363f,
+	0x72076785, 0x05005713, 0x95bf4a82, 0xe2b87a14, 0x7bb12bae, 0x0cb61b38,
+	0x92d28e9b, 0xe5d5be0d, 0x7cdcefb7, 0x0bdbdf21, 0x86d3d2d4, 0xf1d4e242,
+	0x68ddb3f8, 0x1fda836e, 0x81be16cd, 0xf6b9265b, 0x6fb077e1, 0x18b74777,
+	0x88085ae6, 0xff0f6a70, 0x66063bca, 0x11010b5c, 0x8f659eff, 0xf862ae69,
+	0x616bffd3, 0x166ccf45, 0xa00ae278, 0xd70dd2ee, 0x4e048354, 0x3903b3c2,
+	0xa7672661, 0xd06016f7, 0x4969474d, 0x3e6e77db, 0xaed16a4a, 0xd9d65adc,
+	0x40df0b66, 0x37d83bf0, 0xa9bcae53, 0xdebb9ec5, 0x47b2cf7f, 0x30b5ffe9,
+	0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6, 0xbad03605, 0xcdd70693,
+	0x54de5729, 0x23d967bf, 0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94,
+	0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d
+};
+
+/* Get the mirrored value of a byte size number. (0x11010011 --> 0x11001011) */
+static inline uint8_t get_mirror8(uint8_t n)
+{
+	uint8_t mirror[16] = {
+		0x00, 0x08, 0x04, 0x0c, 0x02, 0x0a, 0x06, 0x0e,
+		0x01, 0x09, 0x05, 0x0d, 0x03, 0x0b, 0x07, 0x0f
+	};
+	return (uint8_t)(((mirror[n & 0x0f] << 4) | (mirror[n >> 4])));
+}
+
+static inline uint32_t get_mirror32(uint32_t n)
+{
+	return ((uint32_t)get_mirror8((uint8_t)(n)) << 24) |
+	    ((uint32_t)get_mirror8((uint8_t)(n >> 8)) << 16) |
+	    ((uint32_t)get_mirror8((uint8_t)(n >> 16)) << 8) |
+	    ((uint32_t)get_mirror8((uint8_t)(n >> 24)));
+}
+
+uint32_t get_mac_addr_crc(uint64_t _addr)
+{
+	uint32_t i;
+	uint8_t data;
+	uint32_t crc;
+
+	/* CRC calculation */
+	crc = 0xffffffff;
+	for (i = 0; i < 6; i++) {
+		data = (uint8_t)(_addr >> ((5 - i) * 8));
+		crc = crc ^ data;
+		crc = crc_tbl[crc & 0xff] ^ (crc >> 8);
+	}
+
+	crc = get_mirror32(crc);
+	return crc;
+}
diff --git a/drivers/net/ethernet/freescale/fman/mac/fman_crc32.h b/drivers/net/ethernet/freescale/fman/mac/fman_crc32.h
new file mode 100644
index 0000000..eac30f3
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/fman_crc32.h
@@ -0,0 +1,39 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __FMAN_CRC32_H
+#define __FMAN_CRC32_H
+
+#include "common/general.h"
+
+uint32_t get_mac_addr_crc(uint64_t _addr);
+
+#endif	/* __FMAN_CRC32_H */
diff --git a/drivers/net/ethernet/freescale/fman/mac/fman_dtsec.c b/drivers/net/ethernet/freescale/fman/mac/fman_dtsec.c
new file mode 100644
index 0000000..290a037
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/fman_dtsec.c
@@ -0,0 +1,571 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "fsl_fman_dtsec.h"
+
+void fman_dtsec_stop_rx(struct dtsec_regs __iomem *regs)
+{
+	/* Assert the graceful stop bit */
+	iowrite32be(ioread32be(&regs->rctrl) | RCTRL_GRS, &regs->rctrl);
+}
+
+void fman_dtsec_stop_tx(struct dtsec_regs __iomem *regs)
+{
+	/* Assert the graceful stop bit */
+	iowrite32be(ioread32be(&regs->tctrl) | DTSEC_TCTRL_GTS, &regs->tctrl);
+}
+
+void fman_dtsec_start_tx(struct dtsec_regs __iomem *regs)
+{
+	/* clear the graceful stop bit */
+	iowrite32be(ioread32be(&regs->tctrl) & ~DTSEC_TCTRL_GTS, &regs->tctrl);
+}
+
+void fman_dtsec_start_rx(struct dtsec_regs __iomem *regs)
+{
+	/* clear the graceful stop bit */
+	iowrite32be(ioread32be(&regs->rctrl) & ~RCTRL_GRS, &regs->rctrl);
+}
+
+void fman_dtsec_defconfig(struct dtsec_cfg *cfg)
+{
+	cfg->halfdup_on = DEFAULT_HALFDUP_ON;
+	cfg->halfdup_retransmit = DEFAULT_HALFDUP_RETRANSMIT;
+	cfg->halfdup_coll_window = DEFAULT_HALFDUP_COLL_WINDOW;
+	cfg->halfdup_excess_defer = DEFAULT_HALFDUP_EXCESS_DEFER;
+	cfg->halfdup_no_backoff = DEFAULT_HALFDUP_NO_BACKOFF;
+	cfg->halfdup_bp_no_backoff = DEFAULT_HALFDUP_BP_NO_BACKOFF;
+	cfg->halfdup_alt_backoff_val = DEFAULT_HALFDUP_ALT_BACKOFF_VAL;
+	cfg->halfdup_alt_backoff_en = DEFAULT_HALFDUP_ALT_BACKOFF_EN;
+	cfg->rx_drop_bcast = DEFAULT_RX_DROP_BCAST;
+	cfg->rx_short_frm = DEFAULT_RX_SHORT_FRM;
+	cfg->rx_len_check = DEFAULT_RX_LEN_CHECK;
+	cfg->tx_pad_crc = DEFAULT_TX_PAD_CRC;
+	cfg->tx_crc = DEFAULT_TX_CRC;
+	cfg->rx_ctrl_acc = DEFAULT_RX_CTRL_ACC;
+	cfg->tx_pause_time = DEFAULT_TX_PAUSE_TIME;
+	/* PHY address 0 is reserved (DPAA RM) */
+	cfg->tbipa = DEFAULT_TBIPA;
+	cfg->rx_prepend = DEFAULT_RX_PREPEND;
+	cfg->ptp_tsu_en = DEFAULT_PTP_TSU_EN;
+	cfg->ptp_exception_en = DEFAULT_PTP_EXCEPTION_EN;
+	cfg->preamble_len = DEFAULT_PREAMBLE_LEN;
+	cfg->rx_preamble = DEFAULT_RX_PREAMBLE;
+	cfg->tx_preamble = DEFAULT_TX_PREAMBLE;
+	cfg->loopback = DEFAULT_LOOPBACK;
+	cfg->rx_time_stamp_en = DEFAULT_RX_TIME_STAMP_EN;
+	cfg->tx_time_stamp_en = DEFAULT_TX_TIME_STAMP_EN;
+	cfg->rx_flow = DEFAULT_RX_FLOW;
+	cfg->tx_flow = DEFAULT_TX_FLOW;
+	cfg->rx_group_hash_exd = DEFAULT_RX_GROUP_HASH_EXD;
+	cfg->tx_pause_time_extd = DEFAULT_TX_PAUSE_TIME_EXTD;
+	cfg->rx_promisc = DEFAULT_RX_PROMISC;
+	cfg->non_back_to_back_ipg1 = DEFAULT_NON_BACK_TO_BACK_IPG1;
+	cfg->non_back_to_back_ipg2 = DEFAULT_NON_BACK_TO_BACK_IPG2;
+	cfg->min_ifg_enforcement = DEFAULT_MIN_IFG_ENFORCEMENT;
+	cfg->back_to_back_ipg = DEFAULT_BACK_TO_BACK_IPG;
+	cfg->maximum_frame = DEFAULT_MAXIMUM_FRAME;
+	cfg->tbi_phy_addr = DEFAULT_TBI_PHY_ADDR;
+	cfg->wake_on_lan = DEFAULT_WAKE_ON_LAN;
+}
+
+int fman_dtsec_init(struct dtsec_regs __iomem *regs, struct dtsec_cfg *cfg,
+		    enum enet_interface iface_mode,
+		    enum enet_speed iface_speed,
+		    uint8_t *macaddr,
+		    uint8_t __maybe_unused fm_rev_maj,
+		    uint8_t __maybe_unused fm_rev_min, uint32_t exception_mask)
+{
+	bool is_rgmii, is_sgmii, is_qsgmii;
+	int i;
+	uint32_t tmp;
+
+	/* let's start with a soft reset */
+	iowrite32be(MACCFG1_SOFT_RESET, &regs->maccfg1);
+	iowrite32be(0, &regs->maccfg1);
+
+	/*dtsec_id2*/
+	tmp = ioread32be(&regs->tsec_id2);
+
+	/* check RGMII support */
+	if (iface_mode == E_ENET_IF_RGMII || iface_mode == E_ENET_IF_RMII)
+		if (tmp & DTSEC_ID2_INT_REDUCED_OFF)
+			return -EINVAL;
+
+	if (iface_mode == E_ENET_IF_SGMII || iface_mode == E_ENET_IF_MII)
+		if (tmp & DTSEC_ID2_INT_REDUCED_OFF)
+			return -EINVAL;
+
+	/*ECNTRL*/
+
+	is_rgmii = (bool)((iface_mode == E_ENET_IF_RGMII) ? true : false);
+	is_sgmii = (bool)((iface_mode == E_ENET_IF_SGMII) ? true : false);
+	is_qsgmii = (bool)((iface_mode == E_ENET_IF_QSGMII) ? true : false);
+
+	tmp = 0;
+	if (is_rgmii || iface_mode == E_ENET_IF_GMII)
+		tmp |= DTSEC_ECNTRL_GMIIM;
+	if (is_sgmii)
+		tmp |= (DTSEC_ECNTRL_SGMIIM | DTSEC_ECNTRL_TBIM);
+	if (is_qsgmii)
+		tmp |= (DTSEC_ECNTRL_SGMIIM | DTSEC_ECNTRL_TBIM |
+			DTSEC_ECNTRL_QSGMIIM);
+	if (is_rgmii)
+		tmp |= DTSEC_ECNTRL_RPM;
+	if (iface_speed == E_ENET_SPEED_100)
+		tmp |= DTSEC_ECNTRL_R100M;
+
+	iowrite32be(tmp, &regs->ecntrl);
+	/*ECNTRL*/
+
+	/*TCTRL*/
+	tmp = 0;
+	if (cfg->halfdup_on)
+		tmp |= DTSEC_TCTRL_THDF;
+	if (cfg->tx_time_stamp_en)
+		tmp |= DTSEC_TCTRL_TTSE;
+
+	iowrite32be(tmp, &regs->tctrl);
+
+	/*TCTRL*/
+
+	/*PTV*/
+	tmp = 0;
+
+#ifdef FM_SHORT_PAUSE_TIME_ERRATA_DTSEC1
+	if ((fm_rev_maj == 1) && (fm_rev_min == 0))
+		cfg->tx_pause_time += 2;
+#endif /* FM_SHORT_PAUSE_TIME_ERRATA_DTSEC1 */
+
+	if (cfg->tx_pause_time)
+		tmp |= cfg->tx_pause_time;
+	if (cfg->tx_pause_time_extd)
+		tmp |= cfg->tx_pause_time_extd << PTV_PTE_OFST;
+	iowrite32be(tmp, &regs->ptv);
+
+	/*RCTRL*/
+	tmp = 0;
+	tmp |= ((uint32_t)(cfg->rx_prepend & 0x0000001f)) << 16;
+	if (cfg->rx_ctrl_acc)
+		tmp |= RCTRL_CFA;
+	if (cfg->rx_group_hash_exd)
+		tmp |= RCTRL_GHTX;
+	if (cfg->rx_time_stamp_en)
+		tmp |= RCTRL_RTSE;
+	if (cfg->rx_drop_bcast)
+		tmp |= RCTRL_BC_REJ;
+	if (cfg->rx_short_frm)
+		tmp |= RCTRL_RSF;
+	if (cfg->rx_promisc)
+		tmp |= RCTRL_PROM;
+
+	iowrite32be(tmp, &regs->rctrl);
+	/*RCTRL*/
+
+	/*Assign a Phy Address to the TBI (TBIPA).
+	 *Done also in cases where TBI is not selected to avoid conflict with
+	 *the external PHY's Physical address
+	 */
+	iowrite32be(cfg->tbipa, &regs->tbipa);
+
+	/*TMR_CTL*/
+	iowrite32be(0, &regs->tmr_ctrl);
+
+	if (cfg->ptp_tsu_en) {
+		tmp = 0;
+		tmp |= TMR_PEVENT_TSRE;
+		iowrite32be(tmp, &regs->tmr_pevent);
+
+		if (cfg->ptp_exception_en) {
+			tmp = 0;
+			tmp |= TMR_PEMASK_TSREEN;
+			iowrite32be(tmp, &regs->tmr_pemask);
+		}
+	}
+
+	/*MACCFG1*/
+	tmp = 0;
+	if (cfg->loopback)
+		tmp |= MACCFG1_LOOPBACK;
+	if (cfg->rx_flow)
+		tmp |= MACCFG1_RX_FLOW;
+	if (cfg->tx_flow)
+		tmp |= MACCFG1_TX_FLOW;
+	iowrite32be(tmp, &regs->maccfg1);
+
+	/*MACCFG1*/
+
+	/*MACCFG2*/
+	tmp = 0;
+
+	if (iface_speed < E_ENET_SPEED_1000)
+		tmp |= MACCFG2_NIBBLE_MODE;
+	else if (iface_speed == E_ENET_SPEED_1000)
+		tmp |= MACCFG2_BYTE_MODE;
+
+	tmp |= ((uint32_t)cfg->preamble_len & 0x0000000f)
+	    << PREAMBLE_LENGTH_SHIFT;
+
+	if (cfg->rx_preamble)
+		tmp |= MACCFG2_PRE_AM_RX_EN;
+	if (cfg->tx_preamble)
+		tmp |= MACCFG2_PRE_AM_TX_EN;
+	if (cfg->rx_len_check)
+		tmp |= MACCFG2_LENGTH_CHECK;
+	if (cfg->tx_pad_crc)
+		tmp |= MACCFG2_PAD_CRC_EN;
+	if (cfg->tx_crc)
+		tmp |= MACCFG2_CRC_EN;
+	if (!cfg->halfdup_on)
+		tmp |= MACCFG2_FULL_DUPLEX;
+	iowrite32be(tmp, &regs->maccfg2);
+
+	/*MACCFG2*/
+
+	/*IPGIFG*/
+	tmp = (((cfg->non_back_to_back_ipg1 <<
+		 IPGIFG_NON_BACK_TO_BACK_IPG_1_SHIFT)
+		& IPGIFG_NON_BACK_TO_BACK_IPG_1)
+	       | ((cfg->non_back_to_back_ipg2 <<
+		   IPGIFG_NON_BACK_TO_BACK_IPG_2_SHIFT)
+		 & IPGIFG_NON_BACK_TO_BACK_IPG_2)
+	       | ((cfg->min_ifg_enforcement << IPGIFG_MIN_IFG_ENFORCEMENT_SHIFT)
+		 & IPGIFG_MIN_IFG_ENFORCEMENT)
+	       | (cfg->back_to_back_ipg & IPGIFG_BACK_TO_BACK_IPG));
+	iowrite32be(tmp, &regs->ipgifg);
+
+	/*IPGIFG*/
+
+	/*HAFDUP*/
+	tmp = 0;
+
+	if (cfg->halfdup_alt_backoff_en)
+		tmp = (uint32_t)(HAFDUP_ALT_BEB |
+				  ((cfg->halfdup_alt_backoff_val & 0x0000000f)
+				   << HAFDUP_ALTERNATE_BEB_TRUNCATION_SHIFT));
+	if (cfg->halfdup_bp_no_backoff)
+		tmp |= HAFDUP_BP_NO_BACKOFF;
+	if (cfg->halfdup_no_backoff)
+		tmp |= HAFDUP_NO_BACKOFF;
+	if (cfg->halfdup_excess_defer)
+		tmp |= HAFDUP_EXCESS_DEFER;
+	tmp |= ((cfg->halfdup_retransmit << HAFDUP_RETRANSMISSION_MAX_SHIFT)
+		& HAFDUP_RETRANSMISSION_MAX);
+	tmp |= (cfg->halfdup_coll_window & HAFDUP_COLLISION_WINDOW);
+
+	iowrite32be(tmp, &regs->hafdup);
+	/*HAFDUP*/
+
+	/*MAXFRM*/
+	/* Initialize MAXFRM */
+	iowrite32be(cfg->maximum_frame, &regs->maxfrm);
+
+	/*MAXFRM*/
+
+	/*CAM1*/
+	iowrite32be(0xffffffff, &regs->cam1);
+	iowrite32be(0xffffffff, &regs->cam2);
+
+	/*IMASK*/
+	iowrite32be(exception_mask, &regs->imask);
+	/*IMASK*/
+
+	/*IEVENT*/
+	iowrite32be(0xffffffff, &regs->ievent);
+
+	/*MACSTNADDR1/2*/
+
+	tmp = (uint32_t)((macaddr[5] << 24) |
+			  (macaddr[4] << 16) | (macaddr[3] << 8) | macaddr[2]);
+	iowrite32be(tmp, &regs->macstnaddr1);
+
+	tmp = (uint32_t)((macaddr[1] << 24) | (macaddr[0] << 16));
+	iowrite32be(tmp, &regs->macstnaddr2);
+
+	/*MACSTNADDR1/2*/
+
+	/*HASH*/
+	for (i = 0; i < NUM_OF_HASH_REGS; i++) {
+		/* Initialize IADDRx */
+		iowrite32be(0, &regs->igaddr[i]);
+		/* Initialize GADDRx */
+		iowrite32be(0, &regs->gaddr[i]);
+	}
+
+	return 0;
+}
+
+uint16_t fman_dtsec_get_max_frame_len(struct dtsec_regs __iomem *regs)
+{
+	return (uint16_t)ioread32be(&regs->maxfrm);
+}
+
+void fman_dtsec_set_max_frame_len(struct dtsec_regs __iomem *regs,
+				  uint16_t length)
+{
+	iowrite32be(length, &regs->maxfrm);
+}
+
+void fman_dtsec_set_mac_address(struct dtsec_regs __iomem *regs, uint8_t *adr)
+{
+	uint32_t tmp;
+
+	tmp = (uint32_t)((adr[5] << 24) |
+			  (adr[4] << 16) | (adr[3] << 8) | adr[2]);
+	iowrite32be(tmp, &regs->macstnaddr1);
+
+	tmp = (uint32_t)((adr[1] << 24) | (adr[0] << 16));
+	iowrite32be(tmp, &regs->macstnaddr2);
+}
+
+void fman_dtsec_get_mac_address(struct dtsec_regs __iomem *regs,
+				uint8_t *macaddr)
+{
+	uint32_t tmp1, tmp2;
+
+	tmp1 = ioread32be(&regs->macstnaddr1);
+	tmp2 = ioread32be(&regs->macstnaddr2);
+
+	macaddr[0] = (uint8_t)((tmp2 & 0x00ff0000) >> 16);
+	macaddr[1] = (uint8_t)((tmp2 & 0xff000000) >> 24);
+	macaddr[2] = (uint8_t)(tmp1 & 0x000000ff);
+	macaddr[3] = (uint8_t)((tmp1 & 0x0000ff00) >> 8);
+	macaddr[4] = (uint8_t)((tmp1 & 0x00ff0000) >> 16);
+	macaddr[5] = (uint8_t)((tmp1 & 0xff000000) >> 24);
+}
+
+void fman_dtsec_set_bucket(struct dtsec_regs __iomem *regs, int bucket,
+			   bool enable)
+{
+	int reg_idx = (bucket >> 5) & 0xf;
+	int bit_idx = bucket & 0x1f;
+	uint32_t bit_mask = 0x80000000 >> bit_idx;
+	uint32_t __iomem *reg;
+
+	if (reg_idx > 7)
+		reg = &regs->gaddr[reg_idx - 8];
+	else
+		reg = &regs->igaddr[reg_idx];
+
+	if (enable)
+		iowrite32be(ioread32be(reg) | bit_mask, reg);
+	else
+		iowrite32be(ioread32be(reg) & (~bit_mask), reg);
+}
+
+int fman_dtsec_adjust_link(struct dtsec_regs __iomem *regs,
+			   enum enet_interface __maybe_unused iface_mode,
+			   enum enet_speed speed, bool full_dx)
+{
+	uint32_t tmp;
+
+	if ((speed == E_ENET_SPEED_1000) && !full_dx)
+		return -EINVAL;
+
+	tmp = ioread32be(&regs->maccfg2);
+	if (!full_dx)
+		tmp &= ~MACCFG2_FULL_DUPLEX;
+	else
+		tmp |= MACCFG2_FULL_DUPLEX;
+
+	tmp &= ~(MACCFG2_NIBBLE_MODE | MACCFG2_BYTE_MODE);
+	if (speed < E_ENET_SPEED_1000)
+		tmp |= MACCFG2_NIBBLE_MODE;
+	else if (speed == E_ENET_SPEED_1000)
+		tmp |= MACCFG2_BYTE_MODE;
+	iowrite32be(tmp, &regs->maccfg2);
+
+	tmp = ioread32be(&regs->ecntrl);
+	if (speed == E_ENET_SPEED_100)
+		tmp |= DTSEC_ECNTRL_R100M;
+	else
+		tmp &= ~DTSEC_ECNTRL_R100M;
+	iowrite32be(tmp, &regs->ecntrl);
+
+	return 0;
+}
+
+void fman_dtsec_set_uc_promisc(struct dtsec_regs __iomem *regs, bool enable)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->rctrl);
+
+	if (enable)
+		tmp |= RCTRL_UPROM;
+	else
+		tmp &= ~RCTRL_UPROM;
+
+	iowrite32be(tmp, &regs->rctrl);
+}
+
+void fman_dtsec_set_mc_promisc(struct dtsec_regs __iomem *regs, bool enable)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->rctrl);
+
+	if (enable)
+		tmp |= RCTRL_MPROM;
+	else
+		tmp &= ~RCTRL_MPROM;
+
+	iowrite32be(tmp, &regs->rctrl);
+}
+
+void fman_dtsec_enable(struct dtsec_regs __iomem *regs, bool apply_rx,
+		       bool apply_tx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->maccfg1);
+
+	if (apply_rx)
+		tmp |= MACCFG1_RX_EN;
+
+	if (apply_tx)
+		tmp |= MACCFG1_TX_EN;
+
+	iowrite32be(tmp, &regs->maccfg1);
+}
+
+void fman_dtsec_disable(struct dtsec_regs __iomem *regs, bool apply_rx,
+			bool apply_tx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->maccfg1);
+
+	if (apply_rx)
+		tmp &= ~MACCFG1_RX_EN;
+
+	if (apply_tx)
+		tmp &= ~MACCFG1_TX_EN;
+
+	iowrite32be(tmp, &regs->maccfg1);
+}
+
+void fman_dtsec_set_tx_pause_frames(struct dtsec_regs __iomem *regs,
+				    uint16_t time)
+{
+	uint32_t ptv = 0;
+
+	/* fixme: don't enable tx pause for half-duplex */
+
+	if (time) {
+		ptv = ioread32be(&regs->ptv);
+		ptv &= 0xffff0000;
+		ptv |= time & 0x0000ffff;
+		iowrite32be(ptv, &regs->ptv);
+
+		/* trigger the transmission of a flow-control pause frame */
+		iowrite32be(ioread32be(&regs->maccfg1) | MACCFG1_TX_FLOW,
+			    &regs->maccfg1);
+	} else
+		iowrite32be(ioread32be(&regs->maccfg1) & ~MACCFG1_TX_FLOW,
+			    &regs->maccfg1);
+}
+
+void fman_dtsec_handle_rx_pause(struct dtsec_regs __iomem *regs, bool en)
+{
+	uint32_t tmp;
+
+	/* todo: check if mac is set to full-duplex */
+
+	tmp = ioread32be(&regs->maccfg1);
+	if (en)
+		tmp |= MACCFG1_RX_FLOW;
+	else
+		tmp &= ~MACCFG1_RX_FLOW;
+	iowrite32be(tmp, &regs->maccfg1);
+}
+
+uint32_t fman_dtsec_get_rctrl(struct dtsec_regs __iomem *regs)
+{
+	return ioread32be(&regs->rctrl);
+}
+
+uint32_t fman_dtsec_get_revision(struct dtsec_regs __iomem *regs)
+{
+	return ioread32be(&regs->tsec_id);
+}
+
+uint32_t fman_dtsec_get_event(struct dtsec_regs __iomem *regs,
+			      uint32_t ev_mask)
+{
+	return ioread32be(&regs->ievent) & ev_mask;
+}
+
+void fman_dtsec_ack_event(struct dtsec_regs __iomem *regs, uint32_t ev_mask)
+{
+	iowrite32be(ev_mask, &regs->ievent);
+}
+
+uint32_t fman_dtsec_get_interrupt_mask(struct dtsec_regs __iomem *regs)
+{
+	return ioread32be(&regs->imask);
+}
+
+uint32_t fman_dtsec_check_and_clear_tmr_event(struct dtsec_regs __iomem *regs)
+{
+	uint32_t event;
+
+	event = ioread32be(&regs->tmr_pevent);
+	event &= ioread32be(&regs->tmr_pemask);
+
+	if (event)
+		iowrite32be(event, &regs->tmr_pevent);
+	return event;
+}
+
+void fman_dtsec_enable_tmr_interrupt(struct dtsec_regs __iomem *regs)
+{
+	iowrite32be(ioread32be(&regs->tmr_pemask) | TMR_PEMASK_TSREEN,
+		    &regs->tmr_pemask);
+}
+
+void fman_dtsec_disable_tmr_interrupt(struct dtsec_regs __iomem *regs)
+{
+	iowrite32be(ioread32be(&regs->tmr_pemask) & ~TMR_PEMASK_TSREEN,
+		    &regs->tmr_pemask);
+}
+
+void fman_dtsec_enable_interrupt(struct dtsec_regs __iomem *regs,
+				 uint32_t ev_mask)
+{
+	iowrite32be(ioread32be(&regs->imask) | ev_mask, &regs->imask);
+}
+
+void fman_dtsec_disable_interrupt(struct dtsec_regs __iomem *regs,
+				  uint32_t ev_mask)
+{
+	iowrite32be(ioread32be(&regs->imask) & ~ev_mask, &regs->imask);
+}
diff --git a/drivers/net/ethernet/freescale/fman/mac/fman_dtsec_mii_acc.c b/drivers/net/ethernet/freescale/fman/mac/fman_dtsec_mii_acc.c
new file mode 100644
index 0000000..c393938
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/fman_dtsec_mii_acc.c
@@ -0,0 +1,168 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "common/general.h"
+#include "fsl_fman_dtsec_mii_acc.h"
+
+/*dtsec_mii_get_div() - calculates the value of the dtsec mii divider
+ *@dtsec_freq:		dtsec clock frequency (in Mhz)
+ *This function calculates the dtsec mii clock divider that determines
+ *the MII MDC clock. MII MDC clock will be set to work in the range
+ *of 1.5 to 2.5Mhz
+ *The output of this function is the value of MIIMCFG[MgmtClk] which
+ *implicitly determines the divider value.
+ *Note: the dTSEC system clock is equal to 1/2 of the FMan clock.
+ *The table below which reflects dtsec_mii_get_div() functionality
+ *shows the relations among dtsec_freq, MgmtClk, actual divider
+ *and the MII frequency:
+ *dtsec freq   MgmtClk	   div	      MII freq Mhz
+ *[0.....80]	 1	(1/4)(1/8)    [0   to 2.5]
+ *[81...120]	 2	(1/6)(1/8)    [1.6 to 2.5]
+ *[121..160]	 3	(1/8)(1/8)    [1.8 to 2.5]
+ *[161..200]	 4	(1/10)(1/8)   [2.0 to 2.5]
+ *[201..280]	 5	(1/14)(1/8)   [1.8 to 2.5]
+ *[281..400]	 6	(1/20)(1/8)   [1.1 to 2.5]
+ *[401..560]	 7	(1/28)(1/8)   [1.8 to 2.5]
+ *[560..frq]	 7	(1/28)(1/8)   [frq/224]
+ *Returns: the MIIMCFG[MgmtClk] appropriate value
+ */
+
+static uint8_t dtsec_mii_get_div(uint16_t dtsec_freq)
+{
+	uint16_t mgmt_clk;
+
+	if (dtsec_freq < 80)
+		mgmt_clk = 1;
+	else if (dtsec_freq < 120)
+		mgmt_clk = 2;
+	else if (dtsec_freq < 160)
+		mgmt_clk = 3;
+	else if (dtsec_freq < 200)
+		mgmt_clk = 4;
+	else if (dtsec_freq < 280)
+		mgmt_clk = 5;
+	else if (dtsec_freq < 400)
+		mgmt_clk = 6;
+	else
+		mgmt_clk = 7;
+
+	return (uint8_t)mgmt_clk;
+}
+
+void fman_dtsec_mii_reset(struct dtsec_mii_reg __iomem *regs)
+{
+	/* Reset the management interface */
+	iowrite32be(ioread32be(&regs->miimcfg) | MIIMCFG_RESET_MGMT,
+		    &regs->miimcfg);
+	iowrite32be(ioread32be(&regs->miimcfg) & ~MIIMCFG_RESET_MGMT,
+		    &regs->miimcfg);
+}
+
+int fman_dtsec_mii_write_reg(struct dtsec_mii_reg __iomem *regs, uint8_t addr,
+			     uint8_t reg, uint16_t data, uint16_t dtsec_freq)
+{
+	uint32_t tmp;
+
+	/* Setup the MII Mgmt clock speed */
+	iowrite32be((uint32_t)dtsec_mii_get_div(dtsec_freq), &regs->miimcfg);
+	/* Memory barrier */
+	wmb();
+
+	/* Stop the MII management read cycle */
+	iowrite32be(0, &regs->miimcom);
+	/* Dummy read to make sure MIIMCOM is written */
+	tmp = ioread32be(&regs->miimcom);
+	/* Memory barrier */
+	wmb();
+
+	/* Setting up MII Management Address Register */
+	tmp = (uint32_t)((addr << MIIMADD_PHY_ADDR_SHIFT) | reg);
+	iowrite32be(tmp, &regs->miimadd);
+	/* Memory barrier */
+	wmb();
+
+	/* Setting up MII Management Control Register with data */
+	iowrite32be((uint32_t)data, &regs->miimcon);
+	/* Dummy read to make sure MIIMCON is written */
+	tmp = ioread32be(&regs->miimcon);
+	/* Memory barrier */
+	wmb();
+
+	/* Wait until MII management write is complete */
+	/* todo: a timeout could be useful here */
+	while ((ioread32be(&regs->miimind)) & MIIMIND_BUSY)
+		; /* busy wait */
+
+	return 0;
+}
+
+int fman_dtsec_mii_read_reg(struct dtsec_mii_reg __iomem *regs, uint8_t addr,
+			    uint8_t reg, uint16_t *data, uint16_t dtsec_freq)
+{
+	uint32_t tmp;
+
+	/* Setup the MII Mgmt clock speed */
+	iowrite32be((uint32_t)dtsec_mii_get_div(dtsec_freq), &regs->miimcfg);
+	/* Memory barrier */
+	wmb();
+
+	/* Setting up the MII Management Address Register */
+	tmp = (uint32_t)((addr << MIIMADD_PHY_ADDR_SHIFT) | reg);
+	iowrite32be(tmp, &regs->miimadd);
+	/* Memory barrier */
+	wmb();
+
+	/* Perform an MII management read cycle */
+	iowrite32be(MIIMCOM_READ_CYCLE, &regs->miimcom);
+	/* Dummy read to make sure MIIMCOM is written */
+	tmp = ioread32be(&regs->miimcom);
+	/* Memory barrier */
+	wmb();
+
+	/* Wait until MII management read is complete */
+	/* todo: a timeout could be useful here */
+	while ((ioread32be(&regs->miimind)) & MIIMIND_BUSY)
+		; /* busy wait */
+
+	/* Read MII management status  */
+	*data = (uint16_t)ioread32be(&regs->miimstat);
+	/* Memory barrier */
+	wmb();
+
+	iowrite32be(0, &regs->miimcom);
+	/* Dummy read to make sure MIIMCOM is written */
+	tmp = ioread32be(&regs->miimcom);
+
+	if (*data == 0xffff)
+		return -ENXIO;
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/freescale/fman/mac/fman_memac.c b/drivers/net/ethernet/freescale/fman/mac/fman_memac.c
new file mode 100644
index 0000000..e0bac5a
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/fman_memac.c
@@ -0,0 +1,365 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "fsl_fman_memac.h"
+
+uint32_t fman_memac_get_event(struct memac_regs __iomem *regs, uint32_t ev_mask)
+{
+	return ioread32be(&regs->ievent) & ev_mask;
+}
+
+uint32_t fman_memac_get_interrupt_mask(struct memac_regs __iomem *regs)
+{
+	return ioread32be(&regs->imask);
+}
+
+void fman_memac_ack_event(struct memac_regs __iomem *regs, uint32_t ev_mask)
+{
+	iowrite32be(ev_mask, &regs->ievent);
+}
+
+void fman_memac_set_promiscuous(struct memac_regs __iomem *regs, bool val)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+
+	if (val)
+		tmp |= CMD_CFG_PROMIS_EN;
+	else
+		tmp &= ~CMD_CFG_PROMIS_EN;
+
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_memac_clear_addr_in_paddr(struct memac_regs __iomem *regs,
+				    uint8_t paddr_num)
+{
+	if (paddr_num == 0) {
+		iowrite32be(0, &regs->mac_addr0.mac_addr_l);
+		iowrite32be(0, &regs->mac_addr0.mac_addr_u);
+	} else {
+		iowrite32be(0x0, &regs->mac_addr[paddr_num - 1].mac_addr_l);
+		iowrite32be(0x0, &regs->mac_addr[paddr_num - 1].mac_addr_u);
+	}
+}
+
+void fman_memac_add_addr_in_paddr(struct memac_regs __iomem *regs,
+				  uint8_t *adr, uint8_t paddr_num)
+{
+	uint32_t tmp0, tmp1;
+
+	tmp0 = (uint32_t)(adr[0] | adr[1] << 8 | adr[2] << 16 | adr[3] << 24);
+	tmp1 = (uint32_t)(adr[4] | adr[5] << 8);
+
+	if (paddr_num == 0) {
+		iowrite32be(tmp0, &regs->mac_addr0.mac_addr_l);
+		iowrite32be(tmp1, &regs->mac_addr0.mac_addr_u);
+	} else {
+		iowrite32be(tmp0, &regs->mac_addr[paddr_num - 1].mac_addr_l);
+		iowrite32be(tmp1, &regs->mac_addr[paddr_num - 1].mac_addr_u);
+	}
+}
+
+void fman_memac_enable(struct memac_regs __iomem *regs, bool apply_rx,
+		       bool apply_tx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+
+	if (apply_rx)
+		tmp |= CMD_CFG_RX_EN;
+
+	if (apply_tx)
+		tmp |= CMD_CFG_TX_EN;
+
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_memac_disable(struct memac_regs __iomem *regs, bool apply_rx,
+			bool apply_tx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+
+	if (apply_rx)
+		tmp &= ~CMD_CFG_RX_EN;
+
+	if (apply_tx)
+		tmp &= ~CMD_CFG_TX_EN;
+
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_memac_reset(struct memac_regs __iomem *regs)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+
+	tmp |= CMD_CFG_SW_RESET;
+
+	iowrite32be(tmp, &regs->command_config);
+
+	while (ioread32be(&regs->command_config) & CMD_CFG_SW_RESET)
+		;
+}
+
+int fman_memac_init(struct memac_regs __iomem *regs,
+		    struct memac_cfg *cfg,
+		    enum enet_interface enet_interface,
+		    enum enet_speed enet_speed,
+		    bool slow_10g_if,
+		    uint32_t exceptions)
+{
+	uint32_t tmp;
+
+	/* Config */
+	tmp = 0;
+	if (cfg->wan_mode_enable)
+		tmp |= CMD_CFG_WAN_MODE;
+	if (cfg->promiscuous_mode_enable)
+		tmp |= CMD_CFG_PROMIS_EN;
+	if (cfg->pause_forward_enable)
+		tmp |= CMD_CFG_PAUSE_FWD;
+	if (cfg->pause_ignore)
+		tmp |= CMD_CFG_PAUSE_IGNORE;
+	if (cfg->tx_addr_ins_enable)
+		tmp |= CMD_CFG_TX_ADDR_INS;
+	if (cfg->loopback_enable)
+		tmp |= CMD_CFG_LOOPBACK_EN;
+	if (cfg->cmd_frame_enable)
+		tmp |= CMD_CFG_CNT_FRM_EN;
+	if (cfg->send_idle_enable)
+		tmp |= CMD_CFG_SEND_IDLE;
+	if (cfg->no_length_check_enable)
+		tmp |= CMD_CFG_NO_LEN_CHK;
+	if (cfg->rx_sfd_any)
+		tmp |= CMD_CFG_SFD_ANY;
+	if (cfg->pad_enable)
+		tmp |= CMD_CFG_TX_PAD_EN;
+	if (cfg->wake_on_lan)
+		tmp |= CMD_CFG_MG;
+
+	tmp |= CMD_CFG_CRC_FWD;
+
+	iowrite32be(tmp, &regs->command_config);
+
+	/* Max Frame Length */
+	iowrite32be((uint32_t)cfg->max_frame_length, &regs->maxfrm);
+
+	/* Pause Time */
+	iowrite32be((uint32_t)cfg->pause_quanta, &regs->pause_quanta[0]);
+	iowrite32be((uint32_t)0, &regs->pause_thresh[0]);
+
+	/* IF_MODE */
+	tmp = 0;
+	switch (enet_interface) {
+	case E_ENET_IF_XGMII:
+	case E_ENET_IF_XFI:
+		tmp |= IF_MODE_XGMII;
+		break;
+	default:
+		tmp |= IF_MODE_GMII;
+		if (enet_interface == E_ENET_IF_RGMII && !cfg->loopback_enable)
+			tmp |= IF_MODE_RGMII | IF_MODE_RGMII_AUTO;
+	}
+	iowrite32be(tmp, &regs->if_mode);
+
+	/* TX_FIFO_SECTIONS */
+	tmp = 0;
+	if (enet_interface == E_ENET_IF_XGMII ||
+	    enet_interface == E_ENET_IF_XFI) {
+		if (slow_10g_if) {
+			tmp |= (TX_FIFO_SECTIONS_TX_AVAIL_SLOW_10G |
+				TX_FIFO_SECTIONS_TX_EMPTY_DEFAULT_10G);
+		} else {
+			tmp |= (TX_FIFO_SECTIONS_TX_AVAIL_10G |
+				TX_FIFO_SECTIONS_TX_EMPTY_DEFAULT_10G);
+		}
+	} else {
+		tmp |= (TX_FIFO_SECTIONS_TX_AVAIL_1G |
+			TX_FIFO_SECTIONS_TX_EMPTY_DEFAULT_1G);
+	}
+	iowrite32be(tmp, &regs->tx_fifo_sections);
+
+	/* clear all pending events and set-up interrupts */
+	fman_memac_ack_event(regs, 0xffffffff);
+	fman_memac_set_exception(regs, exceptions, true);
+
+	return 0;
+}
+
+void fman_memac_set_exception(struct memac_regs __iomem *regs, uint32_t val,
+			      bool enable)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->imask);
+	if (enable)
+		tmp |= val;
+	else
+		tmp &= ~val;
+
+	iowrite32be(tmp, &regs->imask);
+}
+
+void fman_memac_set_hash_table(struct memac_regs __iomem *regs, uint32_t val)
+{
+	iowrite32be(val, &regs->hashtable_ctrl);
+}
+
+uint16_t fman_memac_get_max_frame_len(struct memac_regs __iomem *regs)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->maxfrm);
+
+	return (uint16_t)tmp;
+}
+
+void fman_memac_set_tx_pause_frames(struct memac_regs __iomem *regs,
+				    uint8_t priority,
+				    uint16_t pause_time, uint16_t thresh_time)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->tx_fifo_sections);
+
+	GET_TX_EMPTY_DEFAULT_VALUE(tmp);
+	iowrite32be(tmp, &regs->tx_fifo_sections);
+
+	tmp = ioread32be(&regs->command_config);
+	tmp &= ~CMD_CFG_PFC_MODE;
+	priority = 0;
+
+	iowrite32be(tmp, &regs->command_config);
+
+	tmp = ioread32be(&regs->pause_quanta[priority / 2]);
+	if (priority % 2)
+		tmp &= 0x0000FFFF;
+	else
+		tmp &= 0xFFFF0000;
+	tmp |= ((uint32_t)pause_time << (16 * (priority % 2)));
+	iowrite32be(tmp, &regs->pause_quanta[priority / 2]);
+
+	tmp = ioread32be(&regs->pause_thresh[priority / 2]);
+	if (priority % 2)
+		tmp &= 0x0000FFFF;
+	else
+		tmp &= 0xFFFF0000;
+	tmp |= ((uint32_t)thresh_time << (16 * (priority % 2)));
+	iowrite32be(tmp, &regs->pause_thresh[priority / 2]);
+}
+
+void fman_memac_set_rx_ignore_pause_frames(struct memac_regs __iomem *regs,
+					   bool enable)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+	if (enable)
+		tmp |= CMD_CFG_PAUSE_IGNORE;
+	else
+		tmp &= ~CMD_CFG_PAUSE_IGNORE;
+
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_memac_adjust_link(struct memac_regs __iomem *regs,
+			    enum enet_interface iface_mode,
+			    enum enet_speed speed, bool full_dx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->if_mode);
+
+	if (full_dx)
+		tmp &= ~IF_MODE_HD;
+	else
+		tmp |= IF_MODE_HD;
+
+	if (iface_mode == E_ENET_IF_RGMII) {
+		/* Configure RGMII in manual mode */
+		tmp &= ~IF_MODE_RGMII_AUTO;
+		tmp &= ~IF_MODE_RGMII_SP_MASK;
+
+		if (full_dx)
+			tmp |= IF_MODE_RGMII_FD;
+		else
+			tmp &= ~IF_MODE_RGMII_FD;
+
+		switch (speed) {
+		case E_ENET_SPEED_1000:
+			tmp |= IF_MODE_RGMII_1000;
+			break;
+		case E_ENET_SPEED_100:
+			tmp |= IF_MODE_RGMII_100;
+			break;
+		case E_ENET_SPEED_10:
+			tmp |= IF_MODE_RGMII_10;
+			break;
+		default:
+			break;
+		}
+	}
+
+	iowrite32be(tmp, &regs->if_mode);
+}
+
+void fman_memac_defconfig(struct memac_cfg *cfg)
+{
+	cfg->reset_on_init = false;
+	cfg->wan_mode_enable = false;
+	cfg->promiscuous_mode_enable = false;
+	cfg->pause_forward_enable = false;
+	cfg->pause_ignore = false;
+	cfg->tx_addr_ins_enable = false;
+	cfg->loopback_enable = false;
+	cfg->cmd_frame_enable = false;
+	cfg->rx_error_discard = false;
+	cfg->send_idle_enable = false;
+	cfg->no_length_check_enable = true;
+	cfg->lgth_check_nostdr = false;
+	cfg->time_stamp_enable = false;
+	cfg->tx_ipg_length = DEFAULT_TX_IPG_LENGTH;
+	cfg->max_frame_length = DEFAULT_FRAME_LENGTH;
+	cfg->pause_quanta = DEFAULT_PAUSE_QUANTA;
+	cfg->pad_enable = true;
+	cfg->phy_tx_ena_on = false;
+	cfg->rx_sfd_any = false;
+	cfg->rx_pbl_fwd = false;
+	cfg->tx_pbl_fwd = false;
+	cfg->debug_mode = false;
+	cfg->wake_on_lan = false;
+}
diff --git a/drivers/net/ethernet/freescale/fman/mac/fman_memac_mii_acc.c b/drivers/net/ethernet/freescale/fman/mac/fman_memac_mii_acc.c
new file mode 100644
index 0000000..7addd6d
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/fman_memac_mii_acc.c
@@ -0,0 +1,217 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "fsl_fman_memac_mii_acc.h"
+
+static void write_phy_reg_10g(struct memac_mii_access_mem_map __iomem *mii_regs,
+			      uint8_t phy_addr, uint8_t reg, uint16_t data)
+{
+	uint32_t tmp_reg;
+
+	tmp_reg = ioread32be(&mii_regs->mdio_cfg);
+	/* Leave only MDIO_CLK_DIV bits set on */
+	tmp_reg &= MDIO_CFG_CLK_DIV_MASK;
+	/* Set maximum MDIO_HOLD value to allow phy to see
+	 * change of data signal
+	 **/
+	tmp_reg |= MDIO_CFG_HOLD_MASK;
+	/* Add 10G interface mode */
+	tmp_reg |= MDIO_CFG_ENC45;
+	iowrite32be(tmp_reg, &mii_regs->mdio_cfg);
+
+	/* Wait for command completion */
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Specify phy and register to be accessed */
+	iowrite32be(phy_addr, &mii_regs->mdio_ctrl);
+	iowrite32be(reg, &mii_regs->mdio_addr);
+	/* memory barrier */
+	wmb();
+
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Write data */
+	iowrite32be(data, &mii_regs->mdio_data);
+	/* memory barrier */
+	wmb();
+
+	/* Wait for write transaction end */
+	while ((ioread32be(&mii_regs->mdio_data)) & MDIO_DATA_BSY)
+		udelay(1);
+}
+
+static uint32_t read_phy_reg_10g(struct memac_mii_access_mem_map __iomem
+				 *mii_regs, uint8_t phy_addr, uint8_t reg,
+				 uint16_t *data)
+{
+	uint32_t tmp_reg;
+
+	tmp_reg = ioread32be(&mii_regs->mdio_cfg);
+	/* Leave only MDIO_CLK_DIV bits set on */
+	tmp_reg &= MDIO_CFG_CLK_DIV_MASK;
+	/* Set maximum MDIO_HOLD value to allow phy to see
+	 * change of data signal
+	 **/
+	tmp_reg |= MDIO_CFG_HOLD_MASK;
+	/* Add 10G interface mode */
+	tmp_reg |= MDIO_CFG_ENC45;
+	iowrite32be(tmp_reg, &mii_regs->mdio_cfg);
+
+	/* Wait for command completion */
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Specify phy and register to be accessed */
+	iowrite32be(phy_addr, &mii_regs->mdio_ctrl);
+	iowrite32be(reg, &mii_regs->mdio_addr);
+	/* memory barrier */
+	wmb();
+
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Read cycle */
+	tmp_reg = phy_addr;
+	tmp_reg |= MDIO_CTL_READ;
+	iowrite32be(tmp_reg, &mii_regs->mdio_ctrl);
+	/* memory barrier */
+	wmb();
+
+	/* Wait for data to be available */
+	while ((ioread32be(&mii_regs->mdio_data)) & MDIO_DATA_BSY)
+		udelay(1);
+
+	*data = (uint16_t)ioread32be(&mii_regs->mdio_data);
+
+	/* Check if there was an error */
+	return ioread32be(&mii_regs->mdio_cfg);
+}
+
+static void write_phy_reg_1g(struct memac_mii_access_mem_map __iomem *mii_regs,
+			     uint8_t phy_addr, uint8_t reg, uint16_t data)
+{
+	uint32_t tmp_reg;
+
+	/* Leave only MDIO_CLK_DIV and MDIO_HOLD bits set on */
+	tmp_reg = ioread32be(&mii_regs->mdio_cfg);
+	tmp_reg &= (MDIO_CFG_CLK_DIV_MASK | MDIO_CFG_HOLD_MASK);
+	iowrite32be(tmp_reg, &mii_regs->mdio_cfg);
+
+	/* Wait for command completion */
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Write transaction */
+	tmp_reg = (phy_addr << MDIO_CTL_PHY_ADDR_SHIFT);
+	tmp_reg |= reg;
+	iowrite32be(tmp_reg, &mii_regs->mdio_ctrl);
+
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	iowrite32be(data, &mii_regs->mdio_data);
+
+	/* memory barrier */
+	wmb();
+
+	/* Wait for write transaction to end */
+	while ((ioread32be(&mii_regs->mdio_data)) & MDIO_DATA_BSY)
+		udelay(1);
+}
+
+static uint32_t read_phy_reg_1g(struct memac_mii_access_mem_map __iomem
+				*mii_regs, uint8_t phy_addr, uint8_t reg,
+				uint16_t *data)
+{
+	uint32_t tmp_reg;
+
+	/* Leave only MDIO_CLK_DIV and MDIO_HOLD bits set on */
+	tmp_reg = ioread32be(&mii_regs->mdio_cfg);
+	tmp_reg &= (MDIO_CFG_CLK_DIV_MASK | MDIO_CFG_HOLD_MASK);
+	iowrite32be(tmp_reg, &mii_regs->mdio_cfg);
+
+	/* Wait for command completion */
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Read transaction */
+	tmp_reg = (phy_addr << MDIO_CTL_PHY_ADDR_SHIFT);
+	tmp_reg |= reg;
+	tmp_reg |= MDIO_CTL_READ;
+	iowrite32be(tmp_reg, &mii_regs->mdio_ctrl);
+
+	while ((ioread32be(&mii_regs->mdio_cfg)) & MDIO_CFG_BSY)
+		udelay(1);
+
+	/* Wait for data to be available */
+	while ((ioread32be(&mii_regs->mdio_data)) & MDIO_DATA_BSY)
+		udelay(1);
+
+	*data = (uint16_t)ioread32be(&mii_regs->mdio_data);
+
+	/* Check error */
+	return ioread32be(&mii_regs->mdio_cfg);
+}
+
+int fman_memac_mii_write_phy_reg(struct memac_mii_access_mem_map __iomem
+				 *mii_regs, uint8_t phy_addr, uint8_t reg,
+				 uint16_t data, enum enet_speed enet_speed)
+{
+	/* Figure out interface type - 10G vs 1G.
+	 * In 10G interface both phy_addr and devAddr present.
+	 **/
+	if (enet_speed == E_ENET_SPEED_10000)
+		write_phy_reg_10g(mii_regs, phy_addr, reg, data);
+	else
+		write_phy_reg_1g(mii_regs, phy_addr, reg, data);
+
+	return 0;
+}
+
+int fman_memac_mii_read_phy_reg(struct memac_mii_access_mem_map __iomem
+				*mii_regs, uint8_t phy_addr, uint8_t reg,
+				uint16_t *data, enum enet_speed enet_speed)
+{
+	uint32_t ans;
+	/* Figure out interface type - 10G vs 1G.
+	 * In 10G interface both phy_addr and devAddr present.
+	 **/
+	if (enet_speed == E_ENET_SPEED_10000)
+		ans = read_phy_reg_10g(mii_regs, phy_addr, reg, data);
+	else
+		ans = read_phy_reg_1g(mii_regs, phy_addr, reg, data);
+
+	if (ans & MDIO_CFG_READ_ERR)
+		return -EINVAL;
+	return 0;
+}
diff --git a/drivers/net/ethernet/freescale/fman/mac/fman_tgec.c b/drivers/net/ethernet/freescale/fman/mac/fman_tgec.c
new file mode 100644
index 0000000..11bcc1a
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/mac/fman_tgec.c
@@ -0,0 +1,217 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "fsl_fman_tgec.h"
+
+void fman_tgec_set_mac_address(struct tgec_regs __iomem *regs, uint8_t *adr)
+{
+	uint32_t tmp0, tmp1;
+
+	tmp0 = (uint32_t)(adr[0] | adr[1] << 8 | adr[2] << 16 | adr[3] << 24);
+	tmp1 = (uint32_t)(adr[4] | adr[5] << 8);
+	iowrite32be(tmp0, &regs->mac_addr_0);
+	iowrite32be(tmp1, &regs->mac_addr_1);
+}
+
+void fman_tgec_enable(struct tgec_regs __iomem *regs, bool apply_rx,
+		      bool apply_tx)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+	if (apply_rx)
+		tmp |= CMD_CFG_RX_EN;
+	if (apply_tx)
+		tmp |= CMD_CFG_TX_EN;
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_tgec_disable(struct tgec_regs __iomem *regs, bool apply_rx,
+		       bool apply_tx)
+{
+	uint32_t tmp_reg_32;
+
+	tmp_reg_32 = ioread32be(&regs->command_config);
+	if (apply_rx)
+		tmp_reg_32 &= ~CMD_CFG_RX_EN;
+	if (apply_tx)
+		tmp_reg_32 &= ~CMD_CFG_TX_EN;
+	iowrite32be(tmp_reg_32, &regs->command_config);
+}
+
+void fman_tgec_set_promiscuous(struct tgec_regs __iomem *regs, bool val)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+	if (val)
+		tmp |= CMD_CFG_PROMIS_EN;
+	else
+		tmp &= ~CMD_CFG_PROMIS_EN;
+	iowrite32be(tmp, &regs->command_config);
+}
+
+void fman_tgec_set_hash_table(struct tgec_regs __iomem *regs, uint32_t value)
+{
+	iowrite32be(value, &regs->hashtable_ctrl);
+}
+
+void fman_tgec_set_tx_pause_frames(struct tgec_regs __iomem *regs,
+				   uint16_t pause_time)
+{
+	iowrite32be((uint32_t)pause_time, &regs->pause_quant);
+}
+
+void fman_tgec_set_rx_ignore_pause_frames(struct tgec_regs __iomem *regs,
+					  bool en)
+{
+	uint32_t tmp;
+
+	tmp = ioread32be(&regs->command_config);
+	if (en)
+		tmp |= CMD_CFG_PAUSE_IGNORE;
+	else
+		tmp &= ~CMD_CFG_PAUSE_IGNORE;
+	iowrite32be(tmp, &regs->command_config);
+}
+
+uint32_t fman_tgec_get_event(struct tgec_regs __iomem *regs, uint32_t ev_mask)
+{
+	return ioread32be(&regs->ievent) & ev_mask;
+}
+
+void fman_tgec_ack_event(struct tgec_regs __iomem *regs, uint32_t ev_mask)
+{
+	iowrite32be(ev_mask, &regs->ievent);
+}
+
+uint32_t fman_tgec_get_interrupt_mask(struct tgec_regs __iomem *regs)
+{
+	return ioread32be(&regs->imask);
+}
+
+uint32_t fman_tgec_get_revision(struct tgec_regs __iomem *regs)
+{
+	return ioread32be(&regs->tgec_id);
+}
+
+void fman_tgec_enable_interrupt(struct tgec_regs __iomem *regs,
+				uint32_t ev_mask)
+{
+	iowrite32be(ioread32be(&regs->imask) | ev_mask, &regs->imask);
+}
+
+void fman_tgec_disable_interrupt(struct tgec_regs __iomem *regs,
+				 uint32_t ev_mask)
+{
+	iowrite32be(ioread32be(&regs->imask) & ~ev_mask, &regs->imask);
+}
+
+uint16_t fman_tgec_get_max_frame_len(struct tgec_regs __iomem *regs)
+{
+	return (uint16_t)ioread32be(&regs->maxfrm);
+}
+
+void fman_tgec_defconfig(struct tgec_cfg *cfg)
+{
+	cfg->wan_mode_enable = DEFAULT_WAN_MODE_ENABLE;
+	cfg->promiscuous_mode_enable = DEFAULT_PROMISCUOUS_MODE_ENABLE;
+	cfg->pause_forward_enable = DEFAULT_PAUSE_FORWARD_ENABLE;
+	cfg->pause_ignore = DEFAULT_PAUSE_IGNORE;
+	cfg->tx_addr_ins_enable = DEFAULT_TX_ADDR_INS_ENABLE;
+	cfg->loopback_enable = DEFAULT_LOOPBACK_ENABLE;
+	cfg->cmd_frame_enable = DEFAULT_CMD_FRAME_ENABLE;
+	cfg->rx_error_discard = DEFAULT_RX_ERROR_DISCARD;
+	cfg->send_idle_enable = DEFAULT_SEND_IDLE_ENABLE;
+	cfg->no_length_check_enable = DEFAULT_NO_LENGTH_CHECK_ENABLE;
+	cfg->lgth_check_nostdr = DEFAULT_LGTH_CHECK_NOSTDR;
+	cfg->time_stamp_enable = DEFAULT_TIME_STAMP_ENABLE;
+	cfg->tx_ipg_length = DEFAULT_TX_IPG_LENGTH;
+	cfg->max_frame_length = DEFAULT_MAX_FRAME_LENGTH;
+	cfg->pause_quant = DEFAULT_PAUSE_QUANT;
+#ifdef FM_TX_ECC_FRMS_ERRATA_10GMAC_A004
+	cfg->skip_fman11_workaround = false;
+#endif /* FM_TX_ECC_FRMS_ERRATA_10GMAC_A004 */
+}
+
+int fman_tgec_init(struct tgec_regs __iomem *regs, struct tgec_cfg *cfg,
+		   uint32_t exception_mask)
+{
+	uint32_t tmp;
+
+	/* Config */
+	tmp = 0x40;		/* CRC forward */
+	if (cfg->wan_mode_enable)
+		tmp |= CMD_CFG_WAN_MODE;
+	if (cfg->promiscuous_mode_enable)
+		tmp |= CMD_CFG_PROMIS_EN;
+	if (cfg->pause_forward_enable)
+		tmp |= CMD_CFG_PAUSE_FWD;
+	if (cfg->pause_ignore)
+		tmp |= CMD_CFG_PAUSE_IGNORE;
+	if (cfg->tx_addr_ins_enable)
+		tmp |= CMD_CFG_TX_ADDR_INS;
+	if (cfg->loopback_enable)
+		tmp |= CMD_CFG_LOOPBACK_EN;
+	if (cfg->cmd_frame_enable)
+		tmp |= CMD_CFG_CMD_FRM_EN;
+	if (cfg->rx_error_discard)
+		tmp |= CMD_CFG_RX_ER_DISC;
+	if (cfg->send_idle_enable)
+		tmp |= CMD_CFG_SEND_IDLE;
+	if (cfg->no_length_check_enable)
+		tmp |= CMD_CFG_NO_LEN_CHK;
+	if (cfg->time_stamp_enable)
+		tmp |= CMD_CFG_EN_TIMESTAMP;
+	iowrite32be(tmp, &regs->command_config);
+
+	/* Max Frame Length */
+	iowrite32be((uint32_t)cfg->max_frame_length, &regs->maxfrm);
+	/* Pause Time */
+	iowrite32be(cfg->pause_quant, &regs->pause_quant);
+
+	/* clear all pending events and set-up interrupts */
+	fman_tgec_ack_event(regs, 0xffffffff);
+	fman_tgec_enable_interrupt(regs, exception_mask);
+
+	return 0;
+}
+
+void fman_tgec_set_erratum_tx_fifo_corruption_10gmac_a007(struct tgec_regs
+							  __iomem *regs)
+{
+	uint32_t tmp;
+
+	/* restore the default tx ipg Length */
+	tmp = (ioread32be(&regs->tx_ipg_len) & ~TGEC_TX_IPG_LENGTH_MASK) | 12;
+
+	iowrite32be(tmp, &regs->tx_ipg_len);
+}
-- 
1.7.11.7
