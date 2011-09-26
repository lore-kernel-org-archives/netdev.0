From: Andrew Vagin <avagin@gmail.com>
Subject: Re: [PATCH v3 4/7] per-cgroup tcp buffers control
Date: Mon, 26 Sep 2011 18:39:34 +0400
Message-ID: <4E808EA6.4000301@gmail.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com> <1316393805-3005-5-git-send-email-glommer@parallels.com>
Reply-To: avagin@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com,
        kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com,
        davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org,
        linux-mm@kvack.org, kirill@shutemov.name
To: Glauber Costa <glommer@parallels.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1316393805-3005-5-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

We can't change net.ipv4.tcp_mem if a cgroup with memory controller 
isn't mounted.

[root@dhcp-10-30-20-19 ~]# sysctl -w net.ipv4.tcp_mem="3 2 3"
error: "Invalid argument" setting key "net.ipv4.tcp_mem"

It's because tcp_max_memory is initialized in mem_cgroup_populate:

mem_cgroup_populate->register_kmem_files->sockets_populate->tcp_init_cgroup

> +int sockets_populate(struct cgroup *cgrp, struct cgroup_subsys *ss)
> +{
> +	struct proto *proto;
> +	int ret = 0;
> +
> +	read_lock(&proto_list_lock);
> +	list_for_each_entry(proto,&proto_list, node) {
> +		if (proto->init_cgroup)
> +			ret |= proto->init_cgroup(proto, cgrp, ss);
> +	}
> +	if (!ret)
> +		goto out;
> +
> +	list_for_each_entry_continue_reverse(proto,&proto_list, node)
> +		if (proto->destroy_cgroup)
> +			proto->destroy_cgroup(proto, cgrp, ss);
> +
> +out:
> +	read_unlock(&proto_list_lock);
> +	return ret;
> +}

> @@ -198,6 +203,21 @@ static int ipv4_tcp_mem(ctl_table *ctl, int write,
>   	if (ret)
>   		return ret;
>
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +	rcu_read_lock();
> +	cg = mem_cgroup_from_task(current);
> +	for (i = 0; i<  3; i++)
> +		if (vec[i]>  tcp_max_memory(cg)) {
> +			rcu_read_unlock();
> +			return -EINVAL;
> +		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
