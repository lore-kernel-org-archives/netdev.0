From: David Gibson <david@gibson.dropbear.id.au>
Subject: [5/5] Orinoco merge updates, part the fourth: consolidate allocation code
Date: Wed, 30 Mar 2005 13:45:59 +1000
Message-ID: <20050330034559.GK6478@localhost.localdomain>
References: <20050330034238.GF6478@localhost.localdomain> <20050330034316.GG6478@localhost.localdomain> <20050330034403.GH6478@localhost.localdomain> <20050330034429.GI6478@localhost.localdomain> <20050330034449.GJ6478@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Pavel Roskin <proski@gnu.org>,
        Orinoco Development List <orinoco-devel@lists.sourceforge.net>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20050330034449.GJ6478@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Consolidate allocation of firmware buffers.  In the process, remove
duplication of a workaround for an old symbol firmware bug, and fix a
bug where we could retry the workaround, even if it already failed to
help.

Signed-off-by: David Gibson <hermes@gibson.dropbear.id.au>

Index: working-2.6/drivers/net/wireless/orinoco.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco.c	2005-03-11 16:13:31.000000000 +1100
+++ working-2.6/drivers/net/wireless/orinoco.c	2005-03-11 16:21:55.000000000 +1100
@@ -1418,7 +1418,7 @@
 		return err;
 
 	err = hermes_allocate(hw, priv->nicbuf_size, &priv->txfid);
-	if (err == -EIO) {
+	if (err == -EIO && priv->nicbuf_size > TX_NICBUF_SIZE_BUG) {
 		/* Try workaround for old Symbol firmware bug */
 		printk(KERN_WARNING "%s: firmware ALLOC bug detected "
 		       "(old Symbol firmware?). Trying to work around... ",
@@ -2270,7 +2270,7 @@
 	priv->nicbuf_size = IEEE802_11_FRAME_LEN + ETH_HLEN;
 
 	/* Initialize the firmware */
-	err = hermes_init(hw);
+	err = orinoco_reinit_firmware(dev);
 	if (err != 0) {
 		printk(KERN_ERR "%s: failed to initialize firmware (err = %d)\n",
 		       dev->name, err);
@@ -2409,25 +2409,6 @@
 	priv->wep_on = 0;
 	priv->tx_key = 0;
 
-	err = hermes_allocate(hw, priv->nicbuf_size, &priv->txfid);
-	if (err == -EIO) {
-		/* Try workaround for old Symbol firmware bug */
-		printk(KERN_WARNING "%s: firmware ALLOC bug detected "
-		       "(old Symbol firmware?). Trying to work around... ",
-		       dev->name);
-		
-		priv->nicbuf_size = TX_NICBUF_SIZE_BUG;
-		err = hermes_allocate(hw, priv->nicbuf_size, &priv->txfid);
-		if (err)
-			printk("failed!\n");
-		else
-			printk("ok.\n");
-	}
-	if (err) {
-		printk("%s: Error %d allocating Tx buffer\n", dev->name, err);
-		goto out;
-	}
-
 	/* Make the hardware available, as long as it hasn't been
 	 * removed elsewhere (e.g. by PCMCIA hot unplug) */
 	spin_lock_irq(&priv->lock);

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/people/dgibson
