From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] compound skb frag pages appearing in start_xmit
Date: Thu, 11 Oct 2012 09:02:26 +0100
Message-ID: <1349942546.14806.7.camel@zakaz.uk.xensource.com>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com>
	 <1349790863.21172.4406.camel@edumazet-glaptop>
	 <1349792241.21847.199.camel@zakaz.uk.xensource.com>
	 <1349792847.21172.4479.camel@edumazet-glaptop>
	 <1349793630.21847.208.camel@zakaz.uk.xensource.com>
	 <1349863984.10070.26.camel@zakaz.uk.xensource.com>
	 <1349874598.10070.39.camel@zakaz.uk.xensource.com>
	 <748966751.20121010164949@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xen-devel <xen-devel@lists.xen.org>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:23603 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757827Ab2JKICa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 04:02:30 -0400
In-Reply-To: <748966751.20121010164949@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-10 at 15:49 +0100, Sander Eikelenboom wrote:
> Wednesday, October 10, 2012, 3:09:58 PM, you wrote:
> 
> > On Wed, 2012-10-10 at 11:13 +0100, Ian Campbell wrote:
> >> I haven't tackled netfront yet. 
> 
> > I seem to be totally unable to reproduce the equivalent issue on the
> > netfront xmit side, even though it seems like the loop in
> > xennet_make_frags ought to be obviously susceptible to it.
> 
> > Konrad, Sander, are either of you able to repro, e.g. with:
> 
> 
> Hmrrrmm i don't see any traces, only strange behaviour ..
> 
> - i can connect to guests by ssh, but it's sluggish, and sometimes stops working

I saw something like this (ssh sluggish) even with dom0 itself. I'm
trying to see if I can characterise it enough to reliably bisect it.

I already switched out xen-unstable for 4.2-testing but that didn't make
any difference.

> - The guest seem to keep trying to connect to netback:
> 
> [  658.276719] xen_bridge: port 2(vif40.0) entered forwarding state
> [  658.282258] xen_bridge: port 2(vif40.0) entered forwarding state
> [  663.945964] xen_bridge: port 7(vif39.0) entered forwarding state
> [  669.674277] xen_bridge: port 2(vif40.0) entered disabled state
> [  669.680290] device vif40.0 left promiscuous mode
> [  669.685464] xen_bridge: port 2(vif40.0) entered disabled state
> [  672.857222] device vif41.0 entered promiscuous mode
> [  673.166254] xen-blkback:ring-ref 8, event-channel 9, protocol 1 (x86_64-abi)
> [  673.176368] xen_bridge: port 2(vif41.0) entered forwarding state
> [  673.182042] xen_bridge: port 2(vif41.0) entered forwarding state
> [  674.439725] xen_bridge: port 7(vif39.0) entered disabled state
> [  674.445708] device vif39.0 left promiscuous mode
> [  674.450955] xen_bridge: port 7(vif39.0) entered disabled state
> [  677.726040] device vif42.0 entered promiscuous mode
> [  678.053381] xen-blkback:ring-ref 8, event-channel 9, protocol 1 (x86_64-abi)
> [  678.062804] xen_bridge: port 7(vif42.0) entered forwarding state
> [  678.068433] xen_bridge: port 7(vif42.0) entered forwarding state
> [  688.224736] xen_bridge: port 2(vif41.0) entered forwarding state
> [  693.080557] xen_bridge: port 7(vif42.0) entered forwarding state
> [  700.786276] xen_bridge: port 7(vif42.0) entered disabled state
> [  700.792484] device vif42.0 left promiscuous mode
> [  700.802409] xen_bridge: port 7(vif42.0) entered disabled state
> [  704.133606] device vif43.0 entered promiscuous mode
> [  704.460160] xen-blkback:ring-ref 8, event-channel 9, protocol 1 (x86_64-abi)
> [  704.469800] xen_bridge: port 7(vif43.0) entered forwarding state
> [  704.475303] xen_bridge: port 7(vif43.0) entered forwarding state
> [  719.493788] xen_bridge: port 7(vif43.0) entered forwarding state
> [  726.302456] xen_bridge: port 7(vif43.0) entered disabled state
> [  726.308898] device vif43.0 left promiscuous mode
> [  726.314029] xen_bridge: port 7(vif43.0) entered disabled state
> 
> All the guests are already up, but this keeps on going and going and going ....

The domain number seems to be climbing, are you sure something isn't
(crashing and) restarting?

> > diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> > index b06ef81..8a3f770 100644
> > --- a/drivers/net/xen-netfront.c
> > +++ b/drivers/net/xen-netfront.c
> > @@ -462,6 +462,8 @@ static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
> >                 ref = gnttab_claim_grant_reference(&np->gref_tx_head);
> >                 BUG_ON((signed short)ref < 0);
> >  
> > +               BUG_ON(PageCompound(skb_frag_page(frag)));
> > +
> >                 mfn = pfn_to_mfn(page_to_pfn(skb_frag_page(frag)));
> >                 gnttab_grant_foreign_access_ref(ref, np->xbdev->otherend_id,
> >                                                 mfn, GNTMAP_readonly);
> 
> > My repro for netback was just to netcat a wodge of data from dom0->domU
> > but going the other way doesn't seem to trigger.
> 
> 
> 
