From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 5/5] net: Add GRE keyid in flow_keys
Date: Wed, 13 May 2015 13:02:20 -0700
Message-ID: <1431547340.27831.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431444182-3935169-1-git-send-email-tom@herbertland.com>
	 <1431444182-3935169-6-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:34979 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965533AbbEMUCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 16:02:23 -0400
Received: by igbyr2 with SMTP id yr2so149175361igb.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 13:02:22 -0700 (PDT)
In-Reply-To: <1431444182-3935169-6-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-12 at 08:23 -0700, Tom Herbert wrote:
> In flow dissector if a GRE header contains a keyid this is saved in the
> new extra entropy field of flow_keys. The GRE keyid is then represented
> in the flow hash function input.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  include/net/flow_keys.h   |  1 +
>  net/core/flow_dissector.c | 15 ++++++++++++++-
>  2 files changed, 15 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
> index 906d47a..779e42f 100644
> --- a/include/net/flow_keys.h
> +++ b/include/net/flow_keys.h
> @@ -28,6 +28,7 @@ struct flow_keys {
>  	u8	padding;
>  	u32	vlan_id:12,
>  		flow_label:20;
> +	u32	extra_entropy;
>  
>  	union {
>  		__be32 ports;
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index f1fb7a5..1b204ed 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -195,8 +195,21 @@ ipv6:
>  			nhoff += 4;
>  			if (hdr->flags & GRE_CSUM)
>  				nhoff += 4;
> -			if (hdr->flags & GRE_KEY)
> +			if (hdr->flags & GRE_KEY) {
> +				const __be32 *keyid;
> +				__be32 _keyid;
> +
> +				keyid = __skb_header_pointer(skb, nhoff,
> +							     sizeof(_keyid),
> +							     data, hlen,
> +							     &_keyid);
> +				if (!keyid)
> +					return false;
> +
> +				flow->extra_entropy ^= ntohl(*keyid);

entropy doesn't need to respect byte order.

flow->extra_entropy ^= (__force u32)*keyid;
