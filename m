From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 1/9] sctp: Make the port hash table use struct
 net in it's key.
Date: Tue, 14 Aug 2012 23:18:01 -0400
Message-ID: <502B14E9.70701@gmail.com>
References: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com> <87mx27rig7.fsf@xmission.com> <87zk67q31q.fsf_-_@xmission.com> <87txwfq2z9.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Ariyasu <jan.ariyasu@hp.com>,
	Jan Ariyasu <jan.ariyasu@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@infradead.org>, Xi Wang <xi.wang@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87txwfq2z9.fsf_-_@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/06/2012 02:39 PM, Eric W. Biederman wrote:
>
> - Add struct net into the port hash table hash calculation
> - Add struct net inot the struct sctp_bind_bucket so there
>    is a memory of which network namespace a port is allocated in.
>    No need for a ref count because sctp_bind_bucket only exists
>    when there are sockets in the hash table and sockets can not
>    change their network namspace, and sockets already ref count
>    their network namespace.
> - Add struct net into the key comparison when we are testing
>    to see if we have found the port hash table entry we are
>    looking for.
>
> With these changes lookups in the port hash table becomes
> safe to use in multiple network namespaces.
>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>


> ---
>   include/net/sctp/sctp.h    |    4 ++--
>   include/net/sctp/structs.h |    1 +
>   net/sctp/socket.c          |   22 +++++++++++++---------
>   3 files changed, 16 insertions(+), 11 deletions(-)
>
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index ff49964..7c05040 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -632,9 +632,9 @@ static inline int sctp_sanity_check(void)
>
>   /* Warning: The following hash functions assume a power of two 'size'. */
>   /* This is the hash function for the SCTP port hash table. */
> -static inline int sctp_phashfn(__u16 lport)
> +static inline int sctp_phashfn(struct net *net, __u16 lport)
>   {
> -	return lport & (sctp_port_hashsize - 1);
> +	return (net_hash_mix(net) + lport) & (sctp_port_hashsize - 1);
>   }
>
>   /* This is the hash function for the endpoint hash table. */
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index fc5e600..c089bb1 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -102,6 +102,7 @@ struct sctp_bind_bucket {
>   	unsigned short	fastreuse;
>   	struct hlist_node	node;
>   	struct hlist_head	owner;
> +	struct net	*net;
>   };
>
>   struct sctp_bind_hashbucket {
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 5e25981..4316b0f 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -5769,7 +5769,7 @@ static void sctp_unhash(struct sock *sk)
>    * a fastreuse flag (FIXME: NPI ipg).
>    */
>   static struct sctp_bind_bucket *sctp_bucket_create(
> -	struct sctp_bind_hashbucket *head, unsigned short snum);
> +	struct sctp_bind_hashbucket *head, struct net *, unsigned short snum);
>
>   static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
>   {
> @@ -5799,11 +5799,12 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
>   				rover = low;
>   			if (inet_is_reserved_local_port(rover))
>   				continue;
> -			index = sctp_phashfn(rover);
> +			index = sctp_phashfn(sock_net(sk), rover);
>   			head = &sctp_port_hashtable[index];
>   			sctp_spin_lock(&head->lock);
>   			sctp_for_each_hentry(pp, node, &head->chain)
> -				if (pp->port == rover)
> +				if ((pp->port == rover) &&
> +				    net_eq(sock_net(sk), pp->net))
>   					goto next;
>   			break;
>   		next:
> @@ -5827,10 +5828,10 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
>   		 * to the port number (snum) - we detect that with the
>   		 * port iterator, pp being NULL.
>   		 */
> -		head = &sctp_port_hashtable[sctp_phashfn(snum)];
> +		head = &sctp_port_hashtable[sctp_phashfn(sock_net(sk), snum)];
>   		sctp_spin_lock(&head->lock);
>   		sctp_for_each_hentry(pp, node, &head->chain) {
> -			if (pp->port == snum)
> +			if ((pp->port == snum) && net_eq(pp->net, sock_net(sk)))
>   				goto pp_found;
>   		}
>   	}
> @@ -5881,7 +5882,7 @@ pp_found:
>   pp_not_found:
>   	/* If there was a hash table miss, create a new port.  */
>   	ret = 1;
> -	if (!pp && !(pp = sctp_bucket_create(head, snum)))
> +	if (!pp && !(pp = sctp_bucket_create(head, sock_net(sk), snum)))
>   		goto fail_unlock;
>
>   	/* In either case (hit or miss), make sure fastreuse is 1 only
> @@ -6113,7 +6114,7 @@ unsigned int sctp_poll(struct file *file, struct socket *sock, poll_table *wait)
>    ********************************************************************/
>
>   static struct sctp_bind_bucket *sctp_bucket_create(
> -	struct sctp_bind_hashbucket *head, unsigned short snum)
> +	struct sctp_bind_hashbucket *head, struct net *net, unsigned short snum)
>   {
>   	struct sctp_bind_bucket *pp;
>
> @@ -6123,6 +6124,7 @@ static struct sctp_bind_bucket *sctp_bucket_create(
>   		pp->port = snum;
>   		pp->fastreuse = 0;
>   		INIT_HLIST_HEAD(&pp->owner);
> +		pp->net = net;
>   		hlist_add_head(&pp->node, &head->chain);
>   	}
>   	return pp;
> @@ -6142,7 +6144,8 @@ static void sctp_bucket_destroy(struct sctp_bind_bucket *pp)
>   static inline void __sctp_put_port(struct sock *sk)
>   {
>   	struct sctp_bind_hashbucket *head =
> -		&sctp_port_hashtable[sctp_phashfn(inet_sk(sk)->inet_num)];
> +		&sctp_port_hashtable[sctp_phashfn(sock_net(sk),
> +						  inet_sk(sk)->inet_num)];
>   	struct sctp_bind_bucket *pp;
>
>   	sctp_spin_lock(&head->lock);
> @@ -6809,7 +6812,8 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
>   	newsp->hmac = NULL;
>
>   	/* Hook this new socket in to the bind_hash list. */
> -	head = &sctp_port_hashtable[sctp_phashfn(inet_sk(oldsk)->inet_num)];
> +	head = &sctp_port_hashtable[sctp_phashfn(sock_net(oldsk),
> +						 inet_sk(oldsk)->inet_num)];
>   	sctp_local_bh_disable();
>   	sctp_spin_lock(&head->lock);
>   	pp = sctp_sk(oldsk)->bind_hash;
>
