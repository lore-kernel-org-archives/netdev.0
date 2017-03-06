From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 1/2] flow_dissecror: Move ARP dissection
 into a separate function
Date: Mon, 6 Mar 2017 16:49:04 +0100
Message-ID: <20170306154904.GF1822@nanopsycho.orion>
References: <20170221143141.GD2694@nanopsycho.mtl.com>
 <1487687599-5464-1-git-send-email-jiri@resnulli.us>
 <CALx6S376rJOErGA=OC4UBSQKNZEE1Ape4=9w7p8T+Td8DzajdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        mlxsw@mellanox.com
To: Tom Herbert <tom@herbertland.com>, simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35535 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753523AbdCFPuP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 10:50:15 -0500
Received: by mail-wm0-f66.google.com with SMTP id z63so12233978wmg.2
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 07:49:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALx6S376rJOErGA=OC4UBSQKNZEE1Ape4=9w7p8T+Td8DzajdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 21, 2017 at 07:50:53PM CET, tom@herbertland.com wrote:
>On Tue, Feb 21, 2017 at 6:33 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> Make the main flow_dissect function a bit smaller and move the ARP
>> dissection into a separate function. Along with that, do the ARP header
>> processing only in case the flow dissection user requires it.
>>
>
>Acked-by: Tom Herbert <tom@herbertland.com>
>
>GRE might also be a good candidate to get its own function.
>

Submitted with GRE bits. Note that I left you ack and Simon's revby out
since I did some cosmetic changes until rfc.

I would be glad if you both can check it again.

Thanks!


>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  net/core/flow_dissector.c | 111 ++++++++++++++++++++++++----------------------
>>  1 file changed, 59 insertions(+), 52 deletions(-)
>>
>> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>> index c35aae1..10dc5bb 100644
>> --- a/net/core/flow_dissector.c
>> +++ b/net/core/flow_dissector.c
>> @@ -113,6 +113,61 @@ __be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
>>  }
>>  EXPORT_SYMBOL(__skb_flow_get_ports);
>>
>> +static bool __skb_flow_dissect_arp(const struct sk_buff *skb,
>> +                                  struct flow_dissector *flow_dissector,
>> +                                  void *target_container, void *data,
>> +                                  int nhoff, int hlen)
>> +{
>> +       struct flow_dissector_key_arp *key_arp;
>> +       struct {
>> +               unsigned char ar_sha[ETH_ALEN];
>> +               unsigned char ar_sip[4];
>> +               unsigned char ar_tha[ETH_ALEN];
>> +               unsigned char ar_tip[4];
>> +       } *arp_eth, _arp_eth;
>> +       const struct arphdr *arp;
>> +       struct arphdr *_arp;
>> +
>> +       if (!dissector_uses_key(flow_dissector, FLOW_DISSECTOR_KEY_ARP))
>> +               return true;
>> +
>> +       arp = __skb_header_pointer(skb, nhoff, sizeof(_arp), data,
>> +                                  hlen, &_arp);
>> +       if (!arp)
>> +               return false;
>> +
>> +       if (arp->ar_hrd != htons(ARPHRD_ETHER) ||
>> +           arp->ar_pro != htons(ETH_P_IP) ||
>> +           arp->ar_hln != ETH_ALEN ||
>> +           arp->ar_pln != 4 ||
>> +           (arp->ar_op != htons(ARPOP_REPLY) &&
>> +            arp->ar_op != htons(ARPOP_REQUEST)))
>> +               return false;
>> +
>> +       arp_eth = __skb_header_pointer(skb, nhoff + sizeof(_arp),
>> +                                      sizeof(_arp_eth), data,
>> +                                      hlen, &_arp_eth);
>> +       if (!arp_eth)
>> +               return false;
>> +
>> +       key_arp = skb_flow_dissector_target(flow_dissector,
>> +                                           FLOW_DISSECTOR_KEY_ARP,
>> +                                           target_container);
>> +
>> +       memcpy(&key_arp->sip, arp_eth->ar_sip, sizeof(key_arp->sip));
>> +       memcpy(&key_arp->tip, arp_eth->ar_tip, sizeof(key_arp->tip));
>> +
>> +       /* Only store the lower byte of the opcode;
>> +        * this covers ARPOP_REPLY and ARPOP_REQUEST.
>> +        */
>> +       key_arp->op = ntohs(arp->ar_op) & 0xff;
>> +
>> +       ether_addr_copy(key_arp->sha, arp_eth->ar_sha);
>> +       ether_addr_copy(key_arp->tha, arp_eth->ar_tha);
>> +
>> +       return true;
>> +}
>> +
>>  /**
>>   * __skb_flow_dissect - extract the flow_keys struct and return it
>>   * @skb: sk_buff to extract the flow from, can be NULL if the rest are specified
>> @@ -138,7 +193,6 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
>>         struct flow_dissector_key_control *key_control;
>>         struct flow_dissector_key_basic *key_basic;
>>         struct flow_dissector_key_addrs *key_addrs;
>> -       struct flow_dissector_key_arp *key_arp;
>>         struct flow_dissector_key_ports *key_ports;
>>         struct flow_dissector_key_icmp *key_icmp;
>>         struct flow_dissector_key_tags *key_tags;
>> @@ -382,59 +436,12 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
>>                 goto out_good;
>>
>>         case htons(ETH_P_ARP):
>> -       case htons(ETH_P_RARP): {
>> -               struct {
>> -                       unsigned char ar_sha[ETH_ALEN];
>> -                       unsigned char ar_sip[4];
>> -                       unsigned char ar_tha[ETH_ALEN];
>> -                       unsigned char ar_tip[4];
>> -               } *arp_eth, _arp_eth;
>> -               const struct arphdr *arp;
>> -               struct arphdr *_arp;
>> -
>> -               arp = __skb_header_pointer(skb, nhoff, sizeof(_arp), data,
>> -                                          hlen, &_arp);
>> -               if (!arp)
>> -                       goto out_bad;
>> -
>> -               if (arp->ar_hrd != htons(ARPHRD_ETHER) ||
>> -                   arp->ar_pro != htons(ETH_P_IP) ||
>> -                   arp->ar_hln != ETH_ALEN ||
>> -                   arp->ar_pln != 4 ||
>> -                   (arp->ar_op != htons(ARPOP_REPLY) &&
>> -                    arp->ar_op != htons(ARPOP_REQUEST)))
>> +       case htons(ETH_P_RARP):
>> +               if (!__skb_flow_dissect_arp(skb, flow_dissector,
>> +                                           target_container, data,
>> +                                           nhoff, hlen))
>>                         goto out_bad;
>> -
>> -               arp_eth = __skb_header_pointer(skb, nhoff + sizeof(_arp),
>> -                                              sizeof(_arp_eth), data,
>> -                                              hlen,
>> -                                              &_arp_eth);
>> -               if (!arp_eth)
>> -                       goto out_bad;
>> -
>> -               if (dissector_uses_key(flow_dissector,
>> -                                      FLOW_DISSECTOR_KEY_ARP)) {
>> -
>> -                       key_arp = skb_flow_dissector_target(flow_dissector,
>> -                                                           FLOW_DISSECTOR_KEY_ARP,
>> -                                                           target_container);
>> -
>> -                       memcpy(&key_arp->sip, arp_eth->ar_sip,
>> -                              sizeof(key_arp->sip));
>> -                       memcpy(&key_arp->tip, arp_eth->ar_tip,
>> -                              sizeof(key_arp->tip));
>> -
>> -                       /* Only store the lower byte of the opcode;
>> -                        * this covers ARPOP_REPLY and ARPOP_REQUEST.
>> -                        */
>> -                       key_arp->op = ntohs(arp->ar_op) & 0xff;
>> -
>> -                       ether_addr_copy(key_arp->sha, arp_eth->ar_sha);
>> -                       ether_addr_copy(key_arp->tha, arp_eth->ar_tha);
>> -               }
>> -
>>                 goto out_good;
>> -       }
>>
>>         default:
>>                 goto out_bad;
>> --
>> 2.7.4
>>
