From: Jeff Liu <jeff.liu@oracle.com>
Subject: Re: [patch] RDS: fix an integer overflow check
Date: Sat, 13 Oct 2012 21:25:40 +0800
Message-ID: <50796BD4.4000608@oracle.com>
References: <20121012073146.GA9543@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:45840 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753471Ab2JMNZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2012 09:25:58 -0400
In-Reply-To: <20121012073146.GA9543@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/2012 03:31 PM, Dan Carpenter wrote:
> "len" is an int.  We verified that len was postive already.  Since
> PAGE_SIZE is specified as an unsigned long, the type it promoted to
> unsigned and the condition is never true.
>
> I'm not sure this check is actually needed.  It might be that we could
> just remove it?
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/net/rds/info.c b/net/rds/info.c
> index 9a6b4f6..4d62618 100644
> --- a/net/rds/info.c
> +++ b/net/rds/info.c
> @@ -176,7 +176,7 @@ int rds_info_getsockopt(struct socket *sock, int optname, char __user *optval,
>   
>   	/* check for all kinds of wrapping and the like */
>   	start = (unsigned long)optval;
> -	if (len < 0 || len + PAGE_SIZE - 1 < len || start + len < start) {
Looks the original thought is to check up len + (PAGE_SIZE - 1) < len to 
avoid integer overflow, but lack of a "()".

However, we only have one add operation in this function which were 
shown as following:
         nr_pages = (PAGE_ALIGN(start + len) - (start & PAGE_MASK))
                         >> PAGE_SHIFT;

I also gone through the call chains, there is no other (start + len) 
operations for all transport, I think it's safe to remove this check up 
if so.

Thanks,
-Jeff
> +	if (len < 0 || len > INT_MAX - (PAGE_SIZE - 1) || start + len < start) {
>   		ret = -EINVAL;
>   		goto out;
>   	}
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
