From: Paul Mackerras <paulus@samba.org>
Subject: Re: [patch 10/15] ppp_generic: fix lockdep warning
Date: Thu, 26 Apr 2007 20:04:36 +1000
Message-ID: <17968.31028.923114.471858@cargo.ozlabs.ibm.com>
References: <200704260727.l3Q7RTxG023970@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jarkao2@o2.pl,
	jura@netams.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:57470 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754536AbXDZKHI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 06:07:08 -0400
In-Reply-To: <200704260727.l3Q7RTxG023970@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org writes:

> lockdep has seen locks "-> #0" - "-> #3" taken in circular order, but IMHO,
> lock "-> #3" (&pch->downl) taken after "-> #2" (&ppp->wlock) differs from
> &pch->downl lock taken in "-> #0" (before &vlan_netdev_xmit_lock_key) and
> lockdep should be notified about this.
> 
> Reported & tested by: "Yuriy N. Shkandybin" <jura@netams.com>
> Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> Cc: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/ppp_generic.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff -puN drivers/net/ppp_generic.c~ppp_generic-fix-lockdep-warning drivers/net/ppp_generic.c
> --- a/drivers/net/ppp_generic.c~ppp_generic-fix-lockdep-warning
> +++ a/drivers/net/ppp_generic.c
> @@ -1433,7 +1433,8 @@ ppp_channel_push(struct channel *pch)
>  	struct sk_buff *skb;
>  	struct ppp *ppp;
>  
> -	spin_lock_bh(&pch->downl);
> +	local_bh_disable();
> +	spin_lock_nested(&pch->downl, SINGLE_DEPTH_NESTING);

This looks like a band-aid to me.  I don't feel that I understand
exactly how the recursive locking situation arose, or why saying
"SINGLE_DEPTH_NESTING" (whatever that means exactly) is a suitable
fix.

Paul.
