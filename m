From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: RFC crap-patch [PATCH] net: Per CPU separate frag mem accounting
Date: Fri, 15 Mar 2013 21:09:07 +0100
Message-ID: <20130315200907.GA24041@order.stressinduktion.org>
References: <20130308221647.5312.33631.stgit@dragon> <20130308221744.5312.14924.stgit@dragon> <1363245955.14913.21.camel@localhost> <1363251561.14913.33.camel@localhost> <1363294743.2695.10.camel@bwh-desktop.uk.solarflarecom.com> <20130314231250.GA7974@order.stressinduktion.org> <1363304384.2695.42.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38098 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920Ab3COUJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 16:09:09 -0400
Content-Disposition: inline
In-Reply-To: <1363304384.2695.42.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 14, 2013 at 11:39:44PM +0000, Ben Hutchings wrote:
> On Fri, 2013-03-15 at 00:12 +0100, Hannes Frederic Sowa wrote:
> > On Thu, Mar 14, 2013 at 08:59:03PM +0000, Ben Hutchings wrote:
> > > On Thu, 2013-03-14 at 09:59 +0100, Jesper Dangaard Brouer wrote:
> > > > On Thu, 2013-03-14 at 08:25 +0100, Jesper Dangaard Brouer wrote:
> > > > > This is NOT the patch I just mentioned in the other thread, of removing
> > > > > the LRU list.  This patch does real per cpu mem acct, and LRU per CPU.
> > > > > 
> > > > > I get really good performance number with this patch, but I still think
> > > > > this might not be the correct solution.
> > > > 
> > > > The reason is this depend on fragments entering the same HW queue, some
> > > > NICs might not put the first fragment (which have the full header
> > > > tuples) and the remaining fragments on the same queue. In which case
> > > > this patch will loose its performance gain.
> > > [...]
> > > 
> > > The Microsoft RSS spec only includes port numbers in the flow hash for
> > > TCP, presumably because TCP avoids IP fragmentation whereas datagram
> > > protocols cannot.  Some Linux drivers allow UDP ports to be included in
> > > the flow hash but I don't think this is the default for any of them.
> > > 
> > > In Solarflare hardware the IPv4 MF bit inhibits layer 4 flow steering,
> > > so all fragments will be unsteered.  I don't know whether everyone else
> > > got that right though. :-)
> > 
> > Shouldn't they be steered by the IPv4 2-tuple then (if ipv4 hashing is enabled
> > on the card)?
> 
> IP fragments should get a flow hash based on the 2-tuple, yes.

Thanks for clearing this up!

Hm, if we seperate the fragmentation caches per cpu perhaps it would
make sense to recalculate rxhash as soon as we know that we processed the
first fragment with more-fragments flag set and reroute it to another cpu
once (much like rps). It would burn caches but the next packets would
already arrive at the correct cpu. This would perhaps be benficial if
(like I think Jesper said) a common scenario is where packets are split in
minimum 3 fragments. I don't think there would be latency problems either
because we cannot deliver the first fragment up the stack (given no packet
reordering). So we would not have cross cpu fragment lookups anymore, but I
don't know if the overhead is worth it.

This could be done conditionally by a blacklist where we check if the nic
does generate broken udp/fragment checksums. The in-kernel flow dissector
already does handle this case correctly. We would "just" have to verify if
the network cards handle this case correctly. Heh, thats something where
the kernel could tune itself and deactivate cross fragment cache lookups
as soon as it knows that a given interface handles this case correctly. :)

But this also seems to be very complex just for handling fragments. :/
