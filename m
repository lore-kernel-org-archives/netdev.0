From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 4/8] cgroup: Remove CGROUP_BUILTIN_SUBSYS_COUNT
Date: Thu, 13 Sep 2012 14:41:03 +0800
Message-ID: <50517FFF.4030106@huawei.com>
References: <1347459128-32236-1-git-send-email-wagi@monom.org> <1347459128-32236-5-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1347459128-32236-5-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> @@ -1321,11 +1321,13 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
>  	 * take duplicate reference counts on a subsystem that's already used,
>  	 * but rebind_subsystems handles this case.
>  	 */
> -	for (i = CGROUP_BUILTIN_SUBSYS_COUNT; i < CGROUP_SUBSYS_COUNT; i++) {
> +	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
>  		unsigned long bit = 1UL << i;
>  
>  		if (!(bit & opts->subsys_mask))
>  			continue;
> +		if (!subsys[i]->module)
> +			continue;

This check is not necessary. If it's builtin, try_module_get() will just return 1, and
we're fine.

>  		if (!try_module_get(subsys[i]->module)) {
>  			module_pin_failed = true;
>  			break;
> @@ -1337,12 +1339,14 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
>  		 * raced with a module_delete call, and to the user this is
>  		 * essentially a "subsystem doesn't exist" case.
>  		 */
> -		for (i--; i >= CGROUP_BUILTIN_SUBSYS_COUNT; i--) {
> +		for (i--; i >= 0; i--) {
>  			/* drop refcounts only on the ones we took */
>  			unsigned long bit = 1UL << i;
>  
>  			if (!(bit & opts->subsys_mask))
>  				continue;
> +			if (!subsys[i]->module)
> +				continue;

ditto

>  			module_put(subsys[i]->module);
>  		}
>  		return -ENOENT;
> @@ -1354,11 +1358,13 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
>  static void drop_parsed_module_refcounts(unsigned long subsys_mask)
>  {
>  	int i;
> -	for (i = CGROUP_BUILTIN_SUBSYS_COUNT; i < CGROUP_SUBSYS_COUNT; i++) {
> +	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
>  		unsigned long bit = 1UL << i;
>  
>  		if (!(bit & subsys_mask))
>  			continue;
> +		if (!subsys[i]->module)
> +			continue;

ditto

>  		module_put(subsys[i]->module);
>  	}
>  }
> @@ -1437,6 +1443,7 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
>  	INIT_LIST_HEAD(&cgrp->event_list);
>  	spin_lock_init(&cgrp->event_list_lock);
>  	simple_xattrs_init(&cgrp->xattrs);
> +	memset(cgrp->subsys, 0, sizeof(cgrp->subsys));

This seems an unrelated change, and is redundant. Am I missing something?

>  }
>  
