From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Mon, 19 Dec 2016 19:18:04 -0800
Message-ID: <20161220031802.GA77838@ast-mbp.thefacebook.com>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <20161219205631.GA31242@ast-mbp.thefacebook.com>
 <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
 <20161220000254.GA58895@ast-mbp.thefacebook.com>
 <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>,
        Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, David Ahern <dsahern-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrU1_bDVLfokQ7zasHVmeq7S-R+603GEw59V_wuj4eE1hw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 19, 2016 at 04:25:32PM -0800, Andy Lutomirski wrote:
> On Mon, Dec 19, 2016 at 4:02 PM, Alexei Starovoitov
> <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > On Mon, Dec 19, 2016 at 01:23:50PM -0800, Andy Lutomirski wrote:
> >> On Mon, Dec 19, 2016 at 12:56 PM, Alexei Starovoitov
> >> <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> >> > On Sat, Dec 17, 2016 at 10:18:44AM -0800, Andy Lutomirski wrote:
> >> >> Hi all-
> >> >>
> >> >> I apologize for being rather late with this.  I didn't realize that
> >> >> cgroup-bpf was going to be submitted for Linux 4.10, and I didn't see
> >> >> it on the linux-api list, so I missed the discussion.
> >> >>
> >> >> I think that the inet ingress, egress etc filters are a neat feature,
> >> >> but I think the API has some issues that will bite us down the road
> >> >> if it becomes stable in its current form.
> >> >>
> >> >> Most of the problems I see are summarized in this transcript:
> >> >>
> >> >> # mkdir cg2
> >> >> # mount -t cgroup2 none cg2
> >> >> # mkdir cg2/nosockets
> >> >> # strace cgrp_socket_rule cg2/nosockets/ 0
> >> >> ...
> >> >> open("cg2/nosockets/", O_RDONLY|O_DIRECTORY) = 3
> >> >>
> >> >> ^^^^ You can modify a cgroup after opening it O_RDONLY?
> >> >>
> >> >> bpf(BPF_PROG_LOAD, {prog_type=0x9 /* BPF_PROG_TYPE_??? */, insn_cnt=2,
> >> >> insns=0x7fffe3568c10, license="GPL", log_level=1, log_size=262144,
> >> >> log_buf=0x6020c0, kern_version=0}, 48) = 4
> >> >>
> >> >> ^^^^ This is fine.  The bpf() syscall manipulates bpf objects.
> >> >>
> >> >> bpf(0x8 /* BPF_??? */, 0x7fffe3568bf0, 48) = 0
> >> >>
> >> >> ^^^^ This is not so good:
> >> >> ^^^^
> >> >> ^^^^ a) The bpf() syscall is supposed to manipulate bpf objects.  This
> >> >> ^^^^    is manipulating a cgroup.  There's no reason that a socket creation
> >> >> ^^^^    filter couldn't be written in a different language (new iptables
> >> >> ^^^^    table?  Simple list of address families?), but if that happened,
> >> >> ^^^^    then using bpf() to install it would be entirely nonsensical.
> >> >
> >> > I don't see why it's _modifing_ the cgroup. I'm looking at it as
> >> > network stack is using cgroup as an application group that should
> >> > invoke bpf program at the certain point in the stack.
> >> > imo cgroup management is orthogonal.
> >>
> >> It is literally modifying the struct cgroup, and, as a practical
> >> matter, it's causing membership in the cgroup to have a certain
> >> effect.  But rather than pointless arguing, let me propose an
> >> alternative API that I think solves most of the problems here.
> >>
> >> In my model, BPF_PROG_ATTACH and BPF_PROG_DETACH go away completely.
> >> Instead, the cgroup gets three new control files:
> >> "net.ingress_filter", "net.egress_filter", and
> >> "net.socket_create_filter".  Initially, if you read these files, you
> >> see "none\n".
> >>
> >> To attach a bpf filter, you open the file for write and do an ioctl on
> >> it.  After doing the ioctl, if you read the file, you'll see
> >> "bpf:[hash]\n" where "[hash]" is exactly what you'd see in fdinfo for
> >> the bpf program.
> >>
> >> To detach any type of filter, bpf or otherwise, you open the file for
> >> write and write "none\n" (or just "none").
> >>
> >> If you write anything else to the file, you get -EINVAL.  But, if
> >> someone writes a new type of filter (perhaps a simple list of address
> >> families), maybe you can enable the filter by writing something
> >> appropriate to the file.
> >
> > I see no difference in what you're proposing vs what is already implemented
> > from feature set point of view, but the file approach is very ugly, since
> > it's a mismatch to FD style access that bpf is using everywhere.
> > In your proposal you'd also need to add bpf prefix everywhere.
> > So the control file names should be bpf_inet_ingress, bpf_inet_egress
> > and bpf_socket_create.
> 
> I think we're still talking past each other.  A big part of the point
> of changing it is that none of this is specific to bpf.  You could (in

the hooks and context passed into the program is very much bpf specific.
That's what I've been trying to convey all along.

> theory -- I'm not proposing implementing these until there's demand)
> have:
> 
> net.socket_create_filter = "none": no filter
> net.socket_create_filter = "bpf:baadf00d": bpf filter

i'm assuming 'baadf00d' is bpf program fd expressed a text string?
and kernel needs to parse above? will you allow capital and lower
case for 'bpf:' ? and mixed case too? spaces and tabs allowed or not?
can program fd expressed as decimal or hex or both?
how do you return the error? as a text string for user space
to parse?

> net.socket_create_filter = "iptables:foobar": some iptables thingy
> net.socket_create_filter = "nft:blahblahblah": some nft thingy

iptables/nft are not applicable to 'bpf_socket_create' which
looks into:
struct bpf_sock {
        __u32 bound_dev_if;
        __u32 family;
        __u32 type;
        __u32 protocol;
};
so don't fit as an example.

> net.socket_create_filter = "disallow": no sockets created period
> net.socket_create_filter = "address_family_list:1,2,3": allow AF 1, 2, and 3

so you're proposing to add a bunch of hard coded logic to the kernel.
First to parse such text into some sort of syntax tree or list/set
and then have hard coded logic specifically for these two use cases?
While above two can be implemented as trivial bpf programs already?!
That goes 180% degree vs bpf philosophy. bpf is about moving
the specific code out of the kernel and keeping kernel generic that
it can solve as many use cases as possible by being programmable.

> See?  This API is not bpf-specific.  It's an API for filtering.  The

no. I don't see it. BPF_CGROUP_INET_SOCK_CREATE is very much bpf specific
and we just discussed it to the last the detail.

> Can you explain your use case more clearly?
...
> What exactly isn't sensible about using cgroup_bpf for containers?

my use case is close to zero overhead application network monitoring.

> >> > As you're pointing out, in case of security, we probably
> >> > want to preserve original bpf program that should always be
> >> > run first and only after it returned 'ok' (we'd need to define
> >> > what 'ok' means in secruity context) run program attached to sub-hierarchy.
> >>
> >> It's already defined AFAICT.  1 means okay.  0 means not okay.
> >
> > sorry that doesn't make any sense. For seccomp we have a set of
> > ranges that mean different things. Here you're proposing to
> > hastily assign 1 and 0 ? How is that extensible?
> > We need to carefully think through what should be the semantics
> > of attaching multiple programs, consider performance implications,
> > return codes and so on.
> 
> You already assigned it.  The return value of the bpf program, loaded
> in Linus' tree today, tells the kernel whether to accept or reject.

yes. that's what the program tells the hook.
I'm saying that whenever we have a link list of the programs
interaction between them may or may not be expressible with 1/0
and I don't want to rush such decision.

> >
> >> > Another alternative is to disallow attaching programs in sub-hierarchy
> >> > if parent has something already attached, but it's not useful
> >> > for general case.
> >> > All of these are possible future extensions.
> >>
> >> I like this last one, but IT'S NOT A POSSIBLE FUTURE EXTENSION.  You
> >> have to do it now (or disable the feature for 4.10).  This is why I'm
> >> bringing this whole thing up now.
> >
> > We don't have to touch user visible api here, so extensions are fine.
> 
> Huh?  My example in the original email attaches a program in a
> sub-hierarchy.  Are you saying that 4.11 could make that example stop
> working?

No. As was pointed out before only root can load BPF_PROG_TYPE_CGROUP_[SKB|SOCK]
type programs and only root can attach them.
and this root semantics obviously have to be preserved from now on,
but that doesn't mean that non-root combinations have to follow the same.
For example, if for some bizarre reason you want to do
net.socket_create_filter = "disallow": no sockets created period
in the hard coded way without using bpf at all
(I would certainly oppose that as a waste of kernel .text,
but I'm not going to nack it), so you can do whatever semantics you like.
Similarly for bpf+lsm+cgroup. In the next round of Mickael's patches
we'll keep debating the right security model for it.
