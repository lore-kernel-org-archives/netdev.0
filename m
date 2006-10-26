From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: e100: Wait for PHY reset to complete?
Date: Wed, 25 Oct 2006 18:07:57 -0700
Message-ID: <45400A6D.4020704@intel.com>
References: <453F9D4A.8090306@users.sourceforge.net>    <20061025185656.GA19037@electric-eye.fr.zoreil.com>    <453FC693.10705@intel.com> <453FD677.7060405@intel.com> <3699.82.182.159.28.1161819386.squirrel@webmail.sys.kth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28531 "EHLO mga09.intel.com")
	by vger.kernel.org with ESMTP id S1422778AbWJZBKR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 21:10:17 -0400
To: =?ISO-8859-1?Q?Anders_Grafstr=F6m?= <grfstrm@users.sourceforge.net>
In-Reply-To: <3699.82.182.159.28.1161819386.squirrel@webmail.sys.kth.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anders Grafstr=F6m wrote:
> Auke Kok wrote:
>> Allthough the spec itself didn't talk about phy reset times, I've ra=
n this
>> patch with
>> some debugging output on a few boxes and did some speed/duplex setti=
ngs,
>> and the PHY
>> reset returned succesfull after the very first mdio_read, which is b=
efore
>> any msleep(10)
>> is executed. That is also expected behaviour.
>>
>> I think you might be confusing this with a MAC reset, which has a
>> documented 10usec
>> timeout (see 8255x developers manual). The driver already adheres to=
 this
>> by doing a
>> 20usec delay after software/selective resets.
>>
>> which gets us back to the original problem: how did your driver end =
up in
>> loopback mode?
>> (and, how did you figure out that it did??).
>=20
>=20
> This is what the 2.4.33.3 driver does:
>=20
> void
> e100_phy_reset(struct e100_private *bdp)
> {
>         u16 ctrl_reg;
>         ctrl_reg =3D BMCR_RESET;
>         e100_mdi_write(bdp, MII_BMCR, bdp->phy_addr, ctrl_reg);
>         /* ieee 802.3 : The reset process shall be completed       */
>         /* within 0.5 seconds from the settting of PHY reset bit.  */
>         set_current_state(TASK_UNINTERRUPTIBLE);
>         schedule_timeout(HZ / 2);
> }
>=20
> And here
> http://www.cs.helsinki.fi/linux/linux-kernel/2003-23/1245.html
> I found this entry:
>=20
> <scott.feldman@intel.com> (03/06/08 1.1218)
> [e100] misc
> <...>
> * Add 1/2 second delay after PHY reset to allow link partner to
> see and respond to reset, per IEEE 802.3.
>=20
>=20
> I ran mii-diag when the LEDs went out and the register dump
> said it was in loopback. It is somewhat difficult reproduce.
> It seems to be timing dependent, something else has to occur
> at the same time.
> I must confess I have only seen it with the 2.6.13 kernel.
> I have not been able to reproduce it with 2.6.18.
> But I have found no change in the driver that would fix it so
> I suspect the problem is still there.
>=20
> I have tried adding debug output to see if I can read back the
> RESET bit in set state, but then the problem refuses to show
> so I don't think I can rule out an unfinished PHY reset.

theoretically, yes, the ieee spec PHY reset timeout is kind of silly: i=
n no way do we=20
assume that we have re-negotiated link after 1/2 a second! Other code i=
n the driver=20
should take care of that, and since it works I'll assume it does ;)

the mdio_read probably acts as a flush to the hardware too - masqueradi=
ng problems, more=20
goodness. Perhaps we should do a single read in all cases and forget ab=
out the timeout=20
(is there an mdio_write_flush?)

Basically the timeout is wrong: a LINK reset is not a PHY reset. The PH=
Y is back online=20
and ready to respond in (probably) a single clock cycle. The link can t=
ake up to 3=20
seconds in normal cases. Waiting for 1/2 a second does not fix anything=
 there. Here's=20
where the 8255x (PHY part) spec abandons us: I don't read anything abou=
t PHY reset=20
timeouts in it.

Can you try to debug if your while () timeout loop is actually waiting =
for a significant=20
amount? something like adding a printk(KERN_ERR "counted down to %d0 ms=
ec\n", counter);=20
after the entire while{} loop should show you if there is variation in =
the PHY reset=20
time needed for the PHY to be back online.

running mii-diag before the link comes back up might be causing the iss=
ue in the first=20
place, and certainly suggests a small race.

Have you tried to run the e100-sbit branch from jgarzik's netdev-2.6 tr=
ee? We're still=20
looking into merging this and I guess I should push it to -mm to have i=
t receive some=20
testing....

Cheers,

Auke
