From: David Russell <david@aprsworld.com>
Subject: [PATCH] netdev: enc28j60 kernel panic fix.
Date: Wed, 4 May 2016 12:51:35 -0500
Message-ID: <CAEGHc+xdoSVa9J_uYm-Az7n4xc+mycy7Jf1p75pss3eVK3jUHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36814 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251AbcEDRvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 13:51:38 -0400
Received: by mail-io0-f179.google.com with SMTP id u185so70779491iod.3
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 10:51:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When connected directly to another system (not via a switch)
eventually a condition where a NULL pointer dereference occurs in
enc28j60_hw_tx() and this patch simply checks for that condition and
returns gracefully without causing a kernel panic.  I believe, but
have not investigated this is caused by a packet collision and am not
sure if the kernel tracks collisions or counts them as errors, so that
should probably be added if this is what's happening.  I'm also not
familiar with the linux kernel, so may have fixed this in a less than
ideal way.

Developer's Certificate of Origin 1.1

        By making a contribution to this project, I certify that:

        (d) I understand and agree that this project and the contribution
            are public and that a record of the contribution (including all
            personal information I submit with it, including my sign-off) is
            maintained indefinitely and may be redistributed consistent with
            this project or the open source license(s) involved.

Signed-off-by: David Russell <david@aprsworld.com>

---
diff --git a/drivers/net/ethernet/microchip/enc28j60.c
b/drivers/net/ethernet/microchip/enc28j60.c
index 86ea17e..36ac65f 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -1233,6 +1233,9 @@ static void enc28j60_irq_work_handler(struct
work_struct *work)
  */
 static void enc28j60_hw_tx(struct enc28j60_net *priv)
 {
+       if (!priv->tx_skb)
+               return;
+
        if (netif_msg_tx_queued(priv))
                printk(KERN_DEBUG DRV_NAME
                        ": Tx Packet Len:%d\n", priv->tx_skb->len);
