From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: XDP redirect measurements, gotchas and tracepoints
Date: Tue, 22 Aug 2017 18:06:12 -0700
Message-ID: <CAKgT0Uf=ZfVeK-wtvNxSyGEVZ3UseUOHiP3ZOg-SrzmqsR=LtQ@mail.gmail.com>
References: <20170821212506.1cb0d5d6@redhat.com> <CACKFLimAF9OYwz8EqG=1-N40hWuA-8C8k8ut0oFKYdduvZOxHA@mail.gmail.com>
 <599C7530.2010405@gmail.com> <1503426617.2434.5.camel@intel.com> <CACKFLimMWLto4FRxNE3tzrO5MU+p67J7wu=n1nmg0t8QGYjgrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "john.fastabend@gmail.com" <john.fastabend@gmail.com>,
        "brouer@redhat.com" <brouer@redhat.com>,
        "pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        "andy@greyhouse.net" <andy@greyhouse.net>,
        "borkmann@iogearbox.net" <borkmann@iogearbox.net>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:38505 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752779AbdHWBGO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 21:06:14 -0400
In-Reply-To: <CACKFLimMWLto4FRxNE3tzrO5MU+p67J7wu=n1nmg0t8QGYjgrA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 22, 2017 at 1:04 PM, Michael Chan <michael.chan@broadcom.com> wrote:
> On Tue, Aug 22, 2017 at 11:30 AM, Duyck, Alexander H
> <alexander.h.duyck@intel.com> wrote:
>> On Tue, 2017-08-22 at 11:17 -0700, John Fastabend wrote:
>>> On 08/22/2017 11:02 AM, Michael Chan wrote:
>>> > On Mon, Aug 21, 2017 at 12:25 PM, Jesper Dangaard Brouer
>>> > <brouer@redhat.com> wrote:
>>> > >
>>> > > I'be been playing with the latest XDP_REDIRECT feature, that was
>>> > > accepted in net-next (for ixgbe), see merge commit[1].
>>> > >  [1] https://git.kernel.org/davem/net-next/c/6093ec2dc31
>>> > >
>>> >
>>> > Just catching on XDP_REDIRECT and I have a very basic question.  The
>>> > ingress device passes the XDP buffer to the egress device for XDP
>>> > redirect transmission.  When the egress device has transmitted the
>>> > packet, is it supposed to just free the buffer?  Or is it supposed to
>>> > be recycled?
>>> >
>>> > In XDP_TX, the buffer is recycled back to the rx ring.
>>> >
>>>
>>> With XDP_REDIRECT we must "just free the buffer" in ixgbe this means
>>> page_frag_free() on the data. There is no way to know where the xdp
>>> buffer came from it could be a different NIC for example.
>>>
>>> However with how ixgbe is coded up recycling will work as long as
>>> the memory is free'd before the driver ring tries to use it again. In
>>> normal usage this should be the case. And if we are over-running a device
>>> it doesn't really hurt to slow down the sender a bit.
>>>
>>> I think this is a pretty good model, we could probably provide a set
>>> of APIs for drivers to use so that we get some consistency across
>>> vendors here, ala Jesper's page pool ideas.
>>>
>>> (+Alex, for ixgbe details)
>>>
>>> Thanks,
>>> John
>>
>> I think you pretty much covered the inner workings for the ixgbe bits.
>>
>> The only piece I would add is that the recycling trick normally only
>> works if the same interface/driver is doing both the Tx and the Rx. The
>> redirect code cannot assume that is the case and that is the reason why
>> it must always be freeing the traffic on clean-up.
>>
>
> Right, but it's conceivable to add an API to "return" the buffer to
> the input device, right?

You could, it is just added complexity. "just free the buffer" in
ixgbe usually just amounts to one atomic operation to decrement the
total page count since page recycling is already implemented in the
driver. You still would have to unmap the buffer regardless of if you
were recycling it or not so all you would save is 1.000015259 atomic
operations per packet. The fraction is because once every 64K uses we
have to bulk update the count on the page.

There are still thoughts at some point in the future to consider
changing the layout so that we lay things out linearly instead of
interleaving the page halves. However that is a bit of optimization
and right now I don't really have the spare time to explore it. It
would help the performance by making sure the pages are warm on the
second freeing assuming all the packets in a given flow are received
back to back.

- Alex
