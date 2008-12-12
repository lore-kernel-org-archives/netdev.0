From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] ethtool: add register dump support for SMSC LAN9420
Date: Fri, 12 Dec 2008 08:57:33 +0000
Message-ID: <1229072253-7210-1-git-send-email-steve.glendinning@smsc.com>
Cc: Vlad Lyalikov <vlad.lyalikov@smsc.com>,
	Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.115] ([86.54.240.115]:60177 "EHLO
	drevil2.shawell.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755681AbYLLI5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 03:57:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for SMSC's LAN9420 PCI ethernet controller
to ethtool's dump registers (-d) command.

This patch is for use with the smsc9420 driver.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 Makefile.am    |    2 +-
 ethtool-util.h |    3 ++
 ethtool.c      |    2 +
 smsc9420.c     |   95 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 101 insertions(+), 1 deletions(-)
 create mode 100644 smsc9420.c

diff --git a/Makefile.am b/Makefile.am
index 43d1236..f1c945e 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -8,7 +8,7 @@ ethtool_SOURCES = ethtool.c ethtool-copy.h ethtool-util.h	\
 		  amd8111e.c de2104x.c e100.c e1000.c igb.c	\
 		  fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c	\
 		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
-		  smsc911x.c
+		  smsc911x.c smsc9420.c
 
 dist-hook:
 	cp $(top_srcdir)/ethtool.spec $(distdir)
diff --git a/ethtool-util.h b/ethtool-util.h
index 5572771..492ae25 100644
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -73,4 +73,7 @@ int vioc_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 /* SMSC LAN911x/LAN921x embedded ethernet controller */
 int smsc911x_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 
+/* SMSC LAN9420 PCI ethernet controller */
+int smsc9420_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
+
 #endif
diff --git a/ethtool.c b/ethtool.c
index a7c02d0..4b05243 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -14,6 +14,7 @@
  * amd8111e support by Reeja John <reeja.john@amd.com>
  * long arguments by Andi Kleen.
  * SMSC LAN911x support by Steve Glendinning <steve.glendinning@smsc.com>
+ * SMSC LAN9420 support by Steve Glendinning <steve.glendinning@smsc.com>
  *
  * TODO:
  *   * no-args => summary of each device (mii-tool style)
@@ -1195,6 +1196,7 @@ static struct {
 	{ "sky2", sky2_dump_regs },
         { "vioc", vioc_dump_regs },
         { "smsc911x", smsc911x_dump_regs },
+	{ "smsc9420", smsc9420_dump_regs },
 };
 
 static int dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
diff --git a/smsc9420.c b/smsc9420.c
new file mode 100644
index 0000000..0bdd78d
--- /dev/null
+++ b/smsc9420.c
@@ -0,0 +1,95 @@
+#include <stdio.h>
+#include <string.h>
+#include "ethtool-util.h"
+
+int smsc9420_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
+{
+	unsigned int *smsc_reg = (unsigned int *)regs->data;
+
+	fprintf(stdout, "LAN9420 DMAC Control & Status Registers\n");
+	fprintf(stdout, "offset 0x00, BUS_MODE        = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x04, TX_POLL_DEMAND  = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x08, TX_POLL_DEMAND  = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x0C, RX_BASE_ADDR    = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x10, TX_BASE_ADDR    = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x14, DMAC_STATUS     = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x18, DMAC_CONTROL    = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x1C, DMAC_INTR_ENA   = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x20, MISS_FRAME_CNT  = 0x%08X\n",*smsc_reg++);
+	smsc_reg += 11; /* 0x24 - 0x4C RESERVED */
+	fprintf(stdout, "offset 0x50, CUR_TX_BUF_ADDR = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x54, CUR_RX_BUF_ADDR = 0x%08X\n",*smsc_reg++);
+	smsc_reg += 10; /* 0x58 - 0x7C RESERVED */
+	fprintf(stdout, "\n");
+
+	fprintf(stdout, "LAN9420 MAC Control & Status Registers\n");
+	fprintf(stdout, "offset 0x80, MAC_CR          = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x84, ADDRH           = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x88, ADDRL           = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x8C, HASHH           = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x90, HASHL           = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x94, MIIADDR         = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x98, MIIDATA         = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x9C, FLOW            = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xA0, VLAN1           = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xA4, VLAN2           = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xA8, WUFF            = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xAC, WUCSR           = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xB0, COE_CR          = 0x%08X\n",*smsc_reg++);
+	smsc_reg += 3; /* 0xB4 - 0xBC RESERVED */
+	fprintf(stdout, "\n");
+
+	fprintf(stdout, "LAN9420 System Control & Status Registers\n");
+	fprintf(stdout, "offset 0xC0, ID_REV          = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xC4, INT_CTL         = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xC8, INT_STS         = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xCC, INT_CFG         = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xD0, GPIO_CFG        = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xD4, GPT_CFG         = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xD8, GPT_CNT         = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xDC, BUS_CFG         = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xE0, PMT_CTRL        = 0x%08X\n",*smsc_reg++);
+	smsc_reg += 4; /* 0xE4 - 0xF0 RESERVED */
+	fprintf(stdout, "offset 0xF4, FREE_RUN        = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xF8, E2P_CMD         = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xFC, E2P_DATA        = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "\n");
+
+	fprintf(stdout, "PHY Registers\n");
+	fprintf(stdout, "index 0, Basic Control Reg = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 1, Basic Status Reg  = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 2, PHY identifier 1  = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 3, PHY identifier 2  = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 4, Auto Negotiation Advertisement Reg = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 5, Auto Negotiation Link Partner Ability Reg = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 6, Auto Negotiation Expansion Register = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 7, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 8, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 9, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 10, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 11, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 12, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 13, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 14, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 15, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 16, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 17, Mode Control/Status Reg = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 18, Special Modes = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 19, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 20, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 21, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 22, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 23, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 24, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 25, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 26, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 27, Control/Status Indication = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 28, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 29, Interrupt Source Register = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 30, Interrupt Mask Register = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 31, PHY Special Control/Status Register = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "\n");
+
+	return 0;
+}
+
-- 
1.5.6.5

