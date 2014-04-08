From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 6/6] net: Implmement RFC 6936 (zero RX csums for UDP/IPv6)
Date: Tue, 8 Apr 2014 08:47:56 -0700
Message-ID: <CA+mtBx9BcnU7VESN8pJkxP+eM0QdnOXt2S4J+zV8a5Gw7+LhPg@mail.gmail.com>
References: <alpine.DEB.2.02.1404041720560.21339@tomh.mtv.corp.google.com>
	<5342F307.6020407@linux-ipv6.org>
	<CA+mtBx_gUsovA87Fqpn+zzDzNL7wJ7YWX3_pfcZORg=nexXHcw@mail.gmail.com>
	<53434E0F.90707@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:47454 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756709AbaDHPr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 11:47:57 -0400
Received: by mail-ie0-f176.google.com with SMTP id rd18so1102732iec.21
        for <netdev@vger.kernel.org>; Tue, 08 Apr 2014 08:47:57 -0700 (PDT)
In-Reply-To: <53434E0F.90707@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 7, 2014 at 6:17 PM, YOSHIFUJI Hideaki
<yoshfuji@linux-ipv6.org> wrote:
> Tom Herbert wrote:
>
>>>>       while (sk) {
>>>> +             if (!uh->check && !udp_sk(sk)->check6_zero_okay) {
>>>> +                     /*
>>>> +                      * If checksum in packet is zero and not all the
>>>> +                      * sockets accept a zero checksum then declare
>>>> +                      * a checksum error.
>>>> +                      */
>>>> +                     flush_stack(stack, count, skb, ~0);
>>>> +                     count = 0;
>>>> +                     udp6_csum_zero_error(skb);
>>>> +                     UDP6_INC_STATS_BH(net, UDP_MIB_CSUMERRORS, proto == IPPROTO_UDPLITE);
>>>> +                     UDP6_INC_STATS_BH(net, UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
>>>> +                     break;
>>>> +             }
>>>>               stack[count++] = sk;
>>>>               sk = udp_v6_mcast_next(net, sk_nulls_next(sk), uh->dest, daddr,
>>>>                                      uh->source, saddr, dif);
>>>
>>> This seems wrong; packets with zero-checksum will not be delivered to
>>> some sockets if some of sockets accept zero-checksums and others do not.
>>>
>> Okay, I suppose delivering to some and not others is reasonable,
>> although there's no accounting for the non-deliverables-- I suppose
>> there's no completely clean way to do this...
>
> Well, I believe that supporting UDP packets with zero-checksum
> should be implemented in a consistent way with UDP-lite.
>
Zero-checksum is disallowed for UDP-lite RFC3828, we can't change that.

>>> BTW, I have been thinking that we should introduce 4 options
>>> (or bits) for IPv4/IPv6 checksumming for sender/receiver.
>>>
>> What are these 4 options?
>
> I meant combination of {ipv4,ipv6} and {sender,receiver}.
>
I suppose you mean more granularity to enable zero checksums for v4
and v6 UDP TX, and allow zero checksum on RX for v6 UDP (no options
for v4 RX). I'm leery about making it easier to use zero checksums, we
should be encouraging use of UDP checksums. Consider VXLAN draft which
says that UDP checksum should be zero-- this means that the vni is
sent with no protection against corruption (this is L3 so any Ethernet
CRC doesn't count). So with a single bit flip we might send packets to
wrong VM thus breaking isolation which is fundamental in network
virtualization. A goal of my patches is to make CHECKSUM_COMPLETE
efficient and a better option for devices, then sending UDP csums with
zero is less compelling.

> --yoshfuji
>
