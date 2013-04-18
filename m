From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [Patch net-next v4 5/5] ipv6: Add generic UDP Tunnel segmentation
Date: Thu, 18 Apr 2013 10:23:28 -0700
Message-ID: <CALnjE+peRJga4HK7v9e-1v1F0xftNkejd9O5KngVRuu2P2VtQw@mail.gmail.com>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	<1366175423-27310-6-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:34569 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S935970Ab3DRRX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 13:23:29 -0400
Received: by mail-gh0-f199.google.com with SMTP id r16so3338761ghr.6
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 10:23:28 -0700 (PDT)
In-Reply-To: <1366175423-27310-6-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 16, 2013 at 10:10 PM, Cong Wang <amwang@redhat.com> wrote:
> From: Cong Wang <amwang@redhat.com>
>
> Similar to commit 731362674580cb0c696cd1b1a03d8461a10cf90a
> (tunneling: Add generic Tunnel segmentation)
>
> This patch adds generic tunneling offloading support for IPv6-UDP
> based tunnels.
>
> This can be used by tunneling protocols like VXLAN.
>
> Cc: Jesse Gross <jesse@nicira.com>
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  net/ipv6/ip6_offload.c |    4 +-
>  net/ipv6/udp_offload.c |  155 +++++++++++++++++++++++++++++++++---------------
>  2 files changed, 110 insertions(+), 49 deletions(-)
>
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index 71b766e..87fbf2e 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -91,6 +91,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
>         unsigned int unfrag_ip6hlen;
>         u8 *prevhdr;
>         int offset = 0;
> +       bool tunnel;
>
>         if (unlikely(skb_shinfo(skb)->gso_type &
>                      ~(SKB_GSO_UDP |
> @@ -105,6 +106,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
>         if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
>                 goto out;
>
> +       tunnel = skb->encapsulation;
>         ipv6h = ipv6_hdr(skb);
>         __skb_pull(skb, sizeof(*ipv6h));
>         segs = ERR_PTR(-EPROTONOSUPPORT);
> @@ -125,7 +127,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
>                 ipv6h = ipv6_hdr(skb);
>                 ipv6h->payload_len = htons(skb->len - skb->mac_len -
>                                            sizeof(*ipv6h));
> -               if (proto == IPPROTO_UDP) {
> +               if (!tunnel && proto == IPPROTO_UDP) {
>                         unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
>                         fptr = (struct frag_hdr *)(skb_network_header(skb) +
>                                 unfrag_ip6hlen);
> diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
> index 3bb3a89..bbde7ba 100644
> --- a/net/ipv6/udp_offload.c
> +++ b/net/ipv6/udp_offload.c
> @@ -21,26 +21,81 @@ static int udp6_ufo_send_check(struct sk_buff *skb)
>         const struct ipv6hdr *ipv6h;
>         struct udphdr *uh;
>
> -       /* UDP Tunnel offload on ipv6 is not yet supported. */
> -       if (skb->encapsulation)
> -               return -EINVAL;
> -
>         if (!pskb_may_pull(skb, sizeof(*uh)))
>                 return -EINVAL;
>
> -       ipv6h = ipv6_hdr(skb);
> -       uh = udp_hdr(skb);
> +       if (likely(!skb->encapsulation)) {
> +               ipv6h = ipv6_hdr(skb);
> +               uh = udp_hdr(skb);
> +
> +               uh->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr, skb->len,
> +                                            IPPROTO_UDP, 0);
> +               skb->csum_start = skb_transport_header(skb) - skb->head;
> +               skb->csum_offset = offsetof(struct udphdr, check);
> +               skb->ip_summed = CHECKSUM_PARTIAL;
> +       }
>
> -       uh->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr, skb->len,
> -                                    IPPROTO_UDP, 0);
> -       skb->csum_start = skb_transport_header(skb) - skb->head;
> -       skb->csum_offset = offsetof(struct udphdr, check);
> -       skb->ip_summed = CHECKSUM_PARTIAL;
>         return 0;
>  }
>
> +static struct sk_buff *skb_udp6_tunnel_segment(struct sk_buff *skb,
> +                                              netdev_features_t features)
> +{
> +       struct sk_buff *segs = ERR_PTR(-EINVAL);
> +       int mac_len = skb->mac_len;
> +       int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
> +       int outer_hlen;
> +       netdev_features_t enc_features;
> +
> +       if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
> +               goto out;
> +
> +       skb->encapsulation = 0;
> +       __skb_pull(skb, tnl_hlen);
> +       skb_reset_mac_header(skb);
> +       skb_set_network_header(skb, skb_inner_network_offset(skb));
> +       skb->mac_len = skb_inner_network_offset(skb);
> +
> +       /* segment inner packet. */
> +       enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
> +       segs = skb_mac_gso_segment(skb, enc_features);
> +       if (!segs || IS_ERR(segs))
> +               goto out;
> +
> +       outer_hlen = skb_tnl_header_len(skb);
> +       skb = segs;
> +       do {
> +               struct udphdr *uh;
> +               int udp_offset = outer_hlen - tnl_hlen;
> +
> +               skb->mac_len = mac_len;
> +
> +               skb_push(skb, outer_hlen);
> +               skb_reset_mac_header(skb);
> +               skb_set_network_header(skb, mac_len);
> +               skb_set_transport_header(skb, udp_offset);
> +               uh = udp_hdr(skb);
> +               uh->len = htons(skb->len - udp_offset);
> +
> +               /* csum segment if tunnel sets skb with csum. */
> +               if (unlikely(uh->check)) {
> +                       struct ipv6hdr *iph = ipv6_hdr(skb);
> +
> +                       uh->check = csum_ipv6_magic(&iph->saddr, &iph->daddr,
> +                                                      skb->len - udp_offset,
> +                                                      IPPROTO_UDP, 0);
> +                       if (uh->check == 0)
> +                               uh->check = CSUM_MANGLED_0;
> +
> +               }
> +               skb->ip_summed = CHECKSUM_NONE;
> +       } while ((skb = skb->next));
> +out:
> +       return segs;
> +}
> +
skb_udp6_tunnel_segment() looks alot like skb_udp_tunnel_segment(),
difference is checksum calculation. I think we can write a common
function here.

>  static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
> -       netdev_features_t features)
> +                                        netdev_features_t features)
>  {
>         struct sk_buff *segs = ERR_PTR(-EINVAL);
>         unsigned int mss;
> @@ -73,43 +128,47 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
>                 goto out;
>         }
>
> -       /* Do software UFO. Complete and fill in the UDP checksum as HW cannot
> -        * do checksum of UDP packets sent as multiple IP fragments.
> -        */
> -       offset = skb_checksum_start_offset(skb);
> -       csum = skb_checksum(skb, offset, skb->len - offset, 0);
> -       offset += skb->csum_offset;
> -       *(__sum16 *)(skb->data + offset) = csum_fold(csum);
> -       skb->ip_summed = CHECKSUM_NONE;
> -
> -       /* Check if there is enough headroom to insert fragment header. */
> -       if ((skb_mac_header(skb) < skb->head + frag_hdr_sz) &&
> -           pskb_expand_head(skb, frag_hdr_sz, 0, GFP_ATOMIC))
> -               goto out;
> +       if (skb->encapsulation && skb_shinfo(skb)->gso_type & SKB_GSO_UDP_TUNNEL)
> +               segs = skb_udp6_tunnel_segment(skb, features);
> +       else {
> +               /* Do software UFO. Complete and fill in the UDP checksum as HW cannot
> +                * do checksum of UDP packets sent as multiple IP fragments.
> +                */
> +               offset = skb_checksum_start_offset(skb);
> +               csum = skb_checksum(skb, offset, skb->len - offset, 0);
> +               offset += skb->csum_offset;
> +               *(__sum16 *)(skb->data + offset) = csum_fold(csum);
> +               skb->ip_summed = CHECKSUM_NONE;
> +
> +               /* Check if there is enough headroom to insert fragment header. */
> +               if ((skb_mac_header(skb) < skb->head + frag_hdr_sz) &&
> +                   pskb_expand_head(skb, frag_hdr_sz, 0, GFP_ATOMIC))
> +                       goto out;
>
> -       /* Find the unfragmentable header and shift it left by frag_hdr_sz
> -        * bytes to insert fragment header.
> -        */
> -       unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
> -       nexthdr = *prevhdr;
> -       *prevhdr = NEXTHDR_FRAGMENT;
> -       unfrag_len = skb_network_header(skb) - skb_mac_header(skb) +
> -                    unfrag_ip6hlen;
> -       mac_start = skb_mac_header(skb);
> -       memmove(mac_start-frag_hdr_sz, mac_start, unfrag_len);
> -
> -       skb->mac_header -= frag_hdr_sz;
> -       skb->network_header -= frag_hdr_sz;
> -
> -       fptr = (struct frag_hdr *)(skb_network_header(skb) + unfrag_ip6hlen);
> -       fptr->nexthdr = nexthdr;
> -       fptr->reserved = 0;
> -       ipv6_select_ident(fptr, (struct rt6_info *)skb_dst(skb));
> -
> -       /* Fragment the skb. ipv6 header and the remaining fields of the
> -        * fragment header are updated in ipv6_gso_segment()
> -        */
> -       segs = skb_segment(skb, features);
> +               /* Find the unfragmentable header and shift it left by frag_hdr_sz
> +                * bytes to insert fragment header.
> +                */
> +               unfrag_ip6hlen = ip6_find_1stfragopt(skb, &prevhdr);
> +               nexthdr = *prevhdr;
> +               *prevhdr = NEXTHDR_FRAGMENT;
> +               unfrag_len = skb_network_header(skb) - skb_mac_header(skb) +
> +                            unfrag_ip6hlen;
> +               mac_start = skb_mac_header(skb);
> +               memmove(mac_start-frag_hdr_sz, mac_start, unfrag_len);
> +
> +               skb->mac_header -= frag_hdr_sz;
> +               skb->network_header -= frag_hdr_sz;
> +
> +               fptr = (struct frag_hdr *)(skb_network_header(skb) + unfrag_ip6hlen);
> +               fptr->nexthdr = nexthdr;
> +               fptr->reserved = 0;
> +               ipv6_select_ident(fptr, (struct rt6_info *)skb_dst(skb));
> +
> +               /* Fragment the skb. ipv6 header and the remaining fields of the
> +                * fragment header are updated in ipv6_gso_segment()
> +                */
> +               segs = skb_segment(skb, features);
> +       }
>
>  out:
>         return segs;
> --
> 1.7.7.6
>
