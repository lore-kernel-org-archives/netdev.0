From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Thu, 26 Jan 2017 13:45:07 +1300
Message-ID: <87wpdiejjg.fsf@xmission.com>
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
        <20170125001130.GA37299@ast-mbp.thefacebook.com>
        <CALCETrWEDKMMwDFWM8L7hQ=T-Ffrwvmpd2VkvaFpKHuvVLFFEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>, Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:51765 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752026AbdAZAtd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 19:49:33 -0500
In-Reply-To: <CALCETrWEDKMMwDFWM8L7hQ=T-Ffrwvmpd2VkvaFpKHuvVLFFEA@mail.gmail.com>
        (Andy Lutomirski's message of "Wed, 25 Jan 2017 12:28:12 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Lutomirski <luto@amacapital.net> writes:

> On Tue, Jan 24, 2017 at 4:11 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
>> On Tue, Jan 24, 2017 at 01:24:54PM -0800, Andy Lutomirski wrote:
>>> On Tue, Jan 24, 2017 at 12:29 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>>> >
>>> > Users do not run around exec'ing commands in random network contexts (namespace, vrf, device, whatever) and expect them to just work.
>>>
>
>>> setns() is a bit more complicated, but it should still be fine.
>>> netns_install() requires CAP_NET_ADMIN over the target netns, so you
>>> can only switch in to a netns if you already have privilege in that
>>> netns.
>>
>> it's not fine. Consider our main use case which is cgroup-scoped traffic
>> monitoring and enforcement for well behaving apps.
>
> [...]
>
> That does indeed sound like a sensible use case.  Thanks!
>
>>
>>> But perhaps they should be less disjoint.  As far as I know,
>>> cgroup+bpf is the *only* network configuration that is being set up to
>>> run across all network namespaces.  No one has said why this is okay,
>>> let alone why it's preferable to making it work per-netns just like
>>> basically all other Linux network configuration.
>>
>> Single cls_bpf program attached to all netdevs in tc egress
>> hook can call bpf_skb_under_cgroup() to check whether given skb
>> is under given cgroup and afterwards decide to drop/redirect.
>> In terms of 'run across all netns' it's exactly the same.
>> Our monitoring use case came out of it.
>> Unfortunately bpf_skb_under_cgroup() in cls_bpf is not scalable.
>> It works fine for quick on the box monitoring where user logs in
>> to the box and can see what particular job is doing,
>> but it's not usable when there are thousands of cgroups and
>> we need to monitor them all.
>>
>>> I was hoping for an actual likely use case for the bpf hooks to be run
>>> in all namespaces.  You're arguing that iproute2 can be made to work
>>> mostly okay if bpf hooks can run in all namespaces, but the use case
>>> of intentionally making sk_bound_dev_if invalid across all namespaces
>>> seems dubious.
>>
>> I think what Tejun is proposing regarding adding global_ifindex
>> is a great idea and it will make ifindex interaction cleaner not only
>> for cgroup+bpf, but for socket and cls_bpf programs too.
>> I think it would be ok to disallow unprivileged programs (whenever
>> they come) to use of bpf_sock->bound_dev_if and only
>> allow bpf_sock->global_bound_dev_if and that should solve
>> your security concern for future unpriv programs.
>>
>> I think bpf_get_sock_netns_id() helper or sk->netns_id field would
>> be good addition as well, since it will allow 'ip vrf' to be smarter today.
>> It's also more flexible, since bpf_type_cgroup_sock program can make
>> its own decision when netns_id != expecte_id instead of hard coded.
>> Today the ip vrf use case does: 'sk->bound_dev_if = idx; return OK;'
>> it will be able to:
>>   if (sk->netns_id != expected_id)
>>     return DROP;
>>   sk->bound_dev_if = idx;
>>   return OK;
>> or
>>   if (sk->netns_id != expected_id)
>>     return OK;
>>   sk->bound_dev_if = idx;
>>   return OK;
>> or it will be able to bpf_trace_printk() or bpf_perf_event_output()
>> to send notification to vrf user space daemon and so on.
>> Such checks will run at the same speed as checks inside
>> __cgroup_bpf_run_filter_sk(), but all other users won't pay
>> for them when not in use. imo it's a win-win.
>
> Eric, does this sound okay to you?  You're the authority on exposing
> things like namespace ids to users.

*Boggle*  Things that run across all network namespaces break any kind
 of sense I have about thinking about them.

Running across more than one network namespace by default seems very
broken to me.

ifindex is definitely a per network namespace property.

We do have a netns_id in the network stack, but that is also
network namespace local.  It is just the local name of another network
namespace.

I can't imagine how any of those identifiers would make any sense
in a context that was not network namespace specific.  It has to be at a
minimum be interpreted in the context of the network namespace things
are made in.

There are also some huge security and maintenance implications if there
is a filter that can run acrosss all network namespaces.  As it sounds
like it can grant processes visibility into network namespaces they do
not already have.  Which can easily break things like Checkpoint/Restart
as well as having rather large implications for information leaks
and interference in namespaces that you a process would not otherwise
have access to.

When I have looked cgroups + network stack has never worked well in
any use case I have seen.  As cgroups are per process and that makes
things like that only appropriate for very close to the process
transmit decissions.  AKA is it ok to send this process to a socket
controlled by this PID.

I don't have the full context but I am have a hard time imagining
anything sensible going on.   I like the subject.  Let's restrict this
to the initial network namespace so things have a chance of being well
defined.

Eric
