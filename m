From: David Miller <davem@davemloft.net>
Subject: Re: IrDA spams logfiles - since 2.6.19
Date: Wed, 10 Jan 2007 15:26:07 -0800 (PST)
Message-ID: <20070110.152607.125896247.davem@davemloft.net>
References: <20070107005150.GE22817@gamma.logic.tuwien.ac.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57956
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965240AbXAJX0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 18:26:08 -0500
To: avl@logic.at
In-Reply-To: <20070107005150.GE22817@gamma.logic.tuwien.ac.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreas Leitgeb <avl@logic.at>
Date: Sun, 7 Jan 2007 01:51:50 +0100

> As soon as I load the irda-usb module with the device plugged,
> I get lots of messages of following kind into the logs:
>   irda_usb_hard_xmit(), Insuficient skb headroom.
> (the "Insuficient"-typo is original)
> about 7 in a second, then a 2-secs pause. Repeating 
> until the irda-usb module is removed again.
> 
> I then looked up the kernel-source for that particular 
> typo'ed word, and added some info to the log:
>   drivers/net/irda/irda-usb.c:448:
>         if (skb_headroom(skb) < self->header_length) {
>                 IRDA_DEBUG(0, "%s(), Insuficient skb headroom. %d / %d \n",
>                      __FUNCTION__, skb_headroom(skb) , self->header_length);
>         ...
> Which came out as:
>   irda_usb_hard_xmit(), Insuficient skb headroom. 0 / 1
> Thus, while self->header_length == USB_IRDA_HEADER,
> I didn't yet understand the meaning of fields
>   ->data and ->head of the skb.
> 
> I don't know, if the warning itself is right or wrong,
> because other than the spamming of logs, transferring
> data over irda appears to work just fine.

The warning is a bit extreme because the skb_cow() call does fix
things up and makes space available.

But it's not the most efficient thing in the world, so it's good
that we know about this so we can have a closer work.

I want to remove that warning, but first let's figure out what the
call chain is that causes skb_headroom() to end up being zero.

Can you get us some logs this debugging patch?  Thanks.

Please make sure CONFIG_BUG is enabled in your kernel config.
You should get a stack backtrace in your logs when the event
happens.

diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 3ca1082..2017024 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -446,7 +446,7 @@ static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	 * Also, we don't use directly skb_cow(), because it require
 	 * headroom >= 16, which force unnecessary copies - Jean II */
 	if (skb_headroom(skb) < self->header_length) {
-		IRDA_DEBUG(0, "%s(), Insuficient skb headroom.\n", __FUNCTION__);
+		WARN_ON(1);
 		if (skb_cow(skb, self->header_length)) {
 			IRDA_WARNING("%s(), failed skb_cow() !!!\n", __FUNCTION__);
 			goto drop;
