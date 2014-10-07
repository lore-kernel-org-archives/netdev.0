From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for direct
 ring access
Date: Tue, 7 Oct 2014 14:59:40 -0400
Message-ID: <20141007185940.GE27719@hmsreliant.think-freely.org>
References: <20141006000629.32055.2295.stgit@nitbit.x32>
 <20141006002951.GA24376@breakpoint.cc>
 <5431EC82.7010305@gmail.com>
 <543265A5.8000606@redhat.com>
 <5432AEE0.9000600@intel.com>
 <1412615032.3403.27.camel@localhost>
 <5432FD6D.2020102@intel.com>
 <1412637971.706532.175886517.077550BE@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Florian Westphal <fw@strlen.de>, gerlitz.or@gmail.com,
	netdev@vger.kernel.org, john.ronciak@intel.com, amirv@mellanox.com,
	eric.dumazet@gmail.com, danny.zhou@intel.com,
	Willem de Bruijn <willemb@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46833 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754840AbaJGTAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 15:00:13 -0400
Content-Disposition: inline
In-Reply-To: <1412637971.706532.175886517.077550BE@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2014 at 01:26:11AM +0200, Hannes Frederic Sowa wrote:
> Hi John,
> 
> On Mon, Oct 6, 2014, at 22:37, John Fastabend wrote:
> > > I find the six additional ndo ops a bit worrisome as we are adding more
> > > and more subsystem specific ndoops to this struct. I would like to see
> > > some unification here, but currently cannot make concrete proposals,
> > > sorry.
> > 
> > I agree it seems like a bit much. One thought was to split the ndo
> > ops into categories. Switch ops, MACVLAN ops, basic ops and with this
> > userspace queue ops. This sort of goes along with some of the switch
> > offload work which is going to add a handful more ops as best I can
> > tell.
> 
> Thanks for your mail, you answered all of my questions.
> 
> Have you looked at <https://code.google.com/p/kernel/wiki/ProjectUnetq>?
> Willem (also in Cc) used sysfs files which get mmaped to represent the
> tx/rx descriptors. The representation was independent of the device and
> IIRC the prototype used a write(fd, "", 1) to signal the kernel it
> should proceed with tx. I agree, it would be great to be syscall-free
> here.
> 
> For the semantics of the descriptors we could also easily generate files
> in sysfs. I thought about something like tracepoints already do for
> representing the data in the ringbuffer depending on the event:
> 
> -- >8 --
> # cat /sys/kernel/debug/tracing/events/net/net_dev_queue/format 
> name: net_dev_queue
> ID: 1006
> format:
> 	field:unsigned short common_type;       offset:0;       size:2;
> 	signed:0;
> 	field:unsigned char common_flags;       offset:2;       size:1;
> 	signed:0;
> 	field:unsigned char common_preempt_count;       offset:3;      
> 	size:1; signed:0;
> 	field:int common_pid;   offset:4;       size:4; signed:1;
> 
> 	field:void * skbaddr;   offset:8;       size:8; signed:0;
> 	field:unsigned int len; offset:16;      size:4; signed:0;
> 	field:__data_loc char[] name;   offset:20;      size:4;
> 	signed:1;
> 
> print fmt: "dev=%s skbaddr=%p len=%u", __get_str(name), REC->skbaddr,
> REC->len
> -- >8 --
> 
> Maybe the macros from tracing are reusable (TP_STRUCT__entry), e.g.
> endianess would need to be added. Hopefully there is already a user
> space parser somewhere in the perf sources. An easier to parse binary
> representation could be added easily and maybe even something vDSO alike
> if people care about that.
> 
> Maybe this open/mmap per queue also kills some of the ndo_ops?
> 
> Bye,
> Hannes
> 


John-
	I don't know if its of use to you here, but I was experimenting awhile
ago with af_packet memory mapping, using the protection bits in the page tables
as a doorbell mechanism.  I scrapped the work as the performance bottleneck for
af_packet wasn't found in the syscall trap time, but it occurs to me, it might
be useful for you here, in that, using this mechanism, if you keep the transmit
ring non-empty, you only encur the cost of a single trap to start the transmit
process.  Let me know if you want to see it.

Neil
