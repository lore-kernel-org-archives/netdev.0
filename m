From: David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Subject: [2/8] orinoco: Use netif_carrier functions instead of homegrown flag
Date: Wed, 12 Jan 2005 16:25:43 +1100
Message-ID: <20050112052543.GC30426@localhost.localdomain>
References: <20050112052352.GA30426@localhost.localdomain> <20050112052434.GB30426@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20050112052434.GB30426-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Removes the orinoco driver's custom and dodgy "connected" variable
used to track whether or not we're associated with an AP.  Replaces it
instead with netif_carrier_ok() settings.

Signed-off-by: David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>

Index: working-2.6/drivers/net/wireless/orinoco.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco.c	2004-11-03 14:32:15.000000000 +1100
+++ working-2.6/drivers/net/wireless/orinoco.c	2004-11-03 16:16:57.000000000 +1100
@@ -784,7 +784,7 @@
 		return 1;
 	}
 
-	if (! priv->connected) {
+	if (! netif_carrier_ok(dev)) {
 		/* Oops, the firmware hasn't established a connection,
                    silently drop the packet (this seems to be the
                    safest approach). */
@@ -1271,6 +1271,7 @@
 	case HERMES_INQ_LINKSTATUS: {
 		struct hermes_linkstatus linkstatus;
 		u16 newstatus;
+		int connected;
 
 		if (len != sizeof(linkstatus)) {
 			printk(KERN_WARNING "%s: Unexpected size for linkstatus frame (%d bytes)\n",
@@ -1282,15 +1283,14 @@
 				  len / 2);
 		newstatus = le16_to_cpu(linkstatus.linkstatus);
 
-		if ( (newstatus == HERMES_LINKSTATUS_CONNECTED)
-		     || (newstatus == HERMES_LINKSTATUS_AP_CHANGE)
-		     || (newstatus == HERMES_LINKSTATUS_AP_IN_RANGE) )
-			priv->connected = 1;
-		else if ( (newstatus == HERMES_LINKSTATUS_NOT_CONNECTED)
-			  || (newstatus == HERMES_LINKSTATUS_DISCONNECTED)
-			  || (newstatus == HERMES_LINKSTATUS_AP_OUT_OF_RANGE)
-			  || (newstatus == HERMES_LINKSTATUS_ASSOC_FAILED) )
-			priv->connected = 0;
+		connected = (newstatus == HERMES_LINKSTATUS_CONNECTED)
+			|| (newstatus == HERMES_LINKSTATUS_AP_CHANGE)
+			|| (newstatus == HERMES_LINKSTATUS_AP_IN_RANGE);
+
+		if (connected)
+			netif_carrier_on(dev);
+		else
+			netif_carrier_off(dev);
 
 		if (newstatus != priv->last_linkstatus)
 			print_linkstatus(dev, newstatus);
@@ -1368,8 +1368,8 @@
 	}
 	
 	/* firmware will have to reassociate */
+	netif_carrier_off(dev);
 	priv->last_linkstatus = 0xffff;
-	priv->connected = 0;
 
 	return 0;
 }
@@ -1881,7 +1881,7 @@
 
 	priv->hw_unavailable++;
 	priv->last_linkstatus = 0xffff; /* firmware will have to reassociate */
-	priv->connected = 0;
+	netif_carrier_off(dev);
 
 	orinoco_unlock(priv, &flags);
 
@@ -2391,8 +2391,8 @@
 				   * hardware */
 	INIT_WORK(&priv->reset_work, (void (*)(void *))orinoco_reset, dev);
 
+	netif_carrier_off(dev);
 	priv->last_linkstatus = 0xffff;
-	priv->connected = 0;
 
 	return dev;
 
Index: working-2.6/drivers/net/wireless/orinoco.h
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco.h	2004-11-03 14:32:15.000000000 +1100
+++ working-2.6/drivers/net/wireless/orinoco.h	2004-11-03 16:12:40.000000000 +1100
@@ -42,7 +42,6 @@
 	/* driver state */
 	int open;
 	u16 last_linkstatus;
-	int connected;
 
 	/* Net device stuff */
 	struct net_device *ndev;

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist.  NOT _the_ _other_ _way_
				| _around_!
http://www.ozlabs.org/people/dgibson


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
