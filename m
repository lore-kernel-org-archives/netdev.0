From: David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Subject: [5/14] Orinoco driver updates - cleanup low-level code
Date: Thu, 24 Feb 2005 14:58:04 +1100
Message-ID: <20050224035804.GF32001@localhost.localdomain>
References: <20050224035355.GA32001@localhost.localdomain> <20050224035445.GB32001@localhost.localdomain> <20050224035524.GC32001@localhost.localdomain> <20050224035650.GD32001@localhost.localdomain> <20050224035718.GE32001@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>,
	Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20050224035718.GE32001-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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

Apply some cleanups to the low-level orinoco handling code in
hermes.[ch].  This cleans up some error handling code, corrects an
error code to something more accurate, and also increases a timeout
value.  This last can (when the hardware plays up) cause long delays
with spinlocks held, which is bad, but is rather less prone to
prematurely giving up, which has the unfortunate habit of fatally
confusing the hardware in other ways :-/.

Signed-off-by: David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>

Index: working-2.6/drivers/net/wireless/hermes.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/hermes.c	2005-01-12 15:22:34.263633584 +1100
+++ working-2.6/drivers/net/wireless/hermes.c	2004-11-05 13:59:07.000000000 +1100
@@ -383,12 +383,17 @@
 		reg = hermes_read_reg(hw, oreg);
 	}
 
-	if (reg & HERMES_OFFSET_BUSY) {
-		return -ETIMEDOUT;
-	}
+	if (reg != offset) {
+		printk(KERN_ERR "hermes @ %p: BAP%d offset %s: "
+		       "reg=0x%x id=0x%x offset=0x%x\n", hw->iobase, bap,
+		       (reg & HERMES_OFFSET_BUSY) ? "timeout" : "error",
+		       reg, id, offset);
+
+		if (reg & HERMES_OFFSET_BUSY) {
+			return -ETIMEDOUT;
+		}
 
-	if (reg & HERMES_OFFSET_ERR) {
-		return -EIO;
+		return -EIO;		/* error or wrong offset */
 	}
 
 	return 0;
@@ -476,7 +481,7 @@
 	rlength = hermes_read_reg(hw, dreg);
 
 	if (! rlength)
-		return -ENOENT;
+		return -ENODATA;
 
 	rtype = hermes_read_reg(hw, dreg);
 
Index: working-2.6/drivers/net/wireless/hermes.h
===================================================================
--- working-2.6.orig/drivers/net/wireless/hermes.h	2005-01-12 11:13:41.000000000 +1100
+++ working-2.6/drivers/net/wireless/hermes.h	2004-11-05 13:53:55.000000000 +1100
@@ -340,7 +340,7 @@
 #ifdef __KERNEL__
 
 /* Timeouts */
-#define HERMES_BAP_BUSY_TIMEOUT (500) /* In iterations of ~1us */
+#define HERMES_BAP_BUSY_TIMEOUT (10000) /* In iterations of ~1us */
 
 /* Basic control structure */
 typedef struct hermes {

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
