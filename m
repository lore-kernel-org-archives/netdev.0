From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v2 1/3] net/usb/r8152: support aggregation
Date: Thu, 15 Aug 2013 14:26:17 +0200
Message-ID: <20130815122617.GA18057@electric-eye.fr.zoreil.com>
References: <1376378913-879-1-git-send-email-hayeswang@realtek.com>
 <1376484880-741-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1376484880-741-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
[...]
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index 11c51f2..abb0b9f 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
[...]
> @@ -315,13 +318,34 @@ struct tx_desc {
>  	u32 opts2;
>  };
>  
> +struct rx_agg {
> +	struct list_head list;
> +	struct urb *urb;
> +	void *context;

void * is not needed: context is always struct r8152 *.

> +	void *buffer;
> +	void *head;
> +};
> +
> +struct tx_agg {
> +	struct list_head list;
> +	struct urb *urb;
> +	void *context;

void * is not needed: context is always struct r8152 *.

> +	void *buffer;
> +	void *head;
> +	u32 skb_num;
> +	u32 skb_len;
> +};
> +
>  struct r8152 {
>  	unsigned long flags;
>  	struct usb_device *udev;
>  	struct tasklet_struct tl;
>  	struct net_device *netdev;
> -	struct urb *rx_urb, *tx_urb;
> -	struct sk_buff *tx_skb, *rx_skb;
> +	struct tx_agg tx_info[RTL8152_MAX_TX];
> +	struct rx_agg rx_info[RTL8152_MAX_RX];
> +	struct list_head rx_done, tx_free;
> +	struct sk_buff_head tx_queue;
> +	spinlock_t rx_lock, tx_lock;

You may group rx data on one side and tx data on an other side to be
more cache friendly.

[...]
> @@ -686,6 +711,9 @@ static void ocp_reg_write(struct r8152 *tp, u16 addr, u16 data)
>  	ocp_write_word(tp, MCU_TYPE_PLA, ocp_index, data);
>  }
>  
> +static
> +int r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags);
> +

It's a new, less than 10 lines function without driver internal dependencies.

The forward declaration is not needed.

[...]
> @@ -743,129 +751,425 @@ static struct net_device_stats *rtl8152_get_stats(struct net_device *dev)
>  
>  static void read_bulk_callback(struct urb *urb)

No rtl8152_ prefix ?

>  {
[...]
> -	if (!netif_device_present(netdev))
> +	if (!netif_carrier_ok(netdev))
>  		return;

How is it related to the subject of the patch ?

[...]
> +static void rx_bottom(struct r8152 *tp)
> +{
> +	struct net_device_stats *stats;
> +	struct net_device *netdev;
> +	struct rx_agg *agg;
> +	struct rx_desc *rx_desc;
> +	unsigned long lockflags;

Idiom: 'flags'.

> +	struct list_head *cursor, *next;
> +	struct sk_buff *skb;
> +	struct urb *urb;
> +	unsigned pkt_len;
> +	int len_used;
> +	u8 *rx_data;
> +	int ret;

The scope of these variables is needlessly wide.

> +
> +	netdev = tp->netdev;
> +
> +	stats = rtl8152_get_stats(netdev);
> +
> +	spin_lock_irqsave(&tp->rx_lock, lockflags);
> +	list_for_each_safe(cursor, next, &tp->rx_done) {
> +		list_del_init(cursor);
> +		spin_unlock_irqrestore(&tp->rx_lock, lockflags);
> +
> +		agg = list_entry(cursor, struct rx_agg, list);
> +		urb = agg->urb;
> +		if (urb->actual_length < ETH_ZLEN) {

			goto submit;

> +			ret = r8152_submit_rx(tp, agg, GFP_ATOMIC);
> +			spin_lock_irqsave(&tp->rx_lock, lockflags);
> +			if (ret && ret != -ENODEV) {
> +				list_add_tail(&agg->list, next);
> +				tasklet_schedule(&tp->tl);
> +			}
> +			continue;
> +		}

(remove the line above)

[...]
> +			rx_data = rx_agg_align(rx_data + pkt_len + 4);
> +			rx_desc = (struct rx_desc *)rx_data;
> +			pkt_len = le32_to_cpu(rx_desc->opts1) & RX_LEN_MASK;
> +			len_used = (int)(rx_data - (u8 *)agg->head);
> +			len_used += sizeof(struct rx_desc) + pkt_len;
> +		}
> +

submit:

> +		ret = r8152_submit_rx(tp, agg, GFP_ATOMIC);
> +		spin_lock_irqsave(&tp->rx_lock, lockflags);
> +		if (ret && ret != -ENODEV) {
> +			list_add_tail(&agg->list, next);
> +			tasklet_schedule(&tp->tl);
> +		}
> +	}
> +	spin_unlock_irqrestore(&tp->rx_lock, lockflags);
> +}

It should be possible to retrieve more items in the spinlocked section
so as to have a chance to batch more work. I have not thought too deeply
about it.

> +
> +static void tx_bottom(struct r8152 *tp)
> +{
> +	struct net_device_stats *stats;
> +	struct net_device *netdev;
> +	struct tx_agg *agg;
> +	unsigned long lockflags;
> +	u32 remain, total;
> +	u8 *tx_data;
> +	int res;
> +
> +	netdev = tp->netdev;
> +
> +next_agg:

Use a real for / while loop and split this function as you experience
line length problem.

[...]
> +static void bottom_half(unsigned long data)
>  {
>  	struct r8152 *tp;
> -	int status = urb->status;
>  
> -	tp = urb->context;
> -	if (!tp)
> +	tp = (struct r8152 *)data;

  	struct r8152 *tp = (struct r8152 *)data;

[...]
> -	if (!netif_device_present(tp->netdev))
> +
> +	if (!netif_carrier_ok(tp->netdev))
>  		return;

It deserves an explanation.

[...]
> @@ -923,33 +1227,44 @@ static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
>  {
[...]
> +	spin_lock_irqsave(&tp->tx_lock, lockflags);
> +	if (!list_empty(&tp->tx_free) && skb_queue_empty(&tp->tx_queue)) {
> +		struct list_head *cursor;
> +
> +		cursor = tp->tx_free.next;
> +		list_del_init(cursor);
> +		agg = list_entry(cursor, struct tx_agg, list);

Duplicated in tx_bottom.

[...]
> @@ -999,17 +1313,18 @@ static inline u8 rtl8152_get_speed(struct r8152 *tp)
>  
>  static int rtl8152_enable(struct r8152 *tp)
>  {
> -	u32	ocp_data;
> +	u32 ocp_data;
> +	int i, ret;
>  	u8 speed;
>  
>  	speed = rtl8152_get_speed(tp);
> -	if (speed & _100bps) {
> +	if (speed & _10bps) {
>  		ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEEP_CR);
> -		ocp_data &= ~EEEP_CR_EEEP_TX;
> +		ocp_data |= EEEP_CR_EEEP_TX;
>  		ocp_write_word(tp, MCU_TYPE_PLA, PLA_EEEP_CR, ocp_data);
>  	} else {
>  		ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEEP_CR);
> -		ocp_data |= EEEP_CR_EEEP_TX;
> +		ocp_data &= ~EEEP_CR_EEEP_TX;

Call me "Mickey Mouse" if this is related to the subject of the patch.

[...]
> @@ -1631,10 +1965,12 @@ static int rtl8152_probe(struct usb_interface *intf,
>  		return -ENOMEM;
>  	}
>  
> +	SET_NETDEV_DEV(netdev, &intf->dev);
>  	tp = netdev_priv(netdev);
> +	memset(tp, 0, sizeof(*tp));

Useless, see kzalloc in net/core/dev.c::alloc_netdev_mqs

-- 
Ueimor
