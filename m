From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] net: prevent corruption of skb when using skb_gso_segment
Date: Thu, 7 Jan 2016 20:31:26 +0100
Message-ID: <20160107193126.GE23789@breakpoint.cc>
References: <20160106234943.GB23789@breakpoint.cc>
 <1452192181-23586-1-git-send-email-cascardo@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fw@strlen.de, koct9i@gmail.com,
	xiyou.wangcong@gmail.com, davem@davemloft.net, edumazet@google.com,
	linux-kernel@vger.kernel.org
To: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452192181-23586-1-git-send-email-cascardo@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thadeu Lima de Souza Cascardo <cascardo@redhat.com> wrote:
> skb_gso_segment uses skb->cb, which may be owned by the caller. This may
> cause IPCB(skb)->opt.optlen to be overwritten, which will make
> ip_fragment overwrite skb data and possibly skb_shinfo with IPOPT_NOOP,
> thus causing a crash.
> 
> This patch saves skb->cb before calling skb_gso_segment for those users
> that have anything to save, then restore it for each GSO segment.

Thanks.

> --- a/net/netfilter/nfnetlink_queue.c
> +++ b/net/netfilter/nfnetlink_queue.c
> @@ -34,6 +34,7 @@
>  #include <net/tcp_states.h>
>  #include <net/netfilter/nf_queue.h>
>  #include <net/netns/generic.h>
> +#include <net/ip.h>
>  
>  #include <linux/atomic.h>
>  
> @@ -678,6 +679,10 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
>  	int err = -ENOBUFS;
>  	struct net *net = entry->state.net;
>  	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
> +	union {
> +		struct inet_skb_parm h4;
> +		struct inet6_skb_parm h6;
> +	} header;
>  
>  	/* rcu_read_lock()ed by nf_hook_slow() */
>  	queue = instance_lookup(q, queuenum);
> @@ -702,6 +707,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
>  		return __nfqnl_enqueue_packet(net, queue, entry);
>  
>  	nf_bridge_adjust_skb_data(skb);
> +	memcpy(&header, skb->cb, sizeof(header));
>  	segs = skb_gso_segment(skb, 0);
>  	/* Does not use PTR_ERR to limit the number of error codes that can be
>  	 * returned by nf_queue.  For instance, callers rely on -ESRCH to
> @@ -713,6 +719,7 @@ nfqnl_enqueue_packet(struct nf_queue_entry *entry, unsigned int queuenum)
>  	err = 0;
>  	do {
>  		struct sk_buff *nskb = segs->next;
> +		memcpy(skb->cb, &header, sizeof(header));

I think this should be 'segs->cb'.

Other than that, this looks good to me.

> diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
> --- a/net/xfrm/xfrm_output.c
> +++ b/net/xfrm/xfrm_output.c
> @@ -166,7 +166,12 @@ static int xfrm_output2(struct net *net, struct sock *sk, struct sk_buff *skb)
> @@ -179,6 +184,7 @@ static int xfrm_output_gso(struct net *net, struct sock *sk, struct sk_buff *skb
>  		int err;
>  
>  		segs->next = NULL;
> +		memcpy(skb->cb, &header, sizeof(header));
>  		err = xfrm_output2(net, sk, segs);

likewise.
