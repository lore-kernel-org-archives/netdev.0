From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH] openvswitch: make for_each_node loops work with sparse
 numa systems
Date: Tue, 21 Jul 2015 09:24:18 -0700
Message-ID: <20150721162418.GM38815@linux.vnet.ibm.com>
References: <1437492756-22777-1-git-send-email-chris.j.arges@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pshelar@nicira.com, linuxppc-dev@lists.ozlabs.org,
	benh@kernel.crashing.org, linux-numa@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	dev@openvswitch.org, linux-kernel@vger.kernel.org
To: Chris J Arges <chris.j.arges@canonical.com>
Return-path: <linux-numa-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1437492756-22777-1-git-send-email-chris.j.arges@canonical.com>
Sender: linux-numa-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21.07.2015 [10:32:34 -0500], Chris J Arges wrote:
> Some architectures like POWER can have a NUMA node_possible_map that
> contains sparse entries. This causes memory corruption with openvswitch
> since it allocates flow_cache with a multiple of num_possible_nodes() and

Couldn't this also be fixed by just allocationg with a multiple of
nr_node_ids (which seems to have been the original intent all along)?
You could then make your stats array be sparse or not.

> assumes the node variable returned by for_each_node will index into
> flow->stats[node].
> 
> For example, if node_possible_map is 0x30003, this patch will map node to
> node_cnt as follows:
>     0,1,16,17 => 0,1,2,3
> 
> The crash was noticed after 3af229f2 was applied as it changed the
> node_possible_map to match node_online_map on boot.
> Fixes: 3af229f2071f5b5cb31664be6109561fbe19c861

My concern with this version of the fix is that you're relying on,
implicitly, the order of for_each_node's iteration corresponding to the
entries in stats 1:1. But what about node hotplug? It seems better to
have the enumeration of the stats array match the topology accurately,
rather, or to maintain some sort of internal map in the OVS code between
the NUMA node and the entry in the stats array?

I'm willing to be convinced otherwise, though :)

-Nish

> Signed-off-by: Chris J Arges <chris.j.arges@canonical.com>
> ---
>  net/openvswitch/flow.c       | 10 ++++++----
>  net/openvswitch/flow_table.c | 18 +++++++++++-------
>  2 files changed, 17 insertions(+), 11 deletions(-)
> 
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index bc7b0ab..425d45d 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -134,14 +134,14 @@ void ovs_flow_stats_get(const struct sw_flow *flow,
>  			struct ovs_flow_stats *ovs_stats,
>  			unsigned long *used, __be16 *tcp_flags)
>  {
> -	int node;
> +	int node, node_cnt = 0;
> 
>  	*used = 0;
>  	*tcp_flags = 0;
>  	memset(ovs_stats, 0, sizeof(*ovs_stats));
> 
>  	for_each_node(node) {
> -		struct flow_stats *stats = rcu_dereference_ovsl(flow->stats[node]);
> +		struct flow_stats *stats = rcu_dereference_ovsl(flow->stats[node_cnt]);
> 
>  		if (stats) {
>  			/* Local CPU may write on non-local stats, so we must
> @@ -155,16 +155,17 @@ void ovs_flow_stats_get(const struct sw_flow *flow,
>  			ovs_stats->n_bytes += stats->byte_count;
>  			spin_unlock_bh(&stats->lock);
>  		}
> +		node_cnt++;
>  	}
>  }
> 
>  /* Called with ovs_mutex. */
>  void ovs_flow_stats_clear(struct sw_flow *flow)
>  {
> -	int node;
> +	int node, node_cnt = 0;
> 
>  	for_each_node(node) {
> -		struct flow_stats *stats = ovsl_dereference(flow->stats[node]);
> +		struct flow_stats *stats = ovsl_dereference(flow->stats[node_cnt]);
> 
>  		if (stats) {
>  			spin_lock_bh(&stats->lock);
> @@ -174,6 +175,7 @@ void ovs_flow_stats_clear(struct sw_flow *flow)
>  			stats->tcp_flags = 0;
>  			spin_unlock_bh(&stats->lock);
>  		}
> +		node_cnt++;
>  	}
>  }
> 
> diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
> index 4613df8..5d10c54 100644
> --- a/net/openvswitch/flow_table.c
> +++ b/net/openvswitch/flow_table.c
> @@ -77,7 +77,7 @@ struct sw_flow *ovs_flow_alloc(void)
>  {
>  	struct sw_flow *flow;
>  	struct flow_stats *stats;
> -	int node;
> +	int node, node_cnt = 0;
> 
>  	flow = kmem_cache_alloc(flow_cache, GFP_KERNEL);
>  	if (!flow)
> @@ -99,9 +99,11 @@ struct sw_flow *ovs_flow_alloc(void)
> 
>  	RCU_INIT_POINTER(flow->stats[0], stats);
> 
> -	for_each_node(node)
> +	for_each_node(node) {
>  		if (node != 0)
> -			RCU_INIT_POINTER(flow->stats[node], NULL);
> +			RCU_INIT_POINTER(flow->stats[node_cnt], NULL);
> +		node_cnt++;
> +	}
> 
>  	return flow;
>  err:
> @@ -139,15 +141,17 @@ static struct flex_array *alloc_buckets(unsigned int n_buckets)
> 
>  static void flow_free(struct sw_flow *flow)
>  {
> -	int node;
> +	int node, node_cnt = 0;
> 
>  	if (ovs_identifier_is_key(&flow->id))
>  		kfree(flow->id.unmasked_key);
>  	kfree((struct sw_flow_actions __force *)flow->sf_acts);
> -	for_each_node(node)
> -		if (flow->stats[node])
> +	for_each_node(node) {
> +		if (flow->stats[node_cnt])
>  			kmem_cache_free(flow_stats_cache,
> -					(struct flow_stats __force *)flow->stats[node]);
> +					(struct flow_stats __force *)flow->stats[node_cnt]);
> +		node_cnt++;
> +	}
>  	kmem_cache_free(flow_cache, flow);
>  }
> 
> -- 
> 1.9.1
> 
