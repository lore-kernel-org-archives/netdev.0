From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch 1/2] af_iucv: recvmsg: use correct skb_pull() function
Date: Tue, 02 Apr 2013 08:37:19 -0700
Message-ID: <1364917039.5113.170.camel@edumazet-glaptop>
References: <20130402105650.056630101@de.ibm.com>
	 <20130402105707.116460653@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:65404 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932377Ab3DBPhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 11:37:25 -0400
In-Reply-To: <20130402105707.116460653@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-02 at 12:56 +0200, frank.blaschka@de.ibm.com wrote:
> plain text document attachment (601-af-iucv-skb-pull.diff)
> From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
> 
> When receiving data messages, the "BUG_ON(skb->len < skb->data_len)" in
> the skb_pull() function triggers a kernel panic.
> 
> Check if the skb uses paged data (is non-linear) and use the pskb_pull()
> function.  Use skb_pull() for linear skbs' only.
> 
> Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
> Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
> Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
> ---
>  net/iucv/af_iucv.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> --- a/net/iucv/af_iucv.c
> +++ b/net/iucv/af_iucv.c
> @@ -1382,7 +1382,10 @@ static int iucv_sock_recvmsg(struct kioc
>  
>  		/* SOCK_STREAM: re-queue skb if it contains unreceived data */
>  		if (sk->sk_type == SOCK_STREAM) {
> -			skb_pull(skb, copied);
> +			if (skb_is_nonlinear(skb))
> +				pskb_pull(skb, copied);
> +			else
> +				skb_pull(skb, copied);
>  			if (skb->len) {
>  				skb_queue_head(&sk->sk_receive_queue, skb);
>  				goto done;

That cant be right. You can not ignore pskb_pull() return value.

Its also not very efficient.

I would advise using a per skb offset, to avoid skb_pull()
