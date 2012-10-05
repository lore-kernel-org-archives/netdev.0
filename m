From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 11/11] net: xilinx: Show csum in bootlog
Date: Fri, 5 Oct 2012 14:51:02 +0100
Message-ID: <1349445062.16173.48.camel@deadeye.wl.decadent.org.uk>
References: <1349374497-9540-1-git-send-email-monstr@monstr.eu>
	  <1349374497-9540-11-git-send-email-monstr@monstr.eu>
	 <1349378144.2817.23.camel@bwh-desktop.uk.solarflarecom.com>
	 <506EA9C4.2000609@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>
To: <monstr@monstr.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <506EA9C4.2000609@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-10-05 at 11:35 +0200, Michal Simek wrote:
> On 10/04/2012 09:15 PM, Ben Hutchings wrote:
> > On Thu, 2012-10-04 at 20:14 +0200, Michal Simek wrote:
> >> Just show current setting in bootlog.
> > [...]
> >> --- a/drivers/net/ethernet/xilinx/ll_temac_main.c
> >> +++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
> >> @@ -1052,12 +1052,14 @@ static int __devinit temac_of_probe(struct platform_device *op)
> >>   	/* Setup checksum offload, but default to off if not specified */
> >>   	lp->temac_features = 0;
> >>   	p = (__be32 *)of_get_property(op->dev.of_node, "xlnx,txcsum", NULL);
> >> +	dev_info(&op->dev, "TX_CSUM %d\n", be32_to_cpup(p));
> >>   	if (p && be32_to_cpu(*p)) {
> >>   		lp->temac_features |= TEMAC_FEATURE_TX_CSUM;
> >>   		/* Can checksum TCP/UDP over IPv4. */
> >>   		ndev->features |= NETIF_F_IP_CSUM;
> >>   	}
> >>   	p = (__be32 *)of_get_property(op->dev.of_node, "xlnx,rxcsum", NULL);
> >> +	dev_info(&op->dev, "RX_CSUM %d\n", be32_to_cpup(p));
> > [...]
> >
> > Is there any particular reason you think this needs to be logged by
> > default, rather than letting users run ethtool -k?  I suggest using
> > dev_dbg() instead.
> 
> Ok. I have looked at it and there are missing some bits in ndev->features.
> 
> Can you please check that my setting is correct?
> 
> It is SG DMA ip/driver.
> ndev->features = NETIF_F_FRAGLIST | NETIF_F_SG

NETIF_F_SG only; NETIF_F_FRAGLIST means you can handle skbs chained
through the frag_list pointer.

> With two options for csum on RX/TX. They can be selected independently.
> tx Partial csum over IPv4. -> NETIF_F_IP_CSUM
> tx Full csum. -> NETIF_F_HW_CSUM

NETIF_F_IP_CSUM means you have hardware checksum generation for TCP/IPv4
and UDP/IPv4 only (XAE_FEATURE_FULL_TX_CSUM).

NETIF_F_HW_CSUM means you have generic TCP-style checksum generation
using the csum_start and csum_offset fields of the skb
(XAE_FEATURE_PARTIAL_TX_CSUM).  By the way, you're actually testing
XAE_FEATURE_PARTIAL_RX_CSUM in axienet_start_xmit()...

> rx Full csum -> NETIF_F_RXCSUM
>
> Is there any option to support partial csum?

There is no need to differentiate these in the device features.  For TX
the stack needs to know whether to use a software fallback before
passing the skb to you, but on RX it looks at the ip_summed field of
each skb you pass up.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
