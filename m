From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.5 bridging regression
Date: Sun, 21 Oct 2012 13:53:33 +0200
Message-ID: <1350820413.13333.2042.camel@edumazet-glaptop>
References: <20121021112727.GF21937@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:59928 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752728Ab2JULxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 07:53:37 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so534716eaa.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 04:53:36 -0700 (PDT)
In-Reply-To: <20121021112727.GF21937@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-10-21 at 13:27 +0200, Willy Tarreau wrote:
> Hi Eric,
> 
> Since 3.5, I was getting very quick panic when setting up a bridge
> on my guruplug (dual-gig equipped ARM system). This week-end I could
> bisect the issue and found that it is this patch which introduced the
> issue :
> 
>   a1c7fff7e18f59e684e07b0f9a770561cd39f395  net: netdev_alloc_skb() use build_skb()
> 
> I can reliably reproduce the issue by installing my laptop behind this
> bridge and running "find" on an NFS mount. I don't understand why this
> patch can cause this, I was thinking that maybe we free the same page
> twice or something like this but I don't see any such thing there.
> 
> I set up the bridge using this script :
> 
> 	brctl addbr br0
> 	brctl addif br0 eth0
> 	brctl addif br0 eth1
> 	ip a f dev eth0
> 	ip a f dev eth1
> 	ip li set eth0 up
> 	ip li set eth1 up
> 	ip li set br0 up
> 
> The network driver is mv643xx. I don't know if this is important, but
> since this issue is still present in 3.6.2 and nobody has yet reported
> a panic on bridge, I suspect that it may contribute to the issue.

Hello Willy

This is most probably the needed fix.

I guess David planned to send it to stable teams if not already done.

commit acb600def2110b1310466c0e485c0d26299898ae
Author: Eric Dumazet <edumazet@google.com>
Date:   Fri Oct 5 06:23:55 2012 +0000

    net: remove skb recycling
    
    Over time, skb recycling infrastructure got litle interest and
    many bugs. Generic rx path skb allocation is now using page
    fragments for efficient GRO / TCP coalescing, and recyling
    a tx skb for rx path is not worth the pain.
    
    Last identified bug is that fat skbs can be recycled
    and it can endup using high order pages after few iterations.
    
    With help from Maxime Bizon, who pointed out that commit
    87151b8689d (net: allow pskb_expand_head() to get maximum tailroom)
    introduced this regression for recycled skbs.
    
    Instead of fixing this bug, lets remove skb recycling.
    
    Drivers wanting really hot skbs should use build_skb() anyway,
    to allocate/populate sk_buff right before netif_receive_skb()
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Cc: Maxime Bizon <mbizon@freebox.fr>
    Signed-off-by: David S. Miller <davem@davemloft.net>
