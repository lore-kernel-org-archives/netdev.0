From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3] ethernet/arc/arc_emac - Add new driver
Date: Fri, 14 Jun 2013 21:27:04 +0200
Message-ID: <20130614192704.GA4857@electric-eye.fr.zoreil.com>
References: <1371134239-4531-1-git-send-email-abrodkin@synopsys.com>
 <20130613221946.GA16632@electric-eye.fr.zoreil.com>
 <4881796E12491D4BB15146FE0209CE643F5E3A07@DE02WEMBXB.internal.synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andy Shevchenko <andy.shevchenko@gmail.com>,
	Joe Perches <joe@perches.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4881796E12491D4BB15146FE0209CE643F5E3A07@DE02WEMBXB.internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Brodkin <Alexey.Brodkin@synopsys.com> :
> On 06/14/2013 02:20 AM, Francois Romieu wrote:
[...]
> >> +struct arc_emac_priv {
> >> +	struct net_device_stats stats;
> >> +	unsigned int clock_frequency;
> >> +	unsigned int max_speed;
> >> +
> >> +	/* Pointers to BD rings - CPU side */
> >> +	struct arc_emac_bd_t *rxbd;
> >
> > There does not seem to be much need for rxbd->data.
> 
> Could you please clarify this comment? Not clear what do you mean.

Rx and Tx use the same struct but they don't work the same.
They could/should use differents struct.

[...]
> > The descriptor entry is left unchanged. Afaiu the driver will move to the
> > next descriptor and crash on dereferencing NULL (rx_buff->)skb next time
> > it wraps.
> >
> > I suggest avoiding holes: don't netif_receive_skb if you can't alloc a new
> > skb.
> 
> Frankly I cannot understand how "don't netif_receive_skb" for one of the 
> received packets helps to prevent crash on the next iteration?
> And I don't see a way to return any error state from NAPI poll handler.
> Could you please clarify your idea?

The driver assigns the otherwise-netif_received skb to the current rx
descriptor as if it was a newly allocated one. The driver increases
stats.rx_dropped. The rx descriptor ring doesn't ever exhibit a hole.

[...]
> >> +static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
> >> +{
> >> +	struct arc_emac_priv *priv = netdev_priv(ndev);
> >> +	unsigned int info, len, *txbd_curr = &priv->txbd_curr;
> >> +	dma_addr_t addr;
> >> +	char *pkt = skb->data;
> >> +
> >> +	len = max_t(unsigned int, ETH_ZLEN, skb->len);
> >
> > The device automatically pads, right ?
> 
> What do you mean here?

Does the device fill a smaller than 64 bytes packet with zeroes or may
the driver leak information ? The driver should use skb_pad if the
latter applies.

-- 
Ueimor
