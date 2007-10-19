From: ggrundstrom@neteffect.com
Subject: [PATCH 10/14 v2] nes: eeprom and phy routines
Date: Fri, 19 Oct 2007 15:21:16 -0500
Message-ID: <200710192021.l9JKLGFU021817@neteffect.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: general@lists.openfabrics.org, ggrundstrom@neteffect.com,
	netdev@vger.kernel.org
To: ewg@lists.openfabrics.org, rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 75.neteffect.com ([204.57.75.75]:43237 "EHLO
	localhost.localdomain" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758801AbXJSU11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 16:27:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Misc eeprom, phy, and debug routines.

Signed-off-by: Glenn Grundstrom <ggrundstrom@neteffect.com>
---

--- NULL	1969-12-31 18:00:00.000000000 -0600
+++ ofa_kernel-1.3/drivers/infiniband/hw/nes/nes_utils.c	2007-10-19 09:=
43:32.000000000 -0500
@@ -0,0 +1,873 @@
+/*
+ * Copyright (c) 2006 - 2007 NetEffect, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/if_vlan.h>
+#include <linux/crc32.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <linux/init.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/byteorder.h>
+
+#include "nes.h"
+
+#define BITMASK(X)     (1L << (X))
+#define NES_CRC_WID     32
+
+static u16 nes_read16_eeprom(void __iomem *addr, u16 offset);
+
+static u32 nesCRCTable[256];
+static u32 nesCRCInitialized =3D 0;
+
+static u32 nesCRCWidMask(u32);
+static u32 nes_crc_table_gen(u32 *, u32, u32, u32);
+static u32 reflect(u32, u32);
+static u32 byte_swap(u32, u32);
+
+u32 mh_detected;
+u32 mh_pauses_sent;
+
+/**
+ * nes_read_eeprom_values -
+ */
+int nes_read_eeprom_values(struct nes_device *nesdev, struct nes_adapt=
er *nesadapter)
+{
+	u32 mac_addr_low;
+	u16 mac_addr_high;
+	u16 eeprom_data;
+	u16 eeprom_offset;
+	u16 next_section_address;
+	u32 index;
+
+	/* TODO: deal with EEPROM endian issues */
+	if (nesadapter->firmware_eeprom_offset =3D=3D 0) {
+		/* Read the EEPROM Parameters */
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, 0);
+		nes_debug(NES_DBG_HW, "EEPROM Offset 0  =3D 0x%04X\n", eeprom_data);
+		eeprom_offset =3D 2 + (((eeprom_data & 0x007f) << 3) <<
+				((eeprom_data & 0x0080) >> 7));
+		nes_debug(NES_DBG_HW, "Firmware Offset =3D 0x%04X\n", eeprom_offset)=
;
+		nesadapter->firmware_eeprom_offset =3D eeprom_offset;
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset + 4);
+		if (eeprom_data !=3D 0x5746) {
+			nes_debug(NES_DBG_HW, "Not a valid Firmware Image =3D 0x%04X\n", ee=
prom_data);
+			return -1;
+		}
+
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset + 2);
+		nes_debug(NES_DBG_HW, "EEPROM Offset %u  =3D 0x%04X\n",
+				eeprom_offset + 2, eeprom_data);
+		eeprom_offset +=3D ((eeprom_data & 0x00ff) << 3) << ((eeprom_data & =
0x0100) >> 8);
+		nes_debug(NES_DBG_HW, "Software Offset =3D 0x%04X\n", eeprom_offset)=
;
+		nesadapter->software_eeprom_offset =3D eeprom_offset;
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset + 4);
+		if (eeprom_data !=3D 0x5753) {
+			printk("Not a valid Software Image =3D 0x%04X\n", eeprom_data);
+			return -1;
+		}
+
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset + 2);
+		nes_debug(NES_DBG_HW, "EEPROM Offset %u (next section)  =3D 0x%04X\n=
",
+				eeprom_offset + 2, eeprom_data);
+		next_section_address =3D eeprom_offset + (((eeprom_data & 0x00ff) <<=
 3) <<
+				((eeprom_data & 0x0100) >> 8));
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, next_section_address=
 + 4);
+		if (eeprom_data !=3D 0x414d) {
+			nes_debug(NES_DBG_HW, "EEPROM Changed offset should be 0x414d but w=
as 0x%04X\n",
+					eeprom_data);
+			goto no_fw_rev;
+		}
+		eeprom_offset =3D next_section_address;
+
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset + 2);
+		nes_debug(NES_DBG_HW, "EEPROM Offset %u (next section)  =3D 0x%04X\n=
",
+				eeprom_offset + 2, eeprom_data);
+		next_section_address =3D eeprom_offset + (((eeprom_data & 0x00ff) <<=
 3) <<
+				((eeprom_data & 0x0100) >> 8));
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, next_section_address=
 + 4);
+		if (eeprom_data !=3D 0x4f52) {
+			nes_debug(NES_DBG_HW, "EEPROM Changed offset should be 0x4f52 but w=
as 0x%04X\n",
+					eeprom_data);
+			goto no_fw_rev;
+		}
+		eeprom_offset =3D next_section_address;
+
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset + 2);
+		nes_debug(NES_DBG_HW, "EEPROM Offset %u (next section)  =3D 0x%04X\n=
",
+				eeprom_offset + 2, eeprom_data);
+		next_section_address =3D eeprom_offset + ((eeprom_data & 0x00ff) << =
3);
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, next_section_address=
 + 4);
+		if (eeprom_data !=3D 0x5746) {
+			nes_debug(NES_DBG_HW, "EEPROM Changed offset should be 0x5746 but w=
as 0x%04X\n",
+					eeprom_data);
+			goto no_fw_rev;
+		}
+		eeprom_offset =3D next_section_address;
+
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset + 2);
+		nes_debug(NES_DBG_HW, "EEPROM Offset %u (next section)  =3D 0x%04X\n=
",
+				eeprom_offset + 2, eeprom_data);
+		next_section_address =3D eeprom_offset + ((eeprom_data & 0x00ff) << =
3);
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, next_section_address=
 + 4);
+		if (eeprom_data !=3D 0x5753) {
+			nes_debug(NES_DBG_HW, "EEPROM Changed offset should be 0x5753 but w=
as 0x%04X\n",
+					eeprom_data);
+			goto no_fw_rev;
+		}
+		eeprom_offset =3D next_section_address;
+
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset + 2);
+		nes_debug(NES_DBG_HW, "EEPROM Offset %u (next section)  =3D 0x%04X\n=
",
+				eeprom_offset + 2, eeprom_data);
+		next_section_address =3D eeprom_offset + ((eeprom_data & 0x00ff) << =
3);
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, next_section_address=
 + 4);
+		if (eeprom_data !=3D 0x414d) {
+			nes_debug(NES_DBG_HW, "EEPROM Changed offset should be 0x414d but w=
as 0x%04X\n",
+					eeprom_data);
+			goto no_fw_rev;
+		}
+		eeprom_offset =3D next_section_address;
+
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset + 2);
+		nes_debug(NES_DBG_HW, "EEPROM Offset %u (next section)  =3D 0x%04X\n=
",
+				eeprom_offset + 2, eeprom_data);
+		next_section_address =3D eeprom_offset + ((eeprom_data & 0x00ff) << =
3);
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, next_section_address=
 + 4);
+		if (eeprom_data !=3D 0x464e) {
+			nes_debug(NES_DBG_HW, "EEPROM Changed offset should be 0x464e but w=
as 0x%04X\n",
+					eeprom_data);
+			goto no_fw_rev;
+		}
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, next_section_address=
 + 8);
+		printk(PFX "Firmware version %u.%u\n", (u8)(eeprom_data>>8), (u8)eep=
rom_data);
+
+		nesadapter->firmware_version =3D (((u32)(u8)(eeprom_data>>8))  <<  1=
6) +
+				(u32)((u8)eeprom_data);
+
+no_fw_rev:
+		/* eeprom is valid */
+		eeprom_offset =3D nesadapter->software_eeprom_offset;
+		eeprom_offset +=3D 8;
+		nesadapter->netdev_max =3D (u8)nes_read16_eeprom(nesdev->regs, eepro=
m_offset);
+		eeprom_offset +=3D 2;
+		mac_addr_high =3D nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		eeprom_offset +=3D 2;
+		mac_addr_low =3D (u32)nes_read16_eeprom(nesdev->regs, eeprom_offset)=
;
+		eeprom_offset +=3D 2;
+		mac_addr_low <<=3D 16;
+		mac_addr_low +=3D (u32)nes_read16_eeprom(nesdev->regs, eeprom_offset=
);
+		nes_debug(NES_DBG_HW, "Base MAC Address =3D 0x%04X%08X\n",
+				mac_addr_high, mac_addr_low);
+		nes_debug(NES_DBG_HW, "MAC Address count =3D %u\n", nesadapter->netd=
ev_max);
+
+		nesadapter->mac_addr_low =3D mac_addr_low;
+		nesadapter->mac_addr_high =3D mac_addr_high;
+
+		/* Read the Phy Type array */
+		eeprom_offset +=3D 10;
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		nes_debug(NES_DBG_HW, "PhyType: 0x%04x\n", eeprom_data);
+
+		/* Read the port array */
+		eeprom_offset +=3D 2;
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		/* port_count is set by soft reset reg */
+		for (index =3D 0; index < 4; index++) {
+			nesadapter->ports[index] =3D eeprom_data & 0x000f;
+			eeprom_data >>=3D 4;
+		}
+		nes_debug(NES_DBG_HW, "port_count =3D %u, port 0 -> %u, port 1 -> %u=
, port 2 -> %u, port 3 -> %u\n",
+				nesadapter->port_count,
+				nesadapter->ports[0], nesadapter->ports[1],
+				nesadapter->ports[2], nesadapter->ports[3]);
+
+		eeprom_offset +=3D 46;
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		eeprom_offset +=3D 2;
+		nesadapter->rx_pool_size =3D (((u32)eeprom_data) << 16) +
+				nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		nes_debug(NES_DBG_HW, "rx_pool_size =3D 0x%08X\n", nesadapter->rx_po=
ol_size);
+
+		eeprom_offset +=3D 2;
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		eeprom_offset +=3D 2;
+		nesadapter->tx_pool_size =3D (((u32)eeprom_data) << 16) +
+				nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		nes_debug(NES_DBG_HW, "tx_pool_size =3D 0x%08X\n", nesadapter->tx_po=
ol_size);
+
+		eeprom_offset +=3D 2;
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		eeprom_offset +=3D 2;
+		nesadapter->rx_threshold =3D (((u32)eeprom_data) << 16) +
+				nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		nes_debug(NES_DBG_HW, "rx_threshold =3D 0x%08X\n", nesadapter->rx_th=
reshold);
+
+		eeprom_offset +=3D 2;
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		eeprom_offset +=3D 2;
+		nesadapter->tcp_timer_core_clk_divisor =3D (((u32)eeprom_data) << 16=
) +
+				nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		nes_debug(NES_DBG_HW, "tcp_timer_core_clk_divisor =3D 0x%08X\n",
+				nesadapter->tcp_timer_core_clk_divisor);
+
+		eeprom_offset +=3D 2;
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		eeprom_offset +=3D 2;
+		nesadapter->iwarp_config =3D (((u32)eeprom_data) << 16) +
+				nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		nes_debug(NES_DBG_HW, "iwarp_config =3D 0x%08X\n", nesadapter->iwarp=
_config);
+
+		eeprom_offset +=3D 2;
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		eeprom_offset +=3D 2;
+		nesadapter->cm_config =3D (((u32)eeprom_data) << 16) +
+				nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		nes_debug(NES_DBG_HW, "cm_config =3D 0x%08X\n", nesadapter->cm_confi=
g);
+
+		eeprom_offset +=3D 2;
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		eeprom_offset +=3D 2;
+		nesadapter->sws_timer_config =3D (((u32)eeprom_data) << 16) +
+				nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		nes_debug(NES_DBG_HW, "sws_timer_config =3D 0x%08X\n", nesadapter->s=
ws_timer_config);
+
+		eeprom_offset +=3D 2;
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		eeprom_offset +=3D 2;
+		nesadapter->tcp_config1 =3D (((u32)eeprom_data) << 16) +
+				nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		nes_debug(NES_DBG_HW, "tcp_config1 =3D 0x%08X\n", nesadapter->tcp_co=
nfig1);
+
+		eeprom_offset +=3D 2;
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		eeprom_offset +=3D 2;
+		nesadapter->wqm_wat =3D (((u32)eeprom_data) << 16) +
+				nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		nes_debug(NES_DBG_HW, "wqm_wat =3D 0x%08X\n", nesadapter->wqm_wat);
+
+		eeprom_offset +=3D 2;
+		eeprom_data =3D nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		eeprom_offset +=3D 2;
+		nesadapter->core_clock =3D (((u32)eeprom_data) << 16) +
+				nes_read16_eeprom(nesdev->regs, eeprom_offset);
+		nes_debug(NES_DBG_HW, "core_clock =3D 0x%08X\n", nesadapter->core_cl=
ock);
+	}
+
+	nesadapter->phy_index[0] =3D 4;
+	nesadapter->phy_index[1] =3D 5;
+	nesadapter->phy_index[2] =3D 6;
+	nesadapter->phy_index[3] =3D 7;
+
+	/* TODO: get this from EEPROM */
+	nesdev->base_doorbell_index =3D 1;
+
+	return 0;
+}
+
+
+/**
+ * nes_read16_eeprom
+ */
+static u16 nes_read16_eeprom(void __iomem *addr, u16 offset)
+{
+	writel(NES_EEPROM_READ_REQUEST + (offset >> 1),
+			(void __iomem *)addr + NES_EEPROM_COMMAND);
+
+	do {
+	} while (readl((void __iomem *)addr + NES_EEPROM_COMMAND) &
+			NES_EEPROM_READ_REQUEST);
+
+	return(readw((void __iomem *)addr + NES_EEPROM_DATA));
+}
+
+
+/**
+ * nes_write_1G_phy_reg
+ */
+void nes_write_1G_phy_reg(struct nes_device *nesdev, u8 phy_reg, u8 ph=
y_addr, u16 data)
+{
+	struct nes_adapter *nesadapter =3D nesdev->nesadapter;
+	u32 u32temp;
+	u32 counter;
+	unsigned long flags;
+
+	spin_lock_irqsave(&nesadapter->phy_lock, flags);
+
+	nes_write_indexed(nesdev, NES_IDX_MAC_MDIO_CONTROL,
+			0x50020000 | data | ((u32)phy_reg << 18) | ((u32)phy_addr << 23));
+	for (counter =3D 0; counter < 100 ; counter++) {
+		udelay(30);
+		u32temp =3D nes_read_indexed(nesdev, NES_IDX_MAC_INT_STATUS);
+		if (u32temp & 1) {
+			/* nes_debug(NES_DBG_PHY, "Phy interrupt status =3D 0x%X.\n", u32te=
mp); */
+			nes_write_indexed(nesdev, NES_IDX_MAC_INT_STATUS, 1);
+			break;
+		}
+	}
+	if (!(u32temp & 1))
+		nes_debug(NES_DBG_PHY, "Phy is not responding. interrupt status =3D =
0x%X.\n",
+				u32temp);
+
+	spin_unlock_irqrestore(&nesadapter->phy_lock, flags);
+}
+
+
+/**
+ * nes_read_1G_phy_reg
+ * This routine only issues the read, the data must be read
+ * separately.
+ */
+void nes_read_1G_phy_reg(struct nes_device *nesdev, u8 phy_reg, u8 phy=
_addr, u16 *data)
+{
+	struct nes_adapter *nesadapter =3D nesdev->nesadapter;
+	u32 u32temp;
+	u32 counter;
+	unsigned long flags;
+
+	/* nes_debug(NES_DBG_PHY, "%s: phy addr =3D %d, mac_index =3D %d\n",
+			__FUNCTION__, phy_addr, nesdev->mac_index); */
+	spin_lock_irqsave(&nesadapter->phy_lock, flags);
+
+	nes_write_indexed(nesdev, NES_IDX_MAC_MDIO_CONTROL,
+			0x60020000 | ((u32)phy_reg << 18) | ((u32)phy_addr << 23));
+	for (counter =3D 0; counter < 100 ; counter++) {
+		udelay(30);
+		u32temp =3D nes_read_indexed(nesdev, NES_IDX_MAC_INT_STATUS);
+		if (u32temp & 1) {
+			/* nes_debug(NES_DBG_PHY, "Phy interrupt status =3D 0x%X.\n", u32te=
mp); */
+			nes_write_indexed(nesdev, NES_IDX_MAC_INT_STATUS, 1);
+			break;
+		}
+	}
+	if (!(u32temp & 1)) {
+		nes_debug(NES_DBG_PHY, "Phy is not responding. interrupt status =3D =
0x%X.\n",
+				u32temp);
+		*data =3D 0xffff;
+	} else {
+		*data =3D (u16)nes_read_indexed(nesdev, NES_IDX_MAC_MDIO_CONTROL);
+	}
+	spin_unlock_irqrestore(&nesadapter->phy_lock, flags);
+}
+
+
+/**
+ * nes_write_10G_phy_reg
+ */
+void nes_write_10G_phy_reg(struct nes_device *nesdev, u16 phy_reg,
+		u8 phy_addr, u16 data)
+{
+	u32 dev_addr;
+	u32 port_addr;
+	u32 u32temp;
+	u32 counter;
+
+	dev_addr =3D 5;
+	port_addr =3D 0;
+
+	/* set address */
+	nes_write_indexed(nesdev, NES_IDX_MAC_MDIO_CONTROL,
+			0x00020000 | phy_reg | (dev_addr << 18) | (port_addr << 23));
+	for (counter =3D 0; counter < 100 ; counter++) {
+		udelay(30);
+		u32temp =3D nes_read_indexed(nesdev, NES_IDX_MAC_INT_STATUS);
+		if (u32temp & 1) {
+			nes_write_indexed(nesdev, NES_IDX_MAC_INT_STATUS, 1);
+			break;
+		}
+	}
+	if (!(u32temp & 1))
+		nes_debug(NES_DBG_PHY, "Phy is not responding. interrupt status =3D =
0x%X.\n",
+				u32temp);
+
+	/* set data */
+	nes_write_indexed(nesdev, NES_IDX_MAC_MDIO_CONTROL,
+			0x10020000 | data | (dev_addr << 18) | (port_addr << 23));
+	for (counter =3D 0; counter < 100 ; counter++) {
+		udelay(30);
+		u32temp =3D nes_read_indexed(nesdev, NES_IDX_MAC_INT_STATUS);
+		if (u32temp & 1) {
+			nes_write_indexed(nesdev, NES_IDX_MAC_INT_STATUS, 1);
+			break;
+		}
+	}
+	if (!(u32temp & 1))
+		nes_debug(NES_DBG_PHY, "Phy is not responding. interrupt status =3D =
0x%X.\n",
+				u32temp);
+}
+
+
+/**
+ * nes_read_10G_phy_reg
+ * This routine only issues the read, the data must be read
+ * separately.
+ */
+void nes_read_10G_phy_reg(struct nes_device *nesdev, u16 phy_reg, u8 p=
hy_addr)
+{
+	u32 dev_addr;
+	u32 port_addr;
+	u32 u32temp;
+	u32 counter;
+
+	dev_addr =3D 5;
+	port_addr =3D 0;
+
+	/* set address */
+	nes_write_indexed(nesdev, NES_IDX_MAC_MDIO_CONTROL,
+			0x00020000 | phy_reg | (dev_addr << 18) | (port_addr << 23));
+	for (counter =3D 0; counter < 100 ; counter++) {
+		udelay(30);
+		u32temp =3D nes_read_indexed(nesdev, NES_IDX_MAC_INT_STATUS);
+		if (u32temp & 1) {
+			nes_write_indexed(nesdev, NES_IDX_MAC_INT_STATUS, 1);
+			break;
+		}
+	}
+	if (!(u32temp & 1))
+		nes_debug(NES_DBG_PHY, "Phy is not responding. interrupt status =3D =
0x%X.\n",
+				u32temp);
+
+	/* issue read */
+	nes_write_indexed(nesdev, NES_IDX_MAC_MDIO_CONTROL,
+			0x30020000 | (dev_addr << 18) | (port_addr << 23));
+	for (counter =3D 0; counter < 100 ; counter++) {
+		udelay(30);
+		u32temp =3D nes_read_indexed(nesdev, NES_IDX_MAC_INT_STATUS);
+		if (u32temp & 1) {
+			nes_write_indexed(nesdev, NES_IDX_MAC_INT_STATUS, 1);
+			break;
+		}
+	}
+	if (!(u32temp & 1))
+		nes_debug(NES_DBG_PHY, "Phy is not responding. interrupt status =3D =
0x%X.\n",
+				u32temp);
+}
+
+
+/**
+ * nes_arp_table
+ */
+int nes_arp_table(struct nes_device *nesdev, u32 ip_addr, u8 *mac_addr=
, u32 action)
+{
+	struct nes_adapter *nesadapter =3D nesdev->nesadapter;
+	int arp_index;
+	int err =3D 0;
+
+	for (arp_index =3D 0; (u32) arp_index < nesadapter->arp_table_size; a=
rp_index++) {
+		if (nesadapter->arp_table[arp_index].ip_addr =3D=3D ip_addr)
+			break;
+	}
+
+	if (action =3D=3D NES_ARP_ADD) {
+		if (arp_index !=3D nesadapter->arp_table_size) {
+			return -1;
+		}
+
+		arp_index =3D 0;
+		err =3D nes_alloc_resource(nesadapter, nesadapter->allocated_arps,
+				nesadapter->arp_table_size, &arp_index, &nesadapter->next_arp_inde=
x);
+		if (err) {
+			nes_debug(NES_DBG_NETDEV, "nes_alloc_resource returned error =3D %u=
\n", err);
+			return err;
+		}
+		nes_debug(NES_DBG_NETDEV, "ADD, arp_index=3D%d\n", arp_index);
+
+		nesadapter->arp_table[arp_index].ip_addr =3D ip_addr;
+		memcpy(nesadapter->arp_table[arp_index].mac_addr, mac_addr, ETH_ALEN=
);
+		return arp_index;
+	}
+
+	/* DELETE or RESOLVE */
+	if (arp_index =3D=3D nesadapter->arp_table_size) {
+		nes_debug(NES_DBG_NETDEV, "mac address not in ARP table - cannot del=
ete or resolve\n");
+		return -1;
+	}
+
+	if (action =3D=3D NES_ARP_RESOLVE) {
+		nes_debug(NES_DBG_NETDEV, "RESOLVE, arp_index=3D%d\n", arp_index);
+		return arp_index;
+	}
+
+	if (action =3D=3D NES_ARP_DELETE) {
+		nes_debug(NES_DBG_NETDEV, "DELETE, arp_index=3D%d\n", arp_index);
+		nesadapter->arp_table[arp_index].ip_addr =3D 0;
+		memset(nesadapter->arp_table[arp_index].mac_addr, 0x00, ETH_ALEN);
+		nes_free_resource(nesadapter, nesadapter->allocated_arps, arp_index)=
;
+		return arp_index;
+	}
+
+	return -1;
+}
+
+
+/**
+ * nes_mh_fix
+ */
+void nes_mh_fix(unsigned long parm)
+{
+	unsigned long flags;
+	struct nes_device *nesdev =3D (struct nes_device *)parm;
+	struct nes_adapter *nesadapter =3D nesdev->nesadapter;
+	struct nes_vnic *nesvnic;
+	u32 used_chunks_tx;
+	u32 temp_used_chunks_tx;
+	u32 temp_last_used_chunks_tx;
+	u32 used_chunks_mask;
+	u32 mac_tx_frames_low;
+	u32 mac_tx_frames_high;
+	u32 mac_tx_pauses;
+	u32 serdes_status;
+	u32 reset_value;
+	u32 tx_control;
+	u32 tx_config;
+	u32 tx_pause_quanta;
+	u32 rx_control;
+	u32 rx_config;
+	u32 mac_exact_match;
+	u32 mpp_debug;
+	u32 i=3D0;
+	u32 chunks_tx_progress =3D 0;
+
+	spin_lock_irqsave(&nesadapter->phy_lock, flags);
+	if ((nesadapter->mac_sw_state[0] !=3D NES_MAC_SW_IDLE) || (nesadapter=
->mac_link_down[0])) {
+		spin_unlock_irqrestore(&nesadapter->phy_lock, flags);
+		goto no_mh_work;
+	}
+	nesadapter->mac_sw_state[0] =3D NES_MAC_SW_MH;
+	spin_unlock_irqrestore(&nesadapter->phy_lock, flags);
+	do {
+		mac_tx_frames_low =3D nes_read_indexed(nesdev, NES_IDX_MAC_TX_FRAMES=
_LOW);
+		mac_tx_frames_high =3D nes_read_indexed(nesdev, NES_IDX_MAC_TX_FRAME=
S_HIGH);
+		mac_tx_pauses =3D nes_read_indexed(nesdev, NES_IDX_MAC_TX_PAUSE_FRAM=
ES);
+		used_chunks_tx =3D nes_read_indexed(nesdev, NES_IDX_USED_CHUNKS_TX);
+		nesdev->mac_pause_frames_sent +=3D mac_tx_pauses;
+		used_chunks_mask =3D 0;
+		temp_used_chunks_tx =3D used_chunks_tx;
+		temp_last_used_chunks_tx =3D nesdev->last_used_chunks_tx;
+
+		if (nesdev->netdev[0]) {
+			nesvnic =3D netdev_priv(nesdev->netdev[0]);
+		} else {
+			break;
+		}
+
+		for (i=3D0; i<4; i++) {
+			used_chunks_mask <<=3D 8;
+			if (nesvnic->qp_nic_index[i] !=3D 0xff) {
+				used_chunks_mask |=3D 0xff;
+				if ((temp_used_chunks_tx&0xff)<(temp_last_used_chunks_tx&0xff)) {
+					chunks_tx_progress =3D 1;
+				}
+			}
+			temp_used_chunks_tx >>=3D 8;
+			temp_last_used_chunks_tx >>=3D 8;
+		}
+		if ((mac_tx_frames_low) || (mac_tx_frames_high) ||
+			(!(used_chunks_tx&used_chunks_mask)) ||
+			(!(nesdev->last_used_chunks_tx&used_chunks_mask)) ||
+			(chunks_tx_progress) ) {
+			nesdev->last_used_chunks_tx =3D used_chunks_tx;
+			break;
+		}
+		nesdev->last_used_chunks_tx =3D used_chunks_tx;
+		barrier();
+
+		nes_write_indexed(nesdev, NES_IDX_MAC_TX_CONTROL, 0x00000005);
+		mh_pauses_sent++;
+		mac_tx_pauses =3D nes_read_indexed(nesdev, NES_IDX_MAC_TX_PAUSE_FRAM=
ES);
+		if (mac_tx_pauses) {
+			nesdev->mac_pause_frames_sent +=3D mac_tx_pauses;
+			break;
+		}
+
+		tx_control =3D nes_read_indexed(nesdev, NES_IDX_MAC_TX_CONTROL);
+		tx_config =3D nes_read_indexed(nesdev, NES_IDX_MAC_TX_CONFIG);
+		tx_pause_quanta =3D nes_read_indexed(nesdev, NES_IDX_MAC_TX_PAUSE_QU=
ANTA);
+		rx_control =3D nes_read_indexed(nesdev, NES_IDX_MAC_RX_CONTROL);
+		rx_config =3D nes_read_indexed(nesdev, NES_IDX_MAC_RX_CONFIG);
+		mac_exact_match =3D nes_read_indexed(nesdev, NES_IDX_MAC_EXACT_MATCH=
_BOTTOM);
+		mpp_debug =3D nes_read_indexed(nesdev, NES_IDX_MPP_DEBUG);
+
+		/* one last ditch effort to avoid a false positive */
+		mac_tx_pauses =3D nes_read_indexed(nesdev, NES_IDX_MAC_TX_PAUSE_FRAM=
ES);
+		if (mac_tx_pauses) {
+			nesdev->last_mac_tx_pauses =3D nesdev->mac_pause_frames_sent;
+			nes_debug(NES_DBG_HW, "failsafe caught slow outbound pause\n");
+			break;
+		}
+		mh_detected++;
+
+		nes_write_indexed(nesdev, NES_IDX_MAC_TX_CONTROL, 0x00000000);
+		nes_write_indexed(nesdev, NES_IDX_MAC_TX_CONFIG, 0x00000000);
+		reset_value =3D nes_read32(nesdev->regs+NES_SOFTWARE_RESET);
+
+		nes_write32(nesdev->regs+NES_SOFTWARE_RESET, reset_value | 0x0000001=
d);
+
+		while (((nes_read32(nesdev->regs+NES_SOFTWARE_RESET)
+				& 0x00000040) !=3D 0x00000040) && (i++ < 5000)) {
+			/* mdelay(1); */
+		}
+
+		nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_COMMON_CONTROL0, 0x0000=
0008);
+		serdes_status =3D nes_read_indexed(nesdev, NES_IDX_ETH_SERDES_COMMON=
_STATUS0);
+
+		nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_TX_EMP0, 0x000bdef7);
+		nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_TX_DRIVE0, 0x9ce73000);
+		nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_RX_MODE0, 0x0ff00000);
+		nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_RX_SIGDET0, 0x00000000)=
;
+		nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_BYPASS0, 0x00000000);
+		nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_LOOPBACK_CONTROL0, 0x00=
000000);
+		if (nesadapter->OneG_Mode) {
+			nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_RX_EQ_CONTROL0, 0xf018=
2222);
+		} else {
+			nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_RX_EQ_CONTROL0, 0xf004=
2222);
+		}
+		serdes_status =3D nes_read_indexed(nesdev, NES_IDX_ETH_SERDES_RX_EQ_=
STATUS0);
+		nes_write_indexed(nesdev, NES_IDX_ETH_SERDES_CDR_CONTROL0, 0x000000f=
f);
+
+		nes_write_indexed(nesdev, NES_IDX_MAC_TX_CONTROL, tx_control);
+		nes_write_indexed(nesdev, NES_IDX_MAC_TX_CONFIG, tx_config);
+		nes_write_indexed(nesdev, NES_IDX_MAC_TX_PAUSE_QUANTA, tx_pause_quan=
ta);
+		nes_write_indexed(nesdev, NES_IDX_MAC_RX_CONTROL, rx_control);
+		nes_write_indexed(nesdev, NES_IDX_MAC_RX_CONFIG, rx_config);
+		nes_write_indexed(nesdev, NES_IDX_MAC_EXACT_MATCH_BOTTOM, mac_exact_=
match);
+		nes_write_indexed(nesdev, NES_IDX_MPP_DEBUG, mpp_debug);
+
+	} while (0);
+
+	nesadapter->mac_sw_state[0] =3D NES_MAC_SW_IDLE;
+no_mh_work:
+	nesdev->nesadapter->mh_timer.expires =3D jiffies + (HZ/5);
+	add_timer(&nesdev->nesadapter->mh_timer);
+}
+
+
+/*
+"Everything you wanted to know about CRC algorithms, but were afraid t=
o ask
+ for fear that errors in your understanding might be detected." Versio=
n  : 3.
+Date  : 19 August 1993.
+Author  : Ross N. Williams.
+Net  : ross@guest.adelaide.edu.au.
+FTP  : ftp.adelaide.edu.au/pub/rocksoft/crc_v3.txt
+Company  : Rocksoft=99 Pty Ltd.
+Snail  : 16 Lerwick Avenue, Hazelwood Park 5066, Australia.
+Fax  : +61 8 373-4911 (c/- Internode Systems Pty Ltd).
+Phone  : +61 8 379-9217 (10am to 10pm Adelaide Australia time).
+Note  : "Rocksoft" is a trademark of Rocksoft Pty Ltd, Australia.
+Status  : Copyright (C) Ross Williams, 1993. However, permission is gr=
anted to
+ make and distribute verbatim copies of this document provided that th=
is information
+ block and copyright notice is included. Also, the C code modules incl=
uded in this
+ document are fully public domain.
+
+Thanks  : Thanks to Jean-loup Gailly (jloup@chorus.fr) and Mark Adler
+ (me@quest.jpl.nasa.gov) who both proof read this document and picked
+ out lots of nits as well as some big fat bugs.
+
+The current web page for this seems to be http://www.ross.net/crc/crcp=
aper.html.
+
+*/
+
+/*********************************************************************=
*******/
+/*                            Generate width mask                     =
      */
+/*********************************************************************=
*******/
+/*                                                                    =
      */
+/* Returns a longword whose value is (2^p_cm->cm_width)-1.            =
      */
+/* The trick is to do this portably (e.g. without doing <<32).        =
      */
+/*                                                                    =
      */
+/* Author:  Tristan Gross                                             =
      */
+/* Source:  "A PAINLESS GUIDE TO CRC ERROR DETECTION ALGORITHMS"      =
      */
+/*          Ross N. Williams                                          =
      */
+/*          http://www.rocksoft.com                                   =
      */
+/*                                                                    =
      */
+/*********************************************************************=
*******/
+
+static u32 nesCRCWidMask (u32 width)
+{
+	return(((1L<<(((u32)width)-1))-1L)<<1)|1L;
+}
+
+
+/*********************************************************************=
*******/
+/*                             Generate CRC table                     =
      */
+/*********************************************************************=
*******/
+/*                                                                    =
      */
+/* Source:  "A PAINLESS GUIDE TO CRC ERROR DETECTION ALGORITHMS"      =
      */
+/*          Ross N. Williams                                          =
      */
+/*          http://www.rocksoft.com                                   =
      */
+/*                                                                    =
      */
+/*********************************************************************=
*******/
+static u32 nes_crc_table_gen ( u32 *pCRCTable,
+		u32  poly,
+		u32  order,
+		u32  reflectIn)
+{
+	u32 i;
+	u32 reg;
+	u32 byte;
+	u32 topbit =3D BITMASK(NES_CRC_WID-1);
+	u32 tmp;
+
+	for (byte=3D0;byte<256;byte++) {
+
+		// If we need to creat a reflected table we must reflect the index (=
byte) and
+		// reflect the final reg
+		tmp =3D (reflectIn) ? reflect(byte,8): byte;
+
+		reg =3D tmp << (NES_CRC_WID-8);
+
+		for (i=3D0; i<8; i++) {
+			if (reg & topbit) {
+				reg =3D (reg << 1) ^ poly;
+			} else {
+				reg <<=3D 1;
+			}
+		}
+
+		reg =3D (reflectIn) ?  reflect(reg,order): reg;
+		pCRCTable[byte] =3D reg & nesCRCWidMask(NES_CRC_WID);
+	}
+
+	return 0;
+}
+
+
+/*********************************************************************=
*******/
+/*                    Perform 32 bit based CRC calculation            =
      */
+/*********************************************************************=
*******/
+/*                                                                    =
      */
+/* Source:  "A PAINLESS GUIDE TO CRC ERROR DETECTION ALGORITHMS"      =
      */
+/*          Ross N. Williams                                          =
      */
+/*          http://www.rocksoft.com                                   =
      */
+/*                                                                    =
      */
+/* This performs a standard 32 bit crc on an array of arbitrary length=
      */
+/* with an arbitrary initial value and passed generator polynomial    =
      */
+/* in the form of a crc table.                                        =
      */
+/*                                                                    =
      */
+/*********************************************************************=
*******/
+static u32 reflect (u32 data, u32 num)
+{
+	/* Reflects the lower num bits in 'data' around their center point. *=
/
+	u32 i;
+	u32 j      =3D 1;
+	u32 result =3D 0;
+
+	for (i=3D(u32)1<<(num-1); i; i>>=3D1) {
+		if (data & i) result|=3Dj;
+		j <<=3D 1;
+	}
+	return result;
+}
+
+
+/**
+ * byte_swap
+ */
+static u32 byte_swap (u32 data, u32 num)
+{
+	u32 i;
+	u32 result =3D 0;
+
+	if (num%16) {
+		dprintk("\nbyte_swap: ERROR: num is not an even number of bytes\n");
+		/* ASSERT(0); */
+	}
+
+	for (i =3D 0; i < num; i +=3D 8) {
+		result |=3D (0xFF & (data >> i)) << (num-8-i);
+	}
+
+	return result;
+}
+
+
+/**
+ * nes_crc32 -
+ * This is a reflected table algorithm. ReflectIn basically
+ * means to reflect each incomming byte of the data. But to make
+ * things more complicated,  we can instead reflect the initial
+ * value, the final crc, and shift data to the right using a
+ * reflected pCRCTable. CRC is FUN!!
+ */
+u32 nes_crc32 (   u32  reverse,
+		u32  initialValue,
+		u32  finalXOR,
+		u32  messageLength,
+		u8  *pMessage,
+		u32  order,
+		u32  reflectIn,
+		u32  reflectOut)
+
+{
+	u8     *pBlockAddr =3D pMessage;
+	u32     mlen       =3D messageLength;
+	u32     crc;
+
+	if (0 =3D=3D nesCRCInitialized) {
+		nes_crc_table_gen( &nesCRCTable[0], CRC32C_POLY, ORDER, REFIN);
+		nesCRCInitialized =3D 1;
+	}
+
+	crc =3D (reflectIn) ? reflect(initialValue,order): initialValue;
+
+	while (mlen--) {
+		/* printf("byte =3D %x, index =3D %u, crctable[index] =3D %x\n",
+				*pBlockAddr, (crc & 0xffL) ^ *pBlockAddr,
+				nesCRCTable[(crc & 0xffL) ^ *pBlockAddr]);
+		*/
+		if (reflectIn) {
+			crc =3D nesCRCTable[(crc & 0xffL ) ^ *pBlockAddr++] ^ (crc >> 8);
+		} else {
+			crc =3D nesCRCTable[((crc>>24) ^ *pBlockAddr++) & 0xFFL] ^ (crc << =
8);
+		}
+	}
+
+	/* if reflectOut and reflectIn are both set, we don't */
+	/* do anything since reflecting twice effectively does nothing. */
+	crc =3D ((reflectIn)^(reflectOut)) ? reflect(crc,order): crc;
+
+	crc =3D crc^finalXOR;
+
+	/* We don't really use this, but it is here for completeness */
+	crc =3D (reverse) ? byte_swap(crc,32): crc;
+
+	return crc;
+}
+
