From: Matt Porter <mporter@kernel.crashing.org>
Subject: [PATCH] emac: filter illegal frame sizes
Date: Fri, 18 Feb 2005 10:12:46 -0700
Message-ID: <20050218101245.D11439@cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linuxppc-embedded@ozlabs.org
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix to drop frames that are too large for the current MTU.

Signed-off-by: Matt Porter <mporter@kernel.crashing.org>

===== drivers/net/ibm_emac/ibm_emac_core.c 1.9 vs edited =====
--- 1.9/drivers/net/ibm_emac/ibm_emac_core.c	2005-01-20 13:25:10 -07:00
+++ edited/drivers/net/ibm_emac/ibm_emac_core.c	2005-02-18 09:23:08 -07:00
@@ -665,14 +665,21 @@
 				fep->rx_skb[i]->dev = dev;
 				fep->rx_skb[i]->protocol =
 				    eth_type_trans(fep->rx_skb[i], dev);
-				error = netif_rx(fep->rx_skb[i]);
 
-				if ((error == NET_RX_DROP) ||
-				    (error == NET_RX_BAD)) {
-					fep->stats.rx_dropped++;
+				/* Filter frame sizes > our MTU */
+				if (fep->rx_skb[i]->len <= (dev->mtu + ENET_HEADER_SIZE + ENET_FCS_SIZE)) {
+					error = netif_rx(fep->rx_skb[i]);
+					if ((error == NET_RX_DROP) ||
+							(error == NET_RX_BAD)) {
+						fep->stats.rx_dropped++;
+					} else {
+						fep->stats.rx_packets++;
+						fep->stats.rx_bytes += frame_length;
+					}
 				} else {
-					fep->stats.rx_packets++;
-					fep->stats.rx_bytes += frame_length;
+					dev_kfree_skb(fep->rx_skb[i]);
+					fep->stats.rx_length_errors++;
+					fep->stats.rx_errors++;
 				}
 				fep->rx_skb[i] = NULL;
 			} else {
@@ -752,15 +759,23 @@
 					fep->rx_skb[buf[0]]->protocol =
 					    eth_type_trans(fep->rx_skb[buf[0]],
 							   dev);
-					error = netif_rx(fep->rx_skb[buf[0]]);
 
-					if ((error == NET_RX_DROP)
-					    || (error == NET_RX_BAD)) {
-						fep->stats.rx_dropped++;
+					/* Filter frame sizes > our MTU */
+					if (fep->rx_skb[buf[0]]->len <= (dev->mtu + ENET_HEADER_SIZE + ENET_FCS_SIZE)) {
+						error = netif_rx(fep->rx_skb[buf[0]]);
+
+						if ((error == NET_RX_DROP)
+								|| (error == NET_RX_BAD)) {
+							fep->stats.rx_dropped++;
+						} else {
+							fep->stats.rx_packets++;
+							fep->stats.rx_bytes +=
+								fep->rx_skb[buf[0]]->len;
+						}
 					} else {
-						fep->stats.rx_packets++;
-						fep->stats.rx_bytes +=
-						    fep->rx_skb[buf[0]]->len;
+						fep->stats.rx_length_errors++;
+						fep->stats.rx_errors++;
+						dev_kfree_skb(fep->rx_skb[buf[0]]);
 					}
 					for (b = 0; b < bnum; b++)
 						fep->rx_skb[buf[b]] = NULL;
@@ -1041,7 +1056,7 @@
 	/* set speed (default is 10Mb) */
 	switch (speed) {
 	case SPEED_1000:
-		mode_reg |= EMAC_M1_JUMBO_ENABLE | EMAC_M1_RFS_16K;
+		mode_reg |= EMAC_M1_RFS_16K;
 		if (fep->rgmii_dev) {
 			struct ibm_ocp_rgmii *rgmii = RGMII_PRIV(fep->rgmii_dev);
 
@@ -1118,6 +1133,7 @@
 {
 	struct ocp_enet_private *fep = dev->priv;
 	int old_mtu = dev->mtu;
+	unsigned long mode_reg;
 	emac_t *emacp = fep->emacp;
 	u32 em0mr0;
 	int i, full;
@@ -1160,10 +1176,17 @@
 			fep->rx_skb[i] = NULL;
 		}
 
-		/* Set new rx_buffer_size and advertise new mtu */
-		fep->rx_buffer_size =
-		    new_mtu + ENET_HEADER_SIZE + ENET_FCS_SIZE;
+		/* Set new rx_buffer_size, jumbo cap, and advertise new mtu */
+		mode_reg = in_be32(&emacp->em0mr1);
+		if (new_mtu > ENET_DEF_MTU_SIZE) {
+			mode_reg |= EMAC_M1_JUMBO_ENABLE;
+			fep->rx_buffer_size = EMAC_MAX_FRAME;
+		} else {
+			mode_reg &= ~EMAC_M1_JUMBO_ENABLE;
+			fep->rx_buffer_size = ENET_DEF_BUF_SIZE;
+		}
 		dev->mtu = new_mtu;
+		out_be32(&emacp->em0mr1, mode_reg);
 
 		/* Re-init rx skbs */
 		fep->rx_slot = 0;
===== drivers/net/ibm_emac/ibm_emac_core.h 1.3 vs edited =====
--- 1.3/drivers/net/ibm_emac/ibm_emac_core.h	2005-02-08 22:24:52 -07:00
+++ edited/drivers/net/ibm_emac/ibm_emac_core.h	2005-02-18 09:30:07 -07:00
@@ -77,6 +77,8 @@
 
 #define ENET_HEADER_SIZE	14
 #define ENET_FCS_SIZE		4
+#define ENET_DEF_MTU_SIZE	1500
+#define ENET_DEF_BUF_SIZE	(ENET_DEF_MTU_SIZE + ENET_HEADER_SIZE + ENET_FCS_SIZE)
 #define EMAC_MIN_FRAME		64
 #define EMAC_MAX_FRAME		9018
 #define EMAC_MIN_MTU		(EMAC_MIN_FRAME - ENET_HEADER_SIZE - ENET_FCS_SIZE)
