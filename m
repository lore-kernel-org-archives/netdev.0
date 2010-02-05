From: Amit Kucheria <amit.kucheria@canonical.com>
Subject: [PATCH 1/3] fec: fix uninitialized rx buffer usage
Date: Fri,  5 Feb 2010 10:56:20 -0800
Message-ID: <39ec69d1e3af809dcf210f4757ca2385efb5f9bc.1265396105.git.amit.kucheria@canonical.com>
References: <cover.1265396105.git.amit.kucheria@canonical.com>
Cc: Rob Herring <r.herring@freescale.com>, davem@davemloft.net,
	netdev@vger.kernel.org, s.hauer@pengutronix.de, gerg@uclinux.org,
	u.kleine-koenig@pengutronix.de, amit.kucheria@verdurent.com
To: List Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1265396105.git.amit.kucheria@canonical.com>
In-Reply-To: <cover.1265396105.git.amit.kucheria@canonical.com>
References: <cover.1265396105.git.amit.kucheria@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <r.herring@freescale.com>

The fec driver was enabling receive buffer descriptor without allocating
the buffers. Make sure the buffer descriptors are initialized to not
start receiving packets.

Open also calls fec_restart after the rx buffers are allocated. With the code
in fec_restart, it zeroes out the buffer descriptors that have just been
setup.

Signed-off-by: Rob Herring <r.herring@freescale.com>
Signed-off-by: Amit Kucheria <amit.kucheria@canonical.com>
Acked-by: Grant Likely <grant.likely@secretlab.ca>
---
 drivers/net/fec.c |   57 +++++++++++++++++++++++++++--------------------------
 1 files changed, 29 insertions(+), 28 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 16a1d58..9a8743d 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1658,6 +1658,7 @@ static int fec_enet_init(struct net_device *dev, int index)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
 	struct bufdesc *cbd_base;
+	struct bufdesc *bdp;
 	int i;
 
 	/* Allocate memory for buffer descriptors. */
@@ -1710,6 +1711,34 @@ static int fec_enet_init(struct net_device *dev, int index)
 	/* Set MII speed to 2.5 MHz */
 	fep->phy_speed = ((((clk_get_rate(fep->clk) / 2 + 4999999)
 					/ 2500000) / 2) & 0x3F) << 1;
+
+	/* Initialize the receive buffer descriptors. */
+	bdp = fep->rx_bd_base;
+	for (i = 0; i < RX_RING_SIZE; i++) {
+
+		/* Initialize the BD for every fragment in the page. */
+		bdp->cbd_sc = 0;
+		bdp++;
+	}
+
+	/* Set the last buffer to wrap */
+	bdp--;
+	bdp->cbd_sc |= BD_SC_WRAP;
+
+	/* ...and the same for transmit */
+	bdp = fep->tx_bd_base;
+	for (i = 0; i < TX_RING_SIZE; i++) {
+
+		/* Initialize the BD for every fragment in the page. */
+		bdp->cbd_sc = 0;
+		bdp->cbd_bufaddr = 0;
+		bdp++;
+	}
+
+	/* Set the last buffer to wrap */
+	bdp--;
+	bdp->cbd_sc |= BD_SC_WRAP;
+
 	fec_restart(dev, 0);
 
 	/* Queue up command to detect the PHY and initialize the
@@ -1730,7 +1759,6 @@ static void
 fec_restart(struct net_device *dev, int duplex)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
-	struct bufdesc *bdp;
 	int i;
 
 	/* Whack a reset.  We should wait for this. */
@@ -1768,33 +1796,6 @@ fec_restart(struct net_device *dev, int duplex)
 		}
 	}
 
-	/* Initialize the receive buffer descriptors. */
-	bdp = fep->rx_bd_base;
-	for (i = 0; i < RX_RING_SIZE; i++) {
-
-		/* Initialize the BD for every fragment in the page. */
-		bdp->cbd_sc = BD_ENET_RX_EMPTY;
-		bdp++;
-	}
-
-	/* Set the last buffer to wrap */
-	bdp--;
-	bdp->cbd_sc |= BD_SC_WRAP;
-
-	/* ...and the same for transmit */
-	bdp = fep->tx_bd_base;
-	for (i = 0; i < TX_RING_SIZE; i++) {
-
-		/* Initialize the BD for every fragment in the page. */
-		bdp->cbd_sc = 0;
-		bdp->cbd_bufaddr = 0;
-		bdp++;
-	}
-
-	/* Set the last buffer to wrap */
-	bdp--;
-	bdp->cbd_sc |= BD_SC_WRAP;
-
 	/* Enable MII mode */
 	if (duplex) {
 		/* MII enable / FD enable */
-- 
1.6.3.3
