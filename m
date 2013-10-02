From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 2/3] udp: Add udp early demux
Date: Wed, 02 Oct 2013 11:09:25 -0700
Message-ID: <1380737365.19002.110.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380656025-8847-1-git-send-email-sbohrer@rgmadvisors.com>
	 <1380656025-8847-3-git-send-email-sbohrer@rgmadvisors.com>
	 <1380660769.19002.40.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131002173422.GA7824@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tomk@rgmadvisors.com,
	netdev <netdev@vger.kernel.org>
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:61263 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755879Ab3JBSJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 14:09:27 -0400
Received: by mail-pa0-f49.google.com with SMTP id ld10so1362128pab.8
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 11:09:27 -0700 (PDT)
In-Reply-To: <20131002173422.GA7824@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-02 at 12:34 -0500, Shawn Bohrer wrote:
> On Tue, Oct 01, 2013 at 01:52:49PM -0700, Eric Dumazet wrote:
> > On Tue, 2013-10-01 at 14:33 -0500, Shawn Bohrer wrote:
> > > The removal of the routing cache introduced a performance regression for
> > > some UDP workloads since a dst lookup must be done for each packet.
> > > This change caches the dst per socket in a similar manner to what we do
> > > for TCP by implementing early_demux.
> > > 
> > > For UDP multicast we can only cache the dst if there is only one
> > > receiving socket on the host.  Since caching only works when there is
> > > one receiving socket we do the multicast socket lookup using RCU.
> > 
> > For unicast, we should find a matching socket for early demux only if
> > this is a connected socket.
> > 
> > Otherwise, forwarding setups will break.
> > 
> > You probably need to add a minimum score to __udp4_lib_lookup()
> 
> Perhaps I'm missing something but I don't think a minimum score would
> work because compute_score() and compute_score2() have several ways of
> returning a score of lets say 4 and I don't think they all mean the
> socket is connected.

Just change how score is computed. The existing +4 values are not hard
coded anywhere.

You want to compute a score so that a single compare against a threshold
is enough to tell you what's going on, before even taking a refcount on
the socket.


>   Why not just test the socket returned by
> __udp4_lib_lookup() to see if it is connected in
> udp_v4_early_demux()?  Something like:
> 
>         sk = __udp4_lib_lookup(net, iph->saddr, uh->source,
>                                iph->daddr, uh->dest, dif,
>                                &udp_table);
>         /* Only demux connected sockets or forwarding setups will break */
>         if (sk && !inet_sk(sk)->inet_daddr)
>                 return;

nice socket refcount leak ;)
