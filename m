From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [net-next PATCH V3-evictor] net: frag evictor, avoid killing
 warm frag queues
Date: Thu, 06 Dec 2012 16:23:23 +0100
Message-ID: <1354807403.20888.254.camel@localhost>
References: <1354319937.20109.285.camel@edumazet-glaptop>
	 <20121204133007.20215.52566.stgit@dragon>
	 <1354699462.20888.207.camel@localhost>
	 <1354796760.20888.217.camel@localhost>
	 <20121206123248.GA24493@breakpoint.cc>
	 <1354802100.20888.242.camel@localhost>
	 <1354805276.31222.803.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754194Ab2LFPX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2012 10:23:57 -0500
In-Reply-To: <1354805276.31222.803.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-06 at 06:47 -0800, Eric Dumazet wrote:
> On Thu, 2012-12-06 at 14:55 +0100, Jesper Dangaard Brouer wrote:
> 
> > The LRU might be the correct solution after all.  If I enable Ethernet
> > flow-control again, then I have a hard time "activating" the evictor
> > code (with thresh 4M/3M) .  I'll need a separate DoS program, which can
> > send incomplete fragments (in back-to-back bursts) to provoke the
> > evictor and LRU.
> > 
> > My cheap DoS reproducer-hack is to disable Ethernet flow-control on only
> > one interface (out of 3), to cause packet drops and the incomplete
> > fragments. The current preliminary results is that the two other
> > interfaces still gets packets through, we don't get the zero throughput
> > situation.
> >  Two interfaces and no DoS: 15342 Mbit/s
> >  Three interfaces and DoS:   7355 Mbit/s
> > 
> > The reduction might look big, but you have to take into account, that
> > "activating" the evictor code, is also causing scalability issues of its
> > own (which could account for the performance drop it self).
> 
> I would try removing the LRU, but keeping the age information (jiffie of
> last valid frag received on one inet_frag_queue)

I don't think its worth optimizing further, atm.

Because, the test above is without any of my SMP scalability fixes.
With my SMP fixes the result is, full scalability:

 Three interfaces:  (9601+6723+9432) = 25756 Mbit/s

And the 6723 Mbit/s number, is because the old 10G NIC cannot generate
anymore...

And I basically cannot use the cheap DoS reproducer-hack, as the
machine/code-path is now too fast...

Running with 4 interfaces, and starting 6 netperf's (to cause more
interleaving and higher mem usage):

 4716+8042+8765+6204+2475+4568 = 34770 Mbit/s

I could just manage to get to do IpReasmFails = 14.

[jbrouer@dragon ~]$ nstat > /dev/null && sleep 1 && nstat
#kernel
IpInReceives                    2980048            0.0
IpInDelivers                    66217              0.0
IpReasmReqds                    2980040            0.0
IpReasmOKs                      66218              0.0
IpReasmFails                    14                 0.0
UdpInDatagrams                  66218              0.0
IpExtInOctets                   4397976885         0.0

So, after the SMP fixes, its very hard to "activate" the evictor.  We
would need to find a slower e.g. embedded box and tune the evictor on
that, as a multi-CPU machine basically will scale "too-well" now ;-)

--Jesper
