From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH] smc91x: enable ethtool EEPROM interface
Date: Fri, 16 Jan 2009 13:35:43 -0500 (EST)
Message-ID: <alpine.LFD.2.00.0901161328300.9524@xanadu.home>
References: <1232081619-25580-1-git-send-email-VernonInHand@gmail.com>
 <alpine.LFD.2.00.0901160004110.9524@xanadu.home> <4970C3B4.1040006@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Vernon Sauder <vernoninhand@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:24950 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756001AbZAPSgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 13:36:16 -0500
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR005.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0KDK001EDUA63TM0@VL-MO-MR005.ip.videotron.ca> for
 netdev@vger.kernel.org; Fri, 16 Jan 2009 13:34:55 -0500 (EST)
In-reply-to: <4970C3B4.1040006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Jan 2009, Vernon Sauder wrote:

> Sorry about that. This was an old patch before bank checking. Here is an update.
> 
> From: Vernon Sauder <vsauder@inhand.com>
> Date: Fri, 16 Jan 2009 12:05:42 -0500
> Subject: [PATCH] smc91x: enable ethtool EEPROM interface
> 
> 
> Signed-off-by: Vernon Sauder <vsauder@inhand.com>
> ---
>  drivers/net/smc91x.c |  108 +++++++++++++++++++++++++++++++++++++++++++++++++-
>  drivers/net/smc91x.h |   10 +++++
>  2 files changed, 116 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
> index b215a8d..ba802f5 100644
> --- a/drivers/net/smc91x.c
> +++ b/drivers/net/smc91x.c
> @@ -1643,6 +1643,109 @@ static void smc_ethtool_setmsglevel(struct net_device *dev, u32 level)
>  	lp->msg_enable = level;
>  }
> 
> +static int smc_write_eeprom_word(struct net_device *dev, u16 addr, u16 word)
> +{
> +	struct smc_local *lp = netdev_priv(dev);
> +	void __iomem *ioaddr = lp->base;
> +	spin_lock_irq(&lp->lock);
> +	/* load word into GP register */
> +	SMC_SELECT_BANK(lp, 1);
> +	SMC_SET_GP(lp, word);
> +	/* set the address to put the data in EEPROM */
> +	SMC_SELECT_BANK(lp, 2);
> +	SMC_SET_PTR(lp, addr);
> +	/* tell it to write */
> +	SMC_SELECT_BANK(lp, 1);
> +	u16 ctl = SMC_GET_CTL(lp);
> +	SMC_SET_CTL(lp, ctl | (CTL_EEPROM_SELECT | CTL_STORE));
> +	/* wait for it to finish */
> +	do {
> +		udelay(1);
> +	} while (SMC_GET_CTL(lp) & CTL_STORE);
> +	/* clean up */
> +	SMC_SET_CTL(lp, ctl);
> +	SMC_SELECT_BANK(lp, 2);
> +	spin_unlock_irq(&lp->lock);
> +	return 0;
> +}
> +
> +static int smc_read_eeprom_word(struct net_device *dev, u16 addr, u16 *word)
> +{
> +	struct smc_local *lp = netdev_priv(dev);
> +	void __iomem *ioaddr = lp->base;
> +
> +	spin_lock_irq(&lp->lock);
> +	/* set the EEPROM address to get the data from */
> +	SMC_SELECT_BANK(lp, 2);
> +	SMC_SET_PTR(lp, addr | PTR_READ);
> +	/* tell it to load */
> +	SMC_SELECT_BANK(lp, 1);
> +	SMC_SET_GP(lp, 0xffff);	/* init to known */
> +	u16 ctl = SMC_GET_CTL(lp);

Don't put variable declaration in the middle of code sequences.  Not all 
gcc versions support C++ variable declaration style.


> +	SMC_SET_CTL(lp, ctl | (CTL_EEPROM_SELECT | CTL_RELOAD));
> +	/* wait for it to finish */
> +	do {
> +		udelay(1);
> +	} while (SMC_GET_CTL(lp) & CTL_RELOAD);
> +	/* read word from GP register */
> +	*word = SMC_GET_GP(lp);
> +	/* clean up */
> +	SMC_SET_CTL(lp, ctl);
> +	SMC_SELECT_BANK(lp, 2);
> +	spin_unlock_irq(&lp->lock);
> +	return 0;
> +}
> +
> +static int smc_ethtool_geteeprom_len(struct net_device *dev)
> +{
> +	return 0x23 * 2;
> +}
> +
> +static int smc_ethtool_geteeprom(struct net_device *dev,
> +		struct ethtool_eeprom *eeprom, u8 *data)
> +{
> +	int i, ret;
> +
> +	DBG(1, "Reading %d bytes at %d(0x%x)\n",
> +		eeprom->len, eeprom->offset, eeprom->offset);
> +	int imax = smc_ethtool_geteeprom_len(dev);
> +	for (i = 0; i < eeprom->len; i += 2) {
> +		int offset = i + eeprom->offset;
> +		if (offset > imax)
> +			break;
> +		u16 wbuf;

Same here.

> +		ret = smc_read_eeprom_word(dev, offset >> 1, &wbuf);
> +		if (ret != 0)
> +			return ret;
> +		DBG(2, "Read 0x%x from 0x%x\n", wbuf, offset >> 1);
> +		data[i] = (wbuf >> 8) & 0xff;
> +		data[i+1] = wbuf & 0xff;
> +	}
> +	return 0;
> +}
> +
> +static int smc_ethtool_seteeprom(struct net_device *dev,
> +		struct ethtool_eeprom *eeprom, u8 *data)
> +{
> +	int i, ret;
> +
> +	DBG(1, "Writing %d bytes to %d(0x%x)\n",
> +			eeprom->len, eeprom->offset, eeprom->offset);
> +	int imax = smc_ethtool_geteeprom_len(dev);

Same here.

> +	for (i = 0; i < eeprom->len; i += 2) {
> +		int offset = i + eeprom->offset;
> +		if (offset > imax)
> +			break;
> +		u16 wbuf = (data[i] << 8) | data[i + 1];

Same here.


With those fixed you can resubmit with my ACK.


Nicolas
