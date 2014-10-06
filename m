From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for direct
 ring access
Date: Tue, 07 Oct 2014 01:26:11 +0200
Message-ID: <1412637971.706532.175886517.077550BE@webmail.messagingengine.com>
References: <20141006000629.32055.2295.stgit@nitbit.x32>
 <20141006002951.GA24376@breakpoint.cc> <5431EC82.7010305@gmail.com>
 <543265A5.8000606@redhat.com> <5432AEE0.9000600@intel.com>
 <1412615032.3403.27.camel@localhost> <5432FD6D.2020102@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Florian Westphal <fw@strlen.de>, gerlitz.or@gmail.com,
	netdev@vger.kernel.org, john.ronciak@intel.com, amirv@mellanox.com,
	eric.dumazet@gmail.com, danny.zhou@intel.com,
	Willem de Bruijn <willemb@google.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:54702 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750859AbaJFX0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 19:26:12 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway2.nyi.internal (Postfix) with ESMTP id 211652099F
	for <netdev@vger.kernel.org>; Mon,  6 Oct 2014 19:26:12 -0400 (EDT)
In-Reply-To: <5432FD6D.2020102@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi John,

On Mon, Oct 6, 2014, at 22:37, John Fastabend wrote:
> > I find the six additional ndo ops a bit worrisome as we are adding more
> > and more subsystem specific ndoops to this struct. I would like to see
> > some unification here, but currently cannot make concrete proposals,
> > sorry.
> 
> I agree it seems like a bit much. One thought was to split the ndo
> ops into categories. Switch ops, MACVLAN ops, basic ops and with this
> userspace queue ops. This sort of goes along with some of the switch
> offload work which is going to add a handful more ops as best I can
> tell.

Thanks for your mail, you answered all of my questions.

Have you looked at <https://code.google.com/p/kernel/wiki/ProjectUnetq>?
Willem (also in Cc) used sysfs files which get mmaped to represent the
tx/rx descriptors. The representation was independent of the device and
IIRC the prototype used a write(fd, "", 1) to signal the kernel it
should proceed with tx. I agree, it would be great to be syscall-free
here.

For the semantics of the descriptors we could also easily generate files
in sysfs. I thought about something like tracepoints already do for
representing the data in the ringbuffer depending on the event:

-- >8 --
# cat /sys/kernel/debug/tracing/events/net/net_dev_queue/format 
name: net_dev_queue
ID: 1006
format:
	field:unsigned short common_type;       offset:0;       size:2;
	signed:0;
	field:unsigned char common_flags;       offset:2;       size:1;
	signed:0;
	field:unsigned char common_preempt_count;       offset:3;      
	size:1; signed:0;
	field:int common_pid;   offset:4;       size:4; signed:1;

	field:void * skbaddr;   offset:8;       size:8; signed:0;
	field:unsigned int len; offset:16;      size:4; signed:0;
	field:__data_loc char[] name;   offset:20;      size:4;
	signed:1;

print fmt: "dev=%s skbaddr=%p len=%u", __get_str(name), REC->skbaddr,
REC->len
-- >8 --

Maybe the macros from tracing are reusable (TP_STRUCT__entry), e.g.
endianess would need to be added. Hopefully there is already a user
space parser somewhere in the perf sources. An easier to parse binary
representation could be added easily and maybe even something vDSO alike
if people care about that.

Maybe this open/mmap per queue also kills some of the ndo_ops?

Bye,
Hannes
