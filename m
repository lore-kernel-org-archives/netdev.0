From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Fri, 21 Sep 2012 19:11:05 +0200
Message-ID: <1348247465.2669.766.camel@edumazet-glaptop>
References: <1348242511.2669.635.camel@edumazet-glaptop>
	 <20120921.122705.1344923255084267186.davem@davemloft.net>
	 <1348246281.2669.755.camel@edumazet-glaptop>
	 <20120921.130440.1881102470665263512.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, subramanian.vijay@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38903 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756609Ab2IURLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:11:13 -0400
Received: by bkuw11 with SMTP id w11so943191bku.19
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 10:11:12 -0700 (PDT)
In-Reply-To: <20120921.130440.1881102470665263512.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-21 at 13:04 -0400, David Miller wrote:

> It's a silly limitation, in net/core/dev.c:
> 
> 	/* Turn on no cache copy if HW is doing checksum */
> 	if (!(dev->flags & IFF_LOOPBACK)) {
> 		dev->hw_features |= NETIF_F_NOCACHE_COPY;
> 		if (dev->features & NETIF_F_ALL_CSUM) {
> 			dev->wanted_features |= NETIF_F_NOCACHE_COPY;
> 			dev->features |= NETIF_F_NOCACHE_COPY;
> 		}
> 	}
> 
> Maybe this is probably better done as:
> 
> 	/* Turn on no cache copy if HW is doing checksum */
> 	dev->hw_features |= NETIF_F_NOCACHE_COPY;
> 	if (!(dev->flags & IFF_LOOPBACK)) {
> 		if (dev->features & NETIF_F_ALL_CSUM) {
> 			dev->wanted_features |= NETIF_F_NOCACHE_COPY;
> 			dev->features |= NETIF_F_NOCACHE_COPY;
> 		}
> 	}
> 
> And then the code matches more closely the comment. :-)

I did a test, and for various combinations (producer/consumer on same
core or not, same cpu or not...) and performance is divided by 2

So I guess we can leave the code as is
