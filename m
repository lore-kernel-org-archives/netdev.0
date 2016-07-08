From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 0/4] net: cleanup for UDP tunnel's GRO
Date: Fri, 8 Jul 2016 14:27:53 -0700
Message-ID: <CAKgT0UcHB9W3S6W_Di24QtSicNtru3sO4LRuvMAogqKKn1d+ww@mail.gmail.com>
References: <cover.1467895623.git.pabeni@redhat.com> <CAKgT0UegKDuP0KHJ+zE1yDTwxxBjtvhESE3WFhTg65UX+CNL0A@mail.gmail.com>
 <20160708231734.6258c00b@halley> <e6319ae2-b436-18a0-dac1-5ae03e54e056@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Paolo Abeni <pabeni@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>, Jiri Benc <jbenc@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:35890 "EHLO
	mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754606AbcGHV1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 17:27:55 -0400
Received: by mail-it0-f48.google.com with SMTP id f6so13343717ith.1
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 14:27:54 -0700 (PDT)
In-Reply-To: <e6319ae2-b436-18a0-dac1-5ae03e54e056@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 8, 2016 at 1:57 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On 08.07.2016 16:17, Shmulik Ladkani wrote:
>> On Fri, 8 Jul 2016 09:21:40 -0700 Alexander Duyck <alexander.duyck@gmail.com> wrote:
>>> On Thu, Jul 7, 2016 at 8:58 AM, Paolo Abeni <pabeni@redhat.com> wrote:
>>>> With udp tunnel offload in place, the kernel can do GRO for some udp tunnels
>>>> at the ingress device level. Currently both the geneve and the vxlan drivers
>>>> implement an additional GRO aggregation point via gro_cells.
>>>> The latter takes effect for tunnels using zero checksum udp packets, which are
>>>> currently explicitly not aggregated by the udp offload layer.
>>>>
>>>> This patch series adapts the udp tunnel offload to process also zero checksum
>>>> udp packets, if the tunnel's socket allow it. Aggregation, if possible is always
>>>> performed at the ingress device level.
>>>>
>>>> Then the gro_cells hooks, in both vxlan and geneve driver are removed.
>>>
>>> I think removing the gro_cells hooks may be taking things one step too far.
>>
>> +1
>>
>>> I get that there is an impression that it is redundant but there are a
>>> number of paths that could lead to VXLAN or GENEVE frames being
>>> received that are not aggregated via GRO.
>>
>> There's the case where the vxlan/geneve datagrams get IP fragmented, and
>> IP frags are not GROed.
>> GRO aggregation at the vxlan/geneve level is beneficial for this case.
>
> Isn't this a misconfiguration? TCP should not fragment at all, not even
> in vxlan/geneve if one cares about performance? And UDP is not GRO'ed
> anyway.

The problem is that the DF bit of the outer header is what matters,
not the inner one.  I believe the default for many of the UDP tunnels
is to not set the DF bit on the outer header.  The fact is
fragmentation shouldn't happen, but it can and we need to keep that in
mind when we work on these sort of things.

There have been a number of cases in the past with tunnels where "it
works for me" has been how things have been implemented and we need to
avoid that as it creates a significant amount of pain for end users
when they do things and they don't work because they have strayed off
of the one use case that has been tested.

- Alex
