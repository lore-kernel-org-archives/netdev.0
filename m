From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [Patch] sctp: add receive buffer accounting to sctp (fwd)
Date: Fri, 11 Mar 2005 19:58:50 +0530 (IST)
Message-ID: <Pine.LNX.4.61.0503111947470.6007@localhost.localdomain>
References: <Pine.LNX.4.61.0503030027590.8076@localhost.localdomain>
 <20050309211632.6f70fe41.davem@davemloft.net> <20050310120803.GA6341@hmsendeavour.rdu.redhat.com>
 <20050310154342.GG6341@hmsendeavour.rdu.redhat.com>
 <20050310183856.08cb5f7b.davem@davemloft.net> <20050311125724.GB18122@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        lksctp-developers@lists.sourceforge.net
To: nhorman@redhat.com
In-Reply-To: <20050311125724.GB18122@hmsendeavour.rdu.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Neil,

I guess you may not have tried to compile SCTP with this patch. 
2.4 struct sock members do not have sk_ prefix.
So you need to replace sk_rmem_alloc and sk_rcvbuf with rmem_alloc and
rcvbuf.

Thanks
Sridhar

On Fri, 11 Mar 2005 nhorman@redhat.com wrote:

> On Thu, Mar 10, 2005 at 06:38:56PM -0800, David S. Miller wrote:
>> On Thu, 10 Mar 2005 10:43:42 -0500
>> nhorman@redhat.com wrote:
>>
>>> Repost of my ealier rcvbuf patch.  No changes, but rediffed to apply cleanly to
>>> the head of the bitkeeper tree.  Passes all lksctp regression tests
>>
>> Applied, thanks Neil.
>
> You're quite welcome.  Heres the 2.4 version of the same patch that you
> requested.  Applies clean against the bitkeeper head.
>
> Signed-off-by: Neil Horman <nhorman@redhat.com>
>
> [nhorman@hmsendeavour kernel]$ diffstat linux-2.4-sctp.rcvbuf.patch
> input.c |   21 +++++++++++++++++++++
> 1 files changed, 21 insertions(+)
>
>
> --- linux-2.4-sctp/net/sctp/input.c.orig	2005-03-10 13:36:49.000000000 -0500
> +++ linux-2.4-sctp/net/sctp/input.c	2005-03-10 13:51:25.000000000 -0500
> @@ -100,6 +100,21 @@
> 	return 0;
> }
>
> +/* The free routine for skbuffs that sctp receives */
> +static void sctp_rfree(struct sk_buff *skb)
> +{
> +	atomic_sub(sizeof(struct sctp_chunk),&skb->sk->sk_rmem_alloc);
> +	sock_rfree(skb);
> +}
> +
> +/* The ownership wrapper routine to do receive buffer accounting */
> +static void sctp_rcv_set_owner_r(struct sk_buff *skb, struct sock *sk)
> +{
> +	skb_set_owner_r(skb,sk);
> +	skb->destructor = sctp_rfree;
> +	atomic_add(sizeof(struct sctp_chunk),&sk->sk_rmem_alloc);
> +}
> +
> /*
>  * This is the routine which IP calls when receiving an SCTP packet.
>  */
> @@ -183,6 +198,10 @@
> 	rcvr = asoc ? &asoc->base : &ep->base;
> 	sk = rcvr->sk;
>
> +	if ((sk) && (atomic_read(&sk->sk_rmem_alloc) >= sk->sk_rcvbuf))
> +		goto discard_release;
> +
> +
> 	if (!ipsec_sk_policy(sk, skb))
> 		goto discard_release;
>
> @@ -197,6 +216,8 @@
> 		goto discard_release;
> 	}
>
> +	sctp_rcv_set_owner_r(skb,sk);
> +
> 	/* Remember what endpoint is to handle this packet. */
> 	chunk->rcvr = rcvr;
>
>

-- 
