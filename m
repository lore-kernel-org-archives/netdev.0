From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 2/2] net/ieee80211: adjust error handling
Date: Wed, 16 Jul 2008 16:34:54 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0807161634310.28783@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:53411 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756701AbYGPOe7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 10:34:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Converts a test in error handling code to a sequence of labels.

The semantic match that found the problem is:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@@
expression E,E1,E2;
@@

E = alloc_etherdev(...)
... when != E = E1
if (...) { ... free_netdev(E); ... return ...; }
... when != E = E2
(
  if (...)
   {
   ... when != free_netdev(E);
   return dev; }
|
* if (...)
   {
   ... when != free_netdev(E);
   return ...; }
|
register_netdev(E)
)

// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
diff -u -p a/net/ieee80211/ieee80211_module.c b/net/ieee80211/ieee80211_module.c
--- a/net/ieee80211/ieee80211_module.c
+++ b/net/ieee80211/ieee80211_module.c
@@ -157,7 +157,7 @@ struct net_device *alloc_ieee80211(int s
 	err = ieee80211_networks_allocate(ieee);
 	if (err) {
 		IEEE80211_ERROR("Unable to allocate beacon storage: %d\n", err);
-		goto failed;
+		goto failed_free_netdev;
 	}
 	ieee80211_networks_initialize(ieee);
 
@@ -193,9 +193,9 @@ struct net_device *alloc_ieee80211(int s
 
 	return dev;
 
-      failed:
-	if (dev)
-		free_netdev(dev);
+failed_free_netdev:
+	free_netdev(dev);
+failed:
 	return NULL;
 }
 
