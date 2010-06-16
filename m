From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: Proposed linux kernel changes : scaling  tcp/ip stack : 3rd part
Date: Tue, 15 Jun 2010 23:09:49 -0700
Message-ID: <F5330DD9-0486-4831-B2CD-83B3DF111456@earthlink.net>
References: <FDFFEFAB-A741-4232-821E-17BFAE5CAFAC@earthlink.net> <1275556440.2456.19.camel@edumazet-laptop> <97746864-ED54-4A12-AFE7-752AA6E41CDD@earthlink.net> <D70D2636-7C49-48A5-B4DC-B9583A448415@earthlink.net>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Mitchell Erblich <erblichs@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:38708 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753418Ab0FPGJy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jun 2010 02:09:54 -0400
In-Reply-To: <D70D2636-7C49-48A5-B4DC-B9583A448415@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 15, 2010, at 8:30 PM, Mitchell Erblich wrote:

>=20
> On Jun 15, 2010, at 8:11 PM, Mitchell Erblich wrote:
>=20
>>=20
>> On Jun 3, 2010, at 2:14 AM, Eric Dumazet wrote:
>>=20
>>> Le jeudi 03 juin 2010 =E0 01:16 -0700, Mitchell Erblich a =E9crit :
>>>> To whom it may concern,
>>>>=20
>>>> First, my assumption is to keep this discussion local to just a fe=
w tcp/ip
>>>> developers to see if there is any consensus that the below is a lo=
gical=20
>>>> approach. Please also pass this email if there is a "owner(s)" of =
this stack
>>>> to identify if a case exists for the below possible changes.
>>>>=20
>>>> I am not currently on the linux kernel mail group.
>>>> 		=09
>>>> I have experience with modifications of the Linux tcp/ip stack, an=
d have
>>>> merged the changes into the company's local tree and left the poss=
ible=20
>>>> global integration to others.
>>>>=20
>>>> I have been approached by a number of companies about scaling the
>>>> stack with the assumption of a number of cpu cores. At present, I =
find extra
>>>> time on my hands and am considering looking into this area on my o=
wn.
>>>>=20
>>>> The first assumption is that if extra cores are available, that a =
single
>>>> received homogeneous flow of a large number of packets/segments pe=
r
>>>> second (pps) can be split into non-equal flows. This split can in =
effect
>>>> allow a larger recv'd pps rate at the same core load while splitti=
ng off
>>>> other workloads, such as xmit'ing pure ACKs.
>>>>=20
>>>> Simply, again assuming Amdahl's law (and not looking to equalize t=
he load
>>>> between cores), and creating logical separations where in a many c=
ore=20
>>>> system, different cores could have new kernel threads  that operat=
e in=20
>>>> parallel within the tcp/ip stack. The initial separation points wo=
uld be at=20
>>>> the ip/tcp layer boundry and where any recv'd sk/pkt would generat=
e some=20
>>>> form of output.
>>>>=20
>>>> The ip/tcp layer would be split like the vintage AT&T STREAMs prot=
ocol,
>>>> with some form of queuing & scheduling, would be needed. In additi=
on,
>>>> the queuing/schedullng of other kernel threads would occur within =
ip & tcp
>>>> to separate the I/O.
>>>>=20
>>>> A possible validation test is to identify the max recv'd pps rate =
within the
>>>> tcp/ip modules within normal flow TCP established state with norma=
l order=20
>>>> of say 64byte non fragmented segments, before and after each=20
>>>> incremental change. Or the same rate with fewer core/cpu cycles.
>>>>=20
>>>> I am willing to have a private git Linux.org tree that concentrate=
s proposed
>>>> changes into this tree and if there is willingness, a seen want/ne=
ed then identify
>>>> how to implement the merge.
>>>=20
>>> Hi Mitchell
>>>=20
>>> We work everyday to improve network stack, and standard linux tree =
is
>>> pretty scalable, you dont need to setup a separate git tree for tha=
t.
>>>=20
>>> Our beloved maintainer David S. Miller handles two trees, net-2.6 a=
nd
>>> net-next-2.6 where we put all our changes.
>>>=20
>>> http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git
>>> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.gi=
t
>>>=20
>>> I suggest you read the last patches (say .. about 10.000 of them), =
to
>>> have an idea of things we did during last years.
>>>=20
>>> keywords : RCU, multiqueue, RPS, percpu data, lockless algos, cache=
 line
>>> placement...
>>>=20
>>> Its nice to see another man joining the team !
>>>=20
>>> Thanks
>>>=20
>>=20
>>=20
>> Lets start with a two part Linux kernel change and a tcp input/outpu=
t change:
>>=20
>> 2 Parts: 2nd part TBD
>>=20
>> Summary: Don't use last free pages for TCP ACKs with GFP_ATOMIC for =
our
>> sk buf allocs. 1 line change in tcp_output.c with a new gfp.h arg, a=
nd a change
>> in the generic kernel. TBD.
>>=20
>> This change should have no effect with normal available kernel mem a=
llocs.
>>=20
>> Assuming memory pressure ( WAITING for clean memory) we should be al=
locating
>> our last pages for input skbufs and not for xmit allocs.
>>=20
>> By delaying skbuf allocations when we have low kmem, we secondarily =
slow down the
>> tcp flow : if in slow start (SS) we are almost doing a DELACK, else =
CA should/could
>> decrease the number of in-flight ACKs and the peer should do burst a=
voidance
>> if our later ack increases the window in a larger chunk..
>>=20
>> And use the last pages to decrease the chance of dropping a input pk=
t or
>> running out of recv descriptors, because of mem back pressure.
>>=20
>> The change could check for some form of mem pressure before the allo=
c,
>> but the alloc in itself should suffice. We could also do a ECN type =
check before
>> the alloc.
>>=20
>> Now the kicker.  I want a GFP_KERNEL with NO_SLEEP OR a GFP_ATOMIC a=
nd
>> NOT use emergency pools, thus CAN FAIL, to have 0 other secondary ef=
fects
>> and change just the 1 arg.
>>=20
>> code : tcp_output.c : tcp_send_ack()
>>  line : buff =3D alloc_skb(MAX_TCP_HDR, GFP_KERNEL_NSLEEP);   /* wit=
h a NO SLEEP */
>>=20
>> Suggestions, feedback??
>>=20
>> Mitchell Erblich
>>=20
>>=20
>>=20
>>=20
>=20
> Sorry :),
>=20
> 		2nd part:
>=20
> 		use GFP_NOWAIT as 2nd arg to alloc_skb()
>=20
> Mitchell Erblich

Going in the same direction,


If tcp_out_of_resources() and the number of orphaned sockets is above
a configured number (maybe because of DoS attack), SHOULD we consume
our last available resources and most likely effect skbufs that we aren=
't
reset-ing because NOW the recv sk allocs are failing.

thus,
file tcp_timer.c : tcp_out_of_resources()
suggestion change 2nd arg GFP_ATOMIC: tcp_send_active_reset(sk, GFP_NOW=
AIT);

Please note that even if we believed that the GFP_ATOMIC would have a h=
igher=20
probability to send a TCP pkt/seg, that gives us no guarantee that the =
peer
will recv it or will process it.

We COULD also do some form of ECN in this function to inform the peer t=
hat our=20
system is in distress if tcp_send_active_reset() did not return void an=
d informed=20
us of a mem alloc failure with the GFP_NOWAIT.

Since the ECN would benefit the our node/system, this ECN sending event=
 COULD
be argued to have a higher priority and mem argument then sent with a G=
=46P_ATOMIC.


Suggestions, opinions...

Mitchell Erblich

>>=20
>>>=20
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

