From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch] ethtool (was Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow)
Date: Mon, 22 Nov 2004 00:28:50 +0100
Message-ID: <20041121232850.GB22460@electric-eye.fr.zoreil.com>
References: <41A09541.5040405@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
Content-Disposition: inline
In-Reply-To: <41A09541.5040405@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Dawe <rich@phekda.gotadsl.co.uk> :
> diff -pur ethtool-2/ethtool.c ethtool-2.dev/ethtool.c
> --- ethtool-2/ethtool.c	2004-07-02 16:28:48.000000000 +0100
> +++ ethtool-2.dev/ethtool.c	2004-11-21 10:09:13.000000000 +0000
> @@ -996,6 +996,7 @@ static struct {
>  } driver_list[] = {
>  	{ "8139cp", realtek_dump_regs },
>  	{ "8139too", realtek_dump_regs },
> +	{ "r8169", realtek_dump_regs },
>  	{ "de2104x", de2104x_dump_regs },
>  	{ "e1000", e1000_dump_regs },
>  	{ "natsemi", natsemi_dump_regs },
> diff -pur ethtool-2/realtek.c ethtool-2.dev/realtek.c
> --- ethtool-2/realtek.c	2004-04-09 19:44:55.000000000 +0100
> +++ ethtool-2.dev/realtek.c	2004-11-21 11:31:29.015997736 +0000
> @@ -43,7 +43,7 @@ static struct chip_info {
>  	{ "RTL-8100B/8139D",	HW_REVID(1, 1, 1, 0, 1, 0, 1) },
>  	{ "RTL-8139C+",		HW_REVID(1, 1, 1, 0, 1, 1, 0) },
>  	{ "RTL-8101",		HW_REVID(1, 1, 1, 0, 1, 1, 1) },
> -	{ "RTL-8169",		HW_REVID(0, 0, 0, 0, 0, 0, 0) },
> +	{ "RTL-8169",		HW_REVID(0, 0, 1, 0, 0, 0, 0) },

The initial value can be found in the datasheet and my Netgear adapter
announces HW_REVID(0, 0, 0, 0, 1, 0, 0). Joy.

Dave, Jeff, any remark about the patch below ?

Index: ethtool.c
===================================================================
RCS file: /cvsroot/gkernel/ethtool/ethtool.c,v
retrieving revision 1.50
diff -u -p -r1.50 ethtool.c
--- ethtool.c	2 Jul 2004 15:35:09 -0000	1.50
+++ ethtool.c	21 Nov 2004 23:22:54 -0000
@@ -996,6 +996,7 @@ static struct {
 } driver_list[] = {
 	{ "8139cp", realtek_dump_regs },
 	{ "8139too", realtek_dump_regs },
+	{ "r8169", realtek_dump_regs },
 	{ "de2104x", de2104x_dump_regs },
 	{ "e1000", e1000_dump_regs },
 	{ "natsemi", natsemi_dump_regs },
Index: realtek.c
===================================================================
RCS file: /cvsroot/gkernel/ethtool/realtek.c,v
retrieving revision 1.5
diff -u -p -r1.5 realtek.c
--- realtek.c	9 Apr 2004 18:44:55 -0000	1.5
+++ realtek.c	21 Nov 2004 23:22:55 -0000
@@ -22,6 +22,8 @@ enum chip_type {
 	RTL8139Cp,
 	RTL8101,
 	RTL8169,
+	RTL8169s,
+	RTL8110
 };
 
 enum {
@@ -44,6 +46,8 @@ static struct chip_info {
 	{ "RTL-8139C+",		HW_REVID(1, 1, 1, 0, 1, 1, 0) },
 	{ "RTL-8101",		HW_REVID(1, 1, 1, 0, 1, 1, 1) },
 	{ "RTL-8169",		HW_REVID(0, 0, 0, 0, 0, 0, 0) },
+	{ "RTL-8169s",		HW_REVID(0, 0, 0, 0, 1, 0, 0) },
+	{ "RTL-8110",		HW_REVID(0, 0, 1, 0, 0, 0, 0) },
 	{ }
 };
 
@@ -112,7 +116,10 @@ realtek_dump_regs(struct ethtool_drvinfo
 		data[0x08 >> 2],
 		data[0x0c >> 2]);
 
-	if (board_type == RTL8139Cp || board_type == RTL8169) {
+	if (board_type == RTL8139Cp ||
+	    board_type == RTL8169 ||
+	    board_type == RTL8169s ||
+	    board_type == RTL8110) {
 	fprintf(stdout,
 		"0x10: Dump Tally Counter Command   0x%08x 0x%08x\n",
 		data[0x10 >> 2],
@@ -148,7 +155,9 @@ realtek_dump_regs(struct ethtool_drvinfo
 		data[0x2C >> 2]);
 	}
 
-	if (board_type == RTL8169) {
+	if (board_type == RTL8169 ||
+	    board_type == RTL8169s ||
+	    board_type == RTL8110) {
 	fprintf(stdout,
 		"0x30: Flash memory read/write                 0x%08x\n",
 		data[0x30 >> 2]);
@@ -183,7 +192,9 @@ realtek_dump_regs(struct ethtool_drvinfo
 		v & (1 << 2) ? "on" : "off",
 		v & (1 << 4) ? ", RESET" : "");
 
-	if (board_type != RTL8169) {
+	if (board_type != RTL8169 &&
+	    board_type != RTL8169s &&
+	    board_type != RTL8110) {
 	fprintf(stdout,
 		"0x38: Current Address of Packet Read (C mode)     0x%04x\n"
 		"0x3A: Current Rx buffer address (C mode)          0x%04x\n",
@@ -218,7 +229,9 @@ realtek_dump_regs(struct ethtool_drvinfo
 		data8[0x51],
 		data8[0x52]);
 
-	if (board_type == RTL8169) {
+	if (board_type == RTL8169 ||
+	    board_type == RTL8169s ||
+	    board_type == RTL8110) {
 	fprintf(stdout,
 		"0x53: Config 2                                      0x%02x\n"
 		"0x54: Config 3                                      0x%02x\n"
@@ -257,7 +270,9 @@ realtek_dump_regs(struct ethtool_drvinfo
 		"0x5C: Multiple Interrupt Select                   0x%04x\n",
 		data[0x5c >> 2] & 0xffff);
 
-	if (board_type == RTL8169) {
+	if (board_type == RTL8169 ||
+	    board_type == RTL8169s ||
+	    board_type == RTL8110) {
 	fprintf(stdout,
 		"0x60: PHY access                              0x%08x\n"
 		"0x64: TBI control and status                  0x%08x\n",
@@ -448,7 +463,10 @@ realtek_dump_regs(struct ethtool_drvinfo
 	}
 	}
 
-	if (board_type == RTL8139Cp || board_type == RTL8169) {
+	if (board_type == RTL8139Cp ||
+	    board_type == RTL8169 ||
+	    board_type == RTL8169s ||
+	    board_type == RTL8110) {
 	v = data[0xE0 >> 2] & 0xffff;
 	fprintf(stdout,
 		"0xE0: C+ Command                                  0x%04x\n",
