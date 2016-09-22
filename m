From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] net: thunderx: Support for byte queue limits
Date: Thu, 22 Sep 2016 10:41:00 -0700
Message-ID: <9704f631-dad4-3291-8731-bef9a07e1b07@gmail.com>
References: <1474535121-13958-1-git-send-email-sunil.kovvuri@gmail.com>
 <1474535121-13958-3-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: sunil.kovvuri@gmail.com, netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1474535121-13958-3-git-send-email-sunil.kovvuri@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 09/22/2016 02:05 AM, sunil.kovvuri@gmail.com wrote:
> From: Sunil Goutham <sgoutham@cavium.com>
> 
> This patch adds support for byte queue limits
> 
> Signed-off-by: Sunil Goutham <sgoutham@cavium.com>

Where is the code that calls netdev_tx_reset_queue()? This is needed in
the function that brings down the interface, did your test survive a
up/down/up sequence?

> ---
>  drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 11 ++++++--
>  drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 30 ++++++++++++++--------
>  2 files changed, 29 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
> index 7d00162..453e3a0 100644
> --- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
> +++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
> @@ -516,7 +516,8 @@ static int nicvf_init_resources(struct nicvf *nic)
>  static void nicvf_snd_pkt_handler(struct net_device *netdev,
>  				  struct cmp_queue *cq,
>  				  struct cqe_send_t *cqe_tx,
> -				  int cqe_type, int budget)
> +				  int cqe_type, int budget,
> +				  unsigned int *tx_pkts, unsigned int *tx_bytes)
>  {
>  	struct sk_buff *skb = NULL;
>  	struct nicvf *nic = netdev_priv(netdev);
> @@ -547,6 +548,8 @@ static void nicvf_snd_pkt_handler(struct net_device *netdev,
>  		}
>  		nicvf_put_sq_desc(sq, hdr->subdesc_cnt + 1);
>  		prefetch(skb);
> +		(*tx_pkts)++;
> +		*tx_bytes += skb->len;
>  		napi_consume_skb(skb, budget);
>  		sq->skbuff[cqe_tx->sqe_ptr] = (u64)NULL;
>  	} else {
> @@ -662,6 +665,7 @@ static int nicvf_cq_intr_handler(struct net_device *netdev, u8 cq_idx,
>  	struct cmp_queue *cq = &qs->cq[cq_idx];
>  	struct cqe_rx_t *cq_desc;
>  	struct netdev_queue *txq;
> +	unsigned int tx_pkts = 0, tx_bytes = 0;
>  
>  	spin_lock_bh(&cq->lock);
>  loop:
> @@ -701,7 +705,7 @@ loop:
>  		case CQE_TYPE_SEND:
>  			nicvf_snd_pkt_handler(netdev, cq,
>  					      (void *)cq_desc, CQE_TYPE_SEND,
> -					      budget);
> +					      budget, &tx_pkts, &tx_bytes);
>  			tx_done++;
>  		break;
>  		case CQE_TYPE_INVALID:
> @@ -730,6 +734,9 @@ done:
>  		netdev = nic->pnicvf->netdev;
>  		txq = netdev_get_tx_queue(netdev,
>  					  nicvf_netdev_qidx(nic, cq_idx));
> +		if (tx_pkts)
> +			netdev_tx_completed_queue(txq, tx_pkts, tx_bytes);
> +
>  		nic = nic->pnicvf;
>  		if (netif_tx_queue_stopped(txq) && netif_carrier_ok(netdev)) {
>  			netif_tx_start_queue(txq);
> diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
> index 178c5c7..a4fc501 100644
> --- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
> +++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
> @@ -1082,6 +1082,24 @@ static inline void nicvf_sq_add_cqe_subdesc(struct snd_queue *sq, int qentry,
>  	imm->len = 1;
>  }
>  
> +static inline void nicvf_sq_doorbell(struct nicvf *nic, struct sk_buff *skb,
> +				     int sq_num, int desc_cnt)
> +{
> +	struct netdev_queue *txq;
> +
> +	txq = netdev_get_tx_queue(nic->pnicvf->netdev,
> +				  skb_get_queue_mapping(skb));
> +
> +	netdev_tx_sent_queue(txq, skb->len);
> +
> +	/* make sure all memory stores are done before ringing doorbell */
> +	smp_wmb();
> +
> +	/* Inform HW to xmit all TSO segments */
> +	nicvf_queue_reg_write(nic, NIC_QSET_SQ_0_7_DOOR,
> +			      sq_num, desc_cnt);
> +}
> +
>  /* Segment a TSO packet into 'gso_size' segments and append
>   * them to SQ for transfer
>   */
> @@ -1141,12 +1159,8 @@ static int nicvf_sq_append_tso(struct nicvf *nic, struct snd_queue *sq,
>  	/* Save SKB in the last segment for freeing */
>  	sq->skbuff[hdr_qentry] = (u64)skb;
>  
> -	/* make sure all memory stores are done before ringing doorbell */
> -	smp_wmb();
> +	nicvf_sq_doorbell(nic, skb, sq_num, desc_cnt);
>  
> -	/* Inform HW to xmit all TSO segments */
> -	nicvf_queue_reg_write(nic, NIC_QSET_SQ_0_7_DOOR,
> -			      sq_num, desc_cnt);
>  	nic->drv_stats.tx_tso++;
>  	return 1;
>  }
> @@ -1219,12 +1233,8 @@ doorbell:
>  		nicvf_sq_add_cqe_subdesc(sq, qentry, tso_sqe, skb);
>  	}
>  
> -	/* make sure all memory stores are done before ringing doorbell */
> -	smp_wmb();
> +	nicvf_sq_doorbell(nic, skb, sq_num, subdesc_cnt);
>  
> -	/* Inform HW to xmit new packet */
> -	nicvf_queue_reg_write(nic, NIC_QSET_SQ_0_7_DOOR,
> -			      sq_num, subdesc_cnt);
>  	return 1;
>  
>  append_fail:
> 


-- 
Florian
