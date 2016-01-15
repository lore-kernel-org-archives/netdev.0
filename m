From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Optimizing instruction-cache, more packets at each stage
Date: Fri, 15 Jan 2016 14:22:23 +0100
Message-ID: <20160115142223.1e92be75@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56125 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755552AbcAONWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2016 08:22:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Given net-next is closed, we have time to discuss controversial core
changes right? ;-)

I want to do some instruction-cache level optimizations.

What do I mean by that...

The kernel network stack code path (a packet travels) is obviously
larger than the instruction-cache (icache).  Today, every packet
travel individually through the network stack, experiencing the exact
same icache misses (as the previous packet).

I imagine that we could process several packets at each stage in the
packet processing code path.  That way making better use of the
icache.

Today, we already allow NAPI net_rx_action() to process many
(e.g. up-to 64) packets in the driver RX-poll routine.  But the driver
then calls the "full" stack for every single packet (e.g. via
napi_gro_receive()) in its processing loop.  Thus, trashing the icache
for every packet.

I have a prove-of-concept patch for ixgbe, which gives me 10% speedup
on full IP forwarding.  (This patch also optimize delaying when I
touch the packet data, thus it also optimizes data-cache misses).  The
basic idea is that I delay calling ixgbe_rx_skb/napi_gro_receive, and
allow the RX loop (in ixgbe_clean_rx_irq()) to run more iterations
before "flushing" the icache (by calling the stack).


This was only at the driver level.  I also would like some API towards
the stack.  Maybe we could simple pass a skb-list?

Changing / adjusting the stack to support processing in "stages" might
be more difficult/controversial?

Maybe we should view the packets stuck/avail in the RX ring, as
packets that all arrived at the same "time", and thus process them at
the same time.

By letting the "bulking" depend on the avail packets in the RX ring,
we automatically amortize processing cost in a scalable manor.


One challenge with icache optimizations is that it is hard to profile.
But hopefully the new Skylake CPU can profile this.  Because as I
always say, if you cannot measure it, you cannot improve it.


p.s. I doing a Network Performance BoF[1] at NetDev 1.1, where this
and many more subjects will be brought up face-to-face.

[1] http://netdevconf.org/1.1/bof-network-performance-bof-jesper-dangaard-brouer.html
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
