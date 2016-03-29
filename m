From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net PATCH] gro: Allow tunnel stacking in the case of FOU/GUE
Date: Tue, 29 Mar 2016 14:13:11 -0700
Message-ID: <CALx6S36PohjN6ReOE_cZKcyQdcRDOmSh+sij9boTVLnDHNc7JA@mail.gmail.com>
References: <20160328235613.26269.26291.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesse Gross <jesse@kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:38704 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754256AbcC2VNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 17:13:13 -0400
Received: by mail-ig0-f171.google.com with SMTP id ui10so16264484igc.1
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 14:13:12 -0700 (PDT)
In-Reply-To: <20160328235613.26269.26291.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 28, 2016 at 4:58 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
> This patch should fix the issues seen with a recent fix to prevent
> tunnel-in-tunnel frames from being generated with GRO.  The fix itself is
> correct for now as long as we do not add any devices that support
> NETIF_F_GSO_GRE_CSUM.  When such a device is added it could have the
> potential to mess things up due to the fact that the outer transport header
> points to the outer UDP header and not the GRE header as would be expected.
>
> Fixes: fac8e0f579695 ("tunnels: Don't apply GRO to multiple layers of encapsulation.")
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
>
> This should allow us to keep the fix that Jesse added without breaking the
> 3 cases that Tom called out in terms of FOU/GUE.
>
> Additional work will be needed in net-next as we probably need to make it
> so that offloads work correctly when we get around to supporting
> NETIF_F_GSO_GRE_CSUM.
>
>  net/ipv4/fou.c |   32 ++++++++++++++++++++++++++++++++
>  1 file changed, 32 insertions(+)
>
> diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
> index 4136da9275b2..2c30256ee959 100644
> --- a/net/ipv4/fou.c
> +++ b/net/ipv4/fou.c
> @@ -195,6 +195,22 @@ static struct sk_buff **fou_gro_receive(struct sk_buff **head,
>         u8 proto = NAPI_GRO_CB(skb)->proto;
>         const struct net_offload **offloads;
>
> +       switch (proto) {
> +       case IPPROTO_IPIP:
> +       case IPPROTO_IPV6:
> +       case IPPROTO_GRE:
> +               /* We can clear the encap_mark for these 3 protocols as
> +                * we are either adding an L4 tunnel header to the outer
> +                * L3 tunnel header, or we are are simply treating the
> +                * GRE tunnel header as though it is a UDP protocol
> +                * specific header such as VXLAN or GENEVE.
> +                */
> +               NAPI_GRO_CB(skb)->encap_mark = 0;
> +               /* fall-through */
> +       default:
> +               break;
> +       }

Switch statement is not needed, just do NAPI_GRO_CB(skb)->encap_mark = 0;

> +
>         rcu_read_lock();
>         offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
>         ops = rcu_dereference(offloads[proto]);
> @@ -359,6 +375,22 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
>                 NAPI_GRO_CB(p)->flush |= NAPI_GRO_CB(p)->flush_id;
>         }
>
> +       switch (guehdr->proto_ctype) {
> +       case IPPROTO_IPIP:
> +       case IPPROTO_IPV6:
> +       case IPPROTO_GRE:
> +               /* We can clear the encap_mark for these 3 protocols as
> +                * we are either adding an L4 tunnel header to the outer
> +                * L3 tunnel header, or we are are simply treating the
> +                * GRE tunnel header as though it is a UDP protocol
> +                * specific header such as VXLAN or GENEVE.
> +                */
> +               NAPI_GRO_CB(skb)->encap_mark = 0;
> +               /* fall-through */
> +       default:
> +               break;
> +       }
> +
Here also.

>         rcu_read_lock();
>         offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
>         ops = rcu_dereference(offloads[guehdr->proto_ctype]);
>
