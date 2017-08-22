From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: XDP redirect measurements, gotchas and tracepoints
Date: Tue, 22 Aug 2017 13:04:07 -0700
Message-ID: <CACKFLimMWLto4FRxNE3tzrO5MU+p67J7wu=n1nmg0t8QGYjgrA@mail.gmail.com>
References: <20170821212506.1cb0d5d6@redhat.com> <CACKFLimAF9OYwz8EqG=1-N40hWuA-8C8k8ut0oFKYdduvZOxHA@mail.gmail.com>
 <599C7530.2010405@gmail.com> <1503426617.2434.5.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "john.fastabend@gmail.com" <john.fastabend@gmail.com>,
        "brouer@redhat.com" <brouer@redhat.com>,
        "pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        "andy@greyhouse.net" <andy@greyhouse.net>,
        "borkmann@iogearbox.net" <borkmann@iogearbox.net>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:32896 "EHLO
        mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752446AbdHVUEI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 16:04:08 -0400
Received: by mail-yw0-f174.google.com with SMTP id h127so45991185ywf.0
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 13:04:08 -0700 (PDT)
In-Reply-To: <1503426617.2434.5.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 22, 2017 at 11:30 AM, Duyck, Alexander H
<alexander.h.duyck@intel.com> wrote:
> On Tue, 2017-08-22 at 11:17 -0700, John Fastabend wrote:
>> On 08/22/2017 11:02 AM, Michael Chan wrote:
>> > On Mon, Aug 21, 2017 at 12:25 PM, Jesper Dangaard Brouer
>> > <brouer@redhat.com> wrote:
>> > >
>> > > I'be been playing with the latest XDP_REDIRECT feature, that was
>> > > accepted in net-next (for ixgbe), see merge commit[1].
>> > >  [1] https://git.kernel.org/davem/net-next/c/6093ec2dc31
>> > >
>> >
>> > Just catching on XDP_REDIRECT and I have a very basic question.  The
>> > ingress device passes the XDP buffer to the egress device for XDP
>> > redirect transmission.  When the egress device has transmitted the
>> > packet, is it supposed to just free the buffer?  Or is it supposed to
>> > be recycled?
>> >
>> > In XDP_TX, the buffer is recycled back to the rx ring.
>> >
>>
>> With XDP_REDIRECT we must "just free the buffer" in ixgbe this means
>> page_frag_free() on the data. There is no way to know where the xdp
>> buffer came from it could be a different NIC for example.
>>
>> However with how ixgbe is coded up recycling will work as long as
>> the memory is free'd before the driver ring tries to use it again. In
>> normal usage this should be the case. And if we are over-running a device
>> it doesn't really hurt to slow down the sender a bit.
>>
>> I think this is a pretty good model, we could probably provide a set
>> of APIs for drivers to use so that we get some consistency across
>> vendors here, ala Jesper's page pool ideas.
>>
>> (+Alex, for ixgbe details)
>>
>> Thanks,
>> John
>
> I think you pretty much covered the inner workings for the ixgbe bits.
>
> The only piece I would add is that the recycling trick normally only
> works if the same interface/driver is doing both the Tx and the Rx. The
> redirect code cannot assume that is the case and that is the reason why
> it must always be freeing the traffic on clean-up.
>

Right, but it's conceivable to add an API to "return" the buffer to
the input device, right?
