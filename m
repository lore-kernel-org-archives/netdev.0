From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: weird problem
Date: Fri, 26 Jun 2009 12:19:04 +0200
Message-ID: <4A44A098.8080006@cosmosbay.com>
References: <4A43DB99.70602@gmail.com> <20090626083719.GA6445@ff.dom.local> <20090626090545.GB6445@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54161 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847AbZFZKTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 06:19:23 -0400
In-Reply-To: <20090626090545.GB6445@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Fri, Jun 26, 2009 at 08:37:19AM +0000, Jarek Poplawski wrote:
>> On 25-06-2009 22:18, Eric Dumazet wrote:
>>> Pawe? Staszewski a ?crit :
>>>> Ok
>>>>
>>>> After this day of observation im near 100% sure that this cpu load=
 is
>>>> made by route cahce flushes
>>>> When route cache increase to its "net.ipv4.route.gc_thresh" size o=
r is
>>>> near that size
>>>> system is starting to drop some routes from cache then cpu load is
>>>> increase from 2% to near 80%
>>>> after cleaning / flush cache when cache is filling cpu load is aga=
in
>>>> normal 2%
>>>>
>>>> Someone know how to resolve this ?
>>>> on kernels < 2.6.29 i don't see this, all start after upgrade from
>>>> 2.6.28 to 2.6.29 - then i try 2.6.29.1 , 2.6.29.3 and 2.6.30 and o=
n all
>>>> this kernels >=3D 2.6.29 problem with cpu load is the same.
>>>>
>>>> I can minimize this cpu fluctuations by changing of route cache /p=
roc
>>>> parameters but the best result for my router was
>>>>
>>>> 15 sec of 2% cpu
>>>> and after
>>>> 15sec of 80% cpu
>>>>
>>>>
>>>> Regards
>>>> Pawel Staszewski
>>>
>>> I believe this is known 2.6.29 regressions
>>>
>>> Following two commits should correct the problem you have
>>>
>>> Your best bet would be to try 2.6.31-rc1, and tell us if this recen=
t kernel
>>> is ok on your machine ?
>>
>> Btw., the first of these commits is in 2.6.30, which according to
>=20
> And the second as well.
>=20

Thanks Jarek.

Pawel made some reports errors in fib thread, so I am not sure he reall=
y
 tried 2.6.30 and had same oprofile results.

rt_worker_func() taking 13% of cpu0 is an alarm for me :)
And 21% of cpu0 and 34% of cpu6 taken by oprofiled seems odd too...

Pawel, could you give us :

grep . /proc/sys/net/ipv4/route/*
cat /proc/interrupts

on your various kernels (previous to 2.6.29, 2.6.29, 2.6.30, ...)

I suspect a change in hash table size, and/or change in interrupt affin=
ities...


Change in hash table size comes from commit c9503e0fe052020e0294cd07d0e=
cd982eb7c9177

But as Pawel mentioned "net.ipv4.route.gc_thresh =3D 190536", I believe
his hash table is smaller than 512k entries!

Author: Anton Blanchard <anton@samba.org>
Date:   Mon Apr 27 05:42:24 2009 -0700

    ipv4: Limit size of route cache hash table

    Right now we have no upper limit on the size of the route cache has=
h table.
    On a 128GB POWER6 box it ends up as 32MB:

        IP route cache hash table entries: 4194304 (order: 9, 33554432 =
bytes)

    It would be nice to cap this for memory consumption reasons, but a =
massive
    hashtable also causes a significant spike when measuring OS jitter.

    With a 32MB hashtable and 4 million entries, rt_worker_func is taki=
ng
    5 ms to complete. On another system with more memory it's taking 14=
 ms.
    Even though rt_worker_func does call cond_sched() to limit its impa=
ct,
    in an HPC environment we want to keep all sources of OS jitter to a=
 minimum.

    With the patch applied we limit the number of entries to 512k which
    can still be overriden by using the rt_entries boot option:

        IP route cache hash table entries: 524288 (order: 6, 4194304 by=
tes)

    With this patch rt_worker_func now takes 0.460 ms on the same syste=
m.

    Signed-off-by: Anton Blanchard <anton@samba.org>
    Acked-by: Eric Dumazet <dada1@cosmosbay.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

