From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next] Ethtool: Add Altera Triple Speed Ethernet Register Dump Routine
Date: Thu, 24 Apr 2014 17:07:26 -0500
Message-ID: <1398377246-7083-2-git-send-email-vbridgers2013@gmail.com>
References: <1398377246-7083-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com
To: netdev@vger.kernel.org, ben@decadent.org.uk, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:50024 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758142AbaDXWLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 18:11:51 -0400
Received: by mail-pa0-f43.google.com with SMTP id rd3so547534pab.2
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 15:11:50 -0700 (PDT)
In-Reply-To: <1398377246-7083-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds initial support for Altera Triple Speed Ethernet
register dump support.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
 Makefile.am |    2 +-
 ethtool.c   |    1 +
 internal.h  |    5 +++
 tse.c       |  111 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 118 insertions(+), 1 deletion(-)
 create mode 100644 tse.c

diff --git a/Makefile.am b/Makefile.am
index fd3b17f..4698d16 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -13,7 +13,7 @@ ethtool_SOURCES += \
 		  fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c	\
 		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
 		  smsc911x.c at76c50x-usb.c sfc.c stmmac.c	\
-		  sfpid.c sfpdiag.c ixgbevf.c
+		  sfpid.c sfpdiag.c ixgbevf.c tse.c
 endif
 
 TESTS = test-cmdline test-features
diff --git a/ethtool.c b/ethtool.c
index 8e968a8..19b8b0c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -910,6 +910,7 @@ static const struct {
 	{ "st_mac100", st_mac100_dump_regs },
 	{ "st_gmac", st_gmac_dump_regs },
 	{ "et131x", et131x_dump_regs },
+	{ "altera_tse", altera_tse_dump_regs },
 #endif
 };
 
diff --git a/internal.h b/internal.h
index 86a64f2..2ca7e1a 100644
--- a/internal.h
+++ b/internal.h
@@ -243,6 +243,11 @@ int st_gmac_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 /* Et131x ethernet controller */
 int et131x_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 
+/* Altera TSE 10/100/1000 ethernet controller */
+int altera_tse_dump_regs(struct ethtool_drvinfo *info,
+			 struct ethtool_regs *regs);
+
+
 /* Rx flow classification */
 int rxclass_parse_ruleopts(struct cmd_context *ctx,
 			   struct ethtool_rx_flow_spec *fsp);
diff --git a/tse.c b/tse.c
new file mode 100644
index 0000000..098862d
--- /dev/null
+++ b/tse.c
@@ -0,0 +1,111 @@
+/****************************************************************************
+ * Support for the Altera Triple Speed Ethernet 10/100/1000 Controller
+ * Copyright (C) 2014 Altera Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include <stdio.h>
+#include <string.h>
+#include "internal.h"
+
+int
+bitset(u32 val, int bit)
+{
+	if (val & (1 << bit))
+		return 1;
+	return 0;
+}
+
+int altera_tse_dump_regs(struct ethtool_drvinfo *info,
+			 struct ethtool_regs *regs)
+{
+	int i;
+	u32 *tsereg = (unsigned int *)regs->data;
+	u32 version = regs->version;
+
+	/*
+	 * Version 1: Initial TSE driver release. No feature information
+	 *	      available, 32-bits of version is equal to 1.
+	 *
+	 * Version 2: Lower 16-bits of version is 2, upper 16 bits are:
+	 *	Bit 16 - SGMDA or MSGDMA Registers
+	 *	Bit 17 - PCS Present
+	 *	Bit 18 - Supplementary MAC Address Filter Registers Present
+	 *	Bit 19 - Multicast Hash Filter Present
+	 *	Bit 20 - IEEE 1588 Feature Present
+	 */
+	fprintf(stdout, "Altera TSE 10/100/1000 Registers, Version %d\n",
+		version);
+	fprintf(stdout, "---------------------------------------------\n");
+	fprintf(stdout, "Revision               0x%08X\n", tsereg[0]);
+	fprintf(stdout, "    Core Version       %d.%d\n",
+		(tsereg[0] & 0xffff) >> 8,
+		tsereg[0] & 0xff);
+	fprintf(stdout, "    CustVersion        0x%08X\n", tsereg[0] >> 16);
+	fprintf(stdout, "Scratch                0x%08X\n", tsereg[1]);
+	fprintf(stdout, "Command/Config         0x%08X\n", tsereg[2]);
+	fprintf(stdout, "    (0)TX_EN           %d\n", bitset(tsereg[2], 0));
+	fprintf(stdout, "    (1)RX_EN           %d\n", bitset(tsereg[2], 1));
+	fprintf(stdout, "    (2)XON_GEN         %d\n", bitset(tsereg[2], 2));
+	fprintf(stdout, "    (3)ETH_SPEED       %d\n", bitset(tsereg[2], 3));
+	fprintf(stdout, "    (4)PROMIS_EN       %d\n", bitset(tsereg[2], 4));
+	fprintf(stdout, "    (5)PAD_EN          %d\n", bitset(tsereg[2], 5));
+	fprintf(stdout, "    (6)CRC_FWD         %d\n", bitset(tsereg[2], 6));
+	fprintf(stdout, "    (7)PAUSE_FWD       %d\n", bitset(tsereg[2], 7));
+	fprintf(stdout, "    (8)PAUSE_IGN       %d\n", bitset(tsereg[2], 8));
+	fprintf(stdout, "    (9)TXADDR_INS      %d\n", bitset(tsereg[2], 9));
+	fprintf(stdout, "    (10)HD_EN          %d\n", bitset(tsereg[2], 10));
+	fprintf(stdout, "    (11)EXCESS_COL     %d\n", bitset(tsereg[2], 11));
+	fprintf(stdout, "    (12)LATE_COL       %d\n", bitset(tsereg[2], 12));
+	fprintf(stdout, "    (13)SW_RESET       %d\n", bitset(tsereg[2], 13));
+	fprintf(stdout, "    (14)MHASH_SEL      %d\n", bitset(tsereg[2], 14));
+	fprintf(stdout, "    (15)LOOP_EN        %d\n", bitset(tsereg[2], 15));
+	fprintf(stdout, "    (16-18)TX_ADDR_SEL %d\n",
+		(tsereg[2] & 0x30000) >> 16);
+	fprintf(stdout, "    (19)MAGIC_EN       %d\n", bitset(tsereg[2], 19));
+	fprintf(stdout, "    (20)SLEEP          %d\n", bitset(tsereg[2], 20));
+	fprintf(stdout, "    (21)WAKEUP         %d\n", bitset(tsereg[2], 21));
+	fprintf(stdout, "    (22)XOFF_GEN       %d\n", bitset(tsereg[2], 22));
+	fprintf(stdout, "    (23)CTRL_FRAME_EN  %d\n", bitset(tsereg[2], 23));
+	fprintf(stdout, "    (24)NO_LEN_CHECK   %d\n", bitset(tsereg[2], 24));
+	fprintf(stdout, "    (25)ENA_10         %d\n", bitset(tsereg[2], 25));
+	fprintf(stdout, "    (26)RX_ERR_DISC    %d\n", bitset(tsereg[2], 26));
+	fprintf(stdout, "    (31)CTRL_RESET     %d\n", bitset(tsereg[2], 31));
+	fprintf(stdout, "mac_0                  0x%08X\n", tsereg[3]);
+	fprintf(stdout, "mac_1                  0x%08X\n", tsereg[4]);
+	fprintf(stdout, "frm_length             0x%08X\n", tsereg[5]);
+	fprintf(stdout, "pause_quant            0x%08X\n", tsereg[6]);
+	fprintf(stdout, "rx_section_empty       0x%08X\n", tsereg[7]);
+	fprintf(stdout, "rx_section_full        0x%08X\n", tsereg[8]);
+	fprintf(stdout, "tx_section_empty       0x%08X\n", tsereg[9]);
+	fprintf(stdout, "tx_section_full        0x%08X\n", tsereg[0xa]);
+	fprintf(stdout, "rx_almost_empty        0x%08X\n", tsereg[0xb]);
+	fprintf(stdout, "rx_almost_full         0x%08X\n", tsereg[0xc]);
+	fprintf(stdout, "tx_almost_empty        0x%08X\n", tsereg[0xd]);
+	fprintf(stdout, "tx_almost_full         0x%08X\n", tsereg[0xe]);
+	fprintf(stdout, "mdio_addr0             0x%08X\n", tsereg[0xf]);
+	fprintf(stdout, "mdio_addr1             0x%08X\n", tsereg[0x10]);
+	fprintf(stdout, "holdoff_quant          0x%08X\n", tsereg[0x11]);
+
+	fprintf(stdout, "tx_ipg_length          0x%08X\n", tsereg[0x17]);
+	fprintf(stdout, "Transmit Command       0x%08X\n", tsereg[0x3a]);
+	fprintf(stdout, "Receive Command        0x%08X\n", tsereg[0x3b]);
+
+	for (i = 0; i < 64; i++)
+		fprintf(stdout, "Multicast Hash[%02d]     0x%08X\n",
+			i,
+			tsereg[0x40 + i]);
+	return 0;
+}
+
-- 
1.7.9.5
