From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Tue, 24 Jan 2017 13:24:54 -0800
Message-ID: <CALCETrXzh-7BJ4Q_oG0hBkTdK+XgDWUYe0=gLwkqG6sncskv3g@mail.gmail.com>
References: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
 <20170124020950.GA72992@ast-mbp.thefacebook.com> <CALCETrUq_ZSso_252ixzjt+WbFOv_K57zbePUXneLv-Tgi5=jA@mail.gmail.com>
 <20170124031259.GA81720@ast-mbp.thefacebook.com> <CALCETrVZqqfMO+=HGgebbAJ0TY6c3XSyY1G-Ve+g3VQiEfGwyA@mail.gmail.com>
 <08f3f57e-8c51-c893-01ad-3ce23db8166d@cumulusnetworks.com>
 <CALCETrVsqktjiPkfpcm_5uL0UL2Lzr106ZteLchJVnsKH_e-aw@mail.gmail.com>
 <20170124174823.GA17813@ast-mbp.thefacebook.com> <CALCETrW-Sj9eM+Nm9PVpqJky_30YSGhzc8hnzmddPkhHzb5_Fg@mail.gmail.com>
 <242993d5-e27c-7177-a021-610d16b150e4@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tejun Heo <tj@kernel.org>, Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f176.google.com ([209.85.217.176]:35993 "EHLO
        mail-ua0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750822AbdAXVZQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:25:16 -0500
Received: by mail-ua0-f176.google.com with SMTP id 96so144546086uaq.3
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 13:25:15 -0800 (PST)
In-Reply-To: <242993d5-e27c-7177-a021-610d16b150e4@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 12:29 PM, David Ahern <dsa@cumulusnetworks.com> wro=
te:
>
> Users do not run around exec'ing commands in random network contexts (nam=
espace, vrf, device, whatever) and expect them to just work.

I worked on some code once (deployed in production, even!) that calls
unshare() to make a netns and creates an interface and runs code in
there and expects it to just work.  It wouldn't work the outer program
were run under current ip vrf.

>
>>
>> Maybe you can argue that this is a missing feature in cgroup+bpf (no
>> API to query which netns is in use) and a corresponding bug in 'ip
>> vrf', but I see this as evidence that cgroup+bpf as it exists in 4.10
>> is not carefully enough throught through.  The only non-example user
>> of it that I can find (ip vrf) is buggy and can't really be fixed
>> using mechanisms that exist in 4.10-rc.
>
> The argument is that cgroups and namespaces are completely disjoint infra=
structure and that users need to know what they are doing.

But perhaps they should be less disjoint.  As far as I know,
cgroup+bpf is the *only* network configuration that is being set up to
run across all network namespaces.  No one has said why this is okay,
let alone why it's preferable to making it work per-netns just like
basically all other Linux network configuration.

>
>>
>>>
>>>> things up so that unshare will malfunction.  It should avoid
>>>> malfunctioning when running Linux programs that are unaware of it.
>>>
>>> I agree that for VRF use case it will help to make programs netns
>>> aware by adding new bpf_get_current_netns_id() or something helper,
>>> but it's up to the program to function properly or be broken.
>>
>> This will cause David's code to run slower, and I think he wants very
>> high performance.
>
> This is a socket create path not a packet path. While overhead should be =
contained, a few extra cycles should be fine.
>
> Adding the capability to allow users to check the netns id would offer a =
solution to the namespace problem, but there is nothing that *requires* a b=
pf program to do it.
>
> Who's to say an admin does not *want* all processes in a group to have so=
ckets bound to a non-existent device? 'ip vrf' restricts the device index t=
o a VRF device because as a management tool I want it to be user friendly, =
but generically the BPF code does not have any restrictions. ifindex can be=
 any u32 value.

I was hoping for an actual likely use case for the bpf hooks to be run
in all namespaces.  You're arguing that iproute2 can be made to work
mostly okay if bpf hooks can run in all namespaces, but the use case
of intentionally making sk_bound_dev_if invalid across all namespaces
seems dubious.

But all of what you're suggesting doing would still work fine and
would result in less kernel code *and* less eBPF code if the hooks
were per netns.

--Andy
