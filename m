From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [SC92031]: Fix priv->lock context
Date: Fri, 6 Apr 2007 07:57:03 +1000
Message-ID: <20070405215703.GA21219@gondor.apana.org.au>
References: <20070404190402.609cbd65.akpm@linux-foundation.org> <20070405114431.GA10972@gondor.apana.org.au> <20070405.095929.79068467.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, adaplas@pol.net,
	jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2948 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1767362AbXDEV5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 17:57:45 -0400
Content-Disposition: inline
In-Reply-To: <20070405.095929.79068467.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 05, 2007 at 09:59:29AM -0700, David Miller wrote:
> 
> Where is the patch? :-)
> 
> Second time you've done this in two days Herbert, tsk tsk :)))

The patch was so easy that it was left as an exercise to the reader :)

[SC92031]: Fix priv->lock context

The spin_lock calls made in dev->open and dev->close must disable
BH since open/close are made in process context.  Conversely, the
call in dev->hard_start_xmit does not need to disable BH since it
is already executing with BH disabled.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index 15ceeae..5b7284c 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -963,7 +963,7 @@ static int sc92031_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto out;
 	}
 
-	spin_lock_bh(&priv->lock);
+	spin_lock(&priv->lock);
 
 	if (unlikely(!netif_carrier_ok(dev))) {
 		err = -ENOLINK;
@@ -1004,7 +1004,7 @@ static int sc92031_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 
 out_unlock:
-	spin_unlock_bh(&priv->lock);
+	spin_unlock(&priv->lock);
 
 out:
 	dev_kfree_skb(skb);
@@ -1041,12 +1041,12 @@ static int sc92031_open(struct net_device *dev)
 	priv->pm_config = 0;
 
 	/* Interrupts already disabled by sc92031_stop or sc92031_probe */
-	spin_lock(&priv->lock);
+	spin_lock_bh(&priv->lock);
 
 	_sc92031_reset(dev);
 	mmiowb();
 
-	spin_unlock(&priv->lock);
+	spin_unlock_bh(&priv->lock);
 	sc92031_enable_interrupts(dev);
 
 	if (netif_carrier_ok(dev))
@@ -1076,13 +1076,13 @@ static int sc92031_stop(struct net_device *dev)
 	/* Disable interrupts, stop Tx and Rx. */
 	sc92031_disable_interrupts(dev);
 
-	spin_lock(&priv->lock);
+	spin_lock_bh(&priv->lock);
 
 	_sc92031_disable_tx_rx(dev);
 	_sc92031_tx_clear(dev);
 	mmiowb();
 
-	spin_unlock(&priv->lock);
+	spin_unlock_bh(&priv->lock);
 
 	free_irq(pdev->irq, dev);
 	pci_free_consistent(pdev, TX_BUF_TOT_LEN, priv->tx_bufs,
@@ -1538,13 +1538,13 @@ static int sc92031_suspend(struct pci_dev *pdev, pm_message_t state)
 	/* Disable interrupts, stop Tx and Rx. */
 	sc92031_disable_interrupts(dev);
 
-	spin_lock(&priv->lock);
+	spin_lock_bh(&priv->lock);
 
 	_sc92031_disable_tx_rx(dev);
 	_sc92031_tx_clear(dev);
 	mmiowb();
 
-	spin_unlock(&priv->lock);
+	spin_unlock_bh(&priv->lock);
 
 out:
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
@@ -1564,12 +1564,12 @@ static int sc92031_resume(struct pci_dev *pdev)
 		goto out;
 
 	/* Interrupts already disabled by sc92031_suspend */
-	spin_lock(&priv->lock);
+	spin_lock_bh(&priv->lock);
 
 	_sc92031_reset(dev);
 	mmiowb();
 
-	spin_unlock(&priv->lock);
+	spin_unlock_bh(&priv->lock);
 	sc92031_enable_interrupts(dev);
 
 	netif_device_attach(dev);
