From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2/2] NET: Re-add VLAN tag for devices incapable of keeping it
Date: Tue, 6 Nov 2007 13:28:56 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77027E9E9E@nekter>
References: <78C9135A3D2ECE4B8162EBDCE82CAD77027E9D5E@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Dave Johnson" <djohnson+linux-kernel@sw.starentnetworks.com>,
	"David Miller" <davem@davemloft.net>, <jes@trained-monkey.org>,
	<mchan@broadcom.com>, <ram.vepa@neterion.com>,
	<linux-ke
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:42441 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753707AbXKFS27 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 13:28:59 -0500
Content-class: urn:content-classes:message
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD77027E9D5E@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

If you can remove the patch for the s2io driver, we can submit a patch
that can dynamically program Xframe to strip or not strip the vlan tag
based on whether the vlan group is not NULL or NULL respectively. For
this, we have to modify the initialization as well as the vlan
registration.

With regards to the question on the Vlan id received not added to the
group, I think we should drop these packets. This change requires
additional changes to support multiple receive rings. But will add it to
the driver on our website, which supports multiple rx rings, tx fifos,
multiqueue etc, and is a very small incremental change.

Thanks,
Ram

> -----Original Message-----
> From: Ramkrishna Vepa [mailto:Ramkrishna.Vepa@neterion.com]
> Sent: Monday, November 05, 2007 6:40 PM
> To: Dave Johnson; David Miller; jes@trained-monkey.org;
> mchan@broadcom.com; ram.vepa@neterion.com;
linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org; bguo@sw.starentnetworks.com
> Subject: RE: [PATCH 2/2] NET: Re-add VLAN tag for devices incapable of
> keeping it
> 
> The Xframe (S2io) adapter can be programmed dynamically to either,
> always strip the vlan tag or not. In this case, if the vlan group is
> NULL, it can be programmed at run time to NOT strip the vlan tag.
> 
> When a packet with a Vlan id is received that is not added to the
group,
> should it be dropped or indicated up? Either can be handled by the
> hardware. The vlan tag in this particular case will be stripped as the
> vlan group is not NULL.
> 
> Ram
> 
> > -----Original Message-----
> > From: Dave Johnson
> [mailto:djohnson+linux-kernel@sw.starentnetworks.com]
> > Sent: Monday, November 05, 2007 9:47 AM
> > To: David Miller; jes@trained-monkey.org; mchan@broadcom.com;
> > ram.vepa@neterion.com; linux-kernel@vger.kernel.org;
> > netdev@vger.kernel.org; bguo@sw.starentnetworks.com
> > Subject: [PATCH 2/2] NET: Re-add VLAN tag for devices incapable of
> keeping
> > it
> >
> >
> > This patch changes the following drivers to use vlan_hwaccel_rx()
> > and/or vlan_hwaccel_receive_skb() with a NULL vlan group if needed
as
> > they are not setup to dynamically enable/disable vlan removal in
> > their MAC based on the vlan group:
> >
> > drivers/net/tg3.c           Tested on BCM5704, looks good
> > drivers/net/bnx2.c          Tested on BCM5708, looks good
> > drivers/net/acenic.c        Not tested, I don't have one of these
> > drivers/net/s2io.c          Not tested, I don't have one of these
> >
> > In addition, these drivers might also need changes, but should
> > probably be done by the maintainer as it's not clear exactly what
> > change is needed:
> >
> > drivers/net/amd8111e.c
> > drivers/net/cxgb3/*
> >
> > Signed-off-by: Dave Johnson <djohnson@sw.starentnetworks.com>
> >
> > ===== drivers/net/acenic.c 1.77 vs edited =====
> > --- 1.77/drivers/net/acenic.c	2007-07-24 16:28:41 -04:00
> > +++ edited/drivers/net/acenic.c	2007-11-03 12:27:40 -04:00
> > @@ -2036,7 +2036,7 @@
> >
> >  		/* send it up */
> >  #if ACENIC_DO_VLAN
> > -		if (ap->vlgrp && (bd_flags & BD_FLG_VLAN_TAG)) {
> > +		if (bd_flags & BD_FLG_VLAN_TAG) {
> >  			vlan_hwaccel_rx(skb, ap->vlgrp, retdesc->vlan);
> >  		} else
> >  #endif
> > ===== drivers/net/bnx2.c 1.135 vs edited =====
> > --- 1.135/drivers/net/bnx2.c	2007-09-20 15:14:21 -04:00
> > +++ edited/drivers/net/bnx2.c	2007-11-05 09:34:26 -05:00
> > @@ -2493,7 +2493,8 @@
> >  		}
> >
> >  #ifdef BCM_VLAN
> > -		if ((status & L2_FHDR_STATUS_L2_VLAN_TAG) && (bp->vlgrp
> != 0))
> > {
> > +		if ((status & L2_FHDR_STATUS_L2_VLAN_TAG) &&
> > +		    (bp->vlgrp || (bp->flags & ASF_ENABLE_FLAG))) {
> >  			vlan_hwaccel_receive_skb(skb, bp->vlgrp,
> >  				rx_hdr->l2_fhdr_vlan_tag);
> >  		}
> > ===== drivers/net/s2io.c 1.124 vs edited =====
> > --- 1.124/drivers/net/s2io.c	2007-08-03 18:10:44 -04:00
> > +++ edited/drivers/net/s2io.c	2007-11-03 12:29:09 -04:00
> > @@ -6834,8 +6834,7 @@
> >  	sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
> >  	if (!sp->lro) {
> >  		skb->protocol = eth_type_trans(skb, dev);
> > -		if ((sp->vlgrp && RXD_GET_VLAN_TAG(rxdp->Control_2) &&
> > -			vlan_strip_flag)) {
> > +		if (RXD_GET_VLAN_TAG(rxdp->Control_2) &&
> vlan_strip_flag) {
> >  			/* Queueing the vlan frame to the upper layer */
> >  			if (napi)
> >  				vlan_hwaccel_receive_skb(skb, sp->vlgrp,
> > ===== drivers/net/tg3.c 1.523 vs edited =====
> > --- 1.523/drivers/net/tg3.c	2007-09-11 04:28:44 -04:00
> > +++ edited/drivers/net/tg3.c	2007-11-05 09:38:33 -05:00
> > @@ -3417,7 +3417,7 @@
> >
> >  		skb->protocol = eth_type_trans(skb, tp->dev);
> >  #if TG3_VLAN_TAG_USED
> > -		if (tp->vlgrp != NULL &&
> > +		if ((tp->vlgrp || (tp->tg3_flags & TG3_FLAG_ENABLE_ASF))
> &&
> >  		    desc->type_flags & RXD_FLAG_VLAN) {
> >  			tg3_vlan_rx(tp, skb,
> >  				    desc->err_vlan & RXD_VLAN_MASK);

