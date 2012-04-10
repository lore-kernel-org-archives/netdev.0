From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] net: orphan queued skbs if device tx can stall
Date: Tue, 10 Apr 2012 17:10:41 +0300
Message-ID: <20120410141041.GA19556@redhat.com>
References: <20120408171323.GA16012@redhat.com>
 <1334044558.3126.5.camel@edumazet-glaptop>
 <20120410084151.GA27193@redhat.com>
 <1334048100.3126.21.camel@edumazet-glaptop>
 <20120410093140.GA27651@redhat.com>
 <1334052259.3126.68.camel@edumazet-glaptop>
 <20120410112459.GA28825@redhat.com>
 <1334058300.3126.99.camel@edumazet-glaptop>
 <20120410124151.GA29808@redhat.com>
 <1334065929.5300.40.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jason Wang <jasowang@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1334065929.5300.40.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 10, 2012 at 03:52:09PM +0200, Eric Dumazet wrote:
> On Tue, 2012-04-10 at 15:41 +0300, Michael S. Tsirkin wrote:
> 
> > I think it's a bad interface too but it's in a userspace ABI
> > now so I suspect we are stuck with it for now. We can try deprecating
> > but we can't just drop it.
> > 
> 
> By the way, skb orphaning should already be done in skb_orphan_try(),
> not sure why its done again in tun_net_xmit().

I think it's for when some tx flags are set.

> Note we perform orphaning right before giving skb to device on premise
> it'll be sent (and freed) in a reasonable amount of time.

Right. No way to ensure this with tun :(

> With following patch, no more qdisc on top of tun device,

I'll test this, thanks.

> yet user can
> change the limit

Question: if tun is moved between namespaces after tx queue len
is changed, will it get a queueing qdisc then?
If yes we need some other hack to address that ...

> (I would be curious to know if anybody changes tun
> txqueuelen and why)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index bb8c72c..c4a00cf 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -379,6 +379,7 @@ static int tun_net_close(struct net_device *dev)
>  static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct tun_struct *tun = netdev_priv(dev);
> +	int limit;
>  
>  	tun_debug(KERN_INFO, tun, "tun_net_xmit %d\n", skb->len);
>  
> @@ -396,7 +397,8 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
>  	    sk_filter(tun->socket.sk, skb))
>  		goto drop;
>  
> -	if (skb_queue_len(&tun->socket.sk->sk_receive_queue) >= dev->tx_queue_len) {
> +	limit = dev->tx_queue_len ? : TUN_READQ_SIZE;
> +	if (skb_queue_len(&tun->socket.sk->sk_receive_queue) >= limit) {
>  		if (!(tun->flags & TUN_ONE_QUEUE)) {
>  			/* Normal queueing mode. */
>  			/* Packet scheduler handles dropping of further packets. */
> @@ -521,7 +523,7 @@ static void tun_net_init(struct net_device *dev)
>  		/* Zero header length */
>  		dev->type = ARPHRD_NONE;
>  		dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
> -		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
> +		dev->tx_queue_len = 0;
>  		break;
>  
>  	case TUN_TAP_DEV:
> @@ -532,7 +534,7 @@ static void tun_net_init(struct net_device *dev)
>  
>  		eth_hw_addr_random(dev);
>  
> -		dev->tx_queue_len = TUN_READQ_SIZE;  /* We prefer our own queue length */
> +		dev->tx_queue_len = 0;
>  		break;
>  	}
>  }
> 
