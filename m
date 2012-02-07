From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/3 net-next] bnx2: Add support for ethtool
 --show-channels|--set-channels
Date: Tue, 7 Feb 2012 22:01:28 +0000
Message-ID: <1328652088.3549.30.camel@bwh-desktop>
References: <1328491480-13030-1-git-send-email-mchan@broadcom.com>
	 <1328645954.3549.17.camel@bwh-desktop>
	 <1328648307.8014.35.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:55954 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756841Ab2BGWBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 17:01:31 -0500
In-Reply-To: <1328648307.8014.35.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-02-07 at 12:58 -0800, Michael Chan wrote:
> On Tue, 2012-02-07 at 20:19 +0000, Ben Hutchings wrote:
> > On Sun, 2012-02-05 at 17:24 -0800, Michael Chan wrote:
> > > Allow the user to override the default number of RSS/TSS rings.
> > > 
> > > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > > ---
> > >  drivers/net/ethernet/broadcom/bnx2.c |   99 ++++++++++++++++++++++++++++++---
> > >  drivers/net/ethernet/broadcom/bnx2.h |    3 +
> > >  2 files changed, 93 insertions(+), 9 deletions(-)
> > > 
> > > diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
> > > index 0a4c540..2ab31da 100644
> > > --- a/drivers/net/ethernet/broadcom/bnx2.c
> > > +++ b/drivers/net/ethernet/broadcom/bnx2.c
> > > @@ -6246,7 +6246,16 @@ static int
> > >  bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
> > >  {
> > >  	int cpus = num_online_cpus();
> > > -	int msix_vecs = min(cpus + 1, RX_MAX_RINGS);
> > > +	int msix_vecs;
> > > +
> > > +	if (!bp->num_req_rx_rings)
> > > +		msix_vecs = max(cpus + 1, bp->num_req_tx_rings);
> > > +	else if (!bp->num_req_tx_rings)
> > > +		msix_vecs = max(cpus, bp->num_req_rx_rings);
> > > +	else
> > > +		msix_vecs = max(bp->num_req_rx_rings, bp->num_req_tx_rings);
> > > +
> > > +	msix_vecs = min(msix_vecs, RX_MAX_RINGS);
> > 
> > If I read this correctly, IRQs may be shared between RX and TX queues
> > i.e. there may be 'combined channels'.
> 
> It is true that an IRQ can have a TX and a RX queue, but they don't both
> have to be enabled.  Because of that, it is easier to treat them as
> independent queues.  They are independent in all aspects except the IRQ.

Given that these numbers can be set independently, I can see that
treating TX and RX queues as having separate sets of channels might make
the set_channels operation easier to understand.

The kernel-doc actually committed for struct ethtool_channels is not at
all clear on what is meant by a 'channel', but it was certainly my
intent that a channel should correspond to one IRQ and the total number
of IRQs used by a device would be equal to the sum of
{rx,tx,other,combined}_count.  Which is certainly not the case for the
implementation in bnx2.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
