From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net PATCH] net: Reset encap_level to avoid resetting features on
 inner IP headers
Date: Wed, 23 Mar 2016 10:25:35 -0700
Message-ID: <CALx6S34Ag8x_=6S2y=S8_D_0=ELb0um7gom+rsy1r=pn5LQ5oA@mail.gmail.com>
References: <20160322231732.13054.71337.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kernel Team <kernel-team@fb.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:33187 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754652AbcCWRZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 13:25:53 -0400
Received: by mail-io0-f179.google.com with SMTP id c63so55060744iof.0
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 10:25:53 -0700 (PDT)
In-Reply-To: <20160322231732.13054.71337.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2016 at 4:18 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch corrects an oversight in which we were allowing the encap_level
> value to pass from the outer headers to the inner headers.  As a result we
> were incorrectly identifying UDP or GRE tunnels as also making use of ipip
> or sit when the second header actually represented a tunnel encapsulated in
> either a UDP or GRE tunnel which already had the features masked.
>
> Fixes: 76443456227097179c1482 ("net: Move GSO csum into SKB_GSO_CB")
> Reported-by: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Acked-by: Tom Herbert <tom@herbertland.com>

I do found it strange that we need to lie about the encap_level to get
things to work. Hopefully, once the remaining encapsulation devices
move to NETIF_HW_CSUM we can get rid of  enc_features entirely.

> ---
>  net/ipv4/gre_offload.c |    1 +
>  net/ipv4/udp_offload.c |    1 +
>  2 files changed, 2 insertions(+)
>
> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> index dea0390d65bb..43a5c76742dc 100644
> --- a/net/ipv4/gre_offload.c
> +++ b/net/ipv4/gre_offload.c
> @@ -49,6 +49,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>
>         /* setup inner skb. */
>         skb->encapsulation = 0;
> +       SKB_GSO_CB(skb)->encap_level = 0;
>         __skb_pull(skb, tnl_hlen);
>         skb_reset_mac_header(skb);
>         skb_set_network_header(skb, skb_inner_network_offset(skb));
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 5fcb93269afb..80236a9e1769 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -56,6 +56,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>
>         /* setup inner skb. */
>         skb->encapsulation = 0;
> +       SKB_GSO_CB(skb)->encap_level = 0;
>         __skb_pull(skb, tnl_hlen);
>         skb_reset_mac_header(skb);
>         skb_set_network_header(skb, skb_inner_network_offset(skb));
>
