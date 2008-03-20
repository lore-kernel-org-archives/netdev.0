From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] SCTP: Fix sctp_auth_asoc_get_hmac() to avoid kernel panic
Date: Thu, 20 Mar 2008 08:20:12 -0400
Message-ID: <47E2567C.7080105@hp.com>
References: <47E1FBE0.6030209@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:13498 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752833AbYCTMUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 08:20:15 -0400
In-Reply-To: <47E1FBE0.6030209@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wei

Wei Yongjun wrote:
> If association is setup with HMAC-ALGO parameter in which there is no 
> HMAC algorithm supported by the endpoint, send a chunk with AUTH will 
> cause kernel panic.
> 
> This is because  when send chunk with AUTH, sctp_auth_asoc_get_hmac() 
> will be used to get the hmac. In this function, if the HMAC-ALGO is 
> empty, it return NULL. If is not empty, it will find a valid hmac for 
> using. But if all of the HMAC-ALGOs is not supported by endpoint, it 
> will return a bogus pointer, not expected NULL pointer.

This is a workaround, but this problem must never never happen.
RFC 4890 has the following text:

   The HMAC algorithm based on SHA-1 MUST be supported and
   included in the HMAC-ALGO parameter.

As a result, we need to check in sctp_verify_param() that HMAC_SHA1 is
present in the list.  If not, we should probably treat this as a protocol
violation.

It should also be a protocol violation if the HMAC parameter is empty.

That could almost remove the need for the sctp-auth_asoc_get_hmac() function.

-vlad

> 
> This patch fix this problem.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> --- a/net/sctp/auth.c    2008-02-11 17:14:05.000000000 -0500
> +++ b/net/sctp/auth.c    2008-02-14 02:01:18.000000000 -0500
> @@ -549,13 +549,10 @@ struct sctp_hmac *sctp_auth_asoc_get_hma
>         if (!sctp_hmac_list[id].hmac_name)
>             continue;
> 
> -        break;
> +        return &sctp_hmac_list[id];
>     }
> 
> -    if (id == 0)
> -        return NULL;
> -
> -    return &sctp_hmac_list[id];
> +    return NULL;
> }
> 
> static int __sctp_auth_find_hmacid(__be16 *hmacs, int n_elts, __be16 
> hmac_id)
> 
> 

