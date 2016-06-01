From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: fix possible ZERO_SIZE_PTR pointer
 dereferencing error.
Date: Wed, 1 Jun 2016 11:27:11 +0200
Message-ID: <20160601092711.GB2711@salvia>
References: <1464770068-7508-1-git-send-email-lixiubo@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: Xiubo Li <lixiubo@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49028 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757404AbcFAJ1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2016 05:27:18 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id CA2F65B2CC5
	for <netdev@vger.kernel.org>; Wed,  1 Jun 2016 11:27:16 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id BA3E49EBBD
	for <netdev@vger.kernel.org>; Wed,  1 Jun 2016 11:27:16 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id E80F99EBA0
	for <netdev@vger.kernel.org>; Wed,  1 Jun 2016 11:27:13 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1464770068-7508-1-git-send-email-lixiubo@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 01, 2016 at 04:34:28PM +0800, Xiubo Li wrote:
> Since we cannot make sure the 'hook_mask' will always be none zero
> here. If it equals to zero, the num_hooks will be zero too, and then
> kmalloc() will return ZERO_SIZE_PTR, which is (void *)16.
> 
> Then the following error check will fails:
>   ops = kmalloc(sizeof(*ops) * num_hooks, GFP_KERNEL);
>   if (ops == NULL)
>           return ERR_PTR(-ENOMEM);
> 
> So this patch fix this with just doing the zero check before calling
> kmalloc() is called.
> 
> Maybe the case above will never happen here, but in theory.
> 
> Signed-off-by: Xiubo Li <lixiubo@cmss.chinamobile.com>
> ---
>  net/netfilter/x_tables.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index c8a0b7d..4df8e38 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -1185,6 +1185,9 @@ struct nf_hook_ops *xt_hook_link(const struct xt_table *table, nf_hookfn *fn)

What kernel version are you using? I don't see xt_hook_link() in the
development tree.

>  	struct nf_hook_ops *ops;
>  	int ret;
>  
> +	if (!num_hooks)
> +		return ERR_PTR(-EINVAL);
> +
>  	ops = kmalloc(sizeof(*ops) * num_hooks, GFP_KERNEL);
>  	if (ops == NULL)
>  		return ERR_PTR(-ENOMEM);
> -- 
> 1.8.3.1
> 
> 
> 
