From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2 net] bpf: add bpf_sk_netns_id() helper
Date: Sat, 4 Feb 2017 20:17:57 -0800
Message-ID: <CALCETrWvDZp0TFrw88i9gab5L6OhBwrmjYL-yMDwtMHz51HZ+A@mail.gmail.com>
References: <1486171342-3310547-1-git-send-email-ast@fb.com>
 <CALCETrU6hAxyTGZXn1Eo=Pcq8gxLL2=Ai=Hks5-PjDW-3HtJjA@mail.gmail.com>
 <20170205032548.GE73775@ast-mbp.thefacebook.com> <CALCETrU4_y0qSJu4epTO9aNEVZzt9cXY52=bHyGutbAMuEd-VA@mail.gmail.com>
 <20170205040501.GH73775@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:34160 "EHLO
        mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751237AbdBEEST (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 23:18:19 -0500
Received: by mail-vk0-f51.google.com with SMTP id r136so37541590vke.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 20:18:19 -0800 (PST)
In-Reply-To: <20170205040501.GH73775@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 4, 2017 at 8:05 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Sat, Feb 04, 2017 at 07:33:14PM -0800, Andy Lutomirski wrote:
>> On Sat, Feb 4, 2017 at 7:25 PM, Alexei Starovoitov
>> <alexei.starovoitov@gmail.com> wrote:
>> > On Sat, Feb 04, 2017 at 09:15:10AM -0800, Andy Lutomirski wrote:
>> >> On Fri, Feb 3, 2017 at 5:22 PM, Alexei Starovoitov <ast@fb.com> wrote:
>> >> > Note that all bpf programs types are global.
>> >>
>> >> I don't think this has a clear enough meaning to work with.  In
>> >
>> > Please clarify what you mean. The quoted part says
>> > "bpf programs are global". What is not "clear enough" there?
>>
>> What does "bpf programs are global" mean?  I am genuinely unable to
>> figure out what you mean.  Here are some example guesses of what you
>> might mean:
>>
>>  - BPF programs are compiled independently of a namespace.  This is
>> certainly true, but I don't think it matters.
>>
>>  - You want BPF programs to affect everything on the system.  But this
>> doesn't seem right to be -- they only affect things in the relevant
>> cgroup, so they're not global in that sense.
>
> All bpf program types are global in the sense that you can
> make all of them to operate across all possible scopes and namespaces.

I still don't understand what you mean here.  A seccomp program runs
in the process that installs it and children -- it does not run in
"all possible scopes".  A socket filter runs on a single socket and
therefore runs in a single netns.  So presumably I'm still
misunderstanding you

> cgroup only gives a scope for the program to run, but it's
> not limited by it. The user can have the same program
> attached to two or more different cgroups, so one program
> will run across multiple cgroups.

Does this mean "BPF programs are compiled independently of a
namespace?"  If so, I don't see why it's relevant at all.  Sure, you
could compile a BPF program once and install it in two different
scopes, but that doesn't mean that the kernel should *run* it globally
in any sense.  Can you clarify?

>
>>  - The set of BPF program types and the verification rules are
>> independent of cgroup and namespace.  This is true, but I don't think
>> it matters.
>
> It matters. That's actually the key to understand. The loading part
> verifies correctness for particular program type.
> Afterwards the same program can be attached to any place.
> Including different cgroups and different namespaces.
> The 'attach' part is like 'switch on' that enables program
> on particular hook. The scope (whether it's socket or netdev or cgroup)
> is a scope that program author uses to narrow down the hook,
> but it's not an ultimate restriction.
> For example the socket program can be attached to sockets and
> share information with cls_bpf program attached to netdev.
> The kprobe tracing program can peek into kernel internal data
> and share it with cls_bpf or any other type as long as
> everything is root. The information flow is global to the whole system.

Why does any of this imply that a cgroup+bpf program that is attached
once should run for all network namespaces?

>
>> Because we're one week or so from 4.10 final, the 4.10-rc code is
>> problematic even for ip vrf, and there isn't a clear solution yet.
>> There are a bunch of requirements that seem to conflict, and something
>> has to give.
>
> let's go back to the beginning:
> - you've identified a 'malfunction' in ip vrf. It's valid one. Thank you.
> - can it be fixed without kernel changes ? Yes. David offered to do so.

He has (I think) a somewhat kludgey fix that gets the "ip netns" case
right but not the "unshare -n" case.  I think the latter can't be
fixed without kernel changes.
