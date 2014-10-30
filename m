From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] gre: Fix regression in gretap TSO support
Date: Wed, 29 Oct 2014 22:14:57 -0700
Message-ID: <CALnjE+oK-O-PJH_u50HqQQLnvh+GyeCnv6tNQf5qzL0o1RiPQg@mail.gmail.com>
References: <20141030032430.4452.46388.stgit@ahduyck-workstation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Neal Cardwell <ncardwell@google.com>
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:46555 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750974AbaJ3FO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 01:14:58 -0400
Received: by mail-ie0-f173.google.com with SMTP id tr6so4495333ieb.4
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 22:14:58 -0700 (PDT)
In-Reply-To: <20141030032430.4452.46388.stgit@ahduyck-workstation.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2014 at 8:26 PM,  <alexander.duyck@gmail.com> wrote:
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
>
> On recent kernels I found that TSO on gretap interfaces didn't work.  After
> bisecting it I found that commit b884b1a4 had introduced a regression in
> which the Ethernet header was being included in the GRE header length.
>
> This change corrects that by basing the GRE header length on the inner mac
> header in the case of GRE tunnels using transparent Ethernet bridging, and
> uses the network header for all other GRE tunnel types.
>
> Fixes: b884b1a4 ("gre_offload: simplify GRE header length calculation in gre_gso_segment()")
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: H.K. Jerry Chu <hkchu@google.com>
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Patch also fixed problem with ovs-gre.

Acked-by: Pravin B Shelar <pshelar@nicira.com>

Thanks.

> ---
>  net/ipv4/gre_offload.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> index f6e345c..67a1f66 100644
> --- a/net/ipv4/gre_offload.c
> +++ b/net/ipv4/gre_offload.c
> @@ -47,7 +47,10 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>
>         greh = (struct gre_base_hdr *)skb_transport_header(skb);
>
> -       ghl = skb_inner_network_header(skb) - skb_transport_header(skb);
> +       if (greh->protocol == htons(ETH_P_TEB))
> +               ghl = skb_inner_mac_header(skb) - skb_transport_header(skb);
> +       else
> +               ghl = skb_inner_network_header(skb) - skb_transport_header(skb);
>         if (unlikely(ghl < sizeof(*greh)))
>                 goto out;
>
>
