From: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] cfg80211: fix error path in cfg80211_wext_siwscan
Date: Wed, 23 Dec 2009 16:46:05 +0200
Message-ID: <20091223144605.GA23721@bicker>
References: <20091223132937.GG17923@bicker> <1261578815.7304.7.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1261578815.7304.7.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 23, 2009 at 03:33:35PM +0100, Johannes Berg wrote:
> If there's an invalid channel or SSID, the code leaks
> the scan request. Always free the scan request, unless
> it was successfully given to the driver.
> 
> Reported-by: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> ---
> I kinda prefer this, thoughts?
> 

Looks good.

Acked-by: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

regards,
dan carpenter

>  net/wireless/scan.c |   13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
> 
> --- wireless-testing.orig/net/wireless/scan.c	2009-12-23 15:27:20.000000000 +0100
> +++ wireless-testing/net/wireless/scan.c	2009-12-23 15:32:52.000000000 +0100
> @@ -601,7 +601,7 @@ int cfg80211_wext_siwscan(struct net_dev
>  	struct cfg80211_registered_device *rdev;
>  	struct wiphy *wiphy;
>  	struct iw_scan_req *wreq = NULL;
> -	struct cfg80211_scan_request *creq;
> +	struct cfg80211_scan_request *creq = NULL;
>  	int i, err, n_channels = 0;
>  	enum ieee80211_band band;
>  
> @@ -694,8 +694,10 @@ int cfg80211_wext_siwscan(struct net_dev
>  	/* translate "Scan for SSID" request */
>  	if (wreq) {
>  		if (wrqu->data.flags & IW_SCAN_THIS_ESSID) {
> -			if (wreq->essid_len > IEEE80211_MAX_SSID_LEN)
> -				return -EINVAL;
> +			if (wreq->essid_len > IEEE80211_MAX_SSID_LEN) {
> +				err = -EINVAL;
> +				goto out;
> +			}
>  			memcpy(creq->ssids[0].ssid, wreq->essid, wreq->essid_len);
>  			creq->ssids[0].ssid_len = wreq->essid_len;
>  		}
> @@ -707,12 +709,15 @@ int cfg80211_wext_siwscan(struct net_dev
>  	err = rdev->ops->scan(wiphy, dev, creq);
>  	if (err) {
>  		rdev->scan_req = NULL;
> -		kfree(creq);
> +		/* creq will be freed below */
>  	} else {
>  		nl80211_send_scan_start(rdev, dev);
> +		/* creq now owned by driver */
> +		creq = NULL;
>  		dev_hold(dev);
>  	}
>   out:
> +	kfree(creq);
>  	cfg80211_unlock_rdev(rdev);
>  	return err;
>  }
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
