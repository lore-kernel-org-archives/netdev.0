From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [patch 10/15] ppp_generic: fix lockdep warning
Date: Thu, 26 Apr 2007 13:28:12 +0200
Message-ID: <20070426112812.GB3145@ff.dom.local>
References: <200704260727.l3Q7RTxG023970@shell0.pdx.osdl.net> <17968.31028.923114.471858@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, jura@netams.com
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:39713 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754631AbXDZLWX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 07:22:23 -0400
Content-Disposition: inline
In-Reply-To: <17968.31028.923114.471858@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 26, 2007 at 08:04:36PM +1000, Paul Mackerras wrote:
> akpm@linux-foundation.org writes:
> 
> > lockdep has seen locks "-> #0" - "-> #3" taken in circular order, but IMHO,
> > lock "-> #3" (&pch->downl) taken after "-> #2" (&ppp->wlock) differs from
> > &pch->downl lock taken in "-> #0" (before &vlan_netdev_xmit_lock_key) and
> > lockdep should be notified about this.
> > 
> > Reported & tested by: "Yuriy N. Shkandybin" <jura@netams.com>
> > Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> > Cc: Paul Mackerras <paulus@samba.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> > 
> >  drivers/net/ppp_generic.c |    6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
> > 
> > diff -puN drivers/net/ppp_generic.c~ppp_generic-fix-lockdep-warning drivers/net/ppp_generic.c
> > --- a/drivers/net/ppp_generic.c~ppp_generic-fix-lockdep-warning
> > +++ a/drivers/net/ppp_generic.c
> > @@ -1433,7 +1433,8 @@ ppp_channel_push(struct channel *pch)
> >  	struct sk_buff *skb;
> >  	struct ppp *ppp;
> >  
> > -	spin_lock_bh(&pch->downl);
> > +	local_bh_disable();
> > +	spin_lock_nested(&pch->downl, SINGLE_DEPTH_NESTING);
> 
> This looks like a band-aid to me.  I don't feel that I understand
> exactly how the recursive locking situation arose, or why saying
> "SINGLE_DEPTH_NESTING" (whatever that means exactly) is a suitable
> fix.

I think I've cc-d this patch proposal to you, and there was
something about: don't apply without  maintainer's opinion and
Yuriy's testing. I think Andrew was not afraid to risk -mm
stability, and took this earlier.

In this case lockdep sees locks taken in different order,
and one of this locks is pch->downl, taken in two different
functions. Lockdep thinks it's the same lock, but these
functions serve two different type of channels, which
cannot wait for/take this lock at the same time.
SINGLE_DEPTH_NESTING means here this is another lock, so
lockdep doesn't see nothing wrong with this:

f1()
{
spin_lock_nested(&pch->downl, SINGLE_DEPTH_NESTING);
spin_lock(&B);
...
}

f2()
{
spin_lock(&B);
spin_lock(&pch->downl);
...
}

which would generate an error without nesting.
So, if you think it's wrong, the patch should be dumped,
and other measures be taken, to stop bother users with this.

Regards,
Jarek P.
