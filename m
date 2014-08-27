From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Wed, 27 Aug 2014 09:48:59 +0200
Message-ID: <20140827094859.65f4f0fc@redhat.com>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>
	<20140826082815.18034199@redhat.com>
	<20140826121347.0ec7f2ac@redhat.com>
	<20140826145225.6673ab3f@redhat.com>
	<53FCB944.9060904@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, jhs@mojatatu.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au, dborkman@redhat.com, brouer@redhat.com,
	Jeremy Eder <jeder@redhat.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60626 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751986AbaH0HtO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 03:49:14 -0400
In-Reply-To: <53FCB944.9060904@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Aug 2014 09:43:48 -0700
Alexander Duyck <alexander.h.duyck@intel.com> wrote:

> On 08/26/2014 05:52 AM, Jesper Dangaard Brouer wrote:
> > 
[...]
> > 
> > Setting: (inc TX ring size)
> >  sudo ethtool -G eth5 tx 1024
> >  sudo ethtool -C eth5 rx-usecs 1 #(default setting)
> > Result pktgen:
> >  * instant rx:1 tx:5745632 pps n:118 average: rx:1 tx:5748818 pps
> >    (instant variation TX -0.096 ns (min:-0.293 max:0.897) RX 0.000 ns)
> > 
[...]
> > Setting:
> >  sudo ethtool -G eth5 tx 512
> >  sudo ethtool -C eth5 rx-usecs 30
> > Result pktgen:
> >  * instant rx:1 tx:5920856 pps n:114 average: rx:1 tx:5918350 pps
> >    (instant variation TX 0.071 ns (min:-0.177 max:0.135) RX 0.000 ns)
> > 
> 
> My advice would be to disable all C states and P states (including
> turbo) if possible, and try using idle=poll.  Any processor frequency
> and/or C state transitions will totally wreak havoc with trying to get
> reliable results out of any performance test.

Thanks for the advice.

Reading Jeremy Eder's blog post:
 http://www.breakage.org/2012/11/14/processor-max_cstate-intel_idle-max_cstate-and-devcpu_dma_latency/

It seems the best method for disabling these C and P states, and
keeping all CPUs in C0/C1 state is doing:

# tuned-adm profile latency-performance

Accuracy of: "ethtool -C eth5 rx-usecs 30" got slightly little better, (see
below) latency variations below 1ns min:-0.209 ns and max:0.114 ns.  Which is
very good, and should be good enough for us, to measure the upcoming
code changes.

Just increasing TX ring queue still have variations.

I'm also going to disable Hyper-threading in BIOS, even-though I'm only
using one CPU in these tests (I worry that some process running on a
sibling could disturb the accuracy).

Setting:
 * sudo ethtool -C eth5 rx-usecs 30
Result:
 * instant rx:1 tx:5603644 pps n:120 average: rx:0 tx:5603317 pps
   (instant variation TX 0.010 ns (min:-0.132 max:0.114) RX 0.000 ns)
 * instant rx:1 tx:5599820 pps n:300 average: rx:1 tx:5602382 pps
   (instant variation TX -0.082 ns (min:-0.209 max:0.114) RX 0.000 ns)

Setting:
 * sudo ethtool -G eth5 tx 1024
Result:
 * instant rx:1 tx:5398208 pps n:300 average: rx:1 tx:5404893 pps
   (instant variation TX -0.229 ns (min:-0.257 max:1.666) RX 0.000 ns)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
