From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: remove superfluous call to synchronize_net()
Date: Thu, 16 Apr 2009 11:02:31 -0700
Message-ID: <20090416180231.GI6924@linux.vnet.ibm.com>
References: <49E5FF5E.50409@cosmosbay.com> <20090415215454.GU6766@linux.vnet.ibm.com> <49E6C4C7.3050105@cosmosbay.com> <20090416155201.GF6924@linux.vnet.ibm.com> <49E756EB.7020003@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:58037 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756550AbZDPSCd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 14:02:33 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3GHwBDG008135
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 13:58:11 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3GI2X30196452
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 14:02:33 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3GI2VUe017878
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 14:02:32 -0400
Content-Disposition: inline
In-Reply-To: <49E756EB.7020003@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2009 at 06:03:55PM +0200, Eric Dumazet wrote:
> Paul E. McKenney a =E9crit :
> > On Thu, Apr 16, 2009 at 07:40:23AM +0200, Eric Dumazet wrote:
> >> Paul E. McKenney a =E9crit :
> >>> On Wed, Apr 15, 2009 at 05:38:06PM +0200, Eric Dumazet wrote:
> >>>> inet_register_protosw() is adding inet_protosw to inetsw[] with =
appropriate
> >>>> locking section and rcu variant. No need to call synchronize_net=
() to wait
> >>>> for a RCU grace period. Changes are immediatly visible to other =
cpus anyway.
> >>> I agree with the conclusion (that this change is safe), but not w=
ith
> >>> the reasoning process.  ;-)
> >>>
> >>> The reason that this change is safe is that any inter-process
> >>> communication mechanism used to tell other CPUs that this protoco=
l has
> >>> been registered must contain relevant memory barriers, otherwise,=
 that
> >>> mechanism won't be reliable.
> >> But my patch is not fixing some unreliable algo. It is already rel=
iable,
> >> but pessimistic since containing a superflous call to not-related =
function.
> >>
> >>> If an unreliable mechanism was to be used, the other CPU might no=
t yet see
> >>> the protocol.  For example, if the caller did a simple non-atomic=
 store
> >>> to a variable that the other CPU accessed with a simple non-atomi=
c load,
> >>> then that other CPU could potentially see the inetsw[] without th=
e new
> >>> protocol, given that inet_create() is lockless.  Unlikely, but po=
ssible.
> >> Well, this reasoning process is a litle it wrong too ;)
> >> store or loads of the pointer are always atomic.
> >> You probably meant to say that the store had to be done when memor=
y state
> >> is stable and committed by the processor doing the _register() thi=
ng.
> >=20
> > They are indeed atomic, but not necessarily ordered.  So if you did
> > something like:
> >=20
> > 	if (flag)
> > 		operation_needing_protocol();
> >=20
> > Then it is possible for things to get re-ordered so that the
> > operation_needing_protocol() doesn't see the newly registered proto=
col.
> >=20
> >>> But if a proper inter-process communication mechanism is used to =
inform
> >>> the other CPU, then the first CPU's memory operations will be see=
n.
> >>>
> >>> So I suggest a comment to this effect.
> >> Yes, I should really take special attention to ChangeLogs :)
> >=20
> > ;-)
> >=20
> >> Thanks a lot Patrick
> >>
> >> [PATCH] net: remove superfluous call to synchronize_net()
> >>
> >> inet_register_protosw() function is responsible for adding a new
> >> inet protocol into a global table (inetsw[]) that is used with RCU=
 rules.
> >>
> >> As soon as the store of the pointer is done, other cpus might see
> >> this new protocol in inetsw[], so we have to make sure new protoco=
l
> >> is ready for use. All pending memory updates should thus be commit=
ted
> >> to memory before setting the pointer.
> >> This is correctly done using rcu_assign_pointer()
> >>
> >> synchronize_net() is typically used at unregister time, after
> >> unsetting the pointer, to make sure no other cpu is still using
> >> the object we want to dismantle. Using it at register time
> >> is only adding an artificial delay that could hide a real bug,
> >> and this bug could popup if/when synchronize_rcu() can proceed
> >> faster than now.
> >=20
> > Actually, if you make a change, then do a synchronize_rcu(), then u=
se
> > -any- interprocess communications mechanism, safe or not, that caus=
es
> > an RCU read-side critical section to execute, then that RCU read-si=
de
> > critical section is guaranteed to see the change.
> >=20
> > But if you restrict yourself to safe communication mechanisms that
> > maintain ordering (locking, atomic operations that return values, P=
OSIX
> > primitives, ...), then you don't need the synchronize_rcu().
> >=20
> > Yes, I am being pedantic, but then again, I am the guy who would ha=
ve
> > to straighten out any later confusion.  ;-)
> >=20
>=20
> OK :)
>=20
> I suggest applying patch as is, and consider adding a paragraph in Do=
cumentation
> eventually, if you feel a clarification is needed on the subject ?

Please add a comment where the synchronize_rcu() used to be explaining =
why
it is not needed.  The poor slob who copies your code isn't going to re=
ad
theh Documentation/RCU, he is just going to expect it to magically work=
=2E

With the synchronize_rcu(), it does just magically work.  Without the
synchronize_rcu(), you have to be careful.  Therefore, please add the
comment saying that care is required.

							Thanx, Paul
