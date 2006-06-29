From: Per Liden <per.liden@ericsson.com>
Subject: Re: [PATCH 1/3] [TIPC] Fixed skb_under_panic caused by tipc_link_bundle_buf
Date: Thu, 29 Jun 2006 17:17:20 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0606291703270.1695@ulinpc219.uab.ericsson.se>
References: <Pine.LNX.4.64.0606281358100.6341@ulinpc219.uab.ericsson.se>
 <11514964722073-git-send-email-per.liden@ericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:44490 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1750785AbWF2PRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 11:17:25 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <11514964722073-git-send-email-per.liden@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A problem was found with this patch. The direct inspection of bundle 
buffer tailroom did not account for the possiblity of unrequested tailroom 
added by skb_alloc(), thereby allowing a bundle to be created that exceeds 
the current link MTU.

I'll resend this patch set with this issue resolved.

/Per

On Wed, 28 Jun 2006, Per Liden wrote:

> From: Allan Stephens <allan.stephens@windriver.com>
> 
> Now determines tailroom of bundle buffer by directly inspection of buffer.
> Previously, buffer was assumed to have a max capacity equal to the link MTU,
> but the addition of link MTU negotiation means that the link MTU can increase
> after the bundle buffer is allocated.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Per Liden <per.liden@ericsson.com>
> ---
>  net/tipc/link.c |   11 ++++++-----
>  1 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/net/tipc/link.c b/net/tipc/link.c
> index d646580..c6831c7 100644
> --- a/net/tipc/link.c
> +++ b/net/tipc/link.c
> @@ -2,7 +2,7 @@
>   * net/tipc/link.c: TIPC link code
>   * 
>   * Copyright (c) 1996-2006, Ericsson AB
> - * Copyright (c) 2004-2005, Wind River Systems
> + * Copyright (c) 2004-2006, Wind River Systems
>   * All rights reserved.
>   *
>   * Redistribution and use in source and binary forms, with or without
> @@ -988,17 +988,18 @@ static int link_bundle_buf(struct link *
>  	struct tipc_msg *bundler_msg = buf_msg(bundler);
>  	struct tipc_msg *msg = buf_msg(buf);
>  	u32 size = msg_size(msg);
> -	u32 to_pos = align(msg_size(bundler_msg));
> -	u32 rest = link_max_pkt(l_ptr) - to_pos;
> +	u32 bundle_size = msg_size(bundler_msg);
> +	u32 to_pos = align(bundle_size);
> +	u32 pad = to_pos - bundle_size;
>  
>  	if (msg_user(bundler_msg) != MSG_BUNDLER)
>  		return 0;
>  	if (msg_type(bundler_msg) != OPEN_MSG)
>  		return 0;
> -	if (rest < align(size))
> +	if (skb_tailroom(bundler) < (pad + size))
>  		return 0;
>  
> -	skb_put(bundler, (to_pos - msg_size(bundler_msg)) + size);
> +	skb_put(bundler, pad + size);
>  	memcpy(bundler->data + to_pos, buf->data, size);
>  	msg_set_size(bundler_msg, to_pos + size);
>  	msg_set_msgcnt(bundler_msg, msg_msgcnt(bundler_msg) + 1);
> -- 
> 1.4.0
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
