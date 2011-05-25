From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] bonding: prevent deadlock on slave store with alb mode
Date: Tue, 24 May 2011 22:20:56 -0400
Message-ID: <20110525022056.GA10182@hmsreliant.think-freely.org>
References: <1306265765-8257-1-git-send-email-nhorman@tuxdriver.com>
 <20110524200047.GI21309@gospo.rdu.redhat.com>
 <4DDC116F.8020602@gmail.com>
 <20110524203714.GG28521@hmsreliant.think-freely.org>
 <4DDC1A4E.6080700@gmail.com>
 <12577.1306271574@death>
 <20110524231813.GA2350@neilslaptop.think-freely.org>
 <20007.1306283668@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?us-ascii?Q?=3D=3Fus-ascii=3FB=3FPT9JU08tODg1OS0xP1E=2FTmljb2xhc19kZV?=
	 =?us-ascii?Q?9QZXNsbz1GQ2FuPz0=3D=3F=3D?=
	<nicolas.2p.debian@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57669 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611Ab1EYCVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 22:21:14 -0400
Content-Disposition: inline
In-Reply-To: <20007.1306283668@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2011 at 05:34:28PM -0700, Jay Vosburgh wrote:
> Neil Horman <nhorman@tuxdriver.com> wrote:
>=20
> >On Tue, May 24, 2011 at 02:12:54PM -0700, Jay Vosburgh wrote:
> >> Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com> wrote:
> >>=20
> >> >Le 24/05/2011 22:37, Neil Horman a =E9crit :
> >> >
> >> >>>>> +		return -EINVAL;
> >> >>>
> >> >>> This will turn a warning into an error.
> >> >>>
> >> >> Yes, because it should have been an error all along.
> >> >>
> >> >>> This warning existed for long, but never caused the bonding se=
tup to
> >> >>> fail. This patch cause some regression for user space. For exa=
mple,
> >> >>> current ifenslave-2.6 package in Debian doesn't ensure bond is=
 UP
> >> >>> before enslaving, because this was never required.
> >> >>>
> >> >> Thats not a regression, thats the kernel returning an error whe=
re it should have
> >> >> done so all along.  Just because a utility got away with it for=
 awhile and it
> >> >> didn't always cause a lockup, doesn't grandfather that applicat=
ion in to a
> >> >> situation where the kernel has to support its broken behavior i=
n perpituity.
> >> >>
> >> >> Besides, iirc, the ifsenslave utility still uses the ioctl path=
, which this
> >> >> patch doesn't touch, so ifenslave is currently unaffected (alth=
ough I should
> >> >> look in the ioctl path to see if we have already added such a c=
heck, lest you be
> >> >> able to deadlock your system as previously indicated using that=
 tool).
> >> >
> >> >Unfortunately, no. Recent versions of ifenslave-2.6 on Debian don=
't use
> >> >ioctl (ifenslave binary) anymore, but only sysfs.
> >> >
> >> >Documentation/bonding.txt should be updated to reflect this chang=
e.
> >> >pr_warning should be changed to pr_ err.
> >> >Bonding version should be bumped.
> >> >
> >> >Anyway, I will fix this package, but I suspect there exist many u=
ser
> >> >scripts that don't ensure bond is up before enslaving.
> >>=20
> >> 	I looked at sysconfig (as supplied with opensuse) and it uses
> >> sysfs, and does set the master device up first.  The other potenti=
al
> >> user that comes to mind is that OFED at one point had a script to =
set up
> >> bonding for Infiniband devices.  I don't know if this is still the=
 case,
> >> nor do I know if it set the bond device up before enslaving.
> >>=20
> >> 	Generally speaking, though, in the long run I think it should be
> >> permissible to change any bonding option when the bond is down (ev=
en to
> >> values that make no sense in context, e.g., setting the primary to=
 a
> >> device not currently enslaved).  My rationale here is that some op=
tions
> >> are very difficult to modify when the bond is up (e.g., changing t=
he
> >> mode), and now some other set is precluded when the bond is down. =
 The
> >> init scripts already have repeat logic in them; this just makes th=
ings
> >> more complicated.
> >>=20
> >> 	There should be a state wherein any option can be changed (well,
> >> maybe not max_bonds), and that should be the down state.  A subset=
 can
> >> also be changed while up.  I'd be happy to be able to change all o=
ptions
> >> while the bond is up, too, but that seems pretty hard to do.
> >>=20
> >> 	How much harder is it to fix the locking and permit the action
> >> in question here?
> >>=20
> >In this case, to just hack something in place is pretty easy, I can =
just
> >initalize the spinlocks for all cases in the bond_create path.  But =
to do in any
> >sort of sensical way is much harder, since the code is written such =
that you
> >initialize various relevant data structures based on the mode of the=
 bond,
> >which, as you indicated above, you want the right to change up until=
 the point
> >where you ifup the bonded interface.=20
> >
> >The whole thing is predicated on the notion that
> >transitioning from the down to up state is the gating factor to init=
ializing the
> >current configuration.  What might work is an in-between state in wh=
ich you commit
> >and initialize a bond based on the current configuation.  Doing so w=
ould allow
> >you to (re-)initialize a bond configuration in a safe state.  Only a=
fter
> >commiting a configuration could you enslave devices or ifup the bond=
=2E  Once up,
> >further commits would be non-permissable until the bond was brought =
down again.
> >Of course, this would also require changing the semantics of the use=
r space
> >tools.
>=20
> 	One alternative is to simply permit all option changes while the
> bond is down, then commit then as a set when the bond is brought up (=
or
> fail the open or adjust options if the options are invalid).  More or
> less what you suggest, except that the "commit" is the ifup.
>=20
Well, thats rather the problem, by making the ifup be the commit step, =
you deny
the 'in between phase' where the configuration is applied, but prior to=
 the
interface being up, so its safe to enslave devices.

> 	Even that is a substantial rework of how things are done now,
> since as you point out, options today take effect more or less in rea=
l
> time.
>=20
Agreed its both a large undertaking, and it still requires user space
co-ordination.

> >This also begs the question, is it or is it not safe to enslave devi=
ces while
> >the bond is down?  Clearly from the bug report its unsafe, and I don=
't know what
> >other (if any) conditions exist that cause problems when doing this =
(be that a
> >deadlock, panic or simply undefined or unexpected behavior).  If its=
 really
> >unsafe, then issuing a warning seems incorrect, we shouldn't allow u=
ser space to
> >cause things like this, and as such, we should return an error.  If =
it is safe
> >(generally) and this is an isolated bug, then we should probably rem=
ove the
> >warning.  But to just issue a vague 'This might do bad things' warni=
ng seems
> >wrong in either case.
>=20
> 	Agreed.  I think it (conceptually) should be safe to add or
> remove slaves when the bond is down, and bonding shouldn't complain
> about it.
>=20
Ok, thats good to know then.

> 	Ok, I looked through the log, and originally enslaving while
> down via sysfs was disallowed when that code was added.
>=20
> 	Later, enslaving while down was enabled in a patch for
> Infiniband.  Reading the changelog explains why; for IB, enslaving wh=
ile
> up messed up the multicast group addresses:
>=20
> commit 6b1bf096508c870889c2be63c7757a04d72116fe
> Author: Moni Shoua <monis@voltaire.com>
<snip commit log>
>=20
> 	Assuming this situation hasn't changed (and I'm not sure how it
> could, because the first IB slave causes a type change), I don't beli=
eve
> we can disallow enslaving while the bond is down because IB depends o=
n
> it.
>=20
Ok, thats also good to know.  Thank you for doing the research on that.

> >I'll respin the patch to just initialize the spinlocks in the mornin=
g, if thats
> >what will fix the deadlock, but it really seems like the wrong way t=
o go to me.
> >If enslaving devices to a bond while its down has been known to caus=
e problems,
> >then we shouldn't allow it and we should update the user space tools=
 to
> >understand and handle that.
>=20
> 	This is the first I've heard of it causing a panic; looking
> back, I can also see some issues with the warning itself (because it
> happens prior to the rtnl_trylock, the message may repeat a lot if rt=
nl
> is contended), so I'm happy to see the warning go away either way.
>=20
Copy that, it sounds like the warning isn't actually needed (i.e. ensla=
ving with
the bond down should be safe, and this panic is an outlier condition). =
 I'll
respin the patch with the spinlock initialized in the create path and r=
emove the
warning removed in the AM

Thanks!
Neil

> 	-J
>=20
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>=20
