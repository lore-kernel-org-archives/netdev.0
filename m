From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Qdisc: Measuring Head-of-Line blocking with netperf-wrapper
Date: Tue, 16 Sep 2014 15:22:21 +0200
Message-ID: <20140916152221.41811287@redhat.com>
References: <20140915184517.6c5474e5@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNlbg==?= <toke@toke.dk>,
	Dave Taht <dave.taht@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8887 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752295AbaIPNWw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 09:22:52 -0400
In-Reply-To: <20140915184517.6c5474e5@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Sep 2014 18:45:17 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> I've constructed a "netperf-wrapper" test for measuring Head-of-Line
> blocking, called "tcp_upload_prio", that I hope you will approve of?
> 
>  https://github.com/tohojo/netperf-wrapper/commit/1e6b755e8051b6
> 
> The basic idea is to have ping packets with TOS bit 0x10, which end-up
> in the high-prio band of pfifo_fast.  While two TCP uploads utilize
> all the bandwidth.
> 
> These high-prio ping packet should then demonstrate the Head-of-Line
> blocking occurring due to 1) packets in the HW TX ring buffer, or
> 2) in the qdisc layers requeue mechanism.  Disgusting these two case
> might be a little difficult.

Let me demonstrate some the results with some graphs. I'm comparing
same kernel (net-next at c0d1379a) with different TSO, GSO and
disabled-TSO+GSO:

Test TYPES are:
- TSO     == ethtool -K eth4 gro on  gso on  tso on
- GSO     == ethtool -K eth4 gro on  gso on  tso off
- NoneXSO == ethtool -K eth4 gro off gso off tso off

A ping graph for with TSO enabled looks like:
 http://people.netfilter.org/hawk/qdisc/measure01/tcp_upload_prio__ping--TSO_net_next.png

- It clearly shows that we can measure the difference between the
  best-effort and high-priority ping packets.


Zooming in on high-prio ping only, and comparing TSO vs GSO:
 http://people.netfilter.org/hawk/qdisc/measure01/compare_TSO_vs_GSO__ping_hiprio.png
 http://people.netfilter.org/hawk/qdisc/measure01/compare_TSO_vs_GSO__ping_cdf.png

- It clearly shows that GSO have lower/better ping values that TSO,
  e.g. smaller HoL blocking


When adding the NoneXSO to the high-prio compare:
 http://people.netfilter.org/hawk/qdisc/measure01/compare_TSO_vs_GSO_vs_NoneXSO__ping_hiprio.png
 http://people.netfilter.org/hawk/qdisc/measure01/compare_TSO_vs_GSO_vs_NoneXSO__ping_cdf.png

- Then it look a little strange, because the none-GSO/TSO setting looks
  like it have larger Head-of-Line blocking delays.  Something I was
  not expecting.

Do notice that the NoneXSO case have a lower overall/average latency,
likely due to 1) TSO and GSO can put more "bytes" into the qdisc's 1000
packet limit, 2) NoneXSO have more difficulties exausting all
bandwidth, see graph:
 http://people.netfilter.org/hawk/qdisc/measure01/tcp_upload_prio__totals--NoneXSO_net_next.png
vs a more stable TCP speeds with GSO:
 http://people.netfilter.org/hawk/qdisc/measure01/tcp_upload_prio__totals--GSO_net_next.png

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
