From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: Re: [PATCH v2 09/13] can: pruss CAN driver.
Date: Fri, 11 Feb 2011 16:20:26 +0100
Message-ID: <20110211152026.GC373@e-circ.dyndns.org>
References: <1297435892-28278-1-git-send-email-subhasish@mistralsolutions.com>
	<1297435892-28278-10-git-send-email-subhasish@mistralsolutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	"open list:CAN NETWORK DRIVERS" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	nsekhar-l0cyMroinI0@public.gmane.org, open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:CAN NETWORK DRIVERS" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, m-watkins-l0cyMroinI0@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1297435892-28278-10-git-send-email-subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I looked a bit at the TX path:

On Fri, Feb 11, 2011 at 08:21:28PM +0530, Subhasish Ghosh wrote:
> +static int omapl_pru_can_set_bittiming(struct net_device *ndev)
> +{
> +	struct omapl_pru_can_priv *priv = netdev_priv(ndev);
> +	struct can_bittiming *bt = &priv->can.bittiming;
> +	long bit_error = 0;
> +
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES) {
> +		dev_warn(priv->dev, "WARN: Triple"
> +			 "sampling not set due to h/w limitations");
You should not have enabled CAN_CTRLMODE_3_SAMPLES in the first place?
> +	}
> +	if (pru_can_calc_timing(priv->dev, priv->can.clock.freq,
> +				bt->bitrate) != 0)
> +		return -EINVAL;
> +	bit_error =
> +	    (((priv->timer_freq / (priv->timer_freq / bt->bitrate)) -
> +	      bt->bitrate) * 1000) / bt->bitrate;
> +	if (bit_error) {
> +		bit_error =
> +		    (((priv->timer_freq / (priv->timer_freq / bt->bitrate)) -
> +		      bt->bitrate) * 1000000) / bt->bitrate;
> +		printk(KERN_INFO "\nBitrate error %ld.%ld%%\n",
> +			bit_error / 10000, bit_error % 1000);
> +	} else
> +		printk(KERN_INFO "\nBitrate error 0.0%%\n");
> +
> +	return 0;
> +}
I wonder how much of this code is duplicated from drivers/net/can/dev.c ?

> +static netdev_tx_t omapl_pru_can_start_xmit(struct sk_buff *skb,
> +					    struct net_device *ndev)
> +{
> +	struct omapl_pru_can_priv *priv = netdev_priv(ndev);
> +	struct can_frame *cf = (struct can_frame *)skb->data;
> +	int count;
> +	u8 *data = cf->data;
> +	u8 dlc = cf->can_dlc;
> +	u8 *ptr8data = NULL;
> +
most drivers start with:
	if (can_dropped_invalid_skb(dev, skb))
		return NETDEV_TX_OK;

> +	netif_stop_queue(ndev);
why would you stop when you just resumed the queue?
> +	if (cf->can_id & CAN_EFF_FLAG)	/* Extended frame format */
> +		*((u32 *) &priv->can_tx_hndl.strcanmailbox) =
> +		    (cf->can_id & CAN_EFF_MASK) | PRU_CANMID_IDE;
> +	else			/* Standard frame format */
> +		*((u32 *) &priv->can_tx_hndl.strcanmailbox) =
> +		    (cf->can_id & CAN_SFF_MASK) << 18;
> +
> +	if (cf->can_id & CAN_RTR_FLAG)	/* Remote transmission request */
> +		*((u32 *) &priv->can_tx_hndl.strcanmailbox) |= CAN_RTR_FLAG;
> +
> +	ptr8data = &priv->can_tx_hndl.strcanmailbox.u8data7 + (dlc - 1);
> +	for (count = 0; count < (u8) dlc; count++) {
> +		*ptr8data-- = *data++;
> +	}
> +	*((u32 *) &priv->can_tx_hndl.strcanmailbox.u16datalength) = (u32) dlc;
> +/*
> + * search for the next available mbx
> + * if the next mbx is busy, then try the next + 1
> + * do this until the head is reached.
> + * if still unable to tx, stop accepting any packets
> + * if able to tx and the head is reached, then reset next to tail, i.e mbx0
> + * if head is not reached, then just point to the next mbx
> + */
> +	for (; priv->tx_next <= priv->tx_head; priv->tx_next++) {
> +		priv->can_tx_hndl.ecanmailboxnumber =
> +		    (can_mailbox_number) priv->tx_next;
> +		if (-1 == pru_can_write_data_to_mailbox(priv->dev,
> +					&priv->can_tx_hndl)) {
> +			if (priv->tx_next == priv->tx_head) {
> +				priv->tx_next = priv->tx_tail;
> +				if (!netif_queue_stopped(ndev))
If you get here, the queue is not stopped. This test is therefore useless.
> +					netif_stop_queue(ndev);	/* IF stalled */
> +				dev_err(priv->dev,
> +					"%s: no tx mbx available", __func__);
> +				return NETDEV_TX_BUSY;
> +			} else
> +				continue;
> +		} else {
> +			/* set transmit request */
> +			pru_can_tx(priv->dev, priv->tx_next, CAN_TX_PRU_1);
> +			pru_can_tx_mode_set(priv->dev, false, ecanreceive);
> +			pru_can_tx_mode_set(priv->dev, true, ecantransmit);
> +			pru_can_start_abort_tx(priv->dev, PRU_CAN_START);
> +			priv->tx_next++;
> +			can_put_echo_skb(skb, ndev, 0);
> +			break;
> +		}
> +	}
> +	if (priv->tx_next > priv->tx_head) {
> +		priv->tx_next = priv->tx_tail;
> +	}
> +	return NETDEV_TX_OK;
> +}
> +
> +

> +irqreturn_t omapl_tx_can_intr(int irq, void *dev_id)
> +{
> +	struct net_device *ndev = dev_id;
> +	struct omapl_pru_can_priv *priv = netdev_priv(ndev);
> +	struct net_device_stats *stats = &ndev->stats;
> +	u32 bit_set, mbxno;
> +
> +	pru_can_get_intr_status(priv->dev, &priv->can_tx_hndl);
> +	if ((PRU_CAN_ISR_BIT_CCI & priv->can_tx_hndl.u32interruptstatus)
> +	    || (PRU_CAN_ISR_BIT_SRDI & priv->can_tx_hndl.u32interruptstatus)) {
> +		__can_debug("tx_int_status = 0x%X\n",
> +			    priv->can_tx_hndl.u32interruptstatus);
> +		can_free_echo_skb(ndev, 0);
> +	} else {
> +		for (bit_set = 0; ((priv->can_tx_hndl.u32interruptstatus & 0xFF)
> +						>> bit_set != 0); bit_set++)
> +		;
> +		if (0 == bit_set) {
> +			__can_err("%s: invalid mailbox number\n", __func__);
> +			can_free_echo_skb(ndev, 0);
> +		} else {
> +			mbxno = bit_set - 1;	/* mail box numbering starts from 0 */
> +			if (PRU_CAN_ISR_BIT_ESI & priv->can_tx_hndl.
> +			    u32interruptstatus) {
> +				/* read gsr and ack pru */
> +				pru_can_get_global_status(priv->dev, &priv->can_tx_hndl);
> +				omapl_pru_can_err(ndev,
> +						  priv->can_tx_hndl.
> +						  u32interruptstatus,
> +						  priv->can_tx_hndl.
> +						  u32globalstatus);
> +			} else {
> +				stats->tx_packets++;
> +				/* stats->tx_bytes += dlc; */
> +				/*can_get_echo_skb(ndev, 0);*/
> +			}
> +		}
> +	}
> +	if (netif_queue_stopped(ndev))
you can call netif_wake_queue(ndev) multiple times, so there is no need
for netif_queue_stopped()
> +		netif_wake_queue(ndev);
> +
> +	can_get_echo_skb(ndev, 0);
> +	pru_can_tx_mode_set(priv->dev, true, ecanreceive);
> +	return IRQ_HANDLED;
> +}
> +
> +static int omapl_pru_can_open(struct net_device *ndev)
> +{
> +	struct omapl_pru_can_priv *priv = netdev_priv(ndev);
> +	int err;
> +
> +	/* register interrupt handler */
> +	err = request_irq(priv->trx_irq, &omapl_rx_can_intr, IRQF_SHARED,
> +			  "pru_can_irq", ndev);
you're doing a lot of work _in_ the irq handler. Maybe threaded irq?

> +static int omapl_pru_can_close(struct net_device *ndev)
> +{
> +	struct omapl_pru_can_priv *priv = netdev_priv(ndev);
> +
> +	if (!netif_queue_stopped(ndev))
check is not needed.
> +		netif_stop_queue(ndev);
> +
> +	close_candev(ndev);
> +
> +	free_irq(priv->trx_irq, ndev);
> +	return 0;
> +}
> +

Regards,
Kurt
