From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: finer grained nf_conn locking
Date: Mon, 30 Mar 2009 21:57:15 +0200
Message-ID: <49D1241B.6020504@cosmosbay.com>
References: <20090218051906.174295181@vyatta.com>	<20090218052747.679540125@vyatta.com>	<499BDB5D.2050105@trash.net>	<499C1894.7060400@cosmosbay.com>	<49CE568A.9090104@cosmosbay.com> <20090328174835.0d0b63f8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090328174835.0d0b63f8@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =C3=A9crit :
> On Sat, 28 Mar 2009 17:55:38 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>> Eric Dumazet a =C3=A9crit :
>>> Patrick McHardy a =C3=A9crit :
>>>> Stephen Hemminger wrote:
>>>>
>>>>> @@ -50,6 +50,7 @@ struct ip_ct_tcp_state {
>>>>> =20
>>>>>  struct ip_ct_tcp
>>>>>  {
>>>>> +    spinlock_t    lock;
>>>>>      struct ip_ct_tcp_state seen[2];    /* connection parameters =
per
>>>>> direction */
>>>>>      u_int8_t    state;        /* state of the connection (enum
>>>>> tcp_conntrack) */
>>>>>      /* For detecting stale connections */
>>>> Eric already posted a patch to use an array of locks, which is
>>>> a better approach IMO since it keeps the size of the conntrack
>>>> entries down.
>>> Yes, we probably can use an array for short lived lock sections.
>=20
> I am not a fan of the array of locks. Sizing it is awkward and
> it is vulnerable to hash collisions. Let's see if there is another
> better way.

On normal machines, (no debugging spinlocks), patch uses an embedded
spinlock. We probably can use this even on 32bit kernels, considering
previous patch removed the rcu_head (8 bytes on 32bit arches) from
nf_conn :)

if LOCKDEP is on, size of a spinlock is 64 bytes on x86_64.
Adding a spinlock on each nf_conn would be too expensive. In this
case, an array of spinlock is a good compromise, as done in
IP route cache, tcp ehash, ...

I agree sizing of this hash table is not pretty, and should be
a generic kernel service (I wanted such service for futexes for example=
)

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
