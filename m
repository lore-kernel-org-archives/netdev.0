From: Eric Dumazet <edumazet@google.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Fri, 13 May 2016 10:36:34 -0700
Message-ID: <CANn89iJER4ziKLsAkSpKMRKBtHApzsHOnSndXJn2oTsf_01beA@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f178.google.com ([209.85.161.178]:34080 "EHLO
	mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753408AbcEMRgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 13:36:36 -0400
Received: by mail-yw0-f178.google.com with SMTP id j74so109287904ywg.1
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 10:36:35 -0700 (PDT)
In-Reply-To: <1463159940.11721.37.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 13, 2016 at 10:19 AM, Paolo Abeni <pabeni@redhat.com> wrote:

> The difference is small, in the noise range:
>
> [with this patch applied]
> super_netperf 100 -H 192.168.122.1 -t UDP_STREAM -l 60 -- -m 1
> 9.00
>
> [adding the test into __local_bh_enable_ip(), too]
> super_netperf 100 -H 192.168.122.1 -t UDP_STREAM -l 60 -- -m 1
> 9.14
>
> but reproducible, in my experiments.
> I have similar data for different number of flows.
>
>> I believe I did this so that we factorize the logic in do_softirq()
>> and keep the code local to kernel/softirq.c
>>
>> Otherwise, netif_rx_ni() could also process softirq while ksoftirqd
>> was scheduled,
>> so I would have to  'export' the ksoftirqd_running(void) helper in an
>> include file.
>
> The idea could be to add the test in __local_bh_enable_ip(), maintaining
> the test also in do_softirq() (as currently done, i.e for
> local_softirq_pending())
>

Then I guess even the !in_interrupt() test we do is expensive and
could be avoided,
since do_softirq() is doing it again in the unlikely case it really is needed.

@@ -162,7 +170,8 @@ void __local_bh_enable_ip(unsigned long ip,
unsigned int cnt)
         */
        preempt_count_sub(cnt - 1);

-       if (unlikely(!in_interrupt() && local_softirq_pending())) {
+       if (unlikely(local_softirq_pending()) &&
+                    !ksoftirqd_running()) {
                /*
                 * Run softirq if any pending. And do it in its own stack
                 * as we may be calling this deep in a task call stack already.
