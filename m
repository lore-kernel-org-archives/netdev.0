From: Dave Taht <dave.taht@gmail.com>
Subject: Re: Qdisc: Measuring Head-of-Line blocking with netperf-wrapper
Date: Tue, 16 Sep 2014 19:08:23 +0300
Message-ID: <CAA93jw7Xk2joD3L4sP9iqMrbz1DFBtrhYJ1xY7fevBg8NdnwQw@mail.gmail.com>
References: <20140915184517.6c5474e5@redhat.com>
	<20140916152221.41811287@redhat.com>
	<1410875959.7106.200.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140916175600.018350fe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:33355 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754031AbaIPQIY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 12:08:24 -0400
Received: by mail-ob0-f181.google.com with SMTP id wo20so62117obc.12
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 09:08:23 -0700 (PDT)
In-Reply-To: <20140916175600.018350fe@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2014 at 6:56 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Tue, 16 Sep 2014 06:59:19 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> With the TCP usec rtt work I did lately, you'll get more precise res=
ults
>> from a TCP_RR flow, as Tom and I explained.
>
> Here you go, developed a new test:
>  http://people.netfilter.org/hawk/qdisc/experiment01/README.txt
>  http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol.c=
onf
>  https://github.com/netoptimizer/netperf-wrapper/commit/7d0241a78e5
>
> The test includes both a TCP_RR and UDP_RR test that derive the
> latency, also kept the ping tests for comparison.

You have incidentally overwhelmed *me* with data. Thank you very much
for including the *.json* files in your experiments, I'll be able to pa=
rse
and compare them later with netperf-wrapper when I get more time.

> One problem: The NoneXSO test is basically invalid, because I cannot
> make it exhaust the bandwidth, see "Total Upload":
>  http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__=
totals--NoneXSO_net_next.png

Well, i've long conceded that TSO and GSO offloads were needed at 10Gig=
E speeds.
I'd love to get a grip on how bursty they are since some moderation
fixes landed a few
versions back.

>
> Looking at the ping test, there is a clear difference between priorit=
y
> bands, this just shows that the priority band are working as expected
> and the qdisc is backlogged.
>  http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__=
ping--GSO_net_next.png
> E.g. ping test for NoneXSO show it is not backlogged, a broken test:
>  http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__=
ping--NoneXSO_net_next.png
>

I look forward to seeing sch_fq and fq_codel data, for comparison.

>
> Zooming in on the high priority band, we see how the different
> high-prio band measurements are working.
> Here for GSO:
>  http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__=
ping_hiprio--GSO_net_next.png
> Here for TSO:
>  http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__=
ping_hiprio--TSO_net_next.png
>
> I've created a new graph called "rr_latency" that further zooms in on
> the difference between TCP_RR and UDP_RR measurements:
> Here for GSO:
>  http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__=
rr_latency--GSO_net_next.png
> Here for TSO:
>  http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__=
rr_latency--TSO_net_next.png
> A compare graph:
>  http://people.netfilter.org/hawk/qdisc/experiment01/compare_TSO_vs_G=
SO__rr_latency.png
>
> I found the interactions a little strange in the above graphs.


I note that toke had started coding netperf-wrapper back in the day
when 10mbits and RTTs measured in seconds were the norm. I am
DELIGHTED to see it works at all at 10GigE. Other network measurement
tools, like netalyzr, peak out at 20mbits....

You can capture more detail about the tc setup, in particular, if you
invoke it with the -x option.

You might get more detail on your plots if you run as root with
--step-size .01 for a 10ms sampling interval
rather than a 200ms one. This doesn't quite work on a few older tests,
notably rrul.

> Even more strange, I started to play with the ixgbe cleanup interval,
> adjusting via cmdline:
>  sudo ethtool -C eth4 rx-usecs 30
>
> Then the "rr_latency" graph change, significantly lowering the latete=
ncy.
> Here for GSO:
>  http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__=
rr_latency--rxusecs30_GSO_net_next.png
> Here for TSO:
>  http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__=
totals--rxusecs30_TSO_net_next.png

There is always a tradeoff between better batching and better latency.
I've kind of hoped that with the new post-ivy-bridge architectures,
that the weight, even napi weight, was shifting towards dealing with
low latency packets already in cache was more efficient than batching
up processing. The numbers the DPDK folk were getting were astounding.

(but still can't make heads or tails of where you are going with all th=
is)

> Compare graph for GSO:
>  http://people.netfilter.org/hawk/qdisc/experiment01/compare_GSO_vs_G=
SO_with_rxusec30__rr_latency.png
> Compare graph for TSO:
>  http://people.netfilter.org/hawk/qdisc/experiment01/compare_TSO_vs_T=
SO_with_rxusec30__rr_latency.png
> Comparing TSO vs GSO both with rx-usecs 30, which is almost equal.
>  http://people.netfilter.org/hawk/qdisc/experiment01/compare_TSO_vs_G=
SO_both_with_rxusec30__rr_latency.png
>
>
> Checking ping, still follow TCP_RR and UDP_RR, with rx-usecs 30:
>  http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__=
ping_hiprio--rxusecs30_GSO_net_next.png
>  http://people.netfilter.org/hawk/qdisc/experiment01/qdisc_prio_hol__=
ping_hiprio--rxusecs30_TSO_net_next.png

I have generally found that it is easier to present all this data on
graphs or combined graph, on a web page, rather than in email.

> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Sr. Network Kernel Developer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer



--=20
Dave T=C3=A4ht

https://www.bufferbloat.net/projects/make-wifi-fast
