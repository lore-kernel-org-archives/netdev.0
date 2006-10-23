From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/3] ethtool: marvell register dump
Date: Mon, 23 Oct 2006 10:51:42 -0700
Message-ID: <20061023105142.13b507a7@dxpl.pdx.osdl.net>
References: <20061018104632.27a37d75@freekitty>
	<20061018105022.57b57b6a@freekitty>
	<453A63AF.1010505@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:39048 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964972AbWJWRw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2006 13:52:26 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <453A63AF.1010505@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a consolidation of earlier marvell register decode patches to ethtool.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 marvell.c |  106 ++++++++++++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 77 insertions(+), 29 deletions(-)

diff --git a/marvell.c b/marvell.c
index 244bb69..b73addc 100644
--- a/marvell.c
+++ b/marvell.c
@@ -88,10 +88,12 @@ static void dump_ram(const char *name, c
 	printf("End Address                      0x%08X\n", r[1]);
 	printf("Write Pointer                    0x%08X\n", r[2]);
 	printf("Read Pointer                     0x%08X\n", r[3]);
-	printf("Upper Threshold/Pause Packets    0x%08X\n", r[4]);
-	printf("Lower Threshold/Pause Packets    0x%08X\n", r[5]);
-	printf("Upper Threshold/High Priority    0x%08X\n", r[6]);
-	printf("Lower Threshold/High Priority    0x%08X\n", r[7]);
+	if (*name == 'R') {
+		printf("Upper Threshold/Pause Packets    0x%08X\n", r[4]);
+		printf("Lower Threshold/Pause Packets    0x%08X\n", r[5]);
+		printf("Upper Threshold/High Priority    0x%08X\n", r[6]);
+		printf("Lower Threshold/High Priority    0x%08X\n", r[7]);
+	}
 	printf("Packet Counter                   0x%08X\n", r[8]);
 	printf("Level                            0x%08X\n", r[9]);
 	printf("Test                             0x%08X\n", r[10]);
@@ -113,7 +115,7 @@ static void dump_fifo(const char *name, 
 	dump_timer("LED", p + 0x20);
 }
 
-static void dump_gmac_fifo(const void *p)
+static void dump_gmac_fifo(const char *name, const void *p)
 {
 	const u32 *r = p;
 	int i;
@@ -133,6 +135,7 @@ static void dump_gmac_fifo(const void *p
 		"FIFO Read Level",
 	};
 
+	printf("\n%s\n", name);
 	for (i = 0; i < sizeof(regs)/sizeof(regs[0]); ++i)
 		printf("%-32s 0x%08X\n", regs[i], r[i]);
 
@@ -140,6 +143,8 @@ static void dump_gmac_fifo(const void *p
 
 static void dump_mac(const u8 *r)
 {
+	u8 id;
+
 	printf("\nMAC Addresses\n");
 	printf("---------------\n");
 	dump_addr(1, r + 0x100);
@@ -147,10 +152,30 @@ static void dump_mac(const u8 *r)
 	dump_addr(3, r + 0x110);
 	printf("\n");
 
-	printf("Connector type               0x%02X\n", r[0x118]);
-	printf("PMD type                     0x%02X\n", r[0x119]);
-	printf("Configuration                0x%02X\n", r[0x11a]);
-	printf("Chip Revision                0x%02X\n", r[0x11b]);
+	printf("Connector type               0x%02X (%c)\n", 
+	       r[0x118], (char)r[0x118]);
+	printf("PMD type                     0x%02X (%c)\n",
+	       r[0x119], (char)r[0x119]);
+	printf("PHY type                     0x%02X\n", r[0x11d]);
+
+	id = r[0x11b];
+	printf("Chip Id                      0x%02X ", id);
+	switch (id) {
+	case 0x0a:	puts("Genesis");	break;
+	case 0xb0:	puts("Yukon");	break;
+	case 0xb1:	puts("Yukon-Lite");	break;
+	case 0xb2:	puts("Yukon-LP");	break;
+	case 0xb3:	puts("Yukon-2 XL");	break;
+	case 0xb4:	puts("Yukon-2 EC Ultra");	break;
+	case 0xb6:	puts("Yukon-2 EC");	break;
+ 	case 0xb7:	puts("Yukon-2 FE");	break;
+	default:	puts("Unknown");
+	}
+
+	printf(" (rev %d)\n", r[0x11a] & 0xf);
+
+	printf("Ram Buffer                   0x%02X\n", r[0x11c]);
+	       
 }
 	
 static void dump_gma(const char *name, const u8 *r)
@@ -181,21 +206,43 @@ static void dump_gmac(const char *name, 
 	dump_gma("Physical", data + 0x28);
 }
 
+static void dump_pci(const u8 *cfg)
+{
+	int i;
+
+	printf("\nPCI config\n----------\n");
+	for(i = 0; i < 0x80; i++) {
+		if (!(i & 15))
+			printf("%02x:", i);
+		printf(" %02x", cfg[i]);
+		if ((i & 15) == 15)
+			putchar('\n');
+	}
+	putchar('\n');
+}
+
+static void dump_control(u8 *r)
+{
+	printf("Control Registers\n");
+	printf("-----------------\n");
+
+	printf("Register Access Port             0x%02X\n", *r);
+	printf("LED Control/Status               0x%08X\n", *(u32 *) (r + 4));
+
+	printf("Interrupt Source                 0x%08X\n", *(u32 *) (r + 8));
+	printf("Interrupt Mask                   0x%08X\n", *(u32 *) (r + 0xc));
+	printf("Interrupt Hardware Error Source  0x%08X\n", *(u32 *) (r + 0x10));
+	printf("Interrupt Hardware Error Mask    0x%08X\n", *(u32 *) (r + 0x14));
+}
+
 int skge_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 {
 	const u32 *r = (const u32 *) regs->data;
 	int dual = !(regs->data[0x11a] & 1);
 
-	printf("Control Registers\n");
-	printf("-----------------\n");
+	dump_pci(regs->data + 0x380);
 
-	printf("Register Access Port             0x%08X\n", r[0]);
-	printf("LED Control/Status               0x%08X\n", r[1]);
-	printf("Interrupt Source                 0x%08X\n", r[2]);
-	printf("Interrupt Mask                   0x%08X\n", r[3]);
-	printf("Interrupt Hardware Error Source  0x%08X\n", r[4]);
-	printf("Interrupt Hardware Error Mask    0x%08X\n", r[5]);
-	printf("Special Interrupt Source         0x%08X\n", r[6]);
+	dump_control(regs->data);
 
 	printf("\nBus Management Unit\n");
 	printf("-------------------\n");
@@ -295,15 +342,9 @@ int sky2_dump_regs(struct ethtool_drvinf
 	const u32 *r = (const u32 *) regs->data;
 	int dual;
 
-	printf("Control Registers\n");
-	printf("-----------------\n");
+	dump_pci(regs->data + 0x1c00);
 
-	printf("Control/Status                   0x%08X\n", r[1]);
-	printf("Interrupt Source                 0x%08X\n", r[2]);
-	printf("Interrupt Mask                   0x%08X\n", r[3]);
-	printf("Interrupt Hardware Error Source  0x%08X\n", r[4]);
-	printf("Interrupt Hardware Error Mask    0x%08X\n", r[5]);
-	printf("Special Interrupt Source         0x%08X\n", r[6]);
+	dump_control(regs->data);
 
 	printf("\nBus Management Unit\n");
 	printf("-------------------\n");
@@ -319,8 +360,6 @@ int sky2_dump_regs(struct ethtool_drvinf
 	}
 
 	dump_mac(regs->data);
-	dump_gmac("GMAC 1", regs->data + 0x2800);
-	dump_gmac_fifo(regs->data + 0xc40);
 
 	printf("\nStatus BMU:\n-----------\n");
 	printf("Control                                0x%08X\n",
@@ -350,6 +389,14 @@ int sky2_dump_regs(struct ethtool_drvinf
 	dump_timer("TX status", regs->data + 0xec0);
 	dump_timer("ISR", regs->data + 0xed0);
 
+	printf("\nGMAC control             0x%04X\n", *(u32 *)(regs->data + 0xf00));
+	printf("GPHY control             0x%04X\n", *(u32 *)(regs->data + 0xf04));
+	printf("LINK control             0x%02hX\n", *(u16 *)(regs->data + 0xf10));
+
+	dump_gmac("GMAC 1", regs->data + 0x2800);
+	dump_gmac_fifo("Rx GMAC 1", regs->data + 0xc40);
+	dump_gmac_fifo("Tx GMAC 1", regs->data + 0xd40);
+
 	dump_queue2("Receive Queue 1", regs->data +0x400, 1);
 	dump_queue("Sync Transmit Queue 1", regs->data +0x600, 0);
 	dump_queue2("Async Transmit Queue 1", regs->data +0x680, 0);
@@ -364,7 +411,8 @@ int sky2_dump_regs(struct ethtool_drvinf
 		dump_ram("Sync Transmit RAMbuffer 2", regs->data+0xb00);
 		dump_ram("Async Transmit RAMbuffer 21", regs->data+0xb80);
 		dump_gmac("GMAC 2", regs->data + 0x3800);
-		dump_gmac_fifo(regs->data + 0xc40 + 128);
+		dump_gmac_fifo("Rx GMAC 2", regs->data + 0xc40 + 128);
+		dump_gmac_fifo("Tx GMAC 2", regs->data + 0xd40 + 128);
 	}
 
 	return 0;
-- 
1.4.2.3

