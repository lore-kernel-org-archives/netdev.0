From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: qla3xxx: Odd likely incorrect use of test_bit in qla3xxx.c
Date: Thu, 14 May 2015 11:01:16 +0300
Message-ID: <20150514080116.GF8431@mwanda>
References: <1431456145.2884.75.camel@perches.com>
 <20150513131908.GB8431@mwanda>
 <1431538491.2912.14.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42531 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbbENIB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 04:01:26 -0400
Content-Disposition: inline
In-Reply-To: <1431538491.2912.14.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 10:34:51AM -0700, Joe Perches wrote:
> On Wed, 2015-05-13 at 16:19 +0300, Dan Carpenter wrote:
> > Good eye, Joe.
> > 
> > I wrote a Smatch check to find similar bugs.  Te rhey weren't any other
> > places which tried to do bitwise OR.  The bug that happens occasionally
> > is:
> > 
> > #define MY_FLAG BIT(1)
> > 
> > 	if (test_bit(MY_FLAG, &map)) {
> > 		...
> > 
> > It's not normally harmful if it's used consistently, but ath9k had
> > memory corruption because they do:
> > 
> > 	set_bit(BIT(6), &some_unsigned_long);
> > 
> > Anyway, I'll send patches for the bugs I found and push the Smatch
> > check. Thanks!
> 
> In case the patches you found weren't of this type,
> there are other possibly suspicious uses with & like:
> 
> drivers/usb/host/ehci-tegra.c:		set_bit((wIndex & 0xff) - 1, &ehci->suspended_ports);
>

That's puzzling, yes, but my instinct without looking at the context is
that it's probably valid.  I didn't look at that that one, but I looked
at a bunch of similar cases.

My test only looked at test_bit().  I'll update it to look at set_bit()
and clear_bit() as well.  It only complains about "test_bit(x | y, " and
"test_bit(x < y, ".

Btw, Smatch already has a check for when people do:

	set_bit(FOO_BIT, &flags);

	...

	if (flags & FOO_BIT) {

It looks uses the macro names, so if you open code it then it won't
catch the inconsistency, but mostly it works.

regards,
dan carpenter
