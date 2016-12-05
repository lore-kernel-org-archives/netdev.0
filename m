From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [flamebait] xdp, well meaning but pointless
Date: Mon, 5 Dec 2016 12:04:09 +0100
Message-ID: <20161205120409.3097c5e7@redhat.com>
References: <20161201091108.GF26507@breakpoint.cc>
        <20161202182233.7d78459f@redhat.com>
        <CAF=yD-+Wx9Pkt55-dUU6dYM7P==kQoKE4YXKoFSq1yi7rY5rDA@mail.gmail.com>
        <58432186.20006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Florian Westphal <fw@strlen.de>,
        Network Development <netdev@vger.kernel.org>, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55700 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750928AbcLELQS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Dec 2016 06:16:18 -0500
In-Reply-To: <58432186.20006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 3 Dec 2016 11:48:22 -0800
John Fastabend <john.fastabend@gmail.com> wrote:

> On 16-12-03 08:19 AM, Willem de Bruijn wrote:
> > On Fri, Dec 2, 2016 at 12:22 PM, Jesper Dangaard Brouer
> > <brouer@redhat.com> wrote:  
> >>
> >> On Thu, 1 Dec 2016 10:11:08 +0100 Florian Westphal <fw@strlen.de> wrote:
> >>  
> >>> In light of DPDKs existence it make a lot more sense to me to provide
> >>> a). a faster mmap based interface (possibly AF_PACKET based) that allows
> >>> to map nic directly into userspace, detaching tx/rx queue from kernel.
> >>>
> >>> John Fastabend sent something like this last year as a proof of
> >>> concept, iirc it was rejected because register space got exposed directly
> >>> to userspace.  I think we should re-consider merging netmap
> >>> (or something conceptually close to its design).  
> >>
> >> I'm actually working in this direction, of zero-copy RX mapping packets
> >> into userspace.  This work is mostly related to page_pool, and I only
> >> plan to use XDP as a filter for selecting packets going to userspace,
> >> as this choice need to be taken very early.
> >>
> >> My design is here:
> >>  https://prototype-kernel.readthedocs.io/en/latest/vm/page_pool/design/memory_model_nic.html
> >>
> >> This is mostly about changing the memory model in the drivers, to allow
> >> for safely mapping pages to userspace.  (An efficient queue mechanism is
> >> not covered).  
> > 
> > Virtio virtqueues are used in various other locations in the stack.
> > With separate memory pools and send + completion descriptor rings,
> > signal moderation, careful avoidance of cacheline bouncing, etc. these
> > seem like a good opportunity for a TPACKET_V4 format.
> >   
> 
> FWIW. After we rejected exposing the register space to user space due to
> valid security issues we fell back to using VFIO which works nicely for
> mapping virtual functions into userspace and VMs. The main  drawback is
> user space has to manage the VF but that is mostly a solved problem at
> this point. Deployment concerns aside.

Using VFs (PCIe SR-IOV Virtual Functions) solves this in a completely
different orthogonal way.  To me it is still like taking over the entire
NIC, although you use HW to split the traffic into VFs.  Setup for VF
deployment still looks troubling like 1G hugepages and vfio
enable_unsafe_noiommu_mode=1.  And generally getting SR-IOV working on
your HW is a task of it's own.

One thing people often seem to miss with SR-IOV VFs is that VM-to-VM
traffic will be limited by PCIe bandwidth and transaction overheads.
Like Stepen Hemminger demonstrated[1] at NetDev 1.2 and Luigi also have
a paper demonstrating this (AFAICR).
[1] http://netdevconf.org/1.2/session.html?stephen-hemminger


A key difference in my design is to, allow the NIC to be shared in a
safe manor.  The NIC functions 100% as a normal Linux controlled NIC.
The catch is that once an application request zero-copy RX, then the
NIC might have to reconfigure it's RX-ring usage.  As the driver MUST
change into what I call the "read-only packet page" mode, which
actually is the default in many drivers today.


> There was a TPACKET_V4 version we had a prototype of that passed
> buffers down to the hardware to use with the dma engine. This gives
> zero-copy but same as VFs requires the hardware to do all the steering
> of traffic and any expected policy in front of the application. Due to
> requiring user space to kick hardware and vice versa though it was
> somewhat slower so I didn't finish it up. The kick was implemented as a
> syscall iirc. I can maybe look at it a bit more next week and see if its
> worth reviving now in this context.

This is still at the design stage.  The target here is that the
page_pool and driver adjustments will provide the basis for building RX
zero-copy solutions in a memory safe manor.

I do see tcpdump/RAW packet access like TPACKET_V4 being one of the
first users of this.  Not the only user, as further down the road, I
also imagine RX zero-copy delivery into sockets (and perhaps combined
with a "raw_demux" step that doesn't alloc the SKB, which Tom hinted in
the other thread for UDP delivery).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
