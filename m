From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 07/10] gre: Use inner_proto to obtain inner
 header protocol
Date: Sun, 7 Feb 2016 04:11:09 -0600
Message-ID: <CAKgT0UcCCEKC7Gn2CqOR0i9O62NE7gV_w0dMmzbcrf9s2d5Adw@mail.gmail.com>
References: <20160205232109.18529.99816.stgit@localhost.localdomain>
	<20160205232807.18529.87448.stgit@localhost.localdomain>
	<CALx6S350PdxM7UxmT9ByKGAUN-8s=hujmx93U8a06gme9cn36A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Edward Cree <ecree@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33690 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574AbcBGKLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 05:11:10 -0500
Received: by mail-io0-f193.google.com with SMTP id f81so8351245iof.0
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 02:11:09 -0800 (PST)
In-Reply-To: <CALx6S350PdxM7UxmT9ByKGAUN-8s=hujmx93U8a06gme9cn36A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 6, 2016 at 2:55 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Fri, Feb 5, 2016 at 3:28 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>> Instead of parsing headers to determine the inner protocol we can just pull
>> the value from inner_proto.
>>
>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>> ---
>>  net/ipv4/gre_offload.c |    6 ++----
>>  1 file changed, 2 insertions(+), 4 deletions(-)
>>
>> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
>> index c15441b5ff61..003b0ebbcfdd 100644
>> --- a/net/ipv4/gre_offload.c
>> +++ b/net/ipv4/gre_offload.c
>> @@ -20,7 +20,6 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>>  {
>>         int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
>>         struct sk_buff *segs = ERR_PTR(-EINVAL);
>> -       struct gre_base_hdr *greh;
>>         u16 mac_offset = skb->mac_header;
>>         __be16 protocol = skb->protocol;
>>         u16 mac_len = skb->mac_len;
>> @@ -48,15 +47,13 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>>         if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
>>                 goto out;
>>
>> -       greh = (struct gre_base_hdr *)skb_transport_header(skb);
>> -
>>         /* setup inner skb. */
>> -       skb->protocol = greh->protocol;
>>         skb->encapsulation = 0;
>>         __skb_pull(skb, tnl_hlen);
>>         skb_reset_mac_header(skb);
>>         skb_set_network_header(skb, skb_inner_network_offset(skb));
>>         skb->mac_len = skb_inner_network_offset(skb);
>> +       skb->protocol = skb->inner_protocol;
>
> Is this going to be a problem if we try to perform GSO with nested
> encapsulations? (I suppose that's something not supported).

Right tunnels don't offload tunnels so there is no need to worry about
a tunnel nested in a tunnel.  We might get there someday, but I don't
see it happening any time soon because we would end up likely needing
yet another level of header pointers for middle mac, network, and
transport in such a case.

- Alex
