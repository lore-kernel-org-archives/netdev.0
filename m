From: David Miller <davem@davemloft.net>
Subject: Re: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Tue, 17 Nov 2009 00:59:50 -0800 (PST)
Message-ID: <20091117.005950.210148187.davem@davemloft.net>
References: <200911170830.nAH8UtQo010602@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56166
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752905AbZKQI7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 03:59:34 -0500
In-Reply-To: <200911170830.nAH8UtQo010602@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 17 Nov 2009 00:30:55 -0800

> +#include <cna.h>

Using "cna.h" is more appropriate.  "<cna.h>" assumes the
current working directory is in the header search path.

> +static uint bnad_msix = 1;
> +static uint bnad_small_large_rxbufs = 1;
> +static uint bnad_rxqsets_used;
> +static uint bnad_ipid_mode;
> +static uint bnad_vlan_strip = 1;
> +static uint bnad_txq_depth = BNAD_ENTRIES_PER_TXQ;
> +static uint bnad_rxq_depth = BNAD_ENTRIES_PER_RXQ;
> +static uint bnad_log_level ;

Many of these are a waste of space, on one or two counts.

Some of them are static settings that cannot be modified by
either module parameters or ethtool settings.  Therefore they
are constant and should be entirely removed from the driver
and all conditionals on those values completely removed.

In the worst case "const" should be added to them so the compiler
can optimize everything away.

Many of them are also booleans, so even they did stay a more
appropriate type would be 'bool' which typically consumes less space
than 'int' and also communicates better the variable's use.

Overall, this is a very sloppy set of driver knobs.

> +static void
> +bnad_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp);
 ...
> +static void
> +bnad_vlan_rx_kill_vid(struct net_device *netdev, unsigned short vid);

Don't chop things up like this just to abide by the "80 column line limit"
rule.  This makes grepping produce useless results.  If I grep for
"bnad_vlan_rx_kill_vid" the grep output won't show the function's
return type.

> +u32
> +bnad_get_msglevel(struct net_device *netdev)

One line please.

> +void
> +bnad_set_msglevel(struct net_device *netdev, u32 msglevel)

Same here.  And for rest of driver.

> +	BNA_ASSERT(wis <=
> +		   BNA_QE_IN_USE_CNT(&txqinfo->txq.q, txqinfo->txq.q.q_depth));

Please do not define your own assertion macros.  We have an
incredibly complete set of BUG traps and warning producing
state tests.  See "BUG_ON()", "WARN_ON()", "WARN()", etc.

Those macros should be used in favor of your's for many reasons,
the least of which is that WARN() is specifically tailored to
produce output that is parsable by kerneloops.org and other crash
dump analyzing tools.

> +static inline void
> +bnad_disable_txrx_irqs(struct bnad *bnad)
> +{

Is this performance critical?  If not, why inline?  Just drop
the inlines and let the compiler decide, we're not using 1990's
era compiler technology any more. :-)

> +	if (sent) {
> +		if (netif_queue_stopped(netdev) &&
> +		    netif_carrier_ok(netdev) &&
> +		    BNA_Q_FREE_COUNT(&txqinfo->txq) >=
> +		    BNAD_NETIF_WAKE_THRESHOLD) {
> +			netif_wake_queue(netdev);
> +			bnad->stats.netif_queue_wakeup++;
> +		}
> +		bna_ib_ack(bnad->priv, &txqinfo->ib, sent);

Is this driver multiqueue?  It seems so.

Yet here you're only using global device queue flow control.
This means that if one TX queue fills up, it will stop packet
submission for all of your TX queues which is extremely
suboptimal.

Also the netif_carrier_ok() test is not correct here.  The networking
core will stop TX submissions and synchronize the TX stream when the
carrier goes down.  TX queue flow control is independant from carrier
handling.

> +	prefetch(bnad);
> +	prefetch(bnad->netdev);

Prefetching a variable then immediately dereferencing it is
completely pointless.

If you disagree show me a benchmark that shows otherwise.

> +static void
> +bnad_netpoll(struct net_device *netdev)
> +{
> +	struct bnad *bnad = netdev_priv(netdev);
> +	struct bnad_cq_info *cqinfo;
> +	int i;
> +
> +	if (!(bnad->config & BNAD_CF_MSIX)) {
> +		disable_irq(bnad->pcidev->irq);
> +		bnad_isr(bnad->pcidev->irq, netdev);
> +		enable_irq(bnad->pcidev->irq);
> +	} else {
> +		for (i = 0; i < bnad->cq_num; i++) {
> +			cqinfo = &bnad->cq_table[i];
> +			bnad_disable_rx_irq(bnad, cqinfo);
> +			bnad_poll_cq(bnad, cqinfo, BNAD_MAX_Q_DEPTH);
> +			bnad_enable_rx_irq(bnad, cqinfo);
> +		}
> +	}
> +}
> +#endif

This is not correct.  Even if you're not using BNAD_CF_MSIX
you are still using NAPI.  So you should run the ISR and let
NAPI polling get scheduled.

Then bnad_poll_cq() is always running from NAPI ->poll() context
and therefore you don't need to use things like dev_kfree_skb_any()
et al. in there, you can use plain dev_kfree_skb() which is much
more efficient and correct.

> +	tasklet_init(&bnad->tx_free_tasklet, bnad_tx_free_tasklet,
> +		     (unsigned long)bnad);

Using a tasklet for TX packet liberation is dubious at best.   It's
just added overhead, scheduling yet another softirq from another
softirq (->poll() processing) when you can just invoke dev_kfree_skb()
directly.

> +	if (bnad->priv) {
> +
> +
> +		init_completion(&bnad->ioc_comp);

There's a lot of excessive spaces throughout the driver that looks
like this one, please clean them up.  Anything more than one empty
line is likely too much.
