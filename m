From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: remove superfluous call to synchronize_net()
Date: Thu, 16 Apr 2009 08:52:01 -0700
Message-ID: <20090416155201.GF6924@linux.vnet.ibm.com>
References: <49E5FF5E.50409@cosmosbay.com> <20090415215454.GU6766@linux.vnet.ibm.com> <49E6C4C7.3050105@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:37948 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755659AbZDPPwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 11:52:03 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3GFlekk003113
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 11:47:40 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3GFq20C180376
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 11:52:02 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3GFq1pW016042
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 11:52:01 -0400
Content-Disposition: inline
In-Reply-To: <49E6C4C7.3050105@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2009 at 07:40:23AM +0200, Eric Dumazet wrote:
> Paul E. McKenney a =E9crit :
> > On Wed, Apr 15, 2009 at 05:38:06PM +0200, Eric Dumazet wrote:
> >> inet_register_protosw() is adding inet_protosw to inetsw[] with ap=
propriate
> >> locking section and rcu variant. No need to call synchronize_net()=
 to wait
> >> for a RCU grace period. Changes are immediatly visible to other cp=
us anyway.
> >=20
> > I agree with the conclusion (that this change is safe), but not wit=
h
> > the reasoning process.  ;-)
> >=20
> > The reason that this change is safe is that any inter-process
> > communication mechanism used to tell other CPUs that this protocol =
has
> > been registered must contain relevant memory barriers, otherwise, t=
hat
> > mechanism won't be reliable.
>=20
> But my patch is not fixing some unreliable algo. It is already reliab=
le,
> but pessimistic since containing a superflous call to not-related fun=
ction.
>=20
> > If an unreliable mechanism was to be used, the other CPU might not =
yet see
> > the protocol.  For example, if the caller did a simple non-atomic s=
tore
> > to a variable that the other CPU accessed with a simple non-atomic =
load,
> > then that other CPU could potentially see the inetsw[] without the =
new
> > protocol, given that inet_create() is lockless.  Unlikely, but poss=
ible.
>=20
> Well, this reasoning process is a litle it wrong too ;)
> store or loads of the pointer are always atomic.
> You probably meant to say that the store had to be done when memory s=
tate
> is stable and committed by the processor doing the _register() thing.

They are indeed atomic, but not necessarily ordered.  So if you did
something like:

	if (flag)
		operation_needing_protocol();

Then it is possible for things to get re-ordered so that the
operation_needing_protocol() doesn't see the newly registered protocol.

> > But if a proper inter-process communication mechanism is used to in=
form
> > the other CPU, then the first CPU's memory operations will be seen.
> >=20
> > So I suggest a comment to this effect.
>=20
> Yes, I should really take special attention to ChangeLogs :)

;-)

> Thanks a lot Patrick
>=20
> [PATCH] net: remove superfluous call to synchronize_net()
>=20
> inet_register_protosw() function is responsible for adding a new
> inet protocol into a global table (inetsw[]) that is used with RCU ru=
les.
>=20
> As soon as the store of the pointer is done, other cpus might see
> this new protocol in inetsw[], so we have to make sure new protocol
> is ready for use. All pending memory updates should thus be committed
> to memory before setting the pointer.
> This is correctly done using rcu_assign_pointer()
>=20
> synchronize_net() is typically used at unregister time, after
> unsetting the pointer, to make sure no other cpu is still using
> the object we want to dismantle. Using it at register time
> is only adding an artificial delay that could hide a real bug,
> and this bug could popup if/when synchronize_rcu() can proceed
> faster than now.

Actually, if you make a change, then do a synchronize_rcu(), then use
-any- interprocess communications mechanism, safe or not, that causes
an RCU read-side critical section to execute, then that RCU read-side
critical section is guaranteed to see the change.

But if you restrict yourself to safe communication mechanisms that
maintain ordering (locking, atomic operations that return values, POSIX
primitives, ...), then you don't need the synchronize_rcu().

Yes, I am being pedantic, but then again, I am the guy who would have
to straighten out any later confusion.  ;-)

						Thanx, Paul

> This saves about 13 ms on boot time on a HZ=3D1000 8 cpus machine  ;)=
=20
> (4 calls to inet_register_protosw(), and about 3200 us per call)
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 7f03373..1706896 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1003,8 +1003,6 @@ void inet_register_protosw(struct inet_protosw =
*p)
>  out:
>  	spin_unlock_bh(&inetsw_lock);
> =20
> -	synchronize_net();
> -
>  	return;
> =20
>  out_permanent:
>=20
