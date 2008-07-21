From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] Traffic control cgroups subsystem
Date: Mon, 21 Jul 2008 17:26:41 +0800
Message-ID: <48845651.4010904@cn.fujitsu.com>
References: <Pine.LNX.4.64.0807181425270.18212@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	menage@google.com
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57388 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754500AbYGUJ2U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 05:28:20 -0400
In-Reply-To: <Pine.LNX.4.64.0807181425270.18212@ranjit.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ranjit Manomohan wrote:
> This patch adds a traffic control cgroup subsystem that is used
> to tag all packets originating from tasks in this cgroup with a
> specific identifier (tc_classid).
> 
> Signed-off-by: Ranjit Manomohan <ranjitm@google.com>
> 
> ---
> 
> diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
> index e287745..4b12372 100644
> --- a/include/linux/cgroup_subsys.h
> +++ b/include/linux/cgroup_subsys.h
> @@ -48,3 +48,9 @@ SUBSYS(devices)
>  #endif
> 
>  /* */
> +
> +#ifdef CONFIG_CGROUP_TC
> +SUBSYS(tc)
> +#endif
> +

seems tc is not a good name... I won't know it stands for traffic-control if I
didn't know beforehand.

> +int cgroup_tc_classid(struct task_struct *tsk)
> +{
> +    rcu_read_lock();
> +    return container_of(task_subsys_state(tsk, tc_subsys_id),
> +                     struct tc_cgroup, css)->classid;
> +    rcu_read_unlock();

How do you unlock after return ;)

> +}
> +
> +static struct cgroup_subsys_state *tc_create(struct cgroup_subsys *ss,
> +                        struct cgroup *cgroup)
> +{
> +    struct tc_cgroup *tc_cgroup;
> +
> +    tc_cgroup = kzalloc(sizeof(*tc_cgroup), GFP_KERNEL);
> +

The 'if (!tc_cgroup)' below should be here.

> +    /* Copy parent's class id if present */
> +    if (cgroup->parent)
> +        tc_cgroup->classid = cgroup_to_tc(cgroup->parent)->classid;
> +
> +    if (!tc_cgroup)
> +        return ERR_PTR(-ENOMEM);
> +    return &tc_cgroup->css;
> +}
