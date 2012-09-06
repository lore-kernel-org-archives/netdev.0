From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: changing usbnet's API to better deal with cdc-ncm
Date: Thu, 06 Sep 2012 11:22:16 +0200
Message-ID: <1346923336.2484.7.camel@edumazet-glaptop>
References: <2791550.LhGu6po6Xy@linux-lqwf.site>
	 <2AC7D4AD8BA1C640B4C60C61C8E520154A6AA56BF9@EXDCVYMBSTM006.EQ1STM.local>
	 <6556435.5o3fR8ZcBa@linux-lqwf.site>
	 <1346922697.2484.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexey ORISHKO <alexey.orishko@stericsson.com>,
	"bjorn@mork.no" <bjorn@mork.no>, Ming Lei <tom.leiming@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:34550 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965Ab2IFJWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 05:22:22 -0400
In-Reply-To: <1346922697.2484.5.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-06 at 11:11 +0200, Eric Dumazet wrote:

> Really skb_clone() use should be removed from cdc_ncm_rx_fixup()
> 
> Unless you expect 10Gbit speed from this driver, skb_clone() is the
> worst possible strategy.
> 
> Allocating fresh skbs of the right size permits better memory use and
> allows TCP coalescing as well.
> 
> The use of skb_clone() forces some parts of the stack to perform a full
> copy anyway.
> 
> It's still unclear to me with we use up to 32KB blocks in USB drivers...
> 

So I advise testing this patch :

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 4cd582a..c0821f7 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1052,12 +1052,11 @@ static int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in)
 			break;
 
 		} else {
-			skb = skb_clone(skb_in, GFP_ATOMIC);
+			skb = netdev_alloc_skb_ip_align(dev->net, len);
 			if (!skb)
 				goto error;
-			skb->len = len;
-			skb->data = ((u8 *)skb_in->data) + offset;
-			skb_set_tail_pointer(skb, len);
+			skb_put(skb, len);
+			memcpy(skb->data, skb_in->data + offset, len);
 			usbnet_skb_return(dev, skb);
 		}
 	}
