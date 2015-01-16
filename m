From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net 2/2] sh_eth: Fix ethtool operation crash when net device
 is down
Date: Fri, 16 Jan 2015 17:51:25 +0000
Message-ID: <1421430685.1222.192.camel@xylophone.i.decadent.org.uk>
References: <1421430592.1222.190.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: ct178-internal@lists.codethink.co.uk,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:47160 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350AbbAPRv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 12:51:29 -0500
In-Reply-To: <1421430592.1222.190.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver connects and disconnects the PHY device whenever the
net device is brought up and down.  The ethtool get_settings,
set_settings and nway_reset operations will dereference a null
or dangling pointer if called while it is down.

I think it would be preferable to keep the PHY connected, but there
may be good reasons not to.

As an immediate fix for this bug:
- Set the phydev pointer to NULL after disconnecting the PHY
- Change those three operations to return -ENODEV while the PHY is
  not connected

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 0c4d5b5..28e3822 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1827,6 +1827,9 @@ static int sh_eth_get_settings(struct net_device *ndev,
 	unsigned long flags;
 	int ret;
 
+	if (!mdp->phydev)
+		return -ENODEV;
+
 	spin_lock_irqsave(&mdp->lock, flags);
 	ret = phy_ethtool_gset(mdp->phydev, ecmd);
 	spin_unlock_irqrestore(&mdp->lock, flags);
@@ -1841,6 +1844,9 @@ static int sh_eth_set_settings(struct net_device *ndev,
 	unsigned long flags;
 	int ret;
 
+	if (!mdp->phydev)
+		return -ENODEV;
+
 	spin_lock_irqsave(&mdp->lock, flags);
 
 	/* disable tx and rx */
@@ -1875,6 +1881,9 @@ static int sh_eth_nway_reset(struct net_device *ndev)
 	unsigned long flags;
 	int ret;
 
+	if (!mdp->phydev)
+		return -ENODEV;
+
 	spin_lock_irqsave(&mdp->lock, flags);
 	ret = phy_start_aneg(mdp->phydev);
 	spin_unlock_irqrestore(&mdp->lock, flags);
@@ -2184,6 +2193,7 @@ static int sh_eth_close(struct net_device *ndev)
 	if (mdp->phydev) {
 		phy_stop(mdp->phydev);
 		phy_disconnect(mdp->phydev);
+		mdp->phydev = NULL;
 	}
 
 	free_irq(ndev->irq, ndev);
-- 
1.7.10.4
