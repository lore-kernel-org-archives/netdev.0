From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: remove superfluous call to synchronize_net()
Date: Thu, 16 Apr 2009 18:03:55 +0200
Message-ID: <49E756EB.7020003@cosmosbay.com>
References: <49E5FF5E.50409@cosmosbay.com> <20090415215454.GU6766@linux.vnet.ibm.com> <49E6C4C7.3050105@cosmosbay.com> <20090416155201.GF6924@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42359 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753495AbZDPQEF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 12:04:05 -0400
In-Reply-To: <20090416155201.GF6924@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney a =E9crit :
> On Thu, Apr 16, 2009 at 07:40:23AM +0200, Eric Dumazet wrote:
>> Paul E. McKenney a =E9crit :
>>> On Wed, Apr 15, 2009 at 05:38:06PM +0200, Eric Dumazet wrote:
>>>> inet_register_protosw() is adding inet_protosw to inetsw[] with ap=
propriate
>>>> locking section and rcu variant. No need to call synchronize_net()=
 to wait
>>>> for a RCU grace period. Changes are immediatly visible to other cp=
us anyway.
>>> I agree with the conclusion (that this change is safe), but not wit=
h
>>> the reasoning process.  ;-)
>>>
>>> The reason that this change is safe is that any inter-process
>>> communication mechanism used to tell other CPUs that this protocol =
has
>>> been registered must contain relevant memory barriers, otherwise, t=
hat
>>> mechanism won't be reliable.
>> But my patch is not fixing some unreliable algo. It is already relia=
ble,
>> but pessimistic since containing a superflous call to not-related fu=
nction.
>>
>>> If an unreliable mechanism was to be used, the other CPU might not =
yet see
>>> the protocol.  For example, if the caller did a simple non-atomic s=
tore
>>> to a variable that the other CPU accessed with a simple non-atomic =
load,
>>> then that other CPU could potentially see the inetsw[] without the =
new
>>> protocol, given that inet_create() is lockless.  Unlikely, but poss=
ible.
>> Well, this reasoning process is a litle it wrong too ;)
>> store or loads of the pointer are always atomic.
>> You probably meant to say that the store had to be done when memory =
state
>> is stable and committed by the processor doing the _register() thing=
=2E
>=20
> They are indeed atomic, but not necessarily ordered.  So if you did
> something like:
>=20
> 	if (flag)
> 		operation_needing_protocol();
>=20
> Then it is possible for things to get re-ordered so that the
> operation_needing_protocol() doesn't see the newly registered protoco=
l.
>=20
>>> But if a proper inter-process communication mechanism is used to in=
form
>>> the other CPU, then the first CPU's memory operations will be seen.
>>>
>>> So I suggest a comment to this effect.
>> Yes, I should really take special attention to ChangeLogs :)
>=20
> ;-)
>=20
>> Thanks a lot Patrick
>>
>> [PATCH] net: remove superfluous call to synchronize_net()
>>
>> inet_register_protosw() function is responsible for adding a new
>> inet protocol into a global table (inetsw[]) that is used with RCU r=
ules.
>>
>> As soon as the store of the pointer is done, other cpus might see
>> this new protocol in inetsw[], so we have to make sure new protocol
>> is ready for use. All pending memory updates should thus be committe=
d
>> to memory before setting the pointer.
>> This is correctly done using rcu_assign_pointer()
>>
>> synchronize_net() is typically used at unregister time, after
>> unsetting the pointer, to make sure no other cpu is still using
>> the object we want to dismantle. Using it at register time
>> is only adding an artificial delay that could hide a real bug,
>> and this bug could popup if/when synchronize_rcu() can proceed
>> faster than now.
>=20
> Actually, if you make a change, then do a synchronize_rcu(), then use
> -any- interprocess communications mechanism, safe or not, that causes
> an RCU read-side critical section to execute, then that RCU read-side
> critical section is guaranteed to see the change.
>=20
> But if you restrict yourself to safe communication mechanisms that
> maintain ordering (locking, atomic operations that return values, POS=
IX
> primitives, ...), then you don't need the synchronize_rcu().
>=20
> Yes, I am being pedantic, but then again, I am the guy who would have
> to straighten out any later confusion.  ;-)
>=20

OK :)

I suggest applying patch as is, and consider adding a paragraph in Docu=
mentation
eventually, if you feel a clarification is needed on the subject ?

Thank you

