From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2 net-next 0/5] Add bpf support to set sk_bound_dev_if
Date: Mon, 31 Oct 2016 11:16:39 -0600
Message-ID: <69b9c20b-9566-5f75-cebd-a0bd243c2d65@cumulusnetworks.com>
References: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
 <20161031.130104.2206412054220058623.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35387 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944917AbcJaRQm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 13:16:42 -0400
Received: by mail-pf0-f181.google.com with SMTP id s8so79301080pfj.2
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 10:16:41 -0700 (PDT)
In-Reply-To: <20161031.130104.2206412054220058623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/16 11:01 AM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Wed, 26 Oct 2016 17:58:37 -0700
> 
>> The recently added VRF support in Linux leverages the bind-to-device
>> API for programs to specify an L3 domain for a socket. While
>> SO_BINDTODEVICE has been around for ages, not every ipv4/ipv6 capable
>> program has support for it. Even for those programs that do support it,
>> the API requires processes to be started as root (CAP_NET_RAW) which
>> is not desirable from a general security perspective.
>>
>> This patch set leverages Daniel Mack's work to attach bpf programs to
>> a cgroup:
>>
>>     https://www.mail-archive.com/netdev@vger.kernel.org/msg134028.html
>>
>> to provide a capability to set sk_bound_dev_if for all AF_INET{6}
>> sockets opened by a process in a cgroup when the sockets are allocated.
>>
>> This capability enables running any program in a VRF context and is key
>> to deploying Management VRF, a fundamental configuration for networking
>> gear, with any Linux OS installation.
> 
> Ok, after some review I think I understand what's going on here.
> 
> It would initially seem simpler to just support forced sk_bound_dev_if
> in cgroups.  But I think I understand why you may have gone this way:

That's what the l3mdev cgroup patch does -- force the sk_bound_dev_if for sockets. Tejun pushed back on adding new controllers. The cgroup+bpf is another way to accomplish the end goal. The key is using the cgroup infra for parent-child inheritance of the policy, holder of the policy "data" to be applied, tracking what processes are in a group, what the group is for a specific process, and on. No need to reinvent that part.

> 
> 1) The cgroup-bpf code always has the cgroup hierarchy propagation
>    logic.
> 
> 2) The may be use cases for doing things with other sock members.
> 
> With respect to #2, do you know of any such planned use cases already?

One suggestion is the local port binding limitations that Mahesh and Anoop were looking into.

> 
> Also, any reason why you don't allow the cgroup bpf sk filter to return
> an error code so that the sock creation could be cancelled if the eBPF
> program desires that?  It could be useful, I suppose.

My first draft at this feature had that but I removed it for simplicity now. Can certainly add it back.
