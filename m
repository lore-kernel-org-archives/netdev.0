From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/7] net: Add flow_keys digest
Date: Tue, 28 Apr 2015 22:15:00 -0700
Message-ID: <1430284500.3711.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430281661-2271966-1-git-send-email-tom@herbertland.com>
	 <1430281661-2271966-7-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@resnulli.us
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:36570 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbbD2FPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 01:15:03 -0400
Received: by iebrs15 with SMTP id rs15so34686096ieb.3
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 22:15:02 -0700 (PDT)
In-Reply-To: <1430281661-2271966-7-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-28 at 21:27 -0700, Tom Herbert wrote:
> Some users of flow keys (well just sch_choke now) need to pass
> flow_keys in skbuff cb, and use them for exact comparisons of flows
> so that skb->hash is not sufficient. In order to increase size of
> the flow_keys structure, we introduce another structure for
> the purpose of passing flow keys in skbuff cb. We limit this structure
> to sixteen bytes, and we will technically treat this as a digest of
> flow_keys struct hence its name flow_keys_digest. In the first
> incaranation we just copy the flow_keys structure up to 16 bytes--
> this is the same information previously passed in the cb. In the
> future, we'll adapt this for larger flow_keys and could use something
> like SHA-1 over the whole flow_keys to improve the quality of the
> digest.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  include/net/flow_keys.h | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
> 
> diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
> index dc8fd81..f2610ad 100644
> --- a/include/net/flow_keys.h
> +++ b/include/net/flow_keys.h
> @@ -42,4 +42,23 @@ static inline __be32 skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8
>  u32 flow_hash_from_keys(struct flow_keys *keys);
>  unsigned int flow_get_hlen(const unsigned char *data, unsigned int max_len,
>  			   __be16 protocol);
> +
> +/* struct flow_keys_digest:
> + *
> + * This structure used to hold a digest of the full flow keys. This is a larger
> + * "hash" of a connection to allow definitively matching specific flows where
> + * the 32 bit skb_hash is not large enough. The size is limited to 16 bytes
> + * so that it can by used in CB of skb (see sch_choke for an example).
> + */
> +#define FLOW_KEYS_DIGEST_LEN	16
> +struct flow_keys_digest {
> +	u8	data[FLOW_KEYS_DIGEST_LEN];
> +};
> +
> +static inline void make_flow_keys_digest(struct flow_keys_digest *digest,
> +					 struct flow_keys *flow)

const struct flow_keys *flow

> +{

Maybe document that src,dst,ports must be in first 16 bytes of
flows_keys

Some BUILD_BUG_ON() might do the trick

> +	memcpy(&digest->data, flow, FLOW_KEYS_DIGEST_LEN);
> +}
> +
>  #endif
