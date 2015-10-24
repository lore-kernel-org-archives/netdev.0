From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: no CHECKSUM_PARTIAL on skbs with extension headers
 and recalc checksum during fragmentation
Date: Sat, 24 Oct 2015 19:02:04 +0200
Message-ID: <1445706124.1823412.419177649.420E8888@webmail.messagingengine.com>
References: <1445605987-15625-1-git-send-email-hannes@stressinduktion.org>
 <CALx6S35of-Qpo5c+AW5h6_CXbTiZG0yn5_J0skK_LZ4UMxikiA@mail.gmail.com>
 <1445704123.1816692.419166185.45622C02@webmail.messagingengine.com>
 <CALx6S35ttmhwMzbPRCkSApbgvJXcgC-kAzuiDQvOc=98mBQEnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:59903 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751884AbbJXRCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2015 13:02:04 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 773692065B
	for <netdev@vger.kernel.org>; Sat, 24 Oct 2015 13:02:04 -0400 (EDT)
In-Reply-To: <CALx6S35ttmhwMzbPRCkSApbgvJXcgC-kAzuiDQvOc=98mBQEnQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

On Sat, Oct 24, 2015, at 18:46, Tom Herbert wrote:
> On Sat, Oct 24, 2015 at 12:28 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > Hi Tom,
> >
> > On Sat, Oct 24, 2015, at 18:21, Tom Herbert wrote:
> >> On Fri, Oct 23, 2015 at 9:13 AM, Hannes Frederic Sowa
> >> <hannes@stressinduktion.org> wrote:
> >> > CHECKSUM_PARTIAL should only be used on plain vanilla IPv6 + UDP packets
> >> > in ip6_append_data. Some drivers don't correctly handle extension headers,
> >> > especially not ipv6 fragmentation which could result in broken checksums.
> >> >
> >> Yes, we've seen this in some drivers, but the conclusion is that those
> >> drivers are *broken* and need to be fixed! CHECKSUM_PARTIAL works
> >> perfectly well in the presence of extension headers if the
> >> driver/device is correctly implemented (simple algorithm with
> >> csum_start and csum_offset).
> >
> > I will do some more research on those drivers and I agree in general
> > with you. But if you look at the code it was clearly the intention to
> > not use CHECKSUM_PARTIAL on fragmented IPv6 packets, just this intention
> > has not been formulated correctly in code. I still would like to see
> > something like that showing up in stable and we can follow more CSUM
> > bits maybe for drivers who support or don't support that.
> >
> > Also as we are talking about fragments here, I would not put too much
> > effort into that, as fragments will be slow path anyway.
> >
> Checksum will need to be done before fragmentation, but I see little
> value in trying to push that back to the userspace copy. Besides, I
> would expect that UFO should work properly with extension headers.

Sure, checksum needs to be calculated before fragmentation, but touching
the data once during userspace copy seems to be valuable to me to
instead doing it later in the kernel, especially if the data is cold as
it has been on a send queue for quite some while and some context
switches happened (MSG_MORE for example).

For UFO CHECKSUM_PARTIAL is a must and we require proper checksum
offload capabilities. But nearly no networking card does provide UFO
offloading, there are very few of them (but heavily used due to virtual
ones supporting that). If you use UFO during UDP output you end up doing
CHECKSUM_PARTIAL.

> The rule is simple: if a driver states that ids capable of support an
> IPv6 offload, that means that it must properly handle packets with
> extension headers which are a core part of IPv6 protocol. We do not
> want to add any more feature bits for stuff like this.

I would agree, but we don't want to disable CHECKSUM_PARTIAL for most of
the traffic just if some drivers fail to do correct checksum offloading
for fragmented packets.

> It is possible that we will be deploying IPv6 extension headers within
> our data center at some point. I would prefer that we retain the value
> of HW checksum offload in that, but we simply cannot have devices
> silently sending bad checksums...

Yes, sure. Btw. this patch only affects UDP and RAW sockets.

> Please see my patch on the driver helper function to rectify device
> capabilities with packets as they are transmitted.

I have seen that already but will have a second look.

Anyway, currently it is easy to generate broken checksums on the wire
and would like to solve that for net, we certainly can improve that in
net-next.

Bye,
Hannes
