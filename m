From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Mon, 19 Dec 2016 12:56:35 -0800
Message-ID: <20161219205631.GA31242@ast-mbp.thefacebook.com>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
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
In-Reply-To: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 17, 2016 at 10:18:44AM -0800, Andy Lutomirski wrote:
> Hi all-
> 
> I apologize for being rather late with this.  I didn't realize that
> cgroup-bpf was going to be submitted for Linux 4.10, and I didn't see
> it on the linux-api list, so I missed the discussion.
> 
> I think that the inet ingress, egress etc filters are a neat feature,
> but I think the API has some issues that will bite us down the road
> if it becomes stable in its current form.
> 
> Most of the problems I see are summarized in this transcript:
> 
> # mkdir cg2
> # mount -t cgroup2 none cg2
> # mkdir cg2/nosockets
> # strace cgrp_socket_rule cg2/nosockets/ 0
> ...
> open("cg2/nosockets/", O_RDONLY|O_DIRECTORY) = 3
> 
> ^^^^ You can modify a cgroup after opening it O_RDONLY?
> 
> bpf(BPF_PROG_LOAD, {prog_type=0x9 /* BPF_PROG_TYPE_??? */, insn_cnt=2,
> insns=0x7fffe3568c10, license="GPL", log_level=1, log_size=262144,
> log_buf=0x6020c0, kern_version=0}, 48) = 4
> 
> ^^^^ This is fine.  The bpf() syscall manipulates bpf objects.
> 
> bpf(0x8 /* BPF_??? */, 0x7fffe3568bf0, 48) = 0
> 
> ^^^^ This is not so good:
> ^^^^
> ^^^^ a) The bpf() syscall is supposed to manipulate bpf objects.  This
> ^^^^    is manipulating a cgroup.  There's no reason that a socket creation
> ^^^^    filter couldn't be written in a different language (new iptables
> ^^^^    table?  Simple list of address families?), but if that happened,
> ^^^^    then using bpf() to install it would be entirely nonsensical.

I don't see why it's _modifing_ the cgroup. I'm looking at it as
network stack is using cgroup as an application group that should
invoke bpf program at the certain point in the stack.
imo cgroup management is orthogonal.
I certainly don't mind adding 'cat cgroup.bpf' control file that will
print the program digest for debugging, just like we do for fdinfo,
but cgroup file interface shouldn't be used to control networking.
If there was something like networking-wide ioctl, I think it could
have been an alternative way to attach a program to a hook to a cgroup.
Adding a control file to a cgroup for the purpose of attaching bpf,
just doesn't make sense to me, since it's dragging bpf and networking
details into cgroup land. Imagine in the future somebody would want
to have nft to perform similar BPF_CGROUP_INET_INGRESS functionality.
I'd think that the position of the hook within the networking stack
would remain the same, but enum id will be different, since
other ids in that enum (like BPF_CGROUP_INET_SOCK_CREATE) are not
applicable to nft. Similarly the concept of program_fd doesn't exist
there either. So it would be using its own netlink based mechanism
and its own way of enumerating hook id. And cgroup could be passed
as a string into netlink message instead of fd.
So if somebody adds a control file to a cgroup api that takes bpf's hookid
and bpf's program_fd, such control file will only be applicable to bpf
and not usable for anything else. Hence I see no reason to go that route.

> ^^^^
> ^^^^ b) This is starting to be an excessively ugly multiplexer.  Among
> ^^^^    other things, it's very unfriendly to seccomp.
> 
> # echo $$ >cg2/nosockets/cgroup.procs
> # ping 127.0.0.1
> ping: socket: Operation not permitted
> # ls cg2/nosockets/
> cgroup.controllers  cgroup.events  cgroup.procs  cgroup.subtree_control
> # cat cg2/nosockets/cgroup.controllers
> 
> ^^^^ Something in cgroupfs should give an indication that this cgroup
> ^^^^ filters socket creation, but there's nothing there.  You should also
> ^^^^ be able to turn the filter off from cgroupfs.

Doing 'cat cg2/nosockets/cgroup.bpf' here would be useful for debugging
to see which program is attached to which hook in this cgroup.
Detaching programs via cgroup control file is a lot less clear,
since it will be confusing to a running application that attached the program
in the first place, since it won't have any indication that external entity
detached the program.
One can argue that it could be useful for curious human/admin
to detach all bpf progs from all hooks for this cgroup, but
then it probably needs dmesg warning and only usable in extreme cases
as debugging and not something control plane should ever use.

> # mkdir cg2/nosockets/sockets
> # /home/luto/apps/linux/samples/bpf/cgrp_socket_rule cg2/nosockets/sockets/ 1
> 
> ^^^^ This succeeded, which means that, if this feature is enabled in 4.10,
> ^^^^ then we're stuck with its semantics.  If it returned -EINVAL instead,
> ^^^^ there would be a chance to refine it.

i don't see the problem with this behavior. bpf and cgroup are indepedent.
Imange that socket accounting program is attached to cg2/nosockets.
The program is readonly and carry no security meaning.
Why cgroup should prevent creation of cg2/nosockets/foo directory ?

> # echo $$ >cg2/nosockets/sockets/cgroup.procs
> # ping 127.0.0.1
> PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
> 64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.029 ms

hmm. in this case the admin created a subgroup with a group that allows
ping, so? how's that a problem? In case of vrf I can imagine
a set of application auto-binding to one vrf and smaller
set of applications binding to a different vrf.
Or broader set of applications monitoring all tcp traffic
and subset of them monitoring udp instead.
Those are valid use cases.
I guess you're advocating to run a link list of programs?
That won't be useful for the above use cases, where there is no
reason to run more than one program that control plane
assigned to run for this cgroup.
At this stage we decided to allow only one program per cgroup per hook
and later can extend it if necessary.
As you're pointing out, in case of security, we probably
want to preserve original bpf program that should always be
run first and only after it returned 'ok' (we'd need to define
what 'ok' means in secruity context) run program attached to sub-hierarchy.
Another alternative is to disallow attaching programs in sub-hierarchy
if parent has something already attached, but it's not useful
for general case.
All of these are possible future extensions.

> In 4.10 with With CONFIG_CGROUP_BPF=y, a cgroup can have bpf
> programs attached that can do things if various events occur. (Right
> now, this means socket operations, but there are plans in the works
> to do this for LSM hooks too.) These bpf programs can say yes or no,
> but they can also read out various data (including socket payloads!)
> and save them away where an attacker can find them. This sounds a
> lot like seccomp with a narrower scope but a much stronger ability to
> exfiltrate private information.

that sounds like a future problem to solve when bpf+lsm+cgroup are
used for security.

> This isn't much of a problem yet because you currently need
> CAP_NET_ADMIN to create a malicious sandbox in the first place.  I'm
> sure that, in the near future, someone will want to make this stuff
> work in containers with delegated cgroup hierarchies, and then there
> may be a real problem here.

I agree. Currently cgroup+bpf+hooks are for root only and have to
go long way before they can be used for security and sandboxing.

> I've included a few security people on this thread.  The current API
> looks abusable, and it would be nice to find all the holes before
> 4.10 comes out.

I disagree with the urgency. I see nothing that needs immediate action.
bpf+lsm+cgroup is not in the tree yet.
