From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 3/8] orinoco: Fix memory leak and unneeded unlock in orinoco_join_ap()
Date: Fri, 23 Sep 2005 04:18:06 -0400
Message-ID: <E1EIikw-0003op-O6@gnu.org>
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

Fix memory leak and unneeded unlock in orinoco_join_ap()

If orinoco_lock() fails, the code would still run orinoco_unlock(),
instead of freeing the allocated memory.  Found by sparse.

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -1046,7 +1046,7 @@ static void orinoco_join_ap(struct net_d
 		return;
 
 	if (orinoco_lock(priv, &flags) != 0)
-		goto out;
+		goto fail_lock;
 
 	/* Sanity checks in case user changed something in the meantime */
 	if (! priv->bssid_fixed)
@@ -1091,8 +1091,10 @@ static void orinoco_join_ap(struct net_d
 		printk(KERN_ERR "%s: Error issuing join request\n", dev->name);
 
  out:
-	kfree(buf);
 	orinoco_unlock(priv, &flags);
+
+ fail_lock:
+	kfree(buf);
 }
 
 /* Send new BSSID to userspace */



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
