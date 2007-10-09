From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 08 Oct 2007 18:41:26 -0700 (PDT)
Message-ID: <20071008.184126.124062865.davem@davemloft.net>
References: <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com>
	<1191886845.4373.138.camel@localhost> <470AD5D7.1070000@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	hadi@cyberus.ca, mcarlson@broadcom.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com,
	shemminger@linux-foundation.org, kaber@trash.net
To: jeff@garzik.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <470AD5D7.1070000@garzik.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Mon, 08 Oct 2007 21:13:59 -0400

> If you assume a scheduler implementation where each prio band is mapped 
> to a separate CPU, you can certainly see where some CPUs could be 
> substantially idle while others are overloaded, largely depending on the 
> data workload (and priority contained within).

Right, which is why Peter added the prio DRR scheduler stuff for TX
multiqueue (see net/sched/sch_prio.c:rr_qdisc_ops) because this is
what the chips do.

But this doesn't get us to where we want to be as Peter has been
explaining a bit these past few days.

Ok, we're talking a lot but not pouring much concrete, let's start
doing that.  I propose:

1) A library for transmit load balancing functions, with an interface
   that can be made visible to userspace.  I can write this and test
   it on real multiqueue hardware.

   The whole purpose of this library is to set skb->queue_mapping
   based upon the load balancing function.

   Facilities will be added to handle virtualization port selection
   based upon destination MAC address as one of the "load balancing"
   methods.

2) Switch the default qdisc away from pfifo_fast to a new DRR fifo
   with load balancing using the code in #1.  I think this is kind
   of in the territory of what Peter said he is working on.

   I know this is controversial, but realistically I doubt users
   benefit at all from the prioritization that pfifo provides.  They
   will, on the other hand, benefit from TX queue load balancing on
   fast interfaces.

3) Work on discovering a way to make the locking on transmit as
   localized to the current thread of execution as possible.  Things
   like RCU and statistic replication, techniques we use widely
   elsewhere in the stack, begin to come to mind.

I also want to point out another issue.  Any argument wrt. reordering
is specious at best because right now reordering from qdisc to device
happens anyways.

And that's because we drop the qdisc lock first, then we grab the
transmit lock on the device and submit the packet.  So, after we
drop the qdisc lock, another cpu can get the qdisc lock, get the
next packet (perhaps a lower priority one) and then sneak in to
get the device transmit lock before the first thread can, and
thus the packets will be submitted out of order.

This, along with other things, makes me believe that ordering really
doesn't matter in practice.  And therefore, in practice, we can treat
everything from the qdisc to the real hardware as a FIFO even if
something else is going on inside the black box which might reorder
packets on the wire.
