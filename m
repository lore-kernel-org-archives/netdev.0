From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 1/2] net: Utility function to get
 affinity_hint by policy
Date: Thu, 06 Mar 2014 15:38:35 -0500 (EST)
Message-ID: <20140306.153835.2248996436618700806.davem@davemloft.net>
References: <1394126332-11110-1-git-send-email-amirv@mellanox.com>
	<1394126332-11110-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, prarit@redhat.com, gvaradar@cisco.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32985 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbaCFUih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 15:38:37 -0500
In-Reply-To: <1394126332-11110-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu,  6 Mar 2014 19:18:51 +0200

> +	rxq %= num_online_cpus();
> +
> +	p_numa_cores_mask = cpumask_of_node(numa_node);
> +	if (!p_numa_cores_mask)
> +		p_numa_cores_mask = cpu_online_mask;
> +
> +	for_each_cpu(affinity_cpu, p_numa_cores_mask) {
> +		if (--rxq < 0)
> +			goto out;
> +	}
> +
> +	if (!zalloc_cpumask_var(&non_numa_cores_mask, GFP_KERNEL)) {
> +		ret = -ENOMEM;
> +		goto err;
> +	}
> +
> +	cpumask_xor(non_numa_cores_mask, cpu_online_mask, p_numa_cores_mask);
> +
> +	for_each_cpu(affinity_cpu, non_numa_cores_mask) {
> +		if (--rxq < 0)
> +			goto out;
> +	}
> +
> +	ret = -EINVAL;
> +	goto err;

The NUMA core mask and the non-NUMA core mask must together provide
at least num_online_cpus() bits.

Said another way, since rxq is limited to num_online_cpus() it should
never exceed local + non-local cores.

Therefore this -EINVAL path seems like it should not be possible, and
therefore perhaps a WARN_ON() or similar would be appropriate.
