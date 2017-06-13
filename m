From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] ip6_tunnel: Correct tos value in collect_md mode
Date: Tue, 13 Jun 2017 11:57:20 +0200
Message-ID: <593FB700.6020701@iogearbox.net>
References: <1497340529-18736-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        peter.a.dawson@boeing.com, ast@fb.com
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497340529-18736-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/13/2017 09:55 AM, Haishuang Yan wrote:
> Same as ip_gre, geneve and vxlan, use key->tos as tos value.
>

Please also add Fixes tag and Cc original authors.

Fixes: 0e9a709560db ("ip6_tunnel, ip6_gre: fix setting of DSCP on encapsulated packets")

> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> ---
>   net/ipv6/ip6_tunnel.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index ef99d59..5f4aff5 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -1249,7 +1249,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
>   		fl6.flowi6_proto = IPPROTO_IPIP;
>   		fl6.daddr = key->u.ipv6.dst;
>   		fl6.flowlabel = key->label;
> -		dsfield = ip6_tclass(key->label);
> +		dsfield = key->tos;

Not exactly the same as vxlan / geneve. They do use key->tos
indeed, but they also set fl6.flowlabel differently:

   [...]
   prio = info->key.tos;
   [...]
   fl6->flowlabel = ip6_make_flowinfo(RT_TOS(prio),
                                      info->key.label);
   [...]

But looks like the latter is done later in ip6_tnl_xmit() eventually
before the route lookup as per 5f733ee68f9a ("ip6_tunnel: fix traffic
class routing for tunnels") fix. However, you still might want to
mask key->tos with RT_TOS().

>   	} else {
>   		if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
>   			encap_limit = t->parms.encap_limit;
> @@ -1320,7 +1320,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
>   		fl6.flowi6_proto = IPPROTO_IPV6;
>   		fl6.daddr = key->u.ipv6.dst;
>   		fl6.flowlabel = key->label;
> -		dsfield = ip6_tclass(key->label);
> +		dsfield = key->tos;
>   	} else {
>   		offset = ip6_tnl_parse_tlv_enc_lim(skb, skb_network_header(skb));
>   		/* ip6_tnl_parse_tlv_enc_lim() might have reallocated skb->head */
>
