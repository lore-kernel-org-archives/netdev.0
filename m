From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Questions on XDP
Date: Sat, 18 Feb 2017 10:18:10 -0800
Message-ID: <CAKgT0UfE+RN-bK_Hu05kJv62s-edJtkrmkBefHU6UCYQSDdkvw@mail.gmail.com>
References: <CAKgT0Uc0RQyK0SCALEUVGBj8JMHCfp+CqiBsTJXN9mat9jUNjQ@mail.gmail.com>
 <58A62979.1050600@gmail.com> <20170218173402.1af86005@redhat.com> <1487439675.1311.96.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:37342 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753346AbdBRSSM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 13:18:12 -0500
Received: by mail-it0-f51.google.com with SMTP id x75so34896511itb.0
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 10:18:11 -0800 (PST)
In-Reply-To: <1487439675.1311.96.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 18, 2017 at 9:41 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2017-02-18 at 17:34 +0100, Jesper Dangaard Brouer wrote:
>> On Thu, 16 Feb 2017 14:36:41 -0800
>> John Fastabend <john.fastabend@gmail.com> wrote:
>>
>> > On 17-02-16 12:41 PM, Alexander Duyck wrote:
>> > > So I'm in the process of working on enabling XDP for the Intel NICs
>> > > and I had a few questions so I just thought I would put them out here
>> > > to try and get everything sorted before I paint myself into a corner.
>> > >
>> > > So my first question is why does the documentation mention 1 frame per
>> > > page for XDP?
>>
>> Yes, XDP defines upfront a memory model where there is only one packet
>> per page[1], please respect that!
>>
>> This is currently used/needed for fast-direct recycling of pages inside
>> the driver for XDP_DROP and XDP_TX, _without_ performing any atomic
>> refcnt operations on the page. E.g. see mlx4_en_rx_recycle().
>
>
> XDP_DROP does not require having one page per frame.

Agreed.

> (Look after my recent mlx4 patch series if you need to be convinced)
>
> Only XDP_TX is.
>
> This requirement makes XDP useless (very OOM likely) on arches with 64K
> pages.

Actually I have been having a side discussion with John about XDP_TX.
Looking at the Mellanox way of doing it I am not entirely sure it is
useful.  It looks good for benchmarks but that is about it.  Also I
don't see it extending out to the point that we would be able to
exchange packets between interfaces which really seems like it should
be the ultimate goal for XDP_TX.

It seems like eventually we want to be able to peel off the buffer and
send it to something other than ourselves.  For example it seems like
it might be useful at some point to use XDP to do traffic
classification and have it route packets between multiple interfaces
on a host and it wouldn't make sense to have all of them map every
page as bidirectional because it starts becoming ridiculous if you
have dozens of interfaces in a system.

As per our original discussion at netconf if we want to be able to do
XDP Tx with a fully lockless Tx ring we needed to have a Tx ring per
CPU that is performing XDP.  The Tx path will end up needing to do the
map/unmap itself in the case of physical devices but the expense of
that can be somewhat mitigated on x86 at least by either disabling the
IOMMU or using identity mapping.  I think this might be the route
worth exploring as we could then start looking at doing things like
implementing bridges and routers in XDP and see what performance gains
can be had there.

Also as far as the one page per frame it occurs to me that you will
have to eventually deal with things like frame replication.  Once that
comes into play everything becomes much more difficult because the
recycling doesn't work without some sort of reference counting, and
since the device interrupt can migrate you could end up with clean-up
occurring on a different CPUs so you need to have some sort of
synchronization mechanism.

Thanks.

- Alex
