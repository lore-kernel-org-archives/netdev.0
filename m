From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: XDP seeking input from NIC hardware vendors
Date: Mon, 11 Jul 2016 19:24:25 -0700
Message-ID: <20160712022423.GA47757@ast-mbp.thefacebook.com>
References: <20160707124245.6d95635a@redhat.com>
 <D6BB30FE66EA894C9F13C9E3CDDF00F564E5FB81@fmsmsx115.amr.corp.intel.com>
 <20160708022210.GA12244@ast-mbp.thefacebook.com>
 <20160708144453.345b51e5@jkicinski-Precision-T1700>
 <20160708171943.0e1ce8d7@redhat.com>
 <20160708170751.2eaae790@jkicinski-Precision-T1700>
 <577FD8A5.8020700@gmail.com>
 <20160708185107.10c0dbe4@jkicinski-Precision-T1700>
 <20160709132726.3cbccf11@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
	John Fastabend <john.fastabend@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"iovisor-dev@lists.iovisor.org" <iovisor-dev@lists.iovisor.org>,
	Brenden Blanco <bblanco@plumgrid.com>,
	Rana Shahout <ranas@mellanox.com>, Ari Saha <as754m@att.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Simon Horman <horms@verge.net.au>,
	Simon Horman <simon.horman@netronome.com>,
	Edward Cree <ecree@solarflare.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33645 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932496AbcGLCYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 22:24:32 -0400
Received: by mail-pa0-f50.google.com with SMTP id ks6so1189029pab.0
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 19:24:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160709132726.3cbccf11@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 09, 2016 at 01:27:26PM +0200, Jesper Dangaard Brouer wrote:
> On Fri, 8 Jul 2016 18:51:07 +0100
> Jakub Kicinski <jakub.kicinski@netronome.com> wrote:
> 
> > On Fri, 8 Jul 2016 09:45:25 -0700, John Fastabend wrote:
> > > The only distinction between VFs and queue groupings on my side is VFs
> > > provide RSS where as queue groupings have to be selected explicitly.
> > > In a programmable NIC world the distinction might be lost if a "RSS"
> > > program can be loaded into the NIC to select queues but for existing
> > > hardware the distinction is there.  
> > 
> > To do BPF RSS we need a way to select the queue which I think is all
> > Jesper wanted.  So we will have to tackle the queue selection at some
> > point.  The main obstacle with it for me is to define what queue
> > selection means when program is not offloaded to HW...  Implementing
> > queue selection on HW side is trivial.
> 
> Yes, I do see the problem of fallback, when the programs "filter" demux
> cannot be offloaded to hardware.
> 
> First I though it was a good idea to keep the "demux-filter" part of
> the eBPF program, as software fallback can still apply this filter in
> SW, and just mark the packets as not-zero-copy-safe.  But when HW
> offloading is not possible, then packets can be delivered every RX
> queue, and SW would need to handle that, which hard to keep transparent.
> 
> 
> > > If you demux using a eBPF program or via a filter model like
> > > flow_director or cls_{u32|flower} I think we can support both. And this
> > > just depends on the programmability of the hardware. Note flow_director
> > > and cls_{u32|flower} steering to VFs is already in place.  
> 
> Maybe we should keep HW demuxing as a separate setup step.
> 
> Today I can almost do what I want: by setting up ntuple filters, and (if
> Alexei allows it) assign an application specific XDP eBPF program to a
> specific RX queue.
> 
>  ethtool -K eth2 ntuple on
>  ethtool -N eth2 flow-type udp4 dst-ip 192.168.254.1 dst-port 53 action 42
> 
> Then the XDP program can be attached to RX queue 42, and
> promise/guarantee that it will consume all packet.  And then the
> backing page-pool can allow zero-copy RX (and enable scrubbing when
> refilling pool).

so such ntuple rule will send udp4 traffic for specific ip and port
into a queue then it will somehow gets zero-copied to vm?
. looks like a lot of other pieces about zero-copy and qemu need to be
implemented (or at least architected) for this scheme to be conceivable
. and when all that happens what vm is going to do with this very specific
traffic? vm won't have any tcp or even ping?

the network virtualization traffic is typically encapsulated,
so if xdp is used to do steer the traffic, the program would need
to figure out vm id based on headers, strip tunnel, apply policy before
forwarding the packet further. Clearly hw ntuple is not going to suffice.

If there is no networking virtualization and VMs are operating in the
flat network, then there is no policy, no ip filter, no vm migration.
Only mac per vm and sriov handles this case just fine.
When hw becomes more programmable we'll be able to load xdp program
into hw that does tunnel, policy and forwards into vf then sriov will
become actually usable for cloud providers.
hw xdp into vf is more interesting than into a queue, since there is
more than one queue/interrupt per vf and network heavy vm can actually
consume large amount of traffic.
