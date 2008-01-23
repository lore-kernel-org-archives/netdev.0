From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] [IPV4] route: fix locking in rt_run_flush()
Date: Wed, 23 Jan 2008 21:44:25 +0100
Message-ID: <4797A729.4030006@cosmosbay.com>
References: <12009281372201-git-send-email-joonwpark81@gmail.com> <20080121.024043.105024413.davem@davemloft.net> <20080123074320.GB9017@ehus.geninetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: joonwpark81@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604007av.neufgp.fr ([84.96.92.120]:46618
	"EHLO neuf-infra-smtp-out-sp604007av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751045AbYAWUoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 15:44:44 -0500
In-Reply-To: <20080123074320.GB9017@ehus.geninetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

joonwpark81@gmail.com a =E9crit :
> On Mon, Jan 21, 2008 at 02:40:43AM -0800, David Miller wrote:
>> From: Joonwoo Park <joonwpark81@gmail.com>
>> Date: Tue, 22 Jan 2008 00:08:57 +0900
>>
>>> The rt_run_flush() can be stucked if it was called while netdev is =
on the=20
>>> high load.
>>> It's possible when pushing rtable to rt_hash is faster than pulling
>>> from it.
>>>
>>> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
>> I agree with the analysis of the problem, however not the solution.
>>
>> This will absolutely kill software interrupt latency.
>>
>> In fact, we have moved much of the flush work into a workqueue in
>> net-2.6.25 because of how important that is
>>
>> We need to find some other way to solve this.
>>
>=20
> Dave, Eric,
> Thanks so much for comments.
>=20
> I did stress tests and I found that the real problem was not consumer=
 & supplier
> issue.
> It was the problem for me to innumerable enabling & disabling the sof=
tirq.
> But I'm still thinking need of considering issue 'faster caching than=
 flush'. :)=20
>=20
> ifconfig up on heavy loaded interface.
> Before patching:
>  time ifconfig eth1 up
>  BUG: soft lockup - CPU#0 stuck for 11s! [events/0:9]
>  ...
>=20
> After patching:
>  time ifconfig eth1 up
> real	0m0.007s
> user	0m0.000s
> sys	0m0.004s
>=20
> Thanks!
> Joonwoo
>=20
>=20
>>From 87c29506de967e811ad5b57cd2e1a002134e878f Mon Sep 17 00:00:00 200=
1
> From: Joonwoo Park <joonwpark81@gmail.com>
> Date: Wed, 23 Jan 2008 15:16:54 +0900
> Subject: [PATCH] [IPV4] route: reduce locking/unlocking in rt_run_flu=
sh
>=20
> The rt_run_flush does spin_lock_bh/spin_unlock_bh for rt_hash_mask + =
1
> times.
> The rt_hash_mask takes from 32767 to 65535, so it's big overhead.
> In addition, disable_bh/enable_bh for many times in the rt_run_flush
> can cause stuck on a machine with heavily pended softirqs.
>=20
> This patch reduces locking/unlocking as doing it with jumping the loc=
k
> slots.
>=20
> ifconfig up on heavy loaded interface.
> Before:
>  time ifconfig eth1 up
>  BUG: soft lockup - CPU#0 stuck for 11s! [events/0:9]
>  ...
>=20
> After:
>  time ifconfig eth1 up
> real	0m0.007s
> user	0m0.000s
> sys	0m0.004s
>=20

Unfortunatly, your patch doesnt work on CONFIG_SMP=3Dn (softirq will be=
 disabled=20
for the whole scan of table)

Also, some machines around there have 2^22 slots in hash table, and NR_=
CPUS=3D4,=20
so softirqs will be disabled for a too long time.

Please try net-2.6.25 and submit patches on top of it if necessary, sin=
ce=20
rt_run_flush() has pending changes, not in net-2.6

Note : The 'soft lockup' can be avoided by other means.

