From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] netdev: pktgen xmit packet through vlan interface
Date: Fri, 2 May 2014 15:19:21 +0200
Message-ID: <20140502151921.014fbeec@redhat.com>
References: <1399015092-28643-1-git-send-email-zhouzhouyi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, <davem@davemloft.net>,
	<steffen.klassert@secunet.com>, <fan.du@windriver.com>,
	<dborkman@redhat.com>, <minipli@googlemail.com>, <tgraf@suug.ch>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399015092-28643-1-git-send-email-zhouzhouyi@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri,  2 May 2014 15:18:12 +0800
Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:

> As http://www.spinics.net/lists/netdev/msg165015.html
> pktgen generates shared packet through vlan interface will cause
> oops because of duplicate entering tc queue.
>
> Try to solve this problem by means of packet clone instead of sharing.

I really don't like adding this stuff to the fast path of pktgen.

Why would you use pktgen on a VLAN?

Why don't you use the "vlan_id" feature available in pktgen, and send
in the lower real device?



> Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
> ---
>  net/core/pktgen.c |   20 +++++++++++++++++---
>  1 files changed, 17 insertions(+), 3 deletions(-)
> 
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index 0304f98..ced07fc 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -3297,6 +3297,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
>  	netdev_tx_t (*xmit)(struct sk_buff *, struct net_device *)
>  		= odev->netdev_ops->ndo_start_xmit;
>  	struct netdev_queue *txq;
> +	struct sk_buff *nskb = NULL;
>  	u16 queue_map;
>  	int ret;
>  
> @@ -3347,8 +3348,18 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
>  		pkt_dev->last_ok = 0;
>  		goto unlock;
>  	}
> -	atomic_inc(&(pkt_dev->skb->users));
> -	ret = (*xmit)(pkt_dev->skb, odev);
> +
> +	if (pkt_dev->clone_skb && is_vlan_dev(odev)) {
> +		nskb = skb_clone(pkt_dev->skb, GFP_ATOMIC);
> +		ret = -ENOMEM;
> +		if (nskb)
> +			ret = (*xmit)(nskb, odev);
> +		else
> +			nskb = ERR_PTR(ret);
> +	} else {
> +		atomic_inc(&(pkt_dev->skb->users));
> +		ret = (*xmit)(pkt_dev->skb, odev);
> +	}
>  
>  	switch (ret) {
>  	case NETDEV_TX_OK:
> @@ -3372,7 +3383,10 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
>  	case NETDEV_TX_LOCKED:
>  	case NETDEV_TX_BUSY:
>  		/* Retry it next time */
> -		atomic_dec(&(pkt_dev->skb->users));
> +		if (nskb && !IS_ERR(nskb))
> +			kfree_skb(nskb);
> +		else
> +			atomic_dec(&(pkt_dev->skb->users));
>  		pkt_dev->last_ok = 0;
>  	}
>  unlock:



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
