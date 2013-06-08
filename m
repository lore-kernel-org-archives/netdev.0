From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH v2] ethernet/arc/arc_emac - Add new driver
Date: Sat, 8 Jun 2013 11:19:55 +0000
Message-ID: <4881796E12491D4BB15146FE0209CE643F5CA32B@DE02WEMBXB.internal.synopsys.com>
References: <1370617656-18349-1-git-send-email-abrodkin@synopsys.com>
 <1370628783.2209.123.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	"Mischa Jonker" <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"Grant Likely" <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"romieu@fr.zoreil.com" <romieu@fr.zoreil.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/07/2013 10:13 PM, Joe Perches wrote:
 > On Fri, 2013-06-07 at 19:07 +0400, Alexey Brodkin wrote:
 >> Driver for non-standard on-chip ethernet device ARC EMAC 10/100,
 >> instantiated in some legacy ARC (Synopsys) FPGA Boards such as
 >> ARCAngel4/ML50x.
 >
 > trivial comments only:
 >
 >> diff --git a/drivers/net/ethernet/arc/arc_emac_main.c 
b/drivers/net/ethernet/arc/arc_emac_main.c
 >> + * Alexey Brodkin: June 2013
 >> + *  -Upsteaming
 > []
 >> + * Vineet Gupta: June 2011
 >> + *  -Issues when working with 64b cache line size
 > []
 >> + * Vineet Gupta: May 2010
 >> + *  -Reduced foot-print of the main ISR (handling for error cases 
moved out
 > []
 >> + * Vineet Gupta: Nov 2009
 >> + *  -Unified NAPI and Non-NAPI Code.
 > []
 >> + * Vineet Gupta: Nov 2009
 > []
 >> + * Amit Bhor, Sameer Dhavale: 2004
 >
 > Does the internal changelog add anything useful?

Well, I think at this point it's more of honoring people who contributed 
into this driver through past years.
I saw this kind of changelogs in other drivers like "arc_uart" that was 
recently upstreamed: 
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/drivers/tty/serial/arc_uart.c

So if I still want to name contributor should I just list their names?

 >> +static int arc_emac_poll(struct napi_struct *napi, int budget)
 >> +{
 >> +	struct net_device *net_dev = napi->dev;
 >> +	struct arc_emac_priv *priv = netdev_priv(net_dev);
 >> +	struct sk_buff *skb, *skbnew;
 >> +	unsigned int i, loop, len, info, work_done = 0;
 >> +
 >> +	/* Loop thru the BD chain, but not always from 0.
 >> +	 * Start from right after where we last saw a packet.
 >> +	 */
 >> +	i = priv->last_rx_bd;
 >> +
 >> +	for (loop = 0; loop < RX_BD_NUM; loop++) {
 >> +		i = (i + 1) & (RX_BD_NUM - 1);
 >> +
 >> +		info = priv->rxbd[i].info;
 >> +
 >> +		/* BD contains a packet for CPU to grab */
 >> +		if (likely((info & OWN_MASK) == FOR_CPU)) {
 >
 > You could reduce indentation a level for all
 > the lines that follow by using
 > 		if (unlikely(!(...)
 > 			continue;

To be honest I thought about doing it, but personally I don't like 
inverted logic - I'd say it makes code logic not that straight-forward 
for understanding. Still it might be only my feeling and as I've got at 
last to advises to act so - I'll definitely follow your proposal.

 >> +				/* Get a new SKB from stack */
 >> +				skbnew = netdev_alloc_skb(net_dev,
 >> +							  net_dev->mtu +
 >> +							  EMAC_BUFFER_PAD);
 >> +
 >> +				if (!skbnew) {
 >> +					netdev_err(net_dev, "Out of memory, "
 >> +						   "dropping packet\n");
 >
 > OOM messages aren't particularly useful,
 > and coalesce format please...

I noticed that some drivers don't print error messages for this kind of 
errors. My intention was to make possible problem troubleshooting a bit 
easier. But if it is not supposed to print "standard" errors in console 
but simply return proper error code from the function - I'm fine with it 
- makes code smaller)

 >> +static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
 >> +{
 >> +	struct net_device *net_dev = (struct net_device *)dev_instance;
 >
 > Don't need to cast void *
 > netdev is a more common variable name

Good point - thanks.

 >> +		if (status & TXINT_MASK) {
 >> +			unsigned int i, info;
 >> +			struct sk_buff *skb;
 > []
 >> +			if (status & TXCH_MASK) {
 >> +				priv->stats.tx_errors++;
 >> +				priv->stats.tx_aborted_errors++;
 >> +				netdev_err(priv->net_dev,
 >> +					   "Tx chaining err! txbd_dirty = %u\n",
 >> +					   priv->txbd_dirty);
 >
 > You already have a local net_dev.
 > why not use that?

Good point - overengineered stuff)

 >> +int arc_emac_open(struct net_device *net_dev)
 >> +{
 >> +	struct arc_emac_priv *priv = netdev_priv(net_dev);
 >> +	struct arc_emac_bd_t *bd;
 >> +	struct sk_buff *skb;
 >> +	int i;
 >> +
 >> +	if (!priv->phy_node) {
 >> +		netdev_err(net_dev, "arc_emac_open: phy device is absent\n");
 >
 > If you really need the function name,
 > it's better to use "%s: ", __func__

Reminder from previous "printk". Will clean-up.

 >> +int arc_emac_tx(struct sk_buff *skb, struct net_device *net_dev)
 >> +{
 > []
 >> +tx_next_chunk:
 >> +
 >> +	info = priv->txbd[priv->txbd_curr].info;
 >> +	if (likely((info & OWN_MASK) == FOR_CPU)) {
 >
 > 	if (unlikely(!(etc...)
 > 		return NETDEV_TX_BUSY;
 >
 > and save an indent level

Same comment as above - will invert logic.

 >> +/**
 >
 >> +int arc_emac_set_address(struct net_device *net_dev, void *p)
 > []
 >> +	EMAC_REG_SET(priv->reg_base_addr, R_ADDRH,
 >> +		     *(unsigned int *)&net_dev->dev_addr[4] & 0x0000ffff);
 >
 > That doesn't seem endian friendly.

Right. Need to revisit this one.

 >> +static int arc_emac_probe(struct platform_device *pdev)
 >> +{
 > []
 >> +	/* Get phy from device tree */
 >> +	priv->phy_node = of_parse_phandle(pdev->dev.of_node, "phy", 0);
 >> +	if (!priv->phy_node) {
 >> +		dev_err(&pdev->dev, "failed to retrieve phy description "
 >> +			"from device tree\n");
 >
 > Coalesce formats please

Could you please clarify how should I format lines in question?
I'm a bit lost here.

 >> +	err = of_address_to_resource(pdev->dev.of_node, 0, &res_regs);
 >> +	if (err) {
 >> +		dev_err(&pdev->dev, "failed to retrieve registers base "
 >> +			"from device tree\n");
 > []
 >> +	/* Get IRQ from device tree */
 >> +	err = of_irq_to_resource(pdev->dev.of_node, 0, &res_irq);
 >> +	if (!err) {
 >> +		dev_err(&pdev->dev, "failed to retrieve <irq> value "
 >> +			"from device tree\n");
 > []

-Alexey
