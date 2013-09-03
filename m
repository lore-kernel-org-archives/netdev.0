From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] ipv6: Don't depend on per socket memory for neighbour discovery messages
Date: Tue, 3 Sep 2013 20:30:19 +0200
Message-ID: <20130903183019.GG21729@order.stressinduktion.org>
References: <e4600dac657e1160da7a5e7758dcb973b616a10e.1378207925.git.tgraf@suug.ch> <52261A12.3060203@wwwdotorg.org> <20130903172736.GB21729@order.stressinduktion.org> <52261F68.70907@wwwdotorg.org> <1378230697.7360.38.camel@edumazet-glaptop> <52262462.80308@wwwdotorg.org> <20130903182348.GB4166@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Stephen Warren <swarren@wwwdotorg.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Fabio Estevam <festevam@gmail.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35165 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755694Ab3ICSaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 14:30:21 -0400
Content-Disposition: inline
In-Reply-To: <20130903182348.GB4166@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 03, 2013 at 07:23:48PM +0100, Thomas Graf wrote:
> On 09/03/13 at 12:03pm, Stephen Warren wrote:
> > On 09/03/2013 11:51 AM, Eric Dumazet wrote:
> > > On Tue, 2013-09-03 at 11:42 -0600, Stephen Warren wrote:
> > > 
> > >> I don't see any extra messages from PROVE_LOCKING related to networking.
> > >> There is a single extra message from inside the audio driver, but that's
> > >> not networking-related at all.
> > > 
> > > LOCKDEP is automatically disabled at first splat.
> > > 
> > > Please try a kernel without audio driver ;)
> > 
> > Ah, OK. Now I do see something from ipv6:
> > 
> > > [   25.327622] 
> > > [   25.329142] =============================================
> > > [   25.334533] [ INFO: possible recursive locking detected ]
> > > [   25.339927] 3.11.0-rc7-next-20130830-00024-g209b4d8-dirty #17 Not tainted
> > > [   25.346705] ---------------------------------------------
> > > [   25.352095] login/704 is trying to acquire lock:
> > > [   25.356705]  (&ndev->lock){++--..}, at: [<c049be24>] ipv6_chk_mcast_addr+0x5c/0x200
> > > [   25.364405] 
> > > [   25.364405] but task is already holding lock:
> > > [   25.370230]  (&ndev->lock){++--..}, at: [<c0480eb4>] addrconf_rs_timer+0x18/0x134
> 
> Real deadlock, we should not hold idev->lock for ndisc_send_rs(), we
> should drop the lock beforehand I guess. We also don't hold idev->lock
> if we send out the RS via addrconf_dad_completed().

Yes, this already happend by the series to implement ipv6 for vxlan:
caf92bc4007036cfac8ee06c845fdfe6496e4fb3 ("ipv6: do not call ndisc_send_rs()
with write lock").

> I'm confused why lockdep would only trigger after my patch, the
> deadlock is unrelated.

Reordering by the compiler in the short-curcuit evaluation in
ip6_finish_output2 maybe (sk_mc_loop)?

Greetings,

  Hannes
