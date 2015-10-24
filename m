From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net] ipv6: no CHECKSUM_PARTIAL on skbs with extension
 headers and recalc checksum during fragmentation
Date: Sat, 24 Oct 2015 12:46:54 -0400
Message-ID: <CALx6S35ttmhwMzbPRCkSApbgvJXcgC-kAzuiDQvOc=98mBQEnQ@mail.gmail.com>
References: <1445605987-15625-1-git-send-email-hannes@stressinduktion.org>
	<CALx6S35of-Qpo5c+AW5h6_CXbTiZG0yn5_J0skK_LZ4UMxikiA@mail.gmail.com>
	<1445704123.1816692.419166185.45622C02@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:33567 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbbJXQqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2015 12:46:55 -0400
Received: by igbkq10 with SMTP id kq10so51569311igb.0
        for <netdev@vger.kernel.org>; Sat, 24 Oct 2015 09:46:55 -0700 (PDT)
In-Reply-To: <1445704123.1816692.419166185.45622C02@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 24, 2015 at 12:28 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi Tom,
>
> On Sat, Oct 24, 2015, at 18:21, Tom Herbert wrote:
>> On Fri, Oct 23, 2015 at 9:13 AM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>> > CHECKSUM_PARTIAL should only be used on plain vanilla IPv6 + UDP packets
>> > in ip6_append_data. Some drivers don't correctly handle extension headers,
>> > especially not ipv6 fragmentation which could result in broken checksums.
>> >
>> Yes, we've seen this in some drivers, but the conclusion is that those
>> drivers are *broken* and need to be fixed! CHECKSUM_PARTIAL works
>> perfectly well in the presence of extension headers if the
>> driver/device is correctly implemented (simple algorithm with
>> csum_start and csum_offset).
>
> I will do some more research on those drivers and I agree in general
> with you. But if you look at the code it was clearly the intention to
> not use CHECKSUM_PARTIAL on fragmented IPv6 packets, just this intention
> has not been formulated correctly in code. I still would like to see
> something like that showing up in stable and we can follow more CSUM
> bits maybe for drivers who support or don't support that.
>
> Also as we are talking about fragments here, I would not put too much
> effort into that, as fragments will be slow path anyway.
>
Checksum will need to be done before fragmentation, but I see little
value in trying to push that back to the userspace copy. Besides, I
would expect that UFO should work properly with extension headers.

The rule is simple: if a driver states that ids capable of support an
IPv6 offload, that means that it must properly handle packets with
extension headers which are a core part of IPv6 protocol. We do not
want to add any more feature bits for stuff like this.

It is possible that we will be deploying IPv6 extension headers within
our data center at some point. I would prefer that we retain the value
of HW checksum offload in that, but we simply cannot have devices
silently sending bad checksums...

Please see my patch on the driver helper function to rectify device
capabilities with packets as they are transmitted.

Thanks,
Tom

> Bye,
> Hannes
