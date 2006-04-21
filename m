From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH] Unregister network device before releasing PCMCIA resources
Date: Thu, 20 Apr 2006 23:17:40 -0400
Message-ID: <20060421031740.13571.80473.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: linux-pcmcia@lists.infradead.org, linville@tuxdriver.com,
	Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:38044 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S932157AbWDUDRz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 23:17:55 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1FWm9Q-0004YY-IS
	for netdev@vger.kernel.org; Thu, 20 Apr 2006 23:17:44 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski@gnu.org>

This is the right thing to do and it prevents kernel BUG on unload.

Some PCMCIA network drivers use link->dev_node as a flag indicating that
the network device has been successfully registered.  Recent code
changes cause this flag to be 0 after PCMCIA resources have been
released.

Signed-off-by: Pavel Roskin <proski@gnu.org>
---

 drivers/net/wireless/netwave_cs.c  |    4 ++--
 drivers/net/wireless/orinoco_cs.c  |    5 +++--
 drivers/net/wireless/ray_cs.c      |    4 +++-
 drivers/net/wireless/spectrum_cs.c |    5 +++--
 drivers/net/wireless/wavelan_cs.c  |    9 +++++----
 5 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
index 9343d97..5d80db2 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -445,11 +445,11 @@ static void netwave_detach(struct pcmcia
 
 	DEBUG(0, "netwave_detach(0x%p)\n", link);
 
-	netwave_release(link);
-
 	if (link->dev_node)
 		unregister_netdev(dev);
 
+	netwave_release(link);
+
 	free_netdev(dev);
 } /* netwave_detach */
 
diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
index 434f7d7..5988305 100644
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -147,14 +147,15 @@ static void orinoco_cs_detach(struct pcm
 {
 	struct net_device *dev = link->priv;
 
-	orinoco_cs_release(link);
-
 	DEBUG(0, PFX "detach: link=%p link->dev_node=%p\n", link, link->dev_node);
 	if (link->dev_node) {
 		DEBUG(0, PFX "About to unregister net device %p\n",
 		      dev);
 		unregister_netdev(dev);
 	}
+
+	orinoco_cs_release(link);
+
 	free_orinocodev(dev);
 }				/* orinoco_cs_detach */
 
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 879eb42..fac4f1b 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -388,13 +388,15 @@ static void ray_detach(struct pcmcia_dev
     this_device = NULL;
     dev = link->priv;
 
+    if (link->dev_node)
+	unregister_netdev(dev);
+
     ray_release(link);
 
     local = (ray_dev_t *)dev->priv;
     del_timer(&local->timer);
 
     if (link->priv) {
-	if (link->dev_node) unregister_netdev(dev);
         free_netdev(dev);
     }
     DEBUG(2,"ray_cs ray_detach ending\n");
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/spectrum_cs.c
index f7b77ce..2551938 100644
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -626,14 +626,15 @@ static void spectrum_cs_detach(struct pc
 {
 	struct net_device *dev = link->priv;
 
-	spectrum_cs_release(link);
-
 	DEBUG(0, PFX "detach: link=%p link->dev_node=%p\n", link, link->dev_node);
 	if (link->dev_node) {
 		DEBUG(0, PFX "About to unregister net device %p\n",
 		      dev);
 		unregister_netdev(dev);
 	}
+
+	spectrum_cs_release(link);
+
 	free_orinocodev(dev);
 }				/* spectrum_cs_detach */
 
diff --git a/drivers/net/wireless/wavelan_cs.c b/drivers/net/wireless/wavelan_cs.c
index f7724eb..03c2e16 100644
--- a/drivers/net/wireless/wavelan_cs.c
+++ b/drivers/net/wireless/wavelan_cs.c
@@ -4681,6 +4681,11 @@ #ifdef DEBUG_CALLBACK_TRACE
   printk(KERN_DEBUG "-> wavelan_detach(0x%p)\n", link);
 #endif
 
+  /* Remove ourselves from the kernel list of ethernet devices */
+  /* Warning : can't be called from interrupt, timer or wavelan_close() */
+  if (link->dev_node)
+    unregister_netdev(dev);
+
   /* Some others haven't done their job : give them another chance */
   wv_pcmcia_release(link);
 
@@ -4689,10 +4694,6 @@ #endif
     {
       struct net_device *	dev = (struct net_device *) link->priv;
 
-      /* Remove ourselves from the kernel list of ethernet devices */
-      /* Warning : can't be called from interrupt, timer or wavelan_close() */
-      if (link->dev_node)
-	unregister_netdev(dev);
       link->dev_node = NULL;
       ((net_local *)netdev_priv(dev))->link = NULL;
       ((net_local *)netdev_priv(dev))->dev = NULL;

