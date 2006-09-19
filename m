From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] [PATCH] ethtool: add ixgb register dump support
Date: Tue, 19 Sep 2006 11:27:35 -0700
Message-ID: <20060919182735.6371.19262.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, auke@foo-projects.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:45325 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1030397AbWISSSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 14:18:41 -0400
To: jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Nunley <nicholas.d.nunley@intel.com>

This adds support for dumping ixgb registers in readable format.

Signed-off-by: Nicholas Nunley <nicholas.d.nunley@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 Makefile.am    |    4 +-
 ethtool-util.h |    3 +
 ethtool.c      |    2 +
 ixgb.c         |  147 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 154 insertions(+), 2 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index cf4ebc5..c78eecf 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -6,8 +6,8 @@ EXTRA_DIST = ethtool.8 ethtool.spec.in a
 sbin_PROGRAMS = ethtool
 ethtool_SOURCES = ethtool.c ethtool-copy.h ethtool-util.h	\
 		  amd8111e.c de2104x.c e100.c e1000.c		\
-		  fec_8xx.c ibm_emac.c natsemi.c pcnet32.c	\
-		  realtek.c tg3.c skge.c
+		  fec_8xx.c ibm_emac.c ixgb.c natsemi.c		\
+		  pcnet32.c realtek.c tg3.c skge.c
 
 dist-hook:
 	cp $(top_srcdir)/ethtool.spec $(distdir)
diff --git a/ethtool-util.h b/ethtool-util.h
index 52c43bf..0e6fce2 100644
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -42,6 +42,9 @@ int fec_8xx_dump_regs(struct ethtool_drv
 /* PowerPC 4xx on-chip Ethernet controller */
 int ibm_emac_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 
+/* Intel(R) PRO/10GBe Gigabit Adapter Family */
+int ixgb_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
+
 /* Broadcom Tigon3 Ethernet controller */
 int tg3_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 
diff --git a/ethtool.c b/ethtool.c
index 87e22ab..02b9fb7 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -10,6 +10,7 @@
  * ETHTOOL_PHYS_ID support by Chris Leech <christopher.leech@intel.com>
  * e1000 support by Scott Feldman <scott.feldman@intel.com>
  * e100 support by Wen Tao <wen-hwa.tao@intel.com>
+ * ixgb support by Nicholas Nunley <Nicholas.d.nunley@intel.com>
  * amd8111e support by Reeja John <reeja.john@amd.com>
  * long arguments by Andi Kleen.
  *
@@ -937,6 +938,7 @@ static struct {
 	{ "r8169", realtek_dump_regs },
 	{ "de2104x", de2104x_dump_regs },
 	{ "e1000", e1000_dump_regs },
+	{ "ixgb", ixgb_dump_regs },
 	{ "natsemi", natsemi_dump_regs },
 	{ "e100", e100_dump_regs },
 	{ "amd8111e", amd8111e_dump_regs },
diff --git a/ixgb.c b/ixgb.c
new file mode 100644
index 0000000..06b4da2
--- /dev/null
+++ b/ixgb.c
@@ -0,0 +1,147 @@
+/* Copyright (c) 2006 Intel Corporation */
+#include <stdio.h>
+#include "ethtool-util.h"
+
+/* CTRL0 Bit Masks */
+#define IXGB_CTRL0_LRST           0x00000008
+#define IXGB_CTRL0_VME            0x40000000
+
+/* STATUS Bit Masks */
+#define IXGB_STATUS_LU            0x00000002
+#define IXGB_STATUS_BUS64         0x00001000
+#define IXGB_STATUS_PCIX_MODE     0x00002000
+#define IXGB_STATUS_PCIX_SPD_100  0x00004000
+#define IXGB_STATUS_PCIX_SPD_133  0x00008000
+
+/* RCTL Bit Masks */
+#define IXGB_RCTL_RXEN            0x00000002
+#define IXGB_RCTL_SBP             0x00000004
+#define IXGB_RCTL_UPE             0x00000008
+#define IXGB_RCTL_MPE             0x00000010
+#define IXGB_RCTL_RDMTS_MASK      0x00000300
+#define IXGB_RCTL_RDMTS_1_2       0x00000000
+#define IXGB_RCTL_RDMTS_1_4       0x00000100
+#define IXGB_RCTL_RDMTS_1_8       0x00000200
+#define IXGB_RCTL_BAM             0x00008000
+#define IXGB_RCTL_BSIZE_MASK      0x00030000
+#define IXGB_RCTL_BSIZE_4096      0x00010000
+#define IXGB_RCTL_BSIZE_8192      0x00020000
+#define IXGB_RCTL_BSIZE_16384     0x00030000
+#define IXGB_RCTL_VFE             0x00040000
+#define IXGB_RCTL_CFIEN           0x00080000
+
+/* TCTL Bit Masks */
+#define IXGB_TCTL_TXEN            0x00000002
+
+/* RAH Bit Masks */
+#define IXGB_RAH_ASEL_DEST        0x00000000
+#define IXGB_RAH_ASEL_SRC         0x00010000
+#define IXGB_RAH_AV               0x80000000
+
+int
+ixgb_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
+{
+	u32 *regs_buff = (u32 *)regs->data;
+	u8 version = (u8)(regs->version >> 24);
+	u32 reg;
+
+	if (version != 1)
+		return -1;
+	fprintf(stdout, "MAC Registers\n");
+	fprintf(stdout, "-------------\n");
+
+	/* Device control register */
+	reg = regs_buff[0];
+	fprintf(stdout,
+		"0x00000: CTRL0 (Device control register) 0x%08X\n"
+		"      Link reset:                        %s\n"
+		"      VLAN mode:                         %s\n",
+		reg,
+		reg & IXGB_CTRL0_LRST   ? "reset"    : "normal",
+		reg & IXGB_CTRL0_VME    ? "enabled"  : "disabled");
+
+	/* Device status register */
+	reg = regs_buff[2];
+	fprintf(stdout,
+		"0x00010: STATUS (Device status register) 0x%08X\n"
+		"      Link up:                           %s\n"
+		"      Bus type:                          %s\n"
+		"      Bus speed:                         %s\n"
+		"      Bus width:                         %s\n",
+		reg,
+		(reg & IXGB_STATUS_LU)        ? "link config" : "no link config",
+		(reg & IXGB_STATUS_PCIX_MODE) ? "PCI-X" : "PCI",
+			((reg & IXGB_STATUS_PCIX_SPD_133) ? "133MHz" :
+			(reg & IXGB_STATUS_PCIX_SPD_100) ? "100MHz" :
+			"66MHz"),
+		(reg & IXGB_STATUS_BUS64) ? "64-bit" : "32-bit");
+	/* Receive control register */
+	reg = regs_buff[9];
+	fprintf(stdout,
+		"0x00100: RCTL (Receive control register) 0x%08X\n"
+		"      Receiver:                          %s\n"
+		"      Store bad packets:                 %s\n"
+		"      Unicast promiscuous:               %s\n"
+		"      Multicast promiscuous:             %s\n"
+		"      Descriptor minimum threshold size: %s\n"
+		"      Broadcast accept mode:             %s\n"
+		"      VLAN filter:                       %s\n"
+		"      Cononical form indicator:          %s\n",
+		reg,
+		reg & IXGB_RCTL_RXEN    ? "enabled"  : "disabled",
+		reg & IXGB_RCTL_SBP     ? "enabled"  : "disabled",
+		reg & IXGB_RCTL_UPE     ? "enabled"  : "disabled",
+		reg & IXGB_RCTL_MPE     ? "enabled"  : "disabled",
+		(reg & IXGB_RCTL_RDMTS_MASK) == IXGB_RCTL_RDMTS_1_2 ? "1/2" :
+		(reg & IXGB_RCTL_RDMTS_MASK) == IXGB_RCTL_RDMTS_1_4 ? "1/4" :
+		(reg & IXGB_RCTL_RDMTS_MASK) == IXGB_RCTL_RDMTS_1_8 ? "1/8" :
+		"reserved",
+		reg & IXGB_RCTL_BAM     ? "accept"   : "ignore",
+		reg & IXGB_RCTL_VFE     ? "enabled"  : "disabled",
+		reg & IXGB_RCTL_CFIEN   ? "enabled"  : "disabled");
+	fprintf(stdout,
+		"      Receive buffer size:               %s\n",
+		(reg & IXGB_RCTL_BSIZE_MASK) == IXGB_RCTL_BSIZE_16384 ? "16384" :
+		(reg & IXGB_RCTL_BSIZE_MASK) == IXGB_RCTL_BSIZE_8192 ? "8192" :
+		(reg & IXGB_RCTL_BSIZE_MASK) == IXGB_RCTL_BSIZE_4096 ? "4096" :
+		"2048");
+
+	/* Receive descriptor registers */
+	fprintf(stdout,
+		"0x00120: RDLEN (Receive desc length)     0x%08X\n",
+		regs_buff[14]);
+	fprintf(stdout,
+		"0x00128: RDH   (Receive desc head)       0x%08X\n",
+		regs_buff[15]);
+	fprintf(stdout,
+		"0x00130: RDT   (Receive desc tail)       0x%08X\n",
+		regs_buff[16]);
+	fprintf(stdout,
+		"0x00138: RDTR  (Receive delay timer)     0x%08X\n",
+		regs_buff[17]);
+
+	/* Transmit control register */
+	reg = regs_buff[53];
+	fprintf(stdout,
+		"0x00600: TCTL (Transmit ctrl register)   0x%08X\n"
+		"      Transmitter:                       %s\n",
+		reg,
+		reg & IXGB_TCTL_TXEN      ? "enabled"  : "disabled");
+
+	/* Transmit descriptor registers */
+	fprintf(stdout,
+		"0x00610: TDLEN (Transmit desc length)    0x%08X\n",
+		regs_buff[56]);
+	fprintf(stdout,
+		"0x00618: TDH   (Transmit desc head)      0x%08X\n",
+		regs_buff[57]);
+	fprintf(stdout,
+		"0x00620: TDT   (Transmit desc tail)      0x%08X\n",
+		regs_buff[58]);
+	fprintf(stdout,
+		"0x00628: TIDV  (Transmit delay timer)    0x%08X\n",
+		regs_buff[59]);
+	
+	return 0;
+}
+

