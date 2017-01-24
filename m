From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Tue, 24 Jan 2017 13:29:07 -0700
Message-ID: <242993d5-e27c-7177-a021-610d16b150e4@cumulusnetworks.com>
References: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
 <20170124020950.GA72992@ast-mbp.thefacebook.com>
 <CALCETrUq_ZSso_252ixzjt+WbFOv_K57zbePUXneLv-Tgi5=jA@mail.gmail.com>
 <20170124031259.GA81720@ast-mbp.thefacebook.com>
 <CALCETrVZqqfMO+=HGgebbAJ0TY6c3XSyY1G-Ve+g3VQiEfGwyA@mail.gmail.com>
 <08f3f57e-8c51-c893-01ad-3ce23db8166d@cumulusnetworks.com>
 <CALCETrVsqktjiPkfpcm_5uL0UL2Lzr106ZteLchJVnsKH_e-aw@mail.gmail.com>
 <20170124174823.GA17813@ast-mbp.thefacebook.com>
 <CALCETrW-Sj9eM+Nm9PVpqJky_30YSGhzc8hnzmddPkhHzb5_Fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Andy Lutomirski <luto@amacapital.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33211 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750861AbdAXU3P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:29:15 -0500
Received: by mail-pf0-f176.google.com with SMTP id y143so52406228pfb.0
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 12:29:14 -0800 (PST)
In-Reply-To: <CALCETrW-Sj9eM+Nm9PVpqJky_30YSGhzc8hnzmddPkhHzb5_Fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/24/17 11:54 AM, Andy Lutomirski wrote:
>>> My point is that, in 4.10-rc, it doesn't work right, and I doubt this
>>> problem is restricted to just 'ip vrf'.  Without some kind of change
>>> to the way that netns and cgroup+bpf interact, anything that uses
>>> sk_bound_dev_if or reads the ifindex on an skb will be subject to a
>>> huge footgun that unprivileged programs can trigger and any future
>>> attempt to make the cgroup+bpf work for unprivileged users is going to
>>> be more complicated than it deserves to be.
>>
>> For n-th time, the current BPF_PROG_TYPE_CGROUP* is root only and
>> speculation about unprivileged usage are not helping the discussion.
> 
> ...which has nothing to do with my example of how it's broken.  I used
> 'ip vrf' the way it was intended to be used and then I ran code in it
> that uses only APIs that predate eBPF.  The result was that the
> program obtained a broken socket that had sk_bound_dev_if filled in
> with a nonsense index.  There's no speculation -- it's just broken.

Again, there are many ways to arrive at this point where a socket is bound to a device index that is invalid. Nothing stops you from downloading a bpf program with an invalid ifindex. That is up to the user.

Users do not run around exec'ing commands in random network contexts (namespace, vrf, device, whatever) and expect them to just work.

> 
> Maybe you can argue that this is a missing feature in cgroup+bpf (no
> API to query which netns is in use) and a corresponding bug in 'ip
> vrf', but I see this as evidence that cgroup+bpf as it exists in 4.10
> is not carefully enough throught through.  The only non-example user
> of it that I can find (ip vrf) is buggy and can't really be fixed
> using mechanisms that exist in 4.10-rc.

The argument is that cgroups and namespaces are completely disjoint infrastructure and that users need to know what they are doing. If one uses a management tool (ip in this case) in a consistent manner it will work. If 'ip netns' is used to change namespaces, vrf is reset on the switch. And, I have a patch now to properly nest namespaces and vrfs so that mgmt vrf in multiple namespaces will work properly.

> 
>>
>>> things up so that unshare will malfunction.  It should avoid
>>> malfunctioning when running Linux programs that are unaware of it.
>>
>> I agree that for VRF use case it will help to make programs netns
>> aware by adding new bpf_get_current_netns_id() or something helper,
>> but it's up to the program to function properly or be broken.
> 
> This will cause David's code to run slower, and I think he wants very
> high performance.

This is a socket create path not a packet path. While overhead should be contained, a few extra cycles should be fine.

Adding the capability to allow users to check the netns id would offer a solution to the namespace problem, but there is nothing that *requires* a bpf program to do it.

Who's to say an admin does not *want* all processes in a group to have sockets bound to a non-existent device? 'ip vrf' restricts the device index to a VRF device because as a management tool I want it to be user friendly, but generically the BPF code does not have any restrictions. ifindex can be any u32 value.
