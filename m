From: Alan Ott <alan@signal11.us>
Subject: Re: [Linux-zigbee-devel] [PATCH 1/2] mrf24j40: Avoid transmission
 while receiving a frame
Date: Mon, 13 May 2013 23:22:12 -0400
Message-ID: <5191ADE4.8040709@signal11.us>
References: <1368112788-25701-1-git-send-email-david@hauweele.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Hauweele <david@hauweele.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368112788-25701-1-git-send-email-david@hauweele.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/9/13 11:19 AM, David Hauweele wrote:
> The transceiver may fail under heavy traffic when a frame is transmitted
> while receiving another frame.
>
> This patch uses a mutex to separate the transmission and reception of
> frames along with a secondary working queue to avoid a deadlock while
> waiting for the transmission interrupt.
>

Have you observed this failure? I have put this kind of thing in before 
(several times actually) but ultimately convinced myself each time that 
it was not necessary. I'm happy to be shown wrong.


> Signed-off-by: David Hauweele <david@hauweele.net>
> ---
>   drivers/net/ieee802154/mrf24j40.c |   22 +++++++++++++++++++++-
>   1 file changed, 21 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
> index ede3ce4..1e3ddf3 100644
> --- a/drivers/net/ieee802154/mrf24j40.c
> +++ b/drivers/net/ieee802154/mrf24j40.c
> @@ -82,8 +82,10 @@ struct mrf24j40 {
>   	struct ieee802154_dev *dev;
>
>   	struct mutex buffer_mutex; /* only used to protect buf */
> +	struct mutex txrx_mutex; /* avoid transmission while receiving a frame */
>   	struct completion tx_complete;
>   	struct work_struct irqwork;
> +	struct work_struct rxwork;
>   	u8 *buf; /* 3 bytes. Used for SPI single-register transfers. */
>   };
>
> @@ -353,6 +355,8 @@ static int mrf24j40_tx(struct ieee802154_dev *dev, struct sk_buff *skb)
>   	/* Set TXNACKREQ if the ACK bit is set in the packet. */
>   	if (skb->data[0] & IEEE802154_FC_ACK_REQ)
>   		val |= 0x4;
> +
> +	mutex_lock(&devrec->txrx_mutex);
>   	write_short_reg(devrec, REG_TXNCON, val);
>
>   	INIT_COMPLETION(devrec->tx_complete);
> @@ -361,6 +365,9 @@ static int mrf24j40_tx(struct ieee802154_dev *dev, struct sk_buff *skb)
>   	ret = wait_for_completion_interruptible_timeout(
>   						&devrec->tx_complete,
>   						5 * HZ);
> +
> +	mutex_unlock(&devrec->txrx_mutex);
> +
>   	if (ret == -ERESTARTSYS)
>   		goto err;
>   	if (ret == 0) {
> @@ -535,6 +542,8 @@ static int mrf24j40_handle_rx(struct mrf24j40 *devrec)
>   	int ret = 0;
>   	struct sk_buff *skb;
>
> +	mutex_lock(&devrec->txrx_mutex);
> +
>   	/* Turn off reception of packets off the air. This prevents the
>   	 * device from overwriting the buffer while we're reading it. */
>   	ret = read_short_reg(devrec, REG_BBREG1, &val);
> @@ -575,6 +584,8 @@ out:
>   	val &= ~0x4; /* Clear RXDECINV */
>   	write_short_reg(devrec, REG_BBREG1, val);
>
> +	mutex_unlock(&devrec->txrx_mutex);
> +
>   	return ret;
>   }
>
> @@ -616,12 +627,19 @@ static void mrf24j40_isrwork(struct work_struct *work)
>
>   	/* Check for Rx */
>   	if (intstat & 0x8)
> -		mrf24j40_handle_rx(devrec);
> +		schedule_work(&devrec->rxwork);
>

mrf24f40_isrwork() is already called from a workqueue.

>   out:
>   	enable_irq(devrec->spi->irq);
>   }
>
> +static void mrf24j40_rxwork(struct work_struct *work)
> +{
> +	struct mrf24j40 *devrec = container_of(work, struct mrf24j40, rxwork);
> +
> +	mrf24j40_handle_rx(devrec);
> +}
> +
>   static int mrf24j40_probe(struct spi_device *spi)
>   {
>   	int ret = -ENOMEM;
> @@ -648,8 +666,10 @@ static int mrf24j40_probe(struct spi_device *spi)
>   		spi->max_speed_hz = MAX_SPI_SPEED_HZ;
>
>   	mutex_init(&devrec->buffer_mutex);
> +	mutex_init(&devrec->txrx_mutex);
>   	init_completion(&devrec->tx_complete);
>   	INIT_WORK(&devrec->irqwork, mrf24j40_isrwork);
> +	INIT_WORK(&devrec->rxwork, mrf24j40_rxwork);
>   	devrec->spi = spi;
>   	spi_set_drvdata(spi, devrec);
>
>
