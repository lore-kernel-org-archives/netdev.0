From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [Bug 24472] Kernel panic - not syncing: Fatal Exception
Date: Fri, 10 Dec 2010 16:55:10 +0100
Message-ID: <20101210155510.GA1856@del.dom.local>
References: <20101210091505.GA7868@ff.dom.local>
 <4D023DE4.8000400@ota.si>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pstaszewski@artcom.pl,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: Andrej Ota <andrej@ota.si>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39762 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756061Ab0LJPzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 10:55:17 -0500
Received: by wwa36 with SMTP id 36so3858412wwa.1
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 07:55:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4D023DE4.8000400@ota.si>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 10, 2010 at 03:49:08PM +0100, Andrej Ota wrote:
> Move kfree_skb which was causing memory corruption to new location, while still keeping appropriate return value for function __pppoe_xmit. Prevents memory corruption and consequent kernel panic when PPPoE peer terminates the link.

Andrej, a slight misunderstanding - probably I should be more explicit.
I sent this link, which explains why return shouldn't be zero:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=db7bf6d97c6956b7eb0f22131cb5c37bd41f33c0
So the simplest fix is to revert this one change only.
If you disagree with this let me know.

You should also fix the subject to something more meaningful, e.g.:
[PATCH] pppoe: Fix kernel panic caused by __pppoe_xmit

Please, break lines in the changelog around 70 lines and add it
fixes commit 55c95e738da85373965cb03b4f975d0fd559865b.

Thanks,
Jarek P.

> 
> Signed-off-by: Andrej Ota [andrej@ota.si]
> Reported-by: Pawel Staszewski [pstaszewski@artcom.pl]
> ---
>  drivers/net/pppoe.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
> index d72fb05..1a21dce 100644
> --- a/drivers/net/pppoe.c
> +++ b/drivers/net/pppoe.c
> @@ -924,8 +924,10 @@ static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
>  	/* Copy the data if there is no space for the header or if it's
>  	 * read-only.
>  	 */
> -	if (skb_cow_head(skb, sizeof(*ph) + dev->hard_header_len))
> +	if (skb_cow_head(skb, sizeof(*ph) + dev->hard_header_len)) {
> +		kfree_skb(skb);
>  		goto abort;
> +	}
> 
>  	__skb_push(skb, sizeof(*ph));
>  	skb_reset_network_header(skb);
> @@ -947,7 +949,6 @@ static int __pppoe_xmit(struct sock *sk, struct sk_buff *skb)
>  	return 1;
> 
>  abort:
> -	kfree_skb(skb);
>  	return 0;
>  }
> 
> ---
> 
> Andrej Ota.
