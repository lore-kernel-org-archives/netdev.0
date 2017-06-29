From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [oss-drivers] Re: [PATCH net-next v2 8/9] nfp: add a stats
 handler for flower offloads
Date: Thu, 29 Jun 2017 10:14:58 +0200
Message-ID: <20170629081457.GC29453@vergenet.net>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
 <1498681802-2897-9-git-send-email-simon.horman@netronome.com>
 <20170628182817.13f9d7c7@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35500 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751986AbdF2IPE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 04:15:04 -0400
Received: by mail-wm0-f49.google.com with SMTP id w126so74495250wme.0
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 01:15:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170628182817.13f9d7c7@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 28, 2017 at 06:28:17PM -0700, Jakub Kicinski wrote:
> On Wed, 28 Jun 2017 22:30:01 +0200, Simon Horman wrote:
> > @@ -288,7 +292,21 @@ nfp_flower_del_offload(struct nfp_app *app, struct net_device *netdev,
> >  static int
> >  nfp_flower_get_stats(struct nfp_app *app, struct tc_cls_flower_offload *flow)
> >  {
> > -	return -EOPNOTSUPP;
> > +	struct nfp_fl_payload *nfp_flow;
> > +
> > +	nfp_flow = nfp_flower_find_in_fl_table(app, flow->cookie);
> > +	if (!nfp_flow)
> > +		return -EINVAL;
> > +
> > +	spin_lock(&nfp_flow->lock);
> > +	tcf_exts_stats_update(flow->exts, nfp_flow->stats.bytes,
> > +			      nfp_flow->stats.pkts, nfp_flow->stats.used);
> > +
> > +	nfp_flow->stats.pkts = 0;
> > +	nfp_flow->stats.bytes = 0;
> > +	spin_unlock(&nfp_flow->lock);
> > +
> > +	return 0;
> >  }
> 
> This needs to take spin_lock_bh() to lock out the RX path safely :(

Sorry about that, will fix.
