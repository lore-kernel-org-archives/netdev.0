From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH] net/fec_mpc52xx: Fix kernel panic on FEC error
Date: Wed, 14 Oct 2009 11:40:00 -0600
Message-ID: <20091014173842.29148.27965.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Bonesio <bonesio@secretlab.ca>
To: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

From: John Bonesio <bonesio@secretlab.ca>

The MDIO bus cannot be accessed at interrupt context, but on an FEC
error, the fec_mpc52xx driver reset function also tries to reset the
PHY.  Since the error is detected at IRQ context, and the PHY functions
try to sleep, the kernel ends up panicking.

Resetting the PHY on an FEC error isn't even necessary.  This patch
solves the problem by removing the PHY reset entirely.

Signed-off-by: John Bonesio <bonesio@secretlab.ca>
Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

Hi David,

This patch is a bug fix that definitely needs to go in for 2.6.32.
I'll also be asking Greg to pick it up for the stable tree once it
is in mainline.

Thanks,
g.

 drivers/net/fec_mpc52xx.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index c40113f..66dace6 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -759,12 +759,6 @@ static void mpc52xx_fec_reset(struct net_device *dev)
 
 	mpc52xx_fec_hw_init(dev);
 
-	if (priv->phydev) {
-		phy_stop(priv->phydev);
-		phy_write(priv->phydev, MII_BMCR, BMCR_RESET);
-		phy_start(priv->phydev);
-	}
-
 	bcom_fec_rx_reset(priv->rx_dmatsk);
 	bcom_fec_tx_reset(priv->tx_dmatsk);
