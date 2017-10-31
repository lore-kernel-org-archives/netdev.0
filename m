From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG ?] ipv6: addrconf: Adds a missing in6_ifa_hold()
Date: Mon, 30 Oct 2017 21:56:15 -0700
Message-ID: <1509425775.17752.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1509422017.17752.4.camel@edumazet-glaptop3.roam.corp.google.com>
         <f43e1142-e0c6-e2fa-dac8-00579747b91e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:50015 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752450AbdJaE4R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 00:56:17 -0400
Received: by mail-pg0-f67.google.com with SMTP id g6so13640568pgn.6
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 21:56:16 -0700 (PDT)
In-Reply-To: <f43e1142-e0c6-e2fa-dac8-00579747b91e@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-10-30 at 22:49 -0600, David Ahern wrote:
> On 10/30/17 9:53 PM, Eric Dumazet wrote:
> > David, I was looking at addrconf_permanent_addr() and wondered
> > if there is not some problem with it.
> > 
> > It seems we need to increment ifp refcount before calling
> > ipv6_del_addr()
> > 
> > Could you double check if this patch is needed, I am guessing you have a
> > test suite exercising this code path ?
> 
> A lot has changed in 20 months since the patch that added the code. For
> instance, taking down the 'lo' device no longer affects host routes on
> other interfaces. Also, fixup_permanent_addr only fails on memory
> allocation. Did you hit this with a test case because I do not have a
> general one that causes the memory failure (hard coding a failure for an
> address is the only way).
> 
> > 
> > Thanks.
> > 
> > PS : Presumably CONFIG_REFCOUNT_FULL=y should have warned you of the
> > problem.
> 
> I have not run a debug kernel in a while -- and did not have this option
> set. Added it to my debug config.
> 
> > 
> > diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> > index 4a96ebbf8eda5f59a6ff88e836d666a404d2bf0d..8a1c846d3df949a4638589f187120db22a3525ba 100644
> > --- a/net/ipv6/addrconf.c
> > +++ b/net/ipv6/addrconf.c
> > @@ -3335,6 +3335,7 @@ static void addrconf_permanent_addr(struct net_device *dev)
> >  		if ((ifp->flags & IFA_F_PERMANENT) &&
> >  		    fixup_permanent_addr(idev, ifp) < 0) {
> >  			write_unlock_bh(&idev->lock);
> > +			in6_ifa_hold(ifp);
> >  			ipv6_del_addr(ifp);
> >  			write_lock_bh(&idev->lock);
> >  
> 
> Yes, forcing a failure here does trigger refcnt warning, but then you
> knew that. ;-)
> 

Okay ;)

> 
> PS. is the following a known failure? I triggered it looking into your
> report
> 
> [  170.385741] ======================================================
> [  170.387490] WARNING: possible circular locking dependency detected
> [  170.389214] 4.14.0-rc5+ #338 Not tainted
> [  170.390323] ------------------------------------------------------
> [  170.392017] swapper/0/0 is trying to acquire lock:
> [  170.393408]  (slock-AF_INET){+.-.}, at: [<ffffffff8172848b>]
> tcp_delack_timer+0x29/0xb1
> [  170.395622]
> but task is already holding lock:
> [  170.396943]  ((timer)){+.-.}, at: [<ffffffff810f3c53>]
> call_timer_fn+0x5/0x36b
> [  170.397912]
> which lock already depends on the new lock.
> 
> [  170.398986]
> the existing dependency chain (in reverse order) is:
> [  170.399965]
> -> #1 ((timer)){+.-.}:
> [  170.400629]        lock_acquire+0x154/0x220
> [  170.401198]        del_timer_sync+0x47/0xbd
> [  170.401760]        inet_csk_reqsk_queue_drop+0x109/0x141
> [  170.402464]        inet_csk_complete_hashdance+0x3b/0x68
> [  170.403173]        tcp_check_req+0x517/0x5f1
> [  170.403746]        tcp_v4_rcv+0x6ad/0xce7
> [  170.404287]        ip_local_deliver_finish+0x1d4/0x281
> [  170.404985]        ip_local_deliver+0xaf/0xcf
> [  170.405571]        ip_rcv_finish+0x632/0x6ff
> [  170.406140]        ip_rcv+0x45d/0x4a6
> ...

Yeah, please look at 
https://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git/commit/?h=timers/core&id=52f737c2da40259ac9962170ce608b6fb1b55ee4
