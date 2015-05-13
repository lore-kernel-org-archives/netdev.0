From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] neigh: fix a possible leak issue of neigh entry
Date: Tue, 12 May 2015 23:20:48 -0700
Message-ID: <1431498048.566.131.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431495814-22759-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:34680 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753812AbbEMGUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 02:20:50 -0400
Received: by iecmd7 with SMTP id md7so23089005iec.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 23:20:49 -0700 (PDT)
In-Reply-To: <1431495814-22759-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-13 at 13:43 +0800, Ying Xue wrote:
> Once modifying a pending timer of a neighbour, it's insufficient to
> post a warning message. Instead we should not take the neighbour's
> reference count at the same time, otherwise, it causes an issue that
> the neighbour cannot be freed forever.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> ---
>  net/core/neighbour.c |    9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 3de6542..5595db3 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -164,10 +164,11 @@ static int neigh_forced_gc(struct neigh_table *tbl)
>  
>  static void neigh_add_timer(struct neighbour *n, unsigned long when)
>  {
> -	neigh_hold(n);
> -	if (unlikely(mod_timer(&n->timer, when))) {
> -		printk("NEIGH: BUG, double timer add, state is %x\n",
> -		       n->nud_state);
> +	if (likely(!mod_timer(&n->timer, when))) {
> +		neigh_hold(n);
> +	} else {
> +		pr_warn("NEIGH: BUG, double timer add, state is %x\n",
> +			n->nud_state);
>  		dump_stack();
>  	}
>  }

Have you hit this condition ?

If yes, there is a bug elsewhere and we need to fix it, not trying to
recover.
