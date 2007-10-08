From: Jeff Garzik <jeff@garzik.org>
Subject: parallel networking (was Re: [PATCH 1/4] [NET_SCHED] explict hold
 dev tx lock)
Date: Mon, 08 Oct 2007 10:22:28 -0400
Message-ID: <470A3D24.3050803@garzik.org>
References: <1190674298.4264.24.camel@localhost>	 <D5C1322C3E673F459512FB59E0DDC32903A51462@orsmsx414.amr.corp.intel.com>	 <1190677099.4264.37.camel@localhost>	 <20071007.215124.85709188.davem@davemloft.net> <1191850490.4352.41.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	Ingo Molnar <mingo@elte.hu>, mchan@broadcom.com,
	general@lists.openfabrics.org, kumarkr@linux.ibm.com,
	tgraf@suug.ch, randy.dunlap@oracle.com, sri@us.ibm.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45549 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751300AbXJHOYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2007 10:24:09 -0400
In-Reply-To: <1191850490.4352.41.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Sun, 2007-07-10 at 21:51 -0700, David Miller wrote:
> 
>> For these high performance 10Gbit cards it's a load balancing
>> function, really, as all of the transmit queues go out to the same
>> physical port so you could:
>>
>> 1) Load balance on CPU number.
>> 2) Load balance on "flow"
>> 3) Load balance on destination MAC
>>
>> etc. etc. etc.
> 
> The brain-block i am having is the parallelization aspect of it.
> Whatever scheme it is - it needs to ensure the scheduler works as
> expected. For example, if it was a strict prio scheduler i would expect
> that whatever goes out is always high priority first and never ever
> allow a low prio packet out at any time theres something high prio
> needing to go out. If i have the two priorities running on two cpus,
> then i cant guarantee that effect.

Any chance the NIC hardware could provide that guarantee?

8139cp, for example, has two TX DMA rings, with hardcoded 
characteristics:  one is a high prio q, and one a low prio q.  The logic 
is pretty simple:   empty the high prio q first (potentially starving 
low prio q, in worst case).


In terms of overall parallelization, both for TX as well as RX, my gut 
feeling is that we want to move towards an MSI-X, multi-core friendly 
model where packets are LIKELY to be sent and received by the same set 
of [cpus | cores | packages | nodes] that the [userland] processes 
dealing with the data.

There are already some primitive NUMA bits in skbuff allocation, but 
with modern MSI-X and RX/TX flow hashing we could do a whole lot more, 
along the lines of better CPU scheduling decisions, directing flows to 
clusters of cpus, and generally doing a better job of maximizing cache 
efficiency in a modern multi-thread environment.

IMO the current model where each NIC's TX completion and RX processes 
are both locked to the same CPU is outmoded in a multi-core world with 
modern NICs.  :)

But I readily admit general ignorance about the kernel process 
scheduling stuff, so my only idea about a starting point was to see how 
far to go with the concept of "skb affinity" -- a mask in sk_buff that 
is a hint about which cpu(s) on which the NIC should attempt to send and 
receive packets.  When going through bonding or netfilter, it is trivial 
to 'or' together affinity masks.  All the various layers of net stack 
should attempt to honor the skb affinity, where feasible (requires 
interaction with CFS scheduler?).

Or maybe skb affinity is a dumb idea.  I wanted to get people thinking 
on the bigger picture.  Parallelization starts at the user process.

	Jeff


