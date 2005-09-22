From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 1/3] netfilter : 3 patches to boost ip_tables performance
Date: Thu, 22 Sep 2005 15:17:51 +0200
Message-ID: <4332AEFF.1040105@cosmosbay.com>
References: <432EF0C5.5090908@cosmosbay.com> <200509191948.55333.ak@suse.de>
	<432FDAC5.3040801@cosmosbay.com> <200509201830.20689.ak@suse.de>
	<433082DE.3060308@cosmosbay.com> <43308324.70403@cosmosbay.com>
	<4331D0A9.3080801@cosmosbay.com>
	<20050922125724.GJ26520@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20050922125724.GJ26520@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Harald Welte a =E9crit :
> On Wed, Sep 21, 2005 at 11:29:13PM +0200, Eric Dumazet wrote:
>=20
>>Patch 1/3
>>
>>1) No more one rwlock_t protecting the 'curtain'
>=20
>=20
> I have no problem with this change "per se", but with the
> implementation.
>=20
> As of now, we live without any ugly #ifdef CONFIG_SMP / #endif sections
> in the code - and if possible, I would continue this good tradition.
>=20
> For example the get_counters() function.  Wouldn't all the smp specific
> code (for_each_cpu(), ...)  be #defined to nothing anyway?

Well... not exactly, but you are right only the first loop (SET_COUNTER) =
will=20
really do something. The if (cpu =3D=3D curcpu) will be true but the comp=
iler wont=20
  know that, cpu and curcpu are still C variables.


>=20
> And if we really need the #ifdef's, I would appreciate if those
> sectionas are as small as possible.  in get_counters() the section can
> definitely be smaller, rather than basically having the whole function
> body separate for smp and non-smp cases.

get_counters() is not critical, so I agree with you we can stick the gene=
ral=20
version (not the UP optimized one)

>=20
> Also, how much would we loose in runtime performance if we were using a
> "rwlock_t *" even in the UP case?.  I mean, it's just one more pointer
> dereference of something that is expected to be in cache anyway, isn't
> it?  This gets rid of another huge set of #ifdefs that make the code
> unreadable and prone to errors being introduced later on.
>=20

Well, in UP case, the rwlock_t is a nulldef.

I was inspired by another use of percpu data in include/linux/genhd.h
#ifdef  CONFIG_SMP
     struct disk_stats *dkstats;
#else
     struct disk_stats dkstats;
#endif

But if you dislike this, we can use pointer for all cases.

Eric
