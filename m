From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: prevent deadlock on slave store with alb mode
Date: Tue, 24 May 2011 17:34:28 -0700
Message-ID: <20007.1306283668@death>
References: <1306265765-8257-1-git-send-email-nhorman@tuxdriver.com> <20110524200047.GI21309@gospo.rdu.redhat.com> <4DDC116F.8020602@gmail.com> <20110524203714.GG28521@hmsreliant.think-freely.org> <4DDC1A4E.6080700@gmail.com> <12577.1306271574@death> <20110524231813.GA2350@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?us-ascii?Q?=3D=3Fus-ascii=3FB=3FPT9JU08tODg1OS0xP1E=2FTmljb2xhc19kZV?=
	 =?us-ascii?Q?9QZXNsbz1GQ2FuPz0=3D=3F=3D?=
	<nicolas.2p.debian@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:60751 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757457Ab1EYAeg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 20:34:36 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4P0NDUA027606
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 20:23:13 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4P0YXaF096866
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 20:34:33 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4P0YUAY014065
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 20:34:32 -0400
In-reply-to: <20110524231813.GA2350@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman@tuxdriver.com> wrote:

>On Tue, May 24, 2011 at 02:12:54PM -0700, Jay Vosburgh wrote:
>> Nicolas de Peslo=C3=BCan <nicolas.2p.debian@gmail.com> wrote:
>>=20
>> >Le 24/05/2011 22:37, Neil Horman a =C3=A9crit :
>> >
>> >>>>> +		return -EINVAL;
>> >>>
>> >>> This will turn a warning into an error.
>> >>>
>> >> Yes, because it should have been an error all along.
>> >>
>> >>> This warning existed for long, but never caused the bonding setu=
p to
>> >>> fail. This patch cause some regression for user space. For examp=
le,
>> >>> current ifenslave-2.6 package in Debian doesn't ensure bond is U=
P
>> >>> before enslaving, because this was never required.
>> >>>
>> >> Thats not a regression, thats the kernel returning an error where=
 it should have
>> >> done so all along.  Just because a utility got away with it for a=
while and it
>> >> didn't always cause a lockup, doesn't grandfather that applicatio=
n in to a
>> >> situation where the kernel has to support its broken behavior in =
perpituity.
>> >>
>> >> Besides, iirc, the ifsenslave utility still uses the ioctl path, =
which this
>> >> patch doesn't touch, so ifenslave is currently unaffected (althou=
gh I should
>> >> look in the ioctl path to see if we have already added such a che=
ck, lest you be
>> >> able to deadlock your system as previously indicated using that t=
ool).
>> >
>> >Unfortunately, no. Recent versions of ifenslave-2.6 on Debian don't=
 use
>> >ioctl (ifenslave binary) anymore, but only sysfs.
>> >
>> >Documentation/bonding.txt should be updated to reflect this change.
>> >pr_warning should be changed to pr_ err.
>> >Bonding version should be bumped.
>> >
>> >Anyway, I will fix this package, but I suspect there exist many use=
r
>> >scripts that don't ensure bond is up before enslaving.
>>=20
>> 	I looked at sysconfig (as supplied with opensuse) and it uses
>> sysfs, and does set the master device up first.  The other potential
>> user that comes to mind is that OFED at one point had a script to se=
t up
>> bonding for Infiniband devices.  I don't know if this is still the c=
ase,
>> nor do I know if it set the bond device up before enslaving.
>>=20
>> 	Generally speaking, though, in the long run I think it should be
>> permissible to change any bonding option when the bond is down (even=
 to
>> values that make no sense in context, e.g., setting the primary to a
>> device not currently enslaved).  My rationale here is that some opti=
ons
>> are very difficult to modify when the bond is up (e.g., changing the
>> mode), and now some other set is precluded when the bond is down.  T=
he
>> init scripts already have repeat logic in them; this just makes thin=
gs
>> more complicated.
>>=20
>> 	There should be a state wherein any option can be changed (well,
>> maybe not max_bonds), and that should be the down state.  A subset c=
an
>> also be changed while up.  I'd be happy to be able to change all opt=
ions
>> while the bond is up, too, but that seems pretty hard to do.
>>=20
>> 	How much harder is it to fix the locking and permit the action
>> in question here?
>>=20
>In this case, to just hack something in place is pretty easy, I can ju=
st
>initalize the spinlocks for all cases in the bond_create path.  But to=
 do in any
>sort of sensical way is much harder, since the code is written such th=
at you
>initialize various relevant data structures based on the mode of the b=
ond,
>which, as you indicated above, you want the right to change up until t=
he point
>where you ifup the bonded interface.=20
>
>The whole thing is predicated on the notion that
>transitioning from the down to up state is the gating factor to initia=
lizing the
>current configuration.  What might work is an in-between state in whic=
h you commit
>and initialize a bond based on the current configuation.  Doing so wou=
ld allow
>you to (re-)initialize a bond configuration in a safe state.  Only aft=
er
>commiting a configuration could you enslave devices or ifup the bond. =
 Once up,
>further commits would be non-permissable until the bond was brought do=
wn again.
>Of course, this would also require changing the semantics of the user =
space
>tools.

	One alternative is to simply permit all option changes while the
bond is down, then commit then as a set when the bond is brought up (or
fail the open or adjust options if the options are invalid).  More or
less what you suggest, except that the "commit" is the ifup.

	Even that is a substantial rework of how things are done now,
since as you point out, options today take effect more or less in real
time.

>This also begs the question, is it or is it not safe to enslave device=
s while
>the bond is down?  Clearly from the bug report its unsafe, and I don't=
 know what
>other (if any) conditions exist that cause problems when doing this (b=
e that a
>deadlock, panic or simply undefined or unexpected behavior).  If its r=
eally
>unsafe, then issuing a warning seems incorrect, we shouldn't allow use=
r space to
>cause things like this, and as such, we should return an error.  If it=
 is safe
>(generally) and this is an isolated bug, then we should probably remov=
e the
>warning.  But to just issue a vague 'This might do bad things' warning=
 seems
>wrong in either case.

	Agreed.  I think it (conceptually) should be safe to add or
remove slaves when the bond is down, and bonding shouldn't complain
about it.

	Ok, I looked through the log, and originally enslaving while
down via sysfs was disallowed when that code was added.

	Later, enslaving while down was enabled in a patch for
Infiniband.  Reading the changelog explains why; for IB, enslaving whil=
e
up messed up the multicast group addresses:

commit 6b1bf096508c870889c2be63c7757a04d72116fe
Author: Moni Shoua <monis@voltaire.com>
Date:   Tue Oct 9 19:43:40 2007 -0700

    net/bonding: Enable IP multicast for bonding IPoIB devices
   =20
    Allow to enslave devices when the bonding device is not up. Over th=
e discussion
    held at the previous post this seemed to be the most clean way to g=
o, where it
    is not expected to cause instabilities.
   =20
    Normally, the bonding driver is UP before any enslavement takes pla=
ce.
    Once a netdevice is UP, the network stack acts to have it join some=
 multicast groups
    (eg the all-hosts 224.0.0.1). Now, since ether_setup() have set the=
 bonding device
    type to be ARPHRD_ETHER and address len to be ETHER_ALEN, the net c=
ore code
    computes a wrong multicast link address. This is b/c ip_eth_mc_map(=
) is called
    where for multicast joins taking place after the enslavement anothe=
r ip_xxx_mc_map()
    is called (eg ip_ib_mc_map() when the bond type is ARPHRD_INFINIBAN=
D)
   =20
    Signed-off-by: Moni Shoua <monis at voltaire.com>
    Signed-off-by: Or Gerlitz <ogerlitz at voltaire.com>
    Acked-by: Jay Vosburgh <fubar@us.ibm.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

	Assuming this situation hasn't changed (and I'm not sure how it
could, because the first IB slave causes a type change), I don't believ=
e
we can disallow enslaving while the bond is down because IB depends on
it.

>I'll respin the patch to just initialize the spinlocks in the morning,=
 if thats
>what will fix the deadlock, but it really seems like the wrong way to =
go to me.
>If enslaving devices to a bond while its down has been known to cause =
problems,
>then we shouldn't allow it and we should update the user space tools t=
o
>understand and handle that.

	This is the first I've heard of it causing a panic; looking
back, I can also see some issues with the warning itself (because it
happens prior to the rtnl_trylock, the message may repeat a lot if rtnl
is contended), so I'm happy to see the warning go away either way.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
