From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2 net-next] ifb: support more features
Date: Mon, 9 May 2016 10:22:17 -0700
Message-ID: <CAKgT0UffTCeUn5jqFYNqtE6g25sdcAvT6hLNG1F=0BKRWd-xWA@mail.gmail.com>
References: <1462578076.13075.63.camel@edumazet-glaptop3.roam.corp.google.com>
	<1462583999.13075.67.camel@edumazet-glaptop3.roam.corp.google.com>
	<1462686072.23934.4.camel@edumazet-glaptop3.roam.corp.google.com>
	<1462723712.23934.18.camel@edumazet-glaptop3.roam.corp.google.com>
	<1462728942.23934.23.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:37211 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbcEIRWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 13:22:18 -0400
Received: by mail-ig0-f171.google.com with SMTP id s8so97518175ign.0
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 10:22:18 -0700 (PDT)
In-Reply-To: <1462728942.23934.23.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 8, 2016 at 10:35 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2016-05-08 at 09:08 -0700, Eric Dumazet wrote:
>
>
>> So we probably need to make sure the network header is properly set for
>> the segments. Then skb_reset_mac_len(nskb); would work as intended.
>>
>> Since skb_segment() is called from the deepest point in GSO path,
>> it always see the inner network header.
>>
>> Sounds like skb_reset_network_header() calls done in inet_gso_segment()
>> and ipv6_gso_segment() should only be done for the outer header, (when
>> SKB_GSO_CB(skb)->encap_level == 0), or even better, only done in
>> skb_mac_gso_segment()
>>
>> Then we need to use the proper (inner) network header in
>> tcp4_gso_segment() and tcp6_gso_segment(), as they currently use
>> ip_hdr() and ipv6_hdr()
>>
>
> Prototype patch works for me (but GRE/UDP offloads might need some
> work), and would even save few cycles...
>
> Unfortunately GSO for GRE/UDP is kind of mess.

I agree.  I have been trying to work on cleaning it up but it is
taking a while to get it all sorted out.

>  net/core/dev.c           |    1 +
>  net/ipv4/af_inet.c       |    9 +++------
>  net/ipv4/tcp_offload.c   |    2 +-
>  net/ipv6/ip6_offload.c   |    9 +++------
>  net/ipv6/tcpv6_offload.c |    2 +-
>  5 files changed, 9 insertions(+), 14 deletions(-)
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 5c925ac50b95..3a9035ec862b 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2658,6 +2658,7 @@ struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
>                 return ERR_PTR(-EINVAL);
>
>         __skb_pull(skb, vlan_depth);
> +       skb_reset_network_header(skb);
>
>         rcu_read_lock();
>         list_for_each_entry_rcu(ptype, &offload_base, list) {

I'm pretty sure just dropping it in here isn't going to fix much since
this gets called by all the tunnel types that support transparent
Ethernet bridging.

> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 9e481992dbae..fef6335a75bc 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1220,12 +1220,12 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>                        0)))
>                 goto out;
>
> -       skb_reset_network_header(skb);
> -       nhoff = skb_network_header(skb) - skb_mac_header(skb);
> +       skb_reset_inner_network_header(skb);
> +       nhoff = skb->data - skb_mac_header(skb);
>         if (unlikely(!pskb_may_pull(skb, sizeof(*iph))))
>                 goto out;
>
> -       iph = ip_hdr(skb);
> +       iph = inner_ip_hdr(skb);
>         ihl = iph->ihl * 4;
>         if (ihl < sizeof(*iph))
>                 goto out;

One thought that just occurred to me based on this would be to
configure inner headers on the way up, and to configure the outer
headers on the way down.  Then that way we could go through and be
guaranteed that the inner headers represent the inner most set of
header offsets, and the outer ones represent the outer-most set
regardless of the total number of headers present and there would be
no need to call into the reset_headers function since all the headers
would already be set.

I was also looking at possibly dropping the inner transport offset as
from what I can tell it and the csum_offset should always be the same
value since csum_offset will always point to the inner transport
header when any kind of offload is enabled which is the criteria for
skb->encapsulation being set anyway.
