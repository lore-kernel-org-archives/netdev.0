From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Fix inconsistent teardown and release of private
 netdev state.
Date: Fri, 09 Jun 2017 16:33:47 +0200
Message-ID: <1497018827.12088.1.camel@sipsolutions.net>
References: <20170607.155411.201795978436906426.davem@davemloft.net>
         <1497012325.2424.12.camel@sipsolutions.net>
         <20170609.101733.1675759409997288763.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:56754 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751612AbdFIOdw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 10:33:52 -0400
In-Reply-To: <20170609.101733.1675759409997288763.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-09 at 10:17 -0400, David Miller wrote:
> 
> > I guess this must mean that that all others are dealing with the
> > problem "manually", right? Perhaps needs_free_netdev isn't all that
> > necessary then?
> 
> Yeah, the major two modes of operation are manual freeing of the
> netdev (usually at module unload time or similar) or via the
> destructor mechanisms.

Ok, thanks.

> > I think you introduced a bug though - isn't this needed?
> > 
> > --- a/net/mac80211/iface.c
> > +++ b/net/mac80211/iface.c
> > @@ -1816,6 +1816,7 @@ int ieee80211_if_add(struct ieee80211_local
> *local, const char *name,
> >                 ret = dev_alloc_name(ndev, ndev->name);
> >                 if (ret < 0) {
> >                         ieee80211_if_free(ndev);
> > +                       free_netdev(ndev);
> >                         return ret;
> >                 }
> >  
> > There was another caller of ieee80211_if_free() which you modified,
> and
> > thus needs the free_netdev() that you removed from it.
> 
> I think you are right.  The pattern is that when something fails
> after allocating the netdev, but before registering it, that code
> must free the netdev itself.

Right. Do you want me to put that into my tree? I could do it tonight,
or perhaps only Monday though.

> > Would an alternative have been to not use (priv_)destructor here,
> and
> > just free all the data after unregister_netdevice(_many)? This sets
> the
> > reg_state to NETREG_UNREGISTERING, so sysfs can no longer look at
> the
> > stats afterwards, and it's been unlisted (unlist_netdevice) so
> can't be
> > reached through any other means either.
> > 
> > IOW, this would also work and fix the bug above along the way?
> > 
> > diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
> > index 915d7e1b4545..23df973d5181 100644
> > --- a/net/mac80211/iface.c
> > +++ b/net/mac80211/iface.c
>  ...
> > @@ -1932,6 +1931,7 @@ void ieee80211_if_remove(struct
> ieee80211_sub_if_data *sdata)
> >  
> >       if (sdata->dev) {
> >               unregister_netdevice(sdata->dev);
> > +             ieee80211_if_free(sdata->dev);
> >       } else {
> >               cfg80211_unregister_wdev(&sdata->wdev);
> >               ieee80211_teardown_sdata(sdata);
> 
> Unless I misunderstood something, unregister_netdevice() here will
> invoke the ->priv_destructor() and thus now it will be invoked twice?

I think you missed that I removed priv_destructor?

johannes
