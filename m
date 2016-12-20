From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Mon, 19 Dec 2016 16:02:56 -0800
Message-ID: <20161220000254.GA58895@ast-mbp.thefacebook.com>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <20161219205631.GA31242@ast-mbp.thefacebook.com>
 <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel@zonque.org>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
        Tejun Heo <tj@kernel.org>, David Ahern <dsahern@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Linux API <linux-api@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 19, 2016 at 01:23:50PM -0800, Andy Lutomirski wrote:
> On Mon, Dec 19, 2016 at 12:56 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Sat, Dec 17, 2016 at 10:18:44AM -0800, Andy Lutomirski wrote:
> >> Hi all-
> >>
> >> I apologize for being rather late with this.  I didn't realize that
> >> cgroup-bpf was going to be submitted for Linux 4.10, and I didn't see
> >> it on the linux-api list, so I missed the discussion.
> >>
> >> I think that the inet ingress, egress etc filters are a neat feature,
> >> but I think the API has some issues that will bite us down the road
> >> if it becomes stable in its current form.
> >>
> >> Most of the problems I see are summarized in this transcript:
> >>
> >> # mkdir cg2
> >> # mount -t cgroup2 none cg2
> >> # mkdir cg2/nosockets
> >> # strace cgrp_socket_rule cg2/nosockets/ 0
> >> ...
> >> open("cg2/nosockets/", O_RDONLY|O_DIRECTORY) = 3
> >>
> >> ^^^^ You can modify a cgroup after opening it O_RDONLY?
> >>
> >> bpf(BPF_PROG_LOAD, {prog_type=0x9 /* BPF_PROG_TYPE_??? */, insn_cnt=2,
> >> insns=0x7fffe3568c10, license="GPL", log_level=1, log_size=262144,
> >> log_buf=0x6020c0, kern_version=0}, 48) = 4
> >>
> >> ^^^^ This is fine.  The bpf() syscall manipulates bpf objects.
> >>
> >> bpf(0x8 /* BPF_??? */, 0x7fffe3568bf0, 48) = 0
> >>
> >> ^^^^ This is not so good:
> >> ^^^^
> >> ^^^^ a) The bpf() syscall is supposed to manipulate bpf objects.  This
> >> ^^^^    is manipulating a cgroup.  There's no reason that a socket creation
> >> ^^^^    filter couldn't be written in a different language (new iptables
> >> ^^^^    table?  Simple list of address families?), but if that happened,
> >> ^^^^    then using bpf() to install it would be entirely nonsensical.
> >
> > I don't see why it's _modifing_ the cgroup. I'm looking at it as
> > network stack is using cgroup as an application group that should
> > invoke bpf program at the certain point in the stack.
> > imo cgroup management is orthogonal.
> 
> It is literally modifying the struct cgroup, and, as a practical
> matter, it's causing membership in the cgroup to have a certain
> effect.  But rather than pointless arguing, let me propose an
> alternative API that I think solves most of the problems here.
> 
> In my model, BPF_PROG_ATTACH and BPF_PROG_DETACH go away completely.
> Instead, the cgroup gets three new control files:
> "net.ingress_filter", "net.egress_filter", and
> "net.socket_create_filter".  Initially, if you read these files, you
> see "none\n".
> 
> To attach a bpf filter, you open the file for write and do an ioctl on
> it.  After doing the ioctl, if you read the file, you'll see
> "bpf:[hash]\n" where "[hash]" is exactly what you'd see in fdinfo for
> the bpf program.
> 
> To detach any type of filter, bpf or otherwise, you open the file for
> write and write "none\n" (or just "none").
> 
> If you write anything else to the file, you get -EINVAL.  But, if
> someone writes a new type of filter (perhaps a simple list of address
> families), maybe you can enable the filter by writing something
> appropriate to the file.

I see no difference in what you're proposing vs what is already implemented
from feature set point of view, but the file approach is very ugly, since
it's a mismatch to FD style access that bpf is using everywhere.
In your proposal you'd also need to add bpf prefix everywhere.
So the control file names should be bpf_inet_ingress, bpf_inet_egress
and bpf_socket_create.
If you want to prepare such patch for them, I don't mind,
but you cannot kill syscall command, since it's more flexible
and your control-file approach _will_ be obsolete pretty quickly.

> Now the API matches the effect.  A cgroup with something other than
> "none" in one of its net.*_filter files is a cgroup that filters
> network activity.  And you get CRIU compatibility for free: CRIU can
> read the control file and use whatever mechanism is uses for BPF in
> general to restore the cgroup filter state.   As an added bonus, you
> get ACLs for free and the ugly multiplexer goes away.

extended bpf is not supported by criu. only classic, so having
control_file-style attachment doesn't buy us anything.

> >> # mkdir cg2/nosockets/sockets
> >> # /home/luto/apps/linux/samples/bpf/cgrp_socket_rule cg2/nosockets/sockets/ 1
> >>
> >> ^^^^ This succeeded, which means that, if this feature is enabled in 4.10,
> >> ^^^^ then we're stuck with its semantics.  If it returned -EINVAL instead,
> >> ^^^^ there would be a chance to refine it.
> >
> > i don't see the problem with this behavior. bpf and cgroup are indepedent.
> > Imange that socket accounting program is attached to cg2/nosockets.
> > The program is readonly and carry no security meaning.
> > Why cgroup should prevent creation of cg2/nosockets/foo directory ?
> 
> I think you're misunderstanding me.  What I'm saying is that, if you
> allow a cgroup and one of its descendents to both enable the same type
> of filter, you have just committed to some particular semantics for
> what happens.  And I think that the current semantics are the *wrong*
> semantics for default long-term use, so you should either fix the
> semantics or disable the problematic case.

Are you saying that use cases I provided are also 'wrong'?
If you insist on that we won't be able to make any forward progress.
The current semantics is fine for what it's designed for.

> >> # echo $$ >cg2/nosockets/sockets/cgroup.procs
> >> # ping 127.0.0.1
> >> PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
> >> 64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.029 ms
> >
> > hmm. in this case the admin created a subgroup with a group that allows
> > ping, so? how's that a problem?
> 
> I think you're forgetting about namespaces.  There are two different
> admins here.  There's the admin who created the outer container and
> said "no sockets here".  Then there's the admin inside the container
> who said "muahaha, I can create a sub-container and allow sockets
> *there*".

container management frameworks should be doing sensible
things. With any infra in the kernel there are many ways to
create non-sensical setups. It's not a job of the kernel
to interfere with user space.

> > In case of vrf I can imagine
> > a set of application auto-binding to one vrf and smaller
> > set of applications binding to a different vrf.
> > Or broader set of applications monitoring all tcp traffic
> > and subset of them monitoring udp instead.
> > Those are valid use cases.
> 
> > I guess you're advocating to run a link list of programs?
> > That won't be useful for the above use cases, where there is no
> > reason to run more than one program that control plane
> > assigned to run for this cgroup.
> 
> Yes there is, for both monitoring and policy.  If I want to monitor
> all activity in a cgroup, I probably want to monitor descendents as
> well.  If I want to restrict a cgroup, I want to restrict its
> descendents.

you're ignoring use cases I described earlier.
In vrf case there is only one ifindex it needs to bind to.

> In the case where I actually don't want to hook the descendents, I'd
> be find with having an option to turn off recursion.  Maybe
> net.egress_filter could also say "bpf(overridable):[hash]" or
> "bpf(nonrecursive):[hash]".  But you should have to opt in to allowing
> your filter to be overridden.

'opt in' only makes sense if you're implementing sandboxing environment.
It doesn't make sense as the default.

> > At this stage we decided to allow only one program per cgroup per hook
> > and later can extend it if necessary.
> 
> No you can't.  Since you allow the problematic case and you gave it
> the surprising "one program" semantics, you can't change it later.

please show me why we cannot? As far as I can see nothing prevents
that in the future. We can add any number of new fields to
BPF_PROG_ATTACH command just like we did in the past with
other commands, whereas control file interface is not extensible.

> > As you're pointing out, in case of security, we probably
> > want to preserve original bpf program that should always be
> > run first and only after it returned 'ok' (we'd need to define
> > what 'ok' means in secruity context) run program attached to sub-hierarchy.
> 
> It's already defined AFAICT.  1 means okay.  0 means not okay.

sorry that doesn't make any sense. For seccomp we have a set of
ranges that mean different things. Here you're proposing to
hastily assign 1 and 0 ? How is that extensible?
We need to carefully think through what should be the semantics
of attaching multiple programs, consider performance implications,
return codes and so on.

> > Another alternative is to disallow attaching programs in sub-hierarchy
> > if parent has something already attached, but it's not useful
> > for general case.
> > All of these are possible future extensions.
> 
> I like this last one, but IT'S NOT A POSSIBLE FUTURE EXTENSION.  You
> have to do it now (or disable the feature for 4.10).  This is why I'm
> bringing this whole thing up now.

We don't have to touch user visible api here, so extensions are fine.

> >> In 4.10 with With CONFIG_CGROUP_BPF=y, a cgroup can have bpf
> >> programs attached that can do things if various events occur. (Right
> >> now, this means socket operations, but there are plans in the works
> >> to do this for LSM hooks too.) These bpf programs can say yes or no,
> >> but they can also read out various data (including socket payloads!)
> >> and save them away where an attacker can find them. This sounds a
> >> lot like seccomp with a narrower scope but a much stronger ability to
> >> exfiltrate private information.
> >
> > that sounds like a future problem to solve when bpf+lsm+cgroup are
> > used for security.
> 
> [...]
> 
> >
> > I disagree with the urgency. I see nothing that needs immediate action.
> > bpf+lsm+cgroup is not in the tree yet.
> >
> 
> I disagree very strongly here.  The API in 4.10 is IMO quite ugly, but
> the result if bpf+lsm+cgroup works *differently* will be far, far
> uglier.

again we're talking about the future here and 'ugly' is the matter of taste.
I hear all the time that people say that netlink api is ugly, so?

> I think the right solution here is to clean up the API so that it'll
> work for future extensions that people are already imagining.  If this
> can happen for 4.10, great.  If not, then postpone this stuff
> entirely.  I've had code I've written for Linux postponed extensively
> until I've gotten the API right, and it's not so bad.  (Actually, I've
> even had API changes I've made reverted in -stable, IIRC.  This is
> much worse than postponing before a release.)

huh? 'not right api' because it's using bpf syscall instead
of cgroup control-file? I think the opposite is the truth.
syscall style is more extensible whereas control-file and text
based interfaces have proven to be huge pain to extend and maintain.
Again, I don't mind if you want to have both available.
