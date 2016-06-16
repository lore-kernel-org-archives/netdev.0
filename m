From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH 4/5] netdev: implement infrastructure for threadable
 napi irq
Date: Thu, 16 Jun 2016 12:39:53 +0200
Message-ID: <1466073593.4691.47.camel@redhat.com>
References: <cover.1465996447.git.pabeni@redhat.com>
	 <f5e431e8336f80d0e6f6b4c40c81a373db6d6052.1465996447.git.pabeni@redhat.com>
	 <CANn89i+EJMHeMN8=e12hoT1Jv8cCBDXeexTBdsd9hU2G=HpGZA@mail.gmail.com>
	 <1466008955.24431.35.camel@redhat.com>
	 <CANn89iJKxctv5Yzn2ecBLAjh2RtGpjNC6M3dqKXieqaORZaGsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46118 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752665AbcFPKj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2016 06:39:57 -0400
In-Reply-To: <CANn89iJKxctv5Yzn2ecBLAjh2RtGpjNC6M3dqKXieqaORZaGsw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-15 at 10:04 -0700, Eric Dumazet wrote:
> On Wed, Jun 15, 2016 at 9:42 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> > On Wed, 2016-06-15 at 07:17 -0700, Eric Dumazet wrote:
> 
> >>
> >> I really appreciate the effort, but as I already said this is not going to work.
> >>
> >> Many NIC have 2 NAPI contexts per queue, one for TX, one for RX.
> >>
> >> Relying on CFS to switch from the two 'threads' you need in the one
> >> vCPU case will add latencies that your 'pure throughput UDP flood' is
> >> not able to detect.
> >
> > We have done TCP_RR tests with similar results: when the throughput is
> > (guest) cpu bounded and multiple flows are used, there is measurable
> > gain.
> 
> TCP_RR hardly triggers the problem I am mentioning.
> 
> You need a combination of different competing works. Both bulk and rpc like.
> 
> The important factor for RPC is P99 latency.
> 
> Look, the simple fact that mlx4 driver can dequeue 256 skb per TX napi poll
> and only 64 skbs in RX poll is problematic in some workloads, since
> this allows a queue to build up on RX rings.
> 
> >
> >> I was waiting a fix from Andy Lutomirski to be merged before sending
> >> my ksoftirqd fix, which will work and wont bring kernel bloat.
> >
> > We experimented that patch in this scenario, but it don't give
> > measurable gain, since the ksoftirqd threads still prevent the qemu
> > process from using 100% of any hypervisor's cores.
> 
> Not sure what you measured, but in my experiment, the user thread
> could finally get a fair share of the core, instead of 0%
> 
> Improvement was 100000 % or so.

We used a different setup to explicitly avoid the (guest) userspace
starvation issue. Using a guest with 2vCPUs (or more) and a single queue
avoids the starvation issue, because the scheduler moves the user space
processes on a different vCPU in respect to the ksoftirqd thread.

In the hypervisor, with a vanilla kernel, the qemu process receives a
fair share of the cpu time, but considerably less 100%, and his
performances are bounded to a considerable lower throughput than the
theoretical one.

We tested your patch in both the guest and/or the hypervisor with the
above scenario and it doesn't change the throughput numbers much. But it
fixes nicely the starvation issue on single core host and we are
definitely in favor of it and waiting to get it included.

> How are you making sure your thread uses say 1% of the core, and let
> 99% to the 'qemu' process exactly ?

We allow the irq thread to be migrated. The scheduler can move it on a
different (hypervisor) core according to the workload, and qemu can
avoid completely competing with other processes for a cpu.

We are not using the threaded irqs in the guest, only into the
hypervisor.

> How the typical user will enable all this stuff exactly ?

A desktop host or a bare-metal server don't probably need/want it. An
hypervisor or an (small) router would probably enable irq threading on
all supported NICs. That could be managed by the tuned daemon or the
like with an appropriate profile.
Advanced users, also real time sensitive users, can simply use the
procfs now.

kernel without IRQ_FORCED_THREADING are unaffected, kernel with
IRQ_FORCED_THREADING can already change the packet reception (and more)
in a significant way with the forcedirq parameter.

Paolo
