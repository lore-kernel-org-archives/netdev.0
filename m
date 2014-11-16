From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCHv2 net 1/4] net: Add vxlan_gso_check() helper
Date: Sun, 16 Nov 2014 11:35:52 +0200
Message-ID: <CAJ3xEMhwq2Cuiw8sjY3DHFBEdmgKieNZgxWhGsfZ=Rtz41KhTQ@mail.gmail.com>
References: <1415925495-59312-1-git-send-email-joestringer@nicira.com>
	<1415925495-59312-2-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:53757 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754485AbaKPJfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 04:35:53 -0500
Received: by mail-oi0-f46.google.com with SMTP id h136so847623oig.5
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 01:35:53 -0800 (PST)
In-Reply-To: <1415925495-59312-2-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2014 at 2:38 AM, Joe Stringer <joestringer@nicira.com> wrote:
> Most NICs that report NETIF_F_GSO_UDP_TUNNEL support VXLAN, and not
> other UDP-based encapsulation protocols where the format and size of the
> header differs. This patch implements a generic ndo_gso_check() for
> VXLAN which will only advertise GSO support when the skb looks like it
> contains VXLAN (or no UDP tunnelling at all).
>
> Implementation shamelessly stolen from Tom Herbert:
> http://thread.gmane.org/gmane.linux.network/332428/focus=333111
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> v2: Merge helpers for be2net, mlx4, qlcnic
>     Use (sizeof(struct udphdr) + sizeof(struct vxlanhdr))
> v1: Initial post
> ---
>  drivers/net/vxlan.c |   13 +++++++++++++
>  include/net/vxlan.h |    2 ++
>  2 files changed, 15 insertions(+)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index fa9dc45..6b65863 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1571,6 +1571,19 @@ static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
>         return false;
>  }
>
> +bool vxlan_gso_check(struct sk_buff *skb)
> +{
> +       if ((skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL) &&
> +           (skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
> +            skb->inner_protocol != htons(ETH_P_TEB) ||
> +            (skb_inner_mac_header(skb) - skb_transport_header(skb) !=
> +             sizeof(struct udphdr) + sizeof(struct vxlanhdr))))
> +               return false;
> +
> +       return true;
> +}
> +EXPORT_SYMBOL_GPL(vxlan_gso_check);

Joe, any chance you can make the extra step and inline that in
vxlan.h? this is fast path call... you will only need to move struct
vxlanhdr there too.

Or.
