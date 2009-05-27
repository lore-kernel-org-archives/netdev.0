From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] netdev: enc28j60: use IRQF_TRIGGER_FALLING for IRQ by default
Date: Tue, 26 May 2009 18:17:06 -0700
Message-ID: <200905261817.07161.david-b@pacbell.net>
References: <1243333007-25645-1-git-send-email-vapier@gentoo.org> <200905261121.54075.david-b@pacbell.net> <200905261743.16036.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Baruch Siach <baruch@tkos.co.il>,
	Michael Hennerich <michael.hennerich@analog.com>,
	netdev@vger.kernel.org, Bryan Wu <cooloney@kernel.org>
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp108.sbc.mail.gq1.yahoo.com ([67.195.14.111]:37436 "HELO
	smtp108.sbc.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754840AbZE0BXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 21:23:46 -0400
In-Reply-To: <200905261743.16036.vapier@gentoo.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > > > Right ... the appended patch will *undo* the setting
> > > > established in the board init code via set_irq_type().
> > > >
> > > > Moreover, it completely prevents working on systems which
> > > > only support "both edges" triggering.
> > >
> > > how can it provide breakage when people are forced to use set_irq_type()
> > > ?
> >
> > It reverses the IRQ setup done by the board code ...
> 
> how so ?  this code does the irq requesting which means the set_irq_type() 
> needs to come after it

No; set_irq_type() can happen at any time.  It just does setup.
One policy sets IRQ types beforehand.

Equivalently, the driver may run on hardware which only supports
one policy ... *NOT* the policy you propose the driver be changed
to require.


> anyways since the request_irq() will set any flags  
> passed to it, right ?

Wrong.  A set_irq_type() call ensures the IRQ will trigger as
specified by its parameters (unless it fails).  The current
request_irq() leaves that "default" setup alone.

Your patch changes that configuration, making it request
a trigger mode that (a) the hardware may not support, so
the request_irq() will fail; else if it succeeds, then
(b) will clobber whatever mode that was already set up.
The first certainly breaks things; the second probably
does so.


> > the code which you said they'd have to use to work
> > around the breakage your patch adds.
> 
> umm, i'm referring to code the driver and you says should be put in place -- a 
> call to set_irq_type() somewhere in the board init code.

Which is well before the driver request_irq().  As noted
above, you're trying to make the driver request a specific
IRQ type, which is *NOT* one that can necessarily be
supported.

On the other hand, the current IRQ_NONE (type == 0) is by
definition be supported *everywhere* ...

