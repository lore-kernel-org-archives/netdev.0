From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 6/7] bpf: allow eBPF programs to use maps
Date: Tue, 4 Nov 2014 15:08:03 -0800
Message-ID: <CAMEtUuwgSDdMPeRSWGiVAXb4DfwxoBVvd2TgHdruczq2mVbM=A@mail.gmail.com>
References: <1415069656-14138-1-git-send-email-ast@plumgrid.com>
	<1415069656-14138-7-git-send-email-ast@plumgrid.com>
	<5458A17B.7030904@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5458A17B.7030904@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 4, 2014 at 1:50 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> These WARN_ON_ONCE(!rcu_read_lock_held()) seem odd. While I see the point
> that
> you're holding RCU read lock on the lookup, can you elaborate on your RCU
> usage
> here and why it's necessary for delete/update?
>
> I suspect due to the synchronize_rcu() you're using and not using any RCU
> accessors but plain memcpy() e.g. in case of the array ...?

Correct in case of array.
Also hash delete/update() call into lookup() internally
that is using _rcu() helpers...
Future map types might have much more
complex implementations (like LPM), so it helps
to state the rules early.

Another reason is more complex to explain:
A program that intends to access maps has to be one
rcu critical section. So all lookup/update/delete calls
are under rcu_lock_held.
Since programs by themselves cannot have WARN_ON
inside them, I've added WARN_ON in these three
functions that will be called from the programs to make
sure that kernel subsystems don't do (*prog->bpf_func)(...)
without taking rcu_lock if they intend to let programs
access maps.

Having said that in the future we might have a case
for programs that don't call into these functions at all
and execute instructions only. Those won't need
rcu_lock() wrap. I experimented with that for the
patch where I replaced pred-tree walker with eBPF
program. There is no rcu there. And no calls
to map accessors.

Has to be noted, that socket filters use rcu to
protect sk_filter pointer and program itself. So for that
use case we'll keep using rcu for foreseeable future.
For tracing filters I had to add rcu_lock() around
BPF_PROG_RUN() invocation and these WARN_ON
checks saved me a lot of headache, so I prefer to
keep them since they cost nothing when lockdep is off.
