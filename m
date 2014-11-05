From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH V2 1/4] can: m_can: update to support CAN FD features
Date: Wed, 05 Nov 2014 11:12:24 +0100
Message-ID: <5459F808.3020903@hartkopp.net>
References: <1415174326-6623-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, wg@grandegger.com, varkabhadram@gmail.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415174326-6623-1-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05.11.2014 08:58, Dong Aisheng wrote:

> @@ -327,41 +357,65 @@ static inline void m_can_disable_all_interrupts(const struct m_can_priv *priv)
>   	m_can_write(priv, M_CAN_ILE, 0x0);
>   }
>
> -static void m_can_read_fifo(const struct net_device *dev, struct can_frame *cf,
> -			    u32 rxfs)
> +static void m_can_read_fifo(struct net_device *dev, u32 rxfs)
>   {
> +	struct net_device_stats *stats = &dev->stats;
>   	struct m_can_priv *priv = netdev_priv(dev);
> -	u32 id, fgi;
> +	struct canfd_frame *cf;
> +	struct sk_buff *skb;
> +	u32 id, fgi, dlc;
> +	int i;
>
>   	/* calculate the fifo get index for where to read data */
>   	fgi = (rxfs & RXFS_FGI_MASK) >> RXFS_FGI_OFF;
> +	dlc = m_can_fifo_read(priv, fgi, M_CAN_FIFO_DLC);
> +	if (dlc & RX_BUF_EDL)
> +		skb = alloc_canfd_skb(dev, &cf);
> +	else
> +		skb = alloc_can_skb(dev, (struct can_frame **)&cf);

Yes. That's the way it should look like ;-)

> +	if (!skb) {
> +		stats->rx_dropped++;
> +		return;
> +	}
> +
>   	id = m_can_fifo_read(priv, fgi, M_CAN_FIFO_ID);
>   	if (id & RX_BUF_XTD)
>   		cf->can_id = (id & CAN_EFF_MASK) | CAN_EFF_FLAG;
>   	else
>   		cf->can_id = (id >> 18) & CAN_SFF_MASK;
>
> -	if (id & RX_BUF_RTR) {
> +	if (id & RX_BUF_ESI) {
> +		cf->flags |= CANFD_ESI;
> +		netdev_dbg(dev, "ESI Error\n");
> +	}
> +
> +	if (!(dlc & RX_BUF_EDL) && (id & RX_BUF_RTR)) {
>   		cf->can_id |= CAN_RTR_FLAG;
>   	} else {
>   		id = m_can_fifo_read(priv, fgi, M_CAN_FIFO_DLC);
> -		cf->can_dlc = get_can_dlc((id >> 16) & 0x0F);
> -		*(u32 *)(cf->data + 0) = m_can_fifo_read(priv, fgi,
> -							 M_CAN_FIFO_DATA(0));
> -		*(u32 *)(cf->data + 4) = m_can_fifo_read(priv, fgi,
> -							 M_CAN_FIFO_DATA(1));
> +		cf->len = can_dlc2len(get_canfd_dlc((id >> 16) & 0x0F));

if (dlc & RX_BUF_EDL)
	cf->len = can_dlc2len((id >> 16) & 0x0F);
else
	cf->len = get_can_dlc((id >> 16) & 0x0F);

(..)

> @@ -804,7 +870,8 @@ static void m_can_chip_config(struct net_device *dev)
>   		    RXFC_FWM_1 | priv->mcfg[MRAM_RXF1].off);
>
>   	cccr = m_can_read(priv, M_CAN_CCCR);
> -	cccr &= ~(CCCR_TEST | CCCR_MON);
> +	cccr &= ~(CCCR_TEST | CCCR_MON | (CCCR_CMR_MASK << CCCR_CMR_SHIFT) |
> +		(CCCR_CME_MASK << CCCR_CME_SHIFT));
>   	test = m_can_read(priv, M_CAN_TEST);
>   	test &= ~TEST_LBCK;
>
> @@ -816,6 +883,9 @@ static void m_can_chip_config(struct net_device *dev)
>   		test |= TEST_LBCK;
>   	}
>
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_FD)
> +		cccr |= CCCR_CME_CANFD_BRS << CCCR_CME_SHIFT;
> +
>   	m_can_write(priv, M_CAN_CCCR, cccr);
>   	m_can_write(priv, M_CAN_TEST, test);
>

(..)

>
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_FD) {
> +		cccr = m_can_read(priv, M_CAN_CCCR);
> +		cccr &= ~(CCCR_CMR_MASK << CCCR_CMR_SHIFT);
> +		if (cf->flags & CANFD_BRS)
> +			cccr |= CCCR_CMR_CANFD_BRS << CCCR_CMR_SHIFT;
> +		else
> +			cccr |= CCCR_CMR_CANFD << CCCR_CMR_SHIFT;
> +		m_can_write(priv, M_CAN_CCCR, cccr);
> +	}

Unfortunately No. Here it becomes complicated due to the fact that the 
revision 3.0.x does not support per-frame switching for FD/BRS ...

When (priv->can.ctrlmode & CAN_CTRLMODE_FD) is true this *only* tells us, that 
the controller is _capable_ to send either CAN or CAN FD frames.

It does not configure the controller into one of these specific settings!

Additionally: AFAIK when writing to the CCCR you have to make sure that 
there's currently no ongoing transfer.

I would suggest the following approach to make the revision 3.0.x act like a 
correct CAN FD capable controller:

- create a helper function to switch FD and BRS while taking care of ongoing 
transmissions

- create a variable that knows the current tx_mode for FD and BRS

When we need to send a CAN frame which doesn't fit the settings in the tx_mode 
we need to switch the CCCR and update the tx_mode variable.

This at least reduces the needed CCCR operations.

And it also addresses the intention of your patch
[PATCH V1 4/4] can: m_can: allow to send std frame on CAN FD mode

Regards,
Oliver

