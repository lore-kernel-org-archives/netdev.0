From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Fri, 19 Oct 2007 16:39:21 +0200
Message-ID: <20071019143921.GB2598@ff.dom.local>
References: <20071015125301.GC3015@ff.dom.local> <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl> <20071016062108.GB1000@ff.dom.local> <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl> <20071017085809.GA1658@ff.dom.local> <Pine.LNX.4.64N.0710171221510.28993@blysk.ds.pg.gda.pl> <Pine.LNX.4.64N.0710191229510.13279@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Maciej W\. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:58690 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755058AbXJSOgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 10:36:17 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64N.0710191229510.13279@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 19, 2007 at 12:38:29PM +0100, Maciej W. Rozycki wrote:
> On Thu, 18 Oct 2007, Maciej W. Rozycki wrote:
> 
> > > 1) phy_change() checks PHY_HALTED flag without lock; I think it's
> > > racy: eg. if it's done during phy_stop() it can check just before
> > > the flag is set and reenable interrupts just after phy_stop() ends.
> > 
> >  I remember having a look into it, but it was long ago and I cannot 
> > immediately recall the conclusion.  Which means it is either broken or 
> > deserves a comment as non-obvious.  I will have a look into it again, but 
> > I am resource-starved a little at the moment, sorry.
> 
>  Well, I have now recalled what the issue is -- we just plainly and simply 
> want to avoid a hardirq spinlock for the very reason we do not do all the 
> processing in the hardirq handler.  The thing is we make accesses to the 
> MDIO bus with the phydev lock held and it may take ages until these 
> accesses will have completed.  And we cannot afford keeping interrupts 
> disabled for so long.
> 
>  So the only way is to make the check for the HALTED state lockless and 
> make sure any race condition is handled gracefully and does not lead to 
> inconsistent behaviour.  Which I think as of what we have in the 
> net-2.6.24 tree is the case, but there are never too many eyes to look at 
> a piece of code, so if anybody feels like proving me wrong, then just go 
> ahead!

Actually I'm not convinced with this explanation. It seems to me that
since there are such serious locking problems (especially with rntl),
there could be once more considered a private workqueue. You've
written earlier about being a lonely user of this code. But, since
Benjamin offered his help with changing to mutexes, which looks like
very reasonable idea to me (probably I miss most of the points...),
maybe it's very good opportunity to both: make this code better and
double the user base! I'm interested in looking for such solution
if Benjamin thinks there could be too few problems for him... So,
let somebody tell us what could be wrong with this idea?

Cheers (till Monday),
Jarek P.
