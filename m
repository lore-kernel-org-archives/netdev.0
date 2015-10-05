From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] ovs: do not allocate memory from offline numa node
Date: Mon, 5 Oct 2015 15:59:20 +0200
Message-ID: <56128238.8010305@suse.cz>
References: <20151002101822.12499.27658.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	dev@openvswitch.org, Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151002101822.12499.27658.stgit@buzz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/02/2015 12:18 PM, Konstantin Khlebnikov wrote:
> When openvswitch tries allocate memory from offline numa node 0:
> stats = kmem_cache_alloc_node(flow_stats_cache, GFP_KERNEL | __GFP_ZERO, 0)
> It catches VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid))
> [ replaced with VM_WARN_ON(!node_online(nid)) recently ] in linux/gfp.h
> This patch disables numa affinity in this case.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

...

> diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
> index f2ea83ba4763..c7f74aab34b9 100644
> --- a/net/openvswitch/flow_table.c
> +++ b/net/openvswitch/flow_table.c
> @@ -93,7 +93,8 @@ struct sw_flow *ovs_flow_alloc(void)
>
>   	/* Initialize the default stat node. */
>   	stats = kmem_cache_alloc_node(flow_stats_cache,
> -				      GFP_KERNEL | __GFP_ZERO, 0);
> +				      GFP_KERNEL | __GFP_ZERO,
> +				      node_online(0) ? 0 : NUMA_NO_NODE);

Stupid question: can node 0 become offline between this check, and the 
VM_WARN_ON? :) BTW what kind of system has node 0 offline?

>   	if (!stats)
>   		goto err;
>
>
