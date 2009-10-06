From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH net-2.6] tg3: Fix phylib locking strategy
Date: Mon, 5 Oct 2009 17:03:39 -0700
Message-ID: <20091006000339.GA18376@xw6200.broadcom.net>
References: <1254777182.18287@xw6200> <1254778197.8559.2.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Felix Radensky" <felix@embedded-sol.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andy@greyhouse.net" <andy@greyhouse.net>
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4129 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754606AbZJFAE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2009 20:04:26 -0400
In-Reply-To: <1254778197.8559.2.camel@HP1>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 05, 2009 at 02:29:57PM -0700, Michael Chan wrote:
> 
> On Mon, 2009-10-05 at 14:09 -0700, Matt Carlson wrote:
> > Felix, can you verify this solves your problem?
> > 
> > ---
> > 
> > Felix Radensky noted that chip resets were generating stack trace dumps.
> > This is because the driver is attempting to acquire the mdio bus mutex
> > while holding the tp->lock spinlock.  The fix is to change the code such
> > that every phy access takes the tp->lock spinlock instead.
> > 
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > ---
> >  drivers/net/tg3.c |   37 ++++++++++++-------------------------
> >  drivers/net/tg3.h |    1 -
> >  2 files changed, 12 insertions(+), 26 deletions(-)
> > 
> > diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> > index f09bc5d..8afc60e 100644
> > --- a/drivers/net/tg3.c
> > +++ b/drivers/net/tg3.c
> > @@ -902,11 +902,12 @@ static int tg3_mdio_read(struct mii_bus *bp, int mii_id, int reg)
> >  	struct tg3 *tp = bp->priv;
> >  	u32 val;
> >  
> > -	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_PAUSED)
> > -		return -EAGAIN;
> > +	spin_lock(&tp->lock);
> >  
> 
> Matt, do we need spin_lock_bh() here?  The tp->lock can be taken in NAPI
> poll BH context.

Yes.  You are right.  And the same change needs to be made in
tg3_adjust_link().  V2 of the patch, coming up.

