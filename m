From: David Gibson <david@gibson.dropbear.id.au>
Subject: [1/5] Orinoco merge updates, part the fourth: wireless stats updates
Date: Wed, 30 Mar 2005 13:43:16 +1000
Message-ID: <20050330034316.GG6478@localhost.localdomain>
References: <20050330034238.GF6478@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Pavel Roskin <proski@gnu.org>,
        Orinoco Development List <orinoco-devel@lists.sourceforge.net>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20050330034238.GF6478@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Minor updates/bugfixes to the handling of wireless statistics.

Signed-off-by: David Gibson <hermes@gibson.dropbear.id.au>

Index: working-2.6/drivers/net/wireless/orinoco.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco.c	2005-02-25 15:47:53.314373136 +1100
+++ working-2.6/drivers/net/wireless/orinoco.c	2005-02-25 16:20:13.951351472 +1100
@@ -686,7 +686,7 @@
 	struct orinoco_private *priv = netdev_priv(dev);
 	hermes_t *hw = &priv->hw;
 	struct iw_statistics *wstats = &priv->wstats;
-	int err = 0;
+	int err;
 	unsigned long flags;
 
 	if (! netif_device_present(dev)) {
@@ -695,9 +695,21 @@
 		return NULL; /* FIXME: Can we do better than this? */
 	}
 
+	/* If busy, return the old stats.  Returning NULL may cause
+	 * the interface to disappear from /proc/net/wireless */
 	if (orinoco_lock(priv, &flags) != 0)
-		return NULL;  /* FIXME: Erg, we've been signalled, how
-			       * do we propagate this back up? */
+		return wstats;
+
+	/* We can't really wait for the tallies inquiry command to
+	 * complete, so we just use the previous results and trigger
+	 * a new tallies inquiry command for next time - Jean II */
+	/* FIXME: Really we should wait for the inquiry to come back -
+	 * as it is the stats we give don't make a whole lot of sense.
+	 * Unfortunately, it's not clear how to do that within the
+	 * wireless extensions framework: I think we're in user
+	 * context, but a lock seems to be held by the time we get in
+	 * here so we're not safe to sleep here. */
+	hermes_inquire(hw, HERMES_INQ_TALLIES);
 
 	if (priv->iw_mode == IW_MODE_ADHOC) {
 		memset(&wstats->qual, 0, sizeof(wstats->qual));
@@ -716,25 +728,16 @@
 
 		err = HERMES_READ_RECORD(hw, USER_BAP,
 					 HERMES_RID_COMMSQUALITY, &cq);
-		
-		wstats->qual.qual = (int)le16_to_cpu(cq.qual);
-		wstats->qual.level = (int)le16_to_cpu(cq.signal) - 0x95;
-		wstats->qual.noise = (int)le16_to_cpu(cq.noise) - 0x95;
-		wstats->qual.updated = 7;
+
+		if (!err) {
+			wstats->qual.qual = (int)le16_to_cpu(cq.qual);
+			wstats->qual.level = (int)le16_to_cpu(cq.signal) - 0x95;
+			wstats->qual.noise = (int)le16_to_cpu(cq.noise) - 0x95;
+			wstats->qual.updated = 7;
+		}
 	}
 
-	/* We can't really wait for the tallies inquiry command to
-	 * complete, so we just use the previous results and trigger
-	 * a new tallies inquiry command for next time - Jean II */
-	/* FIXME: We're in user context (I think?), so we should just
-           wait for the tallies to come through */
-	err = hermes_inquire(hw, HERMES_INQ_TALLIES);
-               
 	orinoco_unlock(priv, &flags);
-
-	if (err)
-		return NULL;
-		
 	return wstats;
 }
 


-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/people/dgibson
