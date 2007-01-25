From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: Re: [PATCH REPOST 1/2] NET: Accurate packet scheduling for
	ATM/ADSL (kernel)
Date: Thu, 25 Jan 2007 10:55:29 +1000
Message-ID: <1169686529.5776.202.camel@ras.pc.brisbane.lube>
References: <1161041677.6247.1.camel@ras.pc.brisbane.lube>
	 <1161090444.5555.13.camel@jzny2>  <45378DE3.8080700@trash.net>
	 <1161602527.5502.155.camel@ras.pc.stuart.local>
	 <453CB801.4010902@trash.net>
	 <1161640444.5502.214.camel@ras.pc.stuart.local> <453E3CFC.80007@trash.net>
	 <1161733596.3829.91.camel@ras.pc.brisbane.lube>
	 <456ED79E.2070707@trash.net> <1169075223.7560.15.camel@ras>
	 <45AEF219.2060304@trash.net> <1169100970.21535.18.camel@ras>
	 <45AF5C02.1010005@trash.net> <1169176280.1118.8.camel@ras>
	 <45B0B744.7070800@trash.net> <1169263517.11507.14.camel@ras>
	 <45B1D715.8010609@trash.net> <1169365528.3866.71.camel@ras.pc.stuart.local>
	 <45B78B8F.9090106@trash.net>
	 <1169677979.5776.150.camel@ras.pc.brisbane.lube>
	 <45B7F482.7040703@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	Jesper Dangaard Brouer <hawk@diku.dk>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:54151 "EHLO
	adsl-kenny.stuart.id.au" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S964916AbXAYAzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 19:55:50 -0500
In-Reply-To: <45B7F482.7040703@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-01-25 at 01:06 +0100, Patrick McHardy wrote:
> Of course he has to, just like your "atm" parameter. In case
> of stabs it would be something like "stab atm".

The difference being with "atm" he is telling the kernel
he has an ATM line, but with STAB he is telling the 
kernel how it should internally calculate packet lengths
and transmission times.  Why should he care how the
kernel does it?  Surely this should be hidden.  As it
is now, BTW.

> > I was a little too brief.
> > 
> > The comment stems from the observation that in all
> > current implementations:
> > 
> >    const A_CONSTANT;
> >    for (i = 0; i < 256; i += 1)
> >      assert(RTAB[i] == STAB[i] * A_CONSTANT);
> > 
> > Ergo, if in addition to implementing STAB as you
> > plan to, A_CONSTANT was shipped to the kernel then
> > RTAB could be replaced.
> 
> At least look at the patch I sent. STAB mapping is _not_ a
> multiplication by a constant (which wouldn't be able to
> express minimum packet size or padding to multiples of cell
> sizes).

You have read this the wrong way.  Firstly I did look
at the patch you posted - and commented on it in some
detail.  Admittedly it was a while ago.  The details
are fuzzy now, but I am pretty sure I know what you
want achieve and how you plan to go about it.

Secondly, I am not saying STAB is a multiplication by
a constant - any more than RTAB is multiplication by
a constant.  I am fully aware that STAB can take into
account MPU's, cell padding, additional protocol 
overhead and whatnot - just like RTAB does now.

What I am saying is that on or about is summed up in
the tc_calc_xmittime() function in tc_core.c.  It is
a grand total of 1 line long:

  return tc_core_usec2tick(1000000*((double)size/rate));

Later on in the code, we have this assignment:

  rtab[i] = tc_calc_xmittime(bps, sz);

Which can be re-written:

  rtab[i] = tc_core_usec2tick(1000000*((double)size/rate));

If STAB was introduced and was kept to a fixed 256
elements (I am not suggesting it should be), the 
core change would be to change the line above to 
read:

  stab[i] = size;
  rtab[i] = tc_core_usec2tick(1000000*((double)stab[i]/rate));

Thus my assertion that:

  RTAB[i] = STAB[i] * A_CONSTANT

is literally true.  A_CONSTANT is currently always
1000000 / rate * HZ.

All I am saying is that in the kernel, wherever we
have a reference to rtab[i] now, after your stab is
introduced that reference could be replaced by
stab[i] * A_CONSTANT, provided A_CONSTANT was sent
with stab by tc.

Doing this would have several advantages:

  a.  Uses less space than having both RTAB and STAB.

  b.  Provides the framework to allow the kernel to
      overcomes my problem with HZ being too slow
      for ATM links > 2M bips/sec.

  c.  Puts an end to my whinging about compatibility
      problems above.  We can just send the old RTAB.
      It will be ignored by kernels that use STAB.

Are you objecting to this because I hadn't spelt it
out clearly, or is there something deeper I am 
missing?  It doesn't seem like a radical proposal to
me.

