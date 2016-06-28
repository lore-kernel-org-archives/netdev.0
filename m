From: Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>
Subject: Re: [PATCH 2/4] mac80211/cfg: mesh: fix healing time when a mesh
 peer is disconnecting
Date: Tue, 28 Jun 2016 08:27:47 -0400
Message-ID: <20160628122747.GA7757@localhost>
References: <20160628111307.8784-1-yanivma@ti.com>
 <20160628111307.8784-2-yanivma@ti.com>
 <20160628111307.8784-3-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Maital Hahn <maitalm-l0cyMroinI0@public.gmane.org>
To: Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160628111307.8784-3-yanivma-l0cyMroinI0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 28, 2016 at 02:13:05PM +0300, Yaniv Machani wrote:
> From: Maital Hahn <maitalm-l0cyMroinI0@public.gmane.org>
> 
> Once receiving a CLOSE action frame from the disconnecting peer,
> flush all entries in the path table which has this peer as the
> next hop.

Please address the user-visible behavior in your commit messages.
Does it crash?  Does it send frames to an invalid peer?  Do
frames get dropped?

> In addition, upon receiving a packet, if next hop is not found,
> trigger PERQ immidiatly, instead of just putting it in the queue.

"PREQ"

Please split this into a separate patch that we can review
separately (and also give the "why" in the commit log).

> Signed-off-by: Maital Hahn <maitalm-l0cyMroinI0@public.gmane.org>
> Acked-by: Yaniv Machani <yanivma-l0cyMroinI0@public.gmane.org>
> ---
>  net/mac80211/cfg.c       |  1 +
>  net/mac80211/mesh.c      |  3 ++-
>  net/mac80211/mesh_hwmp.c | 42 +++++++++++++++++++++++++-----------------
>  3 files changed, 28 insertions(+), 18 deletions(-)
> 
> diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
> index 0c12e40..f876ef7 100644
> --- a/net/mac80211/cfg.c
> +++ b/net/mac80211/cfg.c
> @@ -1011,6 +1011,7 @@ static void sta_apply_mesh_params(struct ieee80211_local *local,
>  			if (sta->mesh->plink_state == NL80211_PLINK_ESTAB)
>  				changed = mesh_plink_dec_estab_count(sdata);
>  			sta->mesh->plink_state = params->plink_state;
> +			mesh_path_flush_by_nexthop(sta);

This isn't necessary, caller should already be doing
mesh_path_flush_by_nexthop() in every case I could see.  Besides it
cannot be done under plink lock.

> +++ b/net/mac80211/mesh.c
> @@ -159,7 +159,8 @@ void mesh_sta_cleanup(struct sta_info *sta)
>  	if (!sdata->u.mesh.user_mpm) {
>  		changed |= mesh_plink_deactivate(sta);
>  		del_timer_sync(&sta->mesh->plink_timer);
> -	}
> +	} else
> +		mesh_path_flush_by_nexthop(sta);

And this is already fixed in mac80211-next.

-- 
Bob Copeland %% http://bobcopeland.com/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
