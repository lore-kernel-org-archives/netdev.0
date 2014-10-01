From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: pktgen: packet bursting via skb->xmit_more
Date: Tue, 30 Sep 2014 17:11:43 -0700
Message-ID: <1412122303.16704.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412121820-28633-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:58524 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbaJAALp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 20:11:45 -0400
Received: by mail-pa0-f52.google.com with SMTP id fb1so45212pad.25
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 17:11:45 -0700 (PDT)
In-Reply-To: <1412121820-28633-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-30 at 17:03 -0700, Alexei Starovoitov wrote:
...

>  static void pktgen_xmit(struct pktgen_dev *pkt_dev)
>  {
> +	unsigned int burst = ACCESS_ONCE(pkt_dev->burst), burst_cnt;
>  	struct net_device *odev = pkt_dev->odev;
>  	struct netdev_queue *txq;
> +	bool more;
>  	int ret;
>  
>  	/* If device is offline, then don't send */
> @@ -3347,8 +3363,14 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
>  		pkt_dev->last_ok = 0;
>  		goto unlock;
>  	}
> -	atomic_inc(&(pkt_dev->skb->users));
> -	ret = netdev_start_xmit(pkt_dev->skb, odev, txq, false);
> +	atomic_add(burst, &pkt_dev->skb->users);
> +
> +	burst_cnt = 0;
> +

It seems you dont really need @burst_cnt or @more in this function.

xmit_more:
	ret = netdev_start_xmit(pkt_dev->skb, odev, txq, --burst > 0);

> +xmit_more:
> +	more = ++burst_cnt < burst;
> +
> +	ret = netdev_start_xmit(pkt_dev->skb, odev, txq, more);
>  
>  	switch (ret) {
>  	case NETDEV_TX_OK:
> @@ -3356,6 +3378,8 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
>  		pkt_dev->sofar++;
>  		pkt_dev->seq_num++;
>  		pkt_dev->tx_bytes += pkt_dev->last_pkt_size;
> +		if (more && !netif_xmit_frozen_or_drv_stopped(txq))
> +			goto xmit_more;

	if (burst > 0 && !netif_xmit_frozen_or_drv_stopped(txq))
		goto xmit_more

>  		break;
>  	case NET_XMIT_DROP:
>  	case NET_XMIT_CN:
> @@ -3374,6 +3398,9 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
>  		atomic_dec(&(pkt_dev->skb->users));
>  		pkt_dev->last_ok = 0;
>  	}
> +
> +	if (unlikely(burst - burst_cnt > 0))
> +		atomic_sub(burst - burst_cnt, &pkt_dev->skb->users);

	if (unlikely(burst))
		atomic_sub(burst, &pkt_dev->skb->users);

>  unlock:
>  	HARD_TX_UNLOCK(odev, txq);
>  
> @@ -3572,6 +3599,7 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
>  	pkt_dev->svlan_p = 0;
>  	pkt_dev->svlan_cfi = 0;
>  	pkt_dev->svlan_id = 0xffff;
> +	pkt_dev->burst = 1;
>  	pkt_dev->node = -1;
>  
>  	err = pktgen_setup_dev(t->net, pkt_dev, ifname);
