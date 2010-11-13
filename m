From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: Kernel rwlock design, Multicore and IGMP
Date: Sat, 13 Nov 2010 18:03:33 -0500
Message-ID: <4CDF1945.8090101@tilera.com>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com> <1289489007.17691.1310.camel@edumazet-laptop> <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com> <ZXmP8hjgLHA.4648@exchange1.tad.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cypher Wu <cypher.w@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?QW3DqXJpY28gV2FuZw==?= <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ZXmP8hjgLHA.4648@exchange1.tad.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/12/2010 2:13 AM, Am=C3=A9rico Wang wrote:
> On Fri, Nov 12, 2010 at 11:32:59AM +0800, Cypher Wu wrote:
>> On Thu, Nov 11, 2010 at 11:23 PM, Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:
>>> Le jeudi 11 novembre 2010 =C3=A0 21:49 +0800, Cypher Wu a =C3=A9cri=
t :
>>>> I'm using TILEPro and its rwlock in kernel is a liitle different t=
han
>>>> other platforms. It have a priority for write lock that when tried=
 it
>>>> will block the following read lock even if read lock is hold by
>>>> others. Its code can be read in Linux Kernel 2.6.36 in
>>>> arch/tile/lib/spinlock_32.c.
>>>
>>> This seems a bug to me.
>>> [...]
>>>
>> It seems not a problem that read_lock() can be nested or not since
>> rwlock doesn't have 'owner', it's just that should we give
>> write_lock() a priority than read_lock() since if there have a lot
>> read_lock()s then they'll starve write_lock().
>> We should work out a well defined behavior so all the
>> platform-dependent raw_rwlock has to design under that principle.
>=20
> It is a known weakness of rwlock, it is designed like that. :)

Exactly.  The tile rwlock correctly allows recursively reacquiring the =
read
lock.  But it does give priority to writers, for the (unfortunately
incorrect) reasons Cypher Wu outlined above, e.g.:

- Core A takes a read lock
- Core B tries for a write lock and blocks new read locks
- Core A tries for a (recursive) read lock and blocks

Core A and B are now deadlocked.

The solution is actually to simplify the tile rwlock implementation so =
that
both readers and writers contend fairly for the lock.

I'll post a patch in the next day or two for tile.

--=20
Chris Metcalf, Tilera Corp.
http://www.tilera.com
