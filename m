From: Tejun Heo <tj@kernel.org>
Subject: Re: netlink: Replace rhash_portid with bound
Date: Mon, 21 Sep 2015 14:20:22 -0400
Message-ID: <20150921182022.GB13263@mtj.duckdns.org>
References: <20150918111650.GA7508@gondor.apana.org.au>
 <20150920.225521.1063980101511317898.davem@davemloft.net>
 <20150921060636.GA30807@gondor.apana.org.au>
 <20150920.231104.525285577747035896.davem@davemloft.net>
 <20150921133415.GA1740@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150921133415.GA1740@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Herbert.

On Mon, Sep 21, 2015 at 09:34:16PM +0800, Herbert Xu wrote:
> @@ -1119,7 +1120,11 @@ static int netlink_insert(struct sock *sk, u32 portid)
>  		goto err;
>  	}
>  
> -	nlk_sk(sk)->portid = portid;
> +	/* rhashtable_insert carries an implicit write memory barrier
> +	 * so we don't need an smp_wmb here in order to ensure that
> +	 * portid is set before bound.
> +	 */
> +	nlk_sk(sk)->bound = portid;

store_release and load_acquire are different from the usual memory
barriers and can't be paired this way.  You have to pair store_release
and load_acquire.  Besides, it isn't a particularly good idea to
depend on memory barriers embedded in other data structures like the
above.  Here, especially, rhashtable_insert() would have write barrier
*before* the entry is hashed not necessarily *after*, which means that
in the above case, a socket which appears to have set bound to a
reader might not visible when the reader tries to look up the socket
on the hashtable.

There's no reason to be overly smart here.  This isn't a crazy hot
path, write barriers tend to be very cheap, store_release more so.
Please just do smp_store_release() and note what it's paired with.

> @@ -1539,7 +1546,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
>  		}
>  	}
>  
> -	if (!nlk->portid) {
> +	if (!nlk->bound) {

I don't think you can skip load_acquire here just because this is the
second deref of the variable.  That doesn't change anything.  Race
condition could still happen between the first and second tests and
skipping the second would lead to the same kind of bug.

> @@ -1587,7 +1594,7 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
>  	    !netlink_allowed(sock, NL_CFG_F_NONROOT_SEND))
>  		return -EPERM;
>  
> -	if (!nlk->portid)
> +	if (!nlk->bound)

Don't we need load_acquire here too?  Is this path holding a lock
which makes that unnecessary?

I'd suggest making it clear that ->bound is internal (name it
->__bound or sth) and provide a test macro which always uses
load_acquire.  It could be that there are a couple places which can
avoid load_acquire but it just isn't worth it.  load_acquire is very
cheap but bugs around it can be extremely subtle.  Let's please keep
it straight-forward.

Thanks.

-- 
tejun
