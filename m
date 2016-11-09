From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH 1/2] net: mvpp2: don't bring up on MAC address set
Date: Wed, 9 Nov 2016 20:49:00 +0200
Message-ID: <20161109184900.lynqmb7athicvdpu@tarshish>
References: <ff17831771f3575f351c134703d3f153485b01c0.1478696194.git.baruch@tkos.co.il>
 <20161109142211.28caffda@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcin Wojtas <mw@semihalf.com>, netdev@vger.kernel.org,
        Gregory Clement <gregory.clement@free-electrons.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:53470 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753826AbcKIStF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 13:49:05 -0500
Content-Disposition: inline
In-Reply-To: <20161109142211.28caffda@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

On Wed, Nov 09, 2016 at 02:22:11PM +0100, Thomas Petazzoni wrote:
> On Wed,  9 Nov 2016 14:56:33 +0200, Baruch Siach wrote:
> > Current .ndo_set_mac_address implementation brings up the interface when revert
> > to original address after failure succeeds. Fix this.
> > 
> > Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> 
> Indeed, this piece of code is not very smart.
> 
> > diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> > index 60227a3452a4..e427b4706726 100644
> > --- a/drivers/net/ethernet/marvell/mvpp2.c
> > +++ b/drivers/net/ethernet/marvell/mvpp2.c
> > @@ -5686,9 +5686,8 @@ static int mvpp2_set_mac_address(struct net_device *dev, void *p)
> >  		if (!err)
> >  			return 0;
> >  		/* Reconfigure parser to accept the original MAC address */
> > -		err = mvpp2_prs_update_mac_da(dev, dev->dev_addr);
> > -		if (err)
> > -			goto error;
> > +		mvpp2_prs_update_mac_da(dev, dev->dev_addr);
> > +		goto error;
> 
> Wouldn't it make more sense to call mvpp2_prs_update_mac_da() under
> the error: goto label?

An is_valid_ether_addr() failure also goes to the 'error' label, so a more 
intrusive change would be needed.

> But if you think beyond that, it is a bit crazy that to handle the
> error case of mvpp2_prs_update_mac_da(), we have to call
> mvpp2_prs_update_mac_da(), which is exactly the same function...

I agree. This patch is only a minimal fix to the bug.

> Perhaps it would be interesting to investigate what are the various
> conditions for which mvpp2_prs_update_mac_da() fails, and see if we can
> avoid them.

mvpp2_prs_update_mac_da() calls mvpp2_prs_mac_da_accept() that in turn calls 
kzalloc(). kzalloc() might theoretically fail (though it never fails in 
practice). Getting rid of these would not be that easy.

Changing the MAC address in this driver is a rather complex process that 
involves removing the previous header parser, and installing a new one. There 
are many sanity and bound checks along the way.

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.52.368.4656, http://www.tkos.co.il -
