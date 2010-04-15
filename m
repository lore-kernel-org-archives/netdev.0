From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Network multiqueue question
Date: Thu, 15 Apr 2010 11:09:46 -0700
Message-ID: <21433.1271354986@death.nxdomain.ibm.com>
References: <i2tb65cae941004150958n5c66dc42j26724bbb075125a0@mail.gmail.com> <1271353637.16881.2846.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "George B." <georgeb@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:47395 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952Ab0DOSKF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 14:10:05 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3FI0e9J011926
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 14:00:40 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3FIA33f125384
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 14:10:03 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3FB9rUk000758
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 05:09:53 -0600
In-reply-to: <1271353637.16881.2846.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:

>Le jeudi 15 avril 2010 =C3=A0 09:58 -0700, George B. a =C3=A9crit :
>> I am in need of a little education on multiqueue and was wondering i=
f
>> someone here might be able to help me.
>>=20
>> Given intel igb network driver, it appears I can do something like:
>>=20
>>  tc qdisc del dev eth0 root handle 1: multiq
>>=20
>> which works and reports 4 bands:  dev eth0 root refcnt 4 bands 4/4
>>=20
>> But our network is a little more complicated.  Above the ethernet we
>> have the bonding driver which is using mode 2 bonding with two
>> ethernet slaves.  Then we have vlans on the bond interface.  Our
>> production traffic is on a vlan and resource contention is an issue =
as
>> these are busy machines.
>>=20
>> It is my understanding that the vlan driver became multiqueue aware =
in
>> 2.6.32 (we are currently using 2.6.31).
>>=20
>> It would seem that the first thing the kernel would encounter with
>> traffic headed out would be the vlan interface, and then the bond
>> interface, and then the physical ethernet interface.  Is that correc=
t?
>>  So with my kernel, I would seem to get no utility from multiq on th=
e
>> ethernet interface if the vlan interface is going to be a
>> single-threaded bottleneck.  What about the bond driver?  Is it
>> currently multiqueue aware?
>>=20
>> I am try to get some sort of logical picture of how all these things
>> interact with each other to get things a little more efficient and
>> reduce resource contention in the application while still trying to =
be
>> efficient in use of network ports/interfaces.
>>=20
>> If someone feels up to the task of sending a little education my way=
,
>> I would be most appreciative.  There doesn't seem to be a whole lot =
of
>> documentation floating around about multiqueue other than a blurb of
>> text in the kernel and David's presentation of last year.
>
>Hi George
>
>Vlan is multiqueue aware, but bonding is not unfortunatly at this
>moment.
>
>We could let it being 'multiqueue' (a patch was submitted by Oleg A.
>Arkhangelsky a while ago), but bonding xmit routine needs to lock a
>central lock, shared by all queues, so it wont be very efficient...

	The lock is a read lock, so theoretically it should be possible
to enter the bonding transmit function on multiple CPUs at the same
time.  The lock may thrash around, though.

>Since this bothers me a bit, I will probably work on this in a near
>future. (adding real multiqueue capability and RCU to bonding fast
>paths)
>
>Ref: http://permalink.gmane.org/gmane.linux.network/152987

	The question I have about it (and the above patch), is: what
does multi-queue "awareness" really mean for a bonding device?  How doe=
s
allocating a bunch of TX queues help, given that the determination of
the transmitting device hasn't necessarily been made?

	I haven't had the chance to acquire some multi-queue network
cards and check things out with bonding, so I'm not really sure how it
should work.  Should the bond look, from a multi-queue perspective, lik=
e
the largest slave, or should it look like the sum of the slaves?  Some
of this is may be mode-specific, as well.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
