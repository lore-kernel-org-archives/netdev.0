From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
Date: Mon, 12 Dec 2016 16:14:33 +0200
Message-ID: <20161212141433.GB19987@rapoport-lnx>
References: <20161205153132.283fcb0e@redhat.com>
 <20161212083812.GA19987@rapoport-lnx>
 <20161212104042.0a011212@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-mm <linux-mm@kvack.org>,
        John Fastabend <john.fastabend@gmail.com>,
        Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        =?iso-8859-1?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>,
        "Karlsson, Magnus" <magnus.karlsson@intel.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Tom Herbert <tom@herbertland.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Kalman Meth <METH@il.ibm.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:52952 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752626AbcLLOOq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 09:14:46 -0500
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBCEEXZY092675
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2016 09:14:45 -0500
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
        by mx0b-001b2d01.pphosted.com with ESMTP id 279uyn6rtr-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2016 09:14:45 -0500
Received: from localhost
        by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <rppt@linux.vnet.ibm.com>;
        Mon, 12 Dec 2016 14:14:42 -0000
Content-Disposition: inline
In-Reply-To: <20161212104042.0a011212@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 12, 2016 at 10:40:42AM +0100, Jesper Dangaard Brouer wrote:
> 
> On Mon, 12 Dec 2016 10:38:13 +0200 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> 
> > Hello Jesper,
> > 
> > On Mon, Dec 05, 2016 at 03:31:32PM +0100, Jesper Dangaard Brouer wrote:
> > > Hi all,
> > > 
> > > This is my design for how to safely handle RX zero-copy in the network
> > > stack, by using page_pool[1] and modifying NIC drivers.  Safely means
> > > not leaking kernel info in pages mapped to userspace and resilience
> > > so a malicious userspace app cannot crash the kernel.
> > > 
> > > Design target
> > > =============
> > > 
> > > Allow the NIC to function as a normal Linux NIC and be shared in a
> > > safe manor, between the kernel network stack and an accelerated
> > > userspace application using RX zero-copy delivery.
> > > 
> > > Target is to provide the basis for building RX zero-copy solutions in
> > > a memory safe manor.  An efficient communication channel for userspace
> > > delivery is out of scope for this document, but OOM considerations are
> > > discussed below (`Userspace delivery and OOM`_).  
> > 
> > Sorry, if this reply is a bit off-topic.
> 
> It is very much on topic IMHO :-)
> 
> > I'm working on implementation of RX zero-copy for virtio and I've dedicated
> > some thought about making guest memory available for physical NIC DMAs.
> > I believe this is quite related to your page_pool proposal, at least from
> > the NIC driver perspective, so I'd like to share some thoughts here.
> 
> Seems quite related. I'm very interested in cooperating with you! I'm
> not very familiar with virtio, and how packets/pages gets channeled
> into virtio.

They are copied :-)
Presuming we are dealing only with vhost backend, the received skb
eventually gets converted to IOVs, which in turn are copied to the guest
memory. The IOVs point to the guest memory that is allocated by virtio-net
running in the guest.

> > The idea is to dedicate one (or more) of the NIC's queues to a VM, e.g.
> > using macvtap, and then propagate guest RX memory allocations to the NIC
> > using something like new .ndo_set_rx_buffers method.
> 
> I believe the page_pool API/design aligns with this idea/use-case.
> 
> > What is your view about interface between the page_pool and the NIC
> > drivers?
> 
> In my Prove-of-Concept implementation, the NIC driver (mlx5) register
> a page_pool per RX queue.  This is done for two reasons (1) performance
> and (2) for supporting use-cases where only one single RX-ring queue is
> (re)configured to support RX-zero-copy.  There are some associated
> extra cost of enabling this mode, thus it makes sense to only enable it
> when needed.
> 
> I've not decided how this gets enabled, maybe some new driver NDO.  It
> could also happen when a XDP program gets loaded, which request this
> feature.
> 
> The macvtap solution is nice and we should support it, but it requires
> VM to have their MAC-addr registered on the physical switch.  This
> design is about adding flexibility. Registering an XDP eBPF filter
> provides the maximum flexibility for matching the destination VM.

I'm not very familiar with XDP eBPF, and it's difficult for me to estimate
what needs to be done in BPF program to do proper conversion of skb to the
virtio descriptors.

We were not considered using XDP yet, so we've decided to limit the initial
implementation to macvtap because we can ensure correspondence between a
NIC queue and virtual NIC, which is not the case with more generic tap
device. It could be that use of XDP will allow for a generic solution for
virtio case as well.
 
> 
> > Have you considered using "push" model for setting the NIC's RX memory?
> 
> I don't understand what you mean by a "push" model?

Currently, memory allocation in NIC drivers boils down to alloc_page with
some wrapping code. I see two possible ways to make NIC use of some
preallocated pages: either NIC driver will call an API (probably different
from alloc_page) to obtain that memory, or there will be NDO API that
allows to set the NIC's RX buffers. I named the later case "push".
 
