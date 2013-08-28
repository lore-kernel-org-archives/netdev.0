From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool  3/3] ethtool: add ixgbevf support for register dump
Date: Tue, 27 Aug 2013 17:08:49 -0700
Message-ID: <1377648529-8297-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377648529-8297-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:62115 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754070Ab3H1AJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 20:09:13 -0400
In-Reply-To: <1377648529-8297-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch adds support for the ixgbevf driver, which previously was printing
out as hex dump, and in the driver via printk. This patch corrects the
implementation to have a new ixgbevf_reg_dump function that will format the
register output in a more human readable format.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 Makefile.am |   2 +-
 ethtool.c   |   1 +
 internal.h  |   2 +
 ixgbevf.c   | 180 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 184 insertions(+), 1 deletion(-)
 create mode 100644 ixgbevf.c

diff --git a/Makefile.am b/Makefile.am
index ba1faa6..db89d94 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -10,7 +10,7 @@ ethtool_SOURCES = ethtool.c ethtool-copy.h internal.h net_tstamp-copy.h \
 		  fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c	\
 		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
 		  smsc911x.c at76c50x-usb.c sfc.c stmmac.c	\
-		  rxclass.c sfpid.c sfpdiag.c
+		  rxclass.c sfpid.c sfpdiag.c ixgbevf.c
 
 TESTS = test-cmdline test-features
 check_PROGRAMS = test-cmdline test-features
diff --git a/ethtool.c b/ethtool.c
index 3544f0e..dcdc0a9 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -875,6 +875,7 @@ static const struct {
 	{ "igb", igb_dump_regs },
 	{ "ixgb", ixgb_dump_regs },
 	{ "ixgbe", ixgbe_dump_regs },
+	{ "ixgbevf", ixgbevf_dump_regs },
 	{ "natsemi", natsemi_dump_regs },
 	{ "e100", e100_dump_regs },
 	{ "amd8111e", amd8111e_dump_regs },
diff --git a/internal.h b/internal.h
index e977a81..86a64f2 100644
--- a/internal.h
+++ b/internal.h
@@ -213,6 +213,8 @@ int ixgb_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 
 int ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 
+int ixgbevf_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
+
 /* Broadcom Tigon3 Ethernet controller */
 int tg3_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 
diff --git a/ixgbevf.c b/ixgbevf.c
new file mode 100644
index 0000000..dae1178
--- /dev/null
+++ b/ixgbevf.c
@@ -0,0 +1,180 @@
+/* Copyright (c) 2007 Intel Corporation */
+#include <stdio.h>
+#include "internal.h"
+
+int
+ixgbevf_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
+{
+	u32 *regs_buff = (u32 *)regs->data;
+	u8 version = (u8)(regs->version >> 24);
+	u8 i;
+
+	if (version == 0)
+		return -1;
+
+	fprintf(stdout,
+		"0x00000: VFCTRL      (VF Control Register) (Write Only) N/A\n");
+
+	fprintf(stdout,
+		"0x00008: VFSTATUS    (VF Status Register)               0x%08X\n",
+		regs_buff[1]);
+
+	fprintf(stdout,
+		"0x00010: VFLINKS     (VF Link Status Register)          0x%08X\n",
+		regs_buff[2]);
+
+	fprintf(stdout,
+		"0x03190: VFRXMEMWRAP (Rx Packet Buffer Flush Detect)    0x%08X\n",
+		regs_buff[3]);
+
+	fprintf(stdout,
+		"0x00048: VFFRTIMER   (VF Free Running Timer)            0x%08X\n",
+		regs_buff[4]);
+
+	fprintf(stdout,
+		"0x00100: VFEICR      (VF Extended Interrupt Cause)      0x%08X\n",
+		regs_buff[5]);
+
+	fprintf(stdout,
+		"0x00104: VFEICS      (VF Extended Interrupt Cause Set)  0x%08X\n",
+		regs_buff[6]);
+
+	fprintf(stdout,
+		"0x00108: VFEIMS      (VF Extended Interrupt Mask Set)   0x%08X\n",
+		regs_buff[7]);
+
+	fprintf(stdout,
+		"0x0010C: VFEIMC      (VF Extended Interrupt Mask Clear) 0x%08X\n",
+		regs_buff[8]);
+
+	fprintf(stdout,
+		"0x00110: VFEIAC      (VF Extended Interrupt Auto Clear) 0x%08X\n",
+		regs_buff[9]);
+
+	fprintf(stdout,
+		"0x00114: VFEIAM      (VF Extended Interrupt Auto Mask)  0x%08X\n",
+		regs_buff[10]);
+
+	fprintf(stdout,
+		"0x00820: VFEITR(0)   (VF Extended Interrupt Throttle)   0x%08X\n",
+		regs_buff[11]);
+
+	fprintf(stdout,
+		"0x00120: VFIVAR(0)   (VF Interrupt Vector Allocation)   0x%08X\n",
+		regs_buff[12]);
+
+	fprintf(stdout,
+		"0x00140: VFIVAR_MISC (VF Interrupt Vector Misc)         0x%08X\n",
+		regs_buff[13]);
+
+	fprintf(stdout,
+		"0x00104: VFPSRTYPE   (VF Replication Packet Split Type) 0x%08X\n",
+		regs_buff[28]);
+
+	for (i = 0; i < 2; i++)
+		fprintf(stdout,
+			"0x%05x: VFRDBAL(%d)  (VF Rx Desc. Base Addr Low %d)      0x%08X\n",
+			0x1000 + 0x40*i,
+			i, i,
+			regs_buff[14+i]);
+
+	for (i = 0; i < 2; i++)
+		fprintf(stdout,
+			"0x%05x: VFRDBAH(%d)  (VF Rx Desc. Base Addr High %d)     0x%08X\n",
+			0x1004 + 0x40*i,
+			i, i,
+			regs_buff[16+i]);
+
+	for (i = 0; i < 2; i++)
+		fprintf(stdout,
+			"0x%05x: VFRDLEN(%d)  (VF Rx Desc. Length %d)             0x%08X\n",
+			0x1008 + 0x40*i,
+			i, i,
+			regs_buff[18+i]);
+
+	for (i = 0; i < 2; i++)
+		fprintf(stdout,
+			"0x%05x: VFRDH(%d)    (VF Rx Desc. Head %d)               0x%08X\n",
+			0x1010 + 0x40*i,
+			i, i,
+			regs_buff[20+i]);
+
+	for (i = 0; i < 2; i++)
+		fprintf(stdout,
+			"0x%05x: VFRDT(%d)    (VF Rx Desc. Tail %d)               0x%08X\n",
+			0x1018 + 0x40*i,
+			i, i,
+			regs_buff[22+i]);
+
+	for (i = 0; i < 2; i++)
+		fprintf(stdout,
+			"0x%05x: VFRDT(%d)    (VF Rx Desc. Control %d),           0x%08X\n",
+			0x1028 + 0x40*i,
+			i, i,
+			regs_buff[24+i]);
+
+	for (i = 0; i < 2; i++)
+		fprintf(stdout,
+			"0x%05x: VFSRRCTL(%d) (VF Split Rx Control %d)            0x%08X\n",
+			0x1014 + 0x40*i,
+			i, i,
+			regs_buff[26+i]);
+
+	for (i = 0; i < 2; i++)
+		fprintf(stdout,
+			"0x%05x: VFTDBAL(%d)  (VF Tx Desc. Base Addr Low %d)      0x%08X\n",
+			0x2000 + 0x40*i,
+			i, i,
+			regs_buff[29+i]);
+
+	for (i = 0; i < 2; i++)
+		fprintf(stdout,
+			"0x%05x: VFTDBAH(%d)  (VF Tx Desc. Base Addr High %d)     0x%08X\n",
+			0x2004 + 0x40*i,
+			i, i,
+			regs_buff[31+i]);
+
+	for (i = 0; i < 2; i++)
+		fprintf(stdout,
+			"0x%05x: VFTDLEN(%d)  (VF Tx Desc. Length %d)             0x%08X\n",
+			0x2008 + 0x40*i,
+			i, i,
+			regs_buff[33+i]);
+
+	for (i = 0; i < 2; i++)
+		fprintf(stdout,
+			"0x%05x: VFTDH(%d)    (VF Tx Desc. Head %d)               0x%08X\n",
+			0x2010 + 0x40*i,
+			i, i,
+			regs_buff[35+i]);
+
+	for (i = 0; i < 2; i++)
+		fprintf(stdout,
+			"0x%05x: VFTDT(%d)    (VF Tx Desc. Tail %d)               0x%08X\n",
+			0x2018 + 0x40*i,
+			i, i,
+			regs_buff[37+i]);
+
+	for (i = 0; i < 2; i++)
+		fprintf(stdout,
+			"0x%05x: VFTDT(%d)    (VF Tx Desc. Control %d)            0x%08X\n",
+			0x2028 + 0x40*i,
+			i, i,
+			regs_buff[39+i]);
+
+	for (i = 0; i < 2; i++)
+		fprintf(stdout,
+			"0x%05x: VFTDWBAL(%d) (VF Tx Desc. Write Back Addr Lo %d) 0x%08X\n",
+			0x2038 + 0x40*i,
+			i, i,
+			regs_buff[41+i]);
+
+	for (i = 0; i < 2; i++)
+		fprintf(stdout,
+			"0x%05x: VFTDWBAH(%d) (VF Tx Desc. Write Back Addr Hi %d) 0x%08X\n",
+			0x203C + 0x40*i,
+			i, i,
+			regs_buff[43+i]);
+
+	return 0;
+}
-- 
1.8.3.1
