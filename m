From: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>
Subject: Re: forcedeth: MAC-address reversed on resume from suspend
Date: Fri, 4 Jan 2008 11:17:40 +0100
Message-ID: <20080104101740.GA4406@atjola.homenet>
References: <477BFC71.7090002@coderworld.net> <20080102214843.GA19224@rhlx01.hs-esslingen.de> <20080102234209.GA10831@does.not.exist> <20080104034357.GA2113@atjola.homenet> <20080104084517.GA21628@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adrian Bunk <bunk@kernel.org>,
	Richard Jonsson <richie@coderworld.net>,
	linux-kernel@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: Andreas Mohr <andi@lisas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:38850 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750855AbYADKRo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2008 05:17:44 -0500
Content-Disposition: inline
In-Reply-To: <20080104084517.GA21628@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2008.01.04 09:45:17 +0100, Andreas Mohr wrote:
> Hi,
>=20
> On Fri, Jan 04, 2008 at 04:43:57AM +0100, Bj=F6rn Steinbrink wrote:
> > On 2008.01.03 01:42:09 +0200, Adrian Bunk wrote:
> > > [ original bug report: http://lkml.org/lkml/2008/1/2/253 ]
> > >=20
> > > On Wed, Jan 02, 2008 at 10:48:43PM +0100, Andreas Mohr wrote:
> > > > The nv_probe() function then nicely obeys this flag by reversin=
g the
> > > > address if needed, _however_ there's another function,
> > > > nv_copy_mac_to_hw(), which does _NOT_ obey it and simply copies=
 the
> > > > _raw_ netdev dev_addr to the card register (NvRegMacAddrA etc.)=
=2E
> >=20
> > nv_copy_mac_to_hw() is called from nv_probe() _after_ the MAC addre=
ss
> > has been fixed, and from nv_set_mac_address() which is supposed to =
get a
> > correct MAC address anyway. So I don't see any problem there.
>=20
> /* set permanent address to be correct aswell */
> ... orig_mac fumbling ...
>=20
> Why, then, does this driver do such a nice hack as:
>=20
>         /* special op: write back the misordered MAC address - otherw=
ise
>          * the next nv_probe would see a wrong address.
>          */
>         writel(np->orig_mac[0], base + NvRegMacAddrA);
>         writel(np->orig_mac[1], base + NvRegMacAddrB);
>=20
> I really don't see why this driver needs to do these things in such a
> messy way.

Sure you can add some layers of wrappers and then have
"nv_store_mac(np->orig_mac)" instead. Congratulations, you saved 2 line=
s
and added 6 new ones (assuming that you don't go universally u8, that
adds even more). This is the only place that writes the MAC address
besides the existing nv_copy_mac_to_hw wrapper which deals with
net_devices and thus is perfectly usable, internally and externally.

> One thing is for certain: netdev->dev_addr is always in operating sys=
tem
> order, and order should always be handled properly when copying to/fr=
om
> hardware.
>=20
> Such a driver needs exactly *one* central helper method
> to reverse an input MAC address in 6 bytes u8 format
> (which could arguably be added to include/linux/etherdevice.h even,
> since a wee bit too many devices seem to be having trouble
> with wrongly ordered MAC addresses).
> Then it needs exactly *one* function for I/O register access
> to read a MAC address from a device and exactly *one* function
> to write it back (both doing raw, unsorted format transfers only,
> and possibly as inline function).

A function to read the MAC address from the hardware? There's only a
single place (nv_probe()) that ever reads it, why bother?

> And then it needs these card I/O functions wrapped into two functions=
 which
> interface with driver- and OS-related MAC variables
> (struct variables ALWAYS stored in usual system order, NOT H/W order!=
!!!!!)
> which optionally reverse the address (if needed for a particular card=
).

Hu? The MAC address is only ever reversed when the card is not in use,
why the hell would you want to reverse anything when the rest of the OS
is involved? This whole reversing stuff is purely before and after the
card is actually used. It's not that you need to reverse the address to
communicate with the card, it's just initially wrong on the card.

> And then there will never be any confusion about any MAC address form=
at
> anywhere any more, right?

At probing time, you'll have to know whether the address you read from
the hardware is reversed or not. Unless you write it back in reversed
order when you release the card, you need a flag that at least survives
until nv_probe is called the next time. kexec does not write it back, s=
o
you do need such a flag. But the flag apparently doesn't survive a
suspend/resume cycle, so you need to write back the reversed address
then. But the flag will survive a rmmod + modprobe cycle, so you need t=
o
reset it when writing back the reversed address.

> I really don't mean to sound cranky, but this driver did ask for trou=
ble,
> and lots of it ;)
>=20
> Thank you for your reply, and especially thank you for this very fast
> patch!

Well, let's see if my analysis was correct and the patch works, first. =
I
saw the forcedeth code before, but kexec and suspend is totally new to
me and I just made some assumptions based on the reported behaviour and
the commit messages... ;-)

Bj=F6rn
