From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv6 routing table max_size badly dimensioned compared to IPv4
Date: Thu, 27 Feb 2014 12:23:03 -0800
Message-ID: <1393532583.26794.26.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140227192403.GA13472@xs.powerdns.com>
	 <1393531144.26794.24.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140227200814.GA27495@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bert hubert <bert.hubert@netherlabs.nl>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:45636 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbaB0UXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 15:23:06 -0500
Received: by mail-ie0-f173.google.com with SMTP id lx4so2570590iec.18
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 12:23:06 -0800 (PST)
In-Reply-To: <20140227200814.GA27495@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-02-27 at 21:08 +0100, Hannes Frederic Sowa wrote:
> On Thu, Feb 27, 2014 at 11:59:04AM -0800, Eric Dumazet wrote:
> > On Thu, 2014-02-27 at 20:24 +0100, bert hubert wrote:
> > > Hi everybody,
> > > 
> > > Today, a PowerDNS (open source dns, www.powerdns.com) deployment ran into
> > > trouble with large amounts of IPv6 users.  It appears a large telco 'flicked
> > > the switch'.  We had around 8000 DNS queries/s over IPv6, and everything
> > > slowed to a crawl.  100% CPU utilization, most of it in the kernel. The same
> > > amount of queries over IPv4 causes no problems.
> > > 
> > > Note, this system is not functioning as a router or anything. It is just
> > > serving IPv6 DNS to a reasonable number of clients.
> > > 
> > > Thanks to diligent debugging and rapid help from friends over at SUSE, who
> > > suggested setting net.ipv6.route.max_size to a higher than default value,
> > > all problems were quickly resolved (thanks!).
> > > 
> > > From a quick reading of ip6_dst_gc, it is obvious that exceeding the
> > > max_size of the IPv6 routing table quickly becomes painful, causing non-stop
> > > gc scans.
> > > 
> > > net.ipv6.route.max_size defaults to 4096. The equivalent setting for IPv4
> > > defaults to 'millions' or is even dynamically sizing in modern kernels.
> > > 
> > > Now I know distributions can set this sysctl at will, but it appears that
> > > many of them don't. It does appear odd that we still assume at a kernel
> > > level that IPv6 is 'rare', a thousand times more rare than IPv4.
> > > 
> > > If people think this is a good idea, I could try to lift some of the other
> > > 'autosizing' code out there to get the IPv6 max_size limit raised on
> > > non-contrained hardware. 
> > > 
> > > Please let me know!
> > > 
> > 
> > What kernel version do you use ?
> > 
> > I thought this was already solved.
> > 
> > Commit 957c665f37007de93ccbe45902a23143724170d0 is in linux 3.0
> > ("ipv6: Don't put artificial limit on routing table size.")
> 
> The problem with DNS is that just for the DNS/UDP ping-pong we clone a
> rt6_info and reinsert it back into the fib.
> 
> DST_NOCOUNT logic only ensures we can still insert new routes from user space
> while the maximum number of routes is reached in the routing table. In case
> the ipv6 fib is under heavy load it does not help with performance.
> 
> We might think about raising this limit a bit. Number of IPv6 routing entries
> in global routing table already passed 4096. Maybe some heuristic which scales
> this value according to available memory?


Well, if we attach one dst per packet, it seems we already have a limit
of number of packets on the host (qdisc limits + packets on TX ring
buffers)

So DST_NOCOUNT should be used in this case. I thought David patch
was already doing this.
