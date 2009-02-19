From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 0/6] mv643xx_eth updates
Date: Thu, 19 Feb 2009 23:43:19 +0100
Message-ID: <20090219224318.GH17914@xi.wantstofly.org>
References: <20090213000615.GJ17914@xi.wantstofly.org> <20090215.234630.202443700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, nico@cam.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:53747 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754546AbZBSWnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 17:43:20 -0500
Content-Disposition: inline
In-Reply-To: <20090215.234630.202443700.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 15, 2009 at 11:46:30PM -0800, David Miller wrote:

> > Two things here:
> > - Exporting some functionality that mostly already existed in the
> >   driver (interrupt coalescing, etc) to userland via ethtool.
> > - Add Kconfig-configurable LRO support.
> 
> Applied to net-next-2.6, but I think making LRO support
> Kconfig'able is a terrible precedent to set.
> 
> We have an ethtool knob, people can turn it off.
> 
> And furthermore, if it is worse in some cases that is
> a bug that we should fix rather than ignore while hiding
> behind some Kconfig option.
> 
> Please reconsider...

Hi David,

Sorry for being slow with responding to this.

I tried a routing test on an ARM board that uses mv643xx_eth on an
almost vanilla (some arch/arm changes) 2.6.29-rc3 for each of these
three cases:
1. LRO disabled in Kconfig
2. LRO enabled in Kconfig, !NETIF_F_LRO
3. LRO enabled in Kconfig, NETIF_F_LRO

I'm injecting 300kpps on one interface (lan1), and routing the packets
to another interface (lan2).  lan[1234] are virtual (DSA) netdevs that
are tagged over eth0.  I'm reading sw (linux netdev) and hw (switch chip
/ CPU ethernet MAC) rx and tx counters on the eth0 and lan[1234] inter-
faces every second and reporting them with a vmstat-like program.

Columns are:
- lan1 hardware rx counter
- eth0 hardware rx counter
- [...]
- eth interrupts/sec (0 because we stay in polling mode)
- # of elapsed msec since the last line


LRO disabled:

-l1hwrx -e0hwrx -e0swrx -l1swrx -l2swtx -e0swtx -e0hwtx -l2hwtx | -ethint ---ms
 301753  300129  230784  232064  233344  230784  230784  233341 |       0  1000
 298476  300102  231040  229760  228480  231040  231040  228476 |       0  1000
 300069  300070  230784  230784  232064  230784  230784  232069 |       0  1000
 300108  300113  231168  231168  231168  231168  231168  231164 |       0  1000
 300016  300014  229888  229888  229760  229888  229888  229765 |       0  1000
 300056  300058  231040  231040  229888  231040  231040  229887 |       0  1000
 300161  300153  230912  230912  232192  230912  230912  232196 |       0  1000
 300082  300082  231168  231168  229888  231168  231168  229885 |       0  1000
 300069  300075  230912  230912  232064  230912  230912  232057 |       0  1000
 300108  300107  231040  231040  232192  231040  231040  232197 |       0  1000
 300134  300137  230912  230912  228608  230912  230912  228603 |       0  1000
 300056  300057  231040  231040  231040  231040  231040  231048 |       0  1000
 300056  300045  230784  230784  231936  230784  230784  231927 |       0  1000


LRO enabled, !NETIF_F_LRO:

-l1hwrx -e0hwrx -e0swrx -l1swrx -l2swtx -e0swtx -e0hwtx -l2hwtx | -ethint ---ms
 300135  300147  221696  221696  221696  221696  221696  221696 |       0  1000
 300134  300131  221568  221568  221568  221568  221568  221568 |       0  1000
 300121  300116  221568  221568  221568  221568  221568  221568 |       0  1000
 300069  300077  221568  221568  222720  221568  221568  222720 |       0  1000
 300160  300157  221696  221696  223104  221696  221696  223104 |       0  1000
 300148  300146  221696  221696  220416  221696  221696  220416 |       0  1000
 300043  300037  221568  221568  220288  221568  221568  220288 |       0  1000
 300042  300045  221568  221568  222720  221568  221568  222720 |       0  1000
 300135  300134  221696  221696  221824  221696  221696  221824 |       0  1000
 300173  300180  221696  221696  220416  221696  221696  220416 |       0  1000
 300161  300162  221696  221696  221696  221696  221696  221696 |       0  1000
 300043  300034  221568  221568  221568  221568  221568  221568 |       0  1000
 300108  300112  221568  221568  221568  221568  221568  221568 |       0  1000
 300095  300089  221568  221568  221568  221568  221568  221568 |       0  1000
 300160  300161  221696  221696  221696  221696  221696  221696 |       0  1000
 300161  300173  221696  221696  221696  221696  221696  221696 |       0  1000
 300029  300020  221568  221568  221568  221568  221568  221568 |       0  1000
 300161  300163  221568  221568  221568  221568  221568  221568 |       0  1000


LRO enabled, NETIF_F_LRO:

-l1hwrx -e0hwrx -e0swrx -l1swrx -l2swtx -e0swtx -e0hwtx -l2hwtx | -ethint ---ms
 300159  300154  217088  217088  217088  217088  217088  217091 |       0  1000
 300135  300141  217216  217216  219520  217216  217216  219510 |       0  1000
 300055  300058  216960  216960  214656  216960  216960  214656 |       0  1000
 300147  300151  217344  217344  219648  217344  217344  219657 |       0  1000
 300055  300052  217088  217088  214784  217088  217088  214780 |       0  1000
 300148  300145  217344  217344  217344  217344  217344  217346 |       0  1000
 300029  300027  216960  216960  216960  216960  216960  216960 |       0  1000
 300016  300021  217216  217216  217216  217216  217216  217211 |       0  1000
 300043  300040  216960  216960  216960  216960  216960  216966 |       0  1000
 300082  300084  217344  217344  217344  217344  217344  217337 |       0  1000
 300186  300177  217088  217088  217216  217088  217088  217215 |       0  1000


So we take a ~10kpps hit by enabling LRO in Kconfig but without
NETIF_F_LRO set (from ~231 kpps to ~221 kpps), and then another ~4kpps
hit by setting NETIF_F_LRO (to ~217 kpps).  Since this is a 1.2 GHz
CPU, the hit of the former is then about 230 cycles per packet (which
is probably mostly extra cache misses), and that of the latter about
another 100 cycles per packet (a handful of extra function calls and
some tests).

On one hand, quite some effort has gone into optimising mv643xx_eth
routing throughput (from its original 150kpps-ish (don't remember
exactly) in 2.6.25-ish on this board to ~280 kpps now with some more
patches that are not (yet) in mainline), which has often yielded
slow progress at a rate of only a couple kpps per change, and in that
regard it feels like a waste to just throw 10kpps away by always
enabling LRO.  On the other hand, having the Kconfig option kind of
fails the goal of having a driver that automatically does the right
thing in various environments.

What do you think?


thanks,
Lennert
