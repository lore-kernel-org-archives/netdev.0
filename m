From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Wed, 11 Nov 2015 00:40:09 +0000
Message-ID: <yw1xio59pdw6.fsf@unicorn.mansr.com>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
	<20151110233448.GA8646@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slash.tmp@free.fr
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151110233448.GA8646@electric-eye.fr.zoreil.com> (Francois
	Romieu's message of "Wed, 11 Nov 2015 00:34:48 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rancois Romieu <romieu@fr.zoreil.com> writes:

> Mans Rullgard <mans@mansr.com> :
>> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethe=
rnet/aurora/nb8800.c
>> new file mode 100644
>> index 0000000..11cd389
>> --- /dev/null
>> +++ b/drivers/net/ethernet/aurora/nb8800.c
> [...]
>> +static int nb8800_xmit(struct sk_buff *skb, struct net_device *dev)
>> +{
> [...]
>> +
>> +	netdev_sent_queue(dev, skb->len);
>> +
>> +	smp_mb__before_spinlock();
>> +	spin_lock_irqsave(&priv->tx_lock, flags);
>
> At some point you may consider performing both Tx and Rx from napi co=
ntext
> and thus replacing priv->tx_lock with netif_tx_lock.

That lock is to synchronise the DMA start between nb8800_xmit() and the
interrupt handler.  When the DMA complete interrupt arrives, the next
chain should be kicked off as quickly as possible, and I don't see why
that would benefit from being done in napi context.

>> +
>> +	if (!skb->xmit_more) {
>> +		priv->tx_chain->ready =3D true;
>> +		priv->tx_chain =3D NULL;
>> +		nb8800_tx_dma_start(dev);
>> +	}
>> +
>> +	spin_unlock_irqrestore(&priv->tx_lock, flags);
>> +
>> +	priv->tx_next =3D next;
>
> Are there strong reasons why nb8800_tx_done could not kick between
> spin_unlock_irqrestore and the non-local update of priv->tx_next ?

Good catch.  priv->tx_next wasn't accessed elsewhere in an earlier
version, and I forgot to fix that.  nb8800_tx_done() makes sure the DMA
has actually finished, so priv->tx_next should be updated before
starting the DMA rather than after.  The check against tx_next in
nb8800_tx_done() is only to put some limit on the loop and to avoid
confusion when nb8800_dma_stop() does it's dance.  There should be no
need for more synchronisation here than what the already present memory
barriers provide.

> [...]
>> +static irqreturn_t nb8800_irq(int irq, void *dev_id)
>> +{
>> +	struct net_device *dev =3D dev_id;
>> +	struct nb8800_priv *priv =3D netdev_priv(dev);
>> +	u32 val;
>> +
>> +	/* tx interrupt */
>> +	val =3D nb8800_readl(priv, NB8800_TXC_SR);
>> +	if (val) {
> [...]
>> +	}
>> +
>> +	/* rx interrupt */
>> +	val =3D nb8800_readl(priv, NB8800_RXC_SR);
>> +	if (val) {
> [...]
>> +	}
>> +
>> +	return IRQ_HANDLED;
>
> Returning IRQ_HANDLED is fine if one of those hold:
> 1. you're sure that at least one of the "if" branch is used
> 2. you'll be able to quickly figure out what's happening whenever 1. =
stops
>    being true.

You're right, better to check that the device really did have something
to say.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
