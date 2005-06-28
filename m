From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [RFC/PATCH] "safer ipv4 reassembly" (fwd)
Date: Tue, 28 Jun 2005 15:11:39 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0506281404340.28098@resonance.WorkGroup>
References: <Pine.LNX.4.61.0506230930350.15406@resonance.WorkGroup>
 <20050626125619.GA31967@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netdev@oss.sgi.com,
        Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050626125619.GA31967@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Sun, 26 Jun 2005, Herbert Xu wrote:

> .....
> Thanks for writing this patch Arthur.

Likewise, thanks for reviewing it.

> 
> > +struct ipc {
> > +	struct hlist_node	node;
> > +	u32			saddr;
> > +	u32			daddr;
> > +	u8			protocol;
> > +	atomic_t		refcnt;	/* how many ipqs hold refs to us */
> > +	atomic_t		seq;	/* how many ip datagrams for this 
> > +					 * (saddr,daddr,protocol) since we 
> > +					 * were created */
> > +	struct timer_list	timer;
> > +	struct rcu_head		rcu;
> 
> Is RCU worth it here? The only time we'd be taking the locks on this
> is when the first fragment of a packet comes in.  At that point we'll
> be taking write_lock(&ipfrag_lock) anyway.
> 
> The only other use of RCU in your patch is ip_count.  That should be
> changed to be done in ip_defrag instead.  At that point you can simply
> find the ipc by deferencing ipq, so no need for __ipc_find and hence
> RCU.
> 
> The reason you need to change it in this way is because you can't make
> assumptions about ip_rcv_finish being the first place where a packet
> is defragmented.  With connection tracking enabled conntrack is the first
> place where defragmentation occurs.
>   

Right, I see that now. (I'm not well acquainted with the conntrack 
code...) 

One reason I used RCU for the "ipc" structures is that I wanted 
to be able to find find them (in ip_rcv_finish()) without locking. 
Since ip_rcv_finish() is the wrong place to do that, that reason 
is invalid. 

There is a (big) advantage to doing this in ip_defrag() - this 
becomes a no-op for non-fragmented datagrams. The disadvantage 
is that there could be a situation where you receive:

  1) first fragment of datagram X [for a particular (src,dst,proto)]
  2) a zillion non-fragmented datagrams [for the same (src,dst,proto)]
  3) last fragment of datagram X [for (src,dst,proto)]

and no "disorder" would be detected for the datagrams associated 
with (src,dst,proto), even though the ip id could have wrapped in the 
meantime. This seems like a very uncommon case, however.


> > +#define IPC_HASHSZ	IPQ_HASHSZ
> > +static struct {
> > +	struct hlist_head head;
> > +	spinlock_t lock;
> > +} ipc_hash[IPC_HASHSZ];
> 
> I'd store ipc entries in the main ipq hash table since they can use
> the same keys for lookup as ipq entries.  You just need to set protocol
> to zero and map the user to values specific to ipc for ipc entries.
> One mapping would be to set the top bit of user for ipc entries, e.g.
> 
> #define IP_DEFRAG_IPC 0x80000000
> 	ipc->user = ipq->user | IP_DEFRAG_IPC;
> 
> Of course you also need to make sure that the two structures share
> the leading elements.  You can then use the user field to distinguish
> between ipc/ipq entries.

Hmmm, let me think about combining the ipc/ipq structures, and 
also the related question of whether to use RCU for the ipc 
structures. I'll try to spin another version of the patch before 
the end of the week.

--
Arthur
