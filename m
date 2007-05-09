From: Paul Walmsley <paul@booyaka.com>
Subject: [PATCH] From: Paul Walmsley <paul@booyaka.com>
Date: Wed, 09 May 2007 10:47:16 -0600
Message-ID: <20070509164803.557732761@booyaka.com>
References: <20070509164715.430844867@booyaka.com>
Cc: mikep@linuxtr.net, netdev@vger.kernel.org, linux-tr@linuxtr.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from utopia.booyaka.com ([72.9.107.138]:58062 "EHLO
	utopia.booyaka.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754310AbXEIQvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 12:51:53 -0400
Content-Disposition: inline; filename=ibmtr_cs_fix_detach.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ejecting a PCMCIA IBM Token Ring card that has not had its dev->open()
called will reliably trigger an uninitialized spinlock oops when
spinlock debugging is enabled. The system then hangs, occasionally
softlockup oopsing.  Apparently ibmtr.c:tok_interrupt() doesn't expect
to be called before tok_open(), but tok_interrupt() gets called anyway
when the card is ejected.  So, set an already-existing flag which
causes tok_interrupt() to bail out early upon card ejection. Tested by
inserting and removing the PCMCIA card several times.

Patch against 2.6.21-rc6.


Signed-off-by: Paul Walmsley <paul@booyaka.com>

---
 ibmtr_cs.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
index 1060154..9359ca7 100644
--- a/drivers/net/pcmcia/ibmtr_cs.c
+++ b/drivers/net/pcmcia/ibmtr_cs.c
@@ -189,16 +189,20 @@ static void ibmtr_detach(struct pcmcia_device *link)
 {
     struct ibmtr_dev_t *info = link->priv;
     struct net_device *dev = info->dev;
+     struct tok_info *ti = netdev_priv(dev);
 
     DEBUG(0, "ibmtr_detach(0x%p)\n", link);
+    
+    /* 
+     * When the card removal interrupt hits tok_interrupt(), 
+     * bail out early, so we don't crash the machine 
+     */
+    ti->sram_phys |= 1;
 
     if (link->dev_node)
 	unregister_netdev(dev);
-
-    {
-	struct tok_info *ti = netdev_priv(dev);
-	del_timer_sync(&(ti->tr_timer));
-    }
+    
+    del_timer_sync(&(ti->tr_timer));
 
     ibmtr_release(link);
 

-- 

