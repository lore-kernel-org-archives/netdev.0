From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 2.6] WE : Fix get 32 char ESSID
Date: Tue, 10 Jul 2007 11:10:44 -0400
Message-ID: <20070710151044.GC7927@tuxdriver.com>
References: <20070709221322.GA1381@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070709221322.GA1381-yAE0UhLNZJawPNPzzlOzwdBPR1lH4CV8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 09, 2007 at 03:13:22PM -0700, Jean Tourrilhes wrote:

> 	A little bug was introduced a few months ago that prevent
> reading ESSID with 32 character. Philippe Teuwen was the first one to
> report that, followed by the MadWifi team :
> 		http://madwifi.org/ticket/930
> 	The patch fix this bug by removing obsolete code. It also
> reenable setting the full range of ESSID, including ESSID with a final
> NUL which are valid. This was tested on 2.6.21 and 2.6.22.
> 	John : would you mind pushing that to 2.6.23 ? If you are
> happy with it, I can provide backport patches for earlier kernels.

Jean,

Thanks for the patch.

Iirc, I wrote this ugly little piece of code that you seek to remove.
It's purpose is/was to preserve userland ABI for older versions of
the wireless-tools package.  I'll have to dig a little deeper if you
need a more detailed refresher -- let me know.

In that case, I believe the issue was that using older wireless-tools
w/ newer kernels would result in the SSID getting truncated by one
character.  If we apply this patch (removing my hack/fix), won't we
be reintroducing that issue?  If not, can you remind me as to why not?

Thanks,

John

> 
> Signed-off-by: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
> 
> -----------------------------------------------------------
> 
> --- linux/net/wireless/wext.j1.c	2007-07-09 13:19:22.000000000 -0700
> +++ linux/net/wireless/wext.c	2007-07-09 13:19:59.000000000 -0700
> @@ -741,39 +741,11 @@ static int ioctl_standard_call(struct ne
>  		int	extra_size;
>  		int	user_length = 0;
>  		int	err;
> -		int	essid_compat = 0;
>  
>  		/* Calculate space needed by arguments. Always allocate
>  		 * for max space. Easier, and won't last long... */
>  		extra_size = descr->max_tokens * descr->token_size;
>  
> -		/* Check need for ESSID compatibility for WE < 21 */
> -		switch (cmd) {
> -		case SIOCSIWESSID:
> -		case SIOCGIWESSID:
> -		case SIOCSIWNICKN:
> -		case SIOCGIWNICKN:
> -			if (iwr->u.data.length == descr->max_tokens + 1)
> -				essid_compat = 1;
> -			else if (IW_IS_SET(cmd) && (iwr->u.data.length != 0)) {
> -				char essid[IW_ESSID_MAX_SIZE + 1];
> -
> -				err = copy_from_user(essid, iwr->u.data.pointer,
> -						     iwr->u.data.length *
> -						     descr->token_size);
> -				if (err)
> -					return -EFAULT;
> -
> -				if (essid[iwr->u.data.length - 1] == '\0')
> -					essid_compat = 1;
> -			}
> -			break;
> -		default:
> -			break;
> -		}
> -
> -		iwr->u.data.length -= essid_compat;
> -
>  		/* Check what user space is giving us */
>  		if (IW_IS_SET(cmd)) {
>  			/* Check NULL pointer */
> @@ -811,7 +783,6 @@ static int ioctl_standard_call(struct ne
>  		}
>  
>  		/* Create the kernel buffer */
> -		/*    kzalloc ensures NULL-termination for essid_compat */
>  		extra = kzalloc(extra_size, GFP_KERNEL);
>  		if (extra == NULL)
>  			return -ENOMEM;
> @@ -830,8 +801,6 @@ static int ioctl_standard_call(struct ne
>  		/* Call the handler */
>  		ret = handler(dev, &info, &(iwr->u), extra);
>  
> -		iwr->u.data.length += essid_compat;
> -
>  		/* If we have something to return to the user */
>  		if (!ret && IW_IS_GET(cmd)) {
>  			/* Check if there is enough buffer up there */
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
