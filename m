From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [RFC,
	RFT] Re: [PATCH] d80211: make sleeping in hw->config possible #2
Date: Tue, 18 Jul 2006 19:36:55 +0200
Message-ID: <200607181936.55979.mb@bu3sch.de>
References: <200607110054.36520.mb@bu3sch.de>
	<20060718185711.21aaf55b@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
In-Reply-To: <20060718185711.21aaf55b-IhiK2ZEFs2oCVLCxKZUutA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <http://bat.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://bat.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <http://bat.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 18 July 2006 18:57, Jiri Benc wrote:
> On Tue, 11 Jul 2006 00:54:33 +0200, Michael Buesch wrote:
> > This patch makes sleeping in the hw->config callback possible
> > by removing the only atomic caller. The atomic caller was
> > a timer and is replaced by a workqueue.
> 
> This is a modified version of the patch that doesn't use
> cancel_rearming_delayed_work.
> 
> Signed-off-by: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
> 
> ---
>  net/d80211/ieee80211.c       |   23 +++++++++++++++--------
>  net/d80211/ieee80211_i.h     |    3 ++-
>  net/d80211/ieee80211_iface.c |   10 ++++++++--
>  net/d80211/ieee80211_sta.c   |   37 +++++++++++++++++--------------------
>  4 files changed, 42 insertions(+), 31 deletions(-)
> 
> --- dscape.orig/net/d80211/ieee80211.c
> +++ dscape/net/d80211/ieee80211.c
> @@ -4552,14 +4552,6 @@ void ieee80211_unregister_hw(struct net_
>          tasklet_disable(&local->tasklet);
>          /* TODO: skb_queue should be empty here, no need to do anything? */
>  
> -	if (local->rate_limit)
> -		del_timer_sync(&local->rate_limit_timer);
> -	if (local->stat_time)
> -		del_timer_sync(&local->stat_timer);
> -	if (local->scan_timer.data)
> -		del_timer_sync(&local->scan_timer);
> -	ieee80211_rx_bss_list_deinit(dev);
> -
>  	rtnl_lock();
>  	local->reg_state = IEEE80211_DEV_UNREGISTERED;
>  	if (local->apdev)
> @@ -4572,6 +4564,21 @@ void ieee80211_unregister_hw(struct net_
>  	}
>  	rtnl_unlock();
>  
> +	if (local->rate_limit)
> +		del_timer_sync(&local->rate_limit_timer);
> +	if (local->stat_time)
> +		del_timer_sync(&local->stat_timer);
> +	if (local->scan_work.data) {
> +		local->sta_scanning = 0;
> +		cancel_delayed_work(&local->scan_work);
> +		flush_scheduled_work();
> +		/* The scan_work is guaranteed not to be called at this
> +		 * point. It is not scheduled and not running now. It can be

If it is guaranteed to be not to be called, the
cancel_delayed_work(&local->scan_work);
is unnecessary.
If it is possible to be scheduled and delayed here,
it's a bug.

So, if the first is true, we should remove it and if the second
is true, well :)

The flush_scheduled_work() call is necessary, though.

-- 
Greetings Michael.
