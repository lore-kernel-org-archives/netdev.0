From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Qdisc: Measuring Head-of-Line blocking with netperf-wrapper
Date: Mon, 15 Sep 2014 10:24:23 -0700
Message-ID: <1410801863.7106.169.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140915184517.6c5474e5@redhat.com>
	 <CA+mtBx_EthN8G0oEUENmVhb8MJ2MrijhT+FRjJPomBLvJPoH_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
	Dave Taht <dave.taht@gmail.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:62563 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223AbaIORY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 13:24:26 -0400
Received: by mail-pd0-f181.google.com with SMTP id w10so6785949pde.40
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 10:24:26 -0700 (PDT)
In-Reply-To: <CA+mtBx_EthN8G0oEUENmVhb8MJ2MrijhT+FRjJPomBLvJPoH_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-15 at 10:10 -0700, Tom Herbert wrote:
> On Mon, Sep 15, 2014 at 9:45 AM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> >
> > Hi Eric,
> >
> > I've constructed a "netperf-wrapper" test for measuring Head-of-Line
> > blocking, called "tcp_upload_prio", that I hope you will approve of?
> >
> >  https://github.com/tohojo/netperf-wrapper/commit/1e6b755e8051b6
> >
> > The basic idea is to have ping packets with TOS bit 0x10, which end-up
> > in the high-prio band of pfifo_fast.  While two TCP uploads utilize
> > all the bandwidth.
> >
> > These high-prio ping packet should then demonstrate the Head-of-Line
> > blocking occurring due to 1) packets in the HW TX ring buffer, or
> > 2) in the qdisc layers requeue mechanism.  Disgusting these two case
> > might be a little difficult.
> >
> >
> >
> > Special care need to be take for using this on the default
> > qdisc MQ which have pfifo_fast assigned for every HW queue.
> >
> > Setup requirements:
> >  1. IRQ align CPUs to NIC HW queues
> >  2. Force netperf-wrapper subcommands to run the same CPU
> >   E.g: taskset -c 2 ./netperf-wrapper -H IP tcp_upload_prio
> >
> > This will force all measurements to go through the same qdisc.  This
> > is needed so the ping/latency tests measures the real property of
> > the qdisc and Head-of-Line blocking effect.
> >
> >
> > Basically the same as:
> >  sudo taskset -c 2 ping -Q 0x10 192.168.8.2
> >  sudo taskset -c 2 ping         192.168.8.2
> >  sudo taskset -c 2 netperf   -H 192.168.8.2 -t TCP_STREAM -l 120
> >  sudo taskset -c 2 netperf   -H 192.168.8.2 -t TCP_STREAM -l 120
> > --
> ping is a very coarse way to measure latency and in network devices it
> doesn't follow same path as TCP/UDP (no 4-tuple for RSS, ECMP) so it's
> biased and not a very realistic workload. You might want to try using
> netperf TCP_RR at higher priority for a fairer comparison (this is
> what I used to verify BQL benefits). Also, you probably want to make
> sure to have enough antagonist flows to saturate all links when using
> MQ.

Right.

Jesper, relevant netperf option is :

    -y local,remote   Set the socket priority
