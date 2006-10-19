From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ethtool: more sky2 decode
Date: Thu, 19 Oct 2006 14:53:04 -0700
Message-ID: <20061019145304.65e0e5fe@freekitty>
References: <20061018104632.27a37d75@freekitty>
	<20061018105022.57b57b6a@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:53932 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1946539AbWJSVy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 17:54:57 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061018105022.57b57b6a@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

More marvell register decode. Add chip table, pci config info
and other bits useful for debug.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 marvell.c |   80 +++++++++++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 59 insertions(+), 21 deletions(-)

diff --git a/marvell.c b/marvell.c
index e867521..9a14dd2 100644
--- a/marvell.c
+++ b/marvell.c
@@ -141,6 +141,8 @@ static void dump_gmac_fifo(const char *n
 
 static void dump_mac(const u8 *r)
 {
+	u8 id;
+
 	printf("\nMAC Addresses\n");
 	printf("---------------\n");
 	dump_addr(1, r + 0x100);
@@ -148,10 +150,30 @@ static void dump_mac(const u8 *r)
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
@@ -182,21 +204,43 @@ static void dump_gmac(const char *name, 
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
@@ -296,15 +340,9 @@ int sky2_dump_regs(struct ethtool_drvinf
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
-- 
1.4.1

