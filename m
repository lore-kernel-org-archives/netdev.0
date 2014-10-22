From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: log: protect nf_log_register against double
 registering
Date: Wed, 22 Oct 2014 14:02:55 +0200
Message-ID: <20141022120255.GA21821@salvia>
References: <c7fcb46fa24c1a64f00c9322bb5cddbde977da0a.1413842217.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60491 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933003AbaJVMB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2014 08:01:26 -0400
Content-Disposition: inline
In-Reply-To: <c7fcb46fa24c1a64f00c9322bb5cddbde977da0a.1413842217.git.mleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 20, 2014 at 07:58:03PM -0200, Marcelo Ricardo Leitner wrote:
> Currently, despite the comment right before the function,
> nf_log_register allows registering two loggers on with the same type and
> end up overwriting the previous register.
> 
> Not a real issue today as current tree doesn't have two loggers for the
> same type but it's better to get this protected.
> 
> Also make sure that all of its callers do error checking.

No major objetions to this sanity check. Some comment below.

> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> ---
> 
> Notes:
>     Please let me know if you have any issues with the identation on
>     nf_log_register. I just couldn't find a better one.

You can split nf_log_register() in two functions to avoid this.

>     Thanks
> 
>  net/ipv4/netfilter/nf_log_arp.c  |  8 +++++++-
>  net/ipv4/netfilter/nf_log_ipv4.c |  8 +++++++-
>  net/ipv6/netfilter/nf_log_ipv6.c |  8 +++++++-
>  net/netfilter/nf_log.c           | 13 ++++++++++++-
>  4 files changed, 33 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv4/netfilter/nf_log_arp.c b/net/ipv4/netfilter/nf_log_arp.c
> index ccfc78db12ee8acae68faf451f2cf6bc5597f2c1..8b39174b7be390397a110ec9d3ed497bf8ce6d26 100644
> --- a/net/ipv4/netfilter/nf_log_arp.c
> +++ b/net/ipv4/netfilter/nf_log_arp.c
> @@ -130,7 +130,13 @@ static int __init nf_log_arp_init(void)
>  	if (ret < 0)
>  		return ret;
>  
> -	nf_log_register(NFPROTO_ARP, &nf_arp_logger);
> +	ret = nf_log_register(NFPROTO_ARP, &nf_arp_logger);
> +	if (ret < 0) {
> +		pr_err("log: failed to register logger\n");

I think you can use pr_fmt to avoid appending log, it's also going to
append useful information to know which logger has indeed failed.

> +		unregister_pernet_subsys(&nf_log_arp_net_ops);
> +		return ret;

Could you add a goto err1; instead? Just in case we need to extend
this again later on, we'll skip some refactoring.

Thanks.
