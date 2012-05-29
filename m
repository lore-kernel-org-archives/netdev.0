From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] skb: avoid unnecessary reallocations in __skb_cow
Date: Tue, 29 May 2012 14:34:08 +0200
Message-ID: <1338294848.2840.15.camel@edumazet-glaptop>
References: <1338132370-88299-1-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:58125 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750696Ab2E2MeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 08:34:14 -0400
Received: by eeit10 with SMTP id t10so1058857eei.19
        for <netdev@vger.kernel.org>; Tue, 29 May 2012 05:34:12 -0700 (PDT)
In-Reply-To: <1338132370-88299-1-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-05-27 at 17:26 +0200, Felix Fietkau wrote:
> At the beginning of __skb_cow, headroom gets set to a minimum of
> NET_SKB_PAD. This causes unnecessary reallocations if the buffer was not
> cloned and the headroom is just below NET_SKB_PAD, but still more than the
> amount requested by the caller.
> This was showing up frequently in my tests on VLAN tx, where
> vlan_insert_tag calls skb_cow_head(skb, VLAN_HLEN).
> 
> Fix this by only setting the headroom delta if either there is less
> headroom than specified by the caller, or if reallocation has to be done
> anyway because the skb was cloned.
> 
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> ---
>  include/linux/skbuff.h |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 0e50171..1898471 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -1894,12 +1894,15 @@ static inline int skb_clone_writable(const struct sk_buff *skb, unsigned int len
>  static inline int __skb_cow(struct sk_buff *skb, unsigned int headroom,
>  			    int cloned)
>  {
> +	unsigned int alloc_headroom = headroom;
>  	int delta = 0;
>  
>  	if (headroom < NET_SKB_PAD)
> -		headroom = NET_SKB_PAD;
> -	if (headroom > skb_headroom(skb))
> -		delta = headroom - skb_headroom(skb);
> +		alloc_headroom = NET_SKB_PAD;
> +	if (headroom > skb_headroom(skb) ||
> +	    (cloned && alloc_headroom > skb_headroom(skb))) {
> +		delta = alloc_headroom - skb_headroom(skb);
> +	}
>  
>  	if (delta || cloned)
>  		return pskb_expand_head(skb, ALIGN(delta, NET_SKB_PAD), 0,

Nice catch.

Scratching my head on this one. Why not the obvious fix ?

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0e50171..b534a1b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1896,8 +1896,6 @@ static inline int __skb_cow(struct sk_buff *skb, unsigned int headroom,
 {
 	int delta = 0;
 
-	if (headroom < NET_SKB_PAD)
-		headroom = NET_SKB_PAD;
 	if (headroom > skb_headroom(skb))
 		delta = headroom - skb_headroom(skb);
 
