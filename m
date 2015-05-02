From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v3 net-next] pktgen: introduce 'rx' mode
Date: Sat, 2 May 2015 10:46:21 +0200
Message-ID: <20150502104621.4fede885@redhat.com>
References: <1430457130-16003-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Robert Olsson <robert@herjulf.net>,
	Ben Greear <greearb@candelatech.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49652 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750894AbbEBIqi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 May 2015 04:46:38 -0400
In-Reply-To: <1430457130-16003-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Apr 2015 22:12:10 -0700
Alexei Starovoitov <ast@plumgrid.com> wrote:

> Introduce 'RX' mode for pktgen which generates the packets
> using familiar pktgen commands, but feeds them into
> netif_receive_skb() instead of ndo_start_xmit().
> 
> It is designed to test netif_receive_skb and ingress qdisc
> performace only. Make sure to understand how it works before
> using it for other rx benchmarking.

Hi Alexei

First of all I love the idea of modifying pktgen to performance test
the RX path.

I'm not sure the simple "rx" flag is a good "name".  It likely
conflicts with other work where pktgen can receive it own packets, e.g.
https://people.kth.se/~danieltt/pktgen/ or Ben Greer's solution.

In your patch several things are not pktgen "compliant":
 1. Flags in pktgen are normally in upper-case "RX"
 2. Flags also require a disable "!RX" option
 3. You didn't add the flag to list of supported flags
 4. You don't output if the flag is enabled
 5. You didn't update the documentation (Documentation/networking/pktgen.txt)

Cc.ed Robert and Ben, and left the patch below for their review.


> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> v2->v3: addressed more Eric comments. Thanks!
> 
> v1->v2: as suggested by Eric:
> - dropped 'clone_skb' flag, now it will return enotsupp
> - fix rps/rfs bug by checking skb->users after every netif_receive_skb
> - tested with RPS/RFS, taps, veth, physical devs, various tc cls/act
> 
>  net/core/pktgen.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 47 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index 508155b283dd..34fd5ece2681 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -203,6 +203,7 @@
>  #define F_NODE          (1<<15)	/* Node memory alloc*/
>  #define F_UDPCSUM       (1<<16)	/* Include UDP checksum */
>  #define F_NO_TIMESTAMP  (1<<17)	/* Don't timestamp packets (default TS) */
> +#define F_DO_RX		(1<<18)	/* generate packets for RX */
>  
>  /* Thread control flag bits */
>  #define T_STOP        (1<<0)	/* Stop run */
> @@ -1081,7 +1082,8 @@ static ssize_t pktgen_if_write(struct file *file,
>  		if (len < 0)
>  			return len;
>  		if ((value > 0) &&
> -		    (!(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))
> +		    ((pkt_dev->flags & F_DO_RX) ||
> +		     !(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))
>  			return -ENOTSUPP;
>  		i += len;
>  		pkt_dev->clone_skb = value;
> @@ -1089,6 +1091,12 @@ static ssize_t pktgen_if_write(struct file *file,
>  		sprintf(pg_result, "OK: clone_skb=%d", pkt_dev->clone_skb);
>  		return count;
>  	}
> +	if (!strcmp(name, "rx")) {
> +		pkt_dev->flags |= F_DO_RX;
> +
> +		sprintf(pg_result, "OK: RX is ON");
> +		return count;
> +	}
>  	if (!strcmp(name, "count")) {
>  		len = num_arg(&user_buffer[i], 10, &value);
>  		if (len < 0)
> @@ -1134,7 +1142,7 @@ static ssize_t pktgen_if_write(struct file *file,
>  			return len;
>  
>  		i += len;
> -		if ((value > 1) &&
> +		if ((value > 1) && !(pkt_dev->flags & F_DO_RX) &&
>  		    (!(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))
>  			return -ENOTSUPP;
>  		pkt_dev->burst = value < 1 ? 1 : value;
> @@ -3317,6 +3325,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
>  	unsigned int burst = ACCESS_ONCE(pkt_dev->burst);
>  	struct net_device *odev = pkt_dev->odev;
>  	struct netdev_queue *txq;
> +	struct sk_buff *skb;
>  	int ret;
>  
>  	/* If device is offline, then don't send */
> @@ -3349,11 +3358,46 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
>  		pkt_dev->last_pkt_size = pkt_dev->skb->len;
>  		pkt_dev->allocated_skbs++;
>  		pkt_dev->clone_count = 0;	/* reset counter */
> +		if (pkt_dev->flags & F_DO_RX)
> +			pkt_dev->skb->protocol = eth_type_trans(pkt_dev->skb,
> +								pkt_dev->skb->dev);
>  	}
>  
>  	if (pkt_dev->delay && pkt_dev->last_ok)
>  		spin(pkt_dev, pkt_dev->next_tx);
>  
> +	if (pkt_dev->flags & F_DO_RX) {
> +		skb = pkt_dev->skb;
> +		atomic_add(burst, &skb->users);
> +		local_bh_disable();
> +		do {
> +			ret = netif_receive_skb(skb);
> +			if (ret == NET_RX_DROP)
> +				pkt_dev->errors++;
> +			pkt_dev->sofar++;
> +			pkt_dev->seq_num++;
> +			if (atomic_read(&skb->users) != burst) {
> +				/* skb was queued by rps/rfs or taps,
> +				 * so cannot reuse this skb
> +				 */
> +				atomic_sub(burst - 1, &skb->users);
> +				/* get out of the loop and wait
> +				 * until skb is consumed
> +				 */
> +				pkt_dev->last_ok = 1;
> +				pkt_dev->clone_skb = 0;
> +				break;
> +			}
> +			/* skb was 'freed' by stack, so clean few
> +			 * bits and reuse it
> +			 */
> +#ifdef CONFIG_NET_CLS_ACT
> +			skb->tc_verd = 0; /* reset reclass/redir ttl */
> +#endif
> +		} while (--burst > 0);
> +		goto out;
> +	}
> +
>  	txq = skb_get_tx_queue(odev, pkt_dev->skb);
>  
>  	local_bh_disable();
> @@ -3401,6 +3445,7 @@ xmit_more:
>  unlock:
>  	HARD_TX_UNLOCK(odev, txq);
>  
> +out:
>  	local_bh_enable();
>  
>  	/* If pkt_dev->count is zero, then run forever */



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
