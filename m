From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH] natsemi: make cable length magic configurable
Date: Thu, 24 Nov 2011 14:43:59 +0100
Message-ID: <201111241443.59191.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tim Hockin <thockin@hockin.org>, Olaf Kirch <okir@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59326 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751034Ab1KXNoE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Nov 2011 08:44:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Olaf Kirch <okir@suse.de>

We had a customer report concerning problems with a Natsemi DP83815-D
and long cables. With 100m cables, the network would be essentially dead,
not a single packet would get through either way. We had to apply the
patch below to make it work.

The patch adds a module parameter named "no_cable_magic" that does
two things:

 -	Unconditionally set the DSPCFG register to the
	fixed value. Without this change, the chip apparently
	never completes autonegotiation in the tested configuration.

	This has been an unconditional assignment for a long time,
	until this was changed in 2.6.11 (there's an interesting
	explanation in the ChangeLog, subject is
	"[PATCH] natsemi long cable fix", bk commit is
	5871b81bf2b5cf188deab0d414dce104fcb69ca6, git commit in
	tglx/history tree is c0d51c67f9c398279a95c5a7df387f2d9a586c98.

 -	Skip the bit banging in {,un}do_cable_magic. It seems that
	if we write the DSPCFG register as above, a rev D chip will report
	all cables as "short cables", which do_cable_magic detects, and
	trying to be helpful it will "fix" the attenuation coefficient.

I admit the use of a module parameter is ugly, but I didn't find a sane
way to fix this - especially since the magic registers we're changing
are undocumented.

Signed-off-by: Olaf Kirch <okir@suse.de>
Signed-off-by: Jean Delvare <jdelvare@suse.de>
---
We have been including this patch in the SLES kernels since
January 2007, and some POS customers still need that today.

 drivers/net/natsemi.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -83,6 +83,9 @@ static int rx_copybreak;
 
 static int dspcfg_workaround = 1;
 
+/* Set to disable cable magic - needed for very long cables on some chips */
+static int no_cable_magic;
+
 /* Used to pass the media type, etc.
    Both 'options[]' and 'full_duplex[]' should exist for driver
    interoperability.
@@ -141,6 +144,7 @@ module_param(mtu, int, 0);
 module_param(debug, int, 0);
 module_param(rx_copybreak, int, 0);
 module_param(dspcfg_workaround, int, 0);
+module_param(no_cable_magic, int, 0);
 module_param_array(options, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
 MODULE_PARM_DESC(mtu, "DP8381x MTU (all boards)");
@@ -148,6 +152,9 @@ MODULE_PARM_DESC(debug, "DP8381x default
 MODULE_PARM_DESC(rx_copybreak,
 	"DP8381x copy breakpoint for copy-only-tiny-frames");
 MODULE_PARM_DESC(dspcfg_workaround, "DP8381x: control DspCfg workaround");
+MODULE_PARM_DESC(no_cable_magic,
+	"DP8381x: set to 1 to disable magic workaround for short cables "
+	"(may help with long cables");
 MODULE_PARM_DESC(options,
 	"DP8381x: Bits 0-3: media type, bit 17: full duplex");
 MODULE_PARM_DESC(full_duplex, "DP8381x full duplex setting(s) (1)");
@@ -1221,7 +1228,7 @@ static void init_phy_fixup(struct net_de
 		writew(1, ioaddr + PGSEL);
 		writew(PMDCSR_VAL, ioaddr + PMDCSR);
 		writew(TSTDAT_VAL, ioaddr + TSTDAT);
-		np->dspcfg = (np->srr <= SRR_DP83815_C)?
+		np->dspcfg = (np->srr <= SRR_DP83815_C || no_cable_magic) ?
 			DSPCFG_VAL : (DSPCFG_COEF | readw(ioaddr + DSPCFG));
 		writew(np->dspcfg, ioaddr + DSPCFG);
 		writew(SDCFG_VAL, ioaddr + SDCFG);
@@ -1587,7 +1594,7 @@ static void do_cable_magic(struct net_de
 	if (dev->if_port != PORT_TP)
 		return;
 
-	if (np->srr >= SRR_DP83816_A5)
+	if (np->srr >= SRR_DP83816_A5 || no_cable_magic)
 		return;
 
 	/*
@@ -1632,7 +1639,7 @@ static void undo_cable_magic(struct net_
 	if (dev->if_port != PORT_TP)
 		return;
 
-	if (np->srr >= SRR_DP83816_A5)
+	if (np->srr >= SRR_DP83816_A5 || no_cable_magic)
 		return;
 
 	writew(1, ioaddr + PGSEL);

-- 
Jean Delvare
Suse L3
