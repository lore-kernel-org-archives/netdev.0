From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH 7/7] netprio_cgroup: allow nesting and inherit config
	on cgroup creation
Date: Tue, 20 Nov 2012 09:57:14 +0100
Message-ID: <50AB45EA.2050507@monom.org>
References: <1353400211-5182-1-git-send-email-tj@kernel.org>
	<1353400211-5182-8-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	tgraf-G/eBtMaohhA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353400211-5182-8-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tejun,

On 20.11.2012 09:30, Tejun Heo wrote:
> Inherit netprio configuration from ->css_online(), allow nesting and
> remove .broken_hierarchy marking.  This makes netprio_cgroup's
> behavior match netcls_cgroup's.
>
> Note that this patch changes userland-visible behavior.  Nesting is
> allowed and the first level cgroups below the root cgroup behave
> differently - they inherit priorities from the root cgroup on creation
> instead of starting with 0.  This is unfortunate but not doing so is
> much crazier.
>
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Tested and Acked-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

> ---
>   Documentation/cgroups/net_prio.txt |  2 ++
>   net/core/netprio_cgroup.c          | 42 ++++++++++++++++++++++----------------
>   2 files changed, 26 insertions(+), 18 deletions(-)
>
> diff --git a/Documentation/cgroups/net_prio.txt b/Documentation/cgroups/net_prio.txt
> index 01b3226..a82cbd2 100644
> --- a/Documentation/cgroups/net_prio.txt
> +++ b/Documentation/cgroups/net_prio.txt
> @@ -51,3 +51,5 @@ One usage for the net_prio cgroup is with mqprio qdisc allowing application
>   traffic to be steered to hardware/driver based traffic classes. These mappings
>   can then be managed by administrators or other networking protocols such as
>   DCBX.
> +
> +A new net_prio cgroup inherits the parent's configuration.
> diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
> index b2af0d0..bde53da 100644
> --- a/net/core/netprio_cgroup.c
> +++ b/net/core/netprio_cgroup.c
> @@ -136,9 +136,6 @@ static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
>   {
>   	struct cgroup_netprio_state *cs;
>
> -	if (cgrp->parent && cgrp->parent->id)
> -		return ERR_PTR(-EINVAL);
> -
>   	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
>   	if (!cs)
>   		return ERR_PTR(-ENOMEM);
> @@ -146,16 +143,34 @@ static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
>   	return &cs->css;
>   }
>
> -static void cgrp_css_free(struct cgroup *cgrp)
> +static int cgrp_css_online(struct cgroup *cgrp)
>   {
> -	struct cgroup_netprio_state *cs = cgrp_netprio_state(cgrp);
> +	struct cgroup *parent = cgrp->parent;
>   	struct net_device *dev;
> +	int ret = 0;
> +
> +	if (!parent)
> +		return 0;

BTW, parent is always != NULL, because the root cgroup will be attached 
to the dummytop cgroup.

This is the reason why there are this check in netprio_prio()

static u32 netprio_prio(struct cgroup *cgrp, struct net_device *dev)
{
	struct netprio_map *map = rcu_dereference_rtnl(dev->priomap);

	if (map && cgrp->id < map->priomap_len)
		return map->priomap[cgrp->id];

is necessary.

cheer,
daniel
