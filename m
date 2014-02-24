From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 2/2] ixgbe, don't assume mapping of numa node cpus
Date: Mon, 24 Feb 2014 11:39:50 -0800
Message-ID: <530BA006.5030003@intel.com>
References: <1393267913-28212-1-git-send-email-prarit@redhat.com> <1393267913-28212-3-git-send-email-prarit@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"David S. Miller" <davem@davemloft.net>, nhorman@redhat.com,
	agospoda@redhat.com, e1000-devel@lists.sourceforge.net
To: Prarit Bhargava <prarit@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27084 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752850AbaBXTj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 14:39:58 -0500
In-Reply-To: <1393267913-28212-3-git-send-email-prarit@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2014 10:51 AM, Prarit Bhargava wrote:
> The ixgbe driver assumes that the cpus on a node are mapped 1:1 with the
> indexes into arrays.  This is not the case as nodes can contain, for
> example, cpus 0-7, 33-40.
> 
> This patch fixes this problem.
> 
> Signed-off-by: Prarit Bhargava <prarit@redhat.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Cc: Don Skidmore <donald.c.skidmore@intel.com>
> Cc: Greg Rose <gregory.v.rose@intel.com>
> Cc: Alex Duyck <alexander.h.duyck@intel.com>
> Cc: John Ronciak <john.ronciak@intel.com>
> Cc: Mitch Williams <mitch.a.williams@intel.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: nhorman@redhat.com
> Cc: agospoda@redhat.com
> Cc: e1000-devel@lists.sourceforge.net
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c |   16 +++++++++-------
>  1 file changed, 9 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
> index 3668288..8b3992e 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
> @@ -794,11 +794,15 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
>  {
>  	struct ixgbe_q_vector *q_vector;
>  	struct ixgbe_ring *ring;
> -	int node = NUMA_NO_NODE;
> -	int cpu = -1;
> +	int node = adapter->pdev->dev.numa_node;
> +	int cpu, set_affinity = 0;
>  	int ring_count, size;
>  	u8 tcs = netdev_get_num_tc(adapter->netdev);
>  
> +	if (node == NUMA_NO_NODE)
> +		cpu = -1;
> +	else
> +		cpu = cpumask_next(v_idx - 1, cpumask_of_node(node));
>  	ring_count = txr_count + rxr_count;
>  	size = sizeof(struct ixgbe_q_vector) +
>  	       (sizeof(struct ixgbe_ring) * ring_count);

Are you sure this does what you think it does?  I thought the first
value is just the starting offset to check for a bit?  I don't think
cpumask_next is aware of holes in a given mask.  So for example if 8-31
are missing I think you will end up with all of your CPUs being
allocated to CPU 32 since it is the first set bit greater than 15.

What might work better here is a function that returns the local node
CPU IDs first, followed by the remote node IDs if ATR is enabled.  We
should probably have it configured to loop in the case that the number
of queues is greater than local nodes, but ATR is not enabled.

> @@ -807,10 +811,8 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
>  	if ((tcs <= 1) && !(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)) {
>  		u16 rss_i = adapter->ring_feature[RING_F_RSS].indices;
>  		if (rss_i > 1 && adapter->atr_sample_rate) {
> -			if (cpu_online(v_idx)) {
> -				cpu = v_idx;
> -				node = cpu_to_node(cpu);
> -			}
> +			if (likely(cpu_online(cpu)))
> +				set_affinity = 1;
>  		}
>  	}
>  

The node assignment is still needed here.  We need to be able to assign
queues to remote nodes as applications will be there expecting data.  We
have seen a serious performance degradation when trying to feed an
application from a remote queue even if the queue is local to hardware.

> @@ -822,7 +824,7 @@ static int ixgbe_alloc_q_vector(struct ixgbe_adapter *adapter,
>  		return -ENOMEM;
>  
>  	/* setup affinity mask and node */
> -	if (cpu != -1)
> +	if (set_affinity)
>  		cpumask_set_cpu(cpu, &q_vector->affinity_mask);
>  	q_vector->numa_node = node;
>  
> 

I'm not sure what the point of this change is other than the fact that
you changed the cpu configuration to be earlier.  The affinity mask
could be configured with an offline CPU and it should have no negative
affect.

Thanks,

Alex
