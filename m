From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: XDP redirect measurements, gotchas and tracepoints
Date: Tue, 29 Aug 2017 12:52:49 -0700
Message-ID: <CAKgT0Ue3G-bs=YQK5Ab3o7EtL8hsjcUzqpKbceaGc3Ki06mmnQ@mail.gmail.com>
References: <CACKFLinJ0N7b8Xhq4ZoHdB80uXp_MU_vVyzZa7Dq11XrXsvDbw@mail.gmail.com>
 <20170823102937.79a9c4ed@redhat.com> <CACKFLinGuaDLxYRd=vC99DL5n0mf0rDbPRaDg4ctev=DEAhRSQ@mail.gmail.com>
 <20170825144513.1ee9fbb1@redhat.com> <59A03DF5.7070806@gmail.com>
 <CACKFLin-sZEkkCxE2iZRHjgG=K36OJ65B-xrEYVCCSQqhYsH-g@mail.gmail.com>
 <20170828160237.GA70910@C02RW35GFVH8.dhcp.broadcom.net> <CAKgT0UeZ5Wn+8qY8kbBef5weORwGAXjq6Qp7jtB1bscmjY_oYw@mail.gmail.com>
 <20170829152601.02fdb8a3@redhat.com> <CAKgT0Uebz0dX9wotygOo59UTKt-bQ29Oyd6=MkJYE0a+y2dR2A@mail.gmail.com>
 <20170829190253.GA77682@C02RW35GFVH8.dhcp.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Michael Chan <michael.chan@broadcom.com>,
        John Fastabend <john.fastabend@gmail.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        "borkmann@iogearbox.net" <borkmann@iogearbox.net>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:34474 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750822AbdH2Twv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 15:52:51 -0400
In-Reply-To: <20170829190253.GA77682@C02RW35GFVH8.dhcp.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 12:02 PM, Andy Gospodarek <andy@greyhouse.net> wrote:
> On Tue, Aug 29, 2017 at 09:23:49AM -0700, Alexander Duyck wrote:
>> On Tue, Aug 29, 2017 at 6:26 AM, Jesper Dangaard Brouer
>> <brouer@redhat.com> wrote:
>> >
>> > On Mon, 28 Aug 2017 09:11:25 -0700 Alexander Duyck <alexander.duyck@gmail.com> wrote:
>> >
>> >> My advice would be to not over complicate this. My big concern with
>> >> all this buffer recycling is what happens the first time somebody
>> >> introduces something like mirroring? Are you going to copy the data to
>> >> a new page which would be quite expensive or just have to introduce
>> >> reference counts? You are going to have to deal with stuff like
>> >> reference counts eventually so you might as well bite that bullet now.
>> >> My advice would be to not bother with optimizing for performance right
>> >> now and instead focus on just getting functionality. The approach we
>> >> took in ixgbe for the transmit path should work for almost any other
>> >> driver since all you are looking at is having to free the page
>> >> reference which takes care of reference counting already.
>> >
>> > This return API is not about optimizing performance right now.  It is
>> > actually about allowing us to change the underlying memory model per RX
>> > queue for XDP.
>>
>>  I would disagree. To me this is a obvious case of premature optimization.
>>
>
> I'm with Jesper on this.  Though it may seem to you that this is an
> optimization that is not a goal.
>
>> > If a RX-ring is use for both SKBs and XDP, then the refcnt model is
>> > still enforced.  Although a driver using the 1-packet-per-page model,
>> > should be able to reuse refcnt==1 pages when returned from XDP.
>>
>> Isn't this the case for all Rx on XDP enabled rings. Last I knew there
>> was an option to pass packets up via an SKB if XDP_PASS is returned.
>> Are you saying we need to do a special allocation path if an XDP
>> program doesn't make use of XDP_PASS?
>
> I am not proposing that a special allocation path is needed depending on the
> return code from the XDP program.  I'm proposing that in a case where
> the return code is XDP_REDIRECT (or really anytime the ndo_xdp_xmit
> operation is called), that there should be:
>
> (1) notification back to the driver/resource/etc that allocated the page
> that resources are no longer in use.
>
> or
>
> (2) common alloc/free framework used by drivers that operate on
> xdp->data so that framework takes care of refcounting, etc.
>
> My preference is (1) since it provides drivers the most flexibility in
> the event that some hardware resource (rx ring buffer pointer) or
> software resource (page or other chunk of memory) can be freed.

So my preference would be (2) rather than (1). The simple reason being
that I would prefer it if we didn't have every driver doing their own
memory management API. With that said though I realize we need to have
a solid proof-of-concept before we can get there so I am okay with
each driver doing their own thing until we have a clear winner of some
sort in all these discussions.

The biggest issue I see with (1) is that it assumes that the Tx should
somehow be responsible for the recycling. The whole thing ends up
being way too racy. The problem is you will have two drivers sharing a
region of memory and each will have to do some sort of additional
reference counting if not using the existing page count. The result is
you can have either the Rx device needing to free resources which will
have to somehow be tracked from the Rx side, and the Tx side will have
to handle the freeing and dumping the packet back into the Rx pool if
it is the Tx that needs to free the resources. The standard case in
this gets messy, but the exception cases such as removing or resetting
a driver can get messy quickly.
