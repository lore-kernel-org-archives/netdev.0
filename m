From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC net-next 3/9] nfp: provide infrastructure for
 offloading flower based TC filters
Date: Wed, 28 Jun 2017 10:12:45 +0200
Message-ID: <20170628081244.GC9412@vergenet.net>
References: <1498605709-22574-1-git-send-email-simon.horman@netronome.com>
 <1498605709-22574-4-git-send-email-simon.horman@netronome.com>
 <20170627231306.2804cdef@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:33677 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750829AbdF1IMt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 04:12:49 -0400
Received: by mail-wm0-f41.google.com with SMTP id z75so10518553wmc.0
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 01:12:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170627231306.2804cdef@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 27, 2017 at 11:13:06PM -0700, Jakub Kicinski wrote:
> On Wed, 28 Jun 2017 01:21:43 +0200, Simon Horman wrote:
> > From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> > 
> > Adds a flower based TC offload handler for representor devices, this
> > is in addition to the bpf based offload handler. The changes in this
> > patch will be used in a follow-up patch to add tc flower offload to
> > the NFP.
> > 
> > The flower app enables tc offloads on representors by default.
> > 
> > Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> 
> > diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.c b/drivers/net/ethernet/netronome/nfp/flower/main.c
> > index ab68a8f58862..7b27871f489c 100644
> > --- a/drivers/net/ethernet/netronome/nfp/flower/main.c
> > +++ b/drivers/net/ethernet/netronome/nfp/flower/main.c
> > @@ -37,6 +37,7 @@
> >  #include <net/devlink.h>
> >  #include <net/dst_metadata.h>
> >  
> > +#include "main.h"
> >  #include "../nfpcore/nfp_cpp.h"
> >  #include "../nfpcore/nfp_nsp.h"
> >  #include "../nfp_app.h"
> > @@ -303,8 +304,14 @@ static int nfp_flower_vnic_init(struct nfp_app *app, struct nfp_net *nn,
> >  	eth_hw_addr_random(nn->dp.netdev);
> >  	netif_keep_dst(nn->dp.netdev);
> >  
> > +	if (nfp_flower_repr_init(app))
> > +		goto err_free_priv;
> 
> Please make the contents of nfp_flower_repr_init() part of app's .init
> callback.

Thanks, I will fix this up and other comments relating to
nfp_flower_repr_init()

> >  	return 0;
> >  
> > +err_free_priv:
> > +	kfree(app->priv);
> > +	app->priv = NULL;
> 
> This doesn't belong here after my recent series.  priv init was moved
> to app's init callback.
> 
> >  err_invalid_port:
> >  	nn->port = nfp_port_alloc(app, NFP_PORT_INVALID, nn->dp.netdev);
> >  	return PTR_ERR_OR_ZERO(nn->port);
> 
> > +int nfp_flower_repr_init(struct nfp_app *app)
> > +{
> > +	u64 version;
> > +	int err;
> > +
> > +	version = nfp_rtsym_read_le(app->pf->rtbl, "hw_flower_version", &err);
> > +	if (err)
> > +		return -EINVAL;
> 
> Nit: this could return err directly.  Also I think it's worth printing
> an error message.
> 
> > +	/* We need to ensure hardware has enough flower capabilities. */
> > +	if (version != NFP_FLOWER_ALLOWED_VER)
> > +		return -EINVAL;
> 
> Here we should definitely tell the user what went wrong.
> 
> > +	return 0;
> > +}
> 
> > diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
> > index bc9108071e5b..a73b311c1f75 100644
> > --- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
> > +++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
> > @@ -250,6 +250,18 @@ static int nfp_repr_open(struct net_device *netdev)
> >  	return nfp_app_repr_open(repr->app, repr);
> >  }
> >  
> > +static int
> > +nfp_repr_setup_tc(struct net_device *netdev, u32 handle, u32 chain_index,
> > +		  __be16 proto, struct tc_to_netdev *tc)
> > +{
> > +	struct nfp_repr *repr = netdev_priv(netdev);
> > +
> > +	if (chain_index)
> > +		return -EOPNOTSUPP;
> > +
> > +	return nfp_app_setup_tc(repr->app, netdev, handle, proto, tc);
> > +}
> 
> Just a reminder that this could be a nfp_port function.

Sure, will do.
