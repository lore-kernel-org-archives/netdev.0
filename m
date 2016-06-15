From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH 4/5] netdev: implement infrastructure for threadable napi irq
Date: Wed, 15 Jun 2016 10:04:39 -0700
Message-ID: <CANn89iJKxctv5Yzn2ecBLAjh2RtGpjNC6M3dqKXieqaORZaGsw@mail.gmail.com>
References: <cover.1465996447.git.pabeni@redhat.com> <f5e431e8336f80d0e6f6b4c40c81a373db6d6052.1465996447.git.pabeni@redhat.com>
 <CANn89i+EJMHeMN8=e12hoT1Jv8cCBDXeexTBdsd9hU2G=HpGZA@mail.gmail.com> <1466008955.24431.35.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466008955.24431.35.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 15, 2016 at 9:42 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> On Wed, 2016-06-15 at 07:17 -0700, Eric Dumazet wrote:

>>
>> I really appreciate the effort, but as I already said this is not going to work.
>>
>> Many NIC have 2 NAPI contexts per queue, one for TX, one for RX.
>>
>> Relying on CFS to switch from the two 'threads' you need in the one
>> vCPU case will add latencies that your 'pure throughput UDP flood' is
>> not able to detect.
>
> We have done TCP_RR tests with similar results: when the throughput is
> (guest) cpu bounded and multiple flows are used, there is measurable
> gain.

TCP_RR hardly triggers the problem I am mentioning.

You need a combination of different competing works. Both bulk and rpc like.

The important factor for RPC is P99 latency.

Look, the simple fact that mlx4 driver can dequeue 256 skb per TX napi poll
and only 64 skbs in RX poll is problematic in some workloads, since
this allows a queue to build up on RX rings.

>
>> I was waiting a fix from Andy Lutomirski to be merged before sending
>> my ksoftirqd fix, which will work and wont bring kernel bloat.
>
> We experimented that patch in this scenario, but it don't give
> measurable gain, since the ksoftirqd threads still prevent the qemu
> process from using 100% of any hypervisor's cores.

Not sure what you measured, but in my experiment, the user thread
could finally get a fair share of the core, instead of 0%

Improvement was 100000 % or so.

How are you making sure your thread uses say 1% of the core, and let
99% to the 'qemu' process exactly ?

How the typical user will enable all this stuff exactly ?

All I am saying is that you add a complex infra, that will need a lot
of tweaks and considerable maintenance burden,
instead of fixing the existing one _first_.
