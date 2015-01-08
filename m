From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH v3 4/4] can: kvaser_usb: Add support for the Usbcan-II
 family
Date: Thu, 8 Jan 2015 17:19:01 +0200
Message-ID: <20150108151901.GA11398@vivalin-002>
References: <20141223154654.GB6460@vivalin-002>
 <20150105174910.GA6304@linux>
 <20150105175206.GB6304@linux>
 <20150105175713.GC6304@linux>
 <20150105183131.GD6304@linux>
 <54AE6FC1.6050007@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54AE6FC1.6050007@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marc,

On Thu, Jan 08, 2015 at 12:53:37PM +0100, Marc Kleine-Budde wrote:
> On 01/05/2015 07:31 PM, Ahmed S. Darwish wrote:
> > From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
[...]
> > +/* Kvaser USB CAN dongles are divided into two major families:
> > + * - Leaf: Based on Renesas M32C, running firmware labeled as 'filo'
> > + * - UsbcanII: Based on Renesas M16C, running firmware labeled as 'helios'
> > + */
> > +enum kvaser_usb_family {
> > +	KVASER_LEAF,
> > +	KVASER_USBCAN,
> > +};
> > +
> >  #define MAX_TX_URBS			16
> >  #define MAX_RX_URBS			4
> >  #define START_TIMEOUT			1000 /* msecs */
> > @@ -30,8 +41,9 @@
> >  #define RX_BUFFER_SIZE			3072
> >  #define CAN_USB_CLOCK			8000000
> >  #define MAX_NET_DEVICES			3
> > +#define MAX_USBCAN_NET_DEVICES		2
> >  
> > -/* Kvaser USB devices */
> > +/* Leaf USB devices */
> >  #define KVASER_VENDOR_ID		0x0bfd
> >  #define USB_LEAF_DEVEL_PRODUCT_ID	10
> >  #define USB_LEAF_LITE_PRODUCT_ID	11
> > @@ -55,6 +67,16 @@
> >  #define USB_CAN_R_PRODUCT_ID		39
> >  #define USB_LEAF_LITE_V2_PRODUCT_ID	288
> >  #define USB_MINI_PCIE_HS_PRODUCT_ID	289
> > +#define LEAF_PRODUCT_ID(id)		(id >= USB_LEAF_DEVEL_PRODUCT_ID && \
> > +					 id <= USB_MINI_PCIE_HS_PRODUCT_ID)
> 
> Can you please convert both *_PRODUCT_ID() macros into static inline
> bool functions.
> 

Will do.

[...]
> >  MODULE_DEVICE_TABLE(usb, kvaser_usb_table);
> > @@ -463,7 +631,18 @@ static int kvaser_usb_get_software_info(struct kvaser_usb *dev)
> >  	if (err)
> >  		return err;
> >  
> > -	dev->fw_version = le32_to_cpu(msg.u.softinfo.fw_version);
> > +	switch (dev->family) {
> > +	case KVASER_LEAF:
> > +		dev->fw_version = le32_to_cpu(msg.u.leaf.softinfo.fw_version);
> > +		break;
> > +	case KVASER_USBCAN:
> > +		dev->fw_version = le32_to_cpu(msg.u.usbcan.softinfo.fw_version);
> > +		break;
> > +	default:
> > +		dev_err(dev->udev->dev.parent,
> > +			"Invalid device family (%d)\n", dev->family);
> > +		return -EINVAL;
> 
> The default case should not happen. I think you can remove it.
> 

It's true, it _should_ never happen. But I only add such checks if
the follow-up code critically depends on a certain `dev->family`
behavior. So it's kind of a defensive check against any possible
bug in driver or memory.

What do you think?

> > +	}
> >  
> >  	return 0;
> >  }
> > @@ -484,6 +663,9 @@ static int kvaser_usb_get_card_info(struct kvaser_usb *dev)
> >  	dev->nchannels = msg.u.cardinfo.nchannels;
> >  	if (dev->nchannels > MAX_NET_DEVICES)
> >  		return -EINVAL;
> > +	if (dev->family == KVASER_USBCAN &&
> > +	    dev->nchannels > MAX_USBCAN_NET_DEVICES)
> > +		return -EINVAL;
> 
> Nitpick, as the new "if" also does a test on nchannels, why no extend
> the existing "if" with an "||"?
> 

Will do.

> >  
> >  	return 0;
> >  }
> > @@ -496,8 +678,10 @@ static void kvaser_usb_tx_acknowledge(const struct kvaser_usb *dev,
> >  	struct kvaser_usb_net_priv *priv;
> >  	struct sk_buff *skb;
> >  	struct can_frame *cf;
> > -	u8 channel = msg->u.tx_acknowledge.channel;
> > -	u8 tid = msg->u.tx_acknowledge.tid;
> > +	u8 channel, tid;
> > +
> > +	channel = msg->u.tx_acknowledge_header.channel;
> > +	tid = msg->u.tx_acknowledge_header.tid;
> >  
> >  	if (channel >= dev->nchannels) {
> >  		dev_err(dev->udev->dev.parent,
> > @@ -615,37 +799,80 @@ static void kvaser_usb_unlink_tx_urbs(struct kvaser_usb_net_priv *priv)
> >  		priv->tx_contexts[i].echo_index = MAX_TX_URBS;
> >  }
> >  
> > -static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
> > -				const struct kvaser_msg *msg)
> > +static void kvaser_report_error_event(const struct kvaser_usb *dev,
> > +				      struct kvaser_error_summary *es);
> 
> Please rearange your code that forward declarations are not needed (if
> possible - I haven't checked, though).
> 

I originally did it that way, but it completely messed up with the
patch if I do such rearrangement. A huge block of code gets removed
at top of the patch, and it got added again at the end, making the
actual important lines changed _within_ such big block non-apparent.

Maybe I should do the re-arrangement in a follow-up patch?

> > +
> > +/* Report error to userspace iff the controller's errors counter has
> > + * increased, or we're the only channel seeing the bus error state.
> > + *
> > + * As reported by USBCAN sheets, "the CAN controller has difficulties
> > + * to tell whether an error frame arrived on channel 1 or on channel 2."
> > + * Thus, error counters are compared with their earlier values to
> > + * determine which channel was responsible for the error event.
> 
> Your code doesn't match this comment. You compare the error counters
> against the old values to tell if it's a rx or tx error, the channel
> information from the struct kvaser_error_summary is used directly.
> 

Hmmm, good catch, upon a second look, the code looks a bit deceiving.
The comments, meanwhile, are taken verbatim from the Kvaser sheets:

  http://www.kvaser.com/canlib-webhelp/page_hardware_specific_can_controllers.html
  Archived at http://www.webcitation.org/6VQd87jIA

So, what happens is that the firmware does not tell us whether the
received error event is for ch0 or ch1. But it gives us the (possibly
new) error counters for both of them:

struct usbcan_msg_error_event {
        [..]
        u8 tx_errors_count_ch0;
        u8 rx_errors_count_ch0;
        u8 tx_errors_count_ch1;
        u8 rx_errors_count_ch1;
	[..]
} __packed;

We loop over each channel, and report an error to userspace if extra
errors were spotted for such channel.

kvaser_error_summary is not a firmware command or response. Since
the wire format for an error event differs between Leaf and Usbcan,
it's just our way to summarize an error whether it's from any of
them, and this is where the conflict stems from:

- If it's a Leaf-device, `error_summary->channel' is the excat
channel reported by the firmware
- If it's a Usbcan device, `error_summary->channel' is just a mark
to check the error counters for such a channel and report error
to userspace iff they've increased.

Thus the raison d'etre for `error_summary' struct is to share
the error handling code between Leaf and UsbcanII devices since
it's quite similar.

So to clear up this conflict, I suggest the following error_summary
layout:

struct kvaser_error_summary {
       union {
                struct {
                       u8 channel;
                } leaf;
                struct {
                       u8 possible_channel;
                } usbcan;
       };
       /* Rest of layout is left as-is */
}

This way, it's clear that in case of Usbcan, channel is not final
and we need further work to do. What do you think?

(BTW, any better name than "kvaser_error_summary"? It conflicts a
little bit with the namespace used for the packed wire format
structures "kvaser_*")

> > + */
> > +static void usbcan_report_error_if_applicable(const struct kvaser_usb *dev,
> > +					      struct kvaser_error_summary *es)
> 
> Nitpick: can you please add a "kvaser_" prefix to the all usbcan_* and
> leaf_* functions.
> 

Will do.

> >  {
> > -	struct can_frame *cf;
> > -	struct sk_buff *skb;
> > -	struct net_device_stats *stats;
> >  	struct kvaser_usb_net_priv *priv;
> > -	unsigned int new_state;
> > -	u8 channel, status, txerr, rxerr, error_factor;
> > +	int old_tx_err_count, old_rx_err_count, channel, report_error;
> 
> bool report_error;
> 

Will do.

> > +
> > +	channel = es->channel;
> > +	if (channel >= dev->nchannels) {
> > +		dev_err(dev->udev->dev.parent,
> > +			"Invalid channel number (%d)\n", channel);
> > +		return;
> > +	}
> > +
> > +	priv = dev->nets[channel];
> > +	old_tx_err_count = priv->bec.txerr;
> > +	old_rx_err_count = priv->bec.rxerr;
> 
> Why do you make a copy of priv->bec, AFAICS you can use
> priv->bec.{r,t}xerr directly?
> 

Initially, just for clarity, as I was not used yet to socketCAN
structures ;-) will remove it in the next submission.

> > +
> > +	report_error = 0;
> > +	if (es->txerr > old_tx_err_count) {
> > +		es->usbcan.error_state |= USBCAN_ERROR_STATE_TX_ERROR;
> > +		report_error = 1;
> > +	}
> > +	if (es->rxerr > old_rx_err_count) {
> > +		es->usbcan.error_state |= USBCAN_ERROR_STATE_RX_ERROR;
> > +		report_error = 1;
> > +	}
> > +	if ((es->status & M16C_STATE_BUS_ERROR) &&
> > +	    !(es->usbcan.other_ch_status & M16C_STATE_BUS_ERROR)) {
> > +		es->usbcan.error_state |= USBCAN_ERROR_STATE_BUSERROR;
> > +		report_error = 1;
> > +	}
> > +
> > +	if (report_error)
> > +		kvaser_report_error_event(dev, es);
> > +}
> > +
> > +/* Extract error summary from a Leaf-based device error message */
> > +static void leaf_extract_error_from_msg(const struct kvaser_usb *dev,
> > +					const struct kvaser_msg *msg)
> > +{
> > +	struct kvaser_error_summary es = { 0, };
> 
> IIRC "es = { };" should be sufficient.
> 

Correct, will do.

> >  
> >  	switch (msg->id) {
> >  	case CMD_CAN_ERROR_EVENT:
> > -		channel = msg->u.error_event.channel;
> > -		status =  msg->u.error_event.status;
> > -		txerr = msg->u.error_event.tx_errors_count;
> > -		rxerr = msg->u.error_event.rx_errors_count;
> > -		error_factor = msg->u.error_event.error_factor;
> > +		es.channel = msg->u.leaf.error_event.channel;
> > +		es.status =  msg->u.leaf.error_event.status;
> > +		es.txerr = msg->u.leaf.error_event.tx_errors_count;
> > +		es.rxerr = msg->u.leaf.error_event.rx_errors_count;
> > +		es.leaf.error_factor = msg->u.leaf.error_event.error_factor;
> >  		break;
> > -	case CMD_LOG_MESSAGE:
> > -		channel = msg->u.log_message.channel;
> > -		status = msg->u.log_message.data[0];
> > -		txerr = msg->u.log_message.data[2];
> > -		rxerr = msg->u.log_message.data[3];
> > -		error_factor = msg->u.log_message.data[1];
> > +	case CMD_LEAF_LOG_MESSAGE:
> > +		es.channel = msg->u.leaf.log_message.channel;
> > +		es.status = msg->u.leaf.log_message.data[0];
> > +		es.txerr = msg->u.leaf.log_message.data[2];
> > +		es.rxerr = msg->u.leaf.log_message.data[3];
> > +		es.leaf.error_factor = msg->u.leaf.log_message.data[1];
> >  		break;
> >  	case CMD_CHIP_STATE_EVENT:
> > -		channel = msg->u.chip_state_event.channel;
> > -		status =  msg->u.chip_state_event.status;
> > -		txerr = msg->u.chip_state_event.tx_errors_count;
> > -		rxerr = msg->u.chip_state_event.rx_errors_count;
> > -		error_factor = 0;
> > +		es.channel = msg->u.leaf.chip_state_event.channel;
> > +		es.status =  msg->u.leaf.chip_state_event.status;
> > +		es.txerr = msg->u.leaf.chip_state_event.tx_errors_count;
> > +		es.rxerr = msg->u.leaf.chip_state_event.rx_errors_count;
> > +		es.leaf.error_factor = 0;
> >  		break;
> >  	default:
> >  		dev_err(dev->udev->dev.parent, "Invalid msg id (%d)\n",
> > @@ -653,16 +880,92 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
> >  		return;
> >  	}
> >  
> > -	if (channel >= dev->nchannels) {
> > +	kvaser_report_error_event(dev, &es);
> > +}
> > +
> > +/* Extract error summary from a USBCANII-based device error message */
> > +static void usbcan_extract_error_from_msg(const struct kvaser_usb *dev,
> > +					  const struct kvaser_msg *msg)
> > +{
> > +	struct kvaser_error_summary es = { 0, };
> 
> same here.
> 

Ditto.

> > +
> > +	switch (msg->id) {
> > +	/* Sometimes errors are sent as unsolicited chip state events */
> > +	case CMD_CHIP_STATE_EVENT:
> > +		es.channel = msg->u.usbcan.chip_state_event.channel;
> > +		es.status =  msg->u.usbcan.chip_state_event.status;
> > +		es.txerr = msg->u.usbcan.chip_state_event.tx_errors_count;
> > +		es.rxerr = msg->u.usbcan.chip_state_event.rx_errors_count;
> > +		usbcan_report_error_if_applicable(dev, &es);
> > +		break;
> > +
> > +	case CMD_CAN_ERROR_EVENT:
> > +		es.channel = 0;
> > +		es.status = msg->u.usbcan.error_event.status_ch0;
> > +		es.txerr = msg->u.usbcan.error_event.tx_errors_count_ch0;
> > +		es.rxerr = msg->u.usbcan.error_event.rx_errors_count_ch0;
> > +		es.usbcan.other_ch_status =
> > +			msg->u.usbcan.error_event.status_ch1;
> > +		usbcan_report_error_if_applicable(dev, &es);
> > +
> > +		/* For error events, the USBCAN firmware does not support
> > +		 * more than 2 channels: ch0, and ch1.
> > +		 */
> > +		if (dev->nchannels > 1) {
> > +			es.channel = 1;
> 
> Why is channel == 1 if the device has more than 1 channel?
> 

This is related to the "kvaser_error_summary" discussion above
where "channel" is only a suggestion for checking the error
counters.

If the Usbcan device has only one channel, then there's no need
to check if the "tx_errors_count_ch1", "rx_errors_count_ch1" has
increased or not. Their values are undefined.

> > +			es.status = msg->u.usbcan.error_event.status_ch1;
> > +			es.txerr =
> > +				msg->u.usbcan.error_event.tx_errors_count_ch1;
> > +			es.rxerr =
> > +				msg->u.usbcan.error_event.rx_errors_count_ch1;
> > +			es.usbcan.other_ch_status =
> > +				msg->u.usbcan.error_event.status_ch0;
> > +			usbcan_report_error_if_applicable(dev, &es);
> > +		}
> > +		break;
> > +
> > +	default:
> > +		dev_err(dev->udev->dev.parent, "Invalid msg id (%d)\n",
> > +			msg->id);
> > +	}
> > +}
> > +
> > +static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
> > +				const struct kvaser_msg *msg)
> > +{
> > +	switch (dev->family) {
> > +	case KVASER_LEAF:
> > +		leaf_extract_error_from_msg(dev, msg);
> > +		break;
> > +	case KVASER_USBCAN:
> > +		usbcan_extract_error_from_msg(dev, msg);
> > +		break;
> > +	default:
> should not happen.

Yes. As in above, will wait your input in this regarding the checks
being defensive.

[...]
> > +	case KVASER_USBCAN:
> > +		if (es->usbcan.error_state & USBCAN_ERROR_STATE_TX_ERROR)
> > +			stats->tx_errors++;
> > +		if (es->usbcan.error_state & USBCAN_ERROR_STATE_RX_ERROR)
> > +			stats->rx_errors++;
> > +		if (es->usbcan.error_state & USBCAN_ERROR_STATE_BUSERROR) {
> > +			priv->can.can_stats.bus_error++;
> > +			cf->can_id |= CAN_ERR_BUSERROR;
> > +		}
> > +		break;
> > +	default:
> > +		dev_err(dev->udev->dev.parent,
> > +			"Invalid device family (%d)\n", dev->family);
> > +		goto err;
> 
> should not happen.
> 

Ditto.

> >  	}
> >  
> > -	cf->data[6] = txerr;
> > -	cf->data[7] = rxerr;
> > +	cf->data[6] = es->txerr;
> > +	cf->data[7] = es->rxerr;
> >  
> > -	priv->bec.txerr = txerr;
> > -	priv->bec.rxerr = rxerr;
> > +	priv->bec.txerr = es->txerr;
> > +	priv->bec.rxerr = es->rxerr;
> >  
> >  	priv->can.state = new_state;
> >  
> > @@ -774,6 +1093,11 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
> >  
> >  	stats->rx_packets++;
> >  	stats->rx_bytes += cf->can_dlc;
> > +
> > +	return;
> > +
> > +err:
> > +	dev_kfree_skb(skb);
> >  }
> >  
> >  static void kvaser_usb_rx_can_err(const struct kvaser_usb_net_priv *priv,
> > @@ -783,16 +1107,16 @@ static void kvaser_usb_rx_can_err(const struct kvaser_usb_net_priv *priv,
> >  	struct sk_buff *skb;
> >  	struct net_device_stats *stats = &priv->netdev->stats;
> >  
> > -	if (msg->u.rx_can.flag & (MSG_FLAG_ERROR_FRAME |
> > +	if (msg->u.rx_can_header.flag & (MSG_FLAG_ERROR_FRAME |
> >  					 MSG_FLAG_NERR)) {
> >  		netdev_err(priv->netdev, "Unknow error (flags: 0x%02x)\n",
> > -			   msg->u.rx_can.flag);
> > +			   msg->u.rx_can_header.flag);
> >  
> >  		stats->rx_errors++;
> >  		return;
> >  	}
> >  
> > -	if (msg->u.rx_can.flag & MSG_FLAG_OVERRUN) {
> > +	if (msg->u.rx_can_header.flag & MSG_FLAG_OVERRUN) {
> >  		skb = alloc_can_err_skb(priv->netdev, &cf);
> > 		if (!skb) {
> > 			stats->rx_dropped++;
> > 			return;
> > 		}
> 
> Can you prepare a (seperate) patch that does the stats, even in case of OOM here. Same for kvaser_report_error_event()

Sure.

In kvaser_report_error_event() though, isn't it a little bit tricky?
Specially in fragments as in below:

        switch (dev->family) {
        case KVASER_LEAF:
                if (es->leaf.error_factor) {
                        priv->can.can_stats.bus_error++;
                        stats->rx_errors++;

                        cf->can_id |= CAN_ERR_BUSERROR | CAN_ERR_PROT;
                        [...]
                }
                break;
        case KVASER_USBCAN:
                if (es->usbcan.error_state & USBCAN_ERROR_STATE_TX_ERROR)
                        stats->tx_errors++;
                if (es->usbcan.error_state & USBCAN_ERROR_STATE_RX_ERROR)
                        stats->rx_errors++;
                if (es->usbcan.error_state & USBCAN_ERROR_STATE_BUSERROR) {
                        priv->can.can_stats.bus_error++;
                        cf->can_id |= CAN_ERR_BUSERROR;
                }
                break;
        }

IMHO, there will be some duplication of the above fragment. Once
to handle "stats->*", and once to handle packet-related "cf->*" stuff.
Also in the Usbcan case, it will clutter the error_state checks in
different places.

> 
> > 
> > 		cf->can_id |= CAN_ERR_CRTL;
> > 		cf->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
> > 
> > 		stats->rx_over_errors++;
> > 		stats->rx_errors++;
> > 
> > 		netif_rx(skb);
> > 
> > 		stats->rx_packets++;
> > 		stats->rx_bytes += cf->can_dlc;
> 
> Another patch would be not to touch cf after netif_rx(), please move the stats handling before calling netif_rx(). Same applies to the kvaser_usb_rx_can_msg() function.
> 

Indeed, these can be totally bogus values after netif_rx().
I'll introduce this as a new patch in a new series.

Thanks for your review!

Regards,
Darwish
