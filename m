From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH-2.6.26] rndis_host: fix oops when query for OID_GEN_PHYSICAL_MEDIUM fails
Date: Mon, 17 Mar 2008 13:42:11 -0800
Message-ID: <200803171442.11529.david-b@pacbell.net>
References: <20080317213301.15070.30388.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dmonakhov@openvz.org, netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp108.sbc.mail.mud.yahoo.com ([68.142.198.207]:22536 "HELO
	smtp108.sbc.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752835AbYCQVm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 17:42:26 -0400
In-Reply-To: <20080317213301.15070.30388.stgit@fate.lan>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 17 March 2008, Jussi Kivilinna wrote:
> From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> 
> When query for OID_GEN_PHYSICAL_MEDIUM fails, uninitialized pointer
> 'phym' is being accessed in generic_rndis_bind(), resulting OOPS.
> Patch fixes phym to be initialized and setup correctly when
> rndis_query() for physical medium fails.
> 
> Bug was introduced by following commit:
> commit 039ee17d1baabaa21783a0d5ab3e8c6d8c794bdf
> Author: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> Date:   Sun Jan 27 23:34:33 2008 +0200
> 
> Reported-by: Dmitri Monakhov <dmonakhov@openvz.org>
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Acked-by: David Brownell <dbrownell@users.sourceforge.net>

... this should be for 2.6.25 though, yes?  Since that
change was introduced after 2.6.24, and this would
otherwise cause a regression ...


> ---
> 
>  drivers/net/usb/rndis_host.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
> index a613247..1b810ab 100644
> --- a/drivers/net/usb/rndis_host.c
> +++ b/drivers/net/usb/rndis_host.c
> @@ -287,7 +287,7 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
>  		struct rndis_set_c	*set_c;
>  		struct rndis_halt	*halt;
>  	} u;
> -	u32			tmp, *phym;
> +	u32			tmp, phym_unspec, *phym;
>  	int			reply_len;
>  	unsigned char		*bp;
>  
> @@ -359,12 +359,15 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
>  		goto halt_fail_and_release;
>  
>  	/* Check physical medium */
> +	phym = NULL;
>  	reply_len = sizeof *phym;
>  	retval = rndis_query(dev, intf, u.buf, OID_GEN_PHYSICAL_MEDIUM,
>  			0, (void **) &phym, &reply_len);
> -	if (retval != 0)
> +	if (retval != 0 || !phym) {
>  		/* OID is optional so don't fail here. */
> -		*phym = RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED;
> +		phym_unspec = RNDIS_PHYSICAL_MEDIUM_UNSPECIFIED;
> +		phym = &phym_unspec;
> +	}
>  	if ((flags & FLAG_RNDIS_PHYM_WIRELESS) &&
>  			*phym != RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN) {
>  		if (netif_msg_probe(dev))
> 


