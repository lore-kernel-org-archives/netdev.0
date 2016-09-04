From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next V5 2/4] net/dst: Utility functions to build
 dst_metadata without supplying an skb
Date: Sun, 4 Sep 2016 14:14:27 +0300
Message-ID: <116097f9-b3b7-5489-355b-c8a906fa1958@cogentembedded.com>
References: <1472986555-14949-1-git-send-email-hadarh@mellanox.com>
 <1472986555-14949-3-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33760 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753865AbcIDLOc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2016 07:14:32 -0400
Received: by mail-lf0-f47.google.com with SMTP id h127so6848781lfh.0
        for <netdev@vger.kernel.org>; Sun, 04 Sep 2016 04:14:31 -0700 (PDT)
In-Reply-To: <1472986555-14949-3-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/4/2016 1:55 PM, Hadar Hen Zion wrote:

> From: Amir Vadai <amir@vadai.me>
>
> Extract __ip_tun_set_dst() and __ipv6_tun_set_dst() out of
> ip_tun_rx_dst() and ipv6_tun_rx_dst(), to be used without supplying an
> skb.
>
> Signed-off-by: Amir Vadai <amir@vadai.me>
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>
> Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> ---
>  include/net/dst_metadata.h | 45 ++++++++++++++++++++++++++++++++-------------
>  1 file changed, 32 insertions(+), 13 deletions(-)
>
> diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
> index 5db9f59..49e8847 100644
> --- a/include/net/dst_metadata.h
> +++ b/include/net/dst_metadata.h
> @@ -112,12 +112,10 @@ static inline struct ip_tunnel_info *skb_tunnel_info_unclone(struct sk_buff *skb
>  	return &dst->u.tun_info;
>  }
>
> -static inline struct metadata_dst *ip_tun_rx_dst(struct sk_buff *skb,
> -						 __be16 flags,
> -						 __be64 tunnel_id,
> -						 int md_size)
> +static inline struct metadata_dst *
> +__ip_tun_set_dst(__be32 saddr, __be32 daddr, __u8 tos, __u8 ttl,
> +		 __be16 flags, __be64 tunnel_id, int md_size)

    The continuation lines should start under the 1st '__be32' on the broken 
up line. See how it was before your patch.

>  {
> -	const struct iphdr *iph = ip_hdr(skb);
>  	struct metadata_dst *tun_dst;
>
>  	tun_dst = tun_rx_dst(md_size);
> @@ -125,17 +123,27 @@ static inline struct metadata_dst *ip_tun_rx_dst(struct sk_buff *skb,
[...]
> -static inline struct metadata_dst *ipv6_tun_rx_dst(struct sk_buff *skb,
> +static inline struct metadata_dst *ip_tun_rx_dst(struct sk_buff *skb,
>  						 __be16 flags,
>  						 __be64 tunnel_id,
>  						 int md_size)
>  {
> -	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
> +	const struct iphdr *iph = ip_hdr(skb);
> +
> +	return __ip_tun_set_dst(iph->saddr, iph->daddr, iph->tos, iph->ttl,
> +				flags, tunnel_id, md_size);
> +}
> +
> +static inline struct metadata_dst *
> +__ipv6_tun_set_dst(const struct in6_addr *saddr, const struct in6_addr *daddr,
> +		   __u8 tos, __u8 ttl, __be32 label, __be16 flags,
> +		   __be64 tunnel_id, int md_size)

    The continuation lines should start under the 1st *const* on the broken up 
line.

> +{
>  	struct metadata_dst *tun_dst;
>  	struct ip_tunnel_info *info;
>
> @@ -150,14 +158,25 @@ static inline struct metadata_dst *ipv6_tun_rx_dst(struct sk_buff *skb,
[...]
> +static inline struct metadata_dst *
> +ipv6_tun_rx_dst(struct sk_buff *skb, __be16 flags, __be64 tunnel_id,
> +		int md_size)
> +{
> +	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
> +
> +	return __ipv6_tun_set_dst(&ip6h->saddr, &ip6h->daddr,
> +				ipv6_get_dsfield(ip6h), ip6h->hop_limit,
> +				ip6_flowlabel(ip6h), flags, tunnel_id,
> +				md_size);

    The continuation lines should start exactly under the 1st & on the broken 
up line.
    That's DaveM's preference, I don't remember if checkpatch.pl reports that 
for the networking code...

[...]

MBR, Sergei
