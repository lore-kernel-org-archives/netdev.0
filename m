From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Mon, 23 Jan 2017 13:49:04 -0800
Message-ID: <CALCETrUxQdhkPjp_kVb2ywQhH8qZ99=5vy9owB1WhthrhDcWvg@mail.gmail.com>
References: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
 <7bfbda89-1641-7089-9925-d6f751a863e1@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f44.google.com ([209.85.213.44]:35856 "EHLO
        mail-vk0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751082AbdAWVt0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 16:49:26 -0500
Received: by mail-vk0-f44.google.com with SMTP id t8so100054229vke.3
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 13:49:25 -0800 (PST)
In-Reply-To: <7bfbda89-1641-7089-9925-d6f751a863e1@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 1:03 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 1/23/17 1:36 PM, Andy Lutomirski wrote:
>> To see how cgroup+bpf interacts with network namespaces, I wrote a
>> little program called show_bind that calls getsockopt(...,
>> SO_BINDTODEVICE, ...) and prints the result.  It did this:
>>
>>  # ./ip link add dev vrf0 type vrf table 10
>>  # ./ip vrf exec vrf0 ./show_bind
>>  Default binding is "vrf0"
>>  # ./ip vrf exec vrf0 unshare -n ./show_bind
>>  show_bind: getsockopt: No such device
>>
>> What's happening here is that "ip vrf" looks up vrf0's ifindex in
>> the init netns and installs a hook that binds sockets to that
>
> It looks up the device name in the current namespace.
>
>> ifindex.  When the hook runs in a different netns, it sets
>> sk_bound_dev_if to an ifindex from the wrong netns, resulting in
>> incorrect behavior.  In this particular example, the ifindex was 4
>> and there was no ifindex 4 in the new netns.  If there had been,
>> this test would have malfunctioned differently
>
> While the cgroups and network namespace interaction needs improvement, a management tool can workaround the deficiencies:
>
> A shell in the default namespace, mgmt vrf (PS1 tells me the network context):
> dsa@kenny:mgmt:~$
>
> Switch to a different namespace (one that I run VMs for network testing):
> dsa@kenny:mgmt:~$ sudo ip netns exec vms su - dsa
>
> And then bind the shell to vrf2
> dsa@kenny:vms:~$ sudo ip vrf exec vrf2 su - dsa
> dsa@kenny:vms:vrf2:~$
>
> Or I can go straight to vrf2:
> dsa@kenny:mgmt:~$ sudo ip netns exec vms ip vrf exec vrf2 su - dsa
> dsa@kenny:vms:vrf2:~$

Indeed, if you're careful to set up the vrf cgroup in the same netns
that you end up using it in, it'll work.  But there's a bigger footgun
there than I think is warranted, and I'm not sure how iproute2 is
supposed to do all that much better given that the eBPF program can
neither see what namespace a socket is bound to nor can it act in a
way that works correctly in any namespace.

Long-term, I think the real fix is to make the hook work on a
per-netns basis and, if needed, add an interface for a cross-netns
hook to work sensibly.  But I think it's a bit late to do that for
4.10, so instead I'm proposing to limit the API to the case where it
works and the semantics are unambiguous and to leave further
improvements for later.

It's a bit unfortunate that there seems to be an impedance mismatch in
that "ip vrf" acts on cgroups and that cgroups are somewhat orthogonal
to network namespaces.

>
>
> I am testing additional iproute2 cleanups which will be sent before 4.10 is released.
>
> -----8<-----
>
>> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
>> index e89acea22ecf..c0bbc55e244d 100644
>> --- a/kernel/bpf/syscall.c
>> +++ b/kernel/bpf/syscall.c
>> @@ -902,6 +902,17 @@ static int bpf_prog_attach(const union bpf_attr *attr)
>>       struct cgroup *cgrp;
>>       enum bpf_prog_type ptype;
>>
>> +     /*
>> +      * For now, socket bpf hooks attached to cgroups can only be
>> +      * installed in the init netns and only affect the init netns.
>> +      * This could be relaxed in the future once some semantic issues
>> +      * are resolved.  For example, ifindexes belonging to one netns
>> +      * should probably not be visible to hooks installed by programs
>> +      * running in a different netns.
>> +      */
>> +     if (current->nsproxy->net_ns != &init_net)
>> +             return -EINVAL;
>> +
>>       if (!capable(CAP_NET_ADMIN))
>>               return -EPERM;
>>
>
> But should this patch be taken, shouldn't the EPERM out rank the namespace check.
>

I could see that going either way.  If the hook becomes per-netns,
then the capable() check could potentially become ns_capable() and it
would start succeeding.  I'd be happy to change it, though.

--Andy
-- 
Andy Lutomirski
AMA Capital Management, LLC
