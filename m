From: Olaf Kirch <okir@suse.de>
Subject: [RFC] natsemi cable length woes
Date: Thu, 4 Jan 2007 16:39:49 +0100
Message-ID: <20070104153949.GA27978@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:36346 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964930AbXADPjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jan 2007 10:39:52 -0500
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 652CE217E6
	for <netdev@vger.kernel.org>; Thu,  4 Jan 2007 16:39:49 +0100 (CET)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here's a proposed patch that addresses a problem with natsemi
NICs and long cables we've been chasing (*sigh*).

I'm interested in feedback on how to fix this sanely.

Olaf
------------------------------------------------------------------
From: Olaf Kirch <okir@suse.de>
Subject: natsemi: make cable length magic configurable

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
	explanation in the ChangeLog, bk commit is
	5871b81bf2b5cf188deab0d414dce104fcb69ca6)

 -	skip the bit banging in {,un}do_cable_magic. It seems that
	if we write the DSPCFG register as above, a rev D chip will report
	all cables as "short cables", which do_cable_magic detects, and
	trying to be helpful it will "fix" the attenuation coefficient.

I admit the use of a module parameter is ugly, but I didn't find a sane
way to fix this - especially since the magic registers we're changing
are kind of underdocumented.

Signed-off-by: Olaf Kirch <okir@suse.de>

 drivers/net/natsemi.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

Index: linux-2.6.19/drivers/net/natsemi.c
===================================================================
--- linux-2.6.19.orig/drivers/net/natsemi.c
+++ linux-2.6.19/drivers/net/natsemi.c
@@ -72,6 +72,7 @@
 static int debug = -1;
 
 static int mtu;
+static int no_cable_magic;
 
 /* Maximum number of multicast addresses to filter (vs. rx-all-multicast).
    This chip uses a 512 element hash table based on the Ethernet CRC.  */
@@ -139,6 +140,7 @@ MODULE_LICENSE("GPL");
 module_param(mtu, int, 0);
 module_param(debug, int, 0);
 module_param(rx_copybreak, int, 0);
+module_param(no_cable_magic, int, 0);
 module_param_array(options, int, NULL, 0);
 module_param_array(full_duplex, int, NULL, 0);
 MODULE_PARM_DESC(mtu, "DP8381x MTU (all boards)");
@@ -148,6 +150,9 @@ MODULE_PARM_DESC(rx_copybreak,
 MODULE_PARM_DESC(options,
 	"DP8381x: Bits 0-3: media type, bit 17: full duplex");
 MODULE_PARM_DESC(full_duplex, "DP8381x full duplex setting(s) (1)");
+MODULE_PARM_DESC(no_cable_magic,
+	"DP8381x: set no_cable_magic=1 to disable magic workaround for short cables "
+	"(may help with long cables:-)");
 
 /*
 				Theory of Operation
@@ -1147,7 +1152,7 @@ static void init_phy_fixup(struct net_de
 		writew(1, ioaddr + PGSEL);
 		writew(PMDCSR_VAL, ioaddr + PMDCSR);
 		writew(TSTDAT_VAL, ioaddr + TSTDAT);
-		np->dspcfg = (np->srr <= SRR_DP83815_C)?
+		np->dspcfg = (np->srr <= SRR_DP83815_C || no_cable_magic)?
 			DSPCFG_VAL : (DSPCFG_COEF | readw(ioaddr + DSPCFG));
 		writew(np->dspcfg, ioaddr + DSPCFG);
 		writew(SDCFG_VAL, ioaddr + SDCFG);
@@ -1511,7 +1516,7 @@ static void do_cable_magic(struct net_de
 	if (dev->if_port != PORT_TP)
 		return;
 
-	if (np->srr >= SRR_DP83816_A5)
+	if (np->srr >= SRR_DP83816_A5 || no_cable_magic)
 		return;
 
 	/*
@@ -1556,7 +1561,7 @@ static void undo_cable_magic(struct net_
 	if (dev->if_port != PORT_TP)
 		return;
 
-	if (np->srr >= SRR_DP83816_A5)
+	if (np->srr >= SRR_DP83816_A5 || no_cable_magic)
 		return;
 
 	writew(1, ioaddr + PGSEL);

-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
