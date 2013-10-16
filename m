From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] DomU's network interface will hung when Dom0 running
 32bit
Date: Wed, 16 Oct 2013 16:17:32 +0100
Message-ID: <20131016151732.GJ16371@zion.uk.xensource.com>
References: <1381826609.24708.135.camel@kazak.uk.xensource.com>
 <525D0C41.2080407@oracle.com>
 <20131015100624.GB29436@zion.uk.xensource.com>
 <525D2667.6040102@oracle.com>
 <20131015125802.GR11739@zion.uk.xensource.com>
 <525E41CF.7090008@oracle.com>
 <525E5EDF.4030904@oracle.com>
 <525E8FB3.8000606@oracle.com>
 <20131016134740.GG16371@zion.uk.xensource.com>
 <525EAB02.9050207@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, annie li <annie.li@oracle.com>,
	<xen-devel@lists.xenproject.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	<netdev@vger.kernel.org>
To: jianhai luan <jianhai.luan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:19907 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752418Ab3JPPRn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 11:17:43 -0400
Content-Disposition: inline
In-Reply-To: <525EAB02.9050207@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 16, 2013 at 11:04:34PM +0800, jianhai luan wrote:
[...]
> >From ef02403a10173896c5c102f768741d0700b8a3a2 Mon Sep 17 00:00:00 2001
> From: Jason Luan <jianhai.luan@oracle.com>
> Date: Tue, 15 Oct 2013 17:07:49 +0800
> Subject: [PATCH] xen-netback: pending timer only in the range [expire,
>  next_credit)
> 
> The function time_after_eq() do correct judge in range of MAX_UNLONG/2.
> If net-front send lesser package, the delta between now and next_credit
> will out of the range and time_after_eq() will do wrong judge in result
> to net-front hung.  For example:
>     expire    next_credit    ....    next_credit+MAX_UNLONG/2    now
>     -----------------time increases this direction----------------->
> 
> We should be add the environment which now beyond next_credit+MAX_UNLONG/2.
> Because the fact now mustn't before expire, time_before(now, expire) == true
> will show the environment.
>     time_after_eq(now, next_credit) || time_before (now, expire)
>     ==
>     !time_in_range_open(now, expire, next_credit)
> 

OK, you say !time_in_range_open here but the code below has
!time_in_range. I suppose it is a typo?

Your patch should go against "net" tree so you need to have
"[PATCH net]" as prefix.

Also don't send your patch as attachment, send it inline. You can use
git format-patch, git send-email to do this.

Could you please fix the above issues and resend the patch to netdev,
with Ian and me CC'ed.

You can find out how netdev works in
Documentation/networking/netdev-FAQ.txt.

Last but not least, thanks for your contribution!

Wei.

> Signed-off-by: Jason Luan <jianhai.luan@oracle.com>
> ---
>  drivers/net/xen-netback/netback.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index f3e591c..62492f0 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1195,7 +1195,7 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
>  		return true;
>  
>  	/* Passed the point where we can replenish credit? */
> -	if (time_after_eq(now, next_credit)) {
> +	if (!time_in_range(now, vif->credit_timeout.expires, next_credit)) {
>  		vif->credit_timeout.expires = now;
>  		tx_add_credit(vif);
>  	}
> -- 
> 1.7.6.5
> 
