From: Greg Ungerer <gerg@snapgear.com>
Subject: [RFC] net: allow FEC driver to not have attached PHY
Date: Thu, 7 Oct 2010 13:50:16 +1000
Message-ID: <201010070350.o973oGFE026910@goober.internal.moreton.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <gerg@uclinux.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dalsmrelay2.nai.com ([205.227.136.216]:24825 "HELO
	dalsmrelay2.nai.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752430Ab0JGDv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 23:51:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi All,

I have a board with a ColdFire SoC on it with the built-in FEC
ethernet module. On this hardware the FEC eth output is directly
attached to a RTL8305 4-port 10/100 switch. There is no conventional
PHY, the FEC output is direct into the uplink port of the switch
chip.

This setup doesn't work after the FEC code was switch to using
phylib. The driver used to have code to bypass phy detection/setup
for this particular board. The phylib probe finds nothing, and of
course sets a no-link condition.

So, what is the cleanest way to support this?

The attached patch adds a config option to do this sort of generically
for the FEC driver. But I am wondering if there isn't a better way?

Regards
Greg


---

[RFC] net: allow FEC driver to not have attached PHY

At least one board using the FEC driver does not have a conventional
PHY attached to it, it is directly connected to a somewhat simple
ethernet switch (the board is the SnapGear/LITE, and the attached
4-port ethernet switch is a RealTek RTL8305). This switch does not
present the usual register interface of a PHY, it presents nothing.
So a PHY scan will find nothing.

After the FEC driver was changed to use phylib for supporting phys
it no longer works on this particular board/switch setup.

Add a config option to allow configuring the FEC driver to not expect
a PHY to be present.

Signed-off-by: Greg Ungerer <gerg@uclinux.org>
---
 drivers/net/Kconfig |    9 +++++++++
 drivers/net/fec.c   |    7 +++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 93494e2..ee44728 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1934,6 +1934,15 @@ config FEC2
 	  Say Y here if you want to use the second built-in 10/100 Fast
 	  ethernet controller on some Motorola ColdFire processors.
 
+config FEC_NOPHY
+	bool "FEC has no attached PHY"
+	depends on FEC
+	help
+	  Some boards using the FEC driver may not have a PHY directly
+	  attached to it. Typically in this scenario the FEC output is
+	  directly connected to the input of an ethernet switch or hub.
+	  Say Y here if your hardware is like this.
+
 config FEC_MPC52xx
 	tristate "MPC52xx FEC driver"
 	depends on PPC_MPC52xx && PPC_BESTCOMM
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 768b840..3637f89 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -910,6 +910,11 @@ fec_enet_open(struct net_device *dev)
 	if (ret)
 		return ret;
 
+#ifdef CONFIG_FEC_NOPHY
+	/* No PHY connected, assume link is always up */
+	fep->link = 1;
+	fec_restart(dev, 0);
+#else
 	/* Probe and connect to PHY when open the interface */
 	ret = fec_enet_mii_probe(dev);
 	if (ret) {
@@ -917,6 +922,8 @@ fec_enet_open(struct net_device *dev)
 		return ret;
 	}
 	phy_start(fep->phy_dev);
+#endif
+
 	netif_start_queue(dev);
 	fep->opened = 1;
 	return 0;
