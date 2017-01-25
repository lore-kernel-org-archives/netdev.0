From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Tue, 24 Jan 2017 16:11:34 -0800
Message-ID: <20170125001130.GA37299@ast-mbp.thefacebook.com>
References: <20170124020950.GA72992@ast-mbp.thefacebook.com>
 <CALCETrUq_ZSso_252ixzjt+WbFOv_K57zbePUXneLv-Tgi5=jA@mail.gmail.com>
 <20170124031259.GA81720@ast-mbp.thefacebook.com>
 <CALCETrVZqqfMO+=HGgebbAJ0TY6c3XSyY1G-Ve+g3VQiEfGwyA@mail.gmail.com>
 <08f3f57e-8c51-c893-01ad-3ce23db8166d@cumulusnetworks.com>
 <CALCETrVsqktjiPkfpcm_5uL0UL2Lzr106ZteLchJVnsKH_e-aw@mail.gmail.com>
 <20170124174823.GA17813@ast-mbp.thefacebook.com>
 <CALCETrW-Sj9eM+Nm9PVpqJky_30YSGhzc8hnzmddPkhHzb5_Fg@mail.gmail.com>
 <242993d5-e27c-7177-a021-610d16b150e4@cumulusnetworks.com>
 <CALCETrXzh-7BJ4Q_oG0hBkTdK+XgDWUYe0=gLwkqG6sncskv3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsa@cumulusnetworks.com>, Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34964 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750902AbdAYALj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 19:11:39 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so17834515pge.2
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 16:11:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALCETrXzh-7BJ4Q_oG0hBkTdK+XgDWUYe0=gLwkqG6sncskv3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 01:24:54PM -0800, Andy Lutomirski wrote:
> On Tue, Jan 24, 2017 at 12:29 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> >
> > Users do not run around exec'ing commands in random network contexts (namespace, vrf, device, whatever) and expect them to just work.
> 
> I worked on some code once (deployed in production, even!) that calls
> unshare() to make a netns and creates an interface and runs code in
> there and expects it to just work.

that is exactly the counter argument to your proposal which is making cgroups
ignore bpf programs acting on sockets/apps that are no longer in the root ns.
If app can escape cgroup by switching netns, it breaks the scoping assumption
in a way that user space control plane that uses cgroup+bpf cannot oversee.
The program should just work and stay visible to bpf program within
that cgroup scope. More below.

> setns() is a bit more complicated, but it should still be fine.
> netns_install() requires CAP_NET_ADMIN over the target netns, so you
> can only switch in to a netns if you already have privilege in that
> netns.

it's not fine. Consider our main use case which is cgroup-scoped traffic
monitoring and enforcement for well behaving apps.
The container management framework cannot use sandboxing and monitor
all syscalls, because it's unacceptable overhead for production apps.
These apps do unknown things including netns. Some of them run as root too.
The container management needs to see what these apps are doing from
networking point of view with lowest possible overhead. While
cgroup+bpf hook is independent from netns, it's all fine. Initially
the program will simply count bytes/packets and associate them with jobs
where job is a collection of processes. In some cases we need to
restrict whom these jobs can talk to and amount of traffic they send.
Container management doesn't place jobs into netns-es today, because
veth overhead is too high. Something like afnetns might be an option.
Whether it's going to be netns or afnetns should be orthogonal to
cgroup scoped monitoring. A job per cgroup may have multiple
netns inside and the other way around. Multiple cgroup scopes
within single netns. I don't think there is a case where
cgroup/netns scopes will be misaligned, like:
cgroup A + netns 1 and 2
cgroup B + netns 2 and 3
but I don't see a reason to restrict that either.

> But perhaps they should be less disjoint.  As far as I know,
> cgroup+bpf is the *only* network configuration that is being set up to
> run across all network namespaces.  No one has said why this is okay,
> let alone why it's preferable to making it work per-netns just like
> basically all other Linux network configuration.

Single cls_bpf program attached to all netdevs in tc egress
hook can call bpf_skb_under_cgroup() to check whether given skb
is under given cgroup and afterwards decide to drop/redirect.
In terms of 'run across all netns' it's exactly the same.
Our monitoring use case came out of it.
Unfortunately bpf_skb_under_cgroup() in cls_bpf is not scalable.
It works fine for quick on the box monitoring where user logs in
to the box and can see what particular job is doing,
but it's not usable when there are thousands of cgroups and
we need to monitor them all.

> I was hoping for an actual likely use case for the bpf hooks to be run
> in all namespaces.  You're arguing that iproute2 can be made to work
> mostly okay if bpf hooks can run in all namespaces, but the use case
> of intentionally making sk_bound_dev_if invalid across all namespaces
> seems dubious.

I think what Tejun is proposing regarding adding global_ifindex
is a great idea and it will make ifindex interaction cleaner not only
for cgroup+bpf, but for socket and cls_bpf programs too.
I think it would be ok to disallow unprivileged programs (whenever
they come) to use of bpf_sock->bound_dev_if and only
allow bpf_sock->global_bound_dev_if and that should solve
your security concern for future unpriv programs.

I think bpf_get_sock_netns_id() helper or sk->netns_id field would
be good addition as well, since it will allow 'ip vrf' to be smarter today.
It's also more flexible, since bpf_type_cgroup_sock program can make
its own decision when netns_id != expecte_id instead of hard coded.
Today the ip vrf use case does: 'sk->bound_dev_if = idx; return OK;'
it will be able to:
  if (sk->netns_id != expected_id)
    return DROP;
  sk->bound_dev_if = idx;
  return OK;
or
  if (sk->netns_id != expected_id)
    return OK;
  sk->bound_dev_if = idx;
  return OK;
or it will be able to bpf_trace_printk() or bpf_perf_event_output()
to send notification to vrf user space daemon and so on.
Such checks will run at the same speed as checks inside
__cgroup_bpf_run_filter_sk(), but all other users won't pay
for them when not in use. imo it's a win-win.

In parallel I'm planning to work on 'disallow override' flag
for bpf_prog_attach. That should solve remaining concern.
I still disagree about urgency of implementing it, but
it's simple enough, so why not now.
