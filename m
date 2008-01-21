From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Subject: Re: : Emit event stream compat iw_point objects correctly.
Date: Mon, 21 Jan 2008 20:23:15 +0900
Message-ID: <20080121194942.613C.40F06B3A@sm.sony.co.jp>
References: <20071227181439.6F59.40F06B3A@sm.sony.co.jp> <20080110.011602.74511551.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080110.011602.74511551.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

	Hi

Sorry for my intermittent posts.

On Thu, 10 Jan 2008 01:16:02 -0800 (PST)
David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:

> From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
> Date: Thu, 27 Dec 2007 18:24:40 +0900
> 
> > On ppc64 (PS3), IW_EV_LCP_LEN is 8, not 4.
> > 
> > include/linux/wireless.h:
> > 
> > #define IW_EV_LCP_LEN   (sizeof(struct iw_event) - sizeof(union iwreq_data))
> > 
> > where sizeof(struct iw_event) == 24, sizeof(union iwreq_data) == 16 on
> > PS3.
> 
> Here is a new version of the last patch (#12), it should handle
> all of these cases properly now.
> 
> Let me know if you spot any more errors.
> 
> Thanks!
> 
> [WEXT]: Emit event stream entries correctly when compat.
> 
> Three major portions to this change:
> 
> 1) Add IW_EV_COMPAT_LCP_LEN, IW_EV_COMPAT_POINT_OFF,
>    and IW_EV_COMPAT_POINT_LEN helper defines.
> 
> 2) Delete iw_stream_check_add_*(), they are unused.
> 
> 3) Add iw_request_info argument to iwe_stream_add_*(), and use it to
>    size the event and pointer lengths correctly depending upon whether
>    IW_REQUEST_FLAG_COMPAT is set or not.
> 
> 4) The mechanical transformations to the drivers and wireless stack
>    bits to get the iw_request_info passed down into the routines
>    modified in #3.
> 
> With help from Masakazu Mokuno
> 
> Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> ---
>  drivers/net/wireless/airo.c                |   39 +++++---
>  drivers/net/wireless/atmel.c               |   24 ++++-
>  drivers/net/wireless/hostap/hostap.h       |    3 +-
>  drivers/net/wireless/hostap/hostap_ap.c    |   32 +++---
>  drivers/net/wireless/hostap/hostap_ioctl.c |   54 ++++++-----
>  drivers/net/wireless/libertas/scan.c       |   35 ++++---
>  drivers/net/wireless/orinoco.c             |   30 ++++--
>  drivers/net/wireless/prism54/isl_ioctl.c   |   45 +++++----
>  drivers/net/wireless/wl3501_cs.c           |   10 +-
>  drivers/net/wireless/zd1201.c              |   21 +++--
>  include/linux/wireless.h                   |   16 +++
>  include/net/iw_handler.h                   |  150 ++++++++--------------------
>  net/ieee80211/ieee80211_wx.c               |   44 +++++----
>  net/mac80211/ieee80211_i.h                 |    5 +-
>  net/mac80211/ieee80211_ioctl.c             |    2 +-
>  net/mac80211/ieee80211_sta.c               |   59 ++++++-----
>  16 files changed, 293 insertions(+), 276 deletions(-)

<snip>

> diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
> index 6d80ca4..4dc0b5e 100644
> --- a/drivers/net/wireless/prism54/isl_ioctl.c
> +++ b/drivers/net/wireless/prism54/isl_ioctl.c
> @@ -572,8 +572,9 @@ prism54_set_scan(struct net_device *dev, struct iw_request_info *info,
>   */
>  
>  static char *
> -prism54_translate_bss(struct net_device *ndev, char *current_ev,
> -		      char *end_buf, struct obj_bss *bss, char noise)
> +prism54_translate_bss(struct net_device *ndev, struct iw_request_info *info,
> +		      char *current_ev, char *end_buf, struct obj_bss *bss,
> +		      char noise)
>  {
>  	struct iw_event iwe;	/* Temporary buffer */
>  	short cap;

<snip>

> @@ -2728,9 +2730,12 @@ prism2_ioctl_scan_req(struct net_device *ndev,
>  	rvalue |= mgt_get_request(priv, DOT11_OID_BSSLIST, 0, NULL, &r);
>  	bsslist = r.ptr;
>  
> +	info.cmd = PRISM54_HOSTAPD;
> +	info.flags = 0;
> +
>  	/* ok now, scan the list and translate its info */
>  	for (i = 0; i < min(IW_MAX_AP, (int) bsslist->nr); i++)
> -		current_ev = prism54_translate_bss(ndev, current_ev,
> +		current_ev = prism54_translate_bss(ndev, current_ev, &info,

The order of the arguments is wrong.

current_ev = prism54_translate_bss(ndev, &info, current_ev,

>  						   extra + IW_SCAN_MAX_DATA,
>  						   &(bsslist->bsslist[i]),
>  						   noise);

-- 
Masakazu MOKUNO
