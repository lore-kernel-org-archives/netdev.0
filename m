From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v6 05/12] Add sample for adding simple drop program to
 link
Date: Mon, 11 Jul 2016 15:37:08 +0200
Message-ID: <20160711153708.1baa4224@redhat.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
	<1467944124-14891-6-git-send-email-bblanco@plumgrid.com>
	<57837E66.3050000@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Martin KaFai Lau <kafai@fb.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>, brouer@redhat.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51938 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753022AbcGKNhQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2016 09:37:16 -0400
In-Reply-To: <57837E66.3050000@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Jul 2016 07:09:26 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> On 16-07-07 10:15 PM, Brenden Blanco wrote:
> > Add a sample program that only drops packets at the BPF_PROG_TYPE_XDP_RX
> > hook of a link. With the drop-only program, observed single core rate is
> > ~20Mpps.
> >
> > Other tests were run, for instance without the dropcnt increment or
> > without reading from the packet header, the packet rate was mostly
> > unchanged.
> >
> > $ perf record -a samples/bpf/xdp1 $(</sys/class/net/eth0/ifindex)
> > proto 17:   20403027 drops/s
> >  
> 
> 
> So - devil's advocate speaking:
> I can filter and drop with this very specific NIC at 10x as fast
> in hardware, correct?

After avoiding the cache-miss, I believe, we have actually reached the
NIC HW limit.  I base this on, my measurements show that the CPU start
to go idle, even enter sleep C-states.  And we exit NAPI mode, not
using the full budget, emptying the RX ring.


> Would a different NIC (pick something like e1000) have served a better
> example?
> BTW: Brenden, now that i looked closer here, you really dont have
> apple-apple comparison with dropping at tc ingress. You have a
> tweaked prefetch and are intentionally running things on a single
> core. Note: We are able to do 20Mpps drops with tc with a single
> core (as shown in netdev11) on a NUC with removing driver overhead.

AFAIK you were using the pktgen "xmit_mode netif_receive" which inject
packets directly into the stack, thus removing the NIC driver from the
equation.  Brenden only is measuring the driver.
  Thus, you are both doing zoom-in-measuring (of a very specific and
limited section of the code) but two completely different pieces of
code.

Notice, Jamal, in your 20Mpps results, your are also avoiding
interacting with the memory allocator, as you are recycling the same
SKB (and don't be confused by seeing kfree_skb() in perf-top as it only
does atomic_dec() [1]).

In this code-zoom-in benchmark (given single CPU is keep 100% busy) you
are actually measuring that the code path (on average) takes 50 nanosec
(1/20*1000) to execute.  Which is cool, but it is only a zoom-in on a
specific code path (which avoids any I-cache misses).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

[1] https://www.youtube.com/watch?v=M6l1rxZCqLM
