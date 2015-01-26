From: Andri Yngvason <andri.yngvason@marel.com>
Subject: Re: [PATCH v6 5/7] can: kvaser_usb: Update interface state before exiting on
 OOM
Date: Mon, 26 Jan 2015 10:28:43 +0000
Message-ID: <20150126102843.17894.84372@shannon>
References: <20141223154654.GB6460@vivalin-002>
 <20150126051755.GA3014@Darwish.PC> <20150126052039.GB3014@Darwish.PC>
 <20150126052254.GC3014@Darwish.PC> <20150126052406.GD3014@Darwish.PC>
 <20150126052543.GE3014@Darwish.PC> <20150126052719.GF3014@Darwish.PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Wolfgang Grandegger" <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20150126052719.GF3014@Darwish.PC>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Ahmed S. Darwish (2015-01-26 05:27:19)
> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> 
> Update all of the can interface's state and error counters before
> trying any skb allocation that can actually fail with -ENOMEM.
> 
> Suggested-by: Marc Kleine-Budde <mkl@pengutronix.de>
> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> ---
>  drivers/net/can/usb/kvaser_usb.c |  181 ++++++++++++++++++++++----------------
>  1 files changed, 105 insertions(+), 76 deletions(-)
> 
> diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
> index 7af379c..f57ce55 100644
> --- a/drivers/net/can/usb/kvaser_usb.c
> +++ b/drivers/net/can/usb/kvaser_usb.c
> @@ -273,6 +273,10 @@ struct kvaser_msg {
>         } u;
>  } __packed;
>  
> +struct kvaser_usb_error_summary {
> +       u8 channel, status, txerr, rxerr, error_factor;
> +};
> +
>  struct kvaser_usb_tx_urb_context {
>         struct kvaser_usb_net_priv *priv;
>         u32 echo_index;
> @@ -615,6 +619,54 @@ static void kvaser_usb_unlink_tx_urbs(struct kvaser_usb_net_priv *priv)
>                 priv->tx_contexts[i].echo_index = MAX_TX_URBS;
>  }
>  
> +static void kvaser_usb_rx_error_update_can_state(struct kvaser_usb_net_priv *priv,
> +                                                const struct kvaser_usb_error_summary *es)
> +{
> +       struct net_device_stats *stats;
> +       enum can_state new_state;
> +
> +       stats = &priv->netdev->stats;
> +       new_state = priv->can.state;
> +
> +       netdev_dbg(priv->netdev, "Error status: 0x%02x\n", es->status);
> +
> +       if (es->status & (M16C_STATE_BUS_OFF | M16C_STATE_BUS_RESET)) {
> +               priv->can.can_stats.bus_off++;
> +               new_state = CAN_STATE_BUS_OFF;
> +       } else if (es->status & M16C_STATE_BUS_PASSIVE) {
> +               if (priv->can.state != CAN_STATE_ERROR_PASSIVE)
> +                       priv->can.can_stats.error_passive++;
> +               new_state = CAN_STATE_ERROR_PASSIVE;
> +       } else if (es->status & M16C_STATE_BUS_ERROR) {
> +               if ((priv->can.state < CAN_STATE_ERROR_WARNING) &&
> +                   ((es->txerr >= 96) || (es->rxerr >= 96))) {
> +                       priv->can.can_stats.error_warning++;
> +                       new_state = CAN_STATE_ERROR_WARNING;
> +               } else if ((priv->can.state > CAN_STATE_ERROR_ACTIVE) &&
> +                          ((es->txerr < 96) && (es->rxerr < 96))) {
> +                       new_state = CAN_STATE_ERROR_ACTIVE;
> +               }
> +       }
> +
> +       if (!es->status)
> +               new_state = CAN_STATE_ERROR_ACTIVE;
> +
> +       if (priv->can.restart_ms &&
> +           (priv->can.state >= CAN_STATE_BUS_OFF) &&
> +           (new_state < CAN_STATE_BUS_OFF)) {
> +               priv->can.can_stats.restarts++;
> +       }
> +
> +       if (es->error_factor) {
> +               priv->can.can_stats.bus_error++;
> +               stats->rx_errors++;
> +       }
> +
> +       priv->bec.txerr = es->txerr;
> +       priv->bec.rxerr = es->rxerr;
> +       priv->can.state = new_state;
> +}
> +
>  static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>                                 const struct kvaser_msg *msg)
>  {
> @@ -622,30 +674,30 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>         struct sk_buff *skb;
>         struct net_device_stats *stats;
>         struct kvaser_usb_net_priv *priv;
> -       unsigned int new_state;
> -       u8 channel, status, txerr, rxerr, error_factor;
> +       struct kvaser_usb_error_summary es = { };
> +       enum can_state old_state;
>  
>         switch (msg->id) {
>         case CMD_CAN_ERROR_EVENT:
> -               channel = msg->u.error_event.channel;
> -               status =  msg->u.error_event.status;
> -               txerr = msg->u.error_event.tx_errors_count;
> -               rxerr = msg->u.error_event.rx_errors_count;
> -               error_factor = msg->u.error_event.error_factor;
> +               es.channel = msg->u.error_event.channel;
> +               es.status =  msg->u.error_event.status;
> +               es.txerr = msg->u.error_event.tx_errors_count;
> +               es.rxerr = msg->u.error_event.rx_errors_count;
> +               es.error_factor = msg->u.error_event.error_factor;
>                 break;
>         case CMD_LOG_MESSAGE:
> -               channel = msg->u.log_message.channel;
> -               status = msg->u.log_message.data[0];
> -               txerr = msg->u.log_message.data[2];
> -               rxerr = msg->u.log_message.data[3];
> -               error_factor = msg->u.log_message.data[1];
> +               es.channel = msg->u.log_message.channel;
> +               es.status = msg->u.log_message.data[0];
> +               es.txerr = msg->u.log_message.data[2];
> +               es.rxerr = msg->u.log_message.data[3];
> +               es.error_factor = msg->u.log_message.data[1];
>                 break;
>         case CMD_CHIP_STATE_EVENT:
> -               channel = msg->u.chip_state_event.channel;
> -               status =  msg->u.chip_state_event.status;
> -               txerr = msg->u.chip_state_event.tx_errors_count;
> -               rxerr = msg->u.chip_state_event.rx_errors_count;
> -               error_factor = 0;
> +               es.channel = msg->u.chip_state_event.channel;
> +               es.status =  msg->u.chip_state_event.status;
> +               es.txerr = msg->u.chip_state_event.tx_errors_count;
> +               es.rxerr = msg->u.chip_state_event.rx_errors_count;
> +               es.error_factor = 0;
>                 break;
>         default:
>                 dev_err(dev->udev->dev.parent, "Invalid msg id (%d)\n",
> @@ -653,116 +705,93 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>                 return;
>         }
>  
> -       if (channel >= dev->nchannels) {
> +       if (es.channel >= dev->nchannels) {
>                 dev_err(dev->udev->dev.parent,
> -                       "Invalid channel number (%d)\n", channel);
> +                       "Invalid channel number (%d)\n", es.channel);
>                 return;
>         }
>  
> -       priv = dev->nets[channel];
> +       priv = dev->nets[es.channel];
>         stats = &priv->netdev->stats;
>  
> +       /* Update all of the can interface's state and error counters before
> +        * trying any skb allocation that can actually fail with -ENOMEM.
> +        */
> +       old_state = priv->can.state;
> +       kvaser_usb_rx_error_update_can_state(priv, &es);
> +
>         skb = alloc_can_err_skb(priv->netdev, &cf);
>         if (!skb) {
>                 stats->rx_dropped++;
>                 return;
>         }
>  
> -       new_state = priv->can.state;
> -
> -       netdev_dbg(priv->netdev, "Error status: 0x%02x\n", status);
> -
> -       if (status & (M16C_STATE_BUS_OFF | M16C_STATE_BUS_RESET)) {
> +       if (es.status & (M16C_STATE_BUS_OFF | M16C_STATE_BUS_RESET)) {
>                 cf->can_id |= CAN_ERR_BUSOFF;
>  
> -               priv->can.can_stats.bus_off++;
>                 if (!priv->can.restart_ms)
>                         kvaser_usb_simple_msg_async(priv, CMD_STOP_CHIP);
> -
>                 netif_carrier_off(priv->netdev);
> -
> -               new_state = CAN_STATE_BUS_OFF;
> -       } else if (status & M16C_STATE_BUS_PASSIVE) {
> -               if (priv->can.state != CAN_STATE_ERROR_PASSIVE) {
> +       } else if (es.status & M16C_STATE_BUS_PASSIVE) {
> +               if (old_state != CAN_STATE_ERROR_PASSIVE) {
>                         cf->can_id |= CAN_ERR_CRTL;
>  
> -                       if (txerr || rxerr)
> -                               cf->data[1] = (txerr > rxerr)
> +                       if (es.txerr || es.rxerr)
> +                               cf->data[1] = (es.txerr > es.rxerr)
>                                                 ? CAN_ERR_CRTL_TX_PASSIVE
>                                                 : CAN_ERR_CRTL_RX_PASSIVE;
>                         else
>                                 cf->data[1] = CAN_ERR_CRTL_TX_PASSIVE |
>                                               CAN_ERR_CRTL_RX_PASSIVE;
> -
> -                       priv->can.can_stats.error_passive++;
>                 }
> -
> -               new_state = CAN_STATE_ERROR_PASSIVE;
> -       } else if (status & M16C_STATE_BUS_ERROR) {
> -               if ((priv->can.state < CAN_STATE_ERROR_WARNING) &&
> -                   ((txerr >= 96) || (rxerr >= 96))) {
> +       } else if (es.status & M16C_STATE_BUS_ERROR) {
> +               if ((old_state < CAN_STATE_ERROR_WARNING) &&
> +                   ((es.txerr >= 96) || (es.rxerr >= 96))) {
>                         cf->can_id |= CAN_ERR_CRTL;
> -                       cf->data[1] = (txerr > rxerr)
> +                       cf->data[1] = (es.txerr > es.rxerr)
>                                         ? CAN_ERR_CRTL_TX_WARNING
>                                         : CAN_ERR_CRTL_RX_WARNING;
> -
> -                       priv->can.can_stats.error_warning++;
> -                       new_state = CAN_STATE_ERROR_WARNING;
> -               } else if ((priv->can.state > CAN_STATE_ERROR_ACTIVE) &&
> -                          ((txerr < 96) && (rxerr < 96))) {
> +               } else if ((old_state > CAN_STATE_ERROR_ACTIVE) &&
> +                          ((es.txerr < 96) && (es.rxerr < 96))) {
>                         cf->can_id |= CAN_ERR_PROT;
>                         cf->data[2] = CAN_ERR_PROT_ACTIVE;
> -
> -                       new_state = CAN_STATE_ERROR_ACTIVE;
>                 }
>         }
>  
> -       if (!status) {
> +       if (!es.status) {
>                 cf->can_id |= CAN_ERR_PROT;
>                 cf->data[2] = CAN_ERR_PROT_ACTIVE;
> -
> -               new_state = CAN_STATE_ERROR_ACTIVE;
>         }
>  
>         if (priv->can.restart_ms &&
> -           (priv->can.state >= CAN_STATE_BUS_OFF) &&
> -           (new_state < CAN_STATE_BUS_OFF)) {
> +           (old_state >= CAN_STATE_BUS_OFF) &&
> +           (priv->can.state < CAN_STATE_BUS_OFF)) {
>                 cf->can_id |= CAN_ERR_RESTARTED;
>                 netif_carrier_on(priv->netdev);
> -
> -               priv->can.can_stats.restarts++;
>         }
>  
> -       if (error_factor) {
> -               priv->can.can_stats.bus_error++;
> -               stats->rx_errors++;
> -
> +       if (es.error_factor) {
>                 cf->can_id |= CAN_ERR_BUSERROR | CAN_ERR_PROT;
>  
> -               if (error_factor & M16C_EF_ACKE)
> +               if (es.error_factor & M16C_EF_ACKE)
>                         cf->data[3] |= (CAN_ERR_PROT_LOC_ACK);
> -               if (error_factor & M16C_EF_CRCE)
> +               if (es.error_factor & M16C_EF_CRCE)
>                         cf->data[3] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
>                                         CAN_ERR_PROT_LOC_CRC_DEL);
> -               if (error_factor & M16C_EF_FORME)
> +               if (es.error_factor & M16C_EF_FORME)
>                         cf->data[2] |= CAN_ERR_PROT_FORM;
> -               if (error_factor & M16C_EF_STFE)
> +               if (es.error_factor & M16C_EF_STFE)
>                         cf->data[2] |= CAN_ERR_PROT_STUFF;
> -               if (error_factor & M16C_EF_BITE0)
> +               if (es.error_factor & M16C_EF_BITE0)
>                         cf->data[2] |= CAN_ERR_PROT_BIT0;
> -               if (error_factor & M16C_EF_BITE1)
> +               if (es.error_factor & M16C_EF_BITE1)
>                         cf->data[2] |= CAN_ERR_PROT_BIT1;
> -               if (error_factor & M16C_EF_TRE)
> +               if (es.error_factor & M16C_EF_TRE)
>                         cf->data[2] |= CAN_ERR_PROT_TX;
>         }
>  
> -       cf->data[6] = txerr;
> -       cf->data[7] = rxerr;
> -
> -       priv->bec.txerr = txerr;
> -       priv->bec.rxerr = rxerr;
> -
> -       priv->can.state = new_state;
> +       cf->data[6] = es.txerr;
> +       cf->data[7] = es.rxerr;
>  
>         stats->rx_packets++;
>         stats->rx_bytes += cf->can_dlc;
> @@ -786,6 +815,9 @@ static void kvaser_usb_rx_can_err(const struct kvaser_usb_net_priv *priv,
>         }
>  
>         if (msg->u.rx_can.flag & MSG_FLAG_OVERRUN) {
> +               stats->rx_over_errors++;
> +               stats->rx_errors++;
> +
>                 skb = alloc_can_err_skb(priv->netdev, &cf);
>                 if (!skb) {
>                         stats->rx_dropped++;
> @@ -795,9 +827,6 @@ static void kvaser_usb_rx_can_err(const struct kvaser_usb_net_priv *priv,
>                 cf->can_id |= CAN_ERR_CRTL;
>                 cf->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
>  
> -               stats->rx_over_errors++;
> -               stats->rx_errors++;
> -
>                 stats->rx_packets++;
>                 stats->rx_bytes += cf->can_dlc;
>                 netif_rx(skb);
> -- 
> 1.7.7.6

Looks good to me.

--
Andri
