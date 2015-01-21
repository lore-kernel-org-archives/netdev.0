From: Andri Yngvason <andri.yngvason@marel.com>
Subject: Re: [PATCH v5 2/5] can: kvaser_usb: Consolidate and unify state change
 handling
Date: Wed, 21 Jan 2015 16:20:25 +0000
Message-ID: <20150121162025.2933.13836@shannon>
References: <20141223154654.GB6460@vivalin-002> <20150120214409.GA16828@linux>
 <20150120214537.GB16828@linux>
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
In-Reply-To: <20150120214537.GB16828@linux>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Ahmed S. Darwish (2015-01-20 21:45:37)
> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> 
> Replace most of the can interface's state and error counters
> handling with the new can-dev can_change_state() mechanism.
> 
> Suggested-by: Andri Yngvason <andri.yngvason@marel.com>
> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> ---
>  drivers/net/can/usb/kvaser_usb.c | 114 +++++++++++++++++++--------------------
>  1 file changed, 55 insertions(+), 59 deletions(-)
> 
> diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
> index 971c5f9..0386d3f 100644
> --- a/drivers/net/can/usb/kvaser_usb.c
> +++ b/drivers/net/can/usb/kvaser_usb.c
> @@ -620,40 +620,43 @@ static void kvaser_usb_unlink_tx_urbs(struct kvaser_usb_net_priv *priv)
>  }
>  
>  static void kvaser_usb_rx_error_update_can_state(struct kvaser_usb_net_priv *priv,
> -                                                const struct kvaser_usb_error_summary *es)
> +                                                const struct kvaser_usb_error_summary *es,
> +                                                struct can_frame *cf)
>  {
>         struct net_device_stats *stats;
> -       enum can_state new_state;
> -
> -       stats = &priv->netdev->stats;
> -       new_state = priv->can.state;
> +       enum can_state cur_state, new_state, tx_state, rx_state;
>  
>         netdev_dbg(priv->netdev, "Error status: 0x%02x\n", es->status);
>  
> -       if (es->status & M16C_STATE_BUS_OFF) {
> -               priv->can.can_stats.bus_off++;
> +       stats = &priv->netdev->stats;
> +       new_state = cur_state = priv->can.state;
> +
> +       if (es->status & M16C_STATE_BUS_OFF)
>                 new_state = CAN_STATE_BUS_OFF;
> -       } else if (es->status & M16C_STATE_BUS_PASSIVE) {
> -               if (priv->can.state != CAN_STATE_ERROR_PASSIVE)
> -                       priv->can.can_stats.error_passive++;
> +       else if (es->status & M16C_STATE_BUS_PASSIVE)
>                 new_state = CAN_STATE_ERROR_PASSIVE;
> -       }
>  
>         if (es->status == M16C_STATE_BUS_ERROR) {
> -               if ((priv->can.state < CAN_STATE_ERROR_WARNING) &&
> -                   ((es->txerr >= 96) || (es->rxerr >= 96))) {
> -                       priv->can.can_stats.error_warning++;
> +               if ((cur_state < CAN_STATE_ERROR_WARNING) &&
> +                   ((es->txerr >= 96) || (es->rxerr >= 96)))
>                         new_state = CAN_STATE_ERROR_WARNING;
> -               } else if (priv->can.state > CAN_STATE_ERROR_ACTIVE) {
> +               else if (cur_state > CAN_STATE_ERROR_ACTIVE)
>                         new_state = CAN_STATE_ERROR_ACTIVE;
> -               }
>         }
>  
>         if (!es->status)
>                 new_state = CAN_STATE_ERROR_ACTIVE;
>  
> +       if (new_state != cur_state) {
> +               tx_state = (es->txerr >= es->rxerr) ? new_state : 0;
> +               rx_state = (es->txerr <= es->rxerr) ? new_state : 0;
> +
> +               can_change_state(priv->netdev, cf, tx_state, rx_state);
This (below) is redundant. It doesn't harm but at this point can_change_state
has set priv->can.state to new_state.
> +               new_state = priv->can.state;
> +       }
> +
>         if (priv->can.restart_ms &&
> -           (priv->can.state >= CAN_STATE_BUS_OFF) &&
> +           (cur_state >= CAN_STATE_BUS_OFF) &&
>             (new_state < CAN_STATE_BUS_OFF)) {
>                 priv->can.can_stats.restarts++;
>         }
> @@ -665,18 +668,17 @@ static void kvaser_usb_rx_error_update_can_state(struct kvaser_usb_net_priv *pri
>  
>         priv->bec.txerr = es->txerr;
>         priv->bec.rxerr = es->rxerr;
> -       priv->can.state = new_state;
>  }
>  
>  static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>                                 const struct kvaser_msg *msg)
>  {
> -       struct can_frame *cf;
> +       struct can_frame *cf, tmp_cf = { .can_id = CAN_ERR_FLAG, .can_dlc = CAN_ERR_DLC };
>         struct sk_buff *skb;
>         struct net_device_stats *stats;
>         struct kvaser_usb_net_priv *priv;
>         struct kvaser_usb_error_summary es = { };
> -       enum can_state old_state;
> +       enum can_state old_state, new_state;
>  
>         switch (msg->id) {
>         case CMD_CAN_ERROR_EVENT:
> @@ -721,60 +723,54 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>         }
>  
>         /* Update all of the can interface's state and error counters before
> -        * trying any skb allocation that can actually fail with -ENOMEM.
> +        * trying any memory allocation that can actually fail with -ENOMEM.
> +        *
> +        * We send a temporary stack-allocated error can frame to
> +        * can_change_state() for the very same reason.
> +        *
> +        * TODO: Split can_change_state() responsibility between updating the
> +        * can interface's state and counters, and the setting up of can error
> +        * frame ID and data to userspace. Remove stack allocation afterwards.
>          */
>         old_state = priv->can.state;
> -       kvaser_usb_rx_error_update_can_state(priv, &es);
> +       kvaser_usb_rx_error_update_can_state(priv, &es, &tmp_cf);
> +       new_state = priv->can.state;
>  
>         skb = alloc_can_err_skb(priv->netdev, &cf);
>         if (!skb) {
>                 stats->rx_dropped++;
>                 return;
>         }
> +       memcpy(cf, &tmp_cf, sizeof(*cf));
>  
> -       if (es.status & M16C_STATE_BUS_OFF) {
> -               cf->can_id |= CAN_ERR_BUSOFF;
> -
> -               if (!priv->can.restart_ms)
> -                       kvaser_usb_simple_msg_async(priv, CMD_STOP_CHIP);
> -               netif_carrier_off(priv->netdev);
> -       } else if (es.status & M16C_STATE_BUS_PASSIVE) {
> -               if (old_state != CAN_STATE_ERROR_PASSIVE) {
> -                       cf->can_id |= CAN_ERR_CRTL;
> -
> -                       if (es.txerr || es.rxerr)
> -                               cf->data[1] = (es.txerr > es.rxerr)
> -                                               ? CAN_ERR_CRTL_TX_PASSIVE
> -                                               : CAN_ERR_CRTL_RX_PASSIVE;
> -                       else
> -                               cf->data[1] = CAN_ERR_CRTL_TX_PASSIVE |
> -                                             CAN_ERR_CRTL_RX_PASSIVE;
> +       if (new_state != old_state) {
> +               if (es.status & M16C_STATE_BUS_OFF) {
> +                       if (!priv->can.restart_ms)
> +                               kvaser_usb_simple_msg_async(priv, CMD_STOP_CHIP);
> +                       netif_carrier_off(priv->netdev);
> +               }
> +
This block is wrong. The usage of PROT_ACTIVE is based on a misunderstanding.
It's used in some drivers to signify back-to-error-active but its original
meaning is something completely different, AFAIK.
This is handled in can_change_state() using a new CTRL message; namely:
CAN_ERR_CTRL_ACTIVE. The newest version of can-utils is up to date with this.
> +               if (es.status == M16C_STATE_BUS_ERROR) {
> +                       if ((old_state >= CAN_STATE_ERROR_WARNING) ||
> +                           (es.txerr < 96 && es.rxerr < 96)) {
> +                               if (old_state > CAN_STATE_ERROR_ACTIVE) {
> +                                       cf->can_id |= CAN_ERR_PROT;
> +                                       cf->data[2] = CAN_ERR_PROT_ACTIVE;
> +                               }
> +                       }
>                 }
> -       }
>  
> -       if (es.status == M16C_STATE_BUS_ERROR) {
> -               if ((old_state < CAN_STATE_ERROR_WARNING) &&
> -                   ((es.txerr >= 96) || (es.rxerr >= 96))) {
> -                       cf->can_id |= CAN_ERR_CRTL;
> -                       cf->data[1] = (es.txerr > es.rxerr)
> -                                       ? CAN_ERR_CRTL_TX_WARNING
> -                                       : CAN_ERR_CRTL_RX_WARNING;
> -               } else if (old_state > CAN_STATE_ERROR_ACTIVE) {
This is also redundant, and wrong:
> +               if (!es.status) {
>                         cf->can_id |= CAN_ERR_PROT;
>                         cf->data[2] = CAN_ERR_PROT_ACTIVE;
>                 }
> -       }
>  
> -       if (!es.status) {
> -               cf->can_id |= CAN_ERR_PROT;
> -               cf->data[2] = CAN_ERR_PROT_ACTIVE;
> -       }
> -
> -       if (priv->can.restart_ms &&
> -           (old_state >= CAN_STATE_BUS_OFF) &&
> -           (priv->can.state < CAN_STATE_BUS_OFF)) {
> -               cf->can_id |= CAN_ERR_RESTARTED;
> -               netif_carrier_on(priv->netdev);
> +               if (priv->can.restart_ms &&
> +                   (old_state >= CAN_STATE_BUS_OFF) &&
> +                   (new_state < CAN_STATE_BUS_OFF)) {
> +                       cf->can_id |= CAN_ERR_RESTARTED;
> +                       netif_carrier_on(priv->netdev);
> +               }
>         }
>  
>         if (es.error_factor) {
> -- 
> 1.9.1

Looking over the patch again, I've noticed that there are a few things that are
not quite right.

Marc, could you merge the "move bus_off++" patch before you merge this so that I
won't have to incorporate this patch-set into it?

--
Andri
