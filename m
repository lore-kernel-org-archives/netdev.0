From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Marvell 88E609x switch?
Date: Thu, 26 Feb 2009 16:11:07 +0100
Message-ID: <20090226151107.GN17040@xi.wantstofly.org>
References: <49A49C06.90908@mlbassoc.com> <20090225131550.GA24996@xi.wantstofly.org> <49A5B877.8080403@mlbassoc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Gary Thomas <gary@mlbassoc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:44558 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754240AbZBZPLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 10:11:10 -0500
Content-Disposition: inline
In-Reply-To: <49A5B877.8080403@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 25, 2009 at 02:30:31PM -0700, Gary Thomas wrote:

> >> Is there support for this device anywhere?  In particular,
> >> the M88E6095 switch.
> > 
> > Not at the moment, but it should be easy enough to add.  If your
> > board already runs on 2.6.28+, I can whip up some patches for you
> > to try from the docs I have for that part.
> 
> That would be much appreciated, thanks.

I noticed that the 6095/6095F are quite similar to the 6131 as far
as the register set goes.  So something along these lines (hacky
patch, breaks 6131, not for mainline) might just work to detect
single 6095s (cascading DSA chips is something that needs more work,
let's get the single-chip case working first).

The other thing you'll need to do is create dsa platform devices
for your switch chips, a la how it's done in arch/arm/mach-orion5x/
or arch/arm/mach-kirkwood/ for example -- you need to pass in a struct
device * for your network device, a struct device * for your mii bus,
the switch MII address on the MII bus, and names of the individual
ports (where you'll specify "cpu" for the port on the switch chip that
the CPU is connected to).

Let me know if this works.



diff --git a/net/dsa/mv88e6131.c b/net/dsa/mv88e6131.c
index 374d46a..d530e63 100644
--- a/net/dsa/mv88e6131.c
+++ b/net/dsa/mv88e6131.c
@@ -21,6 +21,8 @@ static char *mv88e6131_probe(struct mii_bus *bus, int sw_addr)
 	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
 	if (ret >= 0) {
 		ret &= 0xfff0;
+		if (ret == 0x0950)
+			return "Marvell 88E6095/88E6095F";
 		if (ret == 0x1060)
 			return "Marvell 88E6131";
 	}
@@ -36,7 +38,7 @@ static int mv88e6131_switch_reset(struct dsa_switch *ds)
 	/*
 	 * Set all ports to the disabled state.
 	 */
-	for (i = 0; i < 8; i++) {
+	for (i = 0; i < 11; i++) {
 		ret = REG_READ(REG_PORT(i), 0x04);
 		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
 	}
@@ -268,7 +270,7 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	for (i = 0; i < 6; i++) {
+	for (i = 0; i < 11; i++) {
 		ret = mv88e6131_setup_port(ds, i);
 		if (ret < 0)
 			return ret;
@@ -279,7 +281,7 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 
 static int mv88e6131_port_to_phy_addr(int port)
 {
-	if (port >= 0 && port != 3 && port <= 7)
+	if (port >= 0 && port <= 11)
 		return port;
 	return -1;
 }
