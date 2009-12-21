From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: tg3: link is permanently down after ifdown and ifup
Date: Mon, 21 Dec 2009 10:19:19 -0800
Message-ID: <20091221181919.GB23940@xw6200.broadcom.net>
References: <4B056158.5060104@embedded-sol.com>
 <4B056D85.5010904@embedded-sol.com>
 <1258671053.14964.20.camel@nseg_linux_HP1.broadcom.com>
 <4B1F631E.5030908@embedded-sol.com>
 <20091210011931.GA30802@xw6200.broadcom.net>
 <4B2E547E.3040806@embedded-sol.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Felix Radensky" <felix@embedded-sol.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3055 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756200AbZLUSTt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Dec 2009 13:19:49 -0500
In-Reply-To: <4B2E547E.3040806@embedded-sol.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 20, 2009 at 08:44:46AM -0800, Felix Radensky wrote:
> Hi, Matt
> 
> Matt Carlson wrote:
> > I understand the problem now.  The problem is that tg3_set_power_state()
> > puts the phy into a low-power mode when it releases the device.  When
> > the phy is reacquired, a phy reset is missing to take the device back
> > out of the low-power mode.
> >
> > The patch at the bottom of this email is the fix I'm currently testing.
> > If you wish, you can try it out.
> >
> >
> > [PATCH] tg3: Fix 57780 connectivity problems
> >
> > When management firmware is not present, and WOL is disabled, the driver
> > will put the phy into a low-power mode when shutting down.  To get out
> > of low-power mode, the operation must be reversed or the phy must be
> > reset.
> >
> > In the past, the phylib reset the phy from either phy_start() or
> > phy_start_aneg().  This phy reset has been removed from more recent
> > kernels.  The tg3 driver already has phy reset code in place which is
> > called when it assumes control of the device.  It is bypassed if phylib
> > is enabled though.
> >
> > This patch removes the phylib exception.
> > ---
> >  drivers/net/tg3.c |    3 +--
> >  1 files changed, 1 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> > index 3a74d21..c0a3080 100644
> > --- a/drivers/net/tg3.c
> > +++ b/drivers/net/tg3.c
> > @@ -7523,8 +7523,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
> >  		tg3_abort_hw(tp, 1);
> >  	}
> >  
> > -	if (reset_phy &&
> > -	    !(tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB))
> > +	if (reset_phy)
> >  		tg3_phy_reset(tp);
> >  
> >  	err = tg3_chip_reset(tp);
> >   
> I can confirm that this patch fixes the problem I had. Thanks a lot for 
> the fix.
> 
> There was another problem in 2.6.32 that I reported, namely kernel soft 
> lockup
> when link is synchronized at 100Mbit/sec and tg3 with 57780 goes down . Were
> you able to reproduce it ?

No, but perhaps I don't understand the problem well enough.  Are you
saying that you encounter the problem when you run
'ifconfig bcm57780 down', or is it that losing link itself causes the
problem?

