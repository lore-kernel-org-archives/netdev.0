From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] cnic: fix double initalization of bnx2 based cards
Date: Tue, 8 Mar 2011 11:43:16 -0800
Message-ID: <1299613396.12601.21.camel@HP1>
References: <1299610588-22356-1-git-send-email-nhorman@tuxdriver.com>
 <1299610768.4957.1.camel@bwh-desktop> <1299611277.12601.15.camel@HP1>
 <20110308193601.GA19669@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eddie Wai" <eddie.wai@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3926 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755002Ab1CHTsW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 14:48:22 -0500
In-Reply-To: <20110308193601.GA19669@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2011-03-08 at 11:36 -0800, Neil Horman wrote:
> On Tue, Mar 08, 2011 at 11:07:57AM -0800, Michael Chan wrote:
> > 
> > On Tue, 2011-03-08 at 10:59 -0800, Ben Hutchings wrote:
> > > On Tue, 2011-03-08 at 13:56 -0500, Neil Horman wrote:
> > > > bnx2 cards can work with the cnic driver, but when the cnic driver detects a
> > > > bnx2 card, is_cnic_dev erroneously calls the initalization routines for both
> > > > bnx2 and bnx2x (the former being a regex subset of the later).
> > > 
> > > Since when does strcmp() do a regex match?
> > 
> > Yeah, strcmp() does NULL-terminated string compare, right?
> > 
> Sorry, poor choice of words.  It doesn't do a regex match, I only ment to
> illustrate that bnx2 is a substring of bnx2x.
> 
> strcmp does this:
> 
> strcmp(const char *str1, const char *str2) {
> ...
> 	while (*s1 || *s2) {
> 		...
> 	}
> ...
> }
> 
> Since bnx2 is a substring of bnx2 both if clauses are a match, since you'll hit
> the null terminator of the shorter string in both, which means we call both
> initalization functions.

No, that should not happen.  When we compare NULL-terminated "bnx2" with
NULL-terminated "bnx2x", it won't match because the '\0' won't match the
'x', right?

I think the patch is good.  We can avoid the unnecessary strcmp() when
we have a match with "bnx2" already.  But we should not get both matches
even without the patch.

> 
> I'll leave commentary on initalization in is_cnic_dev to the authors :)
> 
> Neil
> 
> 
> > 
> > > 
> > > Ben.
> > > 
> > > >   This causes
> > > > initalization of bnx2 to unilaterally fail in the cnic driver, which, while not
> > > > catastrophic, is definately not expected.  Fix this by choosing either the bnx2
> > > > or bnx2x initalization path, not both
> > > > 
> > > > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > > > CC: David S. Miller <davem@davemloft.net>
> > > > CC: Michael Chan <mchan@broadcom.com>
> > > > CC: Dmitry Kravkov <dmitry@broadcom.com>
> > > > CC: Eddie Wai <waie@broadcom.com>
> > > > CC: Eilon Greenstein <eilong@broadcom.com>
> > > > ---
> > > >  drivers/net/cnic.c |    2 +-
> > > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > > > 
> > > > diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
> > > > index 271a1f0..18b59ad 100644
> > > > --- a/drivers/net/cnic.c
> > > > +++ b/drivers/net/cnic.c
> > > > @@ -5292,7 +5292,7 @@ static struct cnic_dev *is_cnic_dev(struct net_device *dev)
> > > >  
> > > >  		if (!strcmp(drvinfo.driver, "bnx2"))
> > > >  			cdev = init_bnx2_cnic(dev);
> > > > -		if (!strcmp(drvinfo.driver, "bnx2x"))
> > > > +		else if (!strcmp(drvinfo.driver, "bnx2x"))
> > > >  			cdev = init_bnx2x_cnic(dev);
> > > >  		if (cdev) {
> > > >  			write_lock(&cnic_dev_lock);
> > > 
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 


