From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 1/9] net: Remove martian_source_keep_err goto
 label
Date: Tue, 22 Sep 2015 18:04:07 -0700
Message-ID: <5601FA87.2080701@gmail.com>
References: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
 <1442962523-3974-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35164 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759787AbbIWBEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 21:04:09 -0400
Received: by pacfv12 with SMTP id fv12so24640659pac.2
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 18:04:08 -0700 (PDT)
In-Reply-To: <1442962523-3974-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2015 03:55 PM, David Ahern wrote:
> err is initialized to -EINVAL when it is declared. It is not reset until
> fib_lookup which is well after the 3 users of the martian_source jump. So
> resetting err to -EINVAL at martian_source label is not needed.
>
> Removing that line obviates the need for the martian_source_keep_err label
> so delete it.
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

The comments above and the code below don't sync up.  The function 
fib_validate_source can return either -EINVAL, -EXDEV, 0, or 1.  The 
fact is this may be acceptable as long as all callers of 
ip_route_input_slow will handle a non-zero value as an error and it 
doesn't care about what the actual return value is.  If that is what you 
are going for here at least the comment should be updated, and we should 
be explicit somewhere about documenting the return values.

> ---
>   net/ipv4/route.c | 6 ++----
>   1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 80f7c5b7b832..ef36dfed24da 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1760,7 +1760,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
>   		err = fib_validate_source(skb, saddr, daddr, tos,
>   					  0, dev, in_dev, &itag);
>   		if (err < 0)
> -			goto martian_source_keep_err;
> +			goto martian_source;
>   		goto local_input;
>   	}
>
> @@ -1782,7 +1782,7 @@ out:	return err;
>   		err = fib_validate_source(skb, saddr, 0, tos, 0, dev,
>   					  in_dev, &itag);
>   		if (err < 0)
> -			goto martian_source_keep_err;
> +			goto martian_source;
>   	}
>   	flags |= RTCF_BROADCAST;
>   	res.type = RTN_BROADCAST;
> @@ -1858,8 +1858,6 @@ out:	return err;
>   	goto out;
>
>   martian_source:
> -	err = -EINVAL;
> -martian_source_keep_err:
>   	ip_handle_martian_source(dev, in_dev, skb, daddr, saddr);
>   	goto out;
>   }
>
