From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [RFC][PATCH 3/3] cgroups: net_cls subsys as module
Date: Mon, 2 Nov 2009 13:46:30 -0800
Message-ID: <20091102134630.9947e8cf.rdunlap@xenotime.net>
References: <20091102212825.GA13692@andrew.cmu.edu>
	<20091102213103.GD13692@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org, lizf@cn.fujistu.com,
	akpm@linux-foundation.org, menage@google.com
To: Ben Blum <bblum@andrew.cmu.edu>, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756986AbZKBVq3@vger.kernel.org>
In-Reply-To: <20091102213103.GD13692@andrew.cmu.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Nov 2009 16:31:03 -0500 Ben Blum wrote:

> Allows the net_cls cgroup subsystem to be compiled as a module

Please cc: netdev on networking patches.  [done]


> From: Ben Blum <bblum@andrew.cmu.edu>
> 
> This patch modifies net/sched/cls_cgroup.c to allow the net_cls subsystem to
> be optionally compiled as a module instead of builtin. The cgroup_subsys
> struct is moved around a bit to allow the subsys_id to be either declared as a
> compile-time constant by the cgroup_subsys.h include in cgroup.h, or, if it's
> a module, initialized within the struct by cgroup_load_subsys.
> 
> Signed-off-by: Ben Blum <bblum@andrew.cmu.edu>
> ---
> 
>  net/sched/Kconfig      |    2 +-
>  net/sched/cls_cgroup.c |   37 ++++++++++++++++++++++++++++---------
>  2 files changed, 29 insertions(+), 10 deletions(-)
> 
> 
> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index 929218a..8489951 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -328,7 +328,7 @@ config NET_CLS_FLOW
>  	  module will be called cls_flow.
>  
>  config NET_CLS_CGROUP
> -	bool "Control Group Classifier"
> +	tristate "Control Group Classifier"
>  	select NET_CLS
>  	depends on CGROUPS
>  	---help---
> diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
> index e4877ca..df9723b 100644
> --- a/net/sched/cls_cgroup.c
> +++ b/net/sched/cls_cgroup.c
> @@ -24,6 +24,25 @@ struct cgroup_cls_state
>  	u32 classid;
>  };
>  
> +static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
> +					       struct cgroup *cgrp);
> +static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
> +static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp);
> +
> +struct cgroup_subsys net_cls_subsys = {
> +	.name		= "net_cls",
> +	.create		= cgrp_create,
> +	.destroy	= cgrp_destroy,
> +	.populate	= cgrp_populate,
> +#ifdef CONFIG_NET_CLS_CGROUP
> +	.subsys_id	= net_cls_subsys_id,
> +#else
> +#define net_cls_subsys_id net_cls_subsys.subsys_id
> +#endif
> +	.module		= THIS_MODULE,
> +};
> +
> +
>  static inline struct cgroup_cls_state *cgrp_cls_state(struct cgroup *cgrp)
>  {
>  	return container_of(cgroup_subsys_state(cgrp, net_cls_subsys_id),
> @@ -79,14 +98,6 @@ static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
>  	return cgroup_add_files(cgrp, ss, ss_files, ARRAY_SIZE(ss_files));
>  }
>  
> -struct cgroup_subsys net_cls_subsys = {
> -	.name		= "net_cls",
> -	.create		= cgrp_create,
> -	.destroy	= cgrp_destroy,
> -	.populate	= cgrp_populate,
> -	.subsys_id	= net_cls_subsys_id,
> -};
> -
>  struct cls_cgroup_head
>  {
>  	u32			handle;
> @@ -277,12 +288,20 @@ static struct tcf_proto_ops cls_cgroup_ops __read_mostly = {
>  
>  static int __init init_cgroup_cls(void)
>  {
> -	return register_tcf_proto_ops(&cls_cgroup_ops);
> +	int ret = register_tcf_proto_ops(&cls_cgroup_ops);
> +	if (ret)
> +		return ret;
> +	ret = cgroup_load_subsys(&net_cls_subsys);
> +	if (ret)
> +		unregister_tcf_proto_ops(&cls_cgroup_ops);
> +	return ret;
>  }
>  
>  static void __exit exit_cgroup_cls(void)
>  {
>  	unregister_tcf_proto_ops(&cls_cgroup_ops);
> +	/* TODO: unload subsystem. for now, the try_module_get in load_subsys
> +	 * prevents us from getting here. */
>  }
>  
>  module_init(init_cgroup_cls);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


---
~Randy
