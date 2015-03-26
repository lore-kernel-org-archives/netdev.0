From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] net: fix two possible memory leaks in netif_set_xps_queue
Date: Thu, 26 Mar 2015 11:15:27 -0700
Message-ID: <55144CBF.2060102@redhat.com>
References: <1427355643-10422-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: roy.qing.li@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58137 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751552AbbCZSP2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2015 14:15:28 -0400
In-Reply-To: <1427355643-10422-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/26/2015 12:40 AM, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> new_dev_maps->cpu_map[cpu] maybe be assigned to the memory from
> expand_xps_map() in the first loop, so should be freed
>
> when free dev_maps, make sure to free new_dev_maps->cpu_map[cpu]
> firstly
>
> Fixes: 537c00de1c [net: Add functions netif_reset_xps_queue and netif_set_xps_queue]
> Cc: Alexander Duyck <alexander.h.duyck@redhat.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>   net/core/dev.c | 11 ++++++++++-
>   1 file changed, 10 insertions(+), 1 deletion(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 5d43e01..aa6459f 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2025,9 +2025,11 @@ int netif_set_xps_queue(struct net_device *dev, const struct cpumask *mask,
>   		} else if (dev_maps) {
>   			/* fill in the new device map from the old device map */
>   			map = xmap_dereference(dev_maps->cpu_map[cpu]);
> +			new_map = xmap_dereference(new_dev_maps->cpu_map[cpu]);
>   			RCU_INIT_POINTER(new_dev_maps->cpu_map[cpu], map);
> +			if (new_map && map != new_map)
> +				kfree_rcu(new_map, rcu);
>   		}
> -
>   	}
>   

This would cause memory corruption as you are freeing objects that are 
still active in dev->xps_maps, they cannot be freed until the section 
clearly called out as "Cleanup old maps" below it.  That is where this 
memory is freed using the exact same logic you seemed to copy from below.

>   	rcu_assign_pointer(dev->xps_maps, new_dev_maps);
> @@ -2068,6 +2070,13 @@ out_no_new_maps:
>   	/* free map if not active */
>   	if (!active) {
>   		RCU_INIT_POINTER(dev->xps_maps, NULL);
> +
> +		for_each_possible_cpu(cpu) {
> +			map = xmap_dereference(dev_maps->cpu_map[cpu]);
> +			if (map)
> +				kfree_rcu(map, rcu);
> +		}
> +
>   		kfree_rcu(dev_maps, rcu);
>   	}
>   

This is unnecessary.  If there are no active queue sets left then we 
already removed all of the memory in remove_xps_queue.

- Alex
