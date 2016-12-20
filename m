From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Mon, 19 Dec 2016 19:50:01 -0800
Message-ID: <CALCETrXymvAo-9zhQe=amToz_fs9XGniK2KLZv5Fxc66qcUx6A@mail.gmail.com>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <20161219205631.GA31242@ast-mbp.thefacebook.com> <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com> <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
 <20161220031802.GA77838@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>,
        Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161220031802.GA77838-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 19, 2016 at 7:18 PM, Alexei Starovoitov
<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Mon, Dec 19, 2016 at 04:25:32PM -0800, Andy Lutomirski wrote:
>> I think we're still talking past each other.  A big part of the point
>> of changing it is that none of this is specific to bpf.  You could (in
>
> the hooks and context passed into the program is very much bpf specific.
> That's what I've been trying to convey all along.

You mean BPF_CGROUP_RUN_PROG_INET_SOCK(sk)?  There is nothing bpf
specfic about the hook except that the name of this macro has "BPF" in
it.  There is nothing whatsoever that's bpf-specific about the context
-- sk is not bpf-specific at all.

The only thing bpf-specific about it is that it currently only invokes
bpf programs.  That could easily change.

>
>> theory -- I'm not proposing implementing these until there's demand)
>> have:
>>
>> net.socket_create_filter = "none": no filter
>> net.socket_create_filter = "bpf:baadf00d": bpf filter
>
> i'm assuming 'baadf00d' is bpf program fd expressed a text string?
> and kernel needs to parse above? will you allow capital and lower
> case for 'bpf:' ? and mixed case too? spaces and tabs allowed or not?
> can program fd expressed as decimal or hex or both?
> how do you return the error? as a text string for user space
> to parse?

No.  The kernel does not parse it because you cannot write this to the
file.  You set a bpf filter with ioctl and pass an fd.  If you *read*
the file, you get the same bpf program hash that fdinfo on the bpf
object would show -- this is for debugging and (eventually) CRIU.

>
>> net.socket_create_filter = "iptables:foobar": some iptables thingy
>> net.socket_create_filter = "nft:blahblahblah": some nft thingy
>
> iptables/nft are not applicable to 'bpf_socket_create' which
> looks into:
> struct bpf_sock {
>         __u32 bound_dev_if;
>         __u32 family;
>         __u32 type;
>         __u32 protocol;
> };
> so don't fit as an example.

The code that takes a 'struct sock' and sets up bpf_sock is
bpf-specific and would obviously not be used for non-bpf filter.  But
if you had a filter that was just a like of address families, that
filter would look at struct sock and do its own thing.  iptables
wouldn't make sense for a socket creation filter, but it would make
perfect sense for an ingress filter.  Obviously the bpf-specific state
object wouldn't be used, but it would still be a hook, invoked from
the same network code, guarded by the same static key, looking at the
same skb.

>
>> net.socket_create_filter = "disallow": no sockets created period
>> net.socket_create_filter = "address_family_list:1,2,3": allow AF 1, 2, and 3
>
> so you're proposing to add a bunch of hard coded logic to the kernel.
> First to parse such text into some sort of syntax tree or list/set
> and then have hard coded logic specifically for these two use cases?
> While above two can be implemented as trivial bpf programs already?!
> That goes 180% degree vs bpf philosophy. bpf is about moving
> the specific code out of the kernel and keeping kernel generic that
> it can solve as many use cases as possible by being programmable.

I'm not seriously proposing implementing these.  My point is that
*bpf*, while wonderful, is not the be-all-and-end-all of kernel
configurability, and other types of hooks might want to be hooked in
here.

> ...
>> What exactly isn't sensible about using cgroup_bpf for containers?
>
> my use case is close to zero overhead application network monitoring.

So if I set up a cgroup that's monitored and call it /cgroup/a and
enable delegation and if the program running there wants to do its own
monitoring in /cgroup/a/b (via delegation), then you really want the
outer monitor to silently drop events coming from /cgroup/a/b?

>
>> >> > As you're pointing out, in case of security, we probably
>> >> > want to preserve original bpf program that should always be
>> >> > run first and only after it returned 'ok' (we'd need to define
>> >> > what 'ok' means in secruity context) run program attached to sub-hierarchy.
>> >>
>> >> It's already defined AFAICT.  1 means okay.  0 means not okay.
>> >
>> > sorry that doesn't make any sense. For seccomp we have a set of
>> > ranges that mean different things. Here you're proposing to
>> > hastily assign 1 and 0 ? How is that extensible?
>> > We need to carefully think through what should be the semantics
>> > of attaching multiple programs, consider performance implications,
>> > return codes and so on.
>>
>> You already assigned it.  The return value of the bpf program, loaded
>> in Linus' tree today, tells the kernel whether to accept or reject.
>
> yes. that's what the program tells the hook.
> I'm saying that whenever we have a link list of the programs
> interaction between them may or may not be expressible with 1/0
> and I don't want to rush such decision.

Then disallow nesting.  You're welcome to not rush the decision, but
that's not what you've done.  If 4.10 is released as is, you've made
the decision and you're going to have a hard time changing it.

>
>> >
>> >> > Another alternative is to disallow attaching programs in sub-hierarchy
>> >> > if parent has something already attached, but it's not useful
>> >> > for general case.
>> >> > All of these are possible future extensions.
>> >>
>> >> I like this last one, but IT'S NOT A POSSIBLE FUTURE EXTENSION.  You
>> >> have to do it now (or disable the feature for 4.10).  This is why I'm
>> >> bringing this whole thing up now.
>> >
>> > We don't have to touch user visible api here, so extensions are fine.
>>
>> Huh?  My example in the original email attaches a program in a
>> sub-hierarchy.  Are you saying that 4.11 could make that example stop
>> working?
>
> No. As was pointed out before only root can load BPF_PROG_TYPE_CGROUP_[SKB|SOCK]
> type programs and only root can attach them.

Why?  It really seems to me that you expect that future namespaceable
bpf hooks will use a totally different API.  At KS, I sat in a room
full of people arguing about cgroup v2 and a lot of them pointed out
that there are valid, paying use cases that want to stick cgroup v1 in
a container, because the code that uses cgroup v1 in the container is
called systemd and the contained OS is called RHEL (or SuSE or Ubuntu
or Gentoo or whatever), and that code is *already written* and needs
to be contained.

The current approach to bpf hooks will bite you down the road.  David
Ahern is already proposing using it for something that is not tracing
at all, and someone will want that in a container, and there will be a
problem.

> Similarly for bpf+lsm+cgroup. In the next round of Mickael's patches
> we'll keep debating the right security model for it.
>

How about slowing down a wee bit and trying to come up with cgroup
hook semantics that work for all of these use cases?  I think my
proposal is quite close to workable.

--Andy
