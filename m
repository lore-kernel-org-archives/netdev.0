From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] fix 3c515.c:(.text+0x57200): undefined reference to
	`pnp_get_resource'
Date: Fri, 20 Jun 2008 17:51:05 +0200
Message-ID: <20080620155105.GB6656@elte.hu>
References: <20080620093316.GA19003@elte.hu> <20080620081352.6cb4f9df.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jeff Garzik <jgarzik@redhat.com>,
	netdev@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:35664 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755866AbYFTPv2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 11:51:28 -0400
Content-Disposition: inline
In-Reply-To: <20080620081352.6cb4f9df.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Randy Dunlap <randy.dunlap@oracle.com> wrote:

> >     Signed-off-by: Ingo Molnar <mingo@elte.hu>
> 
> Patch is in Jeff's tree.

i see. Hm, as far as i can see the patch was not Cc:-ed to lkml hence i 
did not see that it exist and created a patch for it. Please Cc: lkml 
for any mainline fix you think other people might trigger.

also, here's some small nitpicking about your patch:

+#ifdef __ISAPNP__
        if (idev) {
                irq = pnp_irq(idev, 0);
                vp->dev = &idev->dev;
        } else {
                irq = inw(ioaddr + 0x2002) & 15;
        }
+#else
+       irq = inw(ioaddr + 0x2002) & 15;
+#endif

as you now unconditonally assume that idev is NULL in the !__ISAPNP__. 
Which is true currently but might not be with other changes (which is 
unlikely but still). It also duplicates code visually.

So i'd still slightly prefer my patch instead of yours which avoids the 
duplication and puts the assumption/constraint straight in there via a 
BUG_ON():

> >  	if (idev) {
> > +#ifdef __ISAPNP__
> >  		irq = pnp_irq(idev, 0);
> > +#else
> > +		/* Can not happen - in the !PNP case we always pass in NULL */
> > +		BUG_ON(1);
> > +#endif
> >  		vp->dev = &idev->dev;
> >  	} else {
> >  		irq = inw(ioaddr + 0x2002) & 15;
> > --

no strong feelings though - it's a nitpick and this code is obviously 
obsolete.

	Ingo
