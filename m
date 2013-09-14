From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: call phy_scan_fixups() after PHY reset
Date: Sat, 14 Sep 2013 04:10:37 +0400
Message-ID: <201309140410.38396.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org,
	laurent.pinchart+renesas@ideasonboard.com
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sometimes the PHY reset that sh_eth_phy_start() does effects the PHY registers
registers values of which are vital for the correct functioning of the driver.
Unfortunately, the existing PHY platform fixup mechanism doesn't help  here as
it only hooks PHY resets done by ioctl() calls. Calling phy_scan_fixups() from
the driver helps here. With a proper platform fixup, this fixes NFS timeouts on
the SH-Mobile Lager board. 

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is against Dave Miller's 'net.git' tree.
If desired, I can merge it with the Lager platform patch I'll post next, altho
there's only runtime interdependency between them...

 drivers/net/ethernet/renesas/sh_eth.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -1701,6 +1701,11 @@ static int sh_eth_phy_start(struct net_d
 
 	/* reset phy - this also wakes it from PDOWN */
 	phy_write(mdp->phydev, MII_BMCR, BMCR_RESET);
+	/* some boards need their registers set to non-default state */
+	ret = phy_scan_fixups(mdp->phydev);
+	if (ret)
+		return ret;
+
 	phy_start(mdp->phydev);
 
 	return 0;
