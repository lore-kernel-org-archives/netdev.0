From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET]: Get rid of NETIF_F_INTERNAL_STATS
Date: Wed, 11 Apr 2007 17:56:02 +1000
Message-ID: <20070411075602.GA17635@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Jeff Garzik <jgarzik@pobox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2369 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751044AbXDKH4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 03:56:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

[NET]: Get rid of NETIF_F_INTERNAL_STATS

The recently added NETIF_F_INTERNAL_STATS isn't very useful.  If the
device driver needs to set it then it can always override get_stats
instead.  All existing drivers that have stats (which should be every
one) will override get_stats anyway.  Those that don't have stats
(if there are any) wouldn't hurt from having a get_stats that just
returns zeros everywhere.

So we can simply get rid of this flag.

This also fixes a potential crash in those get_stats callers that
don't check for a NULL return value (e.g., /proc/net/dev).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 71fc8ff..9c52652 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -323,7 +323,6 @@ struct net_device
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
 #define NETIF_F_GSO		2048	/* Enable software GSO. */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
-#define NETIF_F_INTERNAL_STATS	8192	/* Use stats structure in net_device */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
diff --git a/net/core/dev.c b/net/core/dev.c
index c484fcf..5791021 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3289,11 +3289,9 @@ out:
 	mutex_unlock(&net_todo_run_mutex);
 }
 
-static struct net_device_stats *maybe_internal_stats(struct net_device *dev)
+static struct net_device_stats *get_internal_stats(struct net_device *dev)
 {
-	if (dev->features & NETIF_F_INTERNAL_STATS)
-		return &dev->stats;
-	return NULL;
+	return &dev->stats;
 }
 
 /**
@@ -3331,7 +3329,7 @@ struct net_device *alloc_netdev(int sizeof_priv, const char *name,
 	if (sizeof_priv)
 		dev->priv = netdev_priv(dev);
 
-	dev->get_stats = maybe_internal_stats;
+	dev->get_stats = get_internal_stats;
 	setup(dev);
 	strcpy(dev->name, name);
 	return dev;
