From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix inconsistent teardown and release of private
 netdev state.
Date: Fri, 09 Jun 2017 10:17:33 -0400 (EDT)
Message-ID: <20170609.101733.1675759409997288763.davem@davemloft.net>
References: <20170607.155411.201795978436906426.davem@davemloft.net>
        <1497012325.2424.12.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59042 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751608AbdFIORf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 10:17:35 -0400
In-Reply-To: <1497012325.2424.12.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 09 Jun 2017 14:45:25 +0200

> Under drivers/ in general, I count more than 400 calls to
> register_netdev[ice](), but only 39 that set the new needs_free_netdev.
> Some will overlap and have the same ops, but still, that's a rather
> small portion of them. The logic means those that don't set
> needs_free_netdev can't really use the new priv_destructor (previously
> destructor), I think? It seems to me that priv_destructor should imply
> needs_free_netdev (though not necessarily the other way around).
> 
> I guess this must mean that that all others are dealing with the
> problem "manually", right? Perhaps needs_free_netdev isn't all that
> necessary then?

Yeah, the major two modes of operation are manual freeing of the
netdev (usually at module unload time or similar) or via the
destructor mechanisms.

> I think you introduced a bug though - isn't this needed?
> 
> --- a/net/mac80211/iface.c
> +++ b/net/mac80211/iface.c
> @@ -1816,6 +1816,7 @@ int ieee80211_if_add(struct ieee80211_local *local, const char *name,
>                 ret = dev_alloc_name(ndev, ndev->name);
>                 if (ret < 0) {
>                         ieee80211_if_free(ndev);
> +                       free_netdev(ndev);
>                         return ret;
>                 }
>  
> There was another caller of ieee80211_if_free() which you modified, and
> thus needs the free_netdev() that you removed from it.

I think you are right.  The pattern is that when something fails
after allocating the netdev, but before registering it, that code
must free the netdev itself.

> Would an alternative have been to not use (priv_)destructor here, and
> just free all the data after unregister_netdevice(_many)? This sets the
> reg_state to NETREG_UNREGISTERING, so sysfs can no longer look at the
> stats afterwards, and it's been unlisted (unlist_netdevice) so can't be
> reached through any other means either.
> 
> IOW, this would also work and fix the bug above along the way?
> 
> diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
> index 915d7e1b4545..23df973d5181 100644
> --- a/net/mac80211/iface.c
> +++ b/net/mac80211/iface.c
 ...
> @@ -1932,6 +1931,7 @@ void ieee80211_if_remove(struct ieee80211_sub_if_data *sdata)
>  
>  	if (sdata->dev) {
>  		unregister_netdevice(sdata->dev);
> +		ieee80211_if_free(sdata->dev);
>  	} else {
>  		cfg80211_unregister_wdev(&sdata->wdev);
>  		ieee80211_teardown_sdata(sdata);

Unless I misunderstood something, unregister_netdevice() here will
invoke the ->priv_destructor() and thus now it will be invoked twice?
