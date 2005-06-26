From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] "safer ipv4 reassembly" (fwd)
Date: Sun, 26 Jun 2005 22:56:19 +1000
Message-ID: <20050626125619.GA31967@gondor.apana.org.au>
References: <Pine.LNX.4.61.0506230930350.15406@resonance.WorkGroup>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0506230930350.15406@resonance.WorkGroup>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 23, 2005 at 09:33:35AM -0700, Arthur Kepner wrote:
> 
> What with the recent migration to vger.kernel.org, I'm 
> forwarding this to oss.sgi.com, just in case any interested 
> parties missed it.

Thanks for writing this patch Arthur.

> +struct ipc {
> +	struct hlist_node	node;
> +	u32			saddr;
> +	u32			daddr;
> +	u8			protocol;
> +	atomic_t		refcnt;	/* how many ipqs hold refs to us */
> +	atomic_t		seq;	/* how many ip datagrams for this 
> +					 * (saddr,daddr,protocol) since we 
> +					 * were created */
> +	struct timer_list	timer;
> +	struct rcu_head		rcu;

Is RCU worth it here? The only time we'd be taking the locks on this
is when the first fragment of a packet comes in.  At that point we'll
be taking write_lock(&ipfrag_lock) anyway.

The only other use of RCU in your patch is ip_count.  That should be
changed to be done in ip_defrag instead.  At that point you can simply
find the ipc by deferencing ipq, so no need for __ipc_find and hence
RCU.

The reason you need to change it in this way is because you can't make
assumptions about ip_rcv_finish being the first place where a packet
is defragmented.  With connection tracking enabled conntrack is the first
place where defragmentation occurs.
  
> +#define IPC_HASHSZ	IPQ_HASHSZ
> +static struct {
> +	struct hlist_head head;
> +	spinlock_t lock;
> +} ipc_hash[IPC_HASHSZ];

I'd store ipc entries in the main ipq hash table since they can use
the same keys for lookup as ipq entries.  You just need to set protocol
to zero and map the user to values specific to ipc for ipc entries.
One mapping would be to set the top bit of user for ipc entries, e.g.

#define IP_DEFRAG_IPC 0x80000000
	ipc->user = ipq->user | IP_DEFRAG_IPC;

Of course you also need to make sure that the two structures share
the leading elements.  You can then use the user field to distinguish
between ipc/ipq entries.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
