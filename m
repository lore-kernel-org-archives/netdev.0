From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] can: Driver for the Microchip MCP251x SPI CAN controllers
Date: Mon, 02 Nov 2009 20:49:21 +0100
Message-ID: <4AEF37C1.9030706@grandegger.com>
References: <cabda6420911020729j3323ec33i59c7e94020acc469@mail.gmail.com>
	<1257175840-28528-1-git-send-email-chripell@fsfe.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1257175840-28528-1-git-send-email-chripell-VaTbYqLCNhc@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

I assume this is v2 of the patch.

Christian Pellegrin wrote:
> Signed-off-by: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
> ---
>  drivers/net/can/Kconfig              |    6 +
>  drivers/net/can/Makefile             |    1 +
>  drivers/net/can/mcp251x.c            | 1164 ++++++++++++++++++++++++++++++++++
>  include/linux/can/platform/mcp251x.h |   36 +
>  4 files changed, 1207 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/mcp251x.c
>  create mode 100644 include/linux/can/platform/mcp251x.h
> 
[snip]
> diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
> new file mode 100644
> index 0000000..9471bb7
> --- /dev/null
> +++ b/drivers/net/can/mcp251x.c
[snip]
> +static void mcp251x_hw_tx(struct spi_device *spi, struct can_frame *frame,
> +			  int tx_buf_idx)
> +{
> +	u32 sid, eid, exide, rtr;
> +	u8 buf[SPI_TRANSFER_BUF_LEN];
> +
> +	exide = (frame->can_id & CAN_EFF_FLAG) ? 1 : 0; /* Extended ID Enable */
> +	if (exide)
> +		sid = (frame->can_id & CAN_EFF_MASK) >> 18;
> +	else
> +		sid = frame->can_id & CAN_SFF_MASK; /* Standard ID */
> +	eid = frame->can_id & CAN_EFF_MASK; /* Extended ID */
> +	rtr = (frame->can_id & CAN_RTR_FLAG) ? 1 : 0; /* Remote transmission */
> +
> +	buf[TXBCTRL_OFF] = INSTRUCTION_LOAD_TXB(tx_buf_idx);
> +	buf[TXBSIDH_OFF] = sid >> SIDH_SHIFT;
> +	buf[TXBSIDL_OFF] = ((sid & SIDL_SID_MASK) << SIDL_SID_SHIFT) |
> +		(exide << SIDL_EXIDE_SHIFT) |
> +		((eid >> SIDL_EID_SHIFT) & SIDL_EID_MASK);
> +	buf[TXBEID8_OFF] = GET_BYTE(eid, 1);
> +	buf[TXBEID0_OFF] = GET_BYTE(eid, 0);
> +	buf[TXBDLC_OFF]  = (rtr << DLC_RTR_SHIFT) | frame->can_dlc;

Two spaces before "=".

> +	memcpy(buf + TXBDAT_OFF, frame->data, frame->can_dlc);
> +	mcp251x_hw_tx_frame(spi, buf, frame->can_dlc, tx_buf_idx);
> +	mcp251x_write_reg(spi, TXBCTRL(tx_buf_idx), TXBCTRL_TXREQ);
> +}
> +
[snip]
> +static int mcp251x_open(struct net_device *net)
> +{
> +	struct mcp251x_priv *priv = netdev_priv(net);
> +	struct spi_device *spi = priv->spi;
> +	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
> +	int ret;
> +
> +	if (pdata->transceiver_enable)
> +		pdata->transceiver_enable(1);
> +
> +	priv->force_quit = 0;
> +	priv->tx_skb = NULL;
> +	priv->tx_len = 0;
> +
> +	ret = request_irq(spi->irq, mcp251x_can_isr,
> +			  IRQF_TRIGGER_FALLING, DEVICE_NAME, net);
> +	if (ret) {
> +		dev_err(&spi->dev, "failed to acquire irq %d\n", spi->irq);
> +		return ret;
> +	}

Here the transceiver should be switched off!?

> +	mcp251x_hw_wakeup(spi);
> +	mcp251x_hw_reset(spi);
> +	ret = mcp251x_setup(net, priv, spi);
> +	if (ret) {
> +		free_irq(spi->irq, net);
> +		if (pdata->transceiver_enable)
> +			pdata->transceiver_enable(0);
> +		return ret;
> +	}
> +	mcp251x_set_normal_mode(spi);
> +	netif_wake_queue(net);
> +
> +	return 0;
> +}
> +
[snip]
> +static void mcp251x_irq_work_handler(struct work_struct *ws)
> +{
> +	struct mcp251x_priv *priv = container_of(ws, struct mcp251x_priv,
> +						 irq_work);
> +	struct spi_device *spi = priv->spi;
> +	struct net_device *net = priv->net;
> +	u8 txbnctrl;
> +	u8 intf;
> +	enum can_state new_state;
> +
> +	if (priv->after_suspend) {
> +		mdelay(10);
> +		mcp251x_hw_reset(spi);
> +		mcp251x_setup(net, priv, spi);
> +		if (priv->after_suspend & AFTER_SUSPEND_RESTART) {
> +			mcp251x_set_normal_mode(spi);
> +		} else if (priv->after_suspend & AFTER_SUSPEND_UP) {
> +			netif_device_attach(net);
> +			/* Clean since we lost tx buffer */
> +			if (priv->tx_skb || priv->tx_len) {
> +				mcp251x_clean(net);
> +				netif_wake_queue(net);
> +			}
> +			mcp251x_set_normal_mode(spi);
> +		} else {
> +			mcp251x_hw_sleep(spi);
> +		}
> +		priv->after_suspend = 0;
> +	}
> +
> +	if (priv->can.restart_ms == 0 && priv->can.state == CAN_STATE_BUS_OFF) {
> +		while (!priv->force_quit && !freezing(current) &&
> +		       (intf = mcp251x_read_reg(spi, CANINTF)))
> +			mcp251x_write_bits(spi, CANINTF, intf, 0x00);

Assigning variables within if or while expressions is not allowed. I
wonder why checkpatch did not spot it.

> +		return;
> +	}
> +
> +	while (!priv->force_quit && !freezing(current)) {
> +		u8 eflag = mcp251x_read_reg(spi, EFLG);
> +		int can_id = 0, data1 = 0;
> +
> +		mcp251x_write_reg(spi, EFLG, 0x00);
> +
> +		if (priv->restart_tx) {
> +			priv->restart_tx = 0;
> +			mcp251x_write_reg(spi, TXBCTRL(0), 0);
> +			if (priv->tx_skb || priv->tx_len)
> +				mcp251x_clean(net);
> +			netif_wake_queue(net);
> +			can_id |= CAN_ERR_RESTARTED;
> +		}
> +
> +		if (priv->wake) {
> +			/* Wait whilst the device wakes up */
> +			mdelay(10);
> +			priv->wake = 0;
> +		}
> +
> +		intf = mcp251x_read_reg(spi, CANINTF);
> +		mcp251x_write_bits(spi, CANINTF, intf, 0x00);
> +
> +		/* Update can state */
> +		if (eflag & EFLG_TXBO) {
> +			new_state = CAN_STATE_BUS_OFF;
> +			can_id |= CAN_ERR_BUSOFF;
> +		} else if (eflag & EFLG_TXEP) {
> +			new_state = CAN_STATE_ERROR_PASSIVE;
> +			can_id |= CAN_ERR_CRTL;
> +			data1 |= CAN_ERR_CRTL_TX_PASSIVE;
> +		} else if (eflag & EFLG_RXEP) {
> +			new_state = CAN_STATE_ERROR_PASSIVE;
> +			can_id |= CAN_ERR_CRTL;
> +			data1 |= CAN_ERR_CRTL_RX_PASSIVE;
> +		} else if (eflag & EFLG_TXWAR) {
> +			new_state = CAN_STATE_ERROR_WARNING;
> +			can_id |= CAN_ERR_CRTL;
> +			data1 |= CAN_ERR_CRTL_TX_WARNING;
> +		} else if (eflag & EFLG_RXWAR) {
> +			new_state = CAN_STATE_ERROR_WARNING;
> +			can_id |= CAN_ERR_CRTL;
> +			data1 |= CAN_ERR_CRTL_RX_WARNING;
> +		} else {
> +			new_state = CAN_STATE_ERROR_ACTIVE;
> +		}
> +
> +		/* Update can state statistics */
> +		switch (priv->can.state) {
> +		case CAN_STATE_ERROR_ACTIVE:
> +			if (new_state >= CAN_STATE_ERROR_WARNING &&
> +			    new_state <= CAN_STATE_BUS_OFF)
> +				priv->can.can_stats.error_warning++;
> +		case CAN_STATE_ERROR_WARNING:	/* fallthrough */
> +			if (new_state >= CAN_STATE_ERROR_PASSIVE &&
> +			    new_state <= CAN_STATE_BUS_OFF)
> +				priv->can.can_stats.error_passive++;
> +			break;
> +		default:
> +			break;
> +		}
> +		priv->can.state = new_state;
> +
> +		if ((intf & CANINTF_ERRIF) || (can_id & CAN_ERR_RESTARTED)) {
> +			struct sk_buff *skb;
> +			struct can_frame *frame;
> +
> +			/* Create error frame */
> +			skb = alloc_can_err_skb(net, &frame);
> +			if (skb) {
> +				/* Set error frame flags based on bus state */
> +				frame->can_id = can_id;
> +				frame->data[1] = data1;
> +
> +				/* Update net stats for overflows */
> +				if (eflag & (EFLG_RX0OVR | EFLG_RX1OVR)) {
> +					if (eflag & EFLG_RX0OVR)
> +						net->stats.rx_over_errors++;
> +					if (eflag & EFLG_RX1OVR)
> +						net->stats.rx_over_errors++;
> +					frame->can_id |= CAN_ERR_CRTL;
> +					frame->data[1] |=
> +						CAN_ERR_CRTL_RX_OVERFLOW;
> +				}
> +
> +				netif_rx(skb);
> +			} else {
> +				dev_info(&spi->dev,
> +					 "cannot allocate error skb\n");
> +			}
> +		}
> +
> +		if (priv->can.state == CAN_STATE_BUS_OFF) {
> +			if (priv->can.restart_ms == 0) {
> +				can_bus_off(net);
> +				mcp251x_hw_sleep(spi);
> +				return;
> +			}
> +		}
> +
> +		if (intf == 0)
> +			break;
> +
> +		if (intf & CANINTF_WAKIF)
> +			complete(&priv->awake);
> +
> +		if (intf & CANINTF_MERRF) {
> +			/* If there are pending Tx buffers, restart queue */
> +			txbnctrl = mcp251x_read_reg(spi, TXBCTRL(0));
> +			if (!(txbnctrl & TXBCTRL_TXREQ)) {
> +				if (priv->tx_skb || priv->tx_len)
> +					mcp251x_clean(net);
> +				netif_wake_queue(net);
> +			}
> +		}
> +
> +		if (intf & (CANINTF_TX2IF | CANINTF_TX1IF | CANINTF_TX0IF)) {
> +			net->stats.tx_packets++;
> +			net->stats.tx_bytes += priv->tx_len - 1;
> +			if (priv->tx_len) {
> +				can_get_echo_skb(net, 0);
> +				priv->tx_len = 0;
> +			}
> +			netif_wake_queue(net);
> +		}
> +
> +		if (intf & CANINTF_RX0IF)
> +			mcp251x_hw_rx(spi, 0);
> +
> +		if (intf & CANINTF_RX1IF)
> +			mcp251x_hw_rx(spi, 1);
> +	}
> +}
> +
> +static const struct net_device_ops mcp251x_netdev_ops = {
> +	.ndo_open	= mcp251x_open,
> +	.ndo_stop	= mcp251x_stop,
> +	.ndo_start_xmit	= mcp251x_hard_start_xmit,
> +};
> +
> +static int __devinit mcp251x_can_probe(struct spi_device *spi)
> +{
> +	struct net_device *net;
> +	struct mcp251x_priv *priv;
> +	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
> +	int ret = -ENODEV;
> +
> +	if (!pdata)
> +		/* Platform data is required for osc freq */
> +		goto error_out;
> +
> +	/* Allocate can/net device */
> +	net = alloc_candev(sizeof(struct mcp251x_priv), TX_ECHO_SKB_MAX);
> +	if (!net) {
> +		ret = -ENOMEM;
> +		goto error_alloc;
> +	}
> +
> +	net->netdev_ops		= &mcp251x_netdev_ops;
> +	net->flags		|= IFF_ECHO;

Remove spaces, please.

> +	priv = netdev_priv(net);
> +	priv->can.bittiming_const = &mcp251x_bittiming_const;
> +	priv->can.do_set_mode = mcp251x_do_set_mode;
> +	priv->can.clock.freq = pdata->oscillator_frequency / 2;
> +	priv->can.do_set_bittiming = mcp251x_do_set_bittiming;
> +	priv->net = net;
> +	dev_set_drvdata(&spi->dev, priv);
> +
> +	priv->spi = spi;
> +	mutex_init(&priv->spi_lock);
> +
> +	/* If requested, allocate DMA buffers */
> +	if (mcp251x_enable_dma) {
> +		spi->dev.coherent_dma_mask = ~0;
> +
> +		/*
> +		 * Minimum coherent DMA allocation is PAGE_SIZE, so allocate
> +		 * that much and share it between Tx and Rx DMA buffers.
> +		 */
> +		priv->spi_tx_buf = dma_alloc_coherent(&spi->dev,
> +						      PAGE_SIZE,
> +						      &priv->spi_tx_dma,
> +						      GFP_DMA);
> +
> +		if (priv->spi_tx_buf) {
> +			priv->spi_rx_buf = (u8 *)(priv->spi_tx_buf +
> +						  (PAGE_SIZE / 2));
> +			priv->spi_rx_dma = (dma_addr_t)(priv->spi_tx_dma +
> +							(PAGE_SIZE / 2));
> +		} else {
> +			/* Fall back to non-DMA */
> +			mcp251x_enable_dma = 0;
> +		}
> +	}
> +
> +	/* Allocate non-DMA buffers */
> +	if (!mcp251x_enable_dma) {
> +		priv->spi_tx_buf = kmalloc(SPI_TRANSFER_BUF_LEN, GFP_KERNEL);
> +		if (!priv->spi_tx_buf) {
> +			ret = -ENOMEM;
> +			goto error_tx_buf;
> +		}
> +		priv->spi_rx_buf = kmalloc(SPI_TRANSFER_BUF_LEN, GFP_KERNEL);
> +		if (!priv->spi_tx_buf) {
> +			ret = -ENOMEM;
> +			goto error_rx_buf;
> +		}
> +	}
> +
> +	if (pdata->power_enable)
> +		pdata->power_enable(1);
> +
> +	/* Call out to platform specific setup */
> +	if (pdata->board_specific_setup)
> +		pdata->board_specific_setup(spi);
> +
> +	SET_NETDEV_DEV(net, &spi->dev);
> +
> +	priv->wq = create_freezeable_workqueue("mcp251x_wq");
> +
> +	INIT_WORK(&priv->tx_work, mcp251x_tx_work_handler);
> +	INIT_WORK(&priv->irq_work, mcp251x_irq_work_handler);
> +
> +	init_completion(&priv->awake);
> +
> +	/* Configure the SPI bus */
> +	spi->mode = SPI_MODE_0;
> +	spi->bits_per_word = 8;
> +	spi_setup(spi);
> +
> +	if (!mcp251x_hw_probe(spi)) {
> +		dev_info(&spi->dev, "Probe failed\n");
> +		goto error_probe;
> +	}
> +	mcp251x_hw_sleep(spi);
> +
> +	if (pdata->transceiver_enable)
> +		pdata->transceiver_enable(0);
> +
> +	ret = register_candev(net);
> +	if (ret >= 0) {

if (!ret) ?

> +		dev_info(&spi->dev, "probed\n");
> +		return ret;
> +	}

Shouldn't the power be switched off?

> +error_probe:
> +	if (!mcp251x_enable_dma)
> +		kfree(priv->spi_rx_buf);
> +error_rx_buf:
> +	if (!mcp251x_enable_dma)
> +		kfree(priv->spi_tx_buf);
> +error_tx_buf:
> +	free_candev(net);
> +	if (mcp251x_enable_dma)
> +		dma_free_coherent(&spi->dev, PAGE_SIZE,
> +				  priv->spi_tx_buf, priv->spi_tx_dma);
> +error_alloc:
> +	dev_err(&spi->dev, "probe failed\n");
> +error_out:
> +	return ret;
> +}
> +
[snip]

We are close...

Wolfgang.
