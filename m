From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 2/2] cgroup: get rid of populate for memcg
Date: Mon, 9 Apr 2012 10:40:42 -0700
Message-ID: <20120409174042.GA7522@google.com>
References: <1333728250-14248-1-git-send-email-glommer@parallels.com>
 <1333728250-14248-3-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>,
	Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1333728250-14248-3-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(cc'ing other memcg ppl just in case)

Hello,

I don't think the error handling is correct here.

On Fri, Apr 06, 2012 at 08:04:10PM +0400, Glauber Costa wrote:
> The last man standing justifying the need for populate() is the
> sock memcg initialization functions. Now that we are able to pass
> a struct mem_cgroup instead of a struct cgroup to the socket
> initialization, there is nothing that stops us from initializing
> everything in create().
> 
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> CC: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> CC: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
...
> @@ -5010,7 +5010,9 @@ mem_cgroup_create(struct cgroup *cont)
>  	memcg->move_charge_at_immigrate = 0;
>  	mutex_init(&memcg->thresholds_lock);
>  	spin_lock_init(&memcg->move_lock);
> -	return &memcg->css;
> +
> +	if (!memcg_init_kmem(memcg, &mem_cgroup_subsys))
> +		return &memcg->css;
>  free_out:
>  	__mem_cgroup_free(memcg);
>  	return ERR_PTR(error);

So, the control is just falling through free_out: on kmem init
failure; however, there seem to be stuff which needs to be undone -
hotcpu_notifier() registration, which BTW seems incorrect even on its
own - unmounting and mounting again would probably make the same
notifier registered multiple times corrupting notification chain, and
ref inc on the parent.

It probably would be best to reorganize the function slightly such
that, it's organized as...

	1. alloc
	2. init stuff w/o other side effects
	3. make side effects

and add kmemcg init at the end of the second step.

Also, memcg maintainers, once the patches get updated and acked, I'd
like to route them through cgroup tree so that I can kill ->populate
there.  cgroup/for-3.5 is stable branch which can be pulled into other
trees including the memcg one.  Would that be okay?

Thanks.

-- 
tejun
