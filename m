From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v2 1/2] ip_tunnel: fix potential issue in ip_tunnel_rcv
Date: Wed, 7 Jun 2017 19:13:42 -0700
Message-ID: <CAOrHB_CZ-3TRs2O3KATW_ji_QQxqO=28UeDU_-Gx7ZPxz_RWCg@mail.gmail.com>
References: <1496883476-17445-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "=David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com390e>
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496883476-17445-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 7, 2017 at 5:57 PM, Haishuang Yan
<yanhaishuang@cmss.chinamobile.com> wrote:
> When ip_tunnel_rcv fails, the tun_dst won't be freed, so move
> skb_dst_set to begin and tun_dst would be freed by kfree_skb.
>
> CC: Pravin B Shelar <pshelar@nicira.com>
> Fixes: 2e15ea390e6f ("ip_gre: Add support to collect tunnel metadata.")
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com390e>
> ---
>  net/ipv4/ip_tunnel.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index b878ecb..27fc20f 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -386,6 +386,9 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
>         const struct iphdr *iph = ip_hdr(skb);
>         int err;
>
> +       if (tun_dst)
> +               skb_dst_set(skb, (struct dst_entry *)tun_dst);
> +
If dst is set so early, skb_scrub_packet() would remove the tunnel dst
reference.
It is better to call skb_dst_drop() from error code path.

>  #ifdef CONFIG_NET_IPGRE_BROADCAST
>         if (ipv4_is_multicast(iph->daddr)) {
>                 tunnel->dev->stats.multicast++;
> @@ -439,9 +442,6 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
>                 skb->dev = tunnel->dev;
>         }
>
> -       if (tun_dst)
> -               skb_dst_set(skb, (struct dst_entry *)tun_dst);
> -
>         gro_cells_receive(&tunnel->gro_cells, skb);
>         return 0;
>
> --
> 1.8.3.1
>
>
>
