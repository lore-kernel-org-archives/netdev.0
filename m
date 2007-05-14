From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [patch 04/13] ppp_generic: fix lockdep warning
Date: Mon, 14 May 2007 08:07:00 +0200
Message-ID: <20070514060700.GA1000@ff.dom.local>
References: <200705110552.l4B5qnwC007799@shell0.pdx.osdl.net> <4644D8AF.7060403@garzik.org> <20070511.140309.59656886.davem@davemloft.net> <20070511141225.cf7a6909.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org, jura@netams.com, paulus@samba.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:36969 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755336AbXENGA3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 02:00:29 -0400
Content-Disposition: inline
In-Reply-To: <20070511141225.cf7a6909.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 11, 2007 at 02:12:25PM -0700, Andrew Morton wrote:
> On Fri, 11 May 2007 14:03:09 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Jeff Garzik <jeff@garzik.org>
> > Date: Fri, 11 May 2007 16:57:19 -0400
> > 
> > > applied
> > 
> > I was under the impression that this patch didn't actually fix the
> > problem yet?  I might be thinking about something else...
> 
> yeah, sorry, it seems that the discussion is ongoing.  Please drop the
> patch.  I did.
> 

After sending this patch I was a little confused, when next
lockdep warning report appeared, and I thought - since this is 
not enough, this patch could be dumped. But now I changed my
mind: there are really many possibilities of strange connections
between locks taken from vlans, ppp (with pppoe), multicasts etc.
- that every one possibility less is a gain here.

As I wrote earlier, one of main reasons of such a situation
is calling dev_queue_xmit() in a nested way, with xmit locks  
of previous layers held (as e.g. pppoe after ppp_generic).
On the other hand, changing this may be not enough to, because
some locks are seen by lockdep as one: e.g. eth & ppp netdevs,
or vlan's lock on eth vs. vlan's lock on ppp.

So, now I think this patch should stay (it simply says the truth
to lockdep - there are two, functionally independent kinds of ppp
channels with independent locks), because it does no harm (AFAIK),
and there is really at least one type of lockdep report less.

I also think that my two next patches (for vlan and ppp_generic),
are useful and should be applied even, if they are not enough with
this, quite complex configuration.

Of course, later, if somebody will find better solution, they could
be removed, but now, by not using them, some real locking problems
may be hidden because of the way lockdep works (or stops to work),
and there is no reason to frighten users with these current, false
warnings too.

Regards,
Jarek P.
