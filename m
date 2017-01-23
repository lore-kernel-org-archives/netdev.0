From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Mon, 23 Jan 2017 14:03:52 -0700
Message-ID: <7bfbda89-1641-7089-9925-d6f751a863e1@cumulusnetworks.com>
References: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:34244 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750705AbdAWVDy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 16:03:54 -0500
Received: by mail-pg0-f45.google.com with SMTP id 14so47854714pgg.1
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 13:03:54 -0800 (PST)
In-Reply-To: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/17 1:36 PM, Andy Lutomirski wrote:
> To see how cgroup+bpf interacts with network namespaces, I wrote a
> little program called show_bind that calls getsockopt(...,
> SO_BINDTODEVICE, ...) and prints the result.  It did this:
> 
>  # ./ip link add dev vrf0 type vrf table 10
>  # ./ip vrf exec vrf0 ./show_bind
>  Default binding is "vrf0"
>  # ./ip vrf exec vrf0 unshare -n ./show_bind
>  show_bind: getsockopt: No such device
> 
> What's happening here is that "ip vrf" looks up vrf0's ifindex in
> the init netns and installs a hook that binds sockets to that

It looks up the device name in the current namespace.

> ifindex.  When the hook runs in a different netns, it sets
> sk_bound_dev_if to an ifindex from the wrong netns, resulting in
> incorrect behavior.  In this particular example, the ifindex was 4
> and there was no ifindex 4 in the new netns.  If there had been,
> this test would have malfunctioned differently

While the cgroups and network namespace interaction needs improvement, a management tool can workaround the deficiencies:

A shell in the default namespace, mgmt vrf (PS1 tells me the network context):
dsa@kenny:mgmt:~$ 

Switch to a different namespace (one that I run VMs for network testing):
dsa@kenny:mgmt:~$ sudo ip netns exec vms su - dsa

And then bind the shell to vrf2
dsa@kenny:vms:~$ sudo ip vrf exec vrf2 su - dsa
dsa@kenny:vms:vrf2:~$

Or I can go straight to vrf2:
dsa@kenny:mgmt:~$ sudo ip netns exec vms ip vrf exec vrf2 su - dsa
dsa@kenny:vms:vrf2:~$


I am testing additional iproute2 cleanups which will be sent before 4.10 is released.

-----8<-----

> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index e89acea22ecf..c0bbc55e244d 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -902,6 +902,17 @@ static int bpf_prog_attach(const union bpf_attr *attr)
>  	struct cgroup *cgrp;
>  	enum bpf_prog_type ptype;
>  
> +	/*
> +	 * For now, socket bpf hooks attached to cgroups can only be
> +	 * installed in the init netns and only affect the init netns.
> +	 * This could be relaxed in the future once some semantic issues
> +	 * are resolved.  For example, ifindexes belonging to one netns
> +	 * should probably not be visible to hooks installed by programs
> +	 * running in a different netns.
> +	 */
> +	if (current->nsproxy->net_ns != &init_net)
> +		return -EINVAL;
> +
>  	if (!capable(CAP_NET_ADMIN))
>  		return -EPERM;
>  

But should this patch be taken, shouldn't the EPERM out rank the namespace check.
