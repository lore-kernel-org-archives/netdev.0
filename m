From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [2/5 revised][BNX2]: Add missing wait in
 bnx2_init_5709_context().
Date: Mon, 04 Jun 2007 17:58:49 -0700
Message-ID: <1181005129.7230.2.camel@dell>
References: <1181001635.5275.13.camel@dell>
 <20070604233940.GB31462@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, andy@greyhouse.net,
	"netdev" <netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1235 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752201AbXFEASC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 20:18:02 -0400
In-Reply-To: <20070604233940.GB31462@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add missing wait in bnx2_init_5709_context().

For correctness, we need to wait for the MEM_INIT bit to be cleared
in the BNX2_CTX_COMMAND register before proceeding.

[Added return -EBUSY when the MEM_INIT bit doesn't clear, suggested
by Jeff Garzik.]

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 5d69e5b..0f861e2 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1778,6 +1778,15 @@ bnx2_init_5709_context(struct bnx2 *bp)
 	val = BNX2_CTX_COMMAND_ENABLED | BNX2_CTX_COMMAND_MEM_INIT | (1 << 12);
 	val |= (BCM_PAGE_BITS - 8) << 16;
 	REG_WR(bp, BNX2_CTX_COMMAND, val);
+	for (i = 0; i < 10; i++) {
+		val = REG_RD(bp, BNX2_CTX_COMMAND);
+		if (!(val & BNX2_CTX_COMMAND_MEM_INIT))
+			break;
+		udelay(2);
+	}
+	if (val & BNX2_CTX_COMMAND_MEM_INIT)
+		return -EBUSY;
+
 	for (i = 0; i < bp->ctx_pages; i++) {
 		int j;
 
@@ -3696,9 +3705,11 @@ bnx2_init_chip(struct bnx2 *bp)
 
 	/* Initialize context mapping and zero out the quick contexts.  The
 	 * context block must have already been enabled. */
-	if (CHIP_NUM(bp) == CHIP_NUM_5709)
-		bnx2_init_5709_context(bp);
-	else
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		rc = bnx2_init_5709_context(bp);
+		if (rc)
+			return rc;
+	} else
 		bnx2_init_context(bp);
 
 	if ((rc = bnx2_init_cpus(bp)) != 0)


