From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] can: kvaser_usb: Add support for Kvaser CAN/USB devices
Date: Sun, 05 Aug 2012 22:41:10 +0200
Message-ID: <501EDA66.4090708@grandegger.com>
References: <1343626352-24760-1-git-send-email-olivier@sobrie.be> <50166BF2.9000700@pengutronix.de> <20120730133323.GA13941@hposo> <5017ABC6.7030307@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Olivier Sobrie <olivier@sobrie.be>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5017ABC6.7030307@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/31/2012 11:56 AM, Marc Kleine-Budde wrote:
> On 07/30/2012 03:33 PM, Olivier Sobrie wrote:
...

>>>> +static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>>>> +				const struct kvaser_msg *msg)
>>>> +{
>>>> +	struct can_frame *cf;
>>>> +	struct sk_buff *skb;
>>>> +	struct net_device_stats *stats;
>>>> +	struct kvaser_usb_net_priv *priv;
>>>> +	u8 channel, status, txerr, rxerr;
>>>> +
>>>> +	if (msg->id == CMD_CAN_ERROR_EVENT) {
>>>> +		channel = msg->u.error_event.channel;
>>>> +		status =  msg->u.error_event.status;
>>>> +		txerr = msg->u.error_event.tx_errors_count;
>>>> +		rxerr = msg->u.error_event.rx_errors_count;
>>>> +	} else {
>>>> +		channel = msg->u.chip_state_event.channel;
>>>> +		status =  msg->u.chip_state_event.status;
>>>> +		txerr = msg->u.chip_state_event.tx_errors_count;
>>>> +		rxerr = msg->u.chip_state_event.rx_errors_count;
>>>> +	}
>>>> +
>>>> +	if (channel >= dev->nchannels) {
>>>> +		dev_err(dev->udev->dev.parent,
>>>> +			"Invalid channel number (%d)\n", channel);
>>>> +		return;
>>>> +	}
>>>> +
>>>> +	priv = dev->nets[channel];
>>>> +	stats = &priv->netdev->stats;
>>>> +
>>>> +	skb = alloc_can_err_skb(priv->netdev, &cf);
>>>> +	if (!skb) {
>>>> +		stats->rx_dropped++;
>>>> +		return;
>>>> +	}
>>>> +
>>>> +	if ((status & M16C_STATE_BUS_OFF) ||
>>>> +	    (status & M16C_STATE_BUS_RESET)) {
>>>> +		priv->can.state = CAN_STATE_BUS_OFF;
>>>> +		cf->can_id |= CAN_ERR_BUSOFF;
>>>> +		can_bus_off(priv->netdev);
> 
> you should increment priv->can.can_stats.bus_off

No, already done in can_bus_off():

  http://lxr.free-electrons.com/source/drivers/net/can/dev.c#L439

Wolfgang.
