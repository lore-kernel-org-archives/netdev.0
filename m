From: Jelle Foks <jelle@foks.8m.com>
Subject: r8169.c broke for me from 2.6.20.4 to 2.6.21
Date: Mon, 30 Apr 2007 01:31:23 -0400
Message-ID: <46357F2B.2070806@foks.8m.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-02.tampabay.rr.com ([65.32.5.132]:46440 "EHLO
	ms-smtp-02.tampabay.rr.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423039AbXD3Fb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 01:31:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

When I upgraded from 2.6.20.4 to 2.6.21, the r8169 kept thinking that
the link was down, while with 2.6.20.4, the link was detected at 10Mbit/s.

This is on a (I admit, probably out-of-spec) cable to a Gbit switch from
the r8169 on the mainboard of an AOpen XC Cube EX761.

With 2.6.20.4, the 'link' goes through these states when I boot:

r8169: eth1: link down
ADDRCONF(NETDEV_UP): link is not ready
ADDRCONF(NETDEV_CHANGE):  link becomes ready
r8169: eth1: link up

And then it works (at 10Mbit). With 2.6.21, the link stays down.

When I revert rtl8169_xmii_reset_enable() to the code from the driver in
2.6.20.4 (see the diff below), then it works again, with the same
behaviour as with 2.6.20.4.

My guess is that the 2.6.20.4 code resets the mii in a way that allows
the chip to see a link on my (bad) cable, and the 2.6.21 code does not...

Jelle.

--- linux-2.6.21/drivers/net/r8169.c    2007-04-25 23:08:32.000000000 -0400
+++ linux-2.6.21-jelle/drivers/net/r8169.c      2007-04-30
01:25:59.000000000 -0400
@@ -574,8 +574,10 @@
 {
        unsigned int val;

-       val = mdio_read(ioaddr, MII_BMCR) | BMCR_RESET;
-       mdio_write(ioaddr, MII_BMCR, val & 0xffff);
+       mdio_write(ioaddr, MII_BMCR, BMCR_RESET);
+       val = mdio_read(ioaddr, MII_BMCR);
+/*      val = mdio_read(ioaddr, MII_BMCR) | BMCR_RESET;*/
+/*      mdio_write(ioaddr, MII_BMCR, val & 0xffff);*/
 }

 static void rtl8169_check_link_status(struct net_device *dev,


