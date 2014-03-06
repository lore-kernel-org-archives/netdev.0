From: Amir Vadai <amirv@mellanox.com>
Subject: Re: net: Utility function to get affinity_hint by policy
Date: Fri, 7 Mar 2014 00:24:43 +0200
Message-ID: <20140306222441.GA17512@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <1394126332-11110-1-git-send-email-amirv@mellanox.com>
 <1394126332-11110-2-git-send-email-amirv@mellanox.com>
 <20140306.153835.2248996436618700806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, prarit@redhat.com, gvaradar@cisco.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:58032 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbaCFWYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 17:24:47 -0500
Received: by mail-we0-f172.google.com with SMTP id t61so3987332wes.3
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 14:24:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140306.153835.2248996436618700806.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/14 15:38 -0500, David Miller wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Thu,  6 Mar 2014 19:18:51 +0200
> 
> > +	rxq %= num_online_cpus();
> > +
> > +	p_numa_cores_mask = cpumask_of_node(numa_node);
> > +	if (!p_numa_cores_mask)
> > +		p_numa_cores_mask = cpu_online_mask;
> > +
> > +	for_each_cpu(affinity_cpu, p_numa_cores_mask) {
> > +		if (--rxq < 0)
> > +			goto out;
> > +	}
> > +
> > +	if (!zalloc_cpumask_var(&non_numa_cores_mask, GFP_KERNEL)) {
> > +		ret = -ENOMEM;
> > +		goto err;
> > +	}
> > +
> > +	cpumask_xor(non_numa_cores_mask, cpu_online_mask, p_numa_cores_mask);
> > +
> > +	for_each_cpu(affinity_cpu, non_numa_cores_mask) {
> > +		if (--rxq < 0)
> > +			goto out;
> > +	}
> > +
> > +	ret = -EINVAL;
> > +	goto err;
> 
> The NUMA core mask and the non-NUMA core mask must together provide
> at least num_online_cpus() bits.
> 
> Said another way, since rxq is limited to num_online_cpus() it should
> never exceed local + non-local cores.
> 
> Therefore this -EINVAL path seems like it should not be possible, and
> therefore perhaps a WARN_ON() or similar would be appropriate.

All these could be changed dynamically, and since there is no
protection on this block of code, it is possible that local + non-local
at point of time t1 will exceed num_online_cpus() at t2.
Since this is very rare and the fix for that is very complicated, I
decided not set affinity hint in this scenario, and only return an
error code.

Amir
