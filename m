From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 4/4] udp: Move udp_tunnel_segment into udp_offload.c
Date: Mon, 14 Jul 2014 12:14:50 -0700
Message-ID: <CA+mtBx-Gs67dj9fJhZ74S3eRWt9ODqdj1ETjOPxbU51yZSMtGw@mail.gmail.com>
References: <alpine.DEB.2.02.1407131940460.24734@tomh.mtv.corp.google.com>
	<53C36267.8030404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:55296 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433AbaGNTOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 15:14:51 -0400
Received: by mail-ie0-f179.google.com with SMTP id rl12so2255788iec.24
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 12:14:50 -0700 (PDT)
In-Reply-To: <53C36267.8030404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 13, 2014 at 9:53 PM, Varka Bhadram <varkabhadram@gmail.com> wrote:
> On 07/14/2014 08:19 AM, Tom Herbert wrote:
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>>   net/ipv4/udp.c         | 76
>> --------------------------------------------------
>>   net/ipv4/udp_offload.c | 76
>> ++++++++++++++++++++++++++++++++++++++++++++++++++
>>   2 files changed, 76 insertions(+), 76 deletions(-)
>>
>> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
>> index ac30e10..f6dfe52 100644
>> --- a/net/ipv4/udp.c
>> +++ b/net/ipv4/udp.c
>> @@ -2522,79 +2522,3 @@ void __init udp_init(void)
>>         sysctl_udp_rmem_min = SK_MEM_QUANTUM;
>>         sysctl_udp_wmem_min = SK_MEM_QUANTUM;
>>   }
>> -
>> -struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
>> -                                      netdev_features_t features)
>> -{
>> -       struct sk_buff *segs = ERR_PTR(-EINVAL);
>> -       u16 mac_offset = skb->mac_header;
>> -       int mac_len = skb->mac_len;
>> -       int tnl_hlen = skb_inner_mac_header(skb) -
>> skb_transport_header(skb);
>> -       __be16 protocol = skb->protocol;
>> -       netdev_features_t enc_features;
>> -       int udp_offset, outer_hlen;
>> -       unsigned int oldlen;
>> -       bool need_csum;
>> -
>> -       oldlen = (u16)~skb->len;
>> -
>> -       if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
>> -               goto out;
>> -
>> -       skb->encapsulation = 0;
>> -       __skb_pull(skb, tnl_hlen);
>> -       skb_reset_mac_header(skb);
>> -       skb_set_network_header(skb, skb_inner_network_offset(skb));
>> -       skb->mac_len = skb_inner_network_offset(skb);
>> -       skb->protocol = htons(ETH_P_TEB);
>> -
>> -       need_csum = !!(skb_shinfo(skb)->gso_type &
>> SKB_GSO_UDP_TUNNEL_CSUM);
>> -       if (need_csum)
>> -               skb->encap_hdr_csum = 1;
>> -
>> -       /* segment inner packet. */
>> -       enc_features = skb->dev->hw_enc_features &
>> netif_skb_features(skb);
>> -       segs = skb_mac_gso_segment(skb, enc_features);
>> -       if (!segs || IS_ERR(segs)) {
>> -               skb_gso_error_unwind(skb, protocol, tnl_hlen, mac_offset,
>> -                                    mac_len);
>> -               goto out;
>> -       }
>> -
>> -       outer_hlen = skb_tnl_header_len(skb);
>> -       udp_offset = outer_hlen - tnl_hlen;
>> -       skb = segs;
>> -       do {
>> -               struct udphdr *uh;
>> -               int len;
>> -
>> -               skb_reset_inner_headers(skb);
>> -               skb->encapsulation = 1;
>> -
>> -               skb->mac_len = mac_len;
>> -
>> -               skb_push(skb, outer_hlen);
>> -               skb_reset_mac_header(skb);
>> -               skb_set_network_header(skb, mac_len);
>> -               skb_set_transport_header(skb, udp_offset);
>> -               len = skb->len - udp_offset;
>> -               uh = udp_hdr(skb);
>> -               uh->len = htons(len);
>> -
>> -               if (need_csum) {
>> -                       __be32 delta = htonl(oldlen + len);
>> -
>> -                       uh->check = ~csum_fold((__force __wsum)
>> -                                              ((__force u32)uh->check +
>> -                                               (__force u32)delta));
>> -                       uh->check = gso_make_checksum(skb, ~uh->check);
>> -
>> -                       if (uh->check == 0)
>> -                               uh->check = CSUM_MANGLED_0;
>> -               }
>> -
>> -               skb->protocol = protocol;
>> -       } while ((skb = skb->next));
>> -out:
>> -       return segs;
>> -}
>> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
>> index 546d2d4..4807544 100644
>> --- a/net/ipv4/udp_offload.c
>> +++ b/net/ipv4/udp_offload.c
>> @@ -47,6 +47,82 @@ static int udp4_ufo_send_check(struct sk_buff *skb)
>>         return 0;
>>   }
>>   +struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
>> +                                      netdev_features_t features)
>> +{
>> +       struct sk_buff *segs = ERR_PTR(-EINVAL);
>> +       u16 mac_offset = skb->mac_header;
>> +       int mac_len = skb->mac_len;
>
>
> skb->mac_len is u16... But we are storing in int...?
>
It's just a local variable (mac_len) so it should be inconsequential.
It's be used as an int argument in skb_gso_error_unwind and
skb_set_network_header so it's just a matter of where the implicit
cast is done.

>
>> +       int tnl_hlen = skb_inner_mac_header(skb) -
>> skb_transport_header(skb);
>> +       __be16 protocol = skb->protocol;
>> +       netdev_features_t enc_features;
>> +       int udp_offset, outer_hlen;
>> +       unsigned int oldlen;
>> +       bool need_csum;
>> +
>> +       oldlen = (u16)~skb->len;
>> +
>> +       if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
>> +               goto out;
>> +
>> +       skb->encapsulation = 0;
>> +       __skb_pull(skb, tnl_hlen);
>> +       skb_reset_mac_header(skb);
>> +       skb_set_network_header(skb, skb_inner_network_offset(skb));
>> +       skb->mac_len = skb_inner_network_offset(skb);
>> +       skb->protocol = htons(ETH_P_TEB);
>> +
>> +       need_csum = !!(skb_shinfo(skb)->gso_type &
>> SKB_GSO_UDP_TUNNEL_CSUM);
>> +       if (need_csum)
>> +               skb->encap_hdr_csum = 1;
>> +
>> +       /* segment inner packet. */
>> +       enc_features = skb->dev->hw_enc_features &
>> netif_skb_features(skb);
>> +       segs = skb_mac_gso_segment(skb, enc_features);
>> +       if (!segs || IS_ERR(segs)) {
>> +               skb_gso_error_unwind(skb, protocol, tnl_hlen, mac_offset,
>> +                                    mac_len);
>> +               goto out;
>> +       }
>> +
>> +       outer_hlen = skb_tnl_header_len(skb);
>> +       udp_offset = outer_hlen - tnl_hlen;
>> +       skb = segs;
>> +       do {
>> +               struct udphdr *uh;
>> +               int len;
>> +
>> +               skb_reset_inner_headers(skb);
>> +               skb->encapsulation = 1;
>> +
>> +               skb->mac_len = mac_len;
>> +
>> +               skb_push(skb, outer_hlen);
>> +               skb_reset_mac_header(skb);
>> +               skb_set_network_header(skb, mac_len);
>> +               skb_set_transport_header(skb, udp_offset);
>> +               len = skb->len - udp_offset;
>> +               uh = udp_hdr(skb);
>> +               uh->len = htons(len);
>> +
>> +               if (need_csum) {
>> +                       __be32 delta = htonl(oldlen + len);
>> +
>> +                       uh->check = ~csum_fold((__force __wsum)
>> +                                              ((__force u32)uh->check +
>> +                                               (__force u32)delta));
>> +                       uh->check = gso_make_checksum(skb, ~uh->check);
>> +
>> +                       if (uh->check == 0)
>> +                               uh->check = CSUM_MANGLED_0;
>> +               }
>> +
>> +               skb->protocol = protocol;
>> +       } while ((skb = skb->next));
>> +out:
>> +       return segs;
>> +}
>> +
>>   static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
>>                                          netdev_features_t features)
>>   {
>
>
>
> --
> Regards,
> Varka Bhadram.
>
