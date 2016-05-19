From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] Revert "phy: add support for a reset-gpio specification"
Date: Thu, 19 May 2016 11:09:49 -0700
Message-ID: <20160519180949.GB606@roeck-us.net>
References: <1463587500-12293-1-git-send-email-fabio.estevam@nxp.com>
 <b2763da7-575a-4d73-2997-4236173761bf@cogentembedded.com>
 <573DBFD6.2050508@roeck-us.net>
 <35f32e86-09f4-7e7d-6cf1-49805407e068@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fabio Estevam <fabio.estevam@nxp.com>, davem@davemloft.net,
	u.kleine-koenig@pengutronix.de, f.fainelli@gmail.com,
	netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:57008 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933065AbcESSKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 14:10:07 -0400
Content-Disposition: inline
In-Reply-To: <35f32e86-09f4-7e7d-6cf1-49805407e068@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2016 at 08:11:22PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 05/19/2016 04:29 PM, Guenter Roeck wrote:
> 
> >>>Commit da47b4572056 ("phy: add support for a reset-gpio specification")
> >>>causes the following xtensa qemu crash according to Guenter Roeck:
> >>>
> >>>[    9.366256] libphy: ethoc-mdio: probed
> >>>[    9.367389]  (null): could not attach to PHY
> >>>[    9.368555]  (null): failed to probe MDIO bus
> >>>[    9.371540] Unable to handle kernel paging request at virtual address
> >>>0000001c
> >>>[    9.371540]  pc = d0320926, ra = 903209d1
> >>>[    9.375358] Oops: sig: 11 [#1]
> >>
> >>    Of course, I'd like this patch to be reverted (as it was applied
> >>erroneously instead of my patches)... but where's the backtrace? It's not
> >>immediately clear how this code can cause kernel oops...
> >>
> >See http://www.spinics.net/lists/kernel/msg2258611.html.
> 
>    OK, I'll try to comment on your analysis posted there:
> 
> >GPIOLIB is not configured in my test case, meaning gpiod_get_optional()
> >returns -ENOSYS, and phy_probe() thus returns an error. Question here is if
> >it is really appropriate for the XXX_optional() gpiolib functions to return
> >an error if GPIOLIB is not configured. Either case, result is that pretty
> >much all phy registrations will now fail if GPIOLIB is not configured.
> 
>    Yes, that's the primary issue. That's what needs to be fixed...
> 
As I pointed out, Uwe (who had submitted the offending patch) had objected
to a patch trying to do that last year. I think the problem is quite deep
in the gpio infrastructure: If GPIOLIB is not configured, the infrastructure
needs to do more than just return -ENOSYS. It should check if the property
exists, and only return -ENOSYS if that is the case, but NULL otherwise.

Unfortunately, that would not be easy to implement. It would have to evaluate
devicetree data, ACPI data, and platform data. Today that code is spread around
all over the gpio subsystem, so getting the semantics straight would be a
challenge, and it would be vulnerable to code changes in gpiolib. It would also
be too complex (or at least I think so) to be implemented as as static inline
functions, so some kind of basic gpiolib core code would be required.

Overall, state of the art is that XXX_optional() gpiolib functions simply
can not be used if the calling code must also work if GPIOLIB is not
configured.

Guenter 
