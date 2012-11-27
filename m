From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC net-next PATCH V1 7/9] net: frag queue locking per hash
 bucket
Date: Tue, 27 Nov 2012 16:00:07 +0100
Message-ID: <1354028407.11754.258.camel@localhost>
References: <20121123130749.18764.25962.stgit@dragon>
	 <20121123130836.18764.9297.stgit@dragon>
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
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60429 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753280Ab2K0PCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 10:02:31 -0500
In-Reply-To: <20121123130836.18764.9297.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-23 at 14:08 +0100, Jesper Dangaard Brouer wrote:
> DO NOT apply - patch not finished, can cause on OOPS/PANIC during hash rebuild
> 
> This patch implements per hash bucket locking for the frag queue
> hash.  This removes two write locks, and the only remaining write
> lock is for protecting hash rebuild.  This essentially reduce the
> readers-writer lock to a rebuild lock.
> 
> NOT-Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Last bug mentioned, were not the only one... fixing hopefully the last bug in this patch.


> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
> index 1620a21..447423f 100644
> --- a/net/ipv4/inet_fragment.c
> +++ b/net/ipv4/inet_fragment.c
> @@ -35,20 +35,27 @@ static void inet_frag_secret_rebuild(unsigned long dummy)
>  	unsigned long now = jiffies;
>  	int i;
>  
> +	/* Per bucket lock NOT needed here, due to write lock protection */
>  	write_lock(&f->lock);
> +
>  	get_random_bytes(&f->rnd, sizeof(u32));
>  	for (i = 0; i < INETFRAGS_HASHSZ; i++) {
> +		struct inet_frag_bucket *hb;
>  		struct inet_frag_queue *q;
>  		struct hlist_node *p, *n;
>  
> -		hlist_for_each_entry_safe(q, p, n, &f->hash[i], list) {
> +		hb = &f->hash[i];
> +		hlist_for_each_entry_safe(q, p, n, &hb->chain, list) {
>  			unsigned int hval = f->hashfn(q);
>  
>  			if (hval != i) {
> +				struct inet_frag_bucket *hb_dest;
> +
>  				hlist_del(&q->list);
>  
>  				/* Relink to new hash chain. */
> -				hlist_add_head(&q->list, &f->hash[hval]);
> +				hb_dest = &f->hash[hval];
> +				hlist_add_head(&q->list, &hb->chain);

The above line were wrong, it should have been:
   hlist_add_head(&q->list, &hb_dest->chain);

>  			}
>  		}
>  	}

The patch seem quite stable now.  My test is to adjust to rebuild
interval to 2 sec and then run 4x 10G with two fragments (packet size
1472*2) to create as many fragments as possible (approx 300
inet_frag_queue elements).

30 min test run:
 3726+3896+3960+3608 = 15190 Mbit/s

(For reproducers, note, that changing ipfrag_secret_interval (e.g.
sysctl -w net/ipv4/ipfrag_secret_interval=2), first take effect after
the first interval/timer expires, which default is 10 min)


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
