From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6] natsemi.c NAPI
Date: Mon, 20 Sep 2004 11:57:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920115746.7ccbfb45.davem@davemloft.net>
References: <20040920141030.GV1307@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040920141030.GV1307@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Sep 2004 16:10:30 +0200
Harald Welte <laforge@gnumonks.org> wrote:

> +static inline void natsemi_irq_enable(struct netdev_private *np)
> +{
> +	/* Enable interrupts by setting the interrupt mask. */
> +	writel(DEFAULT_INTR, np->base_addr + IntrMask);
> +	writel(1, np->base_addr + IntrEnable);
> +	mb();
> +}
> +
> +static inline void natsemi_irq_disable(struct netdev_private *np)
> +{
> +	writel(0, np->base_addr + IntrEnable);
> +	mb();
> +}

Kill the mb(), try using:

	readl(np->base_addr + IntrEnable);

in it's place.

This driver (before the NAPI patch) is a bit buggy, it does
no RX processing SMP locking.  So if one one cpu you're doing
RX interrupt processing, and on another cpu tx_timeout() runs
we're totally screwed.

This is not caused by Harald's patch, but there are implications
for his NAPI patch once it is fixed.
