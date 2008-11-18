From: Brice Goglin <brice@myri.com>
Subject: [PATCH net-next] myri10ge: remove hardcoded sram_size
Date: Tue, 18 Nov 2008 21:11:15 +0100
Message-ID: <49232163.9050902@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1948 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752360AbYKRULV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2008 15:11:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removes the use of a hardcoded sram_size, determine string_spec
location from the MCP header instead.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

Index: net-next-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- net-next-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-11-18 21:04:02.000000000 +0100
+++ net-next-2.6/drivers/net/myri10ge/myri10ge.c	2008-11-18 21:04:10.000000000 +0100
@@ -3737,6 +3737,7 @@
 	int i;
 	int status = -ENXIO;
 	int dac_enabled;
+	unsigned hdr_offset, ss_offset;
 
 	netdev = alloc_etherdev_mq(sizeof(*mgp), MYRI10GE_MAX_SLICES);
 	if (netdev == NULL) {
@@ -3804,14 +3805,6 @@
 	if (mgp->mtrr >= 0)
 		mgp->wc_enabled = 1;
 #endif
-	/* Hack.  need to get rid of these magic numbers */
-	mgp->sram_size =
-	    2 * 1024 * 1024 - (2 * (48 * 1024) + (32 * 1024)) - 0x100;
-	if (mgp->sram_size > mgp->board_span) {
-		dev_err(&pdev->dev, "board span %ld bytes too small\n",
-			mgp->board_span);
-		goto abort_with_mtrr;
-	}
 	mgp->sram = ioremap_wc(mgp->iomem_base, mgp->board_span);
 	if (mgp->sram == NULL) {
 		dev_err(&pdev->dev, "ioremap failed for %ld bytes at 0x%lx\n",
@@ -3819,9 +3812,19 @@
 		status = -ENXIO;
 		goto abort_with_mtrr;
 	}
+	hdr_offset =
+	    ntohl(__raw_readl(mgp->sram + MCP_HEADER_PTR_OFFSET)) & 0xffffc;
+	ss_offset = hdr_offset + offsetof(struct mcp_gen_header, string_specs);
+	mgp->sram_size = ntohl(__raw_readl(mgp->sram + ss_offset));
+	if (mgp->sram_size > mgp->board_span ||
+	    mgp->sram_size <= MYRI10GE_FW_OFFSET) {
+		dev_err(&pdev->dev,
+			"invalid sram_size %dB or board span %ldB\n",
+			mgp->sram_size, mgp->board_span);
+		goto abort_with_ioremap;
+	}
 	memcpy_fromio(mgp->eeprom_strings,
-		      mgp->sram + mgp->sram_size - MYRI10GE_EEPROM_STRINGS_SIZE,
-		      MYRI10GE_EEPROM_STRINGS_SIZE);
+		      mgp->sram + mgp->sram_size, MYRI10GE_EEPROM_STRINGS_SIZE);
 	memset(mgp->eeprom_strings + MYRI10GE_EEPROM_STRINGS_SIZE - 2, 0, 2);
 	status = myri10ge_read_mac_addr(mgp);
 	if (status)


