From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter : struct xt_table_info diet
Date: Wed, 14 Nov 2007 18:55:44 +0100
Message-ID: <20071114185544.034ee7d1.dada1@cosmosbay.com>
References: <20071114164735.1ba04bc3.dada1@cosmosbay.com>
	<473B2E2D.4010504@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <473B2E2D.4010504@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Nov 2007 18:19:41 +0100
Patrick McHardy <kaber@trash.net> wrote:

> [netfilter-devel CCed]
> 
> Eric Dumazet wrote:
> > Hi David & Patrick
> > 
> > Please find a patch against net-2.6.25
> > 
> > Thank you
> > 
> > 
> > [PATCH] netfilter : struct xt_table_info diet
> > 
> > Instead of using a big array of NR_CPUS entries, we can compute the size needed at runtime, using nr_cpu_ids
> > 
> > This should save some ram (especially on David's machines where NR_CPUS=4096 : 32 KB can be saved per table, and 64KB for dynamically allocated ones (because of slab/slub alignements) )
> > 
> > In particular, the 'bootstrap' tables are not any more static (in data section) but on stack as their
> > size is now very small.
> > 
> > This also should reduce the size used on stack in compat functions 
> > (get_info() declares an automatic variable, that could be bigger than kernel stack size for big NR_CPUS)
> 
> 
> Thanks, this looks good. One question:
> 
> > diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
> > index 2909c92..ed3bd0b 100644
> > --- a/net/ipv4/netfilter/arp_tables.c
> > +++ b/net/ipv4/netfilter/arp_tables.c
> > @@ -811,7 +811,7 @@ static int do_replace(void __user *user, unsigned int len)
> >  		return -ENOPROTOOPT;
> >  
> >  	/* overflow check */
> > -	if (tmp.size >= (INT_MAX - sizeof(struct xt_table_info)) / NR_CPUS -
> > +	if (tmp.size >= (INT_MAX - XT_TABLE_INFO_SZ) / NR_CPUS -
> >  			SMP_CACHE_BYTES)
> 
> 
> Shouldn't NR_CPUs be replaced by nr_cpu_ids here? I'm wondering
> why we still include NR_CPUs in the calculation at all though,
> unlike in 2.4, we don't allocate one huge area of memory anymore
> but do one allocation per CPU. IIRC it even was you who changed
> that.
> 

Yes, doing an allocation per possible cpu was better than one giant 
allocation (memory savings and NUMA aware)

Well, technically speaking you are right, we may also replace these 
divides per NR_CPUS by nr_cpu_ids (or even better : num_possible_cpus())

Because with NR_CPUS=4096, we actually limit tmp.size to about 524000,
 what a shame ! :)

