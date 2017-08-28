From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: XDP redirect measurements, gotchas and tracepoints
Date: Mon, 28 Aug 2017 15:39:43 -0400
Message-ID: <20170828193943.GB70910@C02RW35GFVH8.dhcp.broadcom.net>
References: <CACKFLimMWLto4FRxNE3tzrO5MU+p67J7wu=n1nmg0t8QGYjgrA@mail.gmail.com>
 <CAKgT0Uf=ZfVeK-wtvNxSyGEVZ3UseUOHiP3ZOg-SrzmqsR=LtQ@mail.gmail.com>
 <CACKFLinJ0N7b8Xhq4ZoHdB80uXp_MU_vVyzZa7Dq11XrXsvDbw@mail.gmail.com>
 <20170823102937.79a9c4ed@redhat.com>
 <CACKFLinGuaDLxYRd=vC99DL5n0mf0rDbPRaDg4ctev=DEAhRSQ@mail.gmail.com>
 <20170825144513.1ee9fbb1@redhat.com>
 <59A03DF5.7070806@gmail.com>
 <CACKFLin-sZEkkCxE2iZRHjgG=K36OJ65B-xrEYVCCSQqhYsH-g@mail.gmail.com>
 <20170828160237.GA70910@C02RW35GFVH8.dhcp.broadcom.net>
 <59A4415C.80702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <michael.chan@broadcom.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>,
        "borkmann@iogearbox.net" <borkmann@iogearbox.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37870 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751366AbdH1Tjw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:39:52 -0400
Received: by mail-wm0-f54.google.com with SMTP id u26so9787956wma.0
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 12:39:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <59A4415C.80702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 28, 2017 at 09:14:20AM -0700, John Fastabend wrote:
> On 08/28/2017 09:02 AM, Andy Gospodarek wrote:
> > On Fri, Aug 25, 2017 at 08:28:55AM -0700, Michael Chan wrote:
> >> On Fri, Aug 25, 2017 at 8:10 AM, John Fastabend
> >> <john.fastabend@gmail.com> wrote:
> >>> On 08/25/2017 05:45 AM, Jesper Dangaard Brouer wrote:
> >>>> On Thu, 24 Aug 2017 20:36:28 -0700
> >>>> Michael Chan <michael.chan@broadcom.com> wrote:
> >>>>
> >>>>> On Wed, Aug 23, 2017 at 1:29 AM, Jesper Dangaard Brouer
> >>>>> <brouer@redhat.com> wrote:
> >>>>>> On Tue, 22 Aug 2017 23:59:05 -0700
> >>>>>> Michael Chan <michael.chan@broadcom.com> wrote:
> >>>>>>
> >>>>>>> On Tue, Aug 22, 2017 at 6:06 PM, Alexander Duyck
> >>>>>>> <alexander.duyck@gmail.com> wrote:
> >>>>>>>> On Tue, Aug 22, 2017 at 1:04 PM, Michael Chan <michael.chan@broadcom.com> wrote:
> >>>>>>>>>
> >>>>>>>>> Right, but it's conceivable to add an API to "return" the buffer to
> >>>>>>>>> the input device, right?
> >>>>>>
> >>>>>> Yes, I would really like to see an API like this.
> >>>>>>
> >>>>>>>>
> >>>>>>>> You could, it is just added complexity. "just free the buffer" in
> >>>>>>>> ixgbe usually just amounts to one atomic operation to decrement the
> >>>>>>>> total page count since page recycling is already implemented in the
> >>>>>>>> driver. You still would have to unmap the buffer regardless of if you
> >>>>>>>> were recycling it or not so all you would save is 1.000015259 atomic
> >>>>>>>> operations per packet. The fraction is because once every 64K uses we
> >>>>>>>> have to bulk update the count on the page.
> >>>>>>>>
> >>>>>>>
> >>>>>>> If the buffer is returned to the input device, the input device can
> >>>>>>> keep the DMA mapping.  All it needs to do is to dma_sync it back to
> >>>>>>> the input device when the buffer is returned.
> >>>>>>
> >>>>>> Yes, exactly, return to the input device. I really think we should
> >>>>>> work on a solution where we can keep the DMA mapping around.  We have
> >>>>>> an opportunity here to make ndo_xdp_xmit TX queues use a specialized
> >>>>>> page return call, to achieve this. (I imagine other arch's have a high
> >>>>>> DMA overhead than Intel)
> >>>>>>
> >>>>>> I'm not sure how the API should look.  The ixgbe recycle mechanism and
> >>>>>> splitting the page (into two packets) actually complicates things, and
> >>>>>> tie us into a page-refcnt based model.  We could get around this by
> >>>>>> each driver implementing a page-return-callback, that allow us to
> >>>>>> return the page to the input device?  Then, drivers implementing the
> >>>>>> 1-packet-per-page can simply check/read the page-refcnt, and if it is
> >>>>>> "1" DMA-sync and reuse it in the RX queue.
> >>>>>>
> >>>>>
> >>>>> Yeah, based on Alex' description, it's not clear to me whether ixgbe
> >>>>> redirecting to a non-intel NIC or vice versa will actually work.  It
> >>>>> sounds like the output device has to make some assumptions about how
> >>>>> the page was allocated by the input device.
> >>>>
> >>>> Yes, exactly. We are tied into a page refcnt based scheme.
> >>>>
> >>>> Besides the ixgbe page recycle scheme (which keeps the DMA RX-mapping)
> >>>> is also tied to the RX queue size, plus how fast the pages are returned.
> >>>> This makes it very hard to tune.  As I demonstrated, default ixgbe
> >>>> settings does not work well with XDP_REDIRECT.  I needed to increase
> >>>> TX-ring size, but it broke page recycling (dropping perf from 13Mpps to
> >>>> 10Mpps) so I also needed it increase RX-ring size.  But perf is best if
> >>>> RX-ring size is smaller, thus two contradicting tuning needed.
> >>>>
> >>>
> >>> The changes to decouple the ixgbe page recycle scheme (1pg per descriptor
> >>> split into two halves being the default) from the number of descriptors
> >>> doesn't look too bad IMO. It seems like it could be done by having some
> >>> extra pages allocated upfront and pulling those in when we need another
> >>> page.
> >>>
> >>> This would be a nice iterative step we could take on the existing API.
> >>>
> >>>>
> >>>>> With buffer return API,
> >>>>> each driver can cleanly recycle or free its own buffers properly.
> >>>>
> >>>> Yes, exactly. And RX-driver can implement a special memory model for
> >>>> this queue.  E.g. RX-driver can know this is a dedicated XDP RX-queue
> >>>> which is never used for SKBs, thus opening for new RX memory models.
> >>>>
> >>>> Another advantage of a return API.  There is also an opportunity for
> >>>> avoiding the DMA map on TX. As we need to know the from-device.  Thus,
> >>>> we can add a DMA API, where we can query if the two devices uses the
> >>>> same DMA engine, and can reuse the same DMA address the RX-side already
> >>>> knows.
> >>>>
> >>>>
> >>>>> Let me discuss this further with Andy to see if we can come up with a
> >>>>> good scheme.
> >>>>
> >>>> Sound good, looking forward to hear what you come-up with :-)
> >>>>
> >>>
> >>> I guess by this thread we will see a broadcom nic with redirect support
> >>> soon ;)
> >>
> >> Yes, Andy actually has finished the coding for XDP_REDIRECT, but the
> >> buffer recycling scheme has some problems.  We can make it work for
> >> Broadcom to Broadcom only, but we want a better solution.
> > 
> > (Sorry for the radio silence I was AFK last week...)
> > 
> > I finished it a little while ago, but Michael and I both have concerns
> > that in a heterogenous hardware setup one can quickly run into issues
> > and haven't had time to work-up a few solutions before bringing this up
> > formally.  It also isn't a major problem until the second
> > optimized/native XDP driver appears on the scene.
> > 
> > I can run a test where XDP redirects from an ixgbe <-> bnxt_en based
> > device I get OOM kills after only a few seconds, due to the lack of
> > feedback between the different drivers that the pointer to xdp->data can
> > be freed/reused/etc and the different buffer allocation schemes used.
> > 
> 
> hmm so how do you get OOM here, I expect the number of in-flight xdp
> bufs should be limited by the number of xdps that can be posted to the
> outgoing interface. If we are hitting OOM that _should_ mean the size of
> the tx queue is too large. Ixgbe should be free'ing the buffer if an error
> is returned from xdp xmit routines (will check this today). And bnxt should
> return an error if we hit some high water mark on xmit.

I reconfigured the hardware after I was done with the bnxt_en devel, but I
should be able to set it up and provide some more detail.  Let me repro it and
debug a bit more.

> 
> > Initially I did not think this was an issue and that xdp_do_flush_map()
> > would handle this, but I think there is a still a need to be able to
> > signal back to the receving device that the buffer allocated has been
> > xmitted by the transmitter and can be freed.  Since there is really no
> > guarantee that completion of an XDP_REDIRECT action means that it is
> > safe to free area pointed to by xdp->data area that contains the packet
> > to be xmitted.  Since the packet done interrupt handler in a driver
> > cannot signal back the the receiving driver that the buffer is now safe
> > to reuse/free there is a chance for trouble.  
> 
> There should be some high water mark on how many outstanding packets
> can be in-flight. At the moment I assumed this was something related to
> queue lengths a more explicit high water mark could added to the xmit path
> and tracked in xdp infrastructure.
> 
> > 
> > I was hoping to spend some time this week cooking up a patch that just
> > did not allow use of XDP_REDIRECT when the ifindex of the outgoing
> > device did not match that of the device to which the XDP prog was
> > attached, but that probably is not worth the trouble when we would just
> > fix it for real.  (It would also require some really terrible hacks to
> > enforce this in the kernel when all that is being done is setting up a
> > map that contains the redirect table, so it is probably not useful.)
> > 
> 
> I would prefer to solve the problem vs limiting the implementation
> 

Agreed.

> > The basic prototype would be something like this:
> > 
> > (rx packet interrupt on eth0, leads to napi_poll)
> > napi_poll (eth0)
> >   call xdp_prog (eth0)
> >     xdp_do_redirect (eth0)
> >       ndo_xdp_xmit (eth1)
> >       mark buffer with information netdev/ring/etc
> >       place buffer on tx ring for eth1
> > 
> > (tx done interrupt on eth1, leads to napi_poll)
> > napi_poll (eth1)
> >   process tx interrupt (eth1)
> >     look up information about netdev/ring/etc
> >     ndo_xdp_data_free (eth0, ring, etc)
> > 
> > Thoughts?
> > 
> 
