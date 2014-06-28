From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH RFC net-next 03/14] bpf: introduce syscall(BPF, ...) and
 BPF maps
Date: Sat, 28 Jun 2014 08:34:15 -0700
Message-ID: <CALCETrUoOTtQ1R1A8Ak35fxHxaFTPHWP6oZWnXDVLKa_ESziWw@mail.gmail.com>
References: <1403913966-4927-1-git-send-email-ast@plumgrid.com>
 <1403913966-4927-4-git-send-email-ast@plumgrid.com> <CALCETrV3WLBmHewCZgfhCkjODWfq_byRg6sF7HpqZ6n9BVMBVQ@mail.gmail.com>
 <CAMEtUuzWs+MbSOGGD-Rc01DHKASa4GxbHdtCrSCLit4cUM35mA@mail.gmail.com>
 <CALCETrWy6=dzTycy-ckiMR92+nQeqAWp_Hw=hi__VSzVWZ43Ag@mail.gmail.com> <CAMEtUuwRf--qyPu3rKB7-57KAu2NdsQdEpVRckqabmf61g+h-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
In-Reply-To: <CAMEtUuwRf--qyPu3rKB7-57KAu2NdsQdEpVRckqabmf61g+h-g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 27, 2014 at 11:43 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> On Fri, Jun 27, 2014 at 11:25 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>> On Fri, Jun 27, 2014 at 10:55 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>> On Fri, Jun 27, 2014 at 5:16 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>>>> On Fri, Jun 27, 2014 at 5:05 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>>>>> BPF syscall is a demux for different BPF releated commands.
>>>>>
>>>>> 'maps' is a generic storage of different types for sharing data between kernel
>>>>> and userspace.
>>>>>
>>>>> The maps can be created/deleted from user space via BPF syscall:
>>>>> - create a map with given id, type and attributes
>>>>>   map_id = bpf_map_create(int map_id, map_type, struct nlattr *attr, int len)
>>>>>   returns positive map id or negative error
>>>>>
>>>>> - delete map with given map id
>>>>>   err = bpf_map_delete(int map_id)
>>>>>   returns zero or negative error
>>>>
>>>> What's the scope of "id"?  How is it secured?
>>>
>>> the map and program id space is global and it's cap_sys_admin only.
>>> There is no pressing need to do it with per-user limits.
>>> So the whole thing is root only for now.
>>>
>>
>> Hmm.  This may be unpleasant if you ever want to support non-root or
>> namespaced operation.
>
> I think it will be easy to extend it per namespace when we lift
> root-only restriction. It will be seamless without user api changes.
>

It might be seamless, but I'm not sure it'll be very useful.  See below.

>> How hard would it be to give these things fds?
>
> you mean programs/maps auto-terminate when creator process
> exits? I thought about it and it's appealing at first glance, but
> doesn't fit the model of existing tracepoint events which are global.
> The programs attached to events need to live without 'daemon'
> hanging around. Therefore I picked 'kernel module'- like method.

Here are some things I'd like to be able to do:

 - Load an eBPF program and use it as a seccomp filter.

 - Create a read-only map and reference it from a seccomp filter.

 - Create a data structure that a seccomp filter can write but that
the filtered process can only read.

 - Create a data structure that a seccomp filter can read but that
some other trusted process can write.

 - Create a network filter of some sort and give permission to
manipulate a list of ports to an otherwise untrusted process.

The first four of these shouldn't require privilege.

All of this fits nicely into a model where all of the eBPF objects
(filters and data structures) are represented by fds.  Read access to
the fd lets you read (or execute eBPF programs).  Write access to the
fd lets you write.  You can send them around naturally using
SCM_RIGHTS, and you can create deprivileged versions by reopening the
objects with less access.

All of this *could* fit in using global ids, but we'd need to answer
questions like "what namespace are they bound to" and "who has access
to a given fd".  I'd want to see that these questions *have* good
answers before committing to this type of model.  Keep in mind that,
for seccomp in particular, granting access to a specific uid will be
very limiting: part of the point of seccomp is to enable
user-controlled finer-grained permissions than allowed by uids and
gids.

--Andy
