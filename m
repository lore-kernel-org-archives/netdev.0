From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] ipv6: Implement limits on hop by hop and
 destination options
Date: Fri, 12 May 2017 18:02:36 -0700
Message-ID: <CALx6S35=3aiP3ip0GabnqbOFS=NFY0zvjPne_WJ_Y9J6ZpPe+w@mail.gmail.com>
References: <1494451999-19031-1-git-send-email-tom@herbertland.com> <20170512.113847.1389407948502066394.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Martin Lau <kafai@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:36650 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755801AbdEMBCh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 21:02:37 -0400
Received: by mail-qt0-f175.google.com with SMTP id f55so11772905qta.3
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 18:02:37 -0700 (PDT)
In-Reply-To: <20170512.113847.1389407948502066394.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 12, 2017 at 8:38 AM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Wed, 10 May 2017 14:33:19 -0700
>
>> RFC 2460 (IPv6) defines hop by hop options and destination options
>> extension headers. Both of these carry a list of TLVs which is
>> only limited by the maximum length of the extension header (2048
>> bytes). By the spec a host must process all the TLVs in these
>> options, however these could be used as a fairly obvious
>> denial of service attack. I think this could in fact be
>> a significant DOS vector on the Internet, one mitigating
>> factor might be that many FWs drop all packets with EH (and
>> obviously this is only IPv6) so an Internet wide attack might not
>> be so effective (yet!).
>>
>> By my calculation, the worse case packet with TLVs in a standard
>> 1500 byte MTU packet that would be processed by the stack contains
>> 1282 invidual TLVs (including pad TLVS) or 724 two byte TLVs. I
>> wrote a quick test program that floods a whole bunch of these
>> packets to a host and sure enough there is substantial time spent
>> in ip6_parse_tlv. These packets contain nothing but unknown TLVS
>> (that are ignored), TLV padding, and bogus UDP header with zero
>> payload length.
>  ...
>> Default values are set to 8 for options counts, and set to INT_MAX
>> for maximum length. Note the choice to limit options to 8 is an
>> arbitrary guess (roughly based on the fact that the stack supports
>> three HBH options and just one destination option).
>
> So the maximum number of TLVs we could process is some function of the
> option count limit, and the number of padding TLVs that can be stuffed
> alongside of those 8 non-padding options?

Yes, if you count the one byte pad TLVs then maximum TLVs processed (#
times through the loop) with the default of 8 is 8 + 9*7= 71. The
padding TLVs are less expensive to process at least.

Function is:
N(max_non_pad) = (max_non_pad + 1) * 7 + max_non_pad
