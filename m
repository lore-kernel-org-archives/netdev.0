From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Fw: [PATCH] sunrpc: use better NUMA affinities
Date: Fri, 29 Jul 2011 08:30:35 +0200
Message-ID: <1311921035.7845.10.camel@edumazet-laptop>
References: <20110729153207.17af3085@notabene.brown>
	 <4E324DB4.7060600@fastmail.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Greg Banks <gnb-97jfqw80gc6171pxa8y+qA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4E324DB4.7060600-97jfqw80gc6171pxa8y+qA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le vendredi 29 juillet 2011 =C3=A0 16:05 +1000, Greg Banks a =C3=A9crit=
 :
> On 29/07/11 15:32, NeilBrown wrote:
> >
> > Hi Greg,
> >   I saw this patch float past and thought of you... You may not be =
interested
> >   any more, and it may be a perfectly good patch that does not need=
 any
> >   comment, but I thought I would let you know anyway.
>=20
> Thanks Neil.
>=20
> I've trimmed the cc list to limit the number of copies Trond and Bruc=
e get:)
>=20
> > From: Eric Dumazet<eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > To: Trond Myklebust<Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> > Cc: "J. Bruce Fields"<bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Neil Brown<neilb@suse.=
de>,
> > David Miller<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netde=
v
> > <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-kernel<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org=
>
> > Subject: [PATCH] sunrpc: use better NUMA affinities
> >
> >
> > Use NUMA aware allocations to reduce latencies and increase through=
put.
>=20
>=20
> Briefly looking at the patch, it doesn't seem wrong but I'm surprised=
=20
> it's (still) necessary.
>=20
> Some years ago at SGI we encountered that same problem; we solved it =
by=20
> delaying all the allocation of data structures associated with a thre=
ad=20
> so that they were performed in the thread itself, after the thread ha=
d=20
> been limited to run on a certain set of CPUs.  Thus the thread's norm=
al=20
> allocation behaviour resulted in all of it's allocations being from=20
> node-local pages.  It was a pretty ugly patch, but it worked and made=
 a=20
> huge difference to NFS throughput on large NUMA boxes.
>=20
> Later Jeff Layton converted the sunrpc svc startup code to use kthrea=
ds=20
> and at the time I read his patches, pointed out this problem, and pos=
ted=20
> my patch for comparison
>=20
> http://linux-nfs.org/pipermail/nfsv4/2008-May/008760.html
>=20
> I seem to remember coming to the conclusion that Jeff eventually=20
> addressed this problem...am I misremembering or did something regress=
?
>=20

Currently, all nfsd kthreads use memory for their kernel stack and
various initial data from a _single_ node, even if you use
sunrpc.pool_mode=3Dpernode  (or percpu)

With my patch, we make sure each thread gets its stack from its local
node.

Check commit 94dcf29a11b3d20a (kthread: use kthread_create_on_node()) t=
o
see how this strategy already was adopted for ksoftirqd, kworker,
migration, and pktgend kthreads.

I only have small machines here (two nodes), so I cannot post
significative bench results, but it seems quite obvious to expect a goo=
d
increase.



--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
