From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC net-next PATCH V1 7/9] net: frag queue locking per hash
 bucket
Date: Tue, 27 Nov 2012 10:07:40 +0100
Message-ID: <1354007260.11754.246.camel@localhost>
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
Received: from mx1.redhat.com ([209.132.183.28]:61157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758536Ab2K0JJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 04:09:19 -0500
In-Reply-To: <20121123130836.18764.9297.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-23 at 14:08 +0100, Jesper Dangaard Brouer wrote:
> DO NOT apply - patch not finished, can cause on OOPS/PANIC during hash rebuild

Think I have fixed this issue.  And its even fixed in this patch, as the
oops occurred, when testing, with a slightly older version of this
patch.


> This patch implements per hash bucket locking for the frag queue
> hash.  This removes two write locks, and the only remaining write
> lock is for protecting hash rebuild.  This essentially reduce the
> readers-writer lock to a rebuild lock.

[... cut ...]
> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
> index 1620a21..447423f 100644
> --- a/net/ipv4/inet_fragment.c
> +++ b/net/ipv4/inet_fragment.c
[...]
> @@ -102,9 +112,17 @@ EXPORT_SYMBOL(inet_frags_exit_net);
>  
>  static inline void fq_unlink(struct inet_frag_queue *fq, struct inet_frags *f)
>  {
> -	write_lock(&f->lock);
> +	struct inet_frag_bucket *hb;
> +	unsigned int hash;
> +
> +	read_lock(&f->lock);
> +	hash = f->hashfn(fq);
> +	hb = &f->hash[hash];

Before the read_lock, were _here_ below then hash calc.  Which is wrong,
and caused the oops, as the hash result can change, when rnd is changed,
during hash rebuild.

> +
> +	spin_lock_bh(&hb->chain_lock);
>  	hlist_del(&fq->list);
> -	write_unlock(&f->lock);
> +	spin_unlock_bh(&hb->chain_lock);
> +	read_unlock(&f->lock);
>  	inet_frag_lru_del(fq);
>  }

[... cut ...]
