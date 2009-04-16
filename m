From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: remove superfluous call to synchronize_net()
Date: Thu, 16 Apr 2009 07:40:23 +0200
Message-ID: <49E6C4C7.3050105@cosmosbay.com>
References: <49E5FF5E.50409@cosmosbay.com> <20090415215454.GU6766@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45271 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbZDPFkf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 01:40:35 -0400
In-Reply-To: <20090415215454.GU6766@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney a =E9crit :
> On Wed, Apr 15, 2009 at 05:38:06PM +0200, Eric Dumazet wrote:
>> inet_register_protosw() is adding inet_protosw to inetsw[] with appr=
opriate
>> locking section and rcu variant. No need to call synchronize_net() t=
o wait
>> for a RCU grace period. Changes are immediatly visible to other cpus=
 anyway.
>=20
> I agree with the conclusion (that this change is safe), but not with
> the reasoning process.  ;-)
>=20
> The reason that this change is safe is that any inter-process
> communication mechanism used to tell other CPUs that this protocol ha=
s
> been registered must contain relevant memory barriers, otherwise, tha=
t
> mechanism won't be reliable.

But my patch is not fixing some unreliable algo. It is already reliable=
,
but pessimistic since containing a superflous call to not-related funct=
ion.

>=20
> If an unreliable mechanism was to be used, the other CPU might not ye=
t see
> the protocol.  For example, if the caller did a simple non-atomic sto=
re
> to a variable that the other CPU accessed with a simple non-atomic lo=
ad,
> then that other CPU could potentially see the inetsw[] without the ne=
w
> protocol, given that inet_create() is lockless.  Unlikely, but possib=
le.

Well, this reasoning process is a litle it wrong too ;)
store or loads of the pointer are always atomic.
You probably meant to say that the store had to be done when memory sta=
te
is stable and committed by the processor doing the _register() thing.

>=20
> But if a proper inter-process communication mechanism is used to info=
rm
> the other CPU, then the first CPU's memory operations will be seen.
>=20
> So I suggest a comment to this effect.

Yes, I should really take special attention to ChangeLogs :)

Thanks a lot Patrick

[PATCH] net: remove superfluous call to synchronize_net()

inet_register_protosw() function is responsible for adding a new
inet protocol into a global table (inetsw[]) that is used with RCU rule=
s.

As soon as the store of the pointer is done, other cpus might see
this new protocol in inetsw[], so we have to make sure new protocol
is ready for use. All pending memory updates should thus be committed
to memory before setting the pointer.
This is correctly done using rcu_assign_pointer()

synchronize_net() is typically used at unregister time, after
unsetting the pointer, to make sure no other cpu is still using
the object we want to dismantle. Using it at register time
is only adding an artificial delay that could hide a real bug,
and this bug could popup if/when synchronize_rcu() can proceed
faster than now.

This saves about 13 ms on boot time on a HZ=3D1000 8 cpus machine  ;)=20
(4 calls to inet_register_protosw(), and about 3200 us per call)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7f03373..1706896 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1003,8 +1003,6 @@ void inet_register_protosw(struct inet_protosw *p=
)
 out:
 	spin_unlock_bh(&inetsw_lock);
=20
-	synchronize_net();
-
 	return;
=20
 out_permanent:

