From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 1/3 net-next] bnx2: Add support for ethtool
 --show-channels|--set-channels
Date: Tue, 7 Feb 2012 12:58:25 -0800
Message-ID: <1328648307.8014.35.camel@nseg_linux_HP1.broadcom.com>
References: <1328491480-13030-1-git-send-email-mchan@broadcom.com>
 <1328645954.3549.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4807 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756581Ab2BGVL4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 16:11:56 -0500
In-Reply-To: <1328645954.3549.17.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2012-02-07 at 20:19 +0000, Ben Hutchings wrote:
> On Sun, 2012-02-05 at 17:24 -0800, Michael Chan wrote:
> > Allow the user to override the default number of RSS/TSS rings.
> > 
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > ---
> >  drivers/net/ethernet/broadcom/bnx2.c |   99 ++++++++++++++++++++++++++++++---
> >  drivers/net/ethernet/broadcom/bnx2.h |    3 +
> >  2 files changed, 93 insertions(+), 9 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
> > index 0a4c540..2ab31da 100644
> > --- a/drivers/net/ethernet/broadcom/bnx2.c
> > +++ b/drivers/net/ethernet/broadcom/bnx2.c
> > @@ -6246,7 +6246,16 @@ static int
> >  bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
> >  {
> >  	int cpus = num_online_cpus();
> > -	int msix_vecs = min(cpus + 1, RX_MAX_RINGS);
> > +	int msix_vecs;
> > +
> > +	if (!bp->num_req_rx_rings)
> > +		msix_vecs = max(cpus + 1, bp->num_req_tx_rings);
> > +	else if (!bp->num_req_tx_rings)
> > +		msix_vecs = max(cpus, bp->num_req_rx_rings);
> > +	else
> > +		msix_vecs = max(bp->num_req_rx_rings, bp->num_req_tx_rings);
> > +
> > +	msix_vecs = min(msix_vecs, RX_MAX_RINGS);
> 
> If I read this correctly, IRQs may be shared between RX and TX queues
> i.e. there may be 'combined channels'.

It is true that an IRQ can have a TX and a RX queue, but they don't both
have to be enabled.  Because of that, it is easier to treat them as
independent queues.  They are independent in all aspects except the IRQ.
