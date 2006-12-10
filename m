From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] ieee80211softmac: Fix errors related to the work_struct changes
Date: Sun, 10 Dec 2006 19:40:48 +0100
Message-ID: <200612101940.48996.mb@bu3sch.de>
References: <20061210173908.GB29871@p15091797.pureserver.info> <200612101849.47179.mb@bu3sch.de> <20061210183536.GC29871@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: dsd@gentoo.org, Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:33426
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762338AbWLJSlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 13:41:13 -0500
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <20061210183536.GC29871@p15091797.pureserver.info>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 10 December 2006 19:35, Ulrich Kunitz wrote:
> On 06-12-10 18:49 Michael Buesch wrote:
> 
> > On Sunday 10 December 2006 18:39, Ulrich Kunitz wrote:
> > > The signature of work functions changed recently from a context
> > > pointer to the work structure pointer. This caused a problem in
> > > the ieee80211softmac code, because the ieee80211softmac_assox_work
> > > function has  been called directly with a parameter explicitly
> > > casted to (void*). This compiled correctly but resulted in a
> > > softlock, because mutex_lock was called with the wrong memory
> > > address. The patch fixes the problem. Another issue was a wrong
> > > call of the schedule_work function. Softmac works again and this
> > > fixes the problem I mentioned earlier in the zd1211rw rx tasklet
> > > patch. The patch is against Linus' tree (commit af1713e0).
> > > 
> > > Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
> > > ---
> > >  net/ieee80211/softmac/ieee80211softmac_assoc.c |    6 +++---
> > >  1 files changed, 3 insertions(+), 3 deletions(-)
> > > 
> > > diff --git a/net/ieee80211/softmac/ieee80211softmac_assoc.c b/net/ieee80211/softmac/ieee80211softmac_assoc.c
> > > index eec1a1d..a824852 100644
> > > --- a/net/ieee80211/softmac/ieee80211softmac_assoc.c
> > > +++ b/net/ieee80211/softmac/ieee80211softmac_assoc.c
> > > @@ -167,7 +167,7 @@ static void
> > >  ieee80211softmac_assoc_notify_scan(struct net_device *dev, int event_type, void *context)
> > >  {
> > >  	struct ieee80211softmac_device *mac = ieee80211_priv(dev);
> > > -	ieee80211softmac_assoc_work((void*)mac);
> > > +	ieee80211softmac_assoc_work(&mac->associnfo.work.work);
> > >  }
> > >  
> > >  static void
> > > @@ -177,7 +177,7 @@ ieee80211softmac_assoc_notify_auth(struc
> > >  
> > >  	switch (event_type) {
> > >  	case IEEE80211SOFTMAC_EVENT_AUTHENTICATED:
> > > -		ieee80211softmac_assoc_work((void*)mac);
> > > +		ieee80211softmac_assoc_work(&mac->associnfo.work.work);
> > >  		break;
> > >  	case IEEE80211SOFTMAC_EVENT_AUTH_FAILED:
> > >  	case IEEE80211SOFTMAC_EVENT_AUTH_TIMEOUT:
> > > @@ -438,7 +438,7 @@ ieee80211softmac_try_reassoc(struct ieee
> > >  
> > >  	spin_lock_irqsave(&mac->lock, flags);
> > >  	mac->associnfo.associating = 1;
> > > -	schedule_work(&mac->associnfo.work);
> > > +	schedule_delayed_work(&mac->associnfo.work, 0);
> > 
> > Why do you use a zero delay here? What does that fix?
> > 
> 
> The problem is that you there are now different work structures:
> struct work_struct and struct delayed_work. The quick fix seems to
> have been to change all old work_structs as associnfo's work to
> delayed_work. The way the structures are designed calling
> schedule_work or schedule_delayed_work doesn't matter, but you
> will get a gcc warning, because the pointer types are not
> identical. This change works around the warning in the same way as
> the other schedule_work calls for associnfo's work.
> 
> I'm not sure, whether the breaking of the workqueue API is really
> worth it. What I see is that the change introduced choices and
> choices make things more complex.

Ah, ok. Thanks for the clarification. In this case this patch is
ACKed as well.

-- 
Greetings Michael.
