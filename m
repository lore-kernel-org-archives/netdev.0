From: Greg Banks <gnb-97jfqw80gc6171pxa8y+qA@public.gmane.org>
Subject: Re: Fw: [PATCH] sunrpc: use better NUMA affinities
Date: Fri, 29 Jul 2011 16:53:21 +1000
Message-ID: <4E3258E1.6020000@fastmail.fm>
References: <20110729153207.17af3085@notabene.brown>	 <4E324DB4.7060600@fastmail.fm> <1311921035.7845.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1311921035.7845.10.camel@edumazet-laptop>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 29/07/11 16:30, Eric Dumazet wrote:
> Le vendredi 29 juillet 2011 =C3=A0 16:05 +1000, Greg Banks a =C3=A9cr=
it :
>> On 29/07/11 15:32, NeilBrown wrote:
>>
>> I seem to remember coming to the conclusion that Jeff eventually
>> addressed this problem...am I misremembering or did something regres=
s?
>>
> Currently, all nfsd kthreads use memory for their kernel stack and
> various initial data from a _single_ node, even if you use
> sunrpc.pool_mode=3Dpernode  (or percpu)

That's just plain broken and I'm very pleased to see you fix it.

I was just surprised that it was still broken and wondering how that=20
happened.  Looking at ToT I see that because I dropped the ball in 2008=
,=20
Jeff's patches didn't address the problem.  In ToT=20
svc_pool_map_set_cpumask() is called *after* kthread_create() and=20
applies to the child thread, *after* it's stack has been allocated on=20
the wrong node.  In the working SGI code, svc_pool_map_set_cpumask() is=
=20
called by the parent node on itself *before* calling kernel_thread() or=
=20
doing any of the data structure allocations, thus ensuring that=20
everything gets allocated using the default memory allocation policy,=20
which on SGI NFS servers was globally tuned to be "node-local".

> With my patch, we make sure each thread gets its stack from its local
> node.
>
> Check commit 94dcf29a11b3d20a (kthread: use kthread_create_on_node())=
 to
> see how this strategy already was adopted for ksoftirqd, kworker,
> migration, and pktgend kthreads.

Ah, I see.  It's unfortunate that the kthread_create() API ends up bein=
g=20
passed a CPU number but that's only used to format the name and not for=
=20
sensible things :(

--=20
Greg.

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
