From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Fri, 15 Jan 2016 15:17:17 +0100
Message-ID: <20160115151717.01eea49e@redhat.com>
References: <20160115142223.1e92be75@redhat.com>
	<5698F4DC.6090302@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>, brouer@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56008 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752855AbcAOORZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2016 09:17:25 -0500
In-Reply-To: <5698F4DC.6090302@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Jan 2016 14:32:12 +0100
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> On 15.01.2016 14:22, Jesper Dangaard Brouer wrote:
> >
> > Given net-next is closed, we have time to discuss controversial core
> > changes right? ;-)
> >
> > I want to do some instruction-cache level optimizations.
> >
> > What do I mean by that...
> >
> > The kernel network stack code path (a packet travels) is obviously
> > larger than the instruction-cache (icache).  Today, every packet
> > travel individually through the network stack, experiencing the exact
> > same icache misses (as the previous packet).
> >
> > I imagine that we could process several packets at each stage in the
> > packet processing code path.  That way making better use of the
> > icache.
> >
> > Today, we already allow NAPI net_rx_action() to process many
> > (e.g. up-to 64) packets in the driver RX-poll routine.  But the driver
> > then calls the "full" stack for every single packet (e.g. via
> > napi_gro_receive()) in its processing loop.  Thus, trashing the icache
> > for every packet.
> >
> > I have a prove-of-concept patch for ixgbe, which gives me 10% speedup
> > on full IP forwarding.  (This patch also optimize delaying when I
> > touch the packet data, thus it also optimizes data-cache misses).  The
> > basic idea is that I delay calling ixgbe_rx_skb/napi_gro_receive, and
> > allow the RX loop (in ixgbe_clean_rx_irq()) to run more iterations
> > before "flushing" the icache (by calling the stack).
> >
> >
> > This was only at the driver level.  I also would like some API towards
> > the stack.  Maybe we could simple pass a skb-list?
> >
> > Changing / adjusting the stack to support processing in "stages" might
> > be more difficult/controversial?
> 
> I once tried this up till the vlan layer and error handling got so 
> complex and complicated that I stopped there. Maybe it is possible in 
> some separate stages.

I've already split the driver layer into a stage.  Next I will split
GRO layer into a stage.  The GRO layer is actually quite expensive
icache-wise as it have deep calls, as the compiler cannot inline
functions due to the flexible function pointer approach.  Simply
enable/disable GRO show 10% CPU usage drop (and perf increase).


> This needs redesign of a lot of stuff and while doing so I would
> switch from a more stack based approach to build the stack to try out
> a more iterative one (see e.g. stack space consumption problems).

The recursive nature of the rx handler (__netif_receive_skb_core/another_round)
is not necessarily bad approach for icache usage (unless rx_handler()
call indirectly flush the icache).  But as you have shown it _is_ bad for
stack space consumption.  

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
