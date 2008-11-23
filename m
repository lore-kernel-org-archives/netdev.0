From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] 8139too: use err.h macros
Date: Sun, 23 Nov 2008 10:45:37 -0800
Message-ID: <20081123104537.792633cd@extreme>
References: <20081123102237.42cc99dd@extreme>
	<20081123183645.GA11340@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48705 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751723AbYKWSqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2008 13:46:18 -0500
In-Reply-To: <20081123183645.GA11340@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Nov 2008 13:36:45 -0500
Jeff Garzik <jeff@garzik.org> wrote:

> On Sun, Nov 23, 2008 at 10:22:37AM -0800, Stephen Hemminger wrote:
> > Instead of using call by reference use the PTR_ERR macros to handle
> > return value with error case. Compile tested only.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > --- a/drivers/net/8139too.c	2008-11-23 10:16:26.000000000 -0800
> > +++ b/drivers/net/8139too.c	2008-11-23 10:19:05.000000000 -0800
> > @@ -741,8 +741,7 @@ static void rtl8139_chip_reset (void __i
> >  }
> >  
> >  
> > -static int __devinit rtl8139_init_board (struct pci_dev *pdev,
> > -					 struct net_device **dev_out)
> > +static __devinit struct net_device * rtl8139_init_board (struct pci_dev *pdev)
> >  {
> >  	void __iomem *ioaddr;
> >  	struct net_device *dev;
> 
> I won't NAK this, but I do wonder why a solution based on yucky
> magic typecasting is preferred...?
> 
> 	Jeff

Dave described the issue last year:
=================================================================================

Today I want to talk about multiple return values. In short, don't do it :-) It really is a sign that things need to be redesigned, and on top of it multiple return values result in quite inefficient code.

The most common case with C is when you need to allocate some memory and return it to caller, but if something goes wrong you want to give some error status too.

So you end up with absolute crap like this:

int create_foo(int flags, struct foo **foop)

or, even worse:

struct foo *create_foo(int flags, int *errp)

I mean, that just doesn't deserve to live. First of all, the compiler has to allocate stack space for that "by reference" turd you had to add to the arguments to pass that second piece of information back. And that's slow, even on register starved cpus like x86 where stack accesses have been heavily optimized inside of the cpu to make up for that.

Secondly, the semantics are not entirely clear. If an error happens for the second API above, will the function return value always be NULL? In the first API above, when an error happens will the "*foop" always be NULL'd out for me or is the caller expected to do that? Likewise, for the second API above, if there is no error and non-NULL is returned, can I depend upon "*errp" being set to zero?

You don't know, because when you look at that interface definition you simply cannot tell. It's one big ambiguous ugly interface.

For this particular case in the kernel we've settled on a set of macros that allow a pointer and an error to be returned in a single function return value. Basically, it takes advantage of the fact that the range of negative error codes cannot ever be legitimate pointers. So the interface above looks like:

struct foo *create_foo(int flags)

and the caller first checks:

	p = create_foo(flags);
	if (IS_ERR(p)) {
		err = PTR_ERR(p);
		return err;
	}

And if "IS_ERR" is not true, it is a non-NULL pointer and no error happened.

It is completely unambiguous what the return values mean, and how they will be presented to the caller. Yes, it's true that looking at the function definition you can't "see" this. But once people are exposed to this pattern enough they pick it up, and it allows us to eliminate ambiguity and unclear semantics for these kinds of cases. 



http://vger.kernel.org/~davem/cgi-bin/blog.cgi/2007/12/31

