From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v11 net-next 04/12] bpf: expand BPF syscall with program load/unload
Date: Wed, 10 Sep 2014 10:19:39 -0700
Message-ID: <CAMEtUuxuTrhJ-Eyqc+sXK_5DeDccpN7EZ9kejS1fif-QxCOMqA@mail.gmail.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
	<1410325808-3657-5-git-send-email-ast@plumgrid.com>
	<5410062A.4090003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linuxfoundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5410062A.4090003@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 10, 2014 at 1:04 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> +       bool                    has_info;       /* whether 'info' is valid
>>         u32                     len;            /* Number of filter blocks
>> -       struct sock_fprog_kern  *orig_prog;     /* Original BPF program */
>> +       union {
>> +               struct sock_fprog_kern  *orig_prog;     /* Original BPF
>> program */
>> +               struct bpf_prog_info    *info;
>> +       };
>
>
> All members of this bpf_prog_info should go into bpf_work_struct,
> as I have intended this to be a ancillary structure here. Since
> we already allocate this anyway, you can reduce complexity by doing
> the additional allocation plus remove the has_info member.

that's doable, but won't you be worried about extra 6 fields
in there that only used by native eBPF programs?
I kept them separate not to introduce any overhead
to classic programs.

>>         struct bpf_work_struct  *work;          /* Deferred free work
>> struct */

Also we'd need to rename it, adjust the comment above
and move into linux/bpf.h, since it don't want to overload
linux/filter.h with native eBPF stuff. In my mind filter.h
is for classic and socket things, whereas bpf.h is net-less.
So I'm 50/50 on this one.
Dropping has_info flag is definitely a plus.

Rename 'struct bpf_work_struct' to 'struct bpf_prog_info' ?
bpf_prog_aux_data? bpf_prog_extra ?
Naming is hard.

> But seccomp already does refcounting on each BPF filter. Or, is the
> intention to remove this from seccomp?

seccomp refcounts its own wrapper struct on top of classic bpf.
It gets incremented when task is forked, so I suspect it will
be needed even when seccomp moves to native.
Note that 'struct sk_filter' has its own refcnt as well which
gets incremented when socket is cloned. It's independent from
eBPF program refcnt which is part of 'struct bpf_prog_info',
since the same eBPF program can be attached to multiple
sockets. So both are needed. Seccomp may want to attach
the same eBPF program to multiple tasks as well to save
some memory.
In classic BPF we may open multiple sockets and attach
the same classic BPF prog to all. prog is allocated multiple
times. JIT is called multiple times, but overhead is not huge.
For eBPF is not an option. In eBPF+tracing single program
may be attached to hundreds of events.

>> +       BUG_ON(fp->has_info);
>
> Why BUG_ON() (also in so many other places)?

because struct bpf_prog can be created in many different
ways and I had a painful bug here while developing.
I think it can be dropped now.
