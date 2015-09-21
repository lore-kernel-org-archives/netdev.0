From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH] net: dsa: actually force the speed on the CPU port
Date: Mon, 21 Sep 2015 21:42:59 +0100
Message-ID: <E1Ze7vP-00073u-57@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:37441 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752306AbbIUUnE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 16:43:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 54d792f257c6 ("net: dsa: Centralise global and port setup
code into mv88e6xxx.") merged in the 4.2 merge window broke the link
speed forcing for the CPU port of Marvell DSA switches.  The original
code was:

        /* MAC Forcing register: don't force link, speed, duplex
         * or flow control state to any particular values on physical
         * ports, but force the CPU port and all DSA ports to 1000 Mb/s
         * full duplex.
         */
        if (dsa_is_cpu_port(ds, p) || ds->dsa_port_mask & (1 << p))
                REG_WRITE(addr, 0x01, 0x003e);
        else
                REG_WRITE(addr, 0x01, 0x0003);

but the new code does a read-modify-write:

                reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_PCS_CTRL);
                if (dsa_is_cpu_port(ds, port) ||
                    ds->dsa_port_mask & (1 << port)) {
                        reg |= PORT_PCS_CTRL_FORCE_LINK |
                                PORT_PCS_CTRL_LINK_UP |
                                PORT_PCS_CTRL_DUPLEX_FULL |
                                PORT_PCS_CTRL_FORCE_DUPLEX;
                        if (mv88e6xxx_6065_family(ds))
                                reg |= PORT_PCS_CTRL_100;
                        else
                                reg |= PORT_PCS_CTRL_1000;

The link speed in the PCS control register is a two bit field.  Forcing
the link speed in this way doesn't ensure that the bit field is set to
the correct value - on the hardware I have here, the speed bitfield
remains set to 0x03, resulting in the speed not being forced to gigabit.

We must clear both bits before forcing the link speed.

Fixes: 54d792f257c6 ("net: dsa: Centralise global and port setup code into mv88e6xxx.")
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
Dave,

Here's the updated patch, sorry for not sending it sooner.

Thanks.

 drivers/net/dsa/mv88e6xxx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 6f13f7206762..f8baa897d1a0 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2000,6 +2000,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		 */
 		reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_PCS_CTRL);
 		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
+			reg &= ~PORT_PCS_CTRL_UNFORCED;
 			reg |= PORT_PCS_CTRL_FORCE_LINK |
 				PORT_PCS_CTRL_LINK_UP |
 				PORT_PCS_CTRL_DUPLEX_FULL |
-- 
2.1.0
