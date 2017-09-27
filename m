From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH v3 1/1] ip_tunnel: add mpls over gre encapsulation
Date: Wed, 27 Sep 2017 08:36:11 -0700
Message-ID: <CAJieiUgkOwJvrEq9vw+2-Up0qc9hvxt3M6LWnf8FSyx9VRX-Dw@mail.gmail.com>
References: <cover.1506504229.git.amine.kherbouche@6wind.com> <198fd7591bc1daae4727ee8b950e116b59f2d4c3.1506504229.git.amine.kherbouche@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, xeb@mail.ru,
        David Lamparter <equinox@diac24.net>
To: Amine Kherbouche <amine.kherbouche@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f170.google.com ([209.85.217.170]:45236 "EHLO
        mail-ua0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752455AbdI0PgM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 11:36:12 -0400
Received: by mail-ua0-f170.google.com with SMTP id c27so8739904uah.2
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 08:36:12 -0700 (PDT)
In-Reply-To: <198fd7591bc1daae4727ee8b950e116b59f2d4c3.1506504229.git.amine.kherbouche@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 27, 2017 at 2:37 AM, Amine Kherbouche
<amine.kherbouche@6wind.com> wrote:
> This commit introduces the MPLSoGRE support (RFC 4023), using ip tunnel
> API.
>
> Encap:
>   - Add a new iptunnel type mpls.
>   - Share tx path: gre type mpls loaded from skb->protocol.
>
> Decap:
>   - pull gre hdr and call mpls_forward().
>
> Signed-off-by: Amine Kherbouche <amine.kherbouche@6wind.com>
> ---
>  include/linux/mpls.h           |  2 ++
>  include/uapi/linux/if_tunnel.h |  1 +
>  net/ipv4/ip_gre.c              | 11 +++++++++
>  net/ipv6/ip6_gre.c             | 11 +++++++++
>  net/mpls/af_mpls.c             | 52 ++++++++++++++++++++++++++++++++++++++++++
>  5 files changed, 77 insertions(+)
>
> diff --git a/include/linux/mpls.h b/include/linux/mpls.h
> index 384fb22..57203c1 100644
> --- a/include/linux/mpls.h
> +++ b/include/linux/mpls.h
> @@ -8,4 +8,6 @@
>  #define MPLS_TC_MASK           (MPLS_LS_TC_MASK >> MPLS_LS_TC_SHIFT)
>  #define MPLS_LABEL_MASK                (MPLS_LS_LABEL_MASK >> MPLS_LS_LABEL_SHIFT)
>
> +int mpls_gre_rcv(struct sk_buff *skb, int gre_hdr_len);
> +
>  #endif  /* _LINUX_MPLS_H */
> diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
> index 2e52088..a2f48c0 100644
> --- a/include/uapi/linux/if_tunnel.h
> +++ b/include/uapi/linux/if_tunnel.h
> @@ -84,6 +84,7 @@ enum tunnel_encap_types {
>         TUNNEL_ENCAP_NONE,
>         TUNNEL_ENCAP_FOU,
>         TUNNEL_ENCAP_GUE,
> +       TUNNEL_ENCAP_MPLS,
>  };
>
>  #define TUNNEL_ENCAP_FLAG_CSUM         (1<<0)
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 9cee986..0a898f4 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -32,6 +32,9 @@
>  #include <linux/netfilter_ipv4.h>
>  #include <linux/etherdevice.h>
>  #include <linux/if_ether.h>
> +#if IS_ENABLED(CONFIG_MPLS)
> +#include <linux/mpls.h>
> +#endif
>
>  #include <net/sock.h>
>  #include <net/ip.h>
> @@ -412,6 +415,14 @@ static int gre_rcv(struct sk_buff *skb)
>                         return 0;
>         }
>
> +       if (unlikely(tpi.proto == htons(ETH_P_MPLS_UC))) {
> +#if IS_ENABLED(CONFIG_MPLS)
> +               return mpls_gre_rcv(skb, hdr_len);
> +#else
> +               goto drop;
> +#endif
> +       }
> +

Amine, one small nit here.., if you define mpls_gre_rcv in gre header
(like you had initially), you could do the below...

#if IS_ENABLED(CONFIG_MPLS)
mpls_gre_rcv()
{
     /* real func */
}
#else
mpls_gre_rcv()
{
    kfree_skb(skb)
    return NET_RX_DROP
}
#endif

and the check in gre_rcv() reduces to

if (unlikely(tpi.proto == htons(ETH_P_MPLS_UC)))
        return mpls_gre_rcv(skb, hdr_len);

Which looks much cleaner.

Other than that, looks great. pls add my Acked-by: Roopa Prabhu
<roopa@cumulusnetworks.com> to your next version.

thanks!
