From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: [PATCH] ixp4xx: Support the all multicast flag on the NPE devices.
Date: Mon, 31 May 2010 18:09:33 +0200
Message-ID: <19459.57149.428000.694558@pilspetsen.it.uu.se>
References: <20100531131102.GA15870@riccoc20.at.omicron.at>
	<m3pr0c17ue.fsf@intrepid.localdomain>
	<20100531153419.GA17317@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc@pm.waw.pl>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fanny.its.uu.se ([130.238.4.241]:59456 "EHLO fanny.its.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751730Ab0EaQJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 May 2010 12:09:40 -0400
In-Reply-To: <20100531153419.GA17317@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Cochran writes:
 > On Mon, May 31, 2010 at 04:09:13PM +0200, Krzysztof Halasa wrote:
 > > Looks good, though I'd prefer a bit of "const" and "static" in the
 > > allmulti[] declaration. Would you please repost? TIA.
 > 
 > Okay, here it is.
 > 
 > Thanks,
 > Richard
 > 
 > This patch adds support for the IFF_ALLMULTI flag. Previously only the
 > IFF_PROMISC flag was supported.
 > 
 > Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
 > ---
 >  drivers/net/arm/ixp4xx_eth.c |   11 +++++++++++
 >  1 files changed, 11 insertions(+), 0 deletions(-)
 > 
 > diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
 > index 6be8b09..42b4361 100644
 > --- a/drivers/net/arm/ixp4xx_eth.c
 > +++ b/drivers/net/arm/ixp4xx_eth.c
 > @@ -739,6 +739,17 @@ static void eth_set_mcast_list(struct net_device *dev)
 >  	struct dev_mc_list *mclist;
 >  	u8 diffs[ETH_ALEN], *addr;
 >  	int i;
 > +	static const u8 allmulti[] = { 0x01, 0x00, 0x00, 0x00, 0x00, 0x00 };
 > +
 > +	if (dev->flags & IFF_ALLMULTI) {
 > +		for (i = 0; i < ETH_ALEN; i++) {
 > +			__raw_writel(allmulti[i], &port->regs->mcast_addr[i]);
 > +			__raw_writel(allmulti[i], &port->regs->mcast_mask[i]);

Seems a bit excessive to define a lookup table for a computation
that amounts to nothing more than "i ? 0 : 1".

Something like the following would IMO be cleaner:

	if (...) {
		for (...) {
			u8 multi = i ? 0x00 : 0x01;
			__raw_writel(multi, ...);
			...
		}
	}
