From: David Gibson <david@gibson.dropbear.id.au>
Subject: [4/5] Orinoco merge updates, part the fourth: don't set channel in managed mode
Date: Wed, 30 Mar 2005 13:44:49 +1000
Message-ID: <20050330034449.GJ6478@localhost.localdomain>
References: <20050330034238.GF6478@localhost.localdomain> <20050330034316.GG6478@localhost.localdomain> <20050330034403.GH6478@localhost.localdomain> <20050330034429.GI6478@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Pavel Roskin <proski@gnu.org>,
        Orinoco Development List <orinoco-devel@lists.sourceforge.net>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20050330034429.GI6478@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Don't attempt to manually set the channel in infrastructure mode, the
firmware doesn't like that much.  Also don't attempt to override the
firmware's default channel number for IBSS mode (I believe default
channel can vary by regulatory domain).

Signed-off-by: David Gibson <hermes@gibson.dropbear.id.au>

Index: working-2.6/drivers/net/wireless/orinoco.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco.c	2005-03-11 15:07:08.000000000 +1100
+++ working-2.6/drivers/net/wireless/orinoco.c	2005-03-11 16:13:31.000000000 +1100
@@ -1615,17 +1615,15 @@
 		return err;
 	}
 	/* Set the channel/frequency */
-	if (priv->channel == 0) {
-		printk(KERN_DEBUG "%s: Channel is 0 in __orinoco_program_rids()\n", dev->name);
-		if (priv->createibss)
-			priv->channel = 10;
-	}
-	err = hermes_write_wordrec(hw, USER_BAP, HERMES_RID_CNFOWNCHANNEL,
-				   priv->channel);
-	if (err) {
-		printk(KERN_ERR "%s: Error %d setting channel\n",
-		       dev->name, err);
-		return err;
+	if (priv->channel != 0 && priv->iw_mode != IW_MODE_INFRA) {
+		err = hermes_write_wordrec(hw, USER_BAP,
+					   HERMES_RID_CNFOWNCHANNEL,
+					   priv->channel);
+		if (err) {
+			printk(KERN_ERR "%s: Error %d setting channel %d\n",
+			       dev->name, err, priv->channel);
+			return err;
+		}
 	}
 
 	if (priv->has_ibss) {
@@ -2405,7 +2403,7 @@
 	/* By default use IEEE/IBSS ad-hoc mode if we have it */
 	priv->prefer_port3 = priv->has_port3 && (! priv->has_ibss);
 	set_port_type(priv);
-	priv->channel = 10; /* default channel, more-or-less arbitrary */
+	priv->channel = 0; /* use firmware default */
 
 	priv->promiscuous = 0;
 	priv->wep_on = 0;

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/people/dgibson
