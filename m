From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Wed, 25 Jan 2017 12:28:12 -0800
Message-ID: <CALCETrWEDKMMwDFWM8L7hQ=T-Ffrwvmpd2VkvaFpKHuvVLFFEA@mail.gmail.com>
References: <20170124020950.GA72992@ast-mbp.thefacebook.com>
 <CALCETrUq_ZSso_252ixzjt+WbFOv_K57zbePUXneLv-Tgi5=jA@mail.gmail.com>
 <20170124031259.GA81720@ast-mbp.thefacebook.com> <CALCETrVZqqfMO+=HGgebbAJ0TY6c3XSyY1G-Ve+g3VQiEfGwyA@mail.gmail.com>
 <08f3f57e-8c51-c893-01ad-3ce23db8166d@cumulusnetworks.com>
 <CALCETrVsqktjiPkfpcm_5uL0UL2Lzr106ZteLchJVnsKH_e-aw@mail.gmail.com>
 <20170124174823.GA17813@ast-mbp.thefacebook.com> <CALCETrW-Sj9eM+Nm9PVpqJky_30YSGhzc8hnzmddPkhHzb5_Fg@mail.gmail.com>
 <242993d5-e27c-7177-a021-610d16b150e4@cumulusnetworks.com>
 <CALCETrXzh-7BJ4Q_oG0hBkTdK+XgDWUYe0=gLwkqG6sncskv3g@mail.gmail.com> <20170125001130.GA37299@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ahern <dsa@cumulusnetworks.com>, Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:35946 "EHLO
        mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752446AbdAYU2j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 15:28:39 -0500
Received: by mail-vk0-f42.google.com with SMTP id t8so141819260vke.3
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 12:28:34 -0800 (PST)
In-Reply-To: <20170125001130.GA37299@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 4:11 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Tue, Jan 24, 2017 at 01:24:54PM -0800, Andy Lutomirski wrote:
>> On Tue, Jan 24, 2017 at 12:29 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> >
>> > Users do not run around exec'ing commands in random network contexts (namespace, vrf, device, whatever) and expect them to just work.
>>

>> setns() is a bit more complicated, but it should still be fine.
>> netns_install() requires CAP_NET_ADMIN over the target netns, so you
>> can only switch in to a netns if you already have privilege in that
>> netns.
>
> it's not fine. Consider our main use case which is cgroup-scoped traffic
> monitoring and enforcement for well behaving apps.

[...]

That does indeed sound like a sensible use case.  Thanks!

>
>> But perhaps they should be less disjoint.  As far as I know,
>> cgroup+bpf is the *only* network configuration that is being set up to
>> run across all network namespaces.  No one has said why this is okay,
>> let alone why it's preferable to making it work per-netns just like
>> basically all other Linux network configuration.
>
> Single cls_bpf program attached to all netdevs in tc egress
> hook can call bpf_skb_under_cgroup() to check whether given skb
> is under given cgroup and afterwards decide to drop/redirect.
> In terms of 'run across all netns' it's exactly the same.
> Our monitoring use case came out of it.
> Unfortunately bpf_skb_under_cgroup() in cls_bpf is not scalable.
> It works fine for quick on the box monitoring where user logs in
> to the box and can see what particular job is doing,
> but it's not usable when there are thousands of cgroups and
> we need to monitor them all.
>
>> I was hoping for an actual likely use case for the bpf hooks to be run
>> in all namespaces.  You're arguing that iproute2 can be made to work
>> mostly okay if bpf hooks can run in all namespaces, but the use case
>> of intentionally making sk_bound_dev_if invalid across all namespaces
>> seems dubious.
>
> I think what Tejun is proposing regarding adding global_ifindex
> is a great idea and it will make ifindex interaction cleaner not only
> for cgroup+bpf, but for socket and cls_bpf programs too.
> I think it would be ok to disallow unprivileged programs (whenever
> they come) to use of bpf_sock->bound_dev_if and only
> allow bpf_sock->global_bound_dev_if and that should solve
> your security concern for future unpriv programs.
>
> I think bpf_get_sock_netns_id() helper or sk->netns_id field would
> be good addition as well, since it will allow 'ip vrf' to be smarter today.
> It's also more flexible, since bpf_type_cgroup_sock program can make
> its own decision when netns_id != expecte_id instead of hard coded.
> Today the ip vrf use case does: 'sk->bound_dev_if = idx; return OK;'
> it will be able to:
>   if (sk->netns_id != expected_id)
>     return DROP;
>   sk->bound_dev_if = idx;
>   return OK;
> or
>   if (sk->netns_id != expected_id)
>     return OK;
>   sk->bound_dev_if = idx;
>   return OK;
> or it will be able to bpf_trace_printk() or bpf_perf_event_output()
> to send notification to vrf user space daemon and so on.
> Such checks will run at the same speed as checks inside
> __cgroup_bpf_run_filter_sk(), but all other users won't pay
> for them when not in use. imo it's a win-win.

Eric, does this sound okay to you?  You're the authority on exposing
things like namespace ids to users.

>
> In parallel I'm planning to work on 'disallow override' flag
> for bpf_prog_attach. That should solve remaining concern.
> I still disagree about urgency of implementing it, but
> it's simple enough, so why not now.
>

Can you describe the exact semantics?  I really think there should be
room for adding a mode where all the relevant programs are invoked and
that this should eventually be the default.  It's the obvious behavior
and it has many fewer footguns.

I would propose the following:

 - By default, socket creation and egress filters call all registered
programs, innermost cgroup first.  If any of them return a reject
code, stop processing further filters and reject.  By default, ingress
filters call all registered programs, innermost cgroup first.  If any
of them return a reject code, stop processing further filters and
reject.  This is indended to Do The Right Thing (TM) for both
monitoring systems and for sandboxing.  For monitoring, if you stick
your hooks in the /a cgroup, you presumably want to see all traffic
that actually goes in and out.  For ingress, you want to see what's
really there before it gets further modified by hooks set up by the
monitored application (which Alexei noted above can run as root).  For
egress, you want to see what really egresses the machine, after any
modifications made by BPF programs set up by the application.  In
particular, if the application sends a packet but then rejects it via
its own hook, you *don't* want to see it because it won't actually go
out on the wire and you shouldn't charge the application for it.  For
socket creation, the outer manager should have the last word on things
like sk_bound_dev_if.

 - As an option, if needed for some application, let a hook give some
indication that it is permissible for it to be overridden.  It's not
entirely clear to me what the exact semantics should be (do only other
hooks with the special flag set override it?  Do all hooks override
it?)  If you do this, give some thought to a workload in which an
outer accounting system is using an overridable hook (for whatever
reason) and an inner application running as root has installed BPF
programs for its own purposes.
