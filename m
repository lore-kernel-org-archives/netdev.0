From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 04/11] net: dsa: qca8k: do not cache unneeded EEE fields
Date: Tue,  1 Aug 2017 16:32:34 -0400
Message-ID: <20170801203241.22294-5-vivien.didelot@savoirfairelinux.com>
References: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The qca8k driver is currently caching a bitfield of the supported member
of a ethtool_eee private structure, which is unused.

Only the eee_enabled field of the private ethtool_eee copy is updated,
thus using p->advertised and p->lp_advertised is also erroneous.

Remove the usage of these private ethtool_eee members and only rely on
phy_ethtool_get_eee to assign the eee_active member.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/qca8k.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 9d6b5d2f7a4a..c316c55aabc6 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -658,12 +658,8 @@ static int
 qca8k_eee_init(struct dsa_switch *ds, int port,
 	       struct phy_device *phy)
 {
-	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
-	struct ethtool_eee *p = &priv->port_sts[port].eee;
 	int ret;
 
-	p->supported = (SUPPORTED_1000baseT_Full | SUPPORTED_100baseT_Full);
-
 	ret = phy_init_eee(phy, 0);
 	if (ret)
 		return 0;
@@ -705,12 +701,7 @@ qca8k_get_eee(struct dsa_switch *ds, int port,
 	int ret;
 
 	ret = phy_ethtool_get_eee(netdev->phydev, p);
-	if (!ret)
-		e->eee_active =
-			!!(p->supported & p->advertised & p->lp_advertised);
-	else
-		e->eee_active = 0;
-
+	e->eee_active = p->eee_active;
 	e->eee_enabled = p->eee_enabled;
 
 	return ret;
-- 
2.13.3
