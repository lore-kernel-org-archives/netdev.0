From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] bonding: prevent deadlock on slave store with alb mode
Date: Tue, 24 May 2011 19:18:13 -0400
Message-ID: <20110524231813.GA2350@neilslaptop.think-freely.org>
References: <1306265765-8257-1-git-send-email-nhorman@tuxdriver.com>
 <20110524200047.GI21309@gospo.rdu.redhat.com>
 <4DDC116F.8020602@gmail.com>
 <20110524203714.GG28521@hmsreliant.think-freely.org>
 <4DDC1A4E.6080700@gmail.com>
 <12577.1306271574@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?us-ascii?B?PT9JU08tODg1OS0xP1E/Tmljb2xhc19kZV9QZXNsbz1GQ2FuPz0=?=
	<nicolas.2p.debian@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41333 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932311Ab1EXXSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 19:18:32 -0400
Content-Disposition: inline
In-Reply-To: <12577.1306271574@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2011 at 02:12:54PM -0700, Jay Vosburgh wrote:
> Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com> wrote:
>=20
> >Le 24/05/2011 22:37, Neil Horman a =E9crit :
> >
> >>>>> +		return -EINVAL;
> >>>
> >>> This will turn a warning into an error.
> >>>
> >> Yes, because it should have been an error all along.
> >>
> >>> This warning existed for long, but never caused the bonding setup=
 to
> >>> fail. This patch cause some regression for user space. For exampl=
e,
> >>> current ifenslave-2.6 package in Debian doesn't ensure bond is UP
> >>> before enslaving, because this was never required.
> >>>
> >> Thats not a regression, thats the kernel returning an error where =
it should have
> >> done so all along.  Just because a utility got away with it for aw=
hile and it
> >> didn't always cause a lockup, doesn't grandfather that application=
 in to a
> >> situation where the kernel has to support its broken behavior in p=
erpituity.
> >>
> >> Besides, iirc, the ifsenslave utility still uses the ioctl path, w=
hich this
> >> patch doesn't touch, so ifenslave is currently unaffected (althoug=
h I should
> >> look in the ioctl path to see if we have already added such a chec=
k, lest you be
> >> able to deadlock your system as previously indicated using that to=
ol).
> >
> >Unfortunately, no. Recent versions of ifenslave-2.6 on Debian don't =
use
> >ioctl (ifenslave binary) anymore, but only sysfs.
> >
> >Documentation/bonding.txt should be updated to reflect this change.
> >pr_warning should be changed to pr_ err.
> >Bonding version should be bumped.
> >
> >Anyway, I will fix this package, but I suspect there exist many user
> >scripts that don't ensure bond is up before enslaving.
>=20
> 	I looked at sysconfig (as supplied with opensuse) and it uses
> sysfs, and does set the master device up first.  The other potential
> user that comes to mind is that OFED at one point had a script to set=
 up
> bonding for Infiniband devices.  I don't know if this is still the ca=
se,
> nor do I know if it set the bond device up before enslaving.
>=20
> 	Generally speaking, though, in the long run I think it should be
> permissible to change any bonding option when the bond is down (even =
to
> values that make no sense in context, e.g., setting the primary to a
> device not currently enslaved).  My rationale here is that some optio=
ns
> are very difficult to modify when the bond is up (e.g., changing the
> mode), and now some other set is precluded when the bond is down.  Th=
e
> init scripts already have repeat logic in them; this just makes thing=
s
> more complicated.
>=20
> 	There should be a state wherein any option can be changed (well,
> maybe not max_bonds), and that should be the down state.  A subset ca=
n
> also be changed while up.  I'd be happy to be able to change all opti=
ons
> while the bond is up, too, but that seems pretty hard to do.
>=20
> 	How much harder is it to fix the locking and permit the action
> in question here?
>=20
In this case, to just hack something in place is pretty easy, I can jus=
t
initalize the spinlocks for all cases in the bond_create path.  But to =
do in any
sort of sensical way is much harder, since the code is written such tha=
t you
initialize various relevant data structures based on the mode of the bo=
nd,
which, as you indicated above, you want the right to change up until th=
e point
where you ifup the bonded interface.=20

The whole thing is predicated on the notion that
transitioning from the down to up state is the gating factor to initial=
izing the
current configuration.  What might work is an in-between state in which=
 you commit
and initialize a bond based on the current configuation.  Doing so woul=
d allow
you to (re-)initialize a bond configuration in a safe state.  Only afte=
r
commiting a configuration could you enslave devices or ifup the bond.  =
Once up,
further commits would be non-permissable until the bond was brought dow=
n again.
Of course, this would also require changing the semantics of the user s=
pace
tools.

This also begs the question, is it or is it not safe to enslave devices=
 while
the bond is down?  Clearly from the bug report its unsafe, and I don't =
know what
other (if any) conditions exist that cause problems when doing this (be=
 that a
deadlock, panic or simply undefined or unexpected behavior).  If its re=
ally
unsafe, then issuing a warning seems incorrect, we shouldn't allow user=
 space to
cause things like this, and as such, we should return an error.  If it =
is safe
(generally) and this is an isolated bug, then we should probably remove=
 the
warning.  But to just issue a vague 'This might do bad things' warning =
seems
wrong in either case.

I'll respin the patch to just initialize the spinlocks in the morning, =
if thats
what will fix the deadlock, but it really seems like the wrong way to g=
o to me.
If enslaving devices to a bond while its down has been known to cause p=
roblems,
then we shouldn't allow it and we should update the user space tools to
understand and handle that.
Neil

> 	-J
>=20
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>=20
