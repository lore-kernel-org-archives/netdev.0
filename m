From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6] e100: use NAPI mode all the time
Date: Sun, 06 Jun 2004 22:33:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40C3D3F6.6010103@pobox.com>
References: <Pine.LNX.4.58.0406041727160.2662@sfeldma-ich5.jf.intel.com> <DC71FD1C-B80C-11D8-9557-000393652100@engr.uky.edu> <1086566591.3721.54.camel@localhost.localdomain> <2DF80C45-B825-11D8-9557-000393652100@engr.uky.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@pobox.com, netdev@oss.sgi.com, bonding-devel@lists.sourceforge.net,
        Scott Feldman <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tim Mattox <tmattox@engr.uky.edu>
In-Reply-To: <2DF80C45-B825-11D8-9557-000393652100@engr.uky.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tim Mattox wrote:
> The problem is caused by the order packets are delivered to the TCP
> stack on the receiving machine.  In normal round-robin bonding mode,
> the packets are sent out one per NIC in the bond.  For simplicity
> sake, lets say we have two NICs in a bond, eth0 and eth1.  When
> sending packets, eth0 will handle all the even packets, and eth1 all
> the odd packets.  Similarly when receiving, eth0 would get all
> the even packets, and eth1 all the odd packets from a particular
> TCP stream.
> 
> With NAPI (or other interrupt mitigation techniques) the
> receiving machine will process multiple packets in a row from a
> single NIC, before getting packets from another NIC.  In the
> above example, eth0 would receive packets 0, 2, 4, 6, etc.
> and pass them to the TCP layer.  Followed by eth1's
> packets 1, 3, 5, 7, etc.  The specific number of out-of-order
> packets received in a row would depend on many factors.
> 
> The TCP layer would need to reorder the packets from something
> like 0, 2, 4, 6, 1, 3, 5, 7 or something
> like 0, 2, 4, 1, 3, 5, 6, 7.  With many possible variations.

Ethernet drivers have _always_ processed multiple packets per interrupt, 
since before the days of NAPI, and before the days of hardware mitigation.

Therefore, this is mainly an argument against using overly simplistic 
load balancing schemes that _create_ this problem :)  It's much smarter 
to load balance based on flows, for example.  I think the ALB mode does 
this?

You appear to be making the incorrect assumption that packets sent in 
this simplistic, round-robin manner could ever _hope_ to arrive in-order 
at the destination.  Any number of things serve gather packets into 
bursts:  net stack TX queue, hardware DMA ring, hardware FIFO, remote 
h/w FIFO, remote hardware DMA ring, remote softirq.


> I don't want to slow the progress of Linux networking development.
> I was objecting to the removal of a feature to e100 that already has
> working code and that was, AFAIK, necessary for the performance
> enhancement of bonding.

No, just don't use a bonding mode that kills performance.  It has 
nothing to do with NAPI.

As I said, ethernet drivers have been processing runs of packets per irq 
/ softirq for ages and ages.  This isn't new with NAPI, to be sure.


> I have NO problems with NAPI itself, I think it's a wonderful development.
> I would even advocate for making NAPI the default across the board.
> But for bonding, until I see otherwise, I want to be able to not use NAPI.
> As I indicated, I will have a new cluster that I can directly test this
> NAPI vs Bonding issue very soon.

As Scott indicated, people use bonding with tg3 (unconditional NAPI) all 
time.

Further, I hope you're not doing something silly like trying to load 
balance on the _same_ ethernet.  If you are, that's a signal that deeper 
problems exist -- you should be able to do wire speed with one NIC.

	Jeff
