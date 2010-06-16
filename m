From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: Proposed linux kernel changes : scaling  tcp/ip stack
Date: Tue, 15 Jun 2010 20:11:42 -0700
Message-ID: <97746864-ED54-4A12-AFE7-752AA6E41CDD@earthlink.net>
References: <FDFFEFAB-A741-4232-821E-17BFAE5CAFAC@earthlink.net> <1275556440.2456.19.camel@edumazet-laptop>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:38349 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752317Ab0FPDLo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 23:11:44 -0400
In-Reply-To: <1275556440.2456.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 3, 2010, at 2:14 AM, Eric Dumazet wrote:

> Le jeudi 03 juin 2010 =E0 01:16 -0700, Mitchell Erblich a =E9crit :
>> To whom it may concern,
>>=20
>> First, my assumption is to keep this discussion local to just a few =
tcp/ip
>> developers to see if there is any consensus that the below is a logi=
cal=20
>> approach. Please also pass this email if there is a "owner(s)" of th=
is stack
>> to identify if a case exists for the below possible changes.
>>=20
>> I am not currently on the linux kernel mail group.
>> 		=09
>> I have experience with modifications of the Linux tcp/ip stack, and =
have
>> merged the changes into the company's local tree and left the possib=
le=20
>> global integration to others.
>>=20
>> I have been approached by a number of companies about scaling the
>> stack with the assumption of a number of cpu cores. At present, I fi=
nd extra
>> time on my hands and am considering looking into this area on my own=
=2E
>>=20
>> The first assumption is that if extra cores are available, that a si=
ngle
>> received homogeneous flow of a large number of packets/segments per
>> second (pps) can be split into non-equal flows. This split can in ef=
fect
>> allow a larger recv'd pps rate at the same core load while splitting=
 off
>> other workloads, such as xmit'ing pure ACKs.
>>=20
>> Simply, again assuming Amdahl's law (and not looking to equalize the=
 load
>> between cores), and creating logical separations where in a many cor=
e=20
>> system, different cores could have new kernel threads  that operate =
in=20
>> parallel within the tcp/ip stack. The initial separation points woul=
d be at=20
>> the ip/tcp layer boundry and where any recv'd sk/pkt would generate =
some=20
>> form of output.
>>=20
>> The ip/tcp layer would be split like the vintage AT&T STREAMs protoc=
ol,
>> with some form of queuing & scheduling, would be needed. In addition=
,
>> the queuing/schedullng of other kernel threads would occur within ip=
 & tcp
>> to separate the I/O.
>>=20
>> A possible validation test is to identify the max recv'd pps rate wi=
thin the
>> tcp/ip modules within normal flow TCP established state with normal =
order=20
>> of say 64byte non fragmented segments, before and after each=20
>> incremental change. Or the same rate with fewer core/cpu cycles.
>>=20
>> I am willing to have a private git Linux.org tree that concentrates =
proposed
>> changes into this tree and if there is willingness, a seen want/need=
 then identify
>> how to implement the merge.
>=20
> Hi Mitchell
>=20
> We work everyday to improve network stack, and standard linux tree is
> pretty scalable, you dont need to setup a separate git tree for that.
>=20
> Our beloved maintainer David S. Miller handles two trees, net-2.6 and
> net-next-2.6 where we put all our changes.
>=20
> http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
>=20
> I suggest you read the last patches (say .. about 10.000 of them), to
> have an idea of things we did during last years.
>=20
> keywords : RCU, multiqueue, RPS, percpu data, lockless algos, cache l=
ine
> placement...
>=20
> Its nice to see another man joining the team !
>=20
> Thanks
>=20


Lets start with a two part Linux kernel change and a tcp input/output c=
hange:

2 Parts: 2nd part TBD

Summary: Don't use last free pages for TCP ACKs with GFP_ATOMIC for our
sk buf allocs. 1 line change in tcp_output.c with a new gfp.h arg, and =
a change
in the generic kernel. TBD.

This change should have no effect with normal available kernel mem allo=
cs.

Assuming memory pressure ( WAITING for clean memory) we should be alloc=
ating
our last pages for input skbufs and not for xmit allocs.

By delaying skbuf allocations when we have low kmem, we secondarily slo=
w down the
tcp flow : if in slow start (SS) we are almost doing a DELACK, else CA =
should/could
decrease the number of in-flight ACKs and the peer should do burst avoi=
dance
if our later ack increases the window in a larger chunk..

And use the last pages to decrease the chance of dropping a input pkt o=
r
running out of recv descriptors, because of mem back pressure.

The change could check for some form of mem pressure before the alloc,
but the alloc in itself should suffice. We could also do a ECN type che=
ck before
the alloc.

Now the kicker.  I want a GFP_KERNEL with NO_SLEEP OR a GFP_ATOMIC and
NOT use emergency pools, thus CAN FAIL, to have 0 other secondary effec=
ts
and change just the 1 arg.

code : tcp_output.c : tcp_send_ack()
   line : buff =3D alloc_skb(MAX_TCP_HDR, GFP_KERNEL_NSLEEP);   /* with=
 a NO SLEEP */

Suggestions, feedback??

Mitchell Erblich





>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

