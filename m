From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: [PATCH net] at803x: insure minimum delay for SGMII link AN completion ckeck
Date: Fri, 10 Feb 2017 18:42:23 +0200
Message-ID: <1486744943-12474-1-git-send-email-claudiu.manoil@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0064.outbound.protection.outlook.com ([104.47.38.64]:65383
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751060AbdBJQ6l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Feb 2017 11:58:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit: f62265b "at803x: double check SGMII side autoneg"
introduced a regression for the p1010rdb board which has
two of the ethernet controllers (eTSEC) connected through
SGMII links to external Atheros SGMII AR8033 PHYs.
The issue consists in a dead link for these ports, and is
100% reproducible on kernel 4.9 (and later):

root@p1010rdb-pb:~# ifconfig eth2 172.16.1.1
[  203.274263] IPv6: ADDRCONF(NETDEV_UP): eth2: link is not ready
root@p1010rdb-pb:~# [  206.408255] 803x_aneg_done: SGMII link is not ok

root@p1010rdb-pb:~# ethtool eth2
Settings for eth2:
        Supported ports: [ MII ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Supported pause frame use: Symmetric Receive-only
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Advertised pause frame use: No
        Advertised auto-negotiation: Yes
        Link partner advertised link modes:  10baseT/Half 10baseT/Full
                                             100baseT/Half 100baseT/Full
                                             1000baseT/Half 1000baseT/Full
        Link partner advertised pause frame use: Symmetric Receive-only
        Link partner advertised auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Full
        Port: MII
        PHYAD: 2
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: g
        Wake-on: d
        Current message level: 0x0000003f (63)
                               drv probe link timer ifdown ifup
        Link detected: no

Insuring up to 100 usecs for the SGMII link side AN to complete
proves to be enough to have a working SGMII link, for this board.
The need for a delay for the SGMII link side may be explained by
the fact that there are two levels of auto-negotiation (AN) for a
SGMII link.  First the PHY autonegotiates the link parameters w/
its link partner over the copper link. In the second stage, the
AN results are then passed to the eTSEC MAC over the SGMII link
using the Clause 37 auto-negotiation functionality.  While the
aneg_done() hook is called by the phylib state machine to check
for the completion of the 1st stage AN of the external PHY,
there's no mechanism to insure proper AN completion of the internal
SGMII link (which is actually handled on the eTSEC side by a
"internal PHY", called TBI).

Fixes: f62265b "at803x: double check SGMII side autoneg"

Signed-off-by: Claudiu Manoil <claudiu.manoil@nxp.com>
---
 drivers/net/phy/at803x.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index a52b560..55fa7c4 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -366,6 +366,7 @@ static void at803x_link_change_notify(struct phy_device *phydev)
 static int at803x_aneg_done(struct phy_device *phydev)
 {
 	int ccr;
+	int timeout = 100; /* usecs */
 
 	int aneg_done = genphy_aneg_done(phydev);
 	if (aneg_done != BMSR_ANEGCOMPLETE)
@@ -383,7 +384,13 @@ static int at803x_aneg_done(struct phy_device *phydev)
 	phy_write(phydev, AT803X_REG_CHIP_CONFIG, ccr & ~AT803X_BT_BX_REG_SEL);
 
 	/* check if the SGMII link is OK. */
-	if (!(phy_read(phydev, AT803X_PSSR) & AT803X_PSSR_MR_AN_COMPLETE)) {
+	do {
+		if (phy_read(phydev, AT803X_PSSR) & AT803X_PSSR_MR_AN_COMPLETE)
+			break;
+		udelay(1);
+	} while (--timeout);
+
+	if (!timeout) {
 		pr_warn("803x_aneg_done: SGMII link is not ok\n");
 		aneg_done = 0;
 	}
-- 
1.7.11.7
