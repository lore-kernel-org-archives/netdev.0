From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] fix sleeping while atomic problem in sock mem_cgroup.
Date: Fri, 16 Dec 2011 01:09:59 -0500 (EST)
Message-ID: <20111216.010959.917434953281175910.davem@davemloft.net>
References: <1324003070-6573-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org
To: glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1324003070-6573-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Date: Fri, 16 Dec 2011 06:37:50 +0400

> Since we can't scan the proto_list to initialize sock cgroups, as it
> holds a rwlock, and we also want to keep the code generic enough to
> avoid calling the initialization functions of protocols directly,
> I propose we keep the interested parties in a separate list. This list
> is protected by a mutex so we can sleep and do the necessary allocations.
> 
> Also fixes a reference problem found by Randy Dunlap's randconfig.
> 
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>

Two small changes please:

1) Add an appropriate prefix to your subject line indicating the subsystem
   being changed by this patch, "net: fix sleeping ..." would be appropriate
   in this case.

2) Put the ifdef'ery into the memcontrol.h header file, rather than sock.c,
   f.e. rename register_sock_cgroup to __register_sock_cgroup(), and
   unregister_sock_cgroup to __unregister_sock_cgroup.  Then create two
   helper inlines in memcontrolh:

	#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
	static inline void register_sock_cgroup(struct proto *prot)
	{
		if (prot->proto_cgroup != NULL)
			register_sock_cgroup(prot);
	}
	static inline void unregister_sock_cgroup(struct proto *prot)
	{
		if (prot->proto_cgroup != NULL)
			unregister_sock_cgroup(prot);
	}
	#else
	static inline void register_sock_cgroup(struct proto *prot)
	{
	}
	static inline void unregister_sock_cgroup(struct proto *prot)
	{
	}
	#endif

   Then call these helpers unconditionally in net/core/sock.c

   That way you don't need any ifdefs in that file at all.
--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
