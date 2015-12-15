From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] mISDN: fix a loop count
Date: Tue, 15 Dec 2015 13:07:52 +0300
Message-ID: <20151215100752.GC20848@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20757 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964872AbbLOKIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 05:08:07 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two issue here.
1)  cnt starts as maxloop + 1 so all these loops iterate one more time
    than intended.
2)  At the end of the loop we test for "if (maxloop && !cnt)" but for
    the first two loops, we end with cnt equal to -1.  Changing this to
    a pre-op means we end with cnt set to 0.

Fixes: cae86d4a4e56 ('mISDN: Add driver for Infineon ISDN chipset family')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
index a77eea5..cb428b9 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -1170,7 +1170,7 @@ mISDNipac_irq(struct ipac_hw *ipac, int maxloop)
 
 	if (ipac->type & IPAC_TYPE_IPACX) {
 		ista = ReadIPAC(ipac, ISACX_ISTA);
-		while (ista && cnt--) {
+		while (ista && --cnt) {
 			pr_debug("%s: ISTA %02x\n", ipac->name, ista);
 			if (ista & IPACX__ICA)
 				ipac_irq(&ipac->hscx[0], ista);
@@ -1182,7 +1182,7 @@ mISDNipac_irq(struct ipac_hw *ipac, int maxloop)
 		}
 	} else if (ipac->type & IPAC_TYPE_IPAC) {
 		ista = ReadIPAC(ipac, IPAC_ISTA);
-		while (ista && cnt--) {
+		while (ista && --cnt) {
 			pr_debug("%s: ISTA %02x\n", ipac->name, ista);
 			if (ista & (IPAC__ICD | IPAC__EXD)) {
 				istad = ReadISAC(isac, ISAC_ISTA);
@@ -1200,7 +1200,7 @@ mISDNipac_irq(struct ipac_hw *ipac, int maxloop)
 			ista = ReadIPAC(ipac, IPAC_ISTA);
 		}
 	} else if (ipac->type & IPAC_TYPE_HSCX) {
-		while (cnt) {
+		while (--cnt) {
 			ista = ReadIPAC(ipac, IPAC_ISTAB + ipac->hscx[1].off);
 			pr_debug("%s: B2 ISTA %02x\n", ipac->name, ista);
 			if (ista)
@@ -1211,7 +1211,6 @@ mISDNipac_irq(struct ipac_hw *ipac, int maxloop)
 				mISDNisac_irq(isac, istad);
 			if (0 == (ista | istad))
 				break;
-			cnt--;
 		}
 	}
 	if (cnt > maxloop) /* only for ISAC/HSCX without PCI IRQ test */
