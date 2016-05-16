From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Mon, 16 May 2016 15:10:32 +0200
Message-ID: <1463404232.4921.26.camel@redhat.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
	 <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
	 <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
	 <94f323a9-515e-4d75-cac8-ef0214f0499e@stressinduktion.org>
	 <1462920697.23934.113.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160511065527.GD3193@twins.programming.kicks-ass.net>
	 <1463003804.23934.154.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1463158203.11721.25.camel@redhat.com>
	 <CANn89iLxx-K6XDgU=c+6S1ExtSoCqQyG+7XjzJW+xoL3ACJYuQ@mail.gmail.com>
	 <1463159940.11721.37.camel@redhat.com>
	 <CANn89iJER4ziKLsAkSpKMRKBtHApzsHOnSndXJn2oTsf_01beA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53434 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753527AbcEPNKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2016 09:10:38 -0400
In-Reply-To: <CANn89iJER4ziKLsAkSpKMRKBtHApzsHOnSndXJn2oTsf_01beA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-05-13 at 10:36 -0700, Eric Dumazet wrote:
> On Fri, May 13, 2016 at 10:19 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> 
> > The difference is small, in the noise range:
> >
> > [with this patch applied]
> > super_netperf 100 -H 192.168.122.1 -t UDP_STREAM -l 60 -- -m 1
> > 9.00
> >
> > [adding the test into __local_bh_enable_ip(), too]
> > super_netperf 100 -H 192.168.122.1 -t UDP_STREAM -l 60 -- -m 1
> > 9.14
> >
> > but reproducible, in my experiments.
> > I have similar data for different number of flows.
> >
> >> I believe I did this so that we factorize the logic in do_softirq()
> >> and keep the code local to kernel/softirq.c
> >>
> >> Otherwise, netif_rx_ni() could also process softirq while ksoftirqd
> >> was scheduled,
> >> so I would have to  'export' the ksoftirqd_running(void) helper in an
> >> include file.
> >
> > The idea could be to add the test in __local_bh_enable_ip(), maintaining
> > the test also in do_softirq() (as currently done, i.e for
> > local_softirq_pending())
> >
> 
> Then I guess even the !in_interrupt() test we do is expensive and
> could be avoided,
> since do_softirq() is doing it again in the unlikely case it really is needed.
> 
> @@ -162,7 +170,8 @@ void __local_bh_enable_ip(unsigned long ip,
> unsigned int cnt)
>          */
>         preempt_count_sub(cnt - 1);
> 
> -       if (unlikely(!in_interrupt() && local_softirq_pending())) {
> +       if (unlikely(local_softirq_pending()) &&
> +                    !ksoftirqd_running()) {
>                 /*
>                  * Run softirq if any pending. And do it in its own stack
>                  * as we may be calling this deep in a task call stack already.

I'm sorry for the not-so-prompt reply. I had to use a different H/W, so
I had to re-run the tests with all the patch flavors to get comparable
results.

While I can confirm that adding the '!ksoftirqd_running()' condition
improves the throughput a little, but in a reproducible way, removing
the '!in_interrupt()' don't change the result measurably, in my
environment.

While running the test against a kernel with the above chunk applied I
got a couple of:

[  702.791025] NOHZ: local_softirq_pending 08

Not seen with the other versions of this patch.

Cheers,

Paolo
