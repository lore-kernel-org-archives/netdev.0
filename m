From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: [PATCH] devlink: fix potential memort leak
Date: Sun, 4 Jun 2017 16:07:43 +0300
Message-ID: <1c80b8da-3f00-48de-f89b-75cf18eebf5d@mellanox.com>
References: <1496580592-13659-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0059.outbound.protection.outlook.com ([104.47.2.59]:20540
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751182AbdFDNIH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Jun 2017 09:08:07 -0400
In-Reply-To: <1496580592-13659-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/04/2017 03:49 PM, Haishuang Yan wrote:
> We must free allocated skb when genlmsg_put() return fails.
> 
> Fixes: 1555d204e743 ("devlink: Support for pipeline debug (dpipe)")
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> ---
>  net/core/devlink.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/devlink.c b/net/core/devlink.c
> index b0b87a2..70b69c6 100644
> --- a/net/core/devlink.c
> +++ b/net/core/devlink.c
> @@ -1680,8 +1680,10 @@ static int devlink_dpipe_tables_fill(struct genl_info *info,
>  
>  	hdr = genlmsg_put(skb, info->snd_portid, info->snd_seq,
>  			  &devlink_nl_family, NLM_F_MULTI, cmd);
> -	if (!hdr)
> +	if (!hdr) {
> +		nlmsg_free(skb);
>  		return -EMSGSIZE;
> +	}
>  
>  	if (devlink_nl_put_handle(skb, devlink))
>  		goto nla_put_failure;
> 

Thanks! I think it a bit better to set the err and goto
down the error path below (only nlmsg_free()). Headrs_fill()
also suffers from this problem.
