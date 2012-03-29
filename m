From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH 1/3] [BUGFIX] memcg/tcp : fix to see use_hierarchy in
 tcp memcontrol cgroup
Date: Thu, 29 Mar 2012 11:14:12 +0200
Message-ID: <4F7427E4.2020307@parallels.com>
References: <4F7408B7.9090706@jp.fujitsu.com> <4F74095B.70105@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:42117 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750932Ab2C2JOS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2012 05:14:18 -0400
In-Reply-To: <4F74095B.70105@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2012 09:03 AM, KAMEZAWA Hiroyuki wrote:
> 
> Now, tcp memory control cgroup ignores memcg's use_hierarchy value
> and act as use_hierarchy=1 always. After this patch, tcp memcontrol will
> work as memcg is designed.
> 
> Note:
>     I know there is a discussion to remove use_hierarchy but this is BUG, now.
> 

Kame,

Are you sure about that?

I just tried it myself, and it seems to work:

root@inf5072-11:~/glommer-temporary/a/b# cat memory.kmem.tcp.usage_in_bytes
724992
root@inf5072-11:~/glommer-temporary/a/b# cat
../memory.kmem.tcp.usage_in_bytes
0


Did you got this conclusion through testing or code inspection?

As a matter of fact, that's why I believe the current behavior is indeed
correct:

the res_counter is initialized as:

        parent_cg = tcp_prot.proto_cgroup(parent);
        if (parent_cg)
                res_parent = parent_cg->memory_allocated;

        res_counter_init(&tcp->tcp_memory_allocated, res_parent);

now, parent is drawn from parent_mem_cgroup(), that reads as follows:

struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg)
{
        if (!memcg->res.parent)
                return NULL;
        return mem_cgroup_from_res_counter(memcg->res.parent, res);
}


so if we have use_hierarchy = 0, res.parent should be NULL (because that
is the way we initialize it)
