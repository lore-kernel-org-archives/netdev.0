From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Qdisc: Measuring Head-of-Line blocking with netperf-wrapper
Date: Tue, 16 Sep 2014 08:30:20 +0200
Message-ID: <20140916083020.4f46015c@redhat.com>
References: <20140915184517.6c5474e5@redhat.com>
	<CA+mtBx_EthN8G0oEUENmVhb8MJ2MrijhT+FRjJPomBLvJPoH_w@mail.gmail.com>
	<1410801863.7106.169.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNl?= =?UTF-8?B?bg==?=
	<toke@toke.dk>, Dave Taht <dave.taht@gmail.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17210 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752189AbaIPGan (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 02:30:43 -0400
In-Reply-To: <1410801863.7106.169.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Sep 2014 10:24:23 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2014-09-15 at 10:10 -0700, Tom Herbert wrote:
> > On Mon, Sep 15, 2014 at 9:45 AM, Jesper Dangaard Brouer
> > <brouer@redhat.com> wrote:
> > >
> > > Hi Eric,
> > >
> > > I've constructed a "netperf-wrapper" test for measuring Head-of-Line
> > > blocking, called "tcp_upload_prio", that I hope you will approve of?
> > >
> > >  https://github.com/tohojo/netperf-wrapper/commit/1e6b755e8051b6
> > >
> > > The basic idea is to have ping packets with TOS bit 0x10, which end-up
> > > in the high-prio band of pfifo_fast.  While two TCP uploads utilize
> > > all the bandwidth.
> > >
> > > These high-prio ping packet should then demonstrate the Head-of-Line
> > > blocking occurring due to 1) packets in the HW TX ring buffer, or
> > > 2) in the qdisc layers requeue mechanism.  Disgusting these two case
> > > might be a little difficult.
> > >
> > >
> > >
> > > Special care need to be take for using this on the default
> > > qdisc MQ which have pfifo_fast assigned for every HW queue.
> > >
> > > Setup requirements:
> > >  1. IRQ align CPUs to NIC HW queues
> > >  2. Force netperf-wrapper subcommands to run the same CPU
> > >   E.g: taskset -c 2 ./netperf-wrapper -H IP tcp_upload_prio
> > >
> > > This will force all measurements to go through the same qdisc.  This
> > > is needed so the ping/latency tests measures the real property of
> > > the qdisc and Head-of-Line blocking effect.
> > >
> > >
> > > Basically the same as:
> > >  sudo taskset -c 2 ping -Q 0x10 192.168.8.2
> > >  sudo taskset -c 2 ping         192.168.8.2
> > >  sudo taskset -c 2 netperf   -H 192.168.8.2 -t TCP_STREAM -l 120
> > >  sudo taskset -c 2 netperf   -H 192.168.8.2 -t TCP_STREAM -l 120
> > > --
> > ping is a very coarse way to measure latency and in network devices it
> > doesn't follow same path as TCP/UDP (no 4-tuple for RSS, ECMP) so it's
> > biased and not a very realistic workload. You might want to try using
> > netperf TCP_RR at higher priority for a fairer comparison (this is
> > what I used to verify BQL benefits). 

I worry about starvation, when putting too much/heavy traffic in the
high prio queue.

I've played with UDP_RR (in high prio queue) to measure the latency, it
worked well (much less fluctuations than ping) for GSO and TSO , but
for the none-GSO case it disturbed the two TCP uploads so much, that
they could not utilize the link.

For TCP_RR I worry what happens if a packet loss and RTO happens, but I
guess putting this in the high prio queue should make drops (a lot)
less likely.

> > Also, you probably want to make
> > sure to have enough antagonist flows to saturate all links when using
> > MQ.

For the none-GSO case, I guess adding more TCP uploads might help, but
they might just get starvated.  I'll give it a try.


> Jesper, relevant netperf option is :
> 
>     -y local,remote   Set the socket priority

Check, netperf-wrapper already supports setting these.


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
