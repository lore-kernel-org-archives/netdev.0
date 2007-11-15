From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH, take2] netfilter : struct xt_table_info diet
Date: Thu, 15 Nov 2007 16:45:16 +0100
Message-ID: <20071115164516.ced96a9e.dada1@cosmosbay.com>
References: <473B6D88.4010701@cosmosbay.com>
	<473C3E92.30004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:60527 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757886AbXKOPpS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 10:45:18 -0500
In-Reply-To: <473C3E92.30004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Nov 2007 13:41:54 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Eric Dumazet wrote:
> > [PATCH] netfilter : struct xt_table_info diet
> > 
> > Instead of using a big array of NR_CPUS entries, we can compute the size
> > needed at runtime, using nr_cpu_ids
> > 
> > This should save some ram (especially on David's machines where
> > NR_CPUS=4096 :
> > 32 KB can be saved per table, and 64KB for dynamically allocated ones
> > (because
> > of slab/slub alignements) )
> > 
> > In particular, the 'bootstrap' tables are not any more static (in data
> > section) but on stack as their size is now very small.
> > 
> > This also should reduce the size used on stack in compat functions
> > (get_info() declares an automatic variable, that could be bigger than
> > kernel
> > stack size for big NR_CPUS)
> 
> 
> I fixed a compilation error with CONFIG_COMPAT and applied it, thanks
> Eric. One question though:
> 
> > +#define XT_TABLE_INFO_SZ (offsetof(struct xt_table_info, entries) \
> > +			  + nr_cpu_ids * sizeof(char *))
> 
> 
> >  	/* overflow check */
> > -	if (tmp.size >= (INT_MAX - sizeof(struct xt_table_info)) / NR_CPUS -
> > -			SMP_CACHE_BYTES)
> > +	if (tmp.size >= INT_MAX / num_possible_cpus())
> >  		return -ENOMEM;
> 
> We need to make sure offsetof(struct xt_table_info, entries) +
> nr_cpu_ids * sizeof(char *) doesn't overflow, so why doesn't it
> use nr_cpu_ids here as well?
> 

nr_cpu_ids is <= NR_CPUS, so XT_TABLE_INFO_SZ cannot overflow

The 'overflow check' we do here is in fact not very usefull now
that we dont need to multiply tmp.size by NR_CPUS and potentially
overflow the result.

We can delete the test, because kmalloc()/vmalloc() will probably
fail gracefully if we ask too much memory.

We could imagine a dual Opteron machine, with a total of 32GB of ram, and
it could be possible to load a 3GB iptable  (that would consume 2*3GB of ram), 
but the 'overflow check' test actually forbids such a scenario.



