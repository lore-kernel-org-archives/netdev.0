From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] softirq: reduce latencies
Date: Thu, 03 Jan 2013 05:31:59 -0800
Message-ID: <1357219919.21409.24519.camel@edumazet-glaptop>
References: <CA+icZUVEvzyrPsQG1QWLnHxhtaewaWTOVzBpTnLqjKuHMjjFHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: sedat.dilek@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+icZUVEvzyrPsQG1QWLnHxhtaewaWTOVzBpTnLqjKuHMjjFHg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-01-03 at 14:12 +0100, Sedat Dilek wrote:
> Hi Eric,
> 
> your patch from [2] applies cleanly on top of Linux v3.8-rc2.
> I would like to test it.
> In [1] you were talking about benchmarks you did.
> Can you describe them or provide a testcase (script etc.)?
> You made only network testing?

Yes I did network testing : 

- net_rx_action() softirq handler is the typical function that can
consume 2 ms per call.

I did some netperf sessions, with multiqueue 10G nics, tuned to that IRQ
would be handled by few cpus.
 (check /proc/irq/*/eth0-$QUEUE/../smp_affinity )

Another way to make the softirq processing use more cpu cycles is by
adding a fake iptable setup like :

for n in `seq 1 100`
do
 iptables -I INPUT
done

A common network load is to launch ~200 concurrent TCP_RR netperf
sessions like the following

netperf -H remote_host -t TCP_RR -l 1000

And then you can launch some netperf asking P99_LATENCY results :

netperf -H remote_host -t TCP_RR -- -k P99_LATENCY

You can play with taskset or netperf option -T to force
netperf/netserver running on given cpus.
