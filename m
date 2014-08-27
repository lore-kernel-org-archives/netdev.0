From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH net-next 1/3] ixgbe: support
 netdev_ops->ndo_xmit_flush()
Date: Wed, 27 Aug 2014 13:34:26 +0200
Message-ID: <20140827133426.7e734beb@redhat.com>
References: <1408887738-7661-1-git-send-email-dborkman@redhat.com>
	<1408887738-7661-2-git-send-email-dborkman@redhat.com>
	<20140825140721.162a6c91@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Florian Westphal <fw@strlen.de>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48175 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756061AbaH0Leg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 07:34:36 -0400
In-Reply-To: <20140825140721.162a6c91@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Aug 2014 14:07:21 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> On Sun, 24 Aug 2014 15:42:16 +0200
> Daniel Borkmann <dborkman@redhat.com> wrote:
> 
> > This implements the deferred tail pointer flush API for the ixgbe
> > driver. Similar version also proposed longer time ago by Alexander Duyck.
> 
> I've run some benchmarks with this patch only, which actually shows a
> performance regression.
> 
[...]
>
> Still a small regression: -14187 pps
>  * In nanosec: (1/1562539*10^9)-(1/1548352*10^9) = -5.86 ns
>  
> I was not expecting this "slowdown", with this rather simple use of the
> new ndo_xmit_flush API.  Can anyone explain why this is happening?

I've re-run this experiment with more accuracy, e.g. C-state tuning, no
Hyper-Threading, and using pktgen. See desc in thread subj: "Get rid of
ndo_xmit_flush"[1].

DaveM was right in reverting this API, according to my new more
accurate measurements, the conclusion is the same, this API hurts performance.

Compared to baseline, with this patch (except not using mmiowb()):
 * (1/5609929*10^9)-(1/5388719*10^9) = -7.32 ns

Details below signature.

[1] http://thread.gmane.org/gmane.linux.network/327502/focus=327803
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


Base setup
==========

BIOS: Disabled HT (Hyper-Threading)

Setup commands:
 sudo killall irqbalance
 base_device_setup.sh eth4 # calls set_irq_affinity
 base_device_setup.sh eth5
 netfilter_unload_modules.sh
 sudo ethtool -C eth5 rx-usecs 30
 sudo tuned-adm profile latency-performance

pktgen cmdline:
 ./example03.sh -i eth5 -d 192.168.21.4 -m 00:12:c0:80:1d:54
 (SKB_CLONE="100000" and no UDP port random)

Vanilla kernel for baselining, just **before**:
 * commit 4798248e4e02 ("net: Add ops->ndo_xmit_flush()").
Thus at:
 * commit 4c83acbc565d53 ("ipv6: White-space cleansing : gaps between function and symbol export").

With no HT:
 * ethtool -C eth5 rx-usecs 30
 * tuned-adm profile latency-performance
Results (pktgen):
 * instant rx:2 tx:5620736 pps n:120 average: rx:1 tx:5618140 pps
   (instant variation TX 0.082 ns (min:-0.088 max:0.147) RX 0.000 ns)
 * instant rx:1 tx:5622300 pps n:250 average: rx:1 tx:5619732 pps
   (instant variation TX 0.081 ns (min:-0.858 max:0.098) RX 0.000 ns)
 * accuracy: (1/5618140*10^9)-(1/5619732*10^9) = 0.05 ns
 * instant rx:1 tx:5618692 pps n:120 average: rx:1 tx:5617469 pps
   (instant variation TX 0.039 ns (min:-0.043 max:0.045) RX 0.000 ns)
 * accuracy: (1/5619732*10^9)-(1/5617469*10^9) = -0.072 ns
 * (reboot same kernel)
 * Some hickup:
 * instant rx:1 tx:5610140 pps n:190 average: rx:1 tx:5587229 pps
   (instant variation TX 0.731 ns (min:-2.612 max:2.627) RX 0.000 ns)
 * accuracy: (1/5587229*10^9)-(1/5617469*10^9) = 0.963 ns
 * accuracy: (1/5587229*10^9)-(1/5619732*10^9) = 1.035 ns
 * instant rx:1 tx:5607568 pps n:120 average: rx:1 tx:5606006 pps
   (instant variation TX 0.050 ns (min:-0.855 max:0.066) RX 0.000 ns)
 * instant rx:1 tx:5608168 pps n:120 average: rx:1 tx:5611001 pps
   (instant variation TX -0.090 ns (min:-0.156 max:0.100) RX 0.000 ns)
 * Average: (5618140+5619732+5617469+5587229+5606006+5611001)/6 = 5609929 pps

Results: on branch 'ndo_xmit_flush'
-----------------------------------
Kernel at:
 * commit fe88e6dd8b9 ("Merge branch 'ndo_xmit_flush'")

Sending out ixgbe, which in this kernel does not have the defined the
ndo_xmit_flush function.

With no HT:
 * ethtool -C eth5 rx-usecs 30
 * tuned-adm profile latency-performance
Results (pktgen):
 * instant rx:1 tx:5600404 pps n:161 average: rx:1 tx:5600257 pps
  (instant variation TX 0.005 ns (min:-0.047 max:0.050) RX 0.000 ns)
 * instant rx:1 tx:5594840 pps n:120 average: rx:1 tx:5595316 pps
  (instant variation TX -0.015 ns (min:-0.028 max:0.025) RX 0.000 ns)
 * instant rx:1 tx:5599644 pps n:140 average: rx:1 tx:5599155 pps
  (instant variation TX 0.016 ns (min:-0.074 max:0.059) RX 0.000 ns)
 * instant rx:1 tx:5601296 pps n:75 average: rx:1 tx:5599074 pps
  (instant variation TX 0.071 ns (min:-0.051 max:0.087) RX 0.000 ns)
 * Averaged: (5600257+5595316+5599155+5599074)/4 = 5598450 pps

Compared to baseline: (averaged 5609929 pps)
 * (1/5609929*10^9)-(1/5598450*10^9) = -0.365ns

Conclusion: When ndo_xmit_flush is not active in driver, performance
is the same, as 0.365ns difference is below our accuracy level.

Results: on branch bulking01
----------------------------

Kernel at:
 * commit fe88e6dd8b9 ("Merge branch 'ndo_xmit_flush'")
 * Plus ixgbe support netdev_ops->ndo_xmit_flush()

With no HT:
 * ethtool -C eth5 rx-usecs 30
 * tuned-adm profile latency-performance
Results (pktgen):
 * instant rx:1 tx:5387528 pps n:170 average: rx:1 tx:5387842 pps
  (instant variation TX -0.011 ns (min:-0.193 max:0.125) RX 0.000 ns)
 * instant rx:1 tx:5387588 pps n:212 average: rx:1 tx:5387930 pps
  (instant variation TX -0.012 ns (min:-0.852 max:0.177) RX 0.000 ns)
 * instant rx:1 tx:5391172 pps n:70 average: rx:1 tx:5389684 pps
  (instant variation TX 0.051 ns (min:-0.097 max:0.087) RX 0.000 ns)
 * instant rx:1 tx:5388444 pps n:150 average: rx:1 tx:5389421 pps
  (instant variation TX -0.034 ns (min:-1.014 max:0.092) RX 0.000 ns
 * Average: (5387842+5387930+5389684+5389421)/4 = 5388719

Compared to baseline: (averaged 5609929 pps)
 * (1/5609929*10^9)-(1/5388719*10^9) = -7.32 ns

Conclusion: When ndo_xmit_flush is ACTIVE in the driver, then this new
API of calling ndo_xmit_flush(), hurts performance.
