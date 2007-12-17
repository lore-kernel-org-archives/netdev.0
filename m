From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Mon, 17 Dec 2007 08:26:01 +0100
Message-ID: <20071217072601.GA1654@ff.dom.local>
References: <20071214002209.ac748206.akpm@linux-foundation.org> <20071214083037.GA15602@gondor.apana.org.au> <20071214.111514.03773174.davem@davemloft.net> <20071214151136.ae0f969b.akpm@linux-foundation.org> <20071215041827.GC25324@gondor.apana.org.au> <20071214214418.0ecd5e67.akpm@linux-foundation.org> <20071215061021.GA26247@gondor.apana.org.au> <20071215024810.20b8a5ae.akpm@linux-foundation.org> <47656931.1040309@gmail.com> <20071217012632.GA8475@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:24598 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755007AbXLQHUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 02:20:51 -0500
Received: by fg-out-1718.google.com with SMTP id e21so258833fga.17
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2007 23:20:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20071217012632.GA8475@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 17, 2007 at 09:26:32AM +0800, Herbert Xu wrote:
> On Sun, Dec 16, 2007 at 07:06:41PM +0100, Jarek Poplawski wrote:
> >
> > It seemed to exist a few days ago:
> > http://kerneltrap.org/mailarchive/linux-netdev/2007/12/4/473123
> > 
> > Btw., I don't know which of the patches: Eric's or yours will be chosen,
> > but, IMHO, there is no reason to remove rtnl_trylock(), which can be still
> > useful, just like mutex_trylock() is.
> 
> Doh! Andrew was too convincing :) I misread the grep result on
> in_interrupt.  Of course that function returns true if we're
> either in an IRQ handler or have BH off.
> 
> I retract what I've said in this thread and continue to oppose
> this change without a might_sleep.
> 

...And I think some change is needed here. Btw., I proposed to change
this long time ago too. There were no response - only Ben Greear
mentioned about some applications, which could rely on the trylock
way. I didn't understand what he was talking about at all - and it
didn't change until I've read this and Eric's patch thread!

So, I was surprised, probably just like Eric, ASSERT_RTNL is 2 in 1,
with this atomic somewhere deep in mind. IMHO this should be better
commented at least. But it's still dubious to me: using trylock this
way makes impossible to verify (eg. by lockdep) recursion cases,
when lock is taken with trylock in a loop.

So, I think using might_sleep() explicitly would be much more
readable or, otherwise, Patrick's proposal with adding
ASSERT_RTNL_ATOMIC would implicitly signal the real meaning of the
other one.

Btw. #2: David Miller gave this example of ASSERT_RTNL use:

	ASSERT_RTNL();
	page = alloc_page(GFP_KERNEL);

But isn't there a debugging duplication: it seems alloc_page() is used
in so many places and this check for GFP is/should_be there already?

Regards,
Jarek P.
