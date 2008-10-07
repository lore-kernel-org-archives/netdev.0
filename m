From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 07 Oct 2008 16:50:47 +0200
Message-ID: <48EB7747.9060505@cosmosbay.com>
References: <20081006185026.GA10383@minyard.local>	 <48EA8197.6080502@cosmosbay.com> <1223367480.26330.7.camel@lappy.programming.kicks-ass.net> <48EB2AE3.3080200@cosmosbay.com> <48EB6EE4.8030703@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, minyard@acm.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	paulmck@linux.vnet.ibm.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([80.12.242.50]:49835 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752765AbYJGOu7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 10:50:59 -0400
In-Reply-To: <48EB6EE4.8030703@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> Eric Dumazet wrote:
>>>> Or just add SLAB_DESTROY_BY_RCU to slab creation in proto_register=
()
>>>> for "struct proto udp_prot/udpv6_prot" so that kmem_cache_free() d=
one
>>>> in sk_prot_free() can defer freeing to RCU...
>>> Be careful!, SLAB_DESTROY_BY_RCU just means the slab page gets
>>> RCU-freed, this means that slab object pointers stay pointing to va=
lid
>>> memory, but it does _NOT_ mean those slab objects themselves remain
>>> valid.
>>>
>>> The slab allocator is free to re-use those objects at any time -
>>> irrespective of the rcu-grace period. Therefore you will have to be=
 able
>>> to validate that the object you point to is indeed the object you
>>> expect, otherwise strange and wonderful things will happen.
>>>
>> Thanks for this clarification. I guess we really need a rcu head the=
n :)
>=20
> No you just need to make sure that the object you located is still ac=
tive
> (f.e. refcount > 0) and that it is really a match (hash pointers may =
be
> updated asynchronously and therefore point to the object that has bee=
n reused
> for something else).
>=20
> Generally it is advisable to use SLAB_DESTROY_BY_RCU because it prese=
rves the
> cache hot advantages of the objects. Regular RCU freeing will let the=
 object
> expire for a tick or so which will result in the cacheline cooling do=
wn.

Seems really good to master this SLAB_DESTROY_BY_RCU thing (I see almos=
t no use
of it in current kernel)

1) Hum, do you know why "struct file" objects dont use SLAB_DESTROY_BY_=
RCU then,
since we noticed a performance regression for several workloads at RCUi=
fication
of file structures ?

2) What prevents an object to be *freed* (and deleted from a hash chain=
), then
re-allocated and inserted to another chain (different keys) ? (final re=
fcount=3D1)

If the lookup detects a key mismatch, how will it continue to the next =
item,
since 'next' pointer will have been reused for the new chain insertion.=
=2E.

Me confused...



