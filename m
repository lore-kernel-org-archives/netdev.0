From: holger@eitzenberger.org
Subject: [patch 1/1] asix: fix BUG in receive path when lowering MTU
Date: Fri, 03 May 2013 12:02:20 +0200
Message-ID: <20130503113254.213946017@eitzenberger.org>
References: <20130503112618.108645718@eitzenberger.org>
Cc: netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:54413 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762005Ab3ECLc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 07:32:57 -0400
Content-Disposition: inline; filename=asix-fix-BUG-in-receive-path.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is bug in the receive path of the asix driver at the time a
packet is received larger than MTU size and DF bit set:

 BUG: unable to handle kernel paging request at 0000004000000001
 IP: [<ffffffff8126f65b>] skb_release_head_state+0x2d/0xd2
 ...
 Call Trace:
  <IRQ> 
  [<ffffffff8126f86d>] ? skb_release_all+0x9/0x1e
  [<ffffffff8126f8ad>] ? __kfree_skb+0x9/0x6f
  [<ffffffffa00b4200>] ? asix_rx_fixup_internal+0xff/0x1ae [asix]
  [<ffffffffa00fb3dc>] ? usbnet_bh+0x4f/0x226 [usbnet]
  ...

It is easily reproducable by setting an MTU of 512 e. g. and sending
something like

  ping -s 1472 -c 1 -M do $SELF

from another box.

And this is because the rx->ax_skb is freed on error, but rx->ax_skb
is not reset, and the size is not reset to zero in this case.

And since the skb is added again to the usbnet->done skb queue it is
accessing already freed memory, resulting in the BUG when freeing a
2nd time.  I therefore think the value 0x0000004000000001 show in the
trace is more or less random data.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: linux-stable-3.8.y/drivers/net/usb/asix_common.c
===================================================================
--- linux-stable-3.8.y.orig/drivers/net/usb/asix_common.c	2013-05-02 11:28:32.000000000 +0200
+++ linux-stable-3.8.y/drivers/net/usb/asix_common.c	2013-05-03 11:33:00.000000000 +0200
@@ -100,6 +100,9 @@
 			netdev_err(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
 				   rx->size);
 			kfree_skb(rx->ax_skb);
+			rx->ax_skb = NULL;
+			rx->size = 0U;
+
 			return 0;
 		}
 
