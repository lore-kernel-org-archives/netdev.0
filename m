From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 7/8] net: ip_tunnel: remove 'csum_help' argument
 to iptunnel_handle_offloads
Date: Fri, 8 Jan 2016 18:05:16 -0800
Message-ID: <CAKgT0UeZwSm4oKoydXWU3iWmjL5m6H=K=hJ2wAkp_GugbZJwjA@mail.gmail.com>
References: <56901197.8040808@solarflare.com>
	<56901244.8060809@solarflare.com>
	<CAKgT0UdQzW2+n7S3YOhAJVZY-q5bjYaQB0jDn7AD3zp2ZrkGZg@mail.gmail.com>
	<CALx6S34MRoLw_JiHuyDANwoF9+u7k9R-UDb_RGP+L-d9D=f3WQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:35796 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754150AbcAICFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 21:05:17 -0500
Received: by mail-ig0-f195.google.com with SMTP id mw1so8903174igb.2
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 18:05:17 -0800 (PST)
In-Reply-To: <CALx6S34MRoLw_JiHuyDANwoF9+u7k9R-UDb_RGP+L-d9D=f3WQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 8, 2016 at 4:44 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Fri, Jan 8, 2016 at 4:35 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Fri, Jan 8, 2016 at 11:47 AM, Edward Cree <ecree@solarflare.com> wrote:
>>> All users now pass false, so we can remove it, and remove the code that
>>>  was conditional upon it.
>>>
>>> Signed-off-by: Edward Cree <ecree@solarflare.com>
>>> ---
>>>  drivers/net/vxlan.c             |  4 ++--
>>>  include/net/ip_tunnels.h        |  3 +--
>>>  include/net/udp_tunnel.h        |  3 +--
>>>  net/ipv4/fou.c                  |  4 ++--
>>>  net/ipv4/ip_gre.c               |  3 +--
>>>  net/ipv4/ip_tunnel_core.c       | 15 +--------------
>>>  net/ipv4/ipip.c                 |  2 +-
>>>  net/ipv6/sit.c                  |  4 ++--
>>>  net/netfilter/ipvs/ip_vs_xmit.c |  6 ++----
>>>  9 files changed, 13 insertions(+), 31 deletions(-)
>>>
>>
>>
>>> diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
>>> index 1db8418..f98bd53 100644
>>> --- a/net/ipv4/ip_tunnel_core.c
>>> +++ b/net/ipv4/ip_tunnel_core.c
>>> @@ -147,7 +147,6 @@ struct metadata_dst *iptunnel_metadata_reply(struct metadata_dst *md,
>>>  EXPORT_SYMBOL_GPL(iptunnel_metadata_reply);
>>>
>>>  struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb,
>>> -                                        bool csum_help,
>>>                                          int gso_type_mask)
>>>  {
>>>         int err;
>>> @@ -165,19 +164,7 @@ struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb,
>>>                 return skb;
>>>         }
>>>
>>> -       /* If packet is not gso and we are resolving any partial checksum,
>>> -        * clear encapsulation flag. This allows setting CHECKSUM_PARTIAL
>>> -        * on the outer header without confusing devices that implement
>>> -        * NETIF_F_IP_CSUM with encapsulation.
>>> -        */
>>> -       if (csum_help)
>>> -               skb->encapsulation = 0;
>>> -
>>> -       if (skb->ip_summed == CHECKSUM_PARTIAL && csum_help) {
>>> -               err = skb_checksum_help(skb);
>>> -               if (unlikely(err))
>>> -                       goto error;
>>> -       } else if (skb->ip_summed != CHECKSUM_PARTIAL)
>>> +       if (skb->ip_summed != CHECKSUM_PARTIAL)
>>>                 skb->ip_summed = CHECKSUM_NONE;
>>>
>>
>> So this patch is a bit broken here.  We should be clearing
>> skb->encapsulation if CHECKSUM_PARTIAL is not set.  That way we don't
>> incorrectly pull in the inner headers when computing the outer
>> checksum.
>>
> In the original code this is done in csum_help argument is true in
> iptunnel_handle_offloads. These patches essentially imply that
> csum_help would always be false so we shouldn't need to clear
> skb->encapsulation any more?

Actually it is causing me to throw warnings on an ixgbe NIC because it
implies that we want to offload the inner checksum, but we are setting
things up to offload the outer checksum.  For example if the inner is
just an ARP or ICMP frame I don't need to checksum the inner headers,
but skb->encapsulation is still set so the inner headers are being
evaluated instead of the outer ones in the Tx checksum routine in the
driver.

If we clear skb->encapsulation if we don't have CHECKSUM_PARTIAL set
then we don't have the issue.  Really the addition of the line
clearing skb->encapsulation should probably be added to the first
patch so that we don't leave skb->encapsulation set when we aren't
requesting offloads.

- Alex
