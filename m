From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/6] neigh: fix a possible leak issue of neigh
 entry
Date: Fri, 15 May 2015 05:12:42 -0700
Message-ID: <1431691962.27831.90.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
	 <1431672946-300-3-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei@purestorage.com,
	joern@purestorage.com, ja@ssi.bg, davem@davemloft.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:35898 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934130AbbEOMMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 08:12:44 -0400
Received: by igbpi8 with SMTP id pi8so215920066igb.1
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 05:12:44 -0700 (PDT)
In-Reply-To: <1431672946-300-3-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-15 at 14:55 +0800, Ying Xue wrote:
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


NACK
