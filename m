From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net PATCH v5 6/6] virtio_net: XDP support for adjust_head
Date: Mon, 23 Jan 2017 19:02:09 +0200
Message-ID: <20170123182421-mutt-send-email-mst@kernel.org>
References: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
 <20170117222259.20280.24625.stgit@john-Precision-Tower-5810>
 <20170118171259-mutt-send-email-mst@kernel.org>
 <40e9a46a-1115-c21a-49f3-fdedb0a34101@redhat.com>
 <20170119231027-mutt-send-email-mst@kernel.org>
 <063D6719AE5E284EB5DD2968C1650D6DB026921C@AcuExch.aculab.com>
 <20170120194824-mutt-send-email-mst@kernel.org>
 <bcf017d4-96b9-9ccf-cc7b-06ec9301251d@redhat.com>
 <5884319B.90909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Jason Wang <jasowang@redhat.com>,
        David Laight <David.Laight@ACULAB.COM>,
        "john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37280 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750742AbdAWRCg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 12:02:36 -0500
Content-Disposition: inline
In-Reply-To: <5884319B.90909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 21, 2017 at 08:14:19PM -0800, John Fastabend wrote:
> On 17-01-21 06:51 PM, Jason Wang wrote:
> > 
> > 
> > On 2017年01月21日 01:48, Michael S. Tsirkin wrote:
> >> On Fri, Jan 20, 2017 at 04:59:11PM +0000, David Laight wrote:
> >>> From: Michael S. Tsirkin
> >>>> Sent: 19 January 2017 21:12
> >>>>> On 2017?01?18? 23:15, Michael S. Tsirkin wrote:
> >>>>>> On Tue, Jan 17, 2017 at 02:22:59PM -0800, John Fastabend wrote:
> >>>>>>> Add support for XDP adjust head by allocating a 256B header region
> >>>>>>> that XDP programs can grow into. This is only enabled when a XDP
> >>>>>>> program is loaded.
> >>>>>>>
> >>>>>>> In order to ensure that we do not have to unwind queue headroom push
> >>>>>>> queue setup below bpf_prog_add. It reads better to do a prog ref
> >>>>>>> unwind vs another queue setup call.
> >>>>>>>
> >>>>>>> At the moment this code must do a full reset to ensure old buffers
> >>>>>>> without headroom on program add or with headroom on program removal
> >>>>>>> are not used incorrectly in the datapath. Ideally we would only
> >>>>>>> have to disable/enable the RX queues being updated but there is no
> >>>>>>> API to do this at the moment in virtio so use the big hammer. In
> >>>>>>> practice it is likely not that big of a problem as this will only
> >>>>>>> happen when XDP is enabled/disabled changing programs does not
> >>>>>>> require the reset. There is some risk that the driver may either
> >>>>>>> have an allocation failure or for some reason fail to correctly
> >>>>>>> negotiate with the underlying backend in this case the driver will
> >>>>>>> be left uninitialized. I have not seen this ever happen on my test
> >>>>>>> systems and for what its worth this same failure case can occur
> >>>>>>> from probe and other contexts in virtio framework.
> >>>>>>>
> >>>>>>> Signed-off-by: John Fastabend<john.r.fastabend@intel.com>
> >>>>>> I've been thinking about it - can't we drop
> >>>>>> old buffers without the head room which were posted before
> >>>>>> xdp attached?
> >>>>>>
> >>>>>> Avoiding the reset would be much nicer.
> >>>>>>
> >>>>>> Thoughts?
> >>>>>>
> >>>>> As been discussed before, device may use them in the same time so it's not
> >>>>> safe. Or do you mean detect them after xdp were set and drop the buffer
> >>>>> without head room, this looks sub-optimal.
> >>>>>
> >>>>> Thanks
> >>>> Yes, this is what I mean.  Why is this suboptimal? It's a single branch
> >>>> in code. Yes we might lose some packets but the big hammer of device
> >>>> reset will likely lose more.
> >>> Why not leave let the hardware receive into the 'small' buffer (without
> >>> headroom) and do a copy when a frame is received.
> >>> Replace the buffers with 'big' ones for the next receive.
> >>> A data copy on a ring full of buffers won't really be noticed.
> >>>
> >>>     David
> >>>
> >> I like that. John?
> >>
> > 
> > This works, I prefer this only if it uses simpler code (but I suspect) than reset.
> > 
> > Thanks
> 
> Before the reset path I looked at doing this but it seems to require tracking
> if a buffer had headroom on a per buffer basis. I don't see a good spot to
> put a bit like this? It could go in the inbuf 'ctx' added by virtqueue_add_inbuf
> but I would need to change the current usage of ctx which in the mergeable case
> at least is just a simple pointer today. I don't like this because it
> complicates the normal path and the XDP hotpath.
> 
> Otherwise we could somehow mark the ring at the point where XDP is enabled so
> that it can learn when a full iteration around the ring. But I can't see a
> simple way to make this work either.
> 
> I don't know the reset look straight forward to me and although not ideal is
> fairly common on hardware based drivers during configuration changes. I'm open
> to any ideas on where to put the metadata to track headroom though.
> 
> Thanks,
> John


Well with 4K pages we actually have 4 spare bits to use.
In fact this means we could reduce the mergeable buffer alignment.
It starts getting strange with 64K pages where we are
out of space, and I just noticed that with bigger pages
virtio is actually broken.

So let me fix it up first of all, and on top - maybe we can just
increase the alignment for 64k pages and up?
Truesize alignment to 512 is still reasonable and presumably
these 64k page boxes have lots of memory.
Would it make sense to tweak SK_RMEM_MAX up for larger
page sizes?

-- 
MST
