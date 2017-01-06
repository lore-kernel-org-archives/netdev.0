From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCHv2 net-next 02/11] net: mvpp2: handle too large value in
 mvpp2_rx_time_coal_set()
Date: Fri, 6 Jan 2017 12:59:24 +0000
Message-ID: <20170106125923.GA14217@n2100.armlinux.org.uk>
References: <1482943567-12483-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1482943567-12483-3-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Yehuda Yitschak <yehuday@marvell.com>,
 Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
 Hanna Hawa <hannah@marvell.com>, Nadav Haklai <nadavh@marvell.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Marcin Wojtas <mw@semihalf.com>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1482943567-12483-3-git-send-email-thomas.petazzoni@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 28, 2016 at 05:45:58PM +0100, Thomas Petazzoni wrote:
> When configuring the MVPP2_ISR_RX_THRESHOLD_REG with the RX coalescing
> time threshold, we do not check for the maximum allowed value supported
> by the driver, which means we might overflow and use a bogus value. This
> commit adds a check for this situation, and if a value higher than what
> is supported by the hardware is provided, then we use the maximum value
> supported by the hardware.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/mvpp2.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> index 02d91e4..a1ba89f 100644
> --- a/drivers/net/ethernet/marvell/mvpp2.c
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
> @@ -154,6 +154,7 @@
>  
>  /* Interrupt Cause and Mask registers */
>  #define MVPP2_ISR_RX_THRESHOLD_REG(rxq)		(0x5200 + 4 * (rxq))
> +#define     MVPP2_MAX_ISR_RX_THRESHOLD		0xfffff0
>  #define MVPP2_ISR_RXQ_GROUP_REG(rxq)		(0x5400 + 4 * (rxq))
>  #define MVPP2_ISR_ENABLE_REG(port)		(0x5420 + 4 * (port))
>  #define     MVPP2_ISR_ENABLE_INTERRUPT(mask)	((mask) & 0xffff)
> @@ -4397,6 +4398,12 @@ static void mvpp2_rx_time_coal_set(struct mvpp2_port *port,
>  	u32 val;
>  
>  	val = (port->priv->tclk / USEC_PER_SEC) * usec;
> +
> +	if (val > MVPP2_MAX_ISR_RX_THRESHOLD) {
> +		val = MVPP2_MAX_ISR_RX_THRESHOLD;
> +		usec = (val * USEC_PER_SEC) / port->priv->tclk;
> +	}
> +

Beware of rounding and overflow errors.  usec and val are u32's.

	MVPP2_MAX_ISR_RX_THRESHOLD = 16777200
	USEC_PER_SEC = 1000000

This equates to 0xF423F0BDC00 for the multiplication, which is a little
larger than 32-bit.  Assuming tclk is 166.666666MHz (as it was on Dove
- I don't know what it would be here) and 64-bit arithmetic, the maximum
value gives 100663us.

Passing that back into the function gives... 16710058, so the second time
around, we end up with a different setting (even though a change wasn't
requested.)

However, 100664 won't trigger your check, neither will values all the way
up to 101067 - the reason being that you're losing so much precision by
dividling the clock by USEC_PER_SEC first.  Only if it's a whole number
of MHz will you get away with that.

So, I'd suggest you switch to using 64 bit math here - it's not a fast
path.  Using bc to evaluate val = port->priv->tclk * usec / USEC_PER_SEC
gives:

	(166666666 * 100663 / 1000000)
	16777166

which is as close as you can come to the limit.

So, I'd suggest (these variants round down, which is acceptable for
this implementation):

static u32 usec_to_cycles(u32 usec, unsigned long clock_rate_hz)
{
	u64 tmp = clock_rate_hz * usec;

	do_div(tmp, USEC_PER_SEC);

	return tmp > 0xffffffff ? 0xffffffff : tmp;
}

static u32 cycles_to_usec(u32 cycles, unsigned long clock_rate_hz)
{
	u64 tmp = cycles * USEC_PER_SEC;

	do_div(tmp, clock_rate_hz);

	return tmp > 0xffffffff ? 0xffffffff : tmp;
}

and:
	u32 val = usec_to_cycles(usec, port->priv->tclk);

	if (val > MVPP2_MAX_ISR_RX_THRESHOLD) {
		usec = cycles_to_usec(MVPP2_MAX_ISR_RX_THRESHOLD,
				      port->priv->tclk);

		/* re-evaluate to get actual register value for usec */
		val = usec_to_cycles(usec, port->priv->tclk);
	}

>  	mvpp2_write(port->priv, MVPP2_ISR_RX_THRESHOLD_REG(rxq->id), val);
>  
>  	rxq->time_coal = usec;

This function appears to be called from two places:

mvpp2_rxq_init():
        mvpp2_rx_time_coal_set(port, rxq, rxq->time_coal);

mvpp2_ethtool_set_coalesce():
                rxq->time_coal = c->rx_coalesce_usecs;
                mvpp2_rx_time_coal_set(port, rxq, rxq->time_coal);

It seems rather pointless to pass in rxq->time_coal when you're also
passing in rxq.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
