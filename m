From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH 4/5] netdev: implement infrastructure for threadable
 napi irq
Date: Thu, 16 Jun 2016 14:03:55 +0200
Message-ID: <1466078635.4691.56.camel@redhat.com>
References: <cover.1465996447.git.pabeni@redhat.com>
	 <f5e431e8336f80d0e6f6b4c40c81a373db6d6052.1465996447.git.pabeni@redhat.com>
	 <CANn89i+EJMHeMN8=e12hoT1Jv8cCBDXeexTBdsd9hU2G=HpGZA@mail.gmail.com>
	 <1466008955.24431.35.camel@redhat.com>
	 <CANn89iJKxctv5Yzn2ecBLAjh2RtGpjNC6M3dqKXieqaORZaGsw@mail.gmail.com>
	 <1466073593.4691.47.camel@redhat.com>
	 <CANn89iL2WpZAOLDWEoJmJ3Hiv3x59c45nCQpLm66j29D0HXfcw@mail.gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iL2WpZAOLDWEoJmJ3Hiv3x59c45nCQpLm66j29D0HXfcw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-06-16 at 04:19 -0700, Eric Dumazet wrote:
> On Thu, Jun 16, 2016 at 3:39 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> > We used a different setup to explicitly avoid the (guest) userspace
> > starvation issue. Using a guest with 2vCPUs (or more) and a single queue
> > avoids the starvation issue, because the scheduler moves the user space
> > processes on a different vCPU in respect to the ksoftirqd thread.
> >
> > In the hypervisor, with a vanilla kernel, the qemu process receives a
> > fair share of the cpu time, but considerably less 100%, and his
> > performances are bounded to a considerable lower throughput than the
> > theoretical one.
> >
> 
> Completely different setup than last time. I am kind of lost.
> 
> Are you trying to find the optimal way to demonstrate your patch can be useful ?
> 
> In a case with 2 vcpus, then the _standard_ kernel will migrate the
> user thread on the cpu not used by the IRQ,
> once process scheduler can see two threads competing on one cpu
> (ksoftirqd and the user thread), and the other cpu being idle.
> 
> Trying to shift the IRQ 'thread' is not nice, since the hardware IRQ
> will be delivered on the wrong cpu.
> 
> Unless user space forces cpu pinning ? Then tell the user it should not.
> 
> The natural choice is to put both producer and consumer on same cpu
> for cache locality reasons (wake affine),
> but in stress mode allow to run the consumer on another cpu if available.
> 
> If the process scheduler fails to migrate the producer, then there is
> a bug needing to be fixed.

I guess you means 'consumer' here. The scheduler doesn't fail to migrate
it: the consumer is actually migrated a lot of times, but on each cpu a
competing and running ksoftirqd thread is found.

The general problem is that under significant network load (not
necessary udp flood, similar behavior is observed even with TCP_RR
tests), with enough rx queue available and enough flows running, no
single thread/process can use 100% of any cpu, even if the overall
capacity would allow it.

Paolo
