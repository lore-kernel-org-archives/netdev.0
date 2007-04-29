From: Paul Walmsley <paul@booyaka.com>
Subject: [PATCH] ibmtr_cs: fix hang on eject
Date: Sat, 28 Apr 2007 20:19:20 -0600 (MDT)
Message-ID: <Pine.LNX.4.64.0704282004370.21519@utopia.booyaka.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, mikep@linuxtr.net
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from utopia.booyaka.com ([72.9.107.138]:60703 "EHLO
	utopia.booyaka.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754044AbXD2CTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2007 22:19:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Sent this patch a few weeks ago to the addresses listed for Token Ring 
maintainers.  No response, and the linux-tr@ address bounced.  Resent 
here in case someone wants to pick it up.  Perhaps a MAINTAINERS edit 
might be in order also.


- Paul


Ejecting a PCMCIA IBM Token Ring card that has not had its dev->open() 
called will reliably trigger an uninitialized spinlock oops when spinlock 
debugging is enabled. The system then hangs, occasionally softlockup 
oopsing.  Apparently ibmtr.c:tok_interrupt() doesn't expect to be called 
before tok_open(), but tok_interrupt() gets called anyway when the card is 
ejected.  So, set an already-existing flag which causes tok_interrupt() to 
bail out early upon card ejection. Tested by inserting and removing the 
PCMCIA card several times.

Patch against 2.6.21-rc6.


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

