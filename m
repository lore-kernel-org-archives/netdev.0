From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH v2 1/2] net: pktgen: support injecting packets
 for qdisc testing
Date: Thu, 30 Jun 2016 10:37:58 +0200
Message-ID: <20160630103758.37bc8d6f@redhat.com>
References: <20160629200306.16491.65359.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932101AbcF3IqY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 04:46:24 -0400
In-Reply-To: <20160629200306.16491.65359.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Jun 2016 13:03:06 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> Add another xmit_mode to pktgen to allow testing xmit functionality
> of qdiscs. The new mode "queue_xmit" injects packets at
> __dev_queue_xmit() so that qdisc is called.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

I generally like this.

>  net/core/pktgen.c |   42 ++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 40 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index f74ab9c..4b3d467 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -213,6 +213,7 @@
>  /* Xmit modes */
>  #define M_START_XMIT		0	/* Default normal TX */
>  #define M_NETIF_RECEIVE 	1	/* Inject packets into stack */
> +#define M_QUEUE_XMIT		2	/* Inject packet into qdisc */
>  
>  /* If lock -- protects updating of if_list */
>  #define   if_lock(t)           spin_lock(&(t->if_lock));
> @@ -626,6 +627,8 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
>  
>  	if (pkt_dev->xmit_mode == M_NETIF_RECEIVE)
>  		seq_puts(seq, "     xmit_mode: netif_receive\n");
> +	else if (pkt_dev->xmit_mode == M_QUEUE_XMIT)
> +		seq_puts(seq, "     xmit_mode: xmit_queue\n");
>  
>  	seq_puts(seq, "     Flags: ");
>  
> @@ -1142,8 +1145,10 @@ static ssize_t pktgen_if_write(struct file *file,
>  			return len;
>  
>  		i += len;
> -		if ((value > 1) && (pkt_dev->xmit_mode == M_START_XMIT) &&
> -		    (!(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))
> +		if ((value > 1) &&
> +		    ((pkt_dev->xmit_mode == M_QUEUE_XMIT) ||
> +		     ((pkt_dev->xmit_mode == M_START_XMIT) &&
> +		     (!(pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)))))
>  			return -ENOTSUPP;
>  		pkt_dev->burst = value < 1 ? 1 : value;
>  		sprintf(pg_result, "OK: burst=%d", pkt_dev->burst);
> @@ -1198,6 +1203,9 @@ static ssize_t pktgen_if_write(struct file *file,
>  			 * at module loading time
>  			 */
>  			pkt_dev->clone_skb = 0;
> +		} else if (strcmp(f, "queue_xmit") == 0) {
> +			pkt_dev->xmit_mode = M_QUEUE_XMIT;
> +			pkt_dev->last_ok = 1;
>  		} else {
>  			sprintf(pg_result,
>  				"xmit_mode -:%s:- unknown\nAvailable modes: %s",
> @@ -3434,6 +3442,36 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
>  #endif
>  		} while (--burst > 0);
>  		goto out; /* Skips xmit_mode M_START_XMIT */
> +	} else if (pkt_dev->xmit_mode == M_QUEUE_XMIT) {
> +		local_bh_disable();
> +		atomic_add(burst, &pkt_dev->skb->users);

Reading the code, people might think that "burst" is allowed for this
mode, which it is not. (You do handle this earlier in this patch when
configuring this mode).

> +		ret = dev_queue_xmit(pkt_dev->skb);
> +		switch (ret) {
> +		case NET_XMIT_SUCCESS:
> +			pkt_dev->sofar++;
> +			pkt_dev->seq_num++;
> +			pkt_dev->tx_bytes += pkt_dev->last_pkt_size;
> +			break;
> +		case NET_XMIT_DROP:
> +		case NET_XMIT_CN:
> +		/* These are all valid return codes for a qdisc but
> +		 * indicate packets are being dropped or will likely
> +		 * be dropped soon.
> +		 */
> +		case NETDEV_TX_BUSY:
> +		/* qdisc may call dev_hard_start_xmit directly in cases
> +		 * where no queues exist e.g. loopback device, virtual
> +		 * devices, etc. In this case we need to handle
> +		 * NETDEV_TX_ codes.
> +		 */
> +		default:
> +			pkt_dev->errors++;
> +			net_info_ratelimited("%s xmit error: %d\n",
> +					     pkt_dev->odevname, ret);
> +			break;
> +		}
> +		goto out;
>  	}
>  
>  	txq = skb_get_tx_queue(odev, pkt_dev->skb);
> 



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
