From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V2 5/9] net: frag, per CPU resource, mem limit
 and LRU list accounting
Date: Mon, 03 Dec 2012 12:25:02 -0500 (EST)
Message-ID: <20121203.122502.145665886665071256.davem@davemloft.net>
References: <20121129161303.17754.47046.stgit@dragon>
	<1354208776.14302.1898.camel@edumazet-glaptop>
	<1354543361.20888.10.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, fw@strlen.de, netdev@vger.kernel.org,
	pablo@netfilter.org, tgraf@suug.ch, amwang@redhat.com,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38717 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214Ab2LCRZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 12:25:07 -0500
In-Reply-To: <1354543361.20888.10.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 03 Dec 2012 15:02:41 +0100

> On Thu, 2012-11-29 at 09:06 -0800, Eric Dumazet wrote:
>> On Thu, 2012-11-29 at 17:13 +0100, Jesper Dangaard Brouer wrote:
>> > The major performance bottleneck on NUMA systems, is the mem limit
>> > counter which is based an atomic counter.  This patch removes the
>> > cache-bouncing of the atomic counter, by moving this accounting to be
>> > bound to each CPU.  The LRU list also need to be done per CPU,
>> > in-order to keep the accounting straight.
>> > 
>> > If fragments belonging together is "sprayed" across CPUs, performance
>> > will still suffer, but due to NIC rxhashing this is not very common.
>> > Correct accounting in this situation is maintained by recording and
>> > "assigning" a CPU to a frag queue when its allocated (caused by the
>> > first packet associated packet).
>> > 
> [...]
>> > +/* Need to maintain these resource limits per CPU, else we will kill
>> > + * performance due to cache-line bouncing
>> > + */
>> > +struct frag_cpu_limit {
>> > +	atomic_t                mem;
>> > +	struct list_head        lru_list;
>> > +	spinlock_t              lru_lock;
>> > +} ____cacheline_aligned_in_smp;
>> > +
>> 
>> This looks like a big patch introducing a specific infrastructure, while
>> we already have lib/percpu_counter.c
> 
> For the record, I cannot use the lib/percpu_counter, because this
> accounting is not kept strictly per CPU, if the fragments are "sprayed"
> across CPUs (as described in the commit message above).

The percpu infrastructure allows precise counts and comparisons even
in that case.  It uses the cheap test when possible, and defers to a
more expensive test when necessary.
