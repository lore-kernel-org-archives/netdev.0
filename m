From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH v7 04/10] tcp memory pressure controls
Date: Mon, 5 Dec 2011 11:01:58 +0900
Message-ID: <20111205110158.8a2e270f.kamezawa.hiroyu@jp.fujitsu.com>
References: <1322611021-1730-1-git-send-email-glommer@parallels.com>
	<1322611021-1730-5-git-send-email-glommer@parallels.com>
	<20111130104943.d9b210ee.kamezawa.hiroyu@jp.fujitsu.com>
	<4ED91188.6030503@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>,
	<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	<kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>, <avagin-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	<eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	KAMEZAWA Hiroyuki <kamezawa.hiroyu-LdfC7J4mv27QFUHtdCDX3A@public.gmane.org>
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4ED91188.6030503-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2 Dec 2011 15:57:28 -0200
Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:

> On 11/29/2011 11:49 PM, KAMEZAWA Hiroyuki wrote:
> >
> >> -static struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
> >> +struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
> >>   {
> >>   	return container_of(cgroup_subsys_state(cont,
> >>   				mem_cgroup_subsys_id), struct mem_cgroup,
> >> @@ -4717,14 +4732,27 @@ static int register_kmem_files(struct cgroup *cont, struct cgroup_subsys *ss)
> >>
> >>   	ret = cgroup_add_files(cont, ss, kmem_cgroup_files,
> >>   			       ARRAY_SIZE(kmem_cgroup_files));
> >> +
> >> +	if (!ret)
> >> +		ret = mem_cgroup_sockets_init(cont, ss);
> >>   	return ret;
> >>   };
> >
> > You does initizalication here. The reason what I think is
> > 1. 'proto_list' is not available at createion of root cgroup and
> >      you need to delay set up until mounting.
> >
> > If so, please add comment or find another way.
> > This seems not very clean to me.
> 
> Yes, we do can run into some ordering issues. A part of the 
> initialization can be done earlier. But I preferred to move it all later
> instead of creating two functions for it. But I can change that if you 
> want, no big deal.
> 

Hmm. please add comments about the 'issue'. It will help readers.


> >> +	tcp->tcp_prot_mem[0] = sysctl_tcp_mem[0];
> >> +	tcp->tcp_prot_mem[1] = sysctl_tcp_mem[1];
> >> +	tcp->tcp_prot_mem[2] = sysctl_tcp_mem[2];
> >> +	tcp->tcp_memory_pressure = 0;
> >
> > Question:
> >
> > Is this value will be updated when an admin chages sysctl ?
> 
> yes.
> 
> > I guess, this value is set at system init script or some which may
> > happen later than mounting cgroup.
> > I don't like to write a guideline 'please set sysctl val before
> > mounting cgroup'
> 
> Agreed.
> 
> This code is in patch 6 (together with the limiting):
> 
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +       rcu_read_lock();
> +       memcg = mem_cgroup_from_task(current);
> +
> +       tcp_prot_mem(memcg, vec[0], 0);
> +       tcp_prot_mem(memcg, vec[1], 1);
> +       tcp_prot_mem(memcg, vec[2], 2);
> +       rcu_read_unlock();
> +#endif
> 
> tcp_prot_mem is just a wrapper around the assignment so we can access 
> memcg's inner fields.
> 


Ok. sysctl and cgroup are updated at the same time.
thank you.
-Kame

--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
