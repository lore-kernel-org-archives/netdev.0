From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2 net-next] net:add one common config ARCH_WANT_RELAX_ORDER
 to support relax ordering.
Date: Mon, 23 Jan 2017 08:28:05 -0800
Message-ID: <CAKgT0UfSgVYsmcLOB4Dadg3O3LVwaspkP4nLUihF-GhJTjL2dw@mail.gmail.com>
References: <1483939954-9864-1-git-send-email-maowenan@huawei.com>
 <20170117.141533.680344033700095483.davem@davemloft.net> <063D6719AE5E284EB5DD2968C1650D6DB0266CD6@AcuExch.aculab.com>
 <CAKgT0Ud5K4GZtbyNOMUh=o8oGTukPA7qvvnK6ptO+KwaTSqGkA@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0267C5A@AcuExch.aculab.com>
 <CAKgT0UeW1LgzFiycz+aQb8j9VamdXO8Q1mO1DqcazeTkwQmYCA@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6DB0268E25@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        "maowenan@huawei.com" <maowenan@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>
To: David Laight <David.Laight@aculab.com>,
        Tushar Dave <tushar.n.dave@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:35862 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750761AbdAWQ2I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 11:28:08 -0500
Received: by mail-it0-f44.google.com with SMTP id c7so66588278itd.1
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 08:28:08 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0268E25@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 1:44 AM, David Laight <David.Laight@aculab.com> wrote:
> Alexander Duyck
>> Sent: 19 January 2017 15:55
> ...
>> >> The Relaxed Ordering attribute doesn't get applied across the board.
>> >> It ends up being limited to a subset of the transactions if I recall
>> >> correctly.  In this case it is the Tx descriptor write back, and the
>> >> Rx data write back.  We don't apply the RO bit to any other
>> >> transactions.
>> >>
>> >> In the case of Tx descriptor there is no harm in allowing it to be
>> >> reordered because we only really read the DD bit so we don't care
>> >> about the ordering of the write back.  In the case of the Rx data the
>> >> Rx descriptor essentially acts as a flush since it is sent without the
>> >> RO bit set.  So all the writes before it must be completed before the
>> >> Rx descriptor write back.
>> >
>> > In which case why not set it unconditionally for all architectures?
>> >
>> > I'm surprised (I often am) that allowing those re-orderings makes
>> > any significant difference.
>> > Unfortunately you need a PCIe analyser to see what is really happening
>> > and they don't come cheap.
>> >
>> > What I do vaguely remember is that some hosts don't always implement
>> > the 'normal' re-ordering of reads and read completions.
>> > Re-ordering of reads allows descriptor reads to overtake transmit
>> > traffic which is likely to make a difference.
>>
>> I think part of the issue, at least in the case of SPARC, is that the
>> handling of the memory writes in the PCIe root complex is impacted by
>> the RO attribute.  On the bus itself it doesn't matter much, but at
>> the root complex it can become expensive to have to wait on a partial
>> write to complete while there are other writes pending.  This is why
>> the IOMMU for SPARC now has a WEAK_ORDERING attribute you can add so
>> that it can write the data in whatever order it wants in relation to
>> other writes in that region.
>
> I hope the IOMMU only ever reorders writes that have the RO bit set.

I'm assuming it only applies to DMA regions mapped with
DMA_ATTR_WEAK_ORDERING.  Since drivers have to specify that attribute
it likely is only going to apply to DMA regions that could have the RO
bit set.

> Has anyone tried cache invalidates on the rx buffers?
> Might make the writes less expensive.
> Or is the issue with NUMA rather than cache.

I don't know.  This is all very SPARC specific and I haven't done any
of the work on it.  You might try checking with those responsible for
introducing DMA_ATTR_WEAK_ORDERING for the SPARC architecture.

- Alex
