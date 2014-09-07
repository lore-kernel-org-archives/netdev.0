From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v10 net-next 2/2] net: filter: split filter.h and expose
 eBPF to user space
Date: Sun, 7 Sep 2014 13:13:06 -0700
Message-ID: <CAMEtUuxJLDu8AAsZQdtG781vwC8y60Ygdt4ji5tbeyTE8YbWbQ@mail.gmail.com>
References: <1409894238-9055-1-git-send-email-ast@plumgrid.com>
	<1409894238-9055-3-git-send-email-ast@plumgrid.com>
	<20140906141051.GA4245@salvia>
	<CAMEtUuxPynQ4wdWDgCU+9_3_GRYn8oA4f-emcF+mqiQdLsqEWg@mail.gmail.com>
	<20140907180737.GA5057@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linuxfoundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140907180737.GA5057@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 7, 2014 at 11:07 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>
> If the patches that provide the very first user interface don't get in
> time to this merge window round for whatever reason, we'll have the
> layout of this exposed to userspace in the next kernel version with no
> clients at all, that doesn't make sense to me.

eBPF cannot have the first user without verifier and tracing
fully reviewed, so first user cannot be in the first
patch no matter what.

In particular this patch only exposed eBPF as an _instruction set_
to user space. llvm and gcc are only two users.
llvm patches _were_ submitted to the list.
Compilers are not some fictitious users.
eBPF ISA is solid. Two backends is a proof.

For eBPF to be loaded, verifier, syscall and other pieces need to
come in gradually. So I logically split them in series:
stage I - expose instruction set
stage II - bpf syscall for maps and manpage
stage III - programs, verifier and user space testsuite
stage IV - ebpf+tracing (the first user of ebpf isa and syscall)
stage V - ebpf+sockets
stage VI - ebpf+ovs
all of the patches _were_ submitted in the past.
Split is done to make review and integration easier.

After stage III user space will be able to load eBPF programs,
but they will still be useless, because they cannot be attached
to anything. Realistically only stage IV makes first real use of
them in tracing.
You know this, yet, you're saying the first user must be
in the first series. Really, what this 'feedback' is about?

> I don't think the speed up of the llvm submission is a good argument,
> this sounds to me similar to the "please apply this patch that
> reserves this new netlink family in include/linux/netlink.h, I promise
> this new subsystem will be submitted soon though. Meanwhile this will
> speed up submission of my userspace software to distributions for
> packaging" argument.

You're not correct here. I'm not saying 'I promise it will be submitted'.
There _were_ already submitted. I split them in chunks to make
review easier and to follow standard linux philosophy of making
small decisions that can be reverted.
We still have a month until merge window, so if stages II and III
don't make it in time, Dave can revert these small patches just
as easily. You're advocating first_user_must_be_in_first_patch
approach, which is against the linux methodology.

> I think you have to find the way to send a small batch with the very
> essencial stuff that, if merged mainstream, will provide just one new
> feature while leaving the repository in consistent state. Then, send
> follow up patches that enhance your thing and that add new clients of
> it.

As I said above the _minimum_ useful program needs verifier
which is more than Dave's cutoff of 10 patches. Therefore I
split all very_essential_stuff into these stages.
Note I'm not sending radix-tree type of eBPF maps as part
of these stages, neither I send array type of eBPF maps,
though they're needed for my last stage (ebpf+ovs).
I'm not sending pointer leak detector for verifier either,
it will be needed before syscall can be exposed to unprivileged
users, etc. There is a lot of stuff that I need for ebpf+ovs that
is _not_ part of these stages. What you see is really
the minimum to make ebpf+tracing useful.
btw, all of ebpf+ovs was submitted to the list back in Sep 2013.

So there is no practical way to do first set of < 10 patches
that will be usable from user space on its own.
Even if I remove verifier and maps altogether, bpf programs
need to be attached to something like tracing and
that is again >10 patches.
These stages with small patches is only sensible approach.
