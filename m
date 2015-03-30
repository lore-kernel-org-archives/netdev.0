From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH resend] Renesas Ethernet AVB driver
Date: Tue, 31 Mar 2015 01:51:44 +0300
Message-ID: <5519D380.6070200@cogentembedded.com>
References: <2926619.fiYHPz1IBk@wasted.cogentembedded.com> <20150328082853.GA4255@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	masaru.nagai.vx@renesas.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20150328082853.GA4255@localhost.localdomain>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/28/2015 11:28 AM, Richard Cochran wrote:

>> Ethernet AVB includes an Gigabit Ethernet controller (E-MAC) that is basically
>> compatible with SuperH Gigabit Ethernet E-MAC). Ethernet AVB  has a dedicated
>> direct memory access controller (AVB-DMAC) that is a new design compared to the
>> SuperH E-DMAC. The AVB-DMAC is compliant with 3 standards formulated for IEEE
>> 802.1BA: IEEE 802.1AS timing and synchronization protocol, IEEE 802.1Qav real-
>> time transfer, and the IEEE 802.1Qat stream reservation protocol.

> Since this is a PTP Hardware Clock driver, why not include the maintainer on CC?

    Sorry for leaving you out of CC. I used the list given by 
scripts/get_maintainer.pl and forgot for the moment that it's also a PTP 
driver. Perhaps there is a way to enhance that script for this particular case 
(I'm not into PERL myself)?

>> The driver only supports device tree probing, so the binding document is
>> included in this patch.

>> Based on the patches by Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com> and
>> Masaru Nagai <masaru.nagai.vx@renesas.com>.

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> We also need SOB from Mitsuhiro and Masaru.

    Hmm, it's the first time I encounter such requirement.
    Not sure how you imagine that if Kimura-san was (mostly) the author of the 
Ethernet driver proper and Nagai-san was the author of the PTP code proper 
(they were 2 different drivers, not sure for what reason -- as the Ethernet 
driver proper failed to compile without PTP enabled for me). Adding them to 
CC: anyway...

> ...

>> Index: net-next/drivers/net/ethernet/renesas/ravb.c
>> ===================================================================
>> --- /dev/null
>> +++ net-next/drivers/net/ethernet/renesas/ravb.c
>> @@ -0,0 +1,3071 @@
[...]

>> +/* There is CPU dependent code */
>> +static int ravb_wait_clear(struct net_device *ndev, u16 reg, u32 bits)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < 100; i++) {
>> +		if (!(ravb_read(ndev, reg) & bits))
>> +			break;
>> +		mdelay(1);
>> +	}
>> +	if (i >= 100)
>> +		return -ETIMEDOUT;
>> +
>> +	return 0;
>> +}
>> +
>> +static int ravb_wait_setting(struct net_device *ndev, u16 reg, u32 bits)
>> +{

> This function is identical to the previous one.

    It is not, the *break* condition is different. I'll look into merging them 
though...

>> +	int i;
>> +
>> +	for (i = 0; i < 100; i++) {
>> +		if (ravb_read(ndev, reg) & bits)
>> +			break;
>> +		mdelay(1);
>> +	}
>> +	if (i >= 100)
>> +		return -ETIMEDOUT;
>> +
>> +	return 0;
>> +}
[...]
>> +static void ravb_get_tx_tstamp(struct net_device *ndev)
>> +{
>> +	struct ravb_private *priv = netdev_priv(ndev);
>> +	struct ravb_tstamp_skb *ts_skb, *ts_skb1;
>> +	struct skb_shared_hwtstamps shhwtstamps;
>> +	struct sk_buff *skb;
>> +	struct timespec ts;

> For new drivers, please use timespec64.

    OK, got it.

[...]
>> +/* Caller must hold the lock */
>> +static void ravb_ptp_update_compare(struct ravb_private *priv, u32 ns)
>> +{
>> +	struct net_device *ndev = priv->ndev;
>> +	/* When the comparison value (GPTC.PTCV) is in range of
>> +	 * [x-1 to x+1] (x is the configured increment value in
>> +	 * GTI.TIV), it may happen that a comparison match is
>> +	 * not detected when the timer wraps around.
>> +	 */

> What does this funtion do, exactly?  This looks very fishy to me.

    Perhaps a workaround for an errata I don't know about. Nagai-san, could 
you maybe elaborate?

>> +	u32 gti_ns_plus_1 = (priv->ptp.current_addend >> 20) + 1;
>> +
>> +	if (ns < gti_ns_plus_1)
>> +		ns = gti_ns_plus_1;
>> +	else if (ns > 0 - gti_ns_plus_1)
>> +		ns = 0 - gti_ns_plus_1;
>> +
>> +	ravb_write(ndev, ns, GPTC);
>> +	ravb_write(ndev, ravb_read(ndev, GCCR) | GCCR_LPTC, GCCR);
>> +	if (ravb_read(ndev, CSR) & CSR_OPS_OPERATION)
>> +		while (ravb_read(ndev, GCCR) & GCCR_LPTC)
>> +			;

> Infinite loop while holding a spin lock = not good.

    Sure. I've spent over 3 weeks cleaning this stuff up, yet still it wasn't 
enough... :-/

[...]
>> +static irqreturn_t ravb_interrupt(int irq, void *dev_id)
>> +{

>> +	if (iss & ISS_CGIS) {
>> +		u32 gis = ravb_read(ndev, GIS);
>> +
>> +		gis &= ravb_read(ndev, GIC);
>> +		if (gis & GIS_PTCF) {
>> +			struct ptp_clock_event event;
>> +
>> +			event.type = PTP_CLOCK_EXTTS;
>> +			event.index = 0;
>> +			event.timestamp = ravb_read(ndev, GCPT);
>> +			ptp_clock_event(priv->ptp.clock, &event);
>> +		}
>> +		if (gis & GIS_PTMF) {
>> +			struct ravb_ptp_perout *perout = priv->ptp.perout;
>> +
>> +			if (perout->period) {
>> +				perout->target += perout->period;
>> +				ravb_ptp_update_compare(priv, perout->target);

> Infinite loop in an interrupt handler. Brilliant.

    The prize goes to Nagai-san. :-)

[...]
>> +/* Packet transmit function for Ethernet AVB */
>> +static int ravb_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>> +{
>> +	struct ravb_private *priv = netdev_priv(ndev);
>> +	struct ravb_tstamp_skb *ts_skb = NULL;
>> +	struct ravb_tx_desc *desc;
>> +	unsigned long flags;
>> +	void *buffer;
>> +	u32 entry;
>> +	u32 tccr;
>> +	int q;
>> +
>> +	/* If skb needs TX timestamp, it is handled in network control queue */
>> +	q = (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) ? RAVB_NC : RAVB_BE;
>> +
>> +	spin_lock_irqsave(&priv->lock, flags);
>> +	if (priv->cur_tx[q] - priv->dirty_tx[q] >= priv->num_tx_ring[q] - 4) {
>> +		if (!ravb_tx_free(ndev, q)) {
>> +			netif_warn(priv, tx_queued, ndev, "TX FD exhausted.\n");
>> +			netif_stop_queue(ndev);
>> +			spin_unlock_irqrestore(&priv->lock, flags);
>> +			return NETDEV_TX_BUSY;
>> +		}
>> +	}
>> +	entry = priv->cur_tx[q] % priv->num_tx_ring[q];
>> +	priv->cur_tx[q]++;
>> +	spin_unlock_irqrestore(&priv->lock, flags);
>> +
>> +	if (skb_put_padto(skb, ETH_ZLEN))
>> +		return NETDEV_TX_OK;
>> +
>> +	priv->tx_skb[q][entry] = skb;
>> +	buffer = PTR_ALIGN(priv->tx_buffers[q][entry], RAVB_ALIGN);
>> +	memcpy(buffer, skb->data, skb->len);
>> +	desc = &priv->tx_ring[q][entry];
>> +	desc->ds = skb->len;
>> +	desc->dptr = dma_map_single(&ndev->dev, buffer, skb->len,
>> +				    DMA_TO_DEVICE);
>> +	if (dma_mapping_error(&ndev->dev, desc->dptr)) {
>> +		dev_kfree_skb_any(skb);
>> +		priv->tx_skb[q][entry] = NULL;
>> +		return NETDEV_TX_OK;
>> +	}
>> +
>> +	/* TX timestamp required */
>> +	if (q == RAVB_NC) {
>> +		ts_skb = kmalloc(sizeof(*ts_skb), GFP_ATOMIC);
>> +		if (!ts_skb) {
>> +			netdev_err(ndev,
>> +				   "Cannot allocate skb list element for HW timestamp\n");
>> +			return -ENOMEM;
>> +		}
>> +		ts_skb->skb = skb;
>> +		ts_skb->tag = priv->ts_skb_tag++;
>> +		priv->ts_skb_tag %= 0x400;
>> +		list_add_tail(&ts_skb->list, &priv->ts_skb_list);
>> +
>> +		/* TAG and timestamp required flag */
>> +		skb_tx_timestamp(skb);
>> +		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;

> Wrong order WRT skb_tx_timestamp() and SKBTX_IN_PROGRESS.

>  From skbuff.h:

> 	/* device driver is going to provide hardware time stamp */
> 	SKBTX_IN_PROGRESS = 1 << 2,

    OK, thank you!

[...]

>> +	}
>> +}
>> +
>> +static bool ravb_ptp_is_config(struct ravb_private *priv)
>> +{

> This is a bit hacky.  Can't your driver make sure that the HW is ready?

    Will look into this. Perhaps it's a remainder from when the PTP driver was 
separate...

>> +	if (ravb_read(priv->ndev, CSR) & CSR_OPS_CONFIG)
>> +		return true;
>> +	else
>> +		return false;
>> +}
>> +
[...]
>> +static int ravb_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
>> +{
>> +	struct ravb_private *priv = container_of(ptp, struct ravb_private,
>> +						 ptp.info);
>> +	unsigned long flags;
>> +	u64 now;
>> +
>> +	if (ravb_ptp_is_config(priv))
>> +		return -EBUSY;
>> +
>> +	spin_lock_irqsave(&priv->lock, flags);
>> +	now = ravb_ptp_cnt_read(priv);
>> +	now += delta;
>> +	ravb_ptp_cnt_write(priv, now);
>> +	spin_unlock_irqrestore(&priv->lock, flags);
>> +
>> +	return 0;
>> +}
>> +
>> +static int ravb_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)

> The PHC driver API will be changing to timespec64 soon.
> (See recent patch series.)

     I know. Let's talk when it changes. :-)

[...]
>> +static int ravb_ptp_perout(struct ptp_clock_info *ptp,
>> +			   struct ptp_perout_request *req, int on)
>> +{
>> +	struct ravb_private *priv = container_of(ptp, struct ravb_private,
>> +						 ptp.info);
>> +	struct net_device *ndev = priv->ndev;
>> +	struct ravb_ptp_perout *perout;
>> +	unsigned long flags;
>> +	u32 gic;
>> +
>> +	if (req->index)
>> +		return -EINVAL;
>> +
>> +	if (on) {
>> +		u64 start_ns;
>> +		u64 period_ns;
>> +
>> +		start_ns = req->start.sec * NSEC_PER_SEC + req->start.nsec;
>> +		period_ns = req->period.sec * NSEC_PER_SEC + req->period.nsec;
>> +
>> +		if (start_ns > U32_MAX) {
>> +			netdev_warn(ndev,
>> +				    "ptp: Start value (nsec) is over limit. Maximum size of start is only 32 bits\n");

> This line is rather long.

    So what? The lines containing the message strings have no limit on the 
length AFAIK, yet it seems to me the resulting message should fit into 80 columns.

[...]
> Thanks,
> Richard

[...]

>> +MODULE_AUTHOR("Mitsuhiro Kimura");

    OK, should have probably added Nagai-san here...

WBR, Sergei

