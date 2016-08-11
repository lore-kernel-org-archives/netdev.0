From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: suppress sparse warnings in IP6_ECN_set_ce()
Date: Thu, 11 Aug 2016 23:26:33 +0200
Message-ID: <1470950793.12189.7.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1470909883-5463-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f193.google.com ([209.85.213.193]:32834 "EHLO
	mail-yb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbcHKV0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 17:26:41 -0400
Received: by mail-yb0-f193.google.com with SMTP id v8so134666ybe.0
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 14:26:40 -0700 (PDT)
In-Reply-To: <1470909883-5463-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-11 at 12:04 +0200, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
> 
> Use the correct type for these manipulations, which is __wsum,
> instead of using __be32. This doesn't really change anything
> since __wsum really *is* __be32, but removes the address space
> warnings from sparse.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Fixes: 34ae6a1aa054 ("ipv6: update skb->csum when CE mark is propagated")
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>
> ---
>  include/net/inet_ecn.h | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
> index 0dc0a51da38f..89aa4e73fc37 100644
> --- a/include/net/inet_ecn.h
> +++ b/include/net/inet_ecn.h
> @@ -119,14 +119,14 @@ struct ipv6hdr;
>   */
>  static inline int IP6_ECN_set_ce(struct sk_buff *skb, struct ipv6hdr *iph)
>  {
> -	__be32 from, to;
> +	__wsum from, to;
>  
>  	if (INET_ECN_is_not_ect(ipv6_get_dsfield(iph)))
>  		return 0;
>  
> -	from = *(__be32 *)iph;
> -	to = from | htonl(INET_ECN_CE << 20);
> -	*(__be32 *)iph = to;
> +	from = *(__wsum *)iph;

Well, 4 first bytes of iph are not a __wsum technically speaking :(

> +	to = from | (__force __wsum)htonl(INET_ECN_CE << 20);

Hmm... this is a bit convoluted.
Doing a OR operation on a __wsum seems strange to me.

> +	*(__wsum *)iph = to;
>  	if (skb->ip_summed == CHECKSUM_COMPLETE)
>  		skb->csum = csum_add(csum_sub(skb->csum, from), to);
>  	return 1;



What about something like that ?

No big deal, but this looks a bit cleaner to me.

Thanks.

diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
index 0dc0a51da38faacab2ea275681f5f70e09a6c79e..dce2d586d9cecb9e9de381aa0926f3e3d3ec9568 100644
--- a/include/net/inet_ecn.h
+++ b/include/net/inet_ecn.h
@@ -128,7 +128,8 @@ static inline int IP6_ECN_set_ce(struct sk_buff *skb, struct ipv6hdr *iph)
 	to = from | htonl(INET_ECN_CE << 20);
 	*(__be32 *)iph = to;
 	if (skb->ip_summed == CHECKSUM_COMPLETE)
-		skb->csum = csum_add(csum_sub(skb->csum, from), to);
+		skb->csum = csum_add(csum_sub(skb->csum, (__force __wsum)from),
+				     (__force __wsum)to);
 	return 1;
 }
 
