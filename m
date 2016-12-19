From: Andy Lutomirski <luto@kernel.org>
Subject: Re: Potential issues (security and otherwise) with the current
 cgroup-bpf API
Date: Mon, 19 Dec 2016 13:23:50 -0800
Message-ID: <CALCETrWr5XMkexdGp7HdkiLkQV=P9ycj+sNO7xWSRoCVxihVZA@mail.gmail.com>
References: <CALCETrV81oFwq2AgeRsN54HA1jR=b5cOZfAgve8H8zhx83DTyA@mail.gmail.com>
 <20161219205631.GA31242@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@kernel.org>, Daniel Mack <daniel@zonque.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        Kees Cook <keescook@chromium.org>, Jann Horn <jann@thejh.net>,
        Tejun Heo <tj@kernel.org>, David Ahern <dsahern@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Graf <tgraf@suug.ch>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Linux API <linux-api@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:35014 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756539AbcLSVYT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Dec 2016 16:24:19 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
        by mail.kernel.org (Postfix) with ESMTP id A106720351
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 21:24:17 +0000 (UTC)
Received: from mail-vk0-f42.google.com (mail-vk0-f42.google.com [209.85.213.42])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 6D451202B8
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 21:24:12 +0000 (UTC)
Received: by mail-vk0-f42.google.com with SMTP id p9so125997119vkd.3
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 13:24:12 -0800 (PST)
In-Reply-To: <20161219205631.GA31242@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2016 at 12:56 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Sat, Dec 17, 2016 at 10:18:44AM -0800, Andy Lutomirski wrote:
>> Hi all-
>>
>> I apologize for being rather late with this.  I didn't realize that
>> cgroup-bpf was going to be submitted for Linux 4.10, and I didn't see
>> it on the linux-api list, so I missed the discussion.
>>
>> I think that the inet ingress, egress etc filters are a neat feature,
>> but I think the API has some issues that will bite us down the road
>> if it becomes stable in its current form.
>>
>> Most of the problems I see are summarized in this transcript:
>>
>> # mkdir cg2
>> # mount -t cgroup2 none cg2
>> # mkdir cg2/nosockets
>> # strace cgrp_socket_rule cg2/nosockets/ 0
>> ...
>> open("cg2/nosockets/", O_RDONLY|O_DIRECTORY) = 3
>>
>> ^^^^ You can modify a cgroup after opening it O_RDONLY?
>>
>> bpf(BPF_PROG_LOAD, {prog_type=0x9 /* BPF_PROG_TYPE_??? */, insn_cnt=2,
>> insns=0x7fffe3568c10, license="GPL", log_level=1, log_size=262144,
>> log_buf=0x6020c0, kern_version=0}, 48) = 4
>>
>> ^^^^ This is fine.  The bpf() syscall manipulates bpf objects.
>>
>> bpf(0x8 /* BPF_??? */, 0x7fffe3568bf0, 48) = 0
>>
>> ^^^^ This is not so good:
>> ^^^^
>> ^^^^ a) The bpf() syscall is supposed to manipulate bpf objects.  This
>> ^^^^    is manipulating a cgroup.  There's no reason that a socket creation
>> ^^^^    filter couldn't be written in a different language (new iptables
>> ^^^^    table?  Simple list of address families?), but if that happened,
>> ^^^^    then using bpf() to install it would be entirely nonsensical.
>
> I don't see why it's _modifing_ the cgroup. I'm looking at it as
> network stack is using cgroup as an application group that should
> invoke bpf program at the certain point in the stack.
> imo cgroup management is orthogonal.

It is literally modifying the struct cgroup, and, as a practical
matter, it's causing membership in the cgroup to have a certain
effect.  But rather than pointless arguing, let me propose an
alternative API that I think solves most of the problems here.

In my model, BPF_PROG_ATTACH and BPF_PROG_DETACH go away completely.
Instead, the cgroup gets three new control files:
"net.ingress_filter", "net.egress_filter", and
"net.socket_create_filter".  Initially, if you read these files, you
see "none\n".

To attach a bpf filter, you open the file for write and do an ioctl on
it.  After doing the ioctl, if you read the file, you'll see
"bpf:[hash]\n" where "[hash]" is exactly what you'd see in fdinfo for
the bpf program.

To detach any type of filter, bpf or otherwise, you open the file for
write and write "none\n" (or just "none").

If you write anything else to the file, you get -EINVAL.  But, if
someone writes a new type of filter (perhaps a simple list of address
families), maybe you can enable the filter by writing something
appropriate to the file.

Now the API matches the effect.  A cgroup with something other than
"none" in one of its net.*_filter files is a cgroup that filters
network activity.  And you get CRIU compatibility for free: CRIU can
read the control file and use whatever mechanism is uses for BPF in
general to restore the cgroup filter state.   As an added bonus, you
get ACLs for free and the ugly multiplexer goes away.

>> # mkdir cg2/nosockets/sockets
>> # /home/luto/apps/linux/samples/bpf/cgrp_socket_rule cg2/nosockets/sockets/ 1
>>
>> ^^^^ This succeeded, which means that, if this feature is enabled in 4.10,
>> ^^^^ then we're stuck with its semantics.  If it returned -EINVAL instead,
>> ^^^^ there would be a chance to refine it.
>
> i don't see the problem with this behavior. bpf and cgroup are indepedent.
> Imange that socket accounting program is attached to cg2/nosockets.
> The program is readonly and carry no security meaning.
> Why cgroup should prevent creation of cg2/nosockets/foo directory ?

I think you're misunderstanding me.  What I'm saying is that, if you
allow a cgroup and one of its descendents to both enable the same type
of filter, you have just committed to some particular semantics for
what happens.  And I think that the current semantics are the *wrong*
semantics for default long-term use, so you should either fix the
semantics or disable the problematic case.

>
>> # echo $$ >cg2/nosockets/sockets/cgroup.procs
>> # ping 127.0.0.1
>> PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
>> 64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.029 ms
>
> hmm. in this case the admin created a subgroup with a group that allows
> ping, so? how's that a problem?

I think you're forgetting about namespaces.  There are two different
admins here.  There's the admin who created the outer container and
said "no sockets here".  Then there's the admin inside the container
who said "muahaha, I can create a sub-container and allow sockets
*there*".

> In case of vrf I can imagine
> a set of application auto-binding to one vrf and smaller
> set of applications binding to a different vrf.
> Or broader set of applications monitoring all tcp traffic
> and subset of them monitoring udp instead.
> Those are valid use cases.

> I guess you're advocating to run a link list of programs?
> That won't be useful for the above use cases, where there is no
> reason to run more than one program that control plane
> assigned to run for this cgroup.

Yes there is, for both monitoring and policy.  If I want to monitor
all activity in a cgroup, I probably want to monitor descendents as
well.  If I want to restrict a cgroup, I want to restrict its
descendents.

In the case where I actually don't want to hook the descendents, I'd
be find with having an option to turn off recursion.  Maybe
net.egress_filter could also say "bpf(overridable):[hash]" or
"bpf(nonrecursive):[hash]".  But you should have to opt in to allowing
your filter to be overridden.

> At this stage we decided to allow only one program per cgroup per hook
> and later can extend it if necessary.

No you can't.  Since you allow the problematic case and you gave it
the surprising "one program" semantics, you can't change it later.

> As you're pointing out, in case of security, we probably
> want to preserve original bpf program that should always be
> run first and only after it returned 'ok' (we'd need to define
> what 'ok' means in secruity context) run program attached to sub-hierarchy.

It's already defined AFAICT.  1 means okay.  0 means not okay.

> Another alternative is to disallow attaching programs in sub-hierarchy
> if parent has something already attached, but it's not useful
> for general case.
> All of these are possible future extensions.

I like this last one, but IT'S NOT A POSSIBLE FUTURE EXTENSION.  You
have to do it now (or disable the feature for 4.10).  This is why I'm
bringing this whole thing up now.

>
>> In 4.10 with With CONFIG_CGROUP_BPF=y, a cgroup can have bpf
>> programs attached that can do things if various events occur. (Right
>> now, this means socket operations, but there are plans in the works
>> to do this for LSM hooks too.) These bpf programs can say yes or no,
>> but they can also read out various data (including socket payloads!)
>> and save them away where an attacker can find them. This sounds a
>> lot like seccomp with a narrower scope but a much stronger ability to
>> exfiltrate private information.
>
> that sounds like a future problem to solve when bpf+lsm+cgroup are
> used for security.

[...]

>
> I disagree with the urgency. I see nothing that needs immediate action.
> bpf+lsm+cgroup is not in the tree yet.
>

I disagree very strongly here.  The API in 4.10 is IMO quite ugly, but
the result if bpf+lsm+cgroup works *differently* will be far, far
uglier.

I think the right solution here is to clean up the API so that it'll
work for future extensions that people are already imagining.  If this
can happen for 4.10, great.  If not, then postpone this stuff
entirely.  I've had code I've written for Linux postponed extensively
until I've gotten the API right, and it's not so bad.  (Actually, I've
even had API changes I've made reverted in -stable, IIRC.  This is
much worse than postponing before a release.)

--Andy
