From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] ethernet/arc/arc_emac - Add new driver
Date: Mon, 10 Jun 2013 00:15:08 +0200
Message-ID: <20130609221508.GA12264@electric-eye.fr.zoreil.com>
References: <1370617656-18349-1-git-send-email-abrodkin@synopsys.com>
 <20130607203231.GA14077@electric-eye.fr.zoreil.com>
 <4881796E12491D4BB15146FE0209CE643F5CB230@DE02WEMBXB.internal.synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"joe@perches.com" <joe@perches.com>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4881796E12491D4BB15146FE0209CE643F5CB230@DE02WEMBXB.internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Brodkin <Alexey.Brodkin@synopsys.com> :
> On 06/08/2013 12:33 AM, Francois Romieu wrote:
>  > Alexey Brodkin <Alexey.Brodkin@synopsys.com> :
[...]
> As replied to Joe I just want to name people contributed in this driver.
> What is a appropriate way to do it?

A polite way could be to see with contributors if it's ok for them to
appear in the (c) section.

[...]
>  > You may #define (FRST_MASK | LAST_MASK)
> 
> This combo is used in only 2 places so is it worth to introduce another 
> define? With these (FRST_MASK | LAST_MASK) I suppose reader will 
> understand that these are 2 separate bits. But still it might be just my 
> vision and if #define (FRST_MASK | LAST_MASK) looks better then I'll add 
> it immediately.

Your call. The #define only needs to appear in or near the function.

[...]
>  >> +				if (!skbnew) {
>  >> +					netdev_err(net_dev, "Out of memory, "
>  >> +						   "dropping packet\n");
>  >
>  > Rate limit or do nothing.
> 
> Not clear what do you mean. Could you please clarify ?

net_ratelimit() will prevent a storm of log messages. Actually I would
avoid the message completely.

[...]
>  >> +{
>  >> +	struct arc_emac_priv *priv = netdev_priv(net_dev);
>  >> +
>  >> +	napi_disable(&priv->napi);
>  >> +	netif_stop_queue(net_dev);
>  >> +
>  >> +	/* Disable interrupts */
>  >> +	EMAC_REG_CLR(priv->reg_base_addr, R_ENABLE,
>  >> +		     TXINT_MASK |	/* Tx interrupt */
>  >> +		     RXINT_MASK |	/* Rx interrupt */
>  >> +		     ERR_MASK |		/* Error interrupt */
>  >> +		     TXCH_MASK);	/* Transmit chaining error interrupt */
>  >
>  > Useless comments.
> 
> Is it clear that TXCH means "Transmit chaining error interrupt"?

ERR_TXCHAIN_MASK ?

> Or those defines should just have comments where they are defined and 
> later just use them with no comments?

s/should have/may have/

Otherwise, yes.

[...]
>  >> +static int arc_mdio_read(struct mii_bus *bus, int phy_addr, int 
> reg_num)
>  >> +{
>  >> +	int error;
>  >> +	unsigned int value;
>  >> +	struct arc_mdio_priv *priv = bus->priv;
>  >
>  > Revert the xmas tree.
> 
> Not clear what does it mean? Could you please calrify?

	struct arc_mdio_priv *priv = bus->priv;
	unsigned int value;
	int error;

[...]
>  >> +struct arc_mdio_priv {
>  >> +	struct mii_bus *bus;
>  >> +	struct device *dev;
>  >> +	void __iomem *reg_base_addr; /* MAC registers base address */
>  >> +};
>  >
>  > Overengineered ?
> 
> Why so? Not clear, sorry.

Most of this struct is shared with the device private one. I am not
sure that they need to be separated.

[...]
>  >> +#define EMAC_REG_SET(reg_base_addr, reg, val)	\
>  >> +			iowrite32((val), reg_base_addr + reg * sizeof(int))
>  >> +
>  >> +#define EMAC_REG_GET(reg_base_addr, reg)	\
>  >> +			ioread32(reg_base_addr + reg * sizeof(int))
>  >
>  > May use real non-caps functions.
> 
> Do you mean to use "io{read|write}32" directly without macro?

Add your own arc_{r/w} functions and use the device private struct
pointer as one of their parameters (whence no void * parameter).

[...]
> Thanks a lot for this deep analisys.

Not that deep:
- arc_emac_tx should disable tx queue as soon as the tx ring is exhausted
- you may consider moving work from the irq handler to napi poll.

-- 
Ueimor
