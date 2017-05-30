From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/7] net: dsa: remove useless copy of tagger xmit
Date: Tue, 30 May 2017 17:29:43 +0200
Message-ID: <20170530152943.GH22758@lunn.ch>
References: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com>
 <20170530142131.23568-7-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170530142131.23568-7-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2017 at 10:21:30AM -0400, Vivien Didelot wrote:
> The dsa_slave_priv structure holds a copy of the dsa_device_ops xmit
> function. It is always assigned to the switch tree xmit function.
> 
> Remove this useless copy.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  net/dsa/dsa_priv.h | 3 ---
>  net/dsa/slave.c    | 4 +---
>  2 files changed, 1 insertion(+), 6 deletions(-)
> 
> diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
> index 0fdd2a8a4ad8..282a55639285 100644
> --- a/net/dsa/dsa_priv.h
> +++ b/net/dsa/dsa_priv.h
> @@ -71,9 +71,6 @@ struct dsa_device_ops {
>  };
>  
>  struct dsa_slave_priv {
> -	struct sk_buff *	(*xmit)(struct sk_buff *skb,
> -					struct net_device *dev);
> -
>  	/* DSA port data, such as switch, port index, etc. */
>  	struct dsa_port		*dp;
>  
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 887e26695519..ebad2af4d3a8 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -363,7 +363,7 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
>  	dev->stats.tx_bytes += skb->len;
>  
>  	/* Transmit function may have to reallocate the original SKB */
> -	nskb = p->xmit(skb, dev);
> +	nskb = p->dp->ds->dst->tag_ops->xmit(skb, dev);

This is also the hot path for DSA transmit. Do we really want to do 4
extra pointer dereferences a million times per second, compared to one
copy during setup?

     Andrew
