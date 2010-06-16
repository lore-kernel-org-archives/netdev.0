From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: Proposed linux kernel changes : scaling  tcp/ip stack : 3rd part
Date: Wed, 16 Jun 2010 00:46:07 -0700
Message-ID: <01357CF3-35A2-45AC-9950-E4EBE955F225@earthlink.net>
References: <FDFFEFAB-A741-4232-821E-17BFAE5CAFAC@earthlink.net> <1275556440.2456.19.camel@edumazet-laptop> <97746864-ED54-4A12-AFE7-752AA6E41CDD@earthlink.net> <D70D2636-7C49-48A5-B4DC-B9583A448415@earthlink.net> <F5330DD9-0486-4831-B2CD-83B3DF111456@earthlink.net> <1276670223.19249.77.camel@edumazet-laptop>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:44802 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753739Ab0FPHqK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jun 2010 03:46:10 -0400
In-Reply-To: <1276670223.19249.77.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 15, 2010, at 11:37 PM, Eric Dumazet wrote:

> Le mardi 15 juin 2010 =E0 23:09 -0700, Mitchell Erblich a =E9crit :
>> On Jun 15, 2010, at 8:30 PM, Mitchell Erblich wrote:
>>=20
>>>=20
>>> On Jun 15, 2010, at 8:11 PM, Mitchell Erblich wrote:
>>>=20
>>>>=20
>>>> On Jun 3, 2010, at 2:14 AM, Eric Dumazet wrote:
>>>>=20
>>>>> Le jeudi 03 juin 2010 =E0 01:16 -0700, Mitchell Erblich a =E9crit=
 :
>>>>>> To whom it may concern,
>>>>>>=20
>>>>>> First, my assumption is to keep this discussion local to just a =
few tcp/ip
>>>>>> developers to see if there is any consensus that the below is a =
logical=20
>>>>>> approach. Please also pass this email if there is a "owner(s)" o=
f this stack
>>>>>> to identify if a case exists for the below possible changes.
>>>>>>=20
>>>>>> I am not currently on the linux kernel mail group.
>>>>>> 		=09
>>>>>> I have experience with modifications of the Linux tcp/ip stack, =
and have
>>>>>> merged the changes into the company's local tree and left the po=
ssible=20
>>>>>> global integration to others.
>>>>>>=20
>>>>>> I have been approached by a number of companies about scaling th=
e
>>>>>> stack with the assumption of a number of cpu cores. At present, =
I find extra
>>>>>> time on my hands and am considering looking into this area on my=
 own.
>>>>>>=20
>>>>>> The first assumption is that if extra cores are available, that =
a single
>>>>>> received homogeneous flow of a large number of packets/segments =
per
>>>>>> second (pps) can be split into non-equal flows. This split can i=
n effect
>>>>>> allow a larger recv'd pps rate at the same core load while split=
ting off
>>>>>> other workloads, such as xmit'ing pure ACKs.
>>>>>>=20
>>>>>> Simply, again assuming Amdahl's law (and not looking to equalize=
 the load
>>>>>> between cores), and creating logical separations where in a many=
 core=20
>>>>>> system, different cores could have new kernel threads  that oper=
ate in=20
>>>>>> parallel within the tcp/ip stack. The initial separation points =
would be at=20
>>>>>> the ip/tcp layer boundry and where any recv'd sk/pkt would gener=
ate some=20
>>>>>> form of output.
>>>>>>=20
>>>>>> The ip/tcp layer would be split like the vintage AT&T STREAMs pr=
otocol,
>>>>>> with some form of queuing & scheduling, would be needed. In addi=
tion,
>>>>>> the queuing/schedullng of other kernel threads would occur withi=
n ip & tcp
>>>>>> to separate the I/O.
>>>>>>=20
>>>>>> A possible validation test is to identify the max recv'd pps rat=
e within the
>>>>>> tcp/ip modules within normal flow TCP established state with nor=
mal order=20
>>>>>> of say 64byte non fragmented segments, before and after each=20
>>>>>> incremental change. Or the same rate with fewer core/cpu cycles.
>>>>>>=20
>>>>>> I am willing to have a private git Linux.org tree that concentra=
tes proposed
>>>>>> changes into this tree and if there is willingness, a seen want/=
need then identify
>>>>>> how to implement the merge.
>>>>>=20
>>>>> Hi Mitchell
>>>>>=20
>>>>> We work everyday to improve network stack, and standard linux tre=
e is
>>>>> pretty scalable, you dont need to setup a separate git tree for t=
hat.
>>>>>=20
>>>>> Our beloved maintainer David S. Miller handles two trees, net-2.6=
 and
>>>>> net-next-2.6 where we put all our changes.
>>>>>=20
>>>>> http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.gi=
t
>>>>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.=
git
>>>>>=20
>>>>> I suggest you read the last patches (say .. about 10.000 of them)=
, to
>>>>> have an idea of things we did during last years.
>>>>>=20
>>>>> keywords : RCU, multiqueue, RPS, percpu data, lockless algos, cac=
he line
>>>>> placement...
>>>>>=20
>>>>> Its nice to see another man joining the team !
>>>>>=20
>>>>> Thanks
>>>>>=20
>>>>=20
>>>>=20
>>>> Lets start with a two part Linux kernel change and a tcp input/out=
put change:
>>>>=20
>>>> 2 Parts: 2nd part TBD
>>>>=20
>>>> Summary: Don't use last free pages for TCP ACKs with GFP_ATOMIC fo=
r our
>>>> sk buf allocs. 1 line change in tcp_output.c with a new gfp.h arg,=
 and a change
>>>> in the generic kernel. TBD.
>>>>=20
>>>> This change should have no effect with normal available kernel mem=
 allocs.
>>>>=20
>>>> Assuming memory pressure ( WAITING for clean memory) we should be =
allocating
>>>> our last pages for input skbufs and not for xmit allocs.
>>>>=20
>>>> By delaying skbuf allocations when we have low kmem, we secondaril=
y slow down the
>>>> tcp flow : if in slow start (SS) we are almost doing a DELACK, els=
e CA should/could
>>>> decrease the number of in-flight ACKs and the peer should do burst=
 avoidance
>>>> if our later ack increases the window in a larger chunk..
>>>>=20
>>>> And use the last pages to decrease the chance of dropping a input =
pkt or
>>>> running out of recv descriptors, because of mem back pressure.
>>>>=20
>>>> The change could check for some form of mem pressure before the al=
loc,
>>>> but the alloc in itself should suffice. We could also do a ECN typ=
e check before
>>>> the alloc.
>>>>=20
>>>> Now the kicker.  I want a GFP_KERNEL with NO_SLEEP OR a GFP_ATOMIC=
 and
>>>> NOT use emergency pools, thus CAN FAIL, to have 0 other secondary =
effects
>>>> and change just the 1 arg.
>>>>=20
>>>> code : tcp_output.c : tcp_send_ack()
>>>> line : buff =3D alloc_skb(MAX_TCP_HDR, GFP_KERNEL_NSLEEP);   /* wi=
th a NO SLEEP */
>>>>=20
>>>> Suggestions, feedback??
>>>>=20
>>>> Mitchell Erblich
>>>>=20
>>>>=20
>>>>=20
>>>>=20
>>>=20
>>> Sorry :),
>>>=20
>>> 		2nd part:
>>>=20
>>> 		use GFP_NOWAIT as 2nd arg to alloc_skb()
>>>=20
>>> Mitchell Erblich
>>=20
>> Going in the same direction,
>>=20
>>=20
>> If tcp_out_of_resources() and the number of orphaned sockets is abov=
e
>> a configured number (maybe because of DoS attack), SHOULD we consume
>> our last available resources and most likely effect skbufs that we a=
ren't
>> reset-ing because NOW the recv sk allocs are failing.
>>=20
>> thus,
>> file tcp_timer.c : tcp_out_of_resources()
>> suggestion change 2nd arg GFP_ATOMIC: tcp_send_active_reset(sk, GFP_=
NOWAIT);
>>=20
>> Please note that even if we believed that the GFP_ATOMIC would have =
a higher=20
>> probability to send a TCP pkt/seg, that gives us no guarantee that t=
he peer
>> will recv it or will process it.
>>=20
>> We COULD also do some form of ECN in this function to inform the pee=
r that our=20
>> system is in distress if tcp_send_active_reset() did not return void=
 and informed=20
>> us of a mem alloc failure with the GFP_NOWAIT.
>>=20
>> Since the ECN would benefit the our node/system, this ECN sending ev=
ent COULD
>> be argued to have a higher priority and mem argument then sent with =
a GFP_ATOMIC.
>>=20
>>=20
>> Suggestions, opinions...
>=20
>=20
> 1) Acks are about the smallest chunks that are ever allocated in netw=
ork
> stack.
>=20
> 2) Their lifetime is close to 0 us. They are not cloned (queued on a
> socket queue), only given to device xmit. Unless you play with trafic
> shaping and insane queue lengths, acks should not use more than 0.000=
1 %
> of your ram.
>=20
> 3) Under attack, adding complex algos to try to resist only delay a b=
it
> the moment where nothing can be done to stop the attack. Being clever=
 or
> not. Dropping packets is very fine.
>=20
> 4) Maybe all the work you think about is the balance between ATOMIC a=
nd
> non ATOMIC (GFP_KERNEL) memory allocations ? Some tuning maybe ?
>   input path always use ATOMIC ops, being run from sofirq, and cannot
> wait.
>=20

I am not suggesting a pure GFP_KERNEL /sleep allocs on either side.
I suggested it with a NO-SLEEP and then looked and saw GFP_NOWAIT.

However, when under mem pressure, it might make sense to delay/slow
the opening of the snd and recv TCP windows, to allow mem pages
to be cleaned and re-used to relieve the mem pressure.

If queues are already existing, then they are the first delay-points
to be reviewed / used, however only under abnormal circumstances.

Maybe even short-lived flows have expired and those resources can now
be used.

>=20
> --

Eric & group,

I am starting simple with a different look at what COULD/SHOULD IT be d=
one?

The question that I am asking is if GFP_NOWAIT WOULD fail  AND GFP_ATOM=
IC
would succeed, then only the last percentage of kernel memory allocatio=
ns are
being done. Do you want to use this last few percentage of memory with =
ACKs/xmits?

Maybe if we failed a few non-necessary / delayable items, then enough t=
ime
may occur to clean pages, and not execute any OOM like code.

The effect of generating a short DELACK SHOULD reduce memory pressure f=
rom=20
the peer in 1 RTT. Also, failing and executing the non-buff code, MAY A=
LSO slow-down
the ramp-up based on the TCP ACK clock.

The number of ACTIVE (recv at the NIC to xmit at the NIC) tcp flows may=
 account
for a non-neglible number of later allocs and decrease mem pressure.

If I understand the diff between GFP_NOWAIT and GFP_ATOMIC, both
don't sleep, and only GFP_NOWAIT doesn't grab for the last available pa=
ges. So,
they are both atomic/no-sleeps.=20

To conclude with part 4: tcp_timer.c has 2 additional calls to tcp_send=
_active_reset()
use GFP_NOWAIT instead of GFP_ATOMIC.

Now, with your statement about "input path always uses atomic". SHOULD =
IT?
SAY under a DoS attack? Why not reject some if no-memory via GFP_NOWAIT=
=2E
If a new flow is to be started and we are under memory pressure, should=
 it not ALSO
use GFP_NOWAIT?  If we ALSO do GFP_NOWAIT on ESTABLISHED flows and (sho=
ot me)
drop a seg/pkt, that should drop them to 1/2 bandwidth. This is in effe=
ct TCP fair-ness.
Thus, delays in ACKs are much more preferred.

Again, we will only minimally effect flows with the NEW suggested chang=
es if their is=20
mem pressure and going to do more aggressive things like reset sockets/=
flows.

Since, my suggested changes are NOT in the form of a patch, then someon=
e ELSE=20
needs to agree with me and then the maintainer must see that it does no=
 harm and=20
the changes slowly moves the code in the right direction.

Mitchell Erblich

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D


=09
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

