From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] ethtool: add register dump support for the stmmac driver.
Date: Tue,  6 Oct 2009 09:51:53 +0200
Message-ID: <1254815513-17603-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:37185 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755551AbZJFILU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 04:11:20 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id E16091CC
	for <netdev@vger.kernel.org>; Tue,  6 Oct 2009 07:52:04 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 97094704
	for <netdev@vger.kernel.org>; Tue,  6 Oct 2009 07:52:04 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds all MAC versions currently found in the STM embedded
platforms (core by Synopsys).
This supports both the DWC Ether MAC 10/100/1000 and the MAC
10/100 devices.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 Makefile.am    |    2 +-
 ethtool-util.h |    5 +++++
 ethtool.c      |    2 ++
 stmmac.c       |   56 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 64 insertions(+), 1 deletions(-)
 create mode 100644 stmmac.c

diff --git a/Makefile.am b/Makefile.am
index eac65fe..4e1a348 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -8,7 +8,7 @@ ethtool_SOURCES = ethtool.c ethtool-copy.h ethtool-util.h	\
 		  amd8111e.c de2104x.c e100.c e1000.c igb.c	\
 		  fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c	\
 		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
-		  smsc911x.c
+		  smsc911x.c stmmac.c
 
 dist-hook:
 	cp $(top_srcdir)/ethtool.spec $(distdir)
diff --git a/ethtool-util.h b/ethtool-util.h
index 5572771..4aba378 100644
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -73,4 +73,9 @@ int vioc_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 /* SMSC LAN911x/LAN921x embedded ethernet controller */
 int smsc911x_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 
+/* STMMAC embedded ethernet controller */
+int st_mac100_dump_regs(struct ethtool_drvinfo *info,
+			struct ethtool_regs *regs);
+int st_gmac_dump_regs(struct ethtool_drvinfo *info,
+			struct ethtool_regs *regs);
 #endif
diff --git a/ethtool.c b/ethtool.c
index 0110682..6c1eac2 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1189,6 +1189,8 @@ static struct {
 	{ "sky2", sky2_dump_regs },
         { "vioc", vioc_dump_regs },
         { "smsc911x", smsc911x_dump_regs },
+	{ "st_mac100", st_mac100_dump_regs },
+	{ "st_gmac", st_gmac_dump_regs },
 };
 
 static int dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
diff --git a/stmmac.c b/stmmac.c
new file mode 100644
index 0000000..9a19b4f
--- /dev/null
+++ b/stmmac.c
@@ -0,0 +1,56 @@
+/* Copyright (C) 2007-2009  STMicroelectronics Ltd
+ * Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
+ */
+#include <stdio.h>
+#include <string.h>
+#include "ethtool-util.h"
+
+int st_mac100_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
+{
+	int i;
+	unsigned int *stmmac_reg = (unsigned int *)regs->data;
+
+	fprintf(stdout, "ST MAC 10/100 Registers\n");
+	fprintf(stdout, "control reg  0x%08X\n", *stmmac_reg++);
+	fprintf(stdout, "addr HI 0x%08X\n", *stmmac_reg++);
+	fprintf(stdout, "addr LO 0x%08X\n", *stmmac_reg++);
+	fprintf(stdout, "multicast hash HI 0x%08X\n", *stmmac_reg++);
+	fprintf(stdout, "multicast hash LO 0x%08X\n", *stmmac_reg++);
+	fprintf(stdout, "MII addr 0x%08X\n", *stmmac_reg++);
+	fprintf(stdout, "MII data %08X\n", *stmmac_reg++);
+	fprintf(stdout, "flow control 0x%08X\n", *stmmac_reg++);
+	fprintf(stdout, "VLAN1 tag 0x%08X\n", *stmmac_reg++);
+	fprintf(stdout, "VLAN2 tag 0x%08X\n", *stmmac_reg++);
+	fprintf(stdout, "mac wakeup frame 0x%08X\n", *stmmac_reg++);
+	fprintf(stdout, "mac wakeup crtl 0x%08X\n", *stmmac_reg++);
+
+	fprintf(stdout, "\n");
+	fprintf(stdout, "DMA Registers\n");
+	for (i = 0; i < 9; i++)
+		fprintf(stdout, "CSR%d  0x%08X\n", i, *stmmac_reg++);
+
+	fprintf(stdout, "DMA cur tx buf addr 0x%08X\n", *stmmac_reg++);
+	fprintf(stdout, "DMA cur rx buf addr 0x%08X\n", *stmmac_reg++);
+
+	fprintf(stdout, "\n");
+
+	return 0;
+}
+
+int st_gmac_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
+{
+	int i;
+	unsigned int *stmmac_reg = (unsigned int *)regs->data;
+
+	fprintf(stdout, "ST GMAC Registers\n");
+	fprintf(stdout, "GMAC Registers\n");
+	for (i = 0; i < 55; i++)
+		fprintf(stdout, "Reg%d  0x%08X\n", i, *stmmac_reg++);
+
+	fprintf(stdout, "\n");
+	fprintf(stdout, "DMA Registers\n");
+	for (i = 0; i < 22; i++)
+		fprintf(stdout, "Reg%d  0x%08X\n", i, *stmmac_reg++);
+
+	return 0;
+}
-- 
1.6.0.4

