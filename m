From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] skbuff: ensure to reset dev in skb_scrub_packet()
Date: Fri, 19 Jul 2013 14:50:21 -0700
Message-ID: <CALnjE+pPUo8zvDHPKKd9mD-jKvgUd=krkt4UnFF06rKVsHPvgg@mail.gmail.com>
References: <1374244891-7030-1-git-send-email-nicolas.dichtel@6wind.com>
	<CALnjE+oTa95w+LQVEdXS+VCbBAafbG8TVmrZmoXTci2DnjA4FA@mail.gmail.com>
	<51E9A441.8010609@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:52244 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750942Ab3GSVuV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jul 2013 17:50:21 -0400
Received: by mail-qa0-f51.google.com with SMTP id f14so156977qak.3
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 14:50:21 -0700 (PDT)
In-Reply-To: <51E9A441.8010609@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 19, 2013 at 1:40 PM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Le 19/07/2013 20:21, Pravin Shelar a =E9crit :
>
>> On Fri, Jul 19, 2013 at 7:41 AM, Nicolas Dichtel
>> <nicolas.dichtel@6wind.com> wrote:
>>>
>>> Because this function is used to scrub a packet when it cross netns=
, we
>>> must
>>> ensure that skb->dev points to the new netns.
>>>
>>> This was done by eth_type_trans() in dev_forward_skb(), but it's al=
so
>>> needed
>>> for ip tunnels.
>>>
>>> I take the opportunity to move the call of skb_scrub_packet() after
>>> eth_type_trans(), to be sure that pkt_type is set to PACKET_HOST.
>>>
>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>> ---
>>>   include/linux/skbuff.h | 3 ++-
>>>   net/core/dev.c         | 6 +++---
>>>   net/core/skbuff.c      | 3 ++-
>>>   net/ipv4/ip_tunnel.c   | 9 +++++----
>>>   net/ipv6/sit.c         | 4 ++--
>>>   5 files changed, 14 insertions(+), 11 deletions(-)
>>>
>>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>>> index 5afefa01a13c..620ecce0a717 100644
>>> --- a/include/linux/skbuff.h
>>> +++ b/include/linux/skbuff.h
>>> @@ -2385,7 +2385,8 @@ extern void              skb_split(struct sk_=
buff
>>> *skb,
>>>                                   struct sk_buff *skb1, const u32 l=
en);
>>>   extern int            skb_shift(struct sk_buff *tgt, struct sk_bu=
ff
>>> *skb,
>>>                                   int shiftlen);
>>> -extern void           skb_scrub_packet(struct sk_buff *skb);
>>> +extern void           skb_scrub_packet(struct sk_buff *skb,
>>> +                                       struct net_device *dev);
>>>
>>>   extern struct sk_buff *skb_segment(struct sk_buff *skb,
>>>                                     netdev_features_t features);
>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>> index 26755dd40daa..6f789b99331b 100644
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>>> @@ -1691,13 +1691,13 @@ int dev_forward_skb(struct net_device *dev,
>>> struct sk_buff *skb)
>>>                  kfree_skb(skb);
>>>                  return NET_RX_DROP;
>>>          }
>>> -       skb_scrub_packet(skb);
>>>          skb->protocol =3D eth_type_trans(skb, dev);
>>>
>>>          /* eth_type_trans() can set pkt_type.
>>> -        * clear pkt_type _after_ calling eth_type_trans()
>>> +        * call skb_scrub_packet() after it to clear pkt_type _afte=
r_
>>> calling
>>> +        * eth_type_trans().
>>>           */
>>> -       skb->pkt_type =3D PACKET_HOST;
>>> +       skb_scrub_packet(skb, dev);
>>>
>>>          return netif_rx(skb);
>>>   }
>>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>>> index 20e02d2605ec..5f4701f89af8 100644
>>> --- a/net/core/skbuff.c
>>> +++ b/net/core/skbuff.c
>>> @@ -3507,13 +3507,14 @@ EXPORT_SYMBOL(skb_try_coalesce);
>>>    * another namespace. We have to clear all information in the skb=
 that
>>>    * could impact namespace isolation.
>>>    */
>>> -void skb_scrub_packet(struct sk_buff *skb)
>>> +void skb_scrub_packet(struct sk_buff *skb, struct net_device *dev)
>>>   {
>>>          skb_orphan(skb);
>>>          skb->tstamp.tv64 =3D 0;
>>>          skb->pkt_type =3D PACKET_HOST;
>>>          skb->skb_iif =3D 0;
>>>          skb_dst_drop(skb);
>>> +       skb->dev =3D dev;
>>>          skb->mark =3D 0;
>>>          secpath_reset(skb);
>>>          nf_reset(skb);
>>> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
>>> index ca1cb2d5f6e2..2e88321c7f23 100644
>>> --- a/net/ipv4/ip_tunnel.c
>>> +++ b/net/ipv4/ip_tunnel.c
>>> @@ -454,15 +454,16 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, s=
truct
>>> sk_buff *skb,
>>>          tstats->rx_bytes +=3D skb->len;
>>>          u64_stats_update_end(&tstats->syncp);
>>>
>>> -       if (tunnel->net !=3D dev_net(tunnel->dev))
>>> -               skb_scrub_packet(skb);
>>> -
>>>          if (tunnel->dev->type =3D=3D ARPHRD_ETHER) {
>>>                  skb->protocol =3D eth_type_trans(skb, tunnel->dev)=
;
>>>                  skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
>>>          } else {
>>>                  skb->dev =3D tunnel->dev;
>>>          }
>>> +
>>> +       if (tunnel->net !=3D dev_net(tunnel->dev))
>>> +               skb_scrub_packet(skb, tunnel->dev);
>>> +
>>
>>
>> It is done in ip_tunnels right above the statement. Where exactly ar=
e
>> we missing skb->dev set to tunnel->dev?
>
> On the xmit path, ipip6_tunnel_xmit() for example.

This functions calls iptunnel_xmit(), which will finally calls
ip_output() which does same assignment for every case. How is that
different than assigning it in skb_scrub_packet()?

>
> And note also, that skb_scrub_packet() is used for netns crossing, he=
nce
> this function should be complete and must not leave some field with p=
ointer
> to the previous netns.
