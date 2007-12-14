From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Fri, 14 Dec 2007 00:22:09 -0800
Message-ID: <20071214002209.ac748206.akpm@linux-foundation.org>
References: <200712140002.lBE02aGO025491@imap1.linux-foundation.org>
	<E1J35d6-00041l-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53353 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753427AbXLNIXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 03:23:19 -0500
In-Reply-To: <E1J35d6-00041l-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Dec 2007 16:10:44 +0800 Herbert Xu <herbert@gondor.apana.org.au> wrote:

> akpm@linux-foundation.org wrote:
> >
> > diff -puN drivers/net/cxgb3/cxgb3_main.c~net-use-mutex_is_locked-for-assert_rtnl drivers/net/cxgb3/cxgb3_main.c
> > --- a/drivers/net/cxgb3/cxgb3_main.c~net-use-mutex_is_locked-for-assert_rtnl
> > +++ a/drivers/net/cxgb3/cxgb3_main.c
> > @@ -2191,7 +2191,7 @@ static void check_t3b2_mac(struct adapte
> > {
> >        int i;
> > 
> > -       if (!rtnl_trylock())    /* synchronize with ifdown */
> > +       if (rtnl_is_locked())   /* synchronize with ifdown */
> >                return;
> > 
> >        for_each_port(adapter, i) {
> > @@ -2219,7 +2219,6 @@ static void check_t3b2_mac(struct adapte
> >                        p->mac.stats.num_resets++;
> >                }
> >        }
> > -       rtnl_unlock();
> 
> This doesn't look right.  It seems that they really want trylock
> here so we should just fix it by removing the bang.

doh.

> Also, does ASSERT_RTNL still warn when someone calls it from an
> atomic context? We definitely don't want to lose that check.

I don't see how it could warn about that.  Nor should it - one might want
to check that rtnl_lock is held inside preempt_disable() or spin_lock or
whatever.

It might make sense to warn if ASSERT_RTNL is called in in_interrupt()
contexts though.

