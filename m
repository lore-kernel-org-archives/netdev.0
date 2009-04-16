From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Thu, 16 Apr 2009 08:26:58 +0200
Message-ID: <49E6CFB2.2020905@cosmosbay.com>
References: <49E5BDF7.8090502@trash.net>	<20090415135526.2afc4d18@nehalam>	<49E64C91.5020708@cosmosbay.com> <20090415.164811.19905145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, kaber@trash.net, jeff.chua.linux@gmail.com,
	paulmck@linux.vnet.ibm.com, paulus@samba.org, mingo@elte.hu,
	torvalds@linux-foundation.org, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51849 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbZDPG15 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 02:27:57 -0400
In-Reply-To: <20090415.164811.19905145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 15 Apr 2009 23:07:29 +0200
>=20
>> Well, it seems original patch was not so bad after all
>>
>> http://lists.netfilter.org/pipermail/netfilter-devel/2006-January/02=
3175.html
>>
>> So change per-cpu spinlocks to per-cpu rwlocks=20
>>
>> and use read_lock() in ipt_do_table() to allow recursion...
>=20
> Grumble, one more barrier to getting rid of rwlocks in the whole
> tree. :-/
>=20
> I really think we should entertain the idea where we don't RCU quiesc=
e
> when adding rules.  That was dismissed as not workable because the ne=
w
> rule must be "visible" as soon as we return to userspace but let's ge=
t
> real, effectively it will be.

We had to RCU quiesce to be sure old rules were not any more used befor=
e
freeing them. Alternative is to defer freeing via call_rcu() but
subject to OOM.

With 200 basic rules, size of rules table is about 40960 bytes per cpu.
(88 pages taken on vmalloc virtual space on my 8 cpus machine)
0xfcaf8000-0xfcb03000   45056 xt_alloc_table_info+0xa8/0xd0 pages=3D10 =
vmalloc
0xfcb04000-0xfcb0f000   45056 xt_alloc_table_info+0xa8/0xd0 pages=3D10 =
vmalloc
0xfcb10000-0xfcb1b000   45056 xt_alloc_table_info+0xa8/0xd0 pages=3D10 =
vmalloc
0xfcb1c000-0xfcb27000   45056 xt_alloc_table_info+0xa8/0xd0 pages=3D10 =
vmalloc
0xfcb28000-0xfcb33000   45056 xt_alloc_table_info+0xa8/0xd0 pages=3D10 =
vmalloc
0xfcb34000-0xfcb3f000   45056 xt_alloc_table_info+0xa8/0xd0 pages=3D10 =
vmalloc
0xfcb40000-0xfcb4b000   45056 xt_alloc_table_info+0xa8/0xd0 pages=3D10 =
vmalloc
0xfcb4c000-0xfcb57000   45056 xt_alloc_table_info+0xa8/0xd0 pages=3D10 =
vmalloc

This kind of monolithic huge object is hard to handle with RCU semantic=
,
more suitable for handling set of small objects (struct file for exampl=
e),
even if RCU can have a backoff of 10000 elements in its queue...

>=20
> If there are any stale object reference issues, we can use RCU object
> destruction to handle that kind of thing.
>=20
> I almost cringed when the per-spinlock idea was proposed, but per-cpu
> rwlocks just takes things too far for my tastes.


In my humble opinion, this is a reasonnable compromise, and Stephen pat=
ch
version 4 is ok for me.


