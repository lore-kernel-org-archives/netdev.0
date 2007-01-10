From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] d80211: Fix __ieee80211_if_del on live interfaces
Date: Wed, 10 Jan 2007 21:09:23 +0100
Message-ID: <200701102109.23565.mb@bu3sch.de>
References: <200701100119.19523.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Ulrich Kunitz <kune@deine-taler.de>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:40184
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965068AbXAJUKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 15:10:44 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200701100119.19523.flamingice@sourmilk.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 10 January 2007 07:19, Michael Wu wrote:
> d80211: Fix __ieee80211_if_del on live interfaces
> 
> ieee80211_if_reinit is called in __ieee80211_if_del, which clears the
> contents of sdata->u. After that, unregister_netdevice is called. If the
> interface is still up, unregister_netdevice will end up calling dev->stop,
> and dev->stop expects the contents of sdata->u to be valid. Bad things
> typically happen at this point.
> 
> This patch fixes that by setting dev->uninit to ieee80211_if_reinit and
> eliminating the call to ieee80211_if_reinit in __ieee80211_if_del. This
> allows ieee80211_if_reinit to be called at a safer time. It also allows
> the removal of the call to ieee80211_if_shutdown in ieee80211_if_reinit
> because ieee80211_if_reinit now will never be called while the interface
> is up.
> 
> Signed-off-by: Michael Wu <flamingice@sourmilk.net>

ACK, this fixes the lockup bug I recently reported.

> ---
> 
>  net/d80211/ieee80211.c       |    2 ++
>  net/d80211/ieee80211_iface.c |    4 ----
>  2 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
> index 964fe45..2f1dce5 100644
> --- a/net/d80211/ieee80211.c
> +++ b/net/d80211/ieee80211.c
> @@ -4324,6 +4324,7 @@ void ieee80211_if_setup(struct net_devic
>  	dev->open = ieee80211_open;
>  	dev->stop = ieee80211_stop;
>  	dev->tx_queue_len = 0;
> +	dev->uninit = ieee80211_if_reinit;
>  	dev->destructor = ieee80211_if_free;
>  }
>  
> @@ -4338,6 +4339,7 @@ void ieee80211_if_mgmt_setup(struct net_
>  	dev->type = ARPHRD_IEEE80211_PRISM;
>  	dev->hard_header_parse = header_parse_80211;
>  	dev->tx_queue_len = 0;
> +	dev->uninit = ieee80211_if_reinit;
>  	dev->destructor = ieee80211_if_free;
>  }
>  
> diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
> index cac0dd5..3b2d259 100644
> --- a/net/d80211/ieee80211_iface.c
> +++ b/net/d80211/ieee80211_iface.c
> @@ -234,9 +234,6 @@ void ieee80211_if_reinit(struct net_devi
>  		sdata->keys[i] = NULL;
>  	}
>  
> -	/* Shouldn't be necessary but won't hurt */
> -	ieee80211_if_shutdown(dev);
> -
>  	switch (sdata->type) {
>  	case IEEE80211_IF_TYPE_AP: {
>  		/* Remove all virtual interfaces that use this BSS
> @@ -311,7 +308,6 @@ void __ieee80211_if_del(struct ieee80211
>  {
>  	struct net_device *dev = sdata->dev;
>  
> -	ieee80211_if_reinit(dev);
>  	list_del(&sdata->list);
>  	ieee80211_sysfs_remove_netdevice(dev);
>  	unregister_netdevice(dev);
> 

-- 
Greetings Michael.
