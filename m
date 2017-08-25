From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: XDP redirect measurements, gotchas and tracepoints
Date: Fri, 25 Aug 2017 08:28:55 -0700
Message-ID: <CACKFLin-sZEkkCxE2iZRHjgG=K36OJ65B-xrEYVCCSQqhYsH-g@mail.gmail.com>
References: <20170821212506.1cb0d5d6@redhat.com> <CACKFLimAF9OYwz8EqG=1-N40hWuA-8C8k8ut0oFKYdduvZOxHA@mail.gmail.com>
 <599C7530.2010405@gmail.com> <1503426617.2434.5.camel@intel.com>
 <CACKFLimMWLto4FRxNE3tzrO5MU+p67J7wu=n1nmg0t8QGYjgrA@mail.gmail.com>
 <CAKgT0Uf=ZfVeK-wtvNxSyGEVZ3UseUOHiP3ZOg-SrzmqsR=LtQ@mail.gmail.com>
 <CACKFLinJ0N7b8Xhq4ZoHdB80uXp_MU_vVyzZa7Dq11XrXsvDbw@mail.gmail.com>
 <20170823102937.79a9c4ed@redhat.com> <CACKFLinGuaDLxYRd=vC99DL5n0mf0rDbPRaDg4ctev=DEAhRSQ@mail.gmail.com>
 <20170825144513.1ee9fbb1@redhat.com> <59A03DF5.7070806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        "andy@greyhouse.net" <andy@greyhouse.net>,
        "borkmann@iogearbox.net" <borkmann@iogearbox.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f170.google.com ([209.85.161.170]:33960 "EHLO
        mail-yw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933386AbdHYP27 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 11:28:59 -0400
Received: by mail-yw0-f170.google.com with SMTP id t188so867018ywb.1
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 08:28:58 -0700 (PDT)
In-Reply-To: <59A03DF5.7070806@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 25, 2017 at 8:10 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 08/25/2017 05:45 AM, Jesper Dangaard Brouer wrote:
>> On Thu, 24 Aug 2017 20:36:28 -0700
>> Michael Chan <michael.chan@broadcom.com> wrote:
>>
>>> On Wed, Aug 23, 2017 at 1:29 AM, Jesper Dangaard Brouer
>>> <brouer@redhat.com> wrote:
>>>> On Tue, 22 Aug 2017 23:59:05 -0700
>>>> Michael Chan <michael.chan@broadcom.com> wrote:
>>>>
>>>>> On Tue, Aug 22, 2017 at 6:06 PM, Alexander Duyck
>>>>> <alexander.duyck@gmail.com> wrote:
>>>>>> On Tue, Aug 22, 2017 at 1:04 PM, Michael Chan <michael.chan@broadcom.com> wrote:
>>>>>>>
>>>>>>> Right, but it's conceivable to add an API to "return" the buffer to
>>>>>>> the input device, right?
>>>>
>>>> Yes, I would really like to see an API like this.
>>>>
>>>>>>
>>>>>> You could, it is just added complexity. "just free the buffer" in
>>>>>> ixgbe usually just amounts to one atomic operation to decrement the
>>>>>> total page count since page recycling is already implemented in the
>>>>>> driver. You still would have to unmap the buffer regardless of if you
>>>>>> were recycling it or not so all you would save is 1.000015259 atomic
>>>>>> operations per packet. The fraction is because once every 64K uses we
>>>>>> have to bulk update the count on the page.
>>>>>>
>>>>>
>>>>> If the buffer is returned to the input device, the input device can
>>>>> keep the DMA mapping.  All it needs to do is to dma_sync it back to
>>>>> the input device when the buffer is returned.
>>>>
>>>> Yes, exactly, return to the input device. I really think we should
>>>> work on a solution where we can keep the DMA mapping around.  We have
>>>> an opportunity here to make ndo_xdp_xmit TX queues use a specialized
>>>> page return call, to achieve this. (I imagine other arch's have a high
>>>> DMA overhead than Intel)
>>>>
>>>> I'm not sure how the API should look.  The ixgbe recycle mechanism and
>>>> splitting the page (into two packets) actually complicates things, and
>>>> tie us into a page-refcnt based model.  We could get around this by
>>>> each driver implementing a page-return-callback, that allow us to
>>>> return the page to the input device?  Then, drivers implementing the
>>>> 1-packet-per-page can simply check/read the page-refcnt, and if it is
>>>> "1" DMA-sync and reuse it in the RX queue.
>>>>
>>>
>>> Yeah, based on Alex' description, it's not clear to me whether ixgbe
>>> redirecting to a non-intel NIC or vice versa will actually work.  It
>>> sounds like the output device has to make some assumptions about how
>>> the page was allocated by the input device.
>>
>> Yes, exactly. We are tied into a page refcnt based scheme.
>>
>> Besides the ixgbe page recycle scheme (which keeps the DMA RX-mapping)
>> is also tied to the RX queue size, plus how fast the pages are returned.
>> This makes it very hard to tune.  As I demonstrated, default ixgbe
>> settings does not work well with XDP_REDIRECT.  I needed to increase
>> TX-ring size, but it broke page recycling (dropping perf from 13Mpps to
>> 10Mpps) so I also needed it increase RX-ring size.  But perf is best if
>> RX-ring size is smaller, thus two contradicting tuning needed.
>>
>
> The changes to decouple the ixgbe page recycle scheme (1pg per descriptor
> split into two halves being the default) from the number of descriptors
> doesn't look too bad IMO. It seems like it could be done by having some
> extra pages allocated upfront and pulling those in when we need another
> page.
>
> This would be a nice iterative step we could take on the existing API.
>
>>
>>> With buffer return API,
>>> each driver can cleanly recycle or free its own buffers properly.
>>
>> Yes, exactly. And RX-driver can implement a special memory model for
>> this queue.  E.g. RX-driver can know this is a dedicated XDP RX-queue
>> which is never used for SKBs, thus opening for new RX memory models.
>>
>> Another advantage of a return API.  There is also an opportunity for
>> avoiding the DMA map on TX. As we need to know the from-device.  Thus,
>> we can add a DMA API, where we can query if the two devices uses the
>> same DMA engine, and can reuse the same DMA address the RX-side already
>> knows.
>>
>>
>>> Let me discuss this further with Andy to see if we can come up with a
>>> good scheme.
>>
>> Sound good, looking forward to hear what you come-up with :-)
>>
>
> I guess by this thread we will see a broadcom nic with redirect support
> soon ;)

Yes, Andy actually has finished the coding for XDP_REDIRECT, but the
buffer recycling scheme has some problems.  We can make it work for
Broadcom to Broadcom only, but we want a better solution.
