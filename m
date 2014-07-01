From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC net-next 03/14] bpf: introduce syscall(BPF, ...) and
 BPF maps
Date: Mon, 30 Jun 2014 22:47:49 -0700
Message-ID: <CAMEtUuyX-tybpMEW=f-00qgq9h3AcHovLNW0_bak3oT4Oj3FuA@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
	<1403913966-4927-4-git-send-email-ast@plumgrid.com>
	<CALCETrV3WLBmHewCZgfhCkjODWfq_byRg6sF7HpqZ6n9BVMBVQ@mail.gmail.com>
	<CAMEtUuzWs+MbSOGGD-Rc01DHKASa4GxbHdtCrSCLit4cUM35mA@mail.gmail.com>
	<CALCETrWy6=dzTycy-ckiMR92+nQeqAWp_Hw=hi__VSzVWZ43Ag@mail.gmail.com>
	<CAMEtUuwRf--qyPu3rKB7-57KAu2NdsQdEpVRckqabmf61g+h-g@mail.gmail.com>
	<CALCETrUoOTtQ1R1A8Ak35fxHxaFTPHWP6oZWnXDVLKa_ESziWw@mail.gmail.com>
	<CAMEtUuzS=9Y_ZjigofvQ5d3=89RS=+d8-WGPk9VVSMc3qawWsw@mail.gmail.com>
	<CALCETrWq+=Q3G2Smjd2RYES42UagpmD0EKxFM+jNufi6_qitWg@mail.gmail.com>
	<CAMEtUuyKY=haqP11VgXHdfHBkqfB-KxuswygUd7hDPLkOFz9HQ@mail.gmail.com>
	<CALCETrW3=idHOKF56d94suiA0NoiUGwr7pENm13q6=1XMbBPdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrW3=idHOKF56d94suiA0NoiUGwr7pENm13q6=1XMbBPdw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 30, 2014 at 3:09 PM, Andy Lutomirski <luto@amacapital.net> =
wrote:
> On Sat, Jun 28, 2014 at 11:36 PM, Alexei Starovoitov <ast@plumgrid.co=
m> wrote:
>> On Sat, Jun 28, 2014 at 6:52 PM, Andy Lutomirski <luto@amacapital.ne=
t> wrote:
>>> On Sat, Jun 28, 2014 at 1:49 PM, Alexei Starovoitov <ast@plumgrid.c=
om> wrote:
>>>>
>>>> Sorry I don't like 'fd' direction at all.
>>>> 1. it will make the whole thing very socket specific and 'net' dep=
endent.
>>>> but the goal here is to be able to use eBPF for tracing in embedde=
d
>>>> setups. So it's gotta be net independent.
>>>> 2. sockets are already overloaded with all sorts of stuff. Adding =
more
>>>> types of sockets will complicate it a lot.
>>>> 3. and most important. read/write operations on sockets are not
>>>> done every nanosecond, whereas lookup operations on bpf maps
>>>> are done every dozen instructions, so we cannot have any overhead
>>>> when accessing maps.
>>>> In other words the verifier is done as static analyzer. I moved al=
l
>>>> the complexity to verify time, so at run-time the programs are as
>>>> fast as possible. I'm strongly against run-time checks in critical=
 path,
>>>> since they kill performance and make the whole approach a lot less=
 usable.
>>>
>>> I may have described my suggestion poorly.  I'm suggesting that all=
 of
>>> these global ids be replaced *for userspace's benefit* with fds.  T=
hat
>>> is, a map would have an associated struct inode, and, when you load=
 an
>>> eBPF program, you'd pass fds into the kernel instead of global ids.
>>> The kernel would still compile the eBPF program to use the global i=
ds,
>>> though.
>>
>> Hmm. If I understood you correctly, you're suggesting to do it simil=
ar
>> to ipc/mqueue, shmem, sockets do. By registering and mounting
>> a file system and providing all superblock and inode hooks=E2=80=A6 =
and
>> probably have its own namespace type=E2=80=A6 hmm=E2=80=A6 may be. T=
hat's
>> quite a bit of work to put lightly. As I said in the other email the=
 first
>> step is root only and all these complexity just not worth doing
>> at this stage.
>
> The downside of not doing it right away is that it's harder to
> retrofit in without breaking early users.
>
> You might be able to get away with using anon_inodes.  That will

Spent quite a bit of time playing with anon_inode_getfd(). The model
works ok for seccomp, but doesn't seem to work for tracing,
since tracepoints are global. Say, syscall(bpf, load_prog) returns
a process-local fd. This 'fd' as a string can be written to
debugfs/tracing/events/.../filter which will increment a refcnt of a gl=
obal
ebpf_program structure and will keep using it. When process exits it wi=
ll
close all fds which in case of ebpf_prog_fd should be a nop, since
the program is still attached to a global event. Now we have a
program and maps that still alive and dangling, since tracepoint events
keep coming, but no new process can access it. Here we just lost all
benefits of making it 'fd' based. Theoretically we can extend tracing t=
o
be fd-based too and tracepoints will auto-detach upon process exit,
but that's not going to work for all other global events. Like networki=
ng
components (bridge, ovs, =E2=80=A6) are global and they won't be adding
fd-based interfaces.
I'm still thinking about it, but it looks like that any process-local
ebpf_prog_id scheme is not going to work for global events. Thoughts?
