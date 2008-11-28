From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 6/6] fs: Introduce kern_mount_special() to mount	special
 vfs
Date: Fri, 28 Nov 2008 23:43:18 +0100
Message-ID: <49307406.4030609@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDCAB.1070204@cosmosbay.com> <20081128092604.GL28946@ZenIV.linux.org.uk> <493072B7.5050308@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	kernel-testers@vger.kernel.org, Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>, rth@twiddle.net,
	ink@jurassic.park.msu.ru
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:49599 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752887AbYK1WoG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 17:44:06 -0500
In-Reply-To: <493072B7.5050308@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Al Viro a =E9crit :
>> On Thu, Nov 27, 2008 at 12:32:59AM +0100, Eric Dumazet wrote:
>>> This function arms a flag (MNT_SPECIAL) on the vfs, to avoid
>>> refcounting on permanent system vfs.
>>> Use this function for sockets, pipes, anonymous fds.
>>
>> IMO that's pushing it past the point of usefulness; unless you can s=
how
>> that this really gives considerable win on pipes et.al. *AND* that i=
t
>> doesn't hurt other loads...
>=20
> Well, if this is the last cache line that might be shared, then yes,=20
> numbers can talk.
> But coming from 10 to 1 instead of 0 is OK I guess
>=20
>>
>> dput() part: again, I want to see what happens on other loads; it's=20
>> probably
>> fine (and win is certainly more than from mntput() change), but...  =
The
>> thing is, atomic_dec_and_lock() in there is often done on dentries w=
ith
>> d_count > 1 and that's fairly cheap (and doesn't involve contention =
on
>> dcache_lock on sane targets).
>>
>> FWIW, unless there's a really good reason to do alpha=20
>> atomic_dec_and_lock()
>> in a special way, I'd try to compare with
>=20
>>         if (atomic_add_unless(&dentry->d_count, -1, 1))
>>                 return;
>=20
> I dont know, but *reading* d_count before trying to write it is expen=
sive
> on modern cpus. Oprofile clearly show that on Intel Core2.
>=20
> Then, *testing* the flag before doing the atomic_something() has the =
same
> problem. Or we should put flag in a different cache line.
>=20
> I am lazy (time for a sleep here), maybe we are smart here and use a=20
> trick like that already ?
>=20
> atomic_t atomic_read_with_write_intent(atomic_t *v)
> {
>        int val =3D 0;
>     /*
>      * No LOCK prefix here, we only give a write intent hint to cpu
>      */
>        asm volatile("xaddl %0, %1"
>                     : "+r" (val), "+m" (v->counter)
>                     : : "memory");
>        return val;
> }

=46orget it, its wrong... I really need to sleep :)


