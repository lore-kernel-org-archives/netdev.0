From: David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Subject: [10/14] Orinoco driver updates - prohibit IBSS with no ESSID
Date: Thu, 24 Feb 2005 15:02:28 +1100
Message-ID: <20050224040228.GL32001@localhost.localdomain>
References: <20050224035355.GA32001@localhost.localdomain> <20050224035445.GB32001@localhost.localdomain> <20050224035524.GC32001@localhost.localdomain> <20050224035650.GD32001@localhost.localdomain> <20050224035718.GE32001@localhost.localdomain> <20050224035804.GF32001@localhost.localdomain> <20050224035957.GH32001@localhost.localdomain> <20050224040024.GI32001@localhost.localdomain> <20050224040052.GJ32001@localhost.localdomain> <20050224040153.GK32001@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>,
	Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20050224040153.GK32001-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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

Remove has_ibss_any flag and never set the CREATEIBSS RID when the
ESSID is empty.  Too many firmware break if we do.

Signed-off-by: David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>

Index: working-2.6/drivers/net/wireless/orinoco.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco.c	2005-02-24 14:50:50.125529816 +1100
+++ working-2.6/drivers/net/wireless/orinoco.c	2005-02-24 14:50:53.166067584 +1100
@@ -1580,21 +1580,26 @@
 	}
 
 	if (priv->has_ibss) {
-		err = hermes_write_wordrec(hw, USER_BAP,
-					   HERMES_RID_CNFCREATEIBSS,
-					   priv->createibss);
-		if (err) {
-			printk(KERN_ERR "%s: Error %d setting CREATEIBSS\n", dev->name, err);
-			return err;
-		}
+		u16 createibss;
 
-		if ((strlen(priv->desired_essid) == 0) && (priv->createibss)
-		   && (!priv->has_ibss_any)) {
+		if ((strlen(priv->desired_essid) == 0) && (priv->createibss)) {
 			printk(KERN_WARNING "%s: This firmware requires an "
 			       "ESSID in IBSS-Ad-Hoc mode.\n", dev->name);
 			/* With wvlan_cs, in this case, we would crash.
 			 * hopefully, this driver will behave better...
 			 * Jean II */
+			createibss = 0;
+		} else {
+			createibss = priv->createibss;
+		}
+		
+		err = hermes_write_wordrec(hw, USER_BAP,
+					   HERMES_RID_CNFCREATEIBSS,
+					   createibss);
+		if (err) {
+			printk(KERN_ERR "%s: Error %d setting CREATEIBSS\n",
+			       dev->name, err);
+			return err;
 		}
 	}
 
@@ -2073,7 +2078,6 @@
 	priv->has_preamble = 0;
 	priv->has_port3 = 1;
 	priv->has_ibss = 1;
-	priv->has_ibss_any = 0;
 	priv->has_wep = 0;
 	priv->has_big_wep = 0;
 
@@ -2089,7 +2093,6 @@
 		firmver = ((unsigned long)sta_id.major << 16) | sta_id.minor;
 
 		priv->has_ibss = (firmver >= 0x60006);
-		priv->has_ibss_any = (firmver >= 0x60010);
 		priv->has_wep = (firmver >= 0x40020);
 		priv->has_big_wep = 1; /* FIXME: this is wrong - how do we tell
 					  Gold cards from the others? */
Index: working-2.6/drivers/net/wireless/orinoco.h
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco.h	2005-02-24 14:50:46.549073520 +1100
+++ working-2.6/drivers/net/wireless/orinoco.h	2005-02-24 14:50:53.167067432 +1100
@@ -57,7 +57,7 @@
 #define FIRMWARE_TYPE_AGERE 1
 #define FIRMWARE_TYPE_INTERSIL 2
 #define FIRMWARE_TYPE_SYMBOL 3
-	int has_ibss, has_port3, has_ibss_any, ibss_port;
+	int has_ibss, has_port3, ibss_port;
 	int has_wep, has_big_wep;
 	int has_mwo;
 	int has_pm;

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist.  NOT _the_ _other_ _way_
				| _around_!
http://www.ozlabs.org/people/dgibson


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
