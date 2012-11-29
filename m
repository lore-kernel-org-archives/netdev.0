From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V2 5/9] net: frag, per CPU resource, mem limit
 and LRU list accounting
Date: Thu, 29 Nov 2012 09:06:16 -0800
Message-ID: <1354208776.14302.1898.camel@edumazet-glaptop>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161303.17754.47046.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:58023 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566Ab2K2RGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 12:06:21 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so7757067pad.19
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 09:06:20 -0800 (PST)
In-Reply-To: <20121129161303.17754.47046.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-29 at 17:13 +0100, Jesper Dangaard Brouer wrote:
> The major performance bottleneck on NUMA systems, is the mem limit
> counter which is based an atomic counter.  This patch removes the
> cache-bouncing of the atomic counter, by moving this accounting to be
> bound to each CPU.  The LRU list also need to be done per CPU,
> in-order to keep the accounting straight.
> 
> If fragments belonging together is "sprayed" across CPUs, performance
> will still suffer, but due to NIC rxhashing this is not very common.
> Correct accounting in this situation is maintained by recording and
> "assigning" a CPU to a frag queue when its allocated (caused by the
> first packet associated packet).
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> 
> ---
> V2:
>  - Rename struct cpu_resource -> frag_cpu_limit
>  - Move init functions from inet_frag.h to inet_fragment.c
>  - Cleanup per CPU in inet_frags_exit_net()
> 
>  include/net/inet_frag.h                 |   64 +++++++++++++++++++------------
>  net/ipv4/inet_fragment.c                |   50 ++++++++++++++++++------
>  net/ipv4/ip_fragment.c                  |    3 +
>  net/ipv6/netfilter/nf_conntrack_reasm.c |    2 -
>  net/ipv6/reassembly.c                   |    2 -
>  5 files changed, 80 insertions(+), 41 deletions(-)
> 
> diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
> index 9bbef17..8421904 100644
> --- a/include/net/inet_frag.h
> +++ b/include/net/inet_frag.h
> @@ -1,11 +1,22 @@
>  #ifndef __NET_FRAG_H__
>  #define __NET_FRAG_H__
>  
> +#include <linux/spinlock.h>
> +#include <linux/atomic.h>
> +
> +/* Need to maintain these resource limits per CPU, else we will kill
> + * performance due to cache-line bouncing
> + */
> +struct frag_cpu_limit {
> +	atomic_t                mem;
> +	struct list_head        lru_list;
> +	spinlock_t              lru_lock;
> +} ____cacheline_aligned_in_smp;
> +

This looks like a big patch introducing a specific infrastructure, while
we already have lib/percpu_counter.c

Not counting the addition of a NR_CPUS array, which is really
unfortunate these days.
