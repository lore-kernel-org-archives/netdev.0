From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v2 5/6] gtp: add socket to pdp context
Date: Thu, 2 Feb 2017 14:56:56 +0100
Message-ID: <20170202135656.GA23901@salvia>
References: <20170130163713.17524-1-aschultz@tpip.net>
 <20170130163713.17524-6-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:50156 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751569AbdBBN5G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 08:57:06 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 7D1F81DF5B9
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 14:56:59 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6FCDFDA841
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 14:56:59 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3F70CDA84B
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 14:56:57 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170130163713.17524-6-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 05:37:12PM +0100, Andreas Schultz wrote:
> Having the socket present in context simplifies the sending logic.
> It also fixes the invalid assumption that we have to use the same
> sending socket for all client IP's on a specific gtp interface.
> 
> Signed-off-by: Andreas Schultz <aschultz@tpip.net>
> ---
>  drivers/net/gtp.c | 72 ++++++++++++++++++++++++++++++-------------------------
>  1 file changed, 39 insertions(+), 33 deletions(-)
> 
> diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
> index 68c6c9b..ff00597 100644
> --- a/drivers/net/gtp.c
> +++ b/drivers/net/gtp.c
[...]
> @@ -984,16 +966,26 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct genl_info *info)
>  	return 0;
>  }
>  
> +static void pdp_context_free(struct rcu_head *head)
> +{
> +	struct pdp_ctx *pctx = container_of(head, struct pdp_ctx, rcu_head);
> +
> +	sock_put(pctx->sk);
> +	kfree(pctx);
> +}
> +
>  static void pdp_context_delete(struct pdp_ctx *pctx)
>  {
>  	hlist_del_rcu(&pctx->hlist_tid);
>  	hlist_del_rcu(&pctx->hlist_addr);
> -	kfree(pctx);
> +	call_rcu(&pctx->rcu_head, pdp_context_free);

This is fixing incorrect rcu conversion in 4/6. Please, fix this there.
