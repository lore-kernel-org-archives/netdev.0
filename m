From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netif_receive_skb return value in bridging scenario
Date: Tue, 26 Feb 2013 08:35:28 -0800
Message-ID: <1361896528.11403.6.camel@edumazet-glaptop>
References: <675385003F19144A8CE636FC6B7BB7012F25EC@039-SN2MPN1-021.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bercaru Cristian-B43982 <B43982@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:37465 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759595Ab3BZQfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 11:35:32 -0500
Received: by mail-pa0-f41.google.com with SMTP id fb11so2553219pad.0
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 08:35:31 -0800 (PST)
In-Reply-To: <675385003F19144A8CE636FC6B7BB7012F25EC@039-SN2MPN1-021.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-26 at 14:57 +0000, Bercaru Cristian-B43982 wrote:
> Hello!
> 
> I noticed that the return value of __netif_receive_skb is initialized
> to NET_RX_DROP.
> 
> If the bridging code handles the packet and successfully returns
> RX_HANDLER_CONSUMED, __netif_receive_skb returns the default value,
> NET_RX_DROP. I don't think it is fair to consider the packet dropped,
> since it is received successfully.
> 
> I thought the return value of __netif_receive_skb was used by Ethernet
> NIC drivers for updating their RX_DROP and RX_OX counters, but I
> studied the source code of various drivers and they seem to ignore
> whatever the return value. It seems strange. Then shouldn't the
> function header look like      " void netif_receive_skb(... "  ?

It seems better to factorize whatever is needed in core network layer,
instead of adding code in all drivers to check netif_receive_skb()
return code.

Check the follwing "atomic_long_inc(&skb->dev->rx_dropped);"
in __netif_receive_skb_core()

For the case you mention, I guess we need the following patch 

diff --git a/net/core/dev.c b/net/core/dev.c
index 17bc535..e98fb4d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3446,6 +3446,7 @@ ncls:
 		}
 		switch (rx_handler(&skb)) {
 		case RX_HANDLER_CONSUMED:
+			ret = NET_RX_SUCCESS;
 			goto unlock;
 		case RX_HANDLER_ANOTHER:
 			goto another_round;
