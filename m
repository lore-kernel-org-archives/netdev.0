From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH RFC net-next 03/14] bpf: introduce syscall(BPF, ...) and
 BPF maps
Date: Mon, 30 Jun 2014 15:09:17 -0700
Message-ID: <CALCETrW3=idHOKF56d94suiA0NoiUGwr7pENm13q6=1XMbBPdw@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
 <1403913966-4927-4-git-send-email-ast@plumgrid.com> <CALCETrV3WLBmHewCZgfhCkjODWfq_byRg6sF7HpqZ6n9BVMBVQ@mail.gmail.com>
 <CAMEtUuzWs+MbSOGGD-Rc01DHKASa4GxbHdtCrSCLit4cUM35mA@mail.gmail.com>
 <CALCETrWy6=dzTycy-ckiMR92+nQeqAWp_Hw=hi__VSzVWZ43Ag@mail.gmail.com>
 <CAMEtUuwRf--qyPu3rKB7-57KAu2NdsQdEpVRckqabmf61g+h-g@mail.gmail.com>
 <CALCETrUoOTtQ1R1A8Ak35fxHxaFTPHWP6oZWnXDVLKa_ESziWw@mail.gmail.com>
 <CAMEtUuzS=9Y_ZjigofvQ5d3=89RS=+d8-WGPk9VVSMc3qawWsw@mail.gmail.com>
 <CALCETrWq+=Q3G2Smjd2RYES42UagpmD0EKxFM+jNufi6_qitWg@mail.gmail.com> <CAMEtUuyKY=haqP11VgXHdfHBkqfB-KxuswygUd7hDPLkOFz9HQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuyKY=haqP11VgXHdfHBkqfB-KxuswygUd7hDPLkOFz9HQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 28, 2014 at 11:36 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>=
 wrote:
> On Sat, Jun 28, 2014 at 6:52 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org=
> wrote:
>> On Sat, Jun 28, 2014 at 1:49 PM, Alexei Starovoitov <ast-uqk4Ao+rVK7QFizaE/u3fw@public.gmane.org=
m> wrote:
>>>
>>> Sorry I don't like 'fd' direction at all.
>>> 1. it will make the whole thing very socket specific and 'net' depe=
ndent.
>>> but the goal here is to be able to use eBPF for tracing in embedded
>>> setups. So it's gotta be net independent.
>>> 2. sockets are already overloaded with all sorts of stuff. Adding m=
ore
>>> types of sockets will complicate it a lot.
>>> 3. and most important. read/write operations on sockets are not
>>> done every nanosecond, whereas lookup operations on bpf maps
>>> are done every dozen instructions, so we cannot have any overhead
>>> when accessing maps.
>>> In other words the verifier is done as static analyzer. I moved all
>>> the complexity to verify time, so at run-time the programs are as
>>> fast as possible. I'm strongly against run-time checks in critical =
path,
>>> since they kill performance and make the whole approach a lot less =
usable.
>>
>> I may have described my suggestion poorly.  I'm suggesting that all =
of
>> these global ids be replaced *for userspace's benefit* with fds.  Th=
at
>> is, a map would have an associated struct inode, and, when you load =
an
>> eBPF program, you'd pass fds into the kernel instead of global ids.
>> The kernel would still compile the eBPF program to use the global id=
s,
>> though.
>
> Hmm. If I understood you correctly, you're suggesting to do it simila=
r
> to ipc/mqueue, shmem, sockets do. By registering and mounting
> a file system and providing all superblock and inode hooks=E2=80=A6 a=
nd
> probably have its own namespace type=E2=80=A6 hmm=E2=80=A6 may be. Th=
at's
> quite a bit of work to put lightly. As I said in the other email the =
first
> step is root only and all these complexity just not worth doing
> at this stage.

The downside of not doing it right away is that it's harder to
retrofit in without breaking early users.

You might be able to get away with using anon_inodes.  That will
prevent repoening via /proc/self/fd from working (I think), but that's
a good thing until someone fixes the /proc reopen hole.  Sigh.

--Andy
