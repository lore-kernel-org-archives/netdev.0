From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Allowing more than 64k connections and heavily optimize bind(0) time.
Date: Sat, 10 Jan 2009 13:59:31 +0300
Message-ID: <20090110105931.GB358@ioremap.net>
References: <20081224190926.GA3244@ioremap.net> <20081225212928.GA12038@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrixpower.ru ([195.178.208.66]:54544 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751027AbZAJK7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Jan 2009 05:59:33 -0500
Content-Disposition: inline
In-Reply-To: <20081225212928.GA12038@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ping :)

I'm getting out from the vacations tomorrow and will try to more
extensively test the patch (QA group found a bug in ipv6 side, but that
was with the .24 backported patch, current one does not have that codepath
iirc). But I would like to know if this worth it.

On Fri, Dec 26, 2008 at 12:29:28AM +0300, Evgeniy Polyakov (zbr@ioremap.net) wrote:
> On Wed, Dec 24, 2008 at 10:09:26PM +0300, Evgeniy Polyakov (zbr@ioremap.net) wrote:
> > As I just have been told, it results in this strange behaviour:
> > $ grep -n :60013 netstat.res
> > 33101:tcp        0      0 local1:60013       remote:80       ESTABLISHED
> > 33105:tcp        0      0 local1:60013       remote:80       ESTABLISHED
> > 52084:tcp        0      0 local2:60013       remote:80       ESTABLISHED
> > 52085:tcp        0      0 local2:60013       remote:80       ESTABLISHED
> > 58249:tcp        0      0 local3:60013       remote:80       ESTABLISHED
> 
> I suppose this issue with the multiple sockets bound to the same local
> address and port is now fixed. Likely problem is in the way my patch broke
> the old code, which assumed that table may contain only single reuse socket
> added via bind() with 0 port.
> 
> In the updated version bind() checks that selected bucket contains fast
> reuse sockets already, and in that case runs the whole bind conflict check,
> which involves address and port, otherwise socket is just added into the table.
> 
> Patch was not yet heavily tested though, but it passed several trivial
> lots-of-binds test application runs.
> I will update patch if production testing reveals some problems.
> 
> Signed-off-by: Evegeniy Polyakov <zbr@ioremap.net>
> 
> diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
> index 5cc182f..6389aea 100644
> --- a/include/net/inet_hashtables.h
> +++ b/include/net/inet_hashtables.h
> @@ -80,6 +80,7 @@ struct inet_bind_bucket {
>  	struct net		*ib_net;
>  	unsigned short		port;
>  	signed short		fastreuse;
> +	int			num_owners;
>  	struct hlist_node	node;
>  	struct hlist_head	owners;
>  };
> @@ -114,7 +115,7 @@ struct inet_hashinfo {
>  	struct inet_bind_hashbucket	*bhash;
>  
>  	unsigned int			bhash_size;
> -	/* Note : 4 bytes padding on 64 bit arches */
> +	int				bsockets;
>  
>  	/* All sockets in TCP_LISTEN state will be in here.  This is the only
>  	 * table where wildcard'd TCP sockets can exist.  Hash function here
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> index bd1278a..0813b3d 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -93,24 +93,40 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
>  	struct inet_bind_hashbucket *head;
>  	struct hlist_node *node;
>  	struct inet_bind_bucket *tb;
> -	int ret;
> +	int ret, attempts = 5;
>  	struct net *net = sock_net(sk);
> + 	int smallest_size = -1, smallest_rover;
>  
>  	local_bh_disable();
>  	if (!snum) {
>  		int remaining, rover, low, high;
>  
> +again:
>  		inet_get_local_port_range(&low, &high);
>  		remaining = (high - low) + 1;
> -		rover = net_random() % remaining + low;
> + 		smallest_rover = rover = net_random() % remaining + low;
>  
> +		smallest_size = -1;
>  		do {
>  			head = &hashinfo->bhash[inet_bhashfn(net, rover,
>  					hashinfo->bhash_size)];
>  			spin_lock(&head->lock);
>  			inet_bind_bucket_for_each(tb, node, &head->chain)
> -				if (tb->ib_net == net && tb->port == rover)
> +				if (tb->ib_net == net && tb->port == rover) {
> + 					if (tb->fastreuse > 0 &&
> + 					    sk->sk_reuse &&
> + 					    sk->sk_state != TCP_LISTEN &&
> + 					    (tb->num_owners < smallest_size || smallest_size == -1)) {
> + 						smallest_size = tb->num_owners;
> + 						smallest_rover = rover;
> +						if (hashinfo->bsockets > (high - low) + 1) {
> +							spin_unlock(&head->lock);
> +							snum = smallest_rover;
> +							goto have_snum;
> +						}
> + 					}
>  					goto next;
> +				}
>  			break;
>  		next:
>  			spin_unlock(&head->lock);
> @@ -125,14 +141,19 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
>  		 * the top level, not from the 'break;' statement.
>  		 */
>  		ret = 1;
> -		if (remaining <= 0)
> +		if (remaining <= 0) {
> +			if (smallest_size != -1) {
> +				snum = smallest_rover;
> +				goto have_snum;
> +			}
>  			goto fail;
> -
> +		}
>  		/* OK, here is the one we will use.  HEAD is
>  		 * non-NULL and we hold it's mutex.
>  		 */
>  		snum = rover;
>  	} else {
> +have_snum:
>  		head = &hashinfo->bhash[inet_bhashfn(net, snum,
>  				hashinfo->bhash_size)];
>  		spin_lock(&head->lock);
> @@ -145,12 +166,16 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
>  tb_found:
>  	if (!hlist_empty(&tb->owners)) {
>  		if (tb->fastreuse > 0 &&
> -		    sk->sk_reuse && sk->sk_state != TCP_LISTEN) {
> +		    sk->sk_reuse && sk->sk_state != TCP_LISTEN &&
> +		    smallest_size == -1) {
>  			goto success;
>  		} else {
>  			ret = 1;
> -			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb))
> +			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
> +				if (sk->sk_reuse && sk->sk_state != TCP_LISTEN && --attempts >= 0)
> +					goto again;
>  				goto fail_unlock;
> +			}
>  		}
>  	}
>  tb_not_found:
> diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
> index 4498190..399ec17 100644
> --- a/net/ipv4/inet_hashtables.c
> +++ b/net/ipv4/inet_hashtables.c
> @@ -38,6 +38,7 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
>  		tb->ib_net       = hold_net(net);
>  		tb->port      = snum;
>  		tb->fastreuse = 0;
> +		tb->num_owners = 0;
>  		INIT_HLIST_HEAD(&tb->owners);
>  		hlist_add_head(&tb->node, &head->chain);
>  	}
> @@ -59,8 +60,13 @@ void inet_bind_bucket_destroy(struct kmem_cache *cachep, struct inet_bind_bucket
>  void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
>  		    const unsigned short snum)
>  {
> +	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
> +
> +	hashinfo->bsockets++;
> +
>  	inet_sk(sk)->num = snum;
>  	sk_add_bind_node(sk, &tb->owners);
> +	tb->num_owners++;
>  	inet_csk(sk)->icsk_bind_hash = tb;
>  }
>  
> @@ -74,10 +80,13 @@ static void __inet_put_port(struct sock *sk)
>  			hashinfo->bhash_size);
>  	struct inet_bind_hashbucket *head = &hashinfo->bhash[bhash];
>  	struct inet_bind_bucket *tb;
> +	
> +	hashinfo->bsockets--;
>  
>  	spin_lock(&head->lock);
>  	tb = inet_csk(sk)->icsk_bind_hash;
>  	__sk_del_bind_node(sk);
> +	tb->num_owners--;
>  	inet_csk(sk)->icsk_bind_hash = NULL;
>  	inet_sk(sk)->num = 0;
>  	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
> @@ -450,9 +459,9 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
>  			 */
>  			inet_bind_bucket_for_each(tb, node, &head->chain) {
>  				if (tb->ib_net == net && tb->port == port) {
> -					WARN_ON(hlist_empty(&tb->owners));
>  					if (tb->fastreuse >= 0)
>  						goto next_port;
> +					WARN_ON(hlist_empty(&tb->owners));
>  					if (!check_established(death_row, sk,
>  								port, &tw))
>  						goto ok;
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 5c8fa7f..3e70134 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -101,6 +101,8 @@ struct inet_hashinfo __cacheline_aligned tcp_hashinfo = {
>  	.lhash_lock  = __RW_LOCK_UNLOCKED(tcp_hashinfo.lhash_lock),
>  	.lhash_users = ATOMIC_INIT(0),
>  	.lhash_wait  = __WAIT_QUEUE_HEAD_INITIALIZER(tcp_hashinfo.lhash_wait),
> +
> +	.bsockets    = 0,
>  };
>  
>  static inline __u32 tcp_v4_init_sequence(struct sk_buff *skb)
> 

-- 
	Evgeniy Polyakov
