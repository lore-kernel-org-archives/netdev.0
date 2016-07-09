From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 0/4] net: cleanup for UDP tunnel's GRO
Date: Fri, 8 Jul 2016 18:27:17 -0700
Message-ID: <CAKgT0UdRr4XbkBw2amJH0RgqW+bQ64EWR6Hg3cejAEYo1nzqLA@mail.gmail.com>
References: <cover.1467895623.git.pabeni@redhat.com> <CAKgT0UegKDuP0KHJ+zE1yDTwxxBjtvhESE3WFhTg65UX+CNL0A@mail.gmail.com>
 <20160708231734.6258c00b@halley> <e6319ae2-b436-18a0-dac1-5ae03e54e056@stressinduktion.org>
 <CAKgT0UcHB9W3S6W_Di24QtSicNtru3sO4LRuvMAogqKKn1d+ww@mail.gmail.com>
 <643a68e2-b3d8-a21b-79ff-9ba7b7c9f418@stressinduktion.org>
 <CAKgT0UciEg0u3aqzQdEuLpaHAK2mXTwf9ng--84m7jL1wdsjnQ@mail.gmail.com> <1dc81b88-47c9-4274-6275-490b16526d4a@stressinduktion.org>
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
Received: from mail-it0-f41.google.com ([209.85.214.41]:37415 "EHLO
	mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932635AbcGIB1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 21:27:19 -0400
Received: by mail-it0-f41.google.com with SMTP id f6so16898174ith.0
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 18:27:19 -0700 (PDT)
In-Reply-To: <1dc81b88-47c9-4274-6275-490b16526d4a@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 8, 2016 at 4:04 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On 08.07.2016 18:11, Alexander Duyck wrote:
>> On Fri, Jul 8, 2016 at 2:51 PM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>>> On 08.07.2016 17:27, Alexander Duyck wrote:
>>>> On Fri, Jul 8, 2016 at 1:57 PM, Hannes Frederic Sowa
>>>> <hannes@stressinduktion.org> wrote:
>>>>> On 08.07.2016 16:17, Shmulik Ladkani wrote:
>>>>>> On Fri, 8 Jul 2016 09:21:40 -0700 Alexander Duyck <alexander.duyck@gmail.com> wrote:
>>>>>>> On Thu, Jul 7, 2016 at 8:58 AM, Paolo Abeni <pabeni@redhat.com> wrote:
>>>>>>>> With udp tunnel offload in place, the kernel can do GRO for some udp tunnels
>>>>>>>> at the ingress device level. Currently both the geneve and the vxlan drivers
>>>>>>>> implement an additional GRO aggregation point via gro_cells.
>>>>>>>> The latter takes effect for tunnels using zero checksum udp packets, which are
>>>>>>>> currently explicitly not aggregated by the udp offload layer.
>>>>>>>>
>>>>>>>> This patch series adapts the udp tunnel offload to process also zero checksum
>>>>>>>> udp packets, if the tunnel's socket allow it. Aggregation, if possible is always
>>>>>>>> performed at the ingress device level.
>>>>>>>>
>>>>>>>> Then the gro_cells hooks, in both vxlan and geneve driver are removed.
>>>>>>>
>>>>>>> I think removing the gro_cells hooks may be taking things one step too far.
>>>>>>
>>>>>> +1
>>>>>>
>>>>>>> I get that there is an impression that it is redundant but there are a
>>>>>>> number of paths that could lead to VXLAN or GENEVE frames being
>>>>>>> received that are not aggregated via GRO.
>>>>>>
>>>>>> There's the case where the vxlan/geneve datagrams get IP fragmented, and
>>>>>> IP frags are not GROed.
>>>>>> GRO aggregation at the vxlan/geneve level is beneficial for this case.
>>>>>
>>>>> Isn't this a misconfiguration? TCP should not fragment at all, not even
>>>>> in vxlan/geneve if one cares about performance? And UDP is not GRO'ed
>>>>> anyway.
>>>>
>>>> The problem is that the DF bit of the outer header is what matters,
>>>> not the inner one.  I believe the default for many of the UDP tunnels
>>>> is to not set the DF bit on the outer header.  The fact is
>>>> fragmentation shouldn't happen, but it can and we need to keep that in
>>>> mind when we work on these sort of things.
>>>
>>> "Old" tunnel protocols inherit the outer DF bit from the inner one,
>>> geneve and vxlan do not. I think we simply never should set DF bit
>>> because vxlan pmtu with source port rss perturbation breaks pmtu
>>> discovery anyway. On the other hand doing so and not having end-to-end
>>> protection of the VNI because of proposed 0 checksum is also...
>>> otherwise at least the Ethernet FCS could protect the frame.
>>
>> The "Old" tunnel protocols can be configured to behave the same way as
>> well.  It is just that most of them default to a mode where they
>> support getting a path MTU if I recall correctly.
>
> That actually only happend very recently, about one month ago (for gre
> at least). The other (ipip) doesn't support that.
>
>>>> There have been a number of cases in the past with tunnels where "it
>>>> works for me" has been how things have been implemented and we need to
>>>> avoid that as it creates a significant amount of pain for end users
>>>> when they do things and they don't work because they have strayed off
>>>> of the one use case that has been tested.
>>>
>>> We certainly don't want to break fragmentation with vxlan and this patch
>>> doesn't change so.
>>>
>>> I really do wonder if GRO on top of fragmentation does have any effect.
>>> Would be great if someone has data for that already?
>>
>> I think that logic is kind of backwards.  It is already there.
>> Instead of asking people to prove that this change is invalid the onus
>> should be on the submitter to prove the change causes no harm.
>
> Of course, sorry, I didn't want to make the impression others should do
> that. I asked because Shmulik made the impression on me he had
> experience with GRO+fragmentation on vxlan and/or geneve and could
> provide some data, maybe even just anecdotal.
>
>> The whole argument is kind of moot anyway based on the comment from
>> Tom.  This is based around being able to aggregate frames with a zero
>> checksum which we can already do, but it requires that the hardware
>> has validated the inner checksum.  What this patch set is doing is
>> trying to take frames that have no checksum and force us to perform a
>> checksum for the inner headers in software.  Really we don't do that
>> now for general GRO, why should we do it in the case of tunnels?  Also
>> I think there is a test escape for the case of a frame with an outer
>> checksum that was not validated by hardware.  In that case the
>> checksum isn't converted until you hit the UDP handler which will then
>> convert it to checksum complete and it then would rely on the GRO
>> cells to merge the frames after we have already validated the checksum
>> for the outer header.
>
> I do agree that Tom's comment changes things a little bit, but currently
> I tend towards removing the check completely, which needs further
> benchmark data. I wonder what difference it should make if we do the
> checksum check only in the gro cells call and not in the regular gro
> call (modulo of course, if gre or ipip need RPS before).

I'm thinking the main difference is that if there is zero checksum and
the hardware hasn't provided any sort of checksum I am not certain if
GRO actually occurs.  In the case of a checksum being present but not
validated by hardware the checksum should be converted to
CHECKSUM_COMPLETE once it is validated and then GRO could occur for
the inner data.

> General-GRO does compute the checksum for TCP if not pre-computed as far
> as I know. So basically we don't special case for tunnels, otherwise why
> would this check be in the udp gro handler?

So I think this might be a more recent change.  I know that you used
to be able to disable the Rx checksum in order to disable GRO.  It
seems like now if you disable it the frames are still aggregated.  It
might be worth while to figure out the reasoning for that change as it
may be applicable to tunnels as well.

> Maybe it also makes sense to optimistically compare some values of the
> tcp header before validating the checksum, so we can make sure that we
> calculate the expensive checksum only if it would actually only make sense.

Okay.  One other thing you might look at is if you could defer
validating the outer checksums until after the inner one has been
validated in the case that the hardware has not validated it.

> Alex, unfortunately I didn't understand your last two sentences.

The patch set as it currently stands was only performing GRO if a
checksum was not present, however if a checksum is present on the
outer header then the cost checksum the UDP packet and then work back
to the TCP header should be comparable to the overhead needed to just
do the TCP header.  Basically what I am getting at is that if you are
going going to coalesce the no checksum case for tunnels without
having the hardware validate the checksum is present you could
probably do the same thing for tunnels if the checksum is present on
the outer header.

- Alex
