From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] libertas: ensure we clean up a scan request properly
Date: Wed, 26 Oct 2011 12:35:23 -0500
Message-ID: <1319650525.8698.11.camel@dcbw.foobar.com>
References: <20111026101926.48109373@queued.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dsd@laptop.org, libertas-dev@lists.infradead.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linville@tuxdriver.com, linux-kernel@vger.kernel.org
To: Andres Salomon <dilinger@queued.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111026101926.48109373@queued.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-10-26 at 10:19 -0700, Andres Salomon wrote:
> Commit 2e30168b ("libertas: terminate scan when stopping interface")
> adds cleanup code to lbs_eth_stop to call cfg80211_scan_done if there's
> an outstanding cfg80211_scan_request.  However, it assumes that the
> scan request was allocated via the cfg80211 stack.  Libertas has
> its own internal allocation method, kept track of with
> priv->internal_scan.  This doesn't set scan_req->wiphy, amongst other
> things, which results in hitting a BUG() when we call cfg80211_scan_done
> on the request.
> 
> This provides a function to take care of the low-level scan_req cleanup
> details.  We simply call that to deal with finishing up scan requests.

Acked-by: Dan Williams <dcbw@redhat.com>

> The bug we were hitting was:
> 
> [  964.321495] kernel BUG at net/wireless/core.h:87!
> [  964.329970] Unable to handle kernel NULL pointer dereference at virtual address 00000000
> [  964.341963] pgd = dcf80000
> ...
> [  964.849998] 9fe0: 00000000 beb417b8 4018e280 401e822c 60000010 00000004 00000000 00000000
> [  964.865007] [<c003104c>] (__bug+0x1c/0x28) from [<c0384ffc>] (cfg80211_scan_done+0x54/0x6c)
> [  964.895324] [<c0384ffc>] (cfg80211_scan_done+0x54/0x6c) from [<bf028bac>] (lbs_eth_stop+0x10c/0x188 [libertas])
> [  964.895324] [<bf028bac>] (lbs_eth_stop+0x10c/0x188 [libertas]) from [<c03002a0>] (__dev_close_many+0x94/0xc4)
> [  964.918995] [<c03002a0>] (__dev_close_many+0x94/0xc4) from [<c030037c>] (dev_close_many+0x78/0xe0)
> 
> Signed-off-by: Andres Salomon <dilinger@queued.net>
> ---
>  drivers/net/wireless/libertas/cfg.c  |   25 +++++++++++++++++--------
>  drivers/net/wireless/libertas/cfg.h  |    1 +
>  drivers/net/wireless/libertas/main.c |    6 ++----
>  3 files changed, 20 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/wireless/libertas/cfg.c b/drivers/net/wireless/libertas/cfg.c
> index ff63782..4fcd653 100644
> --- a/drivers/net/wireless/libertas/cfg.c
> +++ b/drivers/net/wireless/libertas/cfg.c
> @@ -728,15 +728,9 @@ static void lbs_scan_worker(struct work_struct *work)
>  		le16_to_cpu(scan_cmd->hdr.size),
>  		lbs_ret_scan, 0);
>  
> -	if (priv->scan_channel >= priv->scan_req->n_channels) {
> +	if (priv->scan_channel >= priv->scan_req->n_channels)
>  		/* Mark scan done */
> -		if (priv->internal_scan)
> -			kfree(priv->scan_req);
> -		else
> -			cfg80211_scan_done(priv->scan_req, false);
> -
> -		priv->scan_req = NULL;
> -	}
> +		lbs_scan_done(priv);
>  
>  	/* Restart network */
>  	if (carrier)
> @@ -774,6 +768,21 @@ static void _internal_start_scan(struct lbs_private *priv, bool internal,
>  	lbs_deb_leave(LBS_DEB_CFG80211);
>  }
>  
> +/*
> + * Clean up priv->scan_req.  Should be used to handle the allocation details.
> + */
> +void lbs_scan_done(struct lbs_private *priv)
> +{
> +	WARN_ON(!priv->scan_req);
> +
> +	if (priv->internal_scan)
> +		kfree(priv->scan_req);
> +	else
> +		cfg80211_scan_done(priv->scan_req, false);
> +
> +	priv->scan_req = NULL;
> +}
> +
>  static int lbs_cfg_scan(struct wiphy *wiphy,
>  	struct net_device *dev,
>  	struct cfg80211_scan_request *request)
> diff --git a/drivers/net/wireless/libertas/cfg.h b/drivers/net/wireless/libertas/cfg.h
> index a02ee15..558168c 100644
> --- a/drivers/net/wireless/libertas/cfg.h
> +++ b/drivers/net/wireless/libertas/cfg.h
> @@ -16,6 +16,7 @@ int lbs_reg_notifier(struct wiphy *wiphy,
>  void lbs_send_disconnect_notification(struct lbs_private *priv);
>  void lbs_send_mic_failureevent(struct lbs_private *priv, u32 event);
>  
> +void lbs_scan_done(struct lbs_private *priv);
>  void lbs_scan_deinit(struct lbs_private *priv);
>  int lbs_disconnect(struct lbs_private *priv, u16 reason);
>  
> diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
> index b03779b..39a6a7a 100644
> --- a/drivers/net/wireless/libertas/main.c
> +++ b/drivers/net/wireless/libertas/main.c
> @@ -255,10 +255,8 @@ static int lbs_eth_stop(struct net_device *dev)
>  
>  	lbs_update_mcast(priv);
>  	cancel_delayed_work_sync(&priv->scan_work);
> -	if (priv->scan_req) {
> -		cfg80211_scan_done(priv->scan_req, false);
> -		priv->scan_req = NULL;
> -	}
> +	if (priv->scan_req)
> +		lbs_scan_done(priv);
>  
>  	netif_carrier_off(priv->dev);
>  
