From: Willy Tarreau <w@1wt.eu>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Wed, 20 Nov 2013 22:54:35 +0100
Message-ID: <20131120215435.GT8581@1wt.eu>
References: <20131117141940.GA18569@1wt.eu> <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com> <87li0kkhzx.fsf@natisbad.org> <1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com> <20131119174323.GH913@1wt.eu> <1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com> <20131119184121.GN913@1wt.eu> <874n780wzc.fsf@natisbad.org> <20131120191145.GP8581@1wt.eu> <87txf692zx.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	simon.guinot@sequanux.org, netdev@vger.kernel.org,
	edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:50850 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753815Ab3KTVzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Nov 2013 16:55:06 -0500
Content-Disposition: inline
In-Reply-To: <87txf692zx.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnaud,

On Wed, Nov 20, 2013 at 10:28:50PM +0100, Arnaud Ebalard wrote:
> With current Linus tree (head being b4789b8e: aacraid: prevent invalid
> pointer dereference), as a baseline here is what I get:
> 
>  w/ tcp_wmem left w/ default values (4096 16384 4071360)
> 
>   via netperf (TCP_MAERTS/TCP_STREAM): 151.13 / 935.50 Mbits/s
>   via wget against apache: 15.4 MB/s
>   via wget against nginx: 104 MB/s
>  
>  w/ tcp_wmem set to 4096 16384 262144:
> 
>   via netperf (TCP_MAERTS/TCP_STREAM): 919.89 / 935.50 Mbits/s
>   via wget against apache: 63.3 MB/s
>   via wget against nginx: 104 MB/s
>  
> With your patch on top of it (and tcp_wmem kept at its default value):
> 
>  via netperf: 939.16 / 935.44 Mbits/s
>  via wget against apache: 65.9 MB/s (top reports 69.5 sy, 30.1 si
>                                      and 72% CPU for apache2)
>  via wget against nginx: 106 MB/s
> 
> 
> With your patch and MVNETA_TX_DONE_TIMER_PERIOD set to 1 instead of 10
> (still w/ and tcp_wmem kept at its default value):
> 
>  via netperf: 939.12 / 935.84 Mbits/s
>  via wget against apache: 63.7 MB/s
>  via wget against nginx: 108 MB/s
> 
> So:
> 
>  - First, Eric's patch sitting in Linus tree does fix the regression
>    I had on 3.11.7 and early 3.12 (15.4 MB/s vs 256KB/s).
> 
>  - As can be seen in the results of first test, Eric's patch still
>    requires some additional tweaking of tcp_wmem to get netperf and
>    apache somewhat happy w/ perfectible drivers (63.3 MB/s instead of
>    15.4MB/s by setting max tcp send buffer space to 256KB for apache).
> 
>  - For unknown reasons, nginx manages to provide a 104MB/s download rate
>    even with a tcp_wmem set to default and no specific patch of mvneta.
> 
>  - Now, Willy's patch seems to makes netperf happy (link saturated from
>    server to client), w/o tweaking tcp_wmem.
> 
>  - Again with Willy's patch I guess the "limitations" of the platform
>    (1.2GHz CPU w/ 512MB of RAM) somehow prevent Apache to saturate the
>    link. All I can say is that the same test some months ago on a 1.6GHz
>    ARMv5TE (kirkwood 88f6282) w/ 256MB of RAM gave me 108MB/s. I do not
>    know if it is some apache regression, some mvneta vs mv63xx_eth
>    difference or some CPU frequency issue but having netperf and  nginx
>    happy make me wonder about Apache.
> 
>  - Willy, setting MVNETA_TX_DONE_TIMER_PERIOD to 1 instead of 10 w/ your
>    patch does not improve the already good value I get w/ your patch.

Great, thanks for your detailed tests! Concerning Apache, it's common to
see it consume more CPU than others, which makes it more sensible to small
devices like these ones (which BTW have a very small cache and only a 16bit
RAM bus). Please still note that there could be a number of other differences
such as Apache always doing TCP_NODELAY resulting in sending incomplete
segments at the end of each buffer, which consume slightly more descriptors.

> In the end if you iterate on your work to push a version of your patch
> upstream, I'll be happy to test it. And thanks for the time you already
> spent!

I'm currently trying to implement TX IRQ handling. I found the registers
description in the neta driver that is provided in Marvell's LSP kernel
that is shipped with some devices using their CPUs. This code is utterly
broken (eg: splice fails with -EBADF) but I think the register descriptions
could be trusted.

I'd rather have real IRQ handling than just relying on mvneta_poll(), so
that we can use it for asymmetric traffic/routing/whatever.

Regards,
Willy
