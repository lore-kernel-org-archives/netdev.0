From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 2/3] net: mpls: Fixups for GSO
Date: Fri, 19 Aug 2016 13:17:20 -0700
Message-ID: <CAKgT0Ucs5UfdLTGd_tb5i9DEFhGwFOZO0ra0BToueRn4+3PHtA@mail.gmail.com>
References: <1471626542-13335-1-git-send-email-dsa@cumulusnetworks.com> <1471626542-13335-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Lennert Buytenhek <buytenh@wantstofly.org>,
        Simon Horman <simon.horman@netronome.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>, rshearma@brocade.com,
        Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
        olivier.dugeon@orange.com, Roopa Prabhu <roopa@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34573 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752435AbcHSURW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 16:17:22 -0400
Received: by mail-it0-f67.google.com with SMTP id e63so1928092ith.1
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 13:17:21 -0700 (PDT)
In-Reply-To: <1471626542-13335-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 19, 2016 at 10:09 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> As reported by Lennert the MPLS GSO code is failing to properly segment
> large packets. There are a couple of problems:
>
> 1. the inner protocol is not set so the gso segment functions for inner
>    protocol layers are not getting run, and
>
> 2  MPLS labels for packets that use the "native" (non-OVS) MPLS code
>    are not properly accounted for in mpls_gso_segment.
>
> The MPLS GSO code was added for OVS. It is re-using skb_mac_gso_segment
> to call the gso segment functions for the higher layer protocols. That
> means skb_mac_gso_segment is called twice -- once with the network
> protocol set to MPLS and again with the network protocol set to the
> inner protocol.
>
> This patch sets the inner skb protocol addressing item 1 above and sets
> the network_header and inner_network_header to mark where the MPLS labels
> start and end. The MPLS code in OVS is also updated to set the two
> network markers.
>
> From there the MPLS GSO code uses the difference between the network
> header and the inner network header to know the size of the MPLS header
> that was pushed. It then pulls the MPLS header, resets the mac_len and
> protocol for the inner protocol and then calls skb_mac_gso_segment
> to segment the skb.
>
> Afterward the inner protocol segmentation is done the skb protocol
> is set to mpls for each segment and the network and mac headers
> restored.
>
> Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  net/mpls/mpls_gso.c       | 38 +++++++++++++++++++++++++++-----------
>  net/mpls/mpls_iptunnel.c  |  4 ++++
>  net/openvswitch/actions.c |  6 ++++++
>  3 files changed, 37 insertions(+), 11 deletions(-)
>
> diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
> index 2055e57ed1c3..2aa4beaa0e4f 100644
> --- a/net/mpls/mpls_gso.c
> +++ b/net/mpls/mpls_gso.c
> @@ -23,32 +23,48 @@ static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
>                                        netdev_features_t features)
>  {
>         struct sk_buff *segs = ERR_PTR(-EINVAL);
> +       u16 mac_offset = skb->mac_header;
>         netdev_features_t mpls_features;
> +       u16 mac_len = skb->mac_len;
>         __be16 mpls_protocol;
> +       int mpls_hlen;
> +
> +       skb_reset_network_header(skb);
> +       mpls_hlen = skb_inner_network_header(skb) - skb_network_header(skb);
> +       if (unlikely(!pskb_may_pull(skb, mpls_hlen)))
> +               goto out;
>
>         /* Setup inner SKB. */
>         mpls_protocol = skb->protocol;
>         skb->protocol = skb->inner_protocol;
>
> -       /* Push back the mac header that skb_mac_gso_segment() has pulled.
> -        * It will be re-pulled by the call to skb_mac_gso_segment() below
> -        */
> -       __skb_push(skb, skb->mac_len);
> +       __skb_pull(skb, mpls_hlen);
> +
> +       skb->mac_len = 0;
> +       skb_reset_mac_header(skb);
> +       skb_set_network_header(skb, skb_inner_network_offset(skb));

No need to set the network header.  Both IPv4 and IPv6 GSO paths will
reset the network header just like you did at the start.

>         /* Segment inner packet. */
>         mpls_features = skb->dev->mpls_features & features;
>         segs = skb_mac_gso_segment(skb, mpls_features);
> +       if (IS_ERR_OR_NULL(segs)) {
> +               skb_gso_error_unwind(skb, mpls_protocol, mpls_hlen, mac_offset,
> +                                    mac_len);
> +               goto out;
> +       }
>
> +       skb = segs;

You could probably pull your math for mpls_hlen + mac_len out of the
loop below and just take care of adding mac_len to mpls_hlen up here
and store it of in mpls_hlen since it isn't used anywhere else.

> +       do {
> +               skb->mac_len = mac_len;
> +               skb->protocol = mpls_protocol;
>
> -       /* Restore outer protocol. */
> -       skb->protocol = mpls_protocol;
> +               __skb_push(skb, mpls_hlen + mac_len);
>
> -       /* Re-pull the mac header that the call to skb_mac_gso_segment()
> -        * above pulled.  It will be re-pushed after returning
> -        * skb_mac_gso_segment(), an indirect caller of this function.
> -        */
> -       __skb_pull(skb, skb->data - skb_mac_header(skb));

You need to store off the inner network header before you overwrite it
in the lines below.  Either skb_reset_inner_network_header before the
push, or skb_reset_inner_headers before you call the two lines below.

> +               skb_reset_mac_header(skb);
> +               skb_set_network_header(skb, mac_len);
> +       } while ((skb = skb->next));
>
> +out:
>         return segs;
>  }
>
> diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
> index aed872cc05a6..cf52cf30ac4b 100644
> --- a/net/mpls/mpls_iptunnel.c
> +++ b/net/mpls/mpls_iptunnel.c
> @@ -90,7 +90,11 @@ static int mpls_xmit(struct sk_buff *skb)
>         if (skb_cow(skb, hh_len + new_header_size))
>                 goto drop;
>
> +       skb_set_inner_protocol(skb, skb->protocol);
> +       skb_reset_inner_network_header(skb);
> +
>         skb_push(skb, new_header_size);
> +
>         skb_reset_network_header(skb);
>
>         skb->dev = out_dev;
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 1ecbd7715f6d..6d78f162a88b 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -167,6 +167,12 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>                 skb->mac_len);
>         skb_reset_mac_header(skb);
>
> +       /* for GSO: set MPLS as network header and encapsulated protocol
> +        * header as inner network header
> +        */
> +       skb_set_network_header(skb, skb->mac_len);
> +       skb_set_inner_network_header(skb, skb->mac_len + MPLS_HLEN);
> +
>         new_mpls_lse = (__be32 *)skb_mpls_header(skb);
>         *new_mpls_lse = mpls->mpls_lse;
>
> --
> 2.1.4
>
