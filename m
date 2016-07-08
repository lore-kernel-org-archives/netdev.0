From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 0/4] net: cleanup for UDP tunnel's GRO
Date: Fri, 8 Jul 2016 17:51:20 -0400
Message-ID: <643a68e2-b3d8-a21b-79ff-9ba7b7c9f418@stressinduktion.org>
References: <cover.1467895623.git.pabeni@redhat.com>
 <CAKgT0UegKDuP0KHJ+zE1yDTwxxBjtvhESE3WFhTg65UX+CNL0A@mail.gmail.com>
 <20160708231734.6258c00b@halley>
 <e6319ae2-b436-18a0-dac1-5ae03e54e056@stressinduktion.org>
 <CAKgT0UcHB9W3S6W_Di24QtSicNtru3sO4LRuvMAogqKKn1d+ww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Paolo Abeni <pabeni@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>, Jiri Benc <jbenc@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:41245 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751658AbcGHVvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 17:51:22 -0400
In-Reply-To: <CAKgT0UcHB9W3S6W_Di24QtSicNtru3sO4LRuvMAogqKKn1d+ww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.07.2016 17:27, Alexander Duyck wrote:
> On Fri, Jul 8, 2016 at 1:57 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> On 08.07.2016 16:17, Shmulik Ladkani wrote:
>>> On Fri, 8 Jul 2016 09:21:40 -0700 Alexander Duyck <alexander.duyck@gmail.com> wrote:
>>>> On Thu, Jul 7, 2016 at 8:58 AM, Paolo Abeni <pabeni@redhat.com> wrote:
>>>>> With udp tunnel offload in place, the kernel can do GRO for some udp tunnels
>>>>> at the ingress device level. Currently both the geneve and the vxlan drivers
>>>>> implement an additional GRO aggregation point via gro_cells.
>>>>> The latter takes effect for tunnels using zero checksum udp packets, which are
>>>>> currently explicitly not aggregated by the udp offload layer.
>>>>>
>>>>> This patch series adapts the udp tunnel offload to process also zero checksum
>>>>> udp packets, if the tunnel's socket allow it. Aggregation, if possible is always
>>>>> performed at the ingress device level.
>>>>>
>>>>> Then the gro_cells hooks, in both vxlan and geneve driver are removed.
>>>>
>>>> I think removing the gro_cells hooks may be taking things one step too far.
>>>
>>> +1
>>>
>>>> I get that there is an impression that it is redundant but there are a
>>>> number of paths that could lead to VXLAN or GENEVE frames being
>>>> received that are not aggregated via GRO.
>>>
>>> There's the case where the vxlan/geneve datagrams get IP fragmented, and
>>> IP frags are not GROed.
>>> GRO aggregation at the vxlan/geneve level is beneficial for this case.
>>
>> Isn't this a misconfiguration? TCP should not fragment at all, not even
>> in vxlan/geneve if one cares about performance? And UDP is not GRO'ed
>> anyway.
> 
> The problem is that the DF bit of the outer header is what matters,
> not the inner one.  I believe the default for many of the UDP tunnels
> is to not set the DF bit on the outer header.  The fact is
> fragmentation shouldn't happen, but it can and we need to keep that in
> mind when we work on these sort of things.

"Old" tunnel protocols inherit the outer DF bit from the inner one,
geneve and vxlan do not. I think we simply never should set DF bit
because vxlan pmtu with source port rss perturbation breaks pmtu
discovery anyway. On the other hand doing so and not having end-to-end
protection of the VNI because of proposed 0 checksum is also...
otherwise at least the Ethernet FCS could protect the frame.

> There have been a number of cases in the past with tunnels where "it
> works for me" has been how things have been implemented and we need to
> avoid that as it creates a significant amount of pain for end users
> when they do things and they don't work because they have strayed off
> of the one use case that has been tested.

We certainly don't want to break fragmentation with vxlan and this patch
doesn't change so.

I really do wonder if GRO on top of fragmentation does have any effect.
Would be great if someone has data for that already?

Bye,
Hannes
