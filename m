From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH v3] ipconfig wait for carrier
Date: Thu, 19 May 2011 14:32:47 -0500
Message-ID: <1305833568.3271.27.camel@dcbw.foobar.com>
References: <4DD36803.1020001@neli.hopto.org>
		 <20110518.023725.441358922110721042.davem@davemloft.net>
		 <4DD36E54.9040706@neli.hopto.org>
		 <20110518.181427.1228926976939865196.davem@davemloft.net>
	 <1305819120.3271.3.camel@dcbw.foobar.com> <4DD56701.8040007@neli.hopto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Micha Nelissen <micha@neli.hopto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3384 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934235Ab1ESTan (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 15:30:43 -0400
In-Reply-To: <4DD56701.8040007@neli.hopto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-19 at 20:52 +0200, Micha Nelissen wrote:
> Dan Williams wrote:
> > On Wed, 2011-05-18 at 18:14 -0400, David Miller wrote:
> >> Please fix ic_is_init_dev() to return a proper boolean "false" instead
> >> of "0" when IFF_LOOPBACK is set.
> 
> Ok. Had an int before, but boolean is better.
> 
> > Shouldn't the code still wait at *least* one second?  Not all drivers
> > support carrier detect, and those that don't set the carrier always-on.
> > Thus older devices that used to have 1s to get carrier in line (even if
> > they don't report it) now have only 10ms.
> > 
> > I think it should wait at least one second like the code currently does,
> > and then if the carrier still isn't up, wait longer.
> 
> What is the 1 second based on?
> 
> If a driver does not support carrier detect, then this code will wait
> for the timeout period. Or do those older drivers set carrier detect
> immediately when device is probed?

Older devices that do not support carrier detect have the carrier always
on, ie IFF_RUNNING is always set, and netif_carrier_ok() always returns
1.  There is currently no way to determine whether a device supports
carrier detection or not, since drivers do not set a flag anywhere to
that effect (though I'd like it if they did).

I think the bit we're talking about is the change to CONF_POST_OPEN and
the corresponding change from ssleep(1) -> msleep(10).  For drivers that
don't support carrier detect, the patch would effectively decrease the
time that these drivers have to establish a carrier (even if they don't
report it to the kernel!) from 1 second to 10ms.  Then the code in
ic_open_devs() will immediately fall down to have_carrier because these
drivers have the carrier always one.

Net result: previously there was a 1 second window for this older
hardware to establish a link, now there is a 10ms window.  That's a
behavior change that could break stuff that used to work.

Dan

> Micha
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


