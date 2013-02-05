From: "Ganesan Ramalignam" <ganesanr@broadcom.com>
Subject: Re: [PATCH 1/2] NET: ethernet/netlogic: Netlogic XLR/XLS GMAC
 driver
Date: Tue, 5 Feb 2013 16:59:00 +0530
Message-ID: <20130205112859.GA17465@ganesanr.netlogicmircro.com>
References: <1359450699-26141-1-git-send-email-ganesanr@broadcom.com>
 <1359508293.4144.29.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1359508293.4144.29.camel@bwh-desktop.uk.solarflarecom.com>
Content-Disposition: inline
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Ben, Thank you for your comments, will submit the driver with fixes.
Reply inline.

On Wed, Jan 30, 2013 at 01:11:33AM +0000, Ben Hutchings wrote:
> On Tue, 2013-01-29 at 14:41 +0530, ganesanr@broadcom.com wrote:
> > From: Ganesan Ramalingam <ganesanr@broadcom.com>
> > 
> > Add support for the Network Accelerator Engine on Netlogic XLR/XLS
> > MIPS SoCs. The XLR/XLS NAE blocks can be configured as one 10G
> > interface or four 1G interfaces. This driver supports blocks
> > with 1G ports.
> > 
> > Signed-off-by: Ganesan Ramalingam <ganesanr@broadcom.com>
> > ---
> >  This patch has to be merged through netdev tree.
> >  Please review and let me know if there are any comments or suggestions.
> > 
> >  drivers/net/ethernet/Kconfig            |    1 +
> >  drivers/net/ethernet/Makefile           |    1 +
> >  drivers/net/ethernet/netlogic/Kconfig   |    8 +
> >  drivers/net/ethernet/netlogic/Makefile  |    1 +
> >  drivers/net/ethernet/netlogic/xlr_net.c | 1132 +++++++++++++++++++++++++++++++
> >  drivers/net/ethernet/netlogic/xlr_net.h | 1098 ++++++++++++++++++++++++++++++
> >  6 files changed, 2241 insertions(+), 0 deletions(-)
> >  create mode 100644 drivers/net/ethernet/netlogic/Kconfig
> >  create mode 100644 drivers/net/ethernet/netlogic/Makefile
> >  create mode 100644 drivers/net/ethernet/netlogic/xlr_net.c
> >  create mode 100644 drivers/net/ethernet/netlogic/xlr_net.h
> 
> Why add a netlogic directory when the company is now a part of Broadcom?
> 
> [...]

All our submissions are still following the Netlogic convention, look at
arch/mips/netlogic/, this will be changed in future with BRCM wrapper.

> > --- /dev/null
> > +++ b/drivers/net/ethernet/netlogic/xlr_net.c
> [...]
> > +/* Ethtool operation */
> > +static int xlr_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
> > +{
> > +	return 0;
> > +}
> > +
> > +static int xlr_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
> > +{
> > +	return 0;
> > +}
> > +
> > +static void xlr_get_drvinfo(struct net_device *ndev,
> > +		struct ethtool_drvinfo *drvinfo)
> > +{
> > +	return;
> > +}
> > +
> > +static u32 xlr_get_link(struct net_device *ndev)
> > +{
> > +	return 0;
> > +}
> > +
> > +static struct ethtool_ops xlr_ethtool_ops = {
> > +	.get_settings = xlr_get_settings,
> > +	.set_settings = xlr_set_settings,
> > +	.get_drvinfo = xlr_get_drvinfo,
> > +	.get_link = xlr_get_link,
> > +};
> 
> Either implement them or don't.  I'm guessing that phylib can handle
> get_settings and set_settings for you.
> 
> [...]

Fixed

> > +static netdev_tx_t xlr_net_start_xmit(struct sk_buff *skb,
> > +               struct net_device *ndev)
> > +{
> > +       struct nlm_fmn_msg msg;
> > +       struct xlr_net_priv *priv = netdev_priv(ndev);
> > +       int ret;
> > +       u16 qmap;
> > +       u32 flags;
> > +
> > +       qmap = skb->queue_mapping;
> > +       xlr_make_tx_desc(&msg, virt_to_phys(skb->data), skb);
> > +       flags = nlm_cop2_enable();
> > +       ret = nlm_fmn_send(2, 0, priv->nd->tx_stnid, &msg);
> > +       nlm_cop2_restore(flags);
> > +       return NETDEV_TX_OK;
> > +}
> 
> If nlm_fmn_send() fails then you need to free the skbuff.
> 
> [...]

Fixed

> > +static void xlr_stats(struct net_device *ndev, struct net_device_stats *stats)
> > +{
> > +	struct xlr_net_priv *priv = netdev_priv(ndev);
> > +
> > +	stats->rx_packets = nlm_read_reg(priv->base_addr, RX_PACKET_COUNTER);
> > +	stats->tx_packets = nlm_read_reg(priv->base_addr, TX_PACKET_COUNTER);
> > +	stats->rx_bytes = nlm_read_reg(priv->base_addr, RX_BYTE_COUNTER);
> > +	stats->tx_bytes = nlm_read_reg(priv->base_addr, TX_BYTE_COUNTER);
> 
> 32-bit byte counters for a 1G/10G device?  Seriously?
> 
> [...]

Yes, all are 32-bit byte counters

> > +struct net_device_stats *xlr_get_stats(struct net_device *ndev)
> > +{
> > +	struct net_device_stats *stats = &ndev->stats;
> > +
> > +	xlr_stats(ndev, stats);
> > +	return stats;
> > +}
> 
> You should probably be implementing ndo_get_stats64 to provide 64-bit
> stats even on a 32-bit kernel.
> 

Fixed

> > +static int xlr_net_probe(struct platform_device *pdev)
> > +{
> [...]
> > +	ndev->watchdog_timeo = 1000 * HZ;
> [...]
> 

Fixed

> A watchdog timeout of 1000 seconds is ridiculous.  I guess someone just
> kept seeing the watchdog fire and increasing the timeout, and never
> thought about *why* this was happening.
> 
> Ben.
> 
> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 
