From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Qdisc: Measuring Head-of-Line blocking with netperf-wrapper
Date: Tue, 16 Sep 2014 17:56:00 +0200
Message-ID: <20140916175600.018350fe@redhat.com>
References: <20140915184517.6c5474e5@redhat.com>
	<20140916152221.41811287@redhat.com>
	<1410875959.7106.200.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNl?= =?UTF-8?B?bg==?=
	<toke@toke.dk>, Dave Taht <dave.taht@gmail.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50886 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751540AbaIPP4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 11:56:24 -0400
In-Reply-To: <1410875959.7106.200.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Sep 2014 06:59:19 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> With the TCP usec rtt work I did lately, you'll get more precise results
> from a TCP_RR flow, as Tom and I explained.

Here you go, developed a new test:
 http://people.netfilter.org/hawk/qdisc/experiment01/README.txt
 http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol.conf
 https://github.com/netoptimizer/netperf-wrapper/commit/7d0241a78e5

The test includes both a TCP_RR and UDP_RR test that derive the
latency, also kept the ping tests for comparison.

One problem: The NoneXSO test is basically invalid, because I cannot
make it exhaust the bandwidth, see "Total Upload":
 http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__totals--NoneXSO_net_next.png

Looking at the ping test, there is a clear difference between priority
bands, this just shows that the priority band are working as expected
and the qdisc is backlogged.
 http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__ping--GSO_net_next.png
E.g. ping test for NoneXSO show it is not backlogged, a broken test:
 http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__ping--NoneXSO_net_next.png


Zooming in on the high priority band, we see how the different
high-prio band measurements are working.
Here for GSO:
 http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__ping_hiprio--GSO_net_next.png
Here for TSO:
 http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__ping_hiprio--TSO_net_next.png

I've created a new graph called "rr_latency" that further zooms in on
the difference between TCP_RR and UDP_RR measurements:
Here for GSO:
 http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__rr_latency--GSO_net_next.png
Here for TSO:
 http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__rr_latency--TSO_net_next.png
A compare graph:
 http://people.netfilter.org/hawk/qdisc/experiment01/compare_TSO_vs_GSO__rr_latency.png

I found the interactions a little strange in the above graphs.


Even more strange, I started to play with the ixgbe cleanup interval,
adjusting via cmdline:
 sudo ethtool -C eth4 rx-usecs 30

Then the "rr_latency" graph change, significantly lowering the latetency.
Here for GSO:
 http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__rr_latency--rxusecs30_GSO_net_next.png
Here for TSO:
 http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__totals--rxusecs30_TSO_net_next.png

Compare graph for GSO:
 http://people.netfilter.org/hawk/qdisc/experiment01/compare_GSO_vs_GSO_with_rxusec30__rr_latency.png
Compare graph for TSO:
 http://people.netfilter.org/hawk/qdisc/experiment01/compare_TSO_vs_TSO_with_rxusec30__rr_latency.png
Comparing TSO vs GSO both with rx-usecs 30, which is almost equal.
 http://people.netfilter.org/hawk/qdisc/experiment01/compare_TSO_vs_GSO_both_with_rxusec30__rr_latency.png


Checking ping, still follow TCP_RR and UDP_RR, with rx-usecs 30:
 http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__ping_hiprio--rxusecs30_GSO_net_next.png
 http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__ping_hiprio--rxusecs30_TSO_net_next.png

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
