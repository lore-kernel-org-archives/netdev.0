From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 06/10] gre: Use GSO flags to determine csum need
 instead of GRE flags
Date: Sun, 7 Feb 2016 04:06:35 -0600
Message-ID: <CAKgT0UfXzsbXvjuqD0qNKbbDnF6KvxLTPacU0qXeUSFnp7XgkA@mail.gmail.com>
References: <20160205232109.18529.99816.stgit@localhost.localdomain>
	<20160205232801.18529.33991.stgit@localhost.localdomain>
	<CALx6S35-tZ=bORACiSdrMbmzGaBbcetGeQ4fdj+hkTJzZS4HpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Edward Cree <ecree@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f193.google.com ([209.85.213.193]:33137 "EHLO
	mail-ig0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753485AbcBGKGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 05:06:36 -0500
Received: by mail-ig0-f193.google.com with SMTP id hb3so3414832igb.0
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 02:06:35 -0800 (PST)
In-Reply-To: <CALx6S35-tZ=bORACiSdrMbmzGaBbcetGeQ4fdj+hkTJzZS4HpQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 6, 2016 at 2:52 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Fri, Feb 5, 2016 at 3:28 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>> This patch updates the gre checksum path to follow something much closer to
>> the UDP checksum path.  By doing this we can avoid needing to do as much
>> header inspection and can just make use of the fields we were already
>> reading in the sk_buff structure.
>>
>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>> ---
>>  net/ipv4/gre_offload.c |   64 +++++++++++++++++++++++-------------------------
>>  1 file changed, 30 insertions(+), 34 deletions(-)
>>
>> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
>> index 35a8dd35ed4e..c15441b5ff61 100644
>> --- a/net/ipv4/gre_offload.c
>> +++ b/net/ipv4/gre_offload.c
>> @@ -18,14 +18,14 @@
>>  static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>>                                        netdev_features_t features)
>>  {
>> +       int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
>>         struct sk_buff *segs = ERR_PTR(-EINVAL);
>> -       int ghl;
>>         struct gre_base_hdr *greh;
>>         u16 mac_offset = skb->mac_header;
>> -       int mac_len = skb->mac_len;
>>         __be16 protocol = skb->protocol;
>> -       int tnl_hlen;
>> -       bool csum;
>> +       u16 mac_len = skb->mac_len;
>> +       int gre_offset, outer_hlen;
>> +       bool need_csum;
>>
>>         if (unlikely(skb_shinfo(skb)->gso_type &
>>                                 ~(SKB_GSO_TCPV4 |
>> @@ -42,64 +42,60 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>>         if (!skb->encapsulation)
>>                 goto out;
>>
>> -       if (unlikely(!pskb_may_pull(skb, sizeof(*greh))))
>> +       if (unlikely(tnl_hlen < sizeof(struct gre_base_hdr)))
>>                 goto out;
>>
>> -       greh = (struct gre_base_hdr *)skb_transport_header(skb);
>> -
>> -       ghl = skb_inner_mac_header(skb) - skb_transport_header(skb);
>> -       if (unlikely(ghl < sizeof(*greh)))
>> +       if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
>>                 goto out;
>>
>> -       csum = !!(greh->flags & GRE_CSUM);
>> -       if (csum)
>> -               skb->encap_hdr_csum = 1;
>> +       greh = (struct gre_base_hdr *)skb_transport_header(skb);
>>
>>         /* setup inner skb. */
>>         skb->protocol = greh->protocol;
>>         skb->encapsulation = 0;
>> -
>> -       if (unlikely(!pskb_may_pull(skb, ghl)))
>> -               goto out;
>> -
>> -       __skb_pull(skb, ghl);
>> +       __skb_pull(skb, tnl_hlen);
>>         skb_reset_mac_header(skb);
>>         skb_set_network_header(skb, skb_inner_network_offset(skb));
>>         skb->mac_len = skb_inner_network_offset(skb);
>>
>> +       need_csum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_GRE_CSUM);
>
> Should we do a WARN_ON(need_csum && !(greh->flags & GRE_CSUM)) just to
> be conservative?
>

We could but what would be the point?

If there is an issue like that present in the kernel we should
probably fix it in build_header in ip_gre.c instead of trying to push
validation for the case into the GSO code.

- Alex
