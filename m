From: Olivier Sobrie <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH v2] can: kvaser_usb: Add support for Kvaser CAN/USB
 devices
Date: Wed, 8 Aug 2012 15:30:05 +0200
Message-ID: <20120808133005.GA14300@hposo>
References: <1343626352-24760-1-git-send-email-olivier@sobrie.be>
 <1344230489-16595-1-git-send-email-olivier@sobrie.be>
 <5020B51E.8060600@grandegger.com>
 <20120808061419.GA16678@hposo>
 <5022227F.60800@grandegger.com>
Reply-To: Olivier Sobrie <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5022227F.60800-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 08, 2012 at 10:25:35AM +0200, Wolfgang Grandegger wrote:
> Hi Oliver,
> 
> On 08/08/2012 08:14 AM, Olivier Sobrie wrote:
> > Hi Wolfgang,
> > 
> > On Tue, Aug 07, 2012 at 08:26:38AM +0200, Wolfgang Grandegger wrote:
> >> On 08/06/2012 07:21 AM, Olivier Sobrie wrote:
> >>> This driver provides support for several Kvaser CAN/USB devices.
> >>> Such kind of devices supports up to three can network interfaces.
> >>
> >> s/can/CAN/
> >>
> >>> It has been tested with a Kvaser USB Leaf Light (one network interface)
> >>> connected to a pch_can interface.
> >>> The firmware version of the Kvaser device was 2.5.205.
> >>>
> >>> List of Kvaser devices supported by the driver:
> >>>   - Kvaser Leaf prototype (P010v2 and v3)
> >>>   - Kvaser Leaf Light (P010v3)
> >>>   - Kvaser Leaf Professional HS
> >>>   - Kvaser Leaf SemiPro HS
> >>>   - Kvaser Leaf Professional LS
> >>>   - Kvaser Leaf Professional SWC
> >>>   - Kvaser Leaf Professional LIN
> >>>   - Kvaser Leaf SemiPro LS
> >>>   - Kvaser Leaf SemiPro SWC
> >>>   - Kvaser Memorator II, Prototype
> >>>   - Kvaser Memorator II HS/HS
> >>>   - Kvaser USBcan Professional HS/HS
> >>>   - Kvaser Leaf Light GI
> >>>   - Kvaser Leaf Professional HS (OBD-II connector)
> >>>   - Kvaser Memorator Professional HS/LS
> >>>   - Kvaser Leaf Light "China"
> >>>   - Kvaser BlackBird SemiPro
> >>>   - Kvaser OEM Mercury
> >>>   - Kvaser OEM Leaf
> >>>   - Kvaser USBcan R
> >>
> >> Impressive list! What CAN controllers are used inside the devices? SJA1000?
> > 
> > I took this list from the Kvaser driver. However I only have a Kvaser
> > Leaf Light device thus I'm not sure it will work with other ones.
> > If you prefer I can only let Kvaser Leaf Light instead of the full list.
> > In my device it looks to be a Renesas M16C controller.
> 
> OK. Checking the manual, if available, could help to understand how the
> firmware handles bus errors and state changes.

Ok I'll try to find it.

> 
> >>> Signed-off-by: Olivier Sobrie <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
> >>> ---
> >>> Changes since v1:
> >>>   - added copyrights
> >>>   - kvaser_usb.h merged into kvaser.c
> >>>   - added kvaser_usb_get_endpoints to find eindpoints instead of
> >>>     hardcoding their address
> >>>   - some cleanup and comestic changes
> >>>   - fixed issues with errors handling
> >>>   - fixed restart-ms == 0 case
> >>>   - removed do_get_berr_counter method since the hardware doens't return
> >>>     good values for txerr and rxerr.
> >>>
> >>> If someone in the linux-usb mailing can review it, it would be nice.
> >>>
> >>> Concerning the errors, it behaves like that now:
> >>>
> >>> 1) Short-circuit CAN-H and CAN-L and restart-ms = 0
> >>>
> >>> t0: short-circuit + 'cansend can1 123#112233'
> >>>
> >>>   can1  2000008C  [8] 00 0C 90 00 00 00 00 00   ERRORFRAME
> >>> 	controller-problem{rx-error-warning,tx-error-warning}
> >>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >>> 	bus-error
> >>>   can1  2000008C  [8] 00 30 90 00 00 00 00 00   ERRORFRAME
> >>> 	controller-problem{rx-error-passive,tx-error-passive}
> >>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >>> 	bus-error
> >>>   can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
> >>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >>> 	bus-off
> >>> 	bus-error
> >>>
> >>> t1: remove short-circuit + 'ip link set can1 type can restart'
> >>>
> >>>   can1  20000100  [8] 00 00 00 00 00 00 00 00   ERRORFRAME
> >>> 	restarted-after-bus-off
> >>>   can1  20000004  [8] 00 0C 00 00 00 00 00 00   ERRORFRAME
> >>> 	controller-problem{rx-error-warning,tx-error-warning}
> >>
> >> Why do we get the last error message? Maybe the firmware does it that
> >> way (going down passive->warning->active).
> > 
> > It goes in that order: warning -> passive -> bus off -> warning
> > -> passive -> ...
> 
> Just for curiosity? You don't see back to "error active"?

No but that's maybe because of my misunderstanding of the
M16C_STATE_BUS_ERROR flag.
What I see is:
t1: M16C_STATE_BUS_ERROR
t2: M16C_STATE_BUS_ERROR | M16C_STATE_BUS_PASSIVE
t3: M16C_STATE_BUS_ERROR | M16C_STATE_BUS_OFF
and then again
t4: M16C_STATE_BUS_ERROR
t2: M16C_STATE_BUS_ERROR | M16C_STATE_BUS_PASSIVE
t3: M16C_STATE_BUS_ERROR | M16C_STATE_BUS_OFF

Thus as you suggested below, the flag M16C_STATE_BUS_ERROR might not mean
CAN_STATE_ERROR_WARNING...

> 
> >>> 2) Short-circuit CAN-H and CAN-L and restart-ms = 100
> >>>
> >>> t0: short-circuit + cansend can1 123#112233
> >>>
> >>>   can1  2000008C  [8] 00 0C 90 00 00 00 00 00   ERRORFRAME
> >>> 	controller-problem{rx-error-warning,tx-error-warning}
> >>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >>> 	bus-error
> >>>   can1  2000008C  [8] 00 30 90 00 00 00 00 00   ERRORFRAME
> >>> 	controller-problem{rx-error-passive,tx-error-passive}
> >>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >>> 	bus-error
> >>>   can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
> >>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >>> 	bus-off
> >>> 	bus-error
> >>>   can1  2000018C  [8] 00 0C 90 00 00 00 00 00   ERRORFRAME
> >>> 	controller-problem{rx-error-warning,tx-error-warning}
> >>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >>> 	bus-error
> >>> 	restarted-after-bus-off
> >>>   can1  2000008C  [8] 00 0C 90 00 00 00 00 00   ERRORFRAME
> >>> 	controller-problem{rx-error-warning,tx-error-warning}
> >>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >>> 	bus-error
> >>>   can1  2000008C  [8] 00 30 90 00 00 00 00 00   ERRORFRAME
> >>> 	controller-problem{rx-error-passive,tx-error-passive}
> >>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >>> 	bus-error
> >>>   can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
> >>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >>> 	bus-off
> >>> 	bus-error
> >>>   ...
> >>>
> >>>   can1  2000018C  [8] 00 0C 90 00 00 00 00 00   ERRORFRAME
> >>> 	controller-problem{rx-error-warning,tx-error-warning}
> >>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >>> 	bus-error
> >>> 	restarted-after-bus-off
> >>>   can1  2000008C  [8] 00 0C 90 00 00 00 00 00   ERRORFRAME
> >>> 	controller-problem{rx-error-warning,tx-error-warning}
> >>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >>> 	bus-error
> >>>   can1  2000008C  [8] 00 30 90 00 00 00 00 00   ERRORFRAME
> >>> 	controller-problem{rx-error-passive,tx-error-passive}
> >>> 	protocol-violation{{tx-recessive-bit-error,error-on-tx}{}}
> >>> 	bus-error
> >>>
> >>> t1: remove short-circuit
> >>>
> >>>   can1  123  [3] 11 22 33
> >>>   can1  20000008  [8] 00 00 40 00 00 00 00 00   ERRORFRAME
> >>> 	protocol-violation{{back-to-error-active}{}}
> >>
> >> The order is still inverted but likely the firmware is doing it that way.
> > 
> > Indeed the firmware does it that way: it sends the acknwledge of the
> > frame beofre the state change. I can avoid that behavior by checking the
> > state in the acknowledge frame and send the restart frame if the bus was
> > off.
> 
> Well, if the firmware does it wrong, I would not really care. Also,
> could you use timestamping to see if they come close together.

candump can1,0:0,#FFFFFFFF -td -e:
 (001.369850)  can1  123  [3] 11 22 33
 (004.716034)  can1  20000008  [8] 00 00 40 00 00 00 00 00   ERRORFRAME
	protocol-violation{{back-to-error-active}{}}

Not so close... I'll add something in the tx acknowledge.

> 
> >>> 3) CAN-H and CAN-L disconnected
> >>>
> >>> t0: CAN-H and CAN-L disconnected + cansend can1 123#112233
> >>>
> >>>   can1  20000004  [8] 00 30 00 00 00 00 00 00   ERRORFRAME
> >>> 	controller-problem{rx-error-passive,tx-error-passive}
> >>>   can1  2000008C  [8] 00 30 80 1B 00 00 00 00   ERRORFRAME
> >>> 	controller-problem{rx-error-passive,tx-error-passive}
> >>> 	protocol-violation{{error-on-tx}{acknowledge-delimiter}}
> >>> 	bus-error
> >>>
> >>> t1: CAN-H and CAN-L reconnected
> >>>
> >>>   can1  123  [3] 11 22 33
> >>>   can1  20000004  [8] 00 30 00 00 00 00 00 00   ERRORFRAME
> >>> 	controller-problem{rx-error-passive,tx-error-passive}
> >>
> >> Why do we get an error-passive message? Now I will have a closer look to
> >> the code...
> > 
> > The firmware sends a CMD_CAN_ERROR_EVENT with the passive bit set...
> 
> Maybe the order is again inverted. Do they come at the same time
> (visiable with candump -td).

 (002.465349)  can1  123  [3] 11 22 33
 (004.562670)  can1  20000004  [8] 00 30 00 00 00 00 00 00   ERRORFRAME
	controller-problem{rx-error-passive,tx-error-passive}

> 
> >>> +static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
> >>> +				const struct kvaser_msg *msg)
> >>> +{
> >>> +	struct can_frame *cf;
> >>> +	struct sk_buff *skb;
> >>> +	struct net_device_stats *stats;
> >>> +	struct kvaser_usb_net_priv *priv;
> >>> +	unsigned int new_state;
> >>> +	u8 channel, status;
> >>> +
> >>> +	if (msg->id == CMD_CAN_ERROR_EVENT) {
> >>> +		channel = msg->u.error_event.channel;
> >>> +		status =  msg->u.error_event.status;
> >>> +	} else {
> >>> +		channel = msg->u.chip_state_event.channel;
> >>> +		status =  msg->u.chip_state_event.status;
> >>> +	}
> >>> +
> >>> +	if (channel >= dev->nchannels) {
> >>> +		dev_err(dev->udev->dev.parent,
> >>> +			"Invalid channel number (%d)\n", channel);
> >>> +		return;
> >>> +	}
> >>> +
> >>> +	priv = dev->nets[channel];
> >>> +	stats = &priv->netdev->stats;
> >>> +
> >>> +	if (status & M16C_STATE_BUS_RESET) {
> >>> +		kvaser_usb_unlink_tx_urbs(priv);
> >>> +		return;
> >>> +	}
> >>> +	skb = alloc_can_err_skb(priv->netdev, &cf);
> >>> +	if (!skb) {
> >>> +		stats->rx_dropped++;
> >>> +		return;
> >>
> >> Cleanup? kvaser_usb_unlink_tx_urbs()?
> > 
> > If I get the M16C_STATE_BUS_RESET I'll not receive the ack frames anymore.
> > I need to set the context->echo_index back to MAX_TX_URBS to not loose tx
> > urbs.
> > By the way I think a can_free_echo_skb() is missing...
> > 
> >>
> >>> +	}
> >>> +
> >>> +	if (status & M16C_STATE_BUS_OFF) {
> >>> +		cf->can_id |= CAN_ERR_BUSOFF;
> >>> +
> >>> +		if (!priv->can.restart_ms)
> >>> +			kvaser_usb_simple_msg_async(priv, CMD_STOP_CHIP);
> >>> +
> >>> +		if (!priv->can.state != CAN_ERR_BUSOFF) {
> >>> +			priv->can.can_stats.bus_off++;
> >>> +			netif_carrier_off(priv->netdev);
> >>> +		}
> >>> +
> >>> +		new_state = CAN_STATE_BUS_OFF;
> >>> +	} else if (status & M16C_STATE_BUS_PASSIVE) {
> >>> +		cf->can_id |= CAN_ERR_CRTL;
> >>> +		cf->data[1] = CAN_ERR_CRTL_TX_PASSIVE |
> >>> +			      CAN_ERR_CRTL_RX_PASSIVE;
> >>
> >> State changes should only be report when the state really changes.
> >> Therefore it should go under the if block below.
> > 
> > Ok. Is it possible to get such sequence:
> > can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
> > can1  20000088  [8] 00 10 90 00 00 00 00 00   ERRORFRAME
> > can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
> > can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
> > can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
> > 
> > 2 questions:
> > 1) If the bus is still in CAN_ERR_CRTL_RX_PASSIVE after the second frame,
> >    shouldn't we let the corresponding bit set, 0x10?
> 
> No, see below.
> 
> > 2) Can we send multiple times same frame wih same error bits set?
> 
> Yes, because that's what the hardware reports.
> 
> >>
> >>> +		if (priv->can.state != CAN_STATE_ERROR_PASSIVE)
> >>> +			priv->can.can_stats.error_passive++;
> >>> +
> >>> +		new_state = CAN_STATE_ERROR_PASSIVE;
> >>> +	} else if (status & M16C_STATE_BUS_ERROR) {
> >>
> >> Hm, strange, a bus error is not a state change. You use here if...else
> >> if... Isn't it possible that more than one bit is set.
> > 
> > Indeed it is possible to have multiple bits set.
> > e.g. M16C_STATE_BUS_PASSIVE + M16C_STATE_BUS_ERROR or M16C_STATE_BUS_OFF + M16C_STATE_BUS_ERROR.
> 
> OK, that's the normal behaviour. Obviously they send bus errors together
> with the *actual* state. The hardware does usuallly report bus errors
> frequently while the error condition persists.
> 
> > What error should I report in case of M16C_STATE_BUS_ERROR?
> 
> To make that clear, I have added an (old) output from the SJA1000, which
> is the defacto reference. Bus error reporting is enabled and no cable is
> connected. Watch the TX error count increasing and how the state changes:

With my hardware I do not get txerr and rxerr... I only get
M16C_STATE_BUS_ERROR. Thus in fact I can only pass from ACTIVE to PASSIVE
without reaching the WARNING state.

People of Kvaser just told me txerr and rxerr was set with other hardwares
than Kvaser Leaf Lighti... That's the one I've... I'm unlucky :-(.
I'll adapt the code so that txerr and rxerr are reported for working
hardwares..

> 
>   $ ./candump -e 0xffff any
>   can0  20000088  [8] 00 00 80 19 00 08 00 00   ERRORFRAME
>                \             \  \-- ACK slot.
>                 \             \-- error occured on transmission
>                  \-- Bus-error | Protocol violations (data[2], data[3]).
> 
>   can0  20000088  [8] 00 00 80 19 00 10 00 00   ERRORFRAME
>   can0  20000088  [8] 00 00 80 19 00 18 00 00   ERRORFRAME
>   can0  20000088  [8] 00 00 80 19 00 20 00 00   ERRORFRAME
>   can0  20000088  [8] 00 00 80 19 00 28 00 00   ERRORFRAME
>   can0  20000088  [8] 00 00 80 19 00 30 00 00   ERRORFRAME
>   can0  20000088  [8] 00 00 80 19 00 38 00 00   ERRORFRAME
>   can0  20000088  [8] 00 00 80 19 00 40 00 00   ERRORFRAME
>   can0  20000088  [8] 00 00 80 19 00 48 00 00   ERRORFRAME
>   can0  20000088  [8] 00 00 80 19 00 50 00 00   ERRORFRAME
>   can0  20000088  [8] 00 00 80 19 00 58 00 00   ERRORFRAME
>   can0  2000008C  [8] 00 08 80 19 00 60 00 00   ERRORFRAME
>                \          \--  reached warning level for TX errors
>                 \-- | Controller problems (see data[1]).
> 
>   can0  20000088  [8] 00 00 80 19 00 68 00 00   ERRORFRAME
>   can0  20000088  [8] 00 00 80 19 00 70 00 00   ERRORFRAME
>   can0  20000088  [8] 00 00 80 19 00 78 00 00   ERRORFRAME
>   can0  2000008C  [8] 00 20 80 19 00 80 00 00   ERRORFRAME
>                \          \--   reached passive level for TX errors
>                 \-- | Controller problems (see data[1]).
> 
>   can0  20000088  [8] 00 00 80 19 00 80 00 00   ERRORFRAME
>                                       \  \-- RXerror count
>                                        \-- TXerror count
> 
>   can0  20000088  [8] 00 00 80 19 00 80 00 00   ERRORFRAME
>   ...
>   can0  20000088  [8] 00 00 80 19 00 80 00 00   ERRORFRAME

Ok. I'll only set CAN_ERR_PROT_LOC_ACK and not CAN_ERR_PROT_LOC_DEL.

> 
> 
> > 
> >>
> >>> +		cf->can_id |= CAN_ERR_CRTL;
> >>> +		cf->data[1] = CAN_ERR_CRTL_TX_WARNING |
> >>> +			      CAN_ERR_CRTL_RX_WARNING;
> >>
> >> See above.
> >>
> >>> +		if (priv->can.state != CAN_STATE_ERROR_WARNING)
> >>> +			priv->can.can_stats.error_warning++;
> >>> +
> >>> +		new_state = CAN_STATE_ERROR_WARNING;
> >>> +	} else {
> >>> +		cf->can_id |= CAN_ERR_PROT;
> >>> +		cf->data[2] = CAN_ERR_PROT_ACTIVE;
> >>> +
> >>> +		new_state = CAN_STATE_ERROR_ACTIVE;
> >>> +	}
> >>> +
> >>> +	if (priv->can.restart_ms &&
> >>> +	    (priv->can.state >= CAN_STATE_BUS_OFF) &&
> >>> +	    (new_state < CAN_STATE_BUS_OFF)) {
> >>> +		cf->can_id |= CAN_ERR_RESTARTED;
> >>> +		priv->can.can_stats.restarts++;
> >>> +		netif_carrier_on(priv->netdev);
> >>> +	}
> >>> +
> >>> +	if (msg->id == CMD_CAN_ERROR_EVENT) {
> >>> +		u8 error_factor = msg->u.error_event.error_factor;
> >>> +
> >>> +		priv->can.can_stats.bus_error++;
> >>> +		stats->rx_errors++;
> >>> +
> >>> +		cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
> >>> +
> >>> +		if (error_factor & M16C_EF_ACKE)
> >>> +			cf->data[3] |= (CAN_ERR_PROT_LOC_ACK |
> >>> +					CAN_ERR_PROT_LOC_ACK_DEL);
> >>> +		if (error_factor & M16C_EF_CRCE)
> >>> +			cf->data[3] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
> >>> +					CAN_ERR_PROT_LOC_CRC_DEL);
> >>> +		if (error_factor & M16C_EF_FORME)
> >>> +			cf->data[2] |= CAN_ERR_PROT_FORM;
> >>> +		if (error_factor & M16C_EF_STFE)
> >>> +			cf->data[2] |= CAN_ERR_PROT_STUFF;
> >>> +		if (error_factor & M16C_EF_BITE0)
> >>> +			cf->data[2] |= CAN_ERR_PROT_BIT0;
> >>> +		if (error_factor & M16C_EF_BITE1)
> >>> +			cf->data[2] |= CAN_ERR_PROT_BIT1;
> >>> +		if (error_factor & M16C_EF_TRE)
> >>> +			cf->data[2] |= CAN_ERR_PROT_TX;
> >>> +	}
> >>> +
> >>> +	priv->can.state = new_state;
> >>> +
> >>> +	if (!memcmp(cf, &priv->cf_err_old, sizeof(*cf))) {
> >>> +		kfree_skb(skb);
> >>> +		return;
> >>> +	}
> >>
> >> Hm, the firmware seems not to clear error conditions? Anyway, state
> >> change and error reporting is magic on many CAN controllers. Just the
> >> SJA1000 is doing it nicely.
> > 
> > I added it to prevent sending two times the same error. It happens that
> > the firmware sends multiple times the same error message.
> 
> Can then be removed, I think, see above.

Ok.

> 
> >>
> >>> +	netif_rx(skb);
> >>> +
> >>> +	priv->cf_err_old = *cf;
> >>> +
> >>> +	stats->rx_packets++;
> >>> +	stats->rx_bytes += cf->can_dlc;
> >>> +}
> >>> +
> >>> +static void kvaser_usb_rx_can_msg(const struct kvaser_usb *dev,
> >>> +				  const struct kvaser_msg *msg)
> >>> +{
> >>> +	struct kvaser_usb_net_priv *priv;
> >>> +	struct can_frame *cf;
> >>> +	struct sk_buff *skb;
> >>> +	struct net_device_stats *stats;
> >>> +	u8 channel = msg->u.rx_can.channel;
> >>> +
> >>> +	if (channel >= dev->nchannels) {
> >>> +		dev_err(dev->udev->dev.parent,
> >>> +			"Invalid channel number (%d)\n", channel);
> >>> +		return;
> >>> +	}
> >>> +
> >>> +	priv = dev->nets[channel];
> >>> +	stats = &priv->netdev->stats;
> >>> +
> >>> +	skb = alloc_can_skb(priv->netdev, &cf);
> >>> +	if (skb == NULL) {
> >>
> >> s/skb == NULL)/!skb/ ?
> >>
> >>> +		stats->tx_dropped++;
> >>> +		return;
> >>> +	}
> >>> +
> >>> +	cf->can_id = ((msg->u.rx_can.msg[0] & 0x1f) << 6) |
> >>> +		     (msg->u.rx_can.msg[1] & 0x3f);
> >>> +	cf->can_dlc = get_can_dlc(msg->u.rx_can.msg[5]);
> >>> +
> >>> +	if (msg->id == CMD_RX_EXT_MESSAGE) {
> >>> +		cf->can_id <<= 18;
> >>> +		cf->can_id |= ((msg->u.rx_can.msg[2] & 0x0f) << 14) |
> >>> +			      ((msg->u.rx_can.msg[3] & 0xff) << 6) |
> >>> +			      (msg->u.rx_can.msg[4] & 0x3f);
> >>> +		cf->can_id |= CAN_EFF_FLAG;
> >>> +	}
> >>> +
> >>> +	if (msg->u.rx_can.flag & MSG_FLAG_REMOTE_FRAME) {
> >>> +		cf->can_id |= CAN_RTR_FLAG;
> >>> +	} else if (msg->u.rx_can.flag & (MSG_FLAG_ERROR_FRAME |
> >>> +					 MSG_FLAG_NERR)) {
> >>> +		cf->can_id |= CAN_ERR_FLAG;
> >>> +		cf->can_dlc = CAN_ERR_DLC;
> >>> +		cf->data[1] = CAN_ERR_CRTL_UNSPEC;
> >>
> >> What is the meaning of such errors? A comment, netdev_err() or
> >> netdev_dbg() would be nice.
> > 
> > I never reached this error with the hardware I've... I don't know what's
> > the meaning of this flag... I will add a trace.
> 
> Then add a netdev_err().

Ok.

Thank you,

-- 
Olivier
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
