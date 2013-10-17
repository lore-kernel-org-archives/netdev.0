From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] bridge: clean the nf_bridge status when forwarding
 the skb
Date: Thu, 17 Oct 2013 13:28:57 +0200
Message-ID: <20131017112857.GA11318@localhost>
References: <1381791096-3561-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Antonio Quartulli <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33960 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752427Ab3JQL3D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Oct 2013 07:29:03 -0400
Content-Disposition: inline
In-Reply-To: <1381791096-3561-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Oct 15, 2013 at 12:51:36AM +0200, Antonio Quartulli wrote:
> From: Antonio Quartulli <antonio@open-mesh.com>
> 
> Even if it is forbidden to enslave a bridge interface into
> another one, it is still possible to create a chain of
> virtual interfaces including two distinct bridges.
>
> In this case, the skb entering the second bridge could have
> the nf_bridge field already set due to a previous operation
> and consequently lead to wrong a processing of the packet
> itself.
> 
> To prevent this behaviour release and set to NULL the
> nf_bridge field of the skb when forwarding the packet.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
> ---
> 
> I know that not using "extern" when declaring the prototype is not consistent
> with the surrounding code, but checkpatch complaints about using "extern" in .h
> file and I prefer to not do something "wrong" even if stylistically ugly.
> 
> Cheers,
> 
> 
>  net/bridge/br_forward.c   |  2 ++
>  net/bridge/br_netfilter.c | 10 ++++++++++
>  net/bridge/br_private.h   |  2 ++
>  3 files changed, 14 insertions(+)
> 
> diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
> index 4b81b14..62955f3 100644
> --- a/net/bridge/br_forward.c
> +++ b/net/bridge/br_forward.c
> @@ -49,6 +49,8 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
>  	} else {
>  		skb_push(skb, ETH_HLEN);
>  		br_drop_fake_rtable(skb);
> +		br_netfilter_skb_free(skb);
> +
>  		dev_queue_xmit(skb);
>  	}
>  
> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> index f877362..7cad3e2 100644
> --- a/net/bridge/br_netfilter.c
> +++ b/net/bridge/br_netfilter.c
> @@ -1086,3 +1086,13 @@ void br_netfilter_fini(void)
>  #endif
>  	dst_entries_destroy(&fake_dst_ops);
>  }
> +
> +/**
> + * br_netfilter_skb_free - clean the NF bridge data in an skb
> + * @skb: the skb which the data to free belongs to
> + */
> +void br_netfilter_skb_free(struct sk_buff *skb)
> +{
> +	nf_bridge_put(skb->nf_bridge);
> +	skb->nf_bridge = NULL;
> +}

This should be nf_reset.
