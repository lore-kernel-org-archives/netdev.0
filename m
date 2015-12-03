From: Scott Wood <scottwood@freescale.com>
Subject: Re: [net-next v4 4/8] dpaa_eth: add driver's Tx queue selection
Date: Thu, 3 Dec 2015 13:37:04 -0600
Message-ID: <1449171424.15946.17.camel@freescale.com>
References: <1446485500-9782-1-git-send-email-madalin.bucur@freescale.com>
	 <1446485500-9782-5-git-send-email-madalin.bucur@freescale.com>
	 <1449092431.29246.156.camel@freescale.com>
	 <DM2PR0301MB07689A2F03A375C248DDA817E60D0@DM2PR0301MB0768.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Liberman Igal-B31950 <Igal.Liberman@freescale.com>,
	Pledge Roy-R01356 <roy.pledge@freescale.com>,
	"ppc@mindchasers.com" <ppc@mindchasers.com>,
	"joe@perches.com" <joe@perches.com>,
	"pebolle@tiscali.nl" <pebolle@tiscali.nl>,
	"joakim.tjernlund@transmode.se" <joakim.tjernlund@transmode.se>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
To: Bucur Madalin-Cristian-B32716 <madalin.bucur@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <DM2PR0301MB07689A2F03A375C248DDA817E60D0@DM2PR0301MB0768.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-12-03 at 04:02 -0600, Bucur Madalin-Cristian-B32716 wrote:
> > -----Original Message-----
> > From: Wood Scott-B07421
> > Sent: Wednesday, December 02, 2015 11:41 PM
> > 
> > On Mon, 2015-11-02 at 19:31 +0200, Madalin Bucur wrote:
> > > Allow the selection of the transmission queue based on the CPU id.
> > 
> > Explain why.
> 
> I'll add more details in the commit log. This is a customer generated
> feature. Bypassing the standard XPS can increase performance by making use
> of the DPAA HW particularities.
> 
> > > 
> > > Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
> > > ---
> > >  drivers/net/ethernet/freescale/dpaa/Kconfig           | 10 ++++++++++
> > >  drivers/net/ethernet/freescale/dpaa/dpaa_eth.c        |  3 +++
> > >  drivers/net/ethernet/freescale/dpaa/dpaa_eth.h        |  6 ++++++
> > >  drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.c |  8 ++++++++
> > >  drivers/net/ethernet/freescale/dpaa/dpaa_eth_common.h |  4 ++++
> > >  5 files changed, 31 insertions(+)
> > > 
> > > diff --git a/drivers/net/ethernet/freescale/dpaa/Kconfig
> > > b/drivers/net/ethernet/freescale/dpaa/Kconfig
> > > index 022d5aa..2577aac 100644
> > > --- a/drivers/net/ethernet/freescale/dpaa/Kconfig
> > > +++ b/drivers/net/ethernet/freescale/dpaa/Kconfig
> > > @@ -11,6 +11,16 @@ menuconfig FSL_DPAA_ETH
> > > 
> > >  if FSL_DPAA_ETH
> > > 
> > > +config FSL_DPAA_ETH_USE_NDO_SELECT_QUEUE
> > > +	bool "Use driver's Tx queue selection mechanism"
> > > +	default y
> > > +	---help---
> > > +	  The DPAA Ethernet driver defines a ndo_select_queue()
> > > callback
> > > for optimal selection
> > > +	  of the egress FQ. That will override the XPS support for this
> > > netdevice.
> > > +	  If for whatever reason you want to be in control of the
> > > egress FQ
> > > -to-CPU selection and mapping,
> > > +	  or simply don't want to use the driver's ndo_select_queue()
> > > callback, then unselect this
> > > +	  and use the standard XPS support instead.
> > 
> > Is there a use case for needing this to be configurable?
> 
> If the standard XPS is desired, the Kconfig option allows the driver user to
> select that.

Under what circumstances does it make sense to desire this?  Could you put the
answer to that in the help text?

> > > diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> > > b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> > > index 31d55b4..894f1a7 100644
> > > --- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> > > +++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
> > > @@ -390,6 +390,9 @@ static const struct net_device_ops dpa_private_ops =
> > {
> > >  	.ndo_get_stats64 = dpa_get_stats64,
> > >  	.ndo_set_mac_address = dpa_set_mac_address,
> > >  	.ndo_validate_addr = eth_validate_addr,
> > > +#ifdef CONFIG_FSL_DPAA_ETH_USE_NDO_SELECT_QUEUE
> > > +	.ndo_select_queue = dpa_select_queue,
> > > +#endif
> > >  	.ndo_change_mtu = dpa_change_mtu,
> > >  	.ndo_set_rx_mode = dpa_set_rx_mode,
> > >  	.ndo_init = dpa_ndo_init,
> > > diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
> > > b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
> > > index 1ba6617..87577cf 100644
> > > --- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
> > > +++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.h
> > > @@ -420,9 +420,15 @@ static inline void _dpa_assign_wq(struct dpa_fq
> > *fq)
> > >  	}
> > >  }
> > > 
> > > +#ifdef CONFIG_FSL_DPAA_ETH_USE_NDO_SELECT_QUEUE
> > > +/* Use in lieu of skb_get_queue_mapping() */
> > > +#define dpa_get_queue_mapping(skb) \
> > > +	raw_smp_processor_id()
> > > +#else
> > >  /* Use the queue selected by XPS */
> > >  #define dpa_get_queue_mapping(skb) \
> > >  	skb_get_queue_mapping(skb)
> > > +#endif
> > 
> > Why is this necessary?  Shouldn't providing a custom .ndo_select_queue()
> > be
> > sufficient to ensure that skb_get_queue_mapping() returns the same thing?
> 
> dpa_get_queue_mapping() is used in more than one place, the ndo function
> cannot
> be used directly in all places, the current setup is justified.

It's called in two places that I see.  For the call in dpa_tx(), when will
skb_get_queue_mapping() not return the correct answer?  For the call in
dpa_select_queue(), that's already called via function pointer so it would not
be a new indirection layer.

> > And if this goes away, it's just a matter of a function pointer, so if it
> > does
> > need to be configurable it could be a runtime option.
> > 
> > -Scott
> 
> It's used on the hot path, adding an extra indirection layer to make it
> selectable
> at runtime would defeat the purpose...

"if this goes away"

I wasn't asking for a new indirection layer.

-Scott
