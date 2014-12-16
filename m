From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v9 0/3] add hisilicon hip04 ethernet driver
Date: Tue, 16 Dec 2014 09:54:37 +0100
Message-ID: <26790181.hAWQCCSkRa@wuerfel>
References: <1418298150-4944-1-git-send-email-dingtianhong@huawei.com> <2708715.thQWqYuW6a@wuerfel> <548FE5E1.1090300@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-arm-kernel@lists.infradead.org, zhangfei.gao@linaro.org,
	davem@davemloft.net, linux@arm.linux.org.uk, f.fainelli@gmail.com,
	sergei.shtylyov@cogentembedded.com, mark.rutland@arm.com,
	David.Laight@aculab.com, eric.dumazet@gmail.com,
	xuwei5@hisilicon.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:61087 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbaLPIzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 03:55:42 -0500
In-Reply-To: <548FE5E1.1090300@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 16 December 2014 15:57:21 Ding Tianhong wrote:
> On 2014/12/15 21:29, Arnd Bergmann wrote:
> > On Thursday 11 December 2014 19:42:27 Ding Tianhong wrote:
> > @@ -381,57 +392,37 @@ static void hip04_tx_reclaim(struct net_device *ndev, bool force)
> >  		dev_kfree_skb(priv->tx_skb[tx_tail]);
> >  		priv->tx_skb[tx_tail] = NULL;
> >  		tx_tail = TX_NEXT(tx_tail);
> > -		priv->tx_count--;
> > -
> > -		if (priv->tx_count <= 0)
> > -			break;
> > +		count--;
> >  	}
> >  
...
> > -	queue_delayed_work(priv->wq, &priv->tx_clean_task, delta_in_ticks);
> > +	return count;
> 
> I think should return pkts_compl, because may break from the loop, the
> pkts_compl may smaller than count.

The calling convention I used is to return the packets that are remaining
on the queue. Only if that is nonzero we need to reschedule the timer.

> and we need to add netif_tx_lock() to protect this function to avoid concurrency conflict.

Oh, did I miss something? The idea was that the start_xmit function only updates
the tx_head pointer and reads the tx_tail, while the tx_reclaim function does
the reverse, and writes to a different cache line, in order to allow a lockless
queue traversal.

Can you point to a specific struct member that still need to be protected by
the lock? Did I miss a race that would allow both functions to exit with
the timer disabled and entries left on the queue?

> > @@ -623,8 +648,6 @@ static int hip04_mac_stop(struct net_device *ndev)
> >  	struct hip04_priv *priv = netdev_priv(ndev);
> >  	int i;
> >  
> > -	cancel_delayed_work_sync(&priv->tx_clean_task);
> > -
> I think we should cancle the hrtimer when closed and queue the timer when open.

I was expecting that force-cleaning up the tx queue would be enough for that.
It it not?

I suppose it can't hurt to cancel the timer here anyway, and maybe use
WARN_ON() if it's still active.

Starting the timer after opening seems wrong though: at that point there are
no packets on the queue yet. The timer should always start ticking at the
exact point when the first packet is put on the queue while the timer is
not already pending.

> >  	napi_disable(&priv->napi);
> >  	netif_stop_queue(ndev);
> >  	hip04_mac_disable(ndev);
> > @@ -725,6 +748,7 @@ static int hip04_mac_probe(struct platform_device *pdev)
> >  	struct hip04_priv *priv;
> >  	struct resource *res;
> >  	unsigned int irq;
> > +	ktime_t txtime;
> >  	int ret;
> >  
> >  	ndev = alloc_etherdev(sizeof(struct hip04_priv));
> > @@ -751,6 +775,21 @@ static int hip04_mac_probe(struct platform_device *pdev)
> >  	priv->port = arg.args[0];
> >  	priv->chan = arg.args[1] * RX_DESC_NUM;
> >  
> > +	hrtimer_init(&priv->tx_coalesce_timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
> > +
> > +	/*
> > +	 * BQL will try to keep the TX queue as short as possible, but it can't
> > +	 * be faster than tx_coalesce_usecs, so we need a fast timeout here,
> > +	 * but also long enough to gather up enough frames to ensure we don't
> > +	 * get more interrupts than necessary.
> > +	 * 200us is enough for 16 frames of 1500 bytes at gigabit ethernet rate
> > +	 */
> > +	priv->tx_coalesce_frames = TX_DESC_NUM * 3 / 4;
> > +	priv->tx_coalesce_usecs = 200;
> > +	/* allow timer to fire after half the time at the earliest */
> > +	txtime = ktime_set(0, priv->tx_coalesce_usecs * NSEC_PER_USEC / 2);
> > +	hrtimer_set_expires_range(&priv->tx_coalesce_timer, txtime, txtime);
> > +
> 
> I think miss the line:
>  priv->tx_coalesce_timer.function = tx_done;

Yes, good point.

	Arnd
