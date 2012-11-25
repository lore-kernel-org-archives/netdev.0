From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC net-next PATCH V1 0/9] net: fragmentation performance
 scalability on NUMA/SMP systems
Date: Sun, 25 Nov 2012 09:53:47 +0100
Message-ID: <1353833627.11754.134.camel@localhost>
References: <20121123130749.18764.25962.stgit@dragon>
	 <1353810665.2590.4774.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14152 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751626Ab2KYIzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Nov 2012 03:55:31 -0500
In-Reply-To: <1353810665.2590.4774.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-11-24 at 18:31 -0800, Eric Dumazet wrote:
> On Fri, 2012-11-23 at 14:08 +0100, Jesper Dangaard Brouer wrote:
> > This patchset implements significant performance improvements for
> > fragmentation handling in the kernel, with a focus on NUMA and SMP
> > based systems.
> > 
> > Review:
> > 
> >  Please review these patches.  I have on purpose added comments in the
> >  code with the "//" comments style.  These comments are to be removed
> >  before applying.  They serve as a questions to, you, the reviewer.
> > 
> > The fragmentation code today:
> > 
> >  The fragmentation code "protects" kernel resources, by implementing
> >  some memory resource limitation code.  This is centered around a
> >  global readers-writer lock, and (per network namespace) an atomic mem
> >  counter and a LRU (Least-Recently-Used) list.  (Although separate
> >  global variables and namespace resources, are kept for IPv4, IPv6
> >  and Netfilter reassembly.)
> > 
> >  The code tries to keep the memory usage between a high and low
> >  threshold (see: /proc/sys/net/ipv4/ipfrag_{high,low}_thresh).  The
> >  "evictor" code cleans up fragments, when the high threshold is
> >  exceeded, and stops only, when the low threshold is reached.
> > 
> > The scalability problem:
> > 
> >  Having a global/central variable for a resource limit is obviously a
> >  scalability issue on SMP systems, and even amplified on a NUMA based
> >  system.
> > 
> 
> 
> But ... , what practical workload even use fragments ?

(1) DNS (default for Bind) will use up-to 3 UDP fragments before
switching to TCP.  This is getting more and more relevant after the
introduction of DNSSEC.  That's why I'm explicit testing the 3xUDP
fragments so heavily.

(2) For IPVS (load-balancing) we have recently allowed fragmentation in
tunnel mode, towards the realservers (to hide the MTU reduction for the
clients).  Thus, we need better frag performance in this case.

(3) I also have a customer that have a usage scenario/application (at
4x10G) that needs this... but I'm trying to convince them to fix/change
their application...

Scenario (1) is the real reason I want to fix this scalability issue in
the code.


> Sure, netperf -t UDP_STREAM uses frags, but its a benchmark.

Yes, for the default large 64k packets size, its just a "fake"
benchmark.  And notice with my fixes, we are even faster than the
none-frag/single-UDP packet case... but its because we are getting a
GSO/GRO effect.

That's why I'm adjusting the UDP "frag" packet size to get a more
realistic use case... to simulate the DNS use-case (1).


> The only heavy user was NFS in the days it was using UDP, a very long
> time ago.
> 
> A single lost fragment means the whole packet is lost.

That is correct, that's why we need the fix in patch-01. 

(It actually reminds me of the problem with ADSL/ATM, where (small) ATM
frame are used for carrying IP packets, and when some (more central) ATM
link gets overloaded and starts to drops ATM frames, not taking the AAL5
packets into account).

> Another problem with fragments is the lack of 4-tuple hashing, as only
> the first frag contains the dst/src ports.
> 
> Also there is the sysctl_ipfrag_max_dist issue...
> 
> Hint : many NIC provide TSO (TCP offload), but none provide UFO,
> probably because there is no demand for it.


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
