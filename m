From: Paul Walmsley <paul@booyaka.com>
Subject: [PATCH 1/1] Fix hang on IBM Token Ring PCMCIA card ejection
Date: Tue, 27 Mar 2007 22:57:02 -0600 (MDT)
Message-ID: <Pine.LNX.4.64.0703272255460.21789@utopia.booyaka.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: mikep@linuxtr.net, netdev@vger.kernel.org, linux-tr@linuxtr.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from utopia.booyaka.com ([72.9.107.138]:57973 "EHLO
	utopia.booyaka.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753940AbXC1FDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 01:03:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Walmsley <paul@booyaka.com>

Ejecting a PCMCIA IBM Token Ring card that has not had its dev->open()
called will reliably trigger an uninitialized spinlock oops when
spinlock debugging is enabled. The system then hangs, occasionally
softlockup oopsing.  It seems that ibmtr.c:tok_interrupt() doesn't
expect to be called before tok_open() is called, but tok_interrupt()
gets called anyway when the card is ejected.  So, set an already-extant
flag which causes tok_interrupt() to bail out early upon card ejection.
Tested by inserting and removing the PCMCIA card several times.

Applies against 2.6.21-rc5.


Signed-off-by: Paul Walmsley <paul@booyaka.com>

---
  dev/drivers/net/pcmcia/ibmtr_cs.c |   12 ++++++++----
  1 file changed, 8 insertions(+), 4 deletions(-)

Index: linux/dev/drivers/net/pcmcia/ibmtr_cs.c
===================================================================
--- linux.orig/dev/drivers/net/pcmcia/ibmtr_cs.c
+++ linux/dev/drivers/net/pcmcia/ibmtr_cs.c
@@ -189,16 +189,20 @@ static void ibmtr_detach(struct pcmcia_d
  {
      struct ibmtr_dev_t *info = link->priv;
      struct net_device *dev = info->dev;
+    struct tok_info *ti = netdev_priv(dev);

      DEBUG(0, "ibmtr_detach(0x%p)\n", link);
+
+    /*
+     * When the card removal interrupt hits tok_interrupt(),
+     * bail out early, so we don't crash the machine
+     */
+    ti->sram_phys |= 1;

      if (link->dev_node)
  	unregister_netdev(dev);

-    {
-	struct tok_info *ti = netdev_priv(dev);
-	del_timer_sync(&(ti->tr_timer));
-    }
+    del_timer_sync(&(ti->tr_timer));

      ibmtr_release(link);

