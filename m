From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 22:22:50 +0200
Message-ID: <1462911770.5333.11.camel@redhat.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462896230.6687.74.camel@redhat.com>
	 <1462896539.23934.93.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462896539.23934.93.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-05-10 at 09:08 -0700, Eric Dumazet wrote:
> On Tue, 2016-05-10 at 18:03 +0200, Paolo Abeni wrote:
> 
> > If a single core host is under network flood, i.e. ksoftirqd is
> > scheduled and it eventually (after processing ~640 packets) will let the
> > user space process run. The latter will execute a syscall to receive a
> > packet, which will have to disable/enable bh at least once and that will
> > cause the processing of another ~640 packets. To receive a single packet
> > in user space, the kernel has to process more than one thousand packets.
> 
> Looks you found the bug then. Have you tried to fix it ?

The core functionality is implemented in ~100 lines of code, is that
the kind of bloat that do concerns you ?

That could probably be improved removing some code duplication, i.e.
factorizing napi_thread_wait() with irq_wait_for_interrupt() and
possibly napi_threaded_poll() with net_rx_action(). 

If the additional test inside napi_schedule() is really scaring, it can
be guarded with a static_key.

The ksoftirq and the local_bh_enable() design are the root of the
problem, they need to be touched/affected to solve it.

We actually experimented several different options.

Limiting the amount of work performed by local_bh_enable() somewhat
mitigate the issue, but it adds just another kernel parameter difficult
to be tuned.

Running the softirq loop exclusively inside the ksoftirqd will solve the
issue, but this is a very invasive approach, affecting all others
subsystem.

The above can be restricted to the net_rx_action only (i.e. running
net_rx_action always in ksoftirqd context). The related patch isn't
really much simpler than this and will add at least the same number of
additional tests in fast path.

Running the napi loop in a thread that can be migrated gives additional
benefit in the hyper-visor/VM scenario, which can't be achieved
elsewhere.

Would you consider the threaded irq alternative more viable ?

Cheers,

Paolo
