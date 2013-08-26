From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 07/16] sfc: Limit scope of a Falcon A1 IRQ
 workaround
Date: Mon, 26 Aug 2013 23:47:05 +0100
Message-ID: <1377557225.16071.21.camel@deadeye.wl.decadent.org.uk>
References: <1377471363.2586.69.camel@deadeye.wl.decadent.org.uk>
	 <1377471823.2586.76.camel@deadeye.wl.decadent.org.uk>
	 <521B4AA9.9000906@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6834 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756Ab3HZWrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 18:47:09 -0400
In-Reply-To: <521B4AA9.9000906@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-08-26 at 16:31 +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 26-08-2013 3:03, Ben Hutchings wrote:
> 
> > We unconditionally acknowledge legacy interrupts just before disabling
> > them.  This workaround is needed on Falcon A1 but probably not on
> > later chips where the legacy interrupt mechanism is different.  It was
> > also originally done after the IRQ handler was removed, not before.
> > Restore the original behaviour for Falcon A1 only by doing this
> > acknowledgement in the efx_nic_type::fini operation.
> 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> >   drivers/net/ethernet/sfc/falcon.c |    4 ++--
> >   drivers/net/ethernet/sfc/nic.c    |    7 -------
> >   drivers/net/ethernet/sfc/nic.h    |    1 -
> >   3 files changed, 2 insertions(+), 10 deletions(-)
> 
> > diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
> > index f8de382..4492129 100644
> > --- a/drivers/net/ethernet/sfc/falcon.c
> > +++ b/drivers/net/ethernet/sfc/falcon.c
> > @@ -336,7 +336,7 @@ static void falcon_prepare_flush(struct efx_nic *efx)
> >    *
> >    * NB most hardware supports MSI interrupts
> >    */
> > -inline void falcon_irq_ack_a1(struct efx_nic *efx)
> > +static inline void falcon_irq_ack_a1(struct efx_nic *efx)
> 
>     Does inline make sense still when this now is referenced indirectly?

It's not inlined in the cleanup code, either before or after this
change.  But we do want this to be inlined in the following function,
falcon_legacy_interrupt_a1().  So I think it does make sense.

Ben.

> >   {
> >   	efx_dword_t reg;
> >
> > @@ -2343,7 +2343,7 @@ const struct efx_nic_type falcon_a1_nic_type = {
> >   	.remove = falcon_remove_nic,
> >   	.init = falcon_init_nic,
> >   	.dimension_resources = falcon_dimension_resources,
> > -	.fini = efx_port_dummy_op_void,
> > +	.fini = falcon_irq_ack_a1,
> >   	.monitor = falcon_monitor,
> >   	.map_reset_reason = falcon_map_reset_reason,
> >   	.map_reset_flags = falcon_map_reset_flags,
> 
> WBR, Sergei
> 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
