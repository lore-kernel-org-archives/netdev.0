From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 1/2] ip_gre: increase inner ip header ID during segmentation
Date: Fri, 22 Mar 2013 10:12:28 -0700
Message-ID: <CALnjE+q=v4iu7kQod103P-gqCf5YRmJOKeA4-ev9LA_diaVdYA@mail.gmail.com>
References: <1363938600-26129-1-git-send-email-amwang@redhat.com>
	<1363948292-9902-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:58426 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1422646Ab3CVRM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 13:12:29 -0400
Received: by mail-gh0-f198.google.com with SMTP id r11so5728649ghr.9
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 10:12:29 -0700 (PDT)
In-Reply-To: <1363948292-9902-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 22, 2013 at 3:31 AM, Cong Wang <amwang@redhat.com> wrote:
> From: Cong Wang <amwang@redhat.com>
>
> According to the previous discussion [1] on netdev list, DaveM insists
> we should increase the IP header ID for each segmented packets.
> This patch fixes it.
>

Outer IP header ids are incremented in inet_gso_segment for GRE. So it
is already done. In any case I don't think we should increment
IP-Identification in GRE handler, This is layering violation.
This breaks GRE with IPV6 payload.

> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
>
> 1. http://marc.info/?t=136384172700001&r=1&w=2
>
> ---
>  net/ipv4/gre.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
>
> diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
> index 7a4c710..e20631c 100644
> --- a/net/ipv4/gre.c
> +++ b/net/ipv4/gre.c
> @@ -125,8 +125,9 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>         netdev_features_t enc_features;
>         int ghl = GRE_HEADER_SECTION;
>         struct gre_base_hdr *greh;
> +       struct iphdr *iph;
>         int mac_len = skb->mac_len;
> -       int tnl_hlen;
> +       int tnl_hlen, id;
>         bool csum;
>
>         if (unlikely(skb_shinfo(skb)->gso_type &
> @@ -170,6 +171,8 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>         skb_set_network_header(skb, skb_inner_network_offset(skb));
>         skb->mac_len = skb_inner_network_offset(skb);
>
> +       iph = ip_hdr(skb);
> +       id = ntohs(iph->id);
>         /* segment inner packet. */
>         enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
>         segs = skb_mac_gso_segment(skb, enc_features);
> @@ -179,6 +182,8 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>         skb = segs;
>         tnl_hlen = skb_tnl_header_len(skb);
>         do {
> +               iph = (struct iphdr *)skb->data;
> +               iph->id = htons(id++);
>                 __skb_push(skb, ghl);
>                 if (csum) {
>                         __be32 *pcsum;
> --
> 1.7.7.6
>
