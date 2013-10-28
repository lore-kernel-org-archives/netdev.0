From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH net V2] xen-netback: use jiffies_64 value to
 calculate credit timeout
Date: Mon, 28 Oct 2013 11:49:55 +0000
Message-ID: <526E5D7302000078000FD41A@nat28.tlf.novell.com>
References: <1382960117-13053-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <david.vrabel@citrix.com>,
	"Ian Campbell" <ian.campbell@citrix.com>,
	"xen-devel" <xen-devel@lists.xenproject.org>,
	<annie.li@oracle.com>, "Jason Luan" <jianhai.luan@oracle.com>,
	<netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:39048 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756051Ab3J1LuA convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Mon, 28 Oct 2013 07:50:00 -0400
In-Reply-To: <1382960117-13053-1-git-send-email-wei.liu2@citrix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 28.10.13 at 12:35, Wei Liu <wei.liu2@citrix.com> wrote:

Two formal things:

> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1185,18 +1185,17 @@ out:
>  
>  static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
>  {
> -	unsigned long now = jiffies;
> -	unsigned long next_credit =
> -		vif->credit_timeout.expires +
> -		msecs_to_jiffies(vif->credit_usec / 1000);
> +	u64 now = get_jiffies_64();
> +	u64 next_credit = vif->credit_window_start +
> +		(u64)msecs_to_jiffies(vif->credit_usec / 1000);

The cast to u64 seems pointless here.

> @@ -1207,7 +1206,8 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
>  		vif->credit_timeout.function =
>  			tx_credit_callback;
>  		mod_timer(&vif->credit_timeout,
> -			  next_credit);
> +			  (unsigned long)next_credit);

And the cast here seems pointless too (gcc doesn't warn about
truncations).

Jan
