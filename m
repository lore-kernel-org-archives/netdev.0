From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v2 0/4] net: Checksum offload changes - Part IV
Date: Sun, 13 Jul 2014 16:01:21 -0700
Message-ID: <CA+mtBx_7O3TXkUF_P+fF=ebtxuBm4-3xRuU6nFPSiKZP=+08Mg@mail.gmail.com>
References: <alpine.DEB.2.02.1406101848350.5666@tomh.mtv.corp.google.com>
	<20140611.154635.2203844517927313680.davem@davemloft.net>
	<CAJzFV35iTRbgECjg5S3bL025E4b8A3c1sBhfZX=OY3njFDYYoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Sharat Masetty <sharat04@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:64045 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbaGMXBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2014 19:01:22 -0400
Received: by mail-ie0-f178.google.com with SMTP id tp5so2561286ieb.23
        for <netdev@vger.kernel.org>; Sun, 13 Jul 2014 16:01:22 -0700 (PDT)
In-Reply-To: <CAJzFV35iTRbgECjg5S3bL025E4b8A3c1sBhfZX=OY3njFDYYoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2014 at 10:40 PM, Sharat Masetty <sharat04@gmail.com> wrote:
>> Don't do skb_checksum more than once per packet
> Was wondering in which cases does the stack perform the checksum more
> than once? __skb_checksum_complete_head() already sets the ip_summed
> to CHECKSUM_UNNECESSARY, so future checksum calculations are avoided.

Consider the following scenario:

1) VXLAN packet is receive with non-zero UDP checksum and driver did
not set checksum unnecessary.
2) Stack computes and verifies UDP checksum and sets ip_summed to
CHECKSUM_UNNECESSARY.
3) Packet enters UDP tunnel processing, ip_summed is set to
CHECKSUM_NONE since skb->encapsulation == 0
4) Stack will then recompute checksum for an encapsulated TCP packet.

So in this case the bytes in the TCP header and all its data were
checksum twice. To avoid this we don't set CHECKSUM_UNNECESSARY but
keep ip_summed == CHECKSUM_COMPLETE.

There are other cases where the packet can be checksummed twice, for
instance it checksum is bad I believe both GRO and normal path will
compute it (still need to fix this).

Tom

> What am I missing?
>
> Thanks
> Sharat
>
> On Wed, Jun 11, 2014 at 4:46 PM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <therbert@google.com>
>> Date: Tue, 10 Jun 2014 18:54:03 -0700 (PDT)
>>
>>> I am working on overhauling RX checksum offload. Goals of this effort
>>> are:
>>>
>>> - Specify what exactly it means when driver returns CHECKSUM_UNNECESSARY
>>> - Preserve CHECKSUM_COMPLETE through encapsulation layers
>>> - Don't do skb_checksum more than once per packet
>>> - Unify GRO and non-GRO csum verification as much as possible
>>> - Unify the checksum functions (checksum_init)
>>> - Simply code
>>>
>>> What is in this fourth patch set:
>>>
>>> - Preserve CHECKSUM_COMPLETE instead of changing it to
>>>   CHECKSUM_UNNECESSARY. This allows correct reuse in validating multiple
>>>   csums in a packet.
>>> - When SW needs to compute the packet checksum, save it as
>>>   CHECKSUM_COMPLETE. Also mark that checksum was compute by SW.
>>> - Add skb_gro_postpull_rcsum to udp and vxlan to make GRO work with
>>>   CHECKSUM_COMPLETE.
>>>
>>> v2: Removed patch setting skb_encapsulation when validating checksum
>>>     in tcp_gro_receive
>>>
>>> Please review carefully and test if possible, mucking with basic
>>> checksum functions is always a little precarious :-)
>>
>> Series applied, thanks Tom.
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
