From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Thu, 28 Aug 2008 08:20:51 +0200
Message-ID: <48B643C3.9040502@cosmosbay.com>
References: <87zlmyr5nz.fsf@basil.nowhere.org>	<20080827.142941.50104491.davem@davemloft.net>	<20080827144800.5f9fc5b4@extreme> <20080827.150955.118944272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, andi@firstfloor.org, davej@redhat.com,
	netdev@vger.kernel.org, j.w.r.degoede@hhs.nl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp21.orange.fr ([80.12.242.49]:41242 "EHLO smtp21.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751432AbYH1GVF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 02:21:05 -0400
In-Reply-To: <20080827.150955.118944272.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 27 Aug 2008 14:48:00 -0700
>=20
>> I do wonder if having large hash table actually helps? When TCP hash
>> table gets too big, it means every lookup is a cache miss. Assuming
>> a busy server with 2000 connections and perfect hash. On a 4G mem x8=
6-64
>> we are doing 512K hash entries which is ridiculous. Something like 6=
4K
>> entries is more than enough.
>=20
> That's true, but it's nearly guaranteed to only be a single cache mis=
s
> at worst (if the hash function is working) compared to potentially
> multiple ones if we sized it too small.
>=20
> I really see the only way to move forward is to dynamically size the
> thing.  And nobody has been strong enough to implement that yet :)
>=20

You are right. For TCP hash table thats probably hard to implement.

But for route cache, it is probably doable since we added the rt_genid
thing in commit 29e75252da20f3ab9e132c68c9aed156b87beae6=20
([IPV4] route cache: Introduce rt_genid for smooth cache invalidation)

If we add a hash table for each "struct net" (net->ipv4.rt_hash_table),
we then could do something sensible when an admin writes to=20
/proc/sys/net/ipv4/route/hash_size or at rt_check_expire() time, if
hash table is found to be full...

1) Instead of using alloc_large_system_hash() at boot time to allocate
   rt_hash_table, use a plain vmalloc()
Initial hash size could be small (one page) unless "rhash_entries=3Dxxx=
" boot parameter says otherwise.

2) If an admin writes a new value to /proc/sys/net/ipv4/route/hash_size=
 :
- Allocate a new table with vmalloc()
- Change the net->ipv4.rt_genid and net->ipv4.rt_hash_table
- Old table contains obsolete entries, rt_free() them all.
- vfree() old hash table, now empty.


3) In rt_check_expire(), adds some metrics to trigger an expand of the
  hash table in case we found too many entries in it.




