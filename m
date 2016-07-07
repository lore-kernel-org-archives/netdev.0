From: "Fastabend, John R" <john.r.fastabend@intel.com>
Subject: RE: XDP seeking input from NIC hardware vendors
Date: Thu, 7 Jul 2016 15:18:11 +0000
Message-ID: <D6BB30FE66EA894C9F13C9E3CDDF00F564E5FB81@fmsmsx115.amr.corp.intel.com>
References: <20160707124245.6d95635a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Rana Shahout <ranas@mellanox.com>, Ari Saha <as754m@att.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Simon Horman <horms@verge.net.au>,
	Simon Horman <simon.horman@netronome.com>,
	Jakub Kicinski <jakub.kicinski@netronome.com>,
	Edward Cree <ecree@solarflare.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	"iovisor-dev@lists.iovisor.org" <iovisor-dev@lists.iovisor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10694 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751615AbcGGPSY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 11:18:24 -0400
In-Reply-To: <20160707124245.6d95635a@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesper,

I have done some previous work on proprietary systems where we used hardware to do the classification/parsing then passed a cookie to the software which used the cookie to lookup a program to run on the packet. When your programs are structured as a bunch of parsing followed by some actions this can provide real performance benefits. Also a lot of existing hardware supports this today assuming you use headers the hardware "knows" about. It's a natural model for hardware that uses a parser followed by tcam/cam/sram/etc lookup tables.

If the goal is to just separate XDP traffic from non-XDP traffic you could accomplish this with a combination of SR-IOV/macvlan to separate the device queues into multiple netdevs and then run XDP on just one of the netdevs. Then use flow director (ethtool) or 'tc cls_u32/flower' to steer traffic to the netdev. This is how we support multiple networking stacks on one device by the way it is called the bifurcated driver. Its not too far of a stretch to think we could offload some simple XDP programs to program the splitting of traffic instead of cls_u32/flower/flow_director and then you would have a stack of XDP programs. One running in hardware and a set running on the queues in software.

The other interesting thing would be to do more than just packet steering but actually run a more complete XDP program. Netronome supports this right. The question I have though is this a stacked of XDP programs one or more designated for hardware and some running in software perhaps with some annotation in the program so the hardware JIT knows where to place programs or do we expect the JIT itself to try and decide what is best to offload. I think the easiest to start with is to annotate the programs.

Also as far as I know a lot of hardware can stick extra data to the front or end of a packet so you could push metadata calculated by the program here in a generic way without having to extend XDP defined metadata structures. Another option is to DMA the metadata to a specified address. With this metadata the consumer/producer XDP programs have to agree on the format but no one else.

FWIW I was hoping to get some data to show performance overhead vs how deep we parse into the packets. I just wont have time to get to it for awhile but that could tell us how much perf gain the hardware could provide.

Thanks,
John

-----Original Message-----
From: Jesper Dangaard Brouer [mailto:brouer@redhat.com] 
Sent: Thursday, July 7, 2016 3:43 AM
To: iovisor-dev@lists.iovisor.org
Cc: brouer@redhat.com; Brenden Blanco <bblanco@plumgrid.com>; Alexei Starovoitov <alexei.starovoitov@gmail.com>; Rana Shahout <ranas@mellanox.com>; Ari Saha <as754m@att.com>; Tariq Toukan <tariqt@mellanox.com>; Or Gerlitz <ogerlitz@mellanox.com>; netdev@vger.kernel.org; Simon Horman <horms@verge.net.au>; Simon Horman <simon.horman@netronome.com>; Jakub Kicinski <jakub.kicinski@netronome.com>; Edward Cree <ecree@solarflare.com>; Fastabend, John R <john.r.fastabend@intel.com>
Subject: XDP seeking input from NIC hardware vendors


Would it make sense from a hardware point of view, to split the XDP eBPF program into two stages.

 Stage-1: Filter (restricted eBPF / no-helper calls)
 Stage-2: Program

Then the HW can choose to offload stage-1 "filter", and keep the likely more advanced stage-2 on the kernel side.  Do HW vendors see a benefit of this approach?


The generic problem I'm trying to solve is parsing. E.g. that the first step in every XDP program will be to parse the packet-data, in-order to determine if this is a packet the XDP program should process.

Actions from stage-1 "filter" program:
 - DROP (like XDP_DROP, early drop)
 - PASS (like XDP_PASS, normal netstack)
 - MATCH (call stage-2, likely carry-over opaque return code)

The MATCH action should likely carry-over an opaque return code, that makes sense for the stage-2 program. E.g. proto id and/or data offset.
