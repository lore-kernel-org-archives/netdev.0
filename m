From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [FORCEDETH]: Fix xmit_lock/netif_tx_lock after merge
Date: Tue, 20 Jun 2006 17:04:50 +1000
Message-ID: <20060620070450.GA12609@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="EVF5PPMfhYS0aIcm"
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42759 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964895AbWFTHFL
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 03:05:11 -0400
To: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@osdl.org>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

[FORCEDETH]: Fix xmit_lock/netif_tx_lock after merge

There has been an update to the forcedeth driver that added a few new
uses of xmit_lock which is no longer meant to be used directly.  This
patch replaces them with netif_tx_lock_bh.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="forcedeth-xmit-lock.patch"

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 04a53f1..62b38a4 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -2991,13 +2991,13 @@ static int nv_set_settings(struct net_de
 	netif_carrier_off(dev);
 	if (netif_running(dev)) {
 		nv_disable_irq(dev);
-		spin_lock_bh(&dev->xmit_lock);
+		netif_tx_lock_bh(dev);
 		spin_lock(&np->lock);
 		/* stop engines */
 		nv_stop_rx(dev);
 		nv_stop_tx(dev);
 		spin_unlock(&np->lock);
-		spin_unlock_bh(&dev->xmit_lock);
+		netif_tx_unlock_bh(dev);
 	}
 
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
@@ -3131,13 +3131,13 @@ static int nv_nway_reset(struct net_devi
 		netif_carrier_off(dev);
 		if (netif_running(dev)) {
 			nv_disable_irq(dev);
-			spin_lock_bh(&dev->xmit_lock);
+			netif_tx_lock_bh(dev);
 			spin_lock(&np->lock);
 			/* stop engines */
 			nv_stop_rx(dev);
 			nv_stop_tx(dev);
 			spin_unlock(&np->lock);
-			spin_unlock_bh(&dev->xmit_lock);
+			netif_tx_unlock_bh(dev);
 			printk(KERN_INFO "%s: link down.\n", dev->name);
 		}
 
@@ -3244,7 +3244,7 @@ static int nv_set_ringparam(struct net_d
 
 	if (netif_running(dev)) {
 		nv_disable_irq(dev);
-		spin_lock_bh(&dev->xmit_lock);
+		netif_tx_lock_bh(dev);
 		spin_lock(&np->lock);
 		/* stop engines */
 		nv_stop_rx(dev);
@@ -3303,7 +3303,7 @@ static int nv_set_ringparam(struct net_d
 		nv_start_rx(dev);
 		nv_start_tx(dev);
 		spin_unlock(&np->lock);
-		spin_unlock_bh(&dev->xmit_lock);
+		netif_tx_unlock_bh(dev);
 		nv_enable_irq(dev);
 	}
 	return 0;
@@ -3339,13 +3339,13 @@ static int nv_set_pauseparam(struct net_
 	netif_carrier_off(dev);
 	if (netif_running(dev)) {
 		nv_disable_irq(dev);
-		spin_lock_bh(&dev->xmit_lock);
+		netif_tx_lock_bh(dev);
 		spin_lock(&np->lock);
 		/* stop engines */
 		nv_stop_rx(dev);
 		nv_stop_tx(dev);
 		spin_unlock(&np->lock);
-		spin_unlock_bh(&dev->xmit_lock);
+		netif_tx_unlock_bh(dev);
 	}
 
 	np->pause_flags &= ~(NV_PAUSEFRAME_RX_REQ|NV_PAUSEFRAME_TX_REQ);
@@ -3729,7 +3729,7 @@ static void nv_self_test(struct net_devi
 	if (test->flags & ETH_TEST_FL_OFFLINE) {
 		if (netif_running(dev)) {
 			netif_stop_queue(dev);
-			spin_lock_bh(&dev->xmit_lock);
+			netif_tx_lock_bh(dev);
 			spin_lock_irq(&np->lock);
 			nv_disable_hw_interrupts(dev, np->irqmask);
 			if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
@@ -3745,7 +3745,7 @@ static void nv_self_test(struct net_devi
 			nv_drain_rx(dev);
 			nv_drain_tx(dev);
 			spin_unlock_irq(&np->lock);
-			spin_unlock_bh(&dev->xmit_lock);
+			netif_tx_unlock_bh(dev);
 		}
 
 		if (!nv_register_test(dev)) {

--EVF5PPMfhYS0aIcm--
