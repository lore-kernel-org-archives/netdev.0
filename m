From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH net-next] netns: correctly use per-netns ipv4 sysctl_tcp_mem
Date: Wed, 25 Jul 2012 16:45:37 +0400
Message-ID: <500FEA71.9080005@parallels.com>
References: <50079D47.6040001@huawei.com> <1342677832.2626.3839.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Huang Qiang <h.huangqiang@huawei.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<containers@lists.linux-foundation.org>, <yangzhenzhang@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:48896 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756555Ab2GYMs3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2012 08:48:29 -0400
In-Reply-To: <1342677832.2626.3839.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


On 07/19/2012 10:03 AM, Eric Dumazet wrote:
> On Thu, 2012-07-19 at 13:38 +0800, Huang Qiang wrote:
>> From: Yang Zhenzhang <yangzhenzhang@huawei.com>
>>
>> Now, kernel allows each net namespace to independently set up its levels
>> for tcp memory pressure thresholds.

Not really.

So the real limitation here, is done by the memory controller in cgroup,
not the proc files. AFAIK, lxc does not (yet) touches that file by
default, but it does create a memcg placeholder for you container, where
you can set that yourself.

cgroups are outside the realm of the admin, however. So once the
limitation is in place, you might want to restrain their further,
and that's the role of the files in /proc.

The goal is to have something that is as close as possible to a real
system in a container, where an admin could freely set this. (but of
course, never going over its allowance)

You can note this by what reads in sysctl_ipv4.c, when that file is
written to:

#ifdef CONFIG_MEMCG_KMEM
        rcu_read_lock();
        memcg = mem_cgroup_from_task(current);

        tcp_prot_mem(memcg, vec[0], 0);
        tcp_prot_mem(memcg, vec[1], 1);
        tcp_prot_mem(memcg, vec[2], 2);
        rcu_read_unlock();
#endif

This function is defined in tcp_memcontrol.c

void tcp_prot_mem(struct mem_cgroup *memcg, long val, int idx)
{
        struct tcp_memcontrol *tcp;
        struct cg_proto *cg_proto;

        cg_proto = tcp_prot.proto_cgroup(memcg);
        if (!cg_proto)
                return;

        tcp = tcp_from_cgproto(cg_proto);

        tcp->tcp_prot_mem[idx] = val;
}

tcp_prot_mem[] ends up being the vector you access as:

	prot = sk->sk_cgrp->sysctl_mem;

in the function you patch.

I hope it helps.
