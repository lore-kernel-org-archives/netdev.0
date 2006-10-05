From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 2.6.18 8/6]: sb1250-mac: Fix an incorrect use of kfree()
Date: Thu, 5 Oct 2006 17:34:27 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0610051729140.22085@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:41487 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP
	id S1750773AbWJEQe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 12:34:28 -0400
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	Ralf Baechle <ralf@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 The pointer obtained by kmalloc() is treated with ALIGN() before passing 
it to kfree().  This may or may not cause problems depending on the 
minimum alignment enforced by kmalloc() and is ugly anyway.  This change 
records the original pointer returned by kmalloc() so that kfree() may 
safely use it.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---

 This applies on top of the "typedef" change (7/6).  Please consider.

  Maciej

patch-mips-2.6.18-20060920-sb1250-mac-kfree-0
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/drivers/net/sb1250-mac.c linux-mips-2.6.18-20060920/drivers/net/sb1250-mac.c
--- linux-mips-2.6.18-20060920.macro/drivers/net/sb1250-mac.c	2006-10-05 16:18:41.000000000 +0000
+++ linux-mips-2.6.18-20060920/drivers/net/sb1250-mac.c	2006-10-04 23:07:27.000000000 +0000
@@ -220,6 +220,7 @@ struct sbmacdma {
 	/*
 	 * This stuff is for maintenance of the ring
 	 */
+	void			*sbdma_dscrtable_un;
 	struct sbdmadscr	*sbdma_dscrtable;
 						/* base of descriptor table */
 	struct sbdmadscr	*sbdma_dscrtable_end;
@@ -640,15 +641,16 @@ static void sbdma_initctx(struct sbmacdm
 
 	d->sbdma_maxdescr = maxdescr;
 
-	d->sbdma_dscrtable = kmalloc((d->sbdma_maxdescr + 1) *
-				     sizeof(*d->sbdma_dscrtable), GFP_KERNEL);
+	d->sbdma_dscrtable_un = kmalloc((d->sbdma_maxdescr + 1) *
+					sizeof(*d->sbdma_dscrtable),
+					GFP_KERNEL);
 
 	/*
 	 * The descriptor table must be aligned to at least 16 bytes or the
 	 * MAC will corrupt it.
 	 */
 	d->sbdma_dscrtable = (struct sbdmadscr *)
-			     ALIGN((unsigned long)d->sbdma_dscrtable,
+			     ALIGN((unsigned long)d->sbdma_dscrtable_un,
 				   sizeof(*d->sbdma_dscrtable));
 
 	memset(d->sbdma_dscrtable, 0,
@@ -1309,9 +1311,9 @@ static int sbmac_initctx(struct sbmac_so
 
 static void sbdma_uninitctx(struct sbmacdma *d)
 {
-	if (d->sbdma_dscrtable) {
-		kfree(d->sbdma_dscrtable);
-		d->sbdma_dscrtable = NULL;
+	if (d->sbdma_dscrtable_un) {
+		kfree(d->sbdma_dscrtable_un);
+		d->sbdma_dscrtable = d->sbdma_dscrtable_un = NULL;
 	}
 
 	if (d->sbdma_ctxtable) {
