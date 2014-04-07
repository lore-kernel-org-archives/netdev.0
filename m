From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 6/6] net: Implmement RFC 6936 (zero RX csums for UDP/IPv6)
Date: Mon, 7 Apr 2014 13:53:34 -0700
Message-ID: <CA+mtBx_gUsovA87Fqpn+zzDzNL7wJ7YWX3_pfcZORg=nexXHcw@mail.gmail.com>
References: <alpine.DEB.2.02.1404041720560.21339@tomh.mtv.corp.google.com>
	<5342F307.6020407@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:41856 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755187AbaDGUxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 16:53:34 -0400
Received: by mail-ie0-f181.google.com with SMTP id tp5so6488190ieb.26
        for <netdev@vger.kernel.org>; Mon, 07 Apr 2014 13:53:34 -0700 (PDT)
In-Reply-To: <5342F307.6020407@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 7, 2014 at 11:48 AM, YOSHIFUJI Hideaki
<yoshfuji@linux-ipv6.org> wrote:
> Tom Herbert wrote:
>> RFC 6936 relaxes the requirement of RFC 2460 that UDP/IPv6 packets which
>> are received with a zero UDP checksum value must be dropped. RFC 6936
>> allow zero checksums to support tunnels over UDP.
>>
>> This patch adds a new socket option UDP_CHECK6_ZERO_OKAY whcih can be
>> set on a UDP socket to indicate that a zero checksum is acceptable
>> (e.g. the socket is for a tunnel). The ip6 checksum and UDP receive
>> functions were updated accordingly to deal with this.
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>>  include/linux/udp.h      |  3 ++-
>>  include/uapi/linux/udp.h |  1 +
>>  net/ipv4/udp.c           |  8 ++++++++
>>  net/ipv6/ip6_checksum.c  | 19 ++++++++-----------
>>  net/ipv6/udp.c           | 39 +++++++++++++++++++++++++++++++++++++--
>>  5 files changed, 56 insertions(+), 14 deletions(-)
>>
>> diff --git a/include/linux/udp.h b/include/linux/udp.h
>> index 42278bb..647ffc9 100644
>> --- a/include/linux/udp.h
>> +++ b/include/linux/udp.h
>> @@ -779,6 +791,19 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>>       dif = inet6_iif(skb);
>>       sk = udp_v6_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
>>       while (sk) {
>> +             if (!uh->check && !udp_sk(sk)->check6_zero_okay) {
>> +                     /*
>> +                      * If checksum in packet is zero and not all the
>> +                      * sockets accept a zero checksum then declare
>> +                      * a checksum error.
>> +                      */
>> +                     flush_stack(stack, count, skb, ~0);
>> +                     count = 0;
>> +                     udp6_csum_zero_error(skb);
>> +                     UDP6_INC_STATS_BH(net, UDP_MIB_CSUMERRORS, proto == IPPROTO_UDPLITE);
>> +                     UDP6_INC_STATS_BH(net, UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
>> +                     break;
>> +             }
>>               stack[count++] = sk;
>>               sk = udp_v6_mcast_next(net, sk_nulls_next(sk), uh->dest, daddr,
>>                                      uh->source, saddr, dif);
>
> This seems wrong; packets with zero-checksum will not be delivered to
> some sockets if some of sockets accept zero-checksums and others do not.
>
Okay, I suppose delivering to some and not others is reasonable,
although there's no accounting for the non-deliverables-- I suppose
there's no completely clean way to do this...

> BTW, I have been thinking that we should introduce 4 options
> (or bits) for IPv4/IPv6 checksumming for sender/receiver.
>
What are these 4 options?

Tom

> --yoshfuji
