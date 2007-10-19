From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] PHYLIB: IRQ event workqueue handling fixes
Date: Fri, 19 Oct 2007 12:38:29 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0710191229510.13279@blysk.ds.pg.gda.pl>
References: <20071015125301.GC3015@ff.dom.local>
 <Pine.LNX.4.64N.0710151737250.16262@blysk.ds.pg.gda.pl> <20071016062108.GB1000@ff.dom.local>
 <Pine.LNX.4.64N.0710161759050.22596@blysk.ds.pg.gda.pl> <20071017085809.GA1658@ff.dom.local>
 <Pine.LNX.4.64N.0710171221510.28993@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756004AbXJSLiv@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64N.0710171221510.28993@blysk.ds.pg.gda.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Oct 2007, Maciej W. Rozycki wrote:

> > 1) phy_change() checks PHY_HALTED flag without lock; I think it's
> > racy: eg. if it's done during phy_stop() it can check just before
> > the flag is set and reenable interrupts just after phy_stop() ends.
> 
>  I remember having a look into it, but it was long ago and I cannot 
> immediately recall the conclusion.  Which means it is either broken or 
> deserves a comment as non-obvious.  I will have a look into it again, but 
> I am resource-starved a little at the moment, sorry.

 Well, I have now recalled what the issue is -- we just plainly and simply 
want to avoid a hardirq spinlock for the very reason we do not do all the 
processing in the hardirq handler.  The thing is we make accesses to the 
MDIO bus with the phydev lock held and it may take ages until these 
accesses will have completed.  And we cannot afford keeping interrupts 
disabled for so long.

 So the only way is to make the check for the HALTED state lockless and 
make sure any race condition is handled gracefully and does not lead to 
inconsistent behaviour.  Which I think as of what we have in the 
net-2.6.24 tree is the case, but there are never too many eyes to look at 
a piece of code, so if anybody feels like proving me wrong, then just go 
ahead!

  Maciej
