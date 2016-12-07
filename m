From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC PATCH net-next v3 1/2] macb: Add 1588 support in Cadence
 GEM.
Date: Wed, 7 Dec 2016 20:39:09 +0100
Message-ID: <20161207193908.GA13062@netboy>
References: <1481134912-2243-1-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, davem@davemloft.net,
        nicolas.ferre@atmel.com, harinikatakamlinux@gmail.com,
        harini.katakam@xilinx.com, punnaia@xilinx.com, michals@xilinx.com,
        anirudh@xilinx.com, boris.brezillon@free-electrons.com,
        alexandre.belloni@free-electrons.com, tbultel@pixelsurmer.com,
        rafalo@cadence.com
To: Andrei Pistirica <andrei.pistirica@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1481134912-2243-1-git-send-email-andrei.pistirica@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 07, 2016 at 08:21:51PM +0200, Andrei Pistirica wrote:
> +#ifdef CONFIG_MACB_USE_HWSTAMP
> +void gem_ptp_init(struct net_device *ndev);
> +void gem_ptp_remove(struct net_device *ndev);
> +
> +void gem_ptp_do_txstamp(struct macb *bp, struct sk_buff *skb);
> +void gem_ptp_do_rxstamp(struct macb *bp, struct sk_buff *skb);

These are in the hot path, and so you should do the test before
calling the global function, something like this:

void gem_ptp_txstamp(struct macb *bp, struct sk_buff *skb);

static void gem_ptp_do_txstamp(struct macb *bp, struct sk_buff *skb)
{
	if (!bp->hwts_tx_en)
		return;
	gem_ptp_txstamp(bp, skb);
}

Ditto for Rx.

> +#else
> +static inline void gem_ptp_init(struct net_device *ndev) { }
> +static inline void gem_ptp_remove(struct net_device *ndev) { }
> +
> +static inline void gem_ptp_do_txstamp(struct macb *bp, struct sk_buff *skb) { }
> +static inline void gem_ptp_do_rxstamp(struct macb *bp, struct sk_buff *skb) { }
> +#endif
> +

> +static int gem_ptp_adjfine(struct ptp_clock_info *ptp, long scaled_ppm)
> +{
> +	struct macb *bp = container_of(ptp, struct macb, ptp_caps);
> +	u32 word, diff;
> +	u64 adj, rate;
> +	int neg_adj = 0;
> +
> +	if (scaled_ppm < 0) {
> +		neg_adj = 1;
> +		scaled_ppm = -scaled_ppm;
> +	}
> +	rate = scaled_ppm;
> +
> +	/* word: unused(8bit) | ns(8bit) | fractions(16bit) */
> +	word = (bp->ns_incr << 16) + bp->subns_incr;
> +
> +	adj = word;
> +	adj *= rate;
> +	adj >>= 16; /* remove fractions */
> +	adj += 500000UL;
> +	diff = div_u64(adj, 1000000UL);

In order to round correctly, shouldn't this be?

	adj *= rate;
	adj += 500000UL << 16;
	adj >>= 16;
	diff = div_u64(adj, 1000000UL);

> +	word = neg_adj ? word - diff : word + diff;
> +
> +	spin_lock(&bp->tsu_clk_lock);
> +
> +	gem_writel(bp, TISUBN, GEM_BF(SUBNSINCR, (word & 0xffff)));
> +	gem_writel(bp, TI, GEM_BF(NSINCR, (word >> 16)));
> +
> +	spin_unlock(&bp->tsu_clk_lock);
> +	return 0;
> +}

> +static s32 gem_ptp_max_adj(unsigned int f_nom)
> +{
> +	u64 adj;
> +
> +	/* The 48 bits of seconds for the GEM overflows every:
> +	 * 2^48/(365.25 * 24 * 60 *60) =~ 8 925 512 years (~= 9 mil years),
> +	 * thus the maximum adjust frequency must not overflow CNS register:
> +	 *
> +	 * addend  = 10^9/nominal_freq
> +	 * adj_max = +/- addend*ppb_max/10^9
> +	 * max_ppb = (2^8-1)*nominal_freq-10^9
> +	 */
> +	adj = f_nom;
> +	adj *= 0xffff;
> +	adj -= 1000000000ULL;

What is this computation, and how does it relate to the comment?

> +	return adj;
> +}

> +/* While GEM can timestamp PTP packets, it does not mark the RX descriptor

Does it timestamp PTP event packets only, or all packets?

(See my comment in patch 2/2)

> + * to identify them. UDP packets must be parsed to identify PTP packets.
> + *
> + * Note: Inspired from drivers/net/ethernet/ti/cpts.c
> + */

Thanks,
Richard
