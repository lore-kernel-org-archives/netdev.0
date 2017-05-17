From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 9/9] nfp: eliminate an if statement in
 calculation of completed frames
Date: Wed, 17 May 2017 10:36:37 -0700
Message-ID: <20170517103637.2dd8b49d@cakuba.netronome.com>
References: <20170516005523.26124-1-jakub.kicinski@netronome.com>
        <20170516005523.26124-10-jakub.kicinski@netronome.com>
        <063D6719AE5E284EB5DD2968C1650D6DCFFF7B93@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oss-drivers@netronome.com" <oss-drivers@netronome.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:9919 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751348AbdEQRgt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 13:36:49 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFF7B93@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 May 2017 11:07:19 +0000, David Laight wrote:
> From: Jakub Kicinski
> > Sent: 16 May 2017 01:55
> > Given that our rings are always a power of 2, we can simplify the
> > calculation of number of completed TX descriptors by using masking
> > instead of if statement based on whether the index have wrapped
> > or not.
> > 
> > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> > ---
> >  drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 10 ++--------
> >  1 file changed, 2 insertions(+), 8 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
> > b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
> > index c64514f8ee65..da83e17b8b20 100644
> > --- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
> > +++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
> > @@ -940,10 +940,7 @@ static void nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
> >  	if (qcp_rd_p == tx_ring->qcp_rd_p)
> >  		return;
> > 
> > -	if (qcp_rd_p > tx_ring->qcp_rd_p)
> > -		todo = qcp_rd_p - tx_ring->qcp_rd_p;
> > -	else
> > -		todo = qcp_rd_p + tx_ring->cnt - tx_ring->qcp_rd_p;
> > +	todo = D_IDX(tx_ring, qcp_rd_p + tx_ring->cnt - tx_ring->qcp_rd_p);  
> 
> I'm not sure you need to add tx_ring->cnt here.
> I bet D_IDX() masks it away.

True, feel free to send a fix, or I will queue up a correction after
other work I have pending.

> >  	while (todo--) {
> >  		idx = D_IDX(tx_ring, tx_ring->rd_p++);  
> 
> That '++' looks suspicious.
> I think you need to decide whether you are incrementing pointers into the ring
> or indexes into it.
> Sometimes it is safer to use a non-wrapping index and mask when accessing the entry.
> 	entry_ptr = &ring[idx & (RING_SIZE - 1)]
> Ring full is then (read_idx == write_idx + RING_SIZE),
> ring empty (read_idx == write_idx).
> So the index just wrap at (probably)_2^32.

I may be missing the point.  I use a mix of the two, actually, the
software pointers are free running (non-wrapping) but the HW QCP
pointers wrap.  Because HW pointers wrap I always keep one entry on 
the rings empty, see nfp_net_tx_full().
