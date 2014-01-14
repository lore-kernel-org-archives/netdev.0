From: Somnath Kotur <Somnath.Kotur@Emulex.Com>
Subject: RE: [PATCH net 2/2] be2net: Need a delay before processing CQE
 after 2nd mbox register write
Date: Tue, 14 Jan 2014 06:30:38 +0000
Message-ID: <2b2a8734-62c5-4983-a353-a79f0ed96466@CMEXHTCAS1.ad.emulex.com>
References: <4b4fd4cb-9d23-4900-a20c-f2c2bef70849@CMEXHTCAS2.ad.emulex.com>
 <20140110.151109.1275347758815420234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kalesh Purayil <Kalesh.Purayil@Emulex.Com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:59395 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaANGan convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 01:30:43 -0500
In-Reply-To: <20140110.151109.1275347758815420234.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, January 11, 2014 1:41 AM
> To: Somnath Kotur
> Cc: netdev@vger.kernel.org; Kalesh Purayil
> Subject: Re: [PATCH net 2/2] be2net: Need a delay before processing CQE
> after 2nd mbox register write
> 
> From: Somnath Kotur <somnath.kotur@emulex.com>
> Date: Wed, 8 Jan 2014 14:52:02 +0530
> 
> > Due to Host platform synchronization issues between the mbox RDY bit
> > polled status and the completion of the DMA for the CQE, it is
> > preferable that the Host always wait for the RDY bit to transition to
> > 1 after the 2nd mbox register write and always follow that with a
> > short wait for the valid bit in the CQE, before processing the CQE.
> >
> > Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
> > Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
> > ---
> >  drivers/net/ethernet/emulex/benet/be_cmds.c |    3 +++
> >  1 files changed, 3 insertions(+), 0 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c
> > b/drivers/net/ethernet/emulex/benet/be_cmds.c
> > index 94c35c8..78560f2 100644
> > --- a/drivers/net/ethernet/emulex/benet/be_cmds.c
> > +++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
> > @@ -502,6 +502,9 @@ static int be_mbox_notify_wait(struct be_adapter
> *adapter)
> >  	if (status != 0)
> >  		return status;
> >
> > +	/* Need a delay before processing CQE after 2nd mbox register write
> */
> > +	udelay(1);
> > +
> 
> Like others, I find his delay being used to fix the stated problem as
> questionable, at best.
> 
> Either find a more appropriate way to fix this problem, or elaborate (in the
> commit message), why this is really a suitable way to handle this.
Dave,
   	It indeed looks like an *arbitrary* delay between the mbox RDY read and CQ-entry read was not the right solution.
The correct fix would be for the driver to poll on the CQ-entry valid bit to become 1, as the time taken for the mbox-compl DMA
to finish may not be deterministic.
