From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 1/5] net: Get skb hash over flow_keys
 structure
Date: Mon, 11 May 2015 21:56:46 -0700
Message-ID: <1431406606.566.62.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431401204-731380-1-git-send-email-tom@herbertland.com>
	 <1431401204-731380-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:33964 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbbELE4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 00:56:48 -0400
Received: by iedfl3 with SMTP id fl3so142786328ied.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 21:56:48 -0700 (PDT)
In-Reply-To: <1431401204-731380-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-11 at 20:26 -0700, Tom Herbert wrote:
> This patch changes flow hashing to use jhash2 over the flow_keys
> structure instead just doing jhash_3words over src, dst, and ports.
> This method will allow us take more input into the hashing function
> so that we can include full IPv6 addresses, VLAN, flow labels etc.
> without needing to resort to xor'ing which makes for a poor hash.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  include/net/flow_keys.h   | 12 +++++++++---
>  net/core/flow_dissector.c | 20 ++++++++++++++------
>  2 files changed, 23 insertions(+), 9 deletions(-)
> 
> diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
> index 6d6ef62..5907472 100644
> --- a/include/net/flow_keys.h
> +++ b/include/net/flow_keys.h
> @@ -15,6 +15,12 @@
>   * All the members, except thoff, are in network byte order.
>   */
>  struct flow_keys {
> +	u16	thoff;
> +#define FLOW_KEYS_HASH_START_FIELD	n_proto
> +	__be16	n_proto;
> +	u8	ip_proto;
> +	u8	padding;
> +
>  	/* (src,dst) must be grouped, in the same way than in IP header */
>  	__be32 src;
>  	__be32 dst;
> @@ -22,11 +28,11 @@ struct flow_keys {
>  		__be32 ports;
>  		__be16 port16[2];
>  	};
> -	u16	thoff;
> -	__be16	n_proto;
> -	u8	ip_proto;
>  };
>  
> +#define FLOW_KEYS_HASH_OFFSET		\
> +	offsetof(struct flow_keys, FLOW_KEYS_HASH_START_FIELD)
> +

I don't really understand : 

This (2) is not a multiple of 4, so some arches will have unaligned word
accesses ?

>  bool __skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow,
>  			void *data, __be16 proto, int nhoff, int hlen);
>  static inline bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow)
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index d3acc4d..02c5104 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -267,9 +267,19 @@ static __always_inline void __flow_hash_secret_init(void)
>  	net_get_random_once(&hashrnd, sizeof(hashrnd));
>  }
>  
> -static __always_inline u32 __flow_hash_3words(u32 a, u32 b, u32 c, u32 keyval)
> +static __always_inline u32 __flow_hash_words(u32 *words, u32 length, u32 keyval)
>  {
> -	return jhash_3words(a, b, c, keyval);
> +	return jhash2(words, length, keyval);
> +}
> +

-> crash or very slow on MIPS.
