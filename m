From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH] geneve: Fix setting ttl value in collect metadata mode
Date: Mon, 4 Sep 2017 23:47:47 -0700
Message-ID: <CAOrHB_DN4Qo4biEwhiW8X24udQbR9Miix8cwrR2Pcbj5W42txA@mail.gmail.com>
References: <1504442982-12431-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Girish Moodalbail <girish.moodalbail@oracle.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504442982-12431-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 3, 2017 at 5:49 AM, Haishuang Yan
<yanhaishuang@cmss.chinamobile.com> wrote:
> If key->tos is zero in collect metadata mode, tos should fallback to
> ip{4,6}_dst_hoplimit, same as normal mode.
>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> ---
>  drivers/net/geneve.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index f640407..d52a65f 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -834,11 +834,10 @@ static int geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
>         sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
>         if (geneve->collect_md) {
>                 tos = ip_tunnel_ecn_encap(key->tos, ip_hdr(skb), skb);
> -               ttl = key->ttl;
>         } else {
>                 tos = ip_tunnel_ecn_encap(fl4.flowi4_tos, ip_hdr(skb), skb);
> -               ttl = key->ttl ? : ip4_dst_hoplimit(&rt->dst);
>         }
> +       ttl = key->ttl ? : ip4_dst_hoplimit(&rt->dst);
In collect md mode, geneve has to set TTL value from tunnel metadata.
That is the API exposed to userspace. is there reason for this change?


>         df = key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
>
>         err = geneve_build_skb(&rt->dst, skb, info, xnet, sizeof(struct iphdr));
> @@ -873,12 +872,11 @@ static int geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
>         sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
>         if (geneve->collect_md) {
>                 prio = ip_tunnel_ecn_encap(key->tos, ip_hdr(skb), skb);
> -               ttl = key->ttl;
>         } else {
>                 prio = ip_tunnel_ecn_encap(ip6_tclass(fl6.flowlabel),
>                                            ip_hdr(skb), skb);
> -               ttl = key->ttl ? : ip6_dst_hoplimit(dst);
>         }
> +       ttl = key->ttl ? : ip6_dst_hoplimit(dst);
>         err = geneve_build_skb(dst, skb, info, xnet, sizeof(struct ipv6hdr));
>         if (unlikely(err))
>                 return err;
> --
> 1.8.3.1
>
>
>
