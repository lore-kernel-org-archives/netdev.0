From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [RFC, RFT] Re: [PATCH] d80211: make sleeping in hw->config possible #2
Date: Tue, 18 Jul 2006 19:58:30 +0200
Message-ID: <200607181958.31184.mb@bu3sch.de>
References: <200607110054.36520.mb@bu3sch.de> <20060718185711.21aaf55b@griffin.suse.cz> <200607181936.55979.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:37270
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932336AbWGRR7Q
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jul 2006 13:59:16 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <200607181936.55979.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 18 July 2006 19:36, Michael Buesch wrote:
> On Tuesday 18 July 2006 18:57, Jiri Benc wrote:
> > On Tue, 11 Jul 2006 00:54:33 +0200, Michael Buesch wrote:
> > > This patch makes sleeping in the hw->config callback possible
> > > by removing the only atomic caller. The atomic caller was
> > > a timer and is replaced by a workqueue.
> > 
> > This is a modified version of the patch that doesn't use
> > cancel_rearming_delayed_work.
> > 
> > Signed-off-by: Jiri Benc <jbenc@suse.cz>
> > 
> > ---
> >  net/d80211/ieee80211.c       |   23 +++++++++++++++--------
> >  net/d80211/ieee80211_i.h     |    3 ++-
> >  net/d80211/ieee80211_iface.c |   10 ++++++++--
> >  net/d80211/ieee80211_sta.c   |   37 +++++++++++++++++--------------------
> >  4 files changed, 42 insertions(+), 31 deletions(-)
> > 
> > --- dscape.orig/net/d80211/ieee80211.c
> > +++ dscape/net/d80211/ieee80211.c
> > @@ -4552,14 +4552,6 @@ void ieee80211_unregister_hw(struct net_
> >          tasklet_disable(&local->tasklet);
> >          /* TODO: skb_queue should be empty here, no need to do anything? */
> >  
> > -	if (local->rate_limit)
> > -		del_timer_sync(&local->rate_limit_timer);
> > -	if (local->stat_time)
> > -		del_timer_sync(&local->stat_timer);
> > -	if (local->scan_timer.data)
> > -		del_timer_sync(&local->scan_timer);
> > -	ieee80211_rx_bss_list_deinit(dev);
> > -
> >  	rtnl_lock();
> >  	local->reg_state = IEEE80211_DEV_UNREGISTERED;
> >  	if (local->apdev)
> > @@ -4572,6 +4564,21 @@ void ieee80211_unregister_hw(struct net_
> >  	}
> >  	rtnl_unlock();
> >  
> > +	if (local->rate_limit)
> > +		del_timer_sync(&local->rate_limit_timer);
> > +	if (local->stat_time)
> > +		del_timer_sync(&local->stat_timer);
> > +	if (local->scan_work.data) {
> > +		local->sta_scanning = 0;
> > +		cancel_delayed_work(&local->scan_work);
> > +		flush_scheduled_work();
> > +		/* The scan_work is guaranteed not to be called at this
> > +		 * point. It is not scheduled and not running now. It can be
> 
> If it is guaranteed to be not to be called, the
> cancel_delayed_work(&local->scan_work);
> is unnecessary.
> If it is possible to be scheduled and delayed here,
> it's a bug.
> 
> So, if the first is true, we should remove it and if the second
> is true, well :)
> 
> The flush_scheduled_work() call is necessary, though.

Oh, no. I misread the code.
I think it's ok. Sorry for the noise :(

-- 
Greetings Michael.
