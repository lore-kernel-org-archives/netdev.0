From: "Ronciak, John" <john.ronciak@intel.com>
Subject: RE: RFC: NAPI packet weighting patch
Date: Mon, 6 Jun 2005 08:35:26 -0700
Message-ID: <468F3FDA28AA87429AD807992E22D07E0450C002@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <hadi@cyberus.ca>, <buytenh@wantstofly.org>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>, <jdmason@us.ibm.com>,
        <shemminger@osdl.org>, <netdev@oss.sgi.com>,
        <Robert.Olsson@data.slu.se>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "David S. Miller" <davem@davemloft.net>, <mchan@broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

We are dropping packets at the HW level (FIFO errors) with 256
descriptors and the default weight of 64.  As we said reducing the
weight eliminates this which is understandable since the driver is being
serviced more fequently.  We also hacked the driver to do a buffer
allocation per packet sent up the stack.  This reduced the number of
dropped pacekts by about 80% but it was still a significant number of
drops (190K to 39K dropped).  So I don't think this is where the problem
is.  This is also comfimed with the tg3 driver doing the buffer update
to the HW every 25 descriptors.

We did not up the descriptor ring size with the default weight but will
try this today and report back.

Cheers,
John


> -----Original Message-----
> From: David S. Miller [mailto:davem@davemloft.net] 
> Sent: Sunday, June 05, 2005 11:43 PM
> To: mchan@broadcom.com
> Cc: hadi@cyberus.ca; buytenh@wantstofly.org; Williams, Mitch 
> A; Ronciak, John; jdmason@us.ibm.com; shemminger@osdl.org; 
> netdev@oss.sgi.com; Robert.Olsson@data.slu.se; Venkatesan, 
> Ganesh; Brandeburg, Jesse
> Subject: Re: RFC: NAPI packet weighting patch
> 
> 
> From: "David S. Miller" <davem@davemloft.net>
> Date: Sun, 05 Jun 2005 14:36:53 -0700 (PDT)
> 
> > BTW, here is the patch implementing this stuff.
> 
> A new patch and some more data.
> 
> When we go to gigabit, and NAPI kicks in, the first RX
> packet costs a lot (cache misses etc.) but the rest are
> very efficient to process.  I suspect this only holds
> for the single socket case, and on a real system processing
> many connections the cost drop might not be so clean.
> 
> The log output format is:
> 
> (TX_TICKS:RX_TICKS[ RX_TICK1 RX_TICK2 RX_TICK3 ... ])
> 
> Here is an example trace from a single socket TCP stream
> send over gigabit:
> 
> (9:112[ 26 8 7 8 7 ])
> (6:110[ 23 8 8 8 7 ])
> (7:57[ 26 8 ])
> (6:117[ 25 8 9 7 7 ])
> (5:37[ 26 ])
> (6:113[ 28 8 7 8 7 ])
> (0:20[ 9 ])
> (8:111[ 27 7 7 8 7 ])
> (5:109[ 25 8 8 8 7 ])
> (8:113[ 25 7 8 9 7 ])
> (6:108[ 25 8 7 7 7 ])
> (8:88[ 26 8 8 7 ])
> (6:109[ 25 7 7 7 7 ])
> (6:111[ 25 9 8 7 7 ])
> (0:48[ 9 5 ])
> 
> This kind of trace reiterates some things we already know.
> For example, mitigation (HW, SW, or a combination of both)
> helps because processing multiple packets let's us "reuse"
> the cpu cache priming the handling of the first packet
> achieves for us.
> 
> It would be great to stick something like this into the e1000
> driver, and get some output from it with Intel's single NIC
> performance degradation test case.
> 
> It is also necessary for the Intel folks to say whether the
> NIC is running out of RX descriptors in the single NIC
> case with dev->weight set to the default of 64.  If so, does
> increasing the RX ring size to a larger value via ethtool
> help?  If not, then why in the world are things running more
> slowly?
> 
> I've got a crappy 1.5GHZ sparc64 box in my tg3 tests here, and it can
> handle gigabit line rate with much CPU to spare.  So either Intel is
> doing something other than TCP stream tests, or something else is out
> of whack.
> 
> I even tried to do things like having a memory touching program
> run in parallel with the TCP stream test, and this did not make
> the timing numbers in the logs increase much at all.
> 
> --- ./drivers/net/tg3.c.~1~	2005-06-03 11:13:14.000000000 -0700
> +++ ./drivers/net/tg3.c	2005-06-05 23:21:11.000000000 -0700
> @@ -2836,7 +2836,22 @@ static int tg3_rx(struct tg3 *tp, int bu
>  				    desc->err_vlan & RXD_VLAN_MASK);
>  		} else
>  #endif
> +		{
> +			unsigned long t = get_cycles();
> +			struct tg3_poll_log_ent *lp;
> +			unsigned int ent;
> +
>  			netif_receive_skb(skb);
> +			t = get_cycles() - t;
> +
> +			ent = tp->poll_log_ent;
> +			lp = &tp->poll_log[ent];
> +			ent = lp->rx_cur_ent;
> +			if (ent < POLL_RX_SIZE) {
> +				lp->rx_ents[ent] = (u16) t;
> +				lp->rx_cur_ent = ent + 1;
> +			}
> +		}
>  
>  		tp->dev->last_rx = jiffies;
>  		received++;
> @@ -2897,9 +2912,15 @@ static int tg3_poll(struct net_device *n
>  
>  	/* run TX completion thread */
>  	if (sblk->idx[0].tx_consumer != tp->tx_cons) {
> +		unsigned long t;
> +
>  		spin_lock(&tp->tx_lock);
> +		t = get_cycles();		
>  		tg3_tx(tp);
> +		t = get_cycles() - t;
>  		spin_unlock(&tp->tx_lock);
> +
> +		tp->poll_log[tp->poll_log_ent].tx_ticks = (u16) t;
>  	}
>  
>  	spin_unlock_irqrestore(&tp->lock, flags);
> @@ -2911,16 +2932,28 @@ static int tg3_poll(struct net_device *n
>  	if (sblk->idx[0].rx_producer != tp->rx_rcb_ptr) {
>  		int orig_budget = *budget;
>  		int work_done;
> +		unsigned long t;
> +		unsigned int ent;
>  
>  		if (orig_budget > netdev->quota)
>  			orig_budget = netdev->quota;
>  
> +		t = get_cycles();
>  		work_done = tg3_rx(tp, orig_budget);
> +		t = get_cycles() - t;
> +
> +		ent = tp->poll_log_ent;
> +		tp->poll_log[ent].rx_ticks = (u16) t;
>  
>  		*budget -= work_done;
>  		netdev->quota -= work_done;
>  	}
>  
> +	tp->poll_log_ent = (tp->poll_log_ent + 1) & POLL_LOG_MASK;
> +	tp->poll_log[tp->poll_log_ent].tx_ticks = 0;
> +	tp->poll_log[tp->poll_log_ent].rx_ticks = 0;
> +	tp->poll_log[tp->poll_log_ent].rx_cur_ent = 0;
> +
>  	if (tp->tg3_flags & TG3_FLAG_TAGGED_STATUS)
>  		tp->last_tag = sblk->status_tag;
>  	rmb();
> @@ -6609,6 +6642,27 @@ static struct net_device_stats *tg3_get_
>  	stats->rx_crc_errors = old_stats->rx_crc_errors +
>  		calc_crc_errors(tp);
>  
> +	/* XXX Yes, I know, do this right. :-)  */
> +	{
> +		unsigned int ent;
> +
> +		printk("TG3: POLL LOG, current ent[%d]\n", 
> tp->poll_log_ent);
> +		ent = tp->poll_log_ent - (POLL_LOG_SIZE - 1);
> +		ent &= POLL_LOG_MASK;
> +		while (ent != tp->poll_log_ent) {
> +			struct tg3_poll_log_ent *lp = 
> &tp->poll_log[ent];
> +			int i;
> +
> +			printk("(%u:%u[ ",
> +			       lp->tx_ticks, lp->rx_ticks);
> +			for (i = 0; i < lp->rx_cur_ent; i++)
> +				printk("%d ", lp->rx_ents[i]);
> +			printk("])\n");
> +
> +			ent = (ent + 1) & POLL_LOG_MASK;
> +		}
> +	}
> +
>  	return stats;
>  }
>  
> --- ./drivers/net/tg3.h.~1~	2005-06-03 11:13:14.000000000 -0700
> +++ ./drivers/net/tg3.h	2005-06-05 23:21:05.000000000 -0700
> @@ -2003,6 +2003,15 @@ struct tg3_ethtool_stats {
>  	u64		nic_tx_threshold_hit;
>  };
>  
> +struct tg3_poll_log_ent {
> +	u16 tx_ticks;
> +	u16 rx_ticks;
> +#define POLL_RX_SIZE	8
> +#define POLL_RX_MASK	(POLL_RX_SIZE - 1)
> +	u16 rx_cur_ent;
> +	u16 rx_ents[POLL_RX_SIZE];
> +};
> +
>  struct tg3 {
>  	/* begin "general, frequently-used members" cacheline section */
>  
> @@ -2232,6 +2241,11 @@ struct tg3 {
>  #define SST_25VF0X0_PAGE_SIZE		4098
>  
>  	struct ethtool_coalesce		coal;
> +
> +#define POLL_LOG_SIZE	(1 << 7)
> +#define POLL_LOG_MASK	(POLL_LOG_SIZE - 1)
> +	unsigned int			poll_log_ent;
> +	struct tg3_poll_log_ent		poll_log[POLL_LOG_SIZE];
>  };
>  
>  #endif /* !(_T3_H) */
> 
