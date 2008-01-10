From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Thu, 10 Jan 2008 09:51:44 -0500
Message-ID: <20080110145144.GH8728@gospo.usersys.redhat.com>
References: <Pine.LNX.4.64.0801081949290.1135@bizon.gios.gov.pl> <29560.1199820632@death> <Pine.LNX.4.64.0801090732490.1135@bizon.gios.gov.pl> <17850.1199865514@death> <20080109152740.GE8728@gospo.usersys.redhat.com> <32361.1199901296@death> <20080109201709.GF8728@gospo.usersys.redhat.com> <20080109220534.GA2692@gondor.apana.org.au> <7603.1199920750@death> <20080110005809.GA3851@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54937 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753922AbYAJO7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 09:59:52 -0500
Content-Disposition: inline
In-Reply-To: <20080110005809.GA3851@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2008 at 11:58:09AM +1100, Herbert Xu wrote:
> On Wed, Jan 09, 2008 at 03:19:10PM -0800, Jay Vosburgh wrote:
> >
> > >No that's not the point.  The point is to move the majority of the code
> > >into process context so that you can take the RTNL.  Once you have taken
> > >the RTNL you can disable BH all you want and I don't care one bit.
> > 
> > 	I'm not sure how we could move more code into a process context;
> > much of the bonding driver is at the mercy of its callers, as in this
> > case.  The monitoring stuff and enslave / deslave is all in a process
> > context now (workqueue).  The transmit processing functions, for
> > example, can't be assumed to be in any particular context as they're
> > called by dev_queue_xmit.
> 
> No I'm not calling for you to move any more code into process context.
> I was replying to the comment that changing the read_lock calls in
> process context to read_lock_bh somehow undoes the benefit of moving
> softirq code into process context.  It does not since the point of the
> move is to be able to take the RTNL, which you can still do as long as
> you do it before you disable BH.
> 

That wasn't the only purpose, Herbert.  Making sure that calls to
dev_set_mac_address were called from process context was important at
the time of the coding as well since at least the tg3 driver took locks
that could not be taken reliably in soft-irq context.  Michael Chan
fixed this here:

commit 986e0aeb9ae09127b401c3baa66f15b7a31f354c
Author: Michael Chan <mchan@broadcom.com>
Date:   Sat May 5 12:10:20 2007 -0700

    [TG3]: Remove reset during MAC address changes.

so if wasn't as much of an issue after that, but moving as much of the
code to process context was important for that as well (hence the move
to not continue to try to not use bh-locks everywhere).


