From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next v2 1/3] net/usb/r8152: support aggregation
Date: Fri, 16 Aug 2013 11:44:56 +0800
Message-ID: <4C3BE5B36641404DBF9ED8943729871B@realtek.com.tw>
References: <1376378913-879-1-git-send-email-hayeswang@realtek.com> <1376484880-741-1-git-send-email-hayeswang@realtek.com> <20130815122617.GA18057@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, 'nic_swsd' <nic_swsd@realtek.com>,
	<linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	'David Miller' <davem@davemloft.net>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130815122617.GA18057@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Thursday, August 15, 2013 8:26 PM
> To: Hayeswang
> Cc: netdev@vger.kernel.org; nic_swsd; 
> linux-kernel@vger.kernel.org; linux-usb@vger.kernel.org; David Miller
> Subject: Re: [PATCH net-next v2 1/3] net/usb/r8152: support 
> aggregation
> 
[...]
> > +static
> > +int r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, 
> gfp_t mem_flags);
> > +
> 
> It's a new, less than 10 lines function without driver 
> internal dependencies.
> 
> The forward declaration is not needed.

The r8152_submit_rx() need the declaration of read_bulk_callback(), and the
read_bulk_callback() need the declaration of r8152_submit_rx(), too. It likes
a dead lock, so I have no idea how to do it without another declaration.

[...]
> > -	if (!netif_device_present(netdev))
> > +	if (!netif_carrier_ok(netdev))
> >  		return;
> 
> How is it related to the subject of the patch ?

When link down, the driver would cancel all bulks. This avoid the re-submitting
bulk.

> [...]
> > +static void rx_bottom(struct r8152 *tp)
> > +{
> > +	struct net_device_stats *stats;
> > +	struct net_device *netdev;
> > +	struct rx_agg *agg;
> > +	struct rx_desc *rx_desc;
> > +	unsigned long lockflags;
> 
> Idiom: 'flags'.
> 
> > +	struct list_head *cursor, *next;
> > +	struct sk_buff *skb;
> > +	struct urb *urb;
> > +	unsigned pkt_len;
> > +	int len_used;
> > +	u8 *rx_data;
> > +	int ret;
> 
> The scope of these variables is needlessly wide.
> 
> > +
> > +	netdev = tp->netdev;
> > +
> > +	stats = rtl8152_get_stats(netdev);
> > +
> > +	spin_lock_irqsave(&tp->rx_lock, lockflags);
> > +	list_for_each_safe(cursor, next, &tp->rx_done) {
> > +		list_del_init(cursor);
> > +		spin_unlock_irqrestore(&tp->rx_lock, lockflags);
> > +
> > +		agg = list_entry(cursor, struct rx_agg, list);
> > +		urb = agg->urb;
> > +		if (urb->actual_length < ETH_ZLEN) {
> 
> 			goto submit;
> 
> > +			ret = r8152_submit_rx(tp, agg, GFP_ATOMIC);
> > +			spin_lock_irqsave(&tp->rx_lock, lockflags);
> > +			if (ret && ret != -ENODEV) {
> > +				list_add_tail(&agg->list, next);
> > +				tasklet_schedule(&tp->tl);
> > +			}
> > +			continue;
> > +		}
> 
> (remove the line above)
> 
> [...]
> > +			rx_data = rx_agg_align(rx_data + pkt_len + 4);
> > +			rx_desc = (struct rx_desc *)rx_data;
> > +			pkt_len = le32_to_cpu(rx_desc->opts1) & 
> RX_LEN_MASK;
> > +			len_used = (int)(rx_data - (u8 *)agg->head);
> > +			len_used += sizeof(struct rx_desc) + pkt_len;
> > +		}
> > +
> 
> submit:
> 
> > +		ret = r8152_submit_rx(tp, agg, GFP_ATOMIC);
> > +		spin_lock_irqsave(&tp->rx_lock, lockflags);
> > +		if (ret && ret != -ENODEV) {
> > +			list_add_tail(&agg->list, next);
> > +			tasklet_schedule(&tp->tl);
> > +		}
> > +	}
> > +	spin_unlock_irqrestore(&tp->rx_lock, lockflags);
> > +}
> 
> It should be possible to retrieve more items in the spinlocked section
> so as to have a chance to batch more work. I have not thought 
> too deeply
> about it.

I only lock when I want to remove or inser the agg list, and unlock as soon as
possible. I don't think I keep locking for a long time.

 
Best Regards,
Hayes
