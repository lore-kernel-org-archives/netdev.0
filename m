From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] can: mcp251x: Move to threaded interrupts
	instead of workqueues.
Date: Sat, 30 Jan 2010 20:49:19 +0100
Message-ID: <4B648D3F.30909@grandegger.com>
References: <1264857564-3917-1-git-send-email-chripell@fsfe.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1264857564-3917-1-git-send-email-chripell-VaTbYqLCNhc@public.gmane.org>
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

Hi Christian,

Christian Pellegrin wrote:
> This patch addresses concerns about efficiency of handling incoming packets. Handling of
> interrupts is done in a threaded interrupt handler which has a smaller latency than workqueues.
> This change needed a rework of the locking scheme that was much simplified. Some other
> (more or less longstanding) bugs are fixed: utilization of just half of the RX buffers,
> useless wait for interrupt on open, more reliable reset sequence. The MERR interrupt is
> not used anymore: it overloads the CPU in bus-off state without any additional information.

Could you please truncate the lines to the usual 72 (or 80) characters
per line?

> Signed-off-by: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
> ---
>  drivers/net/can/mcp251x.c |  353 +++++++++++++++++++++++----------------------
>  1 files changed, 179 insertions(+), 174 deletions(-)
> 
> diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
> index bbe186b..03a20c3 100644
> --- a/drivers/net/can/mcp251x.c
> +++ b/drivers/net/can/mcp251x.c
> @@ -180,6 +180,14 @@
>  #define RXBEID0_OFF 4
>  #define RXBDLC_OFF  5
>  #define RXBDAT_OFF  6
> +#define RXFSIDH(n) ((n) * 4)
> +#define RXFSIDL(n) ((n) * 4 + 1)
> +#define RXFEID8(n) ((n) * 4 + 2)
> +#define RXFEID0(n) ((n) * 4 + 3)
> +#define RXMSIDH(n) ((n) * 4 + 0x20)
> +#define RXMSIDL(n) ((n) * 4 + 0x21)
> +#define RXMEID8(n) ((n) * 4 + 0x22)
> +#define RXMEID0(n) ((n) * 4 + 0x23)
>  
>  #define GET_BYTE(val, byte)			\
>  	(((val) >> ((byte) * 8)) & 0xff)
> @@ -219,7 +227,8 @@ struct mcp251x_priv {
>  	struct net_device *net;
>  	struct spi_device *spi;
>  
> -	struct mutex spi_lock; /* SPI buffer lock */
> +	struct mutex mcp_lock; /* SPI device lock */
> +
>  	u8 *spi_tx_buf;
>  	u8 *spi_rx_buf;
>  	dma_addr_t spi_tx_dma;
> @@ -227,11 +236,11 @@ struct mcp251x_priv {
>  
>  	struct sk_buff *tx_skb;
>  	int tx_len;
> +
>  	struct workqueue_struct *wq;
>  	struct work_struct tx_work;
> -	struct work_struct irq_work;
> -	struct completion awake;
> -	int wake;
> +	struct work_struct restart_work;
> +
>  	int force_quit;
>  	int after_suspend;
>  #define AFTER_SUSPEND_UP 1
> @@ -241,11 +250,17 @@ struct mcp251x_priv {
>  	int restart_tx;
>  };
>  
> +/* Delayed work functions */
> +static irqreturn_t mcp251x_can_ist(int irq, void *dev_id);
> +static void mcp251x_restart_work_handler(struct work_struct *ws);
> +static void mcp251x_tx_work_handler(struct work_struct *ws);

Any chance to get rid of these forward declarations (by reordering them)?

>  static void mcp251x_clean(struct net_device *net)
>  {
>  	struct mcp251x_priv *priv = netdev_priv(net);
>  
> -	net->stats.tx_errors++;
> +	if (priv->tx_skb || priv->tx_len)
> +		net->stats.tx_errors++;
>  	if (priv->tx_skb)
>  		dev_kfree_skb(priv->tx_skb);
>  	if (priv->tx_len)
> @@ -300,16 +315,12 @@ static u8 mcp251x_read_reg(struct spi_device *spi, uint8_t reg)
>  	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
>  	u8 val = 0;
>  
> -	mutex_lock(&priv->spi_lock);
> -
>  	priv->spi_tx_buf[0] = INSTRUCTION_READ;
>  	priv->spi_tx_buf[1] = reg;
>  
>  	mcp251x_spi_trans(spi, 3);
>  	val = priv->spi_rx_buf[2];
>  
> -	mutex_unlock(&priv->spi_lock);
> -
>  	return val;
>  }
>  
> @@ -317,15 +328,11 @@ static void mcp251x_write_reg(struct spi_device *spi, u8 reg, uint8_t val)
>  {
>  	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
>  
> -	mutex_lock(&priv->spi_lock);
> -
>  	priv->spi_tx_buf[0] = INSTRUCTION_WRITE;
>  	priv->spi_tx_buf[1] = reg;
>  	priv->spi_tx_buf[2] = val;
>  
>  	mcp251x_spi_trans(spi, 3);
> -
> -	mutex_unlock(&priv->spi_lock);
>  }
>  
>  static void mcp251x_write_bits(struct spi_device *spi, u8 reg,
> @@ -333,16 +340,12 @@ static void mcp251x_write_bits(struct spi_device *spi, u8 reg,
>  {
>  	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
>  
> -	mutex_lock(&priv->spi_lock);
> -
>  	priv->spi_tx_buf[0] = INSTRUCTION_BIT_MODIFY;
>  	priv->spi_tx_buf[1] = reg;
>  	priv->spi_tx_buf[2] = mask;
>  	priv->spi_tx_buf[3] = val;
>  
>  	mcp251x_spi_trans(spi, 4);
> -
> -	mutex_unlock(&priv->spi_lock);
>  }
>  
>  static void mcp251x_hw_tx_frame(struct spi_device *spi, u8 *buf,
> @@ -358,10 +361,8 @@ static void mcp251x_hw_tx_frame(struct spi_device *spi, u8 *buf,
>  			mcp251x_write_reg(spi, TXBCTRL(tx_buf_idx) + i,
>  					  buf[i]);
>  	} else {
> -		mutex_lock(&priv->spi_lock);
>  		memcpy(priv->spi_tx_buf, buf, TXBDAT_OFF + len);
>  		mcp251x_spi_trans(spi, TXBDAT_OFF + len);
> -		mutex_unlock(&priv->spi_lock);
>  	}
>  }
>  
> @@ -408,13 +409,9 @@ static void mcp251x_hw_rx_frame(struct spi_device *spi, u8 *buf,
>  		for (; i < (RXBDAT_OFF + len); i++)
>  			buf[i] = mcp251x_read_reg(spi, RXBCTRL(buf_idx) + i);
>  	} else {
> -		mutex_lock(&priv->spi_lock);
> -
>  		priv->spi_tx_buf[RXBCTRL_OFF] = INSTRUCTION_READ_RXB(buf_idx);
>  		mcp251x_spi_trans(spi, SPI_TRANSFER_BUF_LEN);
>  		memcpy(buf, priv->spi_rx_buf, SPI_TRANSFER_BUF_LEN);
> -
> -		mutex_unlock(&priv->spi_lock);
>  	}
>  }
>  
> @@ -467,21 +464,6 @@ static void mcp251x_hw_sleep(struct spi_device *spi)
>  	mcp251x_write_reg(spi, CANCTRL, CANCTRL_REQOP_SLEEP);
>  }
>  
> -static void mcp251x_hw_wakeup(struct spi_device *spi)
> -{
> -	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
> -
> -	priv->wake = 1;
> -
> -	/* Can only wake up by generating a wake-up interrupt. */
> -	mcp251x_write_bits(spi, CANINTE, CANINTE_WAKIE, CANINTE_WAKIE);
> -	mcp251x_write_bits(spi, CANINTF, CANINTF_WAKIF, CANINTF_WAKIF);
> -
> -	/* Wait until the device is awake */
> -	if (!wait_for_completion_timeout(&priv->awake, HZ))
> -		dev_err(&spi->dev, "MCP251x didn't wake-up\n");
> -}
> -
>  static netdev_tx_t mcp251x_hard_start_xmit(struct sk_buff *skb,
>  					   struct net_device *net)
>  {
> @@ -490,7 +472,15 @@ static netdev_tx_t mcp251x_hard_start_xmit(struct sk_buff *skb,
>  
>  	if (priv->tx_skb || priv->tx_len) {
>  		dev_warn(&spi->dev, "hard_xmit called while tx busy\n");
> -		netif_stop_queue(net);
> +		/*
> +		 * Note: we may see this message on recovery from bus-off.
> +		 * This happens because can_restart calls netif_carrier_on
> +		 * before the restart worqueue has had a chance to run and

s/worqueue/workqueue/

> +		 * clear the TX logic.
> +		 * This message is worrisome (because it points out
> +		 * something wrong with locking logic) if seen when
> +		 * there is no bus-off recovery going on.
> +		 */

Before it calls netif_carrier_on, it calls the drivers "do_set_mode"
callback. See:

http://lxr.linux.no/#linux+v2.6.32/drivers/net/can/dev.c#L383

Is there a way to clear the TX logic in the "do_set_mode" callback?

>  		return NETDEV_TX_BUSY;
>  	}
>  
> @@ -516,7 +506,7 @@ static int mcp251x_do_set_mode(struct net_device *net, enum can_mode mode)
>  		priv->restart_tx = 1;
>  		if (priv->can.restart_ms == 0)
>  			priv->after_suspend = AFTER_SUSPEND_RESTART;
> -		queue_work(priv->wq, &priv->irq_work);
> +		queue_work(priv->wq, &priv->restart_work);
>  		break;
>  	default:
>  		return -EOPNOTSUPP;
> @@ -525,7 +515,7 @@ static int mcp251x_do_set_mode(struct net_device *net, enum can_mode mode)
>  	return 0;
>  }
>  
> -static void mcp251x_set_normal_mode(struct spi_device *spi)
> +static int mcp251x_set_normal_mode(struct spi_device *spi)
>  {
>  	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
>  	unsigned long timeout;
> @@ -533,8 +523,7 @@ static void mcp251x_set_normal_mode(struct spi_device *spi)
>  	/* Enable interrupts */
>  	mcp251x_write_reg(spi, CANINTE,
>  			  CANINTE_ERRIE | CANINTE_TX2IE | CANINTE_TX1IE |
> -			  CANINTE_TX0IE | CANINTE_RX1IE | CANINTE_RX0IE |
> -			  CANINTF_MERRF);
> +			  CANINTE_TX0IE | CANINTE_RX1IE | CANINTE_RX0IE);
>  
>  	if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
>  		/* Put device into loopback mode */
> @@ -555,11 +544,12 @@ static void mcp251x_set_normal_mode(struct spi_device *spi)
>  			if (time_after(jiffies, timeout)) {
>  				dev_err(&spi->dev, "MCP251x didn't"
>  					" enter in normal mode\n");
> -				return;
> +				return -EBUSY;
>  			}
>  		}
>  	}
>  	priv->can.state = CAN_STATE_ERROR_ACTIVE;
> +	return 0;
>  }
>  
>  static int mcp251x_do_set_bittiming(struct net_device *net)
> @@ -590,33 +580,39 @@ static int mcp251x_setup(struct net_device *net, struct mcp251x_priv *priv,
>  {
>  	mcp251x_do_set_bittiming(net);
>  
> -	/* Enable RX0->RX1 buffer roll over and disable filters */
> -	mcp251x_write_bits(spi, RXBCTRL(0),
> -			   RXBCTRL_BUKT | RXBCTRL_RXM0 | RXBCTRL_RXM1,
> -			   RXBCTRL_BUKT | RXBCTRL_RXM0 | RXBCTRL_RXM1);
> -	mcp251x_write_bits(spi, RXBCTRL(1),
> -			   RXBCTRL_RXM0 | RXBCTRL_RXM1,
> -			   RXBCTRL_RXM0 | RXBCTRL_RXM1);
> +	mcp251x_write_reg(spi, RXBCTRL(0),
> +			  RXBCTRL_BUKT | RXBCTRL_RXM0 | RXBCTRL_RXM1);
> +	mcp251x_write_reg(spi, RXBCTRL(1),
> +			  RXBCTRL_RXM0 | RXBCTRL_RXM1);
>  	return 0;
>  }
>  
> -static void mcp251x_hw_reset(struct spi_device *spi)
> +static int mcp251x_hw_reset(struct spi_device *spi)
>  {
>  	struct mcp251x_priv *priv = dev_get_drvdata(&spi->dev);
>  	int ret;
> -
> -	mutex_lock(&priv->spi_lock);
> +	unsigned long timeout;
>  
>  	priv->spi_tx_buf[0] = INSTRUCTION_RESET;
> -
>  	ret = spi_write(spi, priv->spi_tx_buf, 1);
> -
> -	mutex_unlock(&priv->spi_lock);
> -
> -	if (ret)
> +	if (ret) {
>  		dev_err(&spi->dev, "reset failed: ret = %d\n", ret);
> +		return -EIO;
> +	}
> +
>  	/* Wait for reset to finish */
> +	timeout = jiffies + HZ;
>  	mdelay(10);
> +	while ((mcp251x_read_reg(spi, CANSTAT) & CANCTRL_REQOP_MASK)
> +	       != CANCTRL_REQOP_CONF) {
> +		schedule();
> +		if (time_after(jiffies, timeout)) {
> +			dev_err(&spi->dev, "MCP251x didn't"
> +				" enter in conf mode after reset\n");
> +			return -EBUSY;
> +		}
> +	}
> +	return 0;
>  }
>  
>  static int mcp251x_hw_probe(struct spi_device *spi)
> @@ -640,16 +636,17 @@ static int mcp251x_hw_probe(struct spi_device *spi)
>  	return (st1 == 0x80 && st2 == 0x07) ? 1 : 0;
>  }
>  
> -static irqreturn_t mcp251x_can_isr(int irq, void *dev_id)
> +static void mcp251x_open_clean(struct net_device *net)
>  {
> -	struct net_device *net = (struct net_device *)dev_id;
>  	struct mcp251x_priv *priv = netdev_priv(net);
> +	struct spi_device *spi = priv->spi;
> +	struct mcp251x_platform_data *pdata = spi->dev.platform_data;
>  
> -	/* Schedule bottom half */
> -	if (!work_pending(&priv->irq_work))
> -		queue_work(priv->wq, &priv->irq_work);
> -
> -	return IRQ_HANDLED;
> +	free_irq(spi->irq, priv);
> +	mcp251x_hw_sleep(spi);
> +	if (pdata->transceiver_enable)
> +		pdata->transceiver_enable(0);
> +	close_candev(net);
>  }
>  
>  static int mcp251x_open(struct net_device *net)
> @@ -665,6 +662,7 @@ static int mcp251x_open(struct net_device *net)
>  		return ret;
>  	}
>  
> +	mutex_lock(&priv->mcp_lock);
>  	if (pdata->transceiver_enable)
>  		pdata->transceiver_enable(1);
>  
> @@ -672,31 +670,40 @@ static int mcp251x_open(struct net_device *net)
>  	priv->tx_skb = NULL;
>  	priv->tx_len = 0;
>  
> -	ret = request_irq(spi->irq, mcp251x_can_isr,
> -			  IRQF_TRIGGER_FALLING, DEVICE_NAME, net);
> +	ret = request_threaded_irq(spi->irq, NULL, mcp251x_can_ist,
> +			  IRQF_TRIGGER_FALLING, DEVICE_NAME, priv);
>  	if (ret) {
>  		dev_err(&spi->dev, "failed to acquire irq %d\n", spi->irq);
>  		if (pdata->transceiver_enable)
>  			pdata->transceiver_enable(0);
>  		close_candev(net);
> -		return ret;
> +		goto open_unlock;
>  	}
>  
> -	mcp251x_hw_wakeup(spi);
> -	mcp251x_hw_reset(spi);
> +	priv->wq = create_freezeable_workqueue("mcp251x_wq");
> +	INIT_WORK(&priv->tx_work, mcp251x_tx_work_handler);
> +	INIT_WORK(&priv->restart_work, mcp251x_restart_work_handler);
> +
> +	ret = mcp251x_hw_reset(spi);
> +	if (ret) {
> +		mcp251x_open_clean(net);
> +		goto open_unlock;
> +	}
>  	ret = mcp251x_setup(net, priv, spi);
>  	if (ret) {
> -		free_irq(spi->irq, net);
> -		mcp251x_hw_sleep(spi);
> -		if (pdata->transceiver_enable)
> -			pdata->transceiver_enable(0);
> -		close_candev(net);
> -		return ret;
> +		mcp251x_open_clean(net);
> +		goto open_unlock;
> +	}
> +	ret = mcp251x_set_normal_mode(spi);
> +	if (ret) {
> +		mcp251x_open_clean(net);
> +		goto open_unlock;
>  	}
> -	mcp251x_set_normal_mode(spi);
>  	netif_wake_queue(net);
>  
> -	return 0;
> +open_unlock:
> +	mutex_unlock(&priv->mcp_lock);
> +	return ret;
>  }
>  
>  static int mcp251x_stop(struct net_device *net)
> @@ -707,17 +714,19 @@ static int mcp251x_stop(struct net_device *net)
>  
>  	close_candev(net);
>  
> +	priv->force_quit = 1;
> +	free_irq(spi->irq, priv);
> +	destroy_workqueue(priv->wq);
> +	priv->wq = NULL;
> +
> +	mutex_lock(&priv->mcp_lock);
> +
>  	/* Disable and clear pending interrupts */
>  	mcp251x_write_reg(spi, CANINTE, 0x00);
>  	mcp251x_write_reg(spi, CANINTF, 0x00);
>  
> -	priv->force_quit = 1;
> -	free_irq(spi->irq, net);
> -	flush_workqueue(priv->wq);
> -
>  	mcp251x_write_reg(spi, TXBCTRL(0), 0);
> -	if (priv->tx_skb || priv->tx_len)
> -		mcp251x_clean(net);
> +	mcp251x_clean(net);
>  
>  	mcp251x_hw_sleep(spi);
>  
> @@ -726,9 +735,27 @@ static int mcp251x_stop(struct net_device *net)
>  
>  	priv->can.state = CAN_STATE_STOPPED;
>  
> +	mutex_unlock(&priv->mcp_lock);
> +
>  	return 0;
>  }
>  
> +static void mcp251x_error_skb(struct net_device *net, int can_id, int data1)
> +{
> +	struct sk_buff *skb;
> +	struct can_frame *frame;
> +
> +	skb = alloc_can_err_skb(net, &frame);
> +	if (skb) {
> +		frame->can_id = can_id;
> +		frame->data[1] = data1;
> +		netif_rx(skb);
> +	} else {
> +		dev_info(&net->dev,
> +			 "cannot allocate error skb\n");

dev_err?

> +	}
> +}
> +
>  static void mcp251x_tx_work_handler(struct work_struct *ws)
>  {
>  	struct mcp251x_priv *priv = container_of(ws, struct mcp251x_priv,
> @@ -737,14 +764,16 @@ static void mcp251x_tx_work_handler(struct work_struct *ws)
>  	struct net_device *net = priv->net;
>  	struct can_frame *frame;
>  
> +	mutex_lock(&priv->mcp_lock);
>  	if (priv->tx_skb) {
>  		frame = (struct can_frame *)priv->tx_skb->data;
>  
>  		if (priv->can.state == CAN_STATE_BUS_OFF) {
>  			mcp251x_clean(net);
>  			netif_wake_queue(net);
> -			return;
> +			goto restart_work_unlock;
>  		}

		} else { ? To get rid of the label.

> +
>  		if (frame->can_dlc > CAN_FRAME_MAX_DATA_LEN)
>  			frame->can_dlc = CAN_FRAME_MAX_DATA_LEN;
>  		mcp251x_hw_tx(spi, frame, 0);
> @@ -752,18 +781,18 @@ static void mcp251x_tx_work_handler(struct work_struct *ws)
>  		can_put_echo_skb(priv->tx_skb, net, 0);
>  		priv->tx_skb = NULL;
>  	}
> +restart_work_unlock:
> +	mutex_unlock(&priv->mcp_lock);
>  }

Wolfgang.
