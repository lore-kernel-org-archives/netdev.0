From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v3] Renesas Ethernet AVB driver
Date: Sun, 19 Apr 2015 11:19:25 +0200
Message-ID: <20150419091923.GA5714@netboy>
References: <32501816.HtkLenWQpn@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <32501816.HtkLenWQpn@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 14, 2015 at 01:07:38AM +0300, Sergei Shtylyov wrote:

> +static int ravb_wait(struct net_device *ndev, u16 reg, u32 mask, u32 value)
> +{
> +	int i;
> +
> +	for (i = 0; i < 10000; i++) {
> +		if ((ravb_read(ndev, reg) & mask) == value)
> +			return 0;
> +		udelay(10);
> +	}
> +	return -ETIMEDOUT;
> +}

This function performs a busy wait of up to 100 milliseconds.

It also has a return value.

> +/* function for waiting dma process finished */
> +static void ravb_wait_stop_dma(struct net_device *ndev)
> +{
> +	/* Wait for stopping the hardware TX process */
> +	ravb_wait(ndev, TCCR, TCCR_TSRQ0 | TCCR_TSRQ1 | TCCR_TSRQ2 | TCCR_TSRQ3,
> +		  0);
> +
> +	ravb_wait(ndev, CSR, CSR_TPO0 | CSR_TPO1 | CSR_TPO2 | CSR_TPO3, 0);

Ignores return value.

> +	/* Stop the E-MAC's RX processes. */
> +	ravb_write(ndev, ravb_read(ndev, ECMR) & ~ECMR_RE, ECMR);
> +
> +	/* Wait for stopping the RX DMA process */
> +	ravb_wait(ndev, CSR, CSR_RPO, 0);
> +}
> +
> +/* Caller must hold the lock */
> +static void ravb_ptp_update_compare(struct ravb_private *priv, u32 ns)
> +{
> +	struct net_device *ndev = priv->ndev;
> +	/* When the comparison value (GPTC.PTCV) is in range of
> +	 * [x-1 to x+1] (x is the configured increment value in
> +	 * GTI.TIV), it may happen that a comparison match is
> +	 * not detected when the timer wraps around.
> +	 */
> +	u32 gti_ns_plus_1 = (priv->ptp.current_addend >> 20) + 1;
> +
> +	if (ns < gti_ns_plus_1)
> +		ns = gti_ns_plus_1;
> +	else if (ns > 0 - gti_ns_plus_1)
> +		ns = 0 - gti_ns_plus_1;
> +
> +	ravb_write(ndev, ns, GPTC);
> +	ravb_write(ndev, ravb_read(ndev, GCCR) | GCCR_LPTC, GCCR);
> +	if (ravb_read(ndev, CSR) & CSR_OPS_OPERATION)
> +		ravb_wait(ndev, GCCR, GCCR_LPTC, 0);

Ignores return value.

> +}

> +static void ravb_ptp_tcr_request(struct ravb_private *priv, int request)
> +{
> +	struct net_device *ndev = priv->ndev;
> +
> +	if (ravb_read(ndev, CSR) & CSR_OPS_OPERATION) {
> +		ravb_wait(ndev, GCCR, GCCR_TCR, GCCR_TCR_NOREQ);
> +		ravb_write(ndev, ravb_read(ndev, GCCR) | request, GCCR);
> +		ravb_wait(ndev, GCCR, GCCR_TCR, GCCR_TCR_NOREQ);

Ignores return value.

> +	}
> +}

> +/* Caller must hold lock */
> +static void ravb_ptp_time_write(struct ravb_private *priv,
> +				const struct timespec64 *ts)
> +{
> +	struct net_device *ndev = priv->ndev;
> +
> +	ravb_ptp_tcr_request(priv, GCCR_TCR_RESET);
> +
> +	ravb_write(ndev, ts->tv_nsec, GTO0);
> +	ravb_write(ndev, ts->tv_sec,  GTO1);
> +	ravb_write(ndev, (ts->tv_sec >> 32) & 0xffff, GTO2);
> +	ravb_write(ndev, ravb_read(ndev, GCCR) | GCCR_LTO, GCCR);
> +	if (ravb_read(ndev, CSR) & CSR_OPS_OPERATION)
> +		ravb_wait(ndev, GCCR, GCCR_LTO, 0);

Ignores return value.

> +}
> +
> +/* Caller must hold lock */
> +static u64 ravb_ptp_cnt_read(struct ravb_private *priv)
> +{
> +	struct timespec64 ts;
> +	ktime_t kt;
> +
> +	ravb_ptp_time_read(priv, &ts);
> +	kt = timespec64_to_ktime(ts);
> +
> +	return ktime_to_ns(kt);
> +}
> +
> +/* Caller must hold lock */
> +static void ravb_ptp_cnt_write(struct ravb_private *priv, u64 ns)
> +{
> +	struct timespec64 ts = ns_to_timespec64(ns);
> +
> +	ravb_ptp_time_write(priv, &ts);
> +}
> +

> +/* Caller must hold lock */
> +static void ravb_ptp_select_counter(struct ravb_private *priv, u16 sel)
> +{
> +	struct net_device *ndev = priv->ndev;
> +	u32 val;
> +
> +	ravb_wait(ndev, GCCR, GCCR_TCR, GCCR_TCR_NOREQ);

Ignores return value.

> +	val = ravb_read(ndev, GCCR) & ~GCCR_TCSS;
> +	ravb_write(ndev, val | (sel << 8), GCCR);
> +}
> +
> +/* Caller must hold lock */
> +static void ravb_ptp_update_addend(struct ravb_private *priv, u32 addend)
> +{
> +	struct net_device *ndev = priv->ndev;
> +
> +	priv->ptp.current_addend = addend;
> +
> +	ravb_write(ndev, addend & GTI_TIV, GTI);
> +	ravb_write(ndev, ravb_read(ndev, GCCR) | GCCR_LTI, GCCR);
> +	if (ravb_read(ndev, CSR) & CSR_OPS_OPERATION)
> +		ravb_wait(ndev, GCCR, GCCR_LTI, 0);

Ignores return value.

> +}
> +
> +/* PTP clock operations */
> +static int ravb_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
> +{
> +	struct ravb_private *priv = container_of(ptp, struct ravb_private,
> +						 ptp.info);
> +	unsigned long flags;
> +	u32 diff, addend;
> +	int neg_adj = 0;
> +	u64 adj;
> +
> +	if (ppb < 0) {
> +		neg_adj = 1;
> +		ppb = -ppb;
> +	}
> +	addend = priv->ptp.default_addend;
> +	adj = addend;
> +	adj *= ppb;
> +	diff = div_u64(adj, NSEC_PER_SEC);
> +
> +	addend = neg_adj ? addend - diff : addend + diff;
> +
> +	spin_lock_irqsave(&priv->lock, flags);
> +	ravb_ptp_update_addend(priv, addend);

This is one example of many where you make a call to ravb_wait() while:

- holding a spinlock with interrupts disabled (for up to 100 milliseconds)
- ignoring the return value

> +	spin_unlock_irqrestore(&priv->lock, flags);
> +
> +	return 0;
> +}

The ravb_wait() callers follow this pattern.

   1. set a HW bit
   2. wait for HW bit to clear before continuing

I suggest using a another pattern instead.

   1. check HW bit is clear (from previous operation)
   2. if (!clear) return timeout error
   3. set a HW bit

   Step #1 should include a limited retry.

Your way blocks the CPU for a multiple of 10 usec every single time.
The way I suggested allows the CPU to go to other work while the bit
clears in parallel.

Thanks,
Richard





