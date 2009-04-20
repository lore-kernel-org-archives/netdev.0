From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Software receive packet steering
Date: Mon, 20 Apr 2009 12:32:29 +0200
Message-ID: <87eivnpqde.fsf@basil.nowhere.org>
References: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:51659 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753504AbZDTKce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 06:32:34 -0400
In-Reply-To: <65634d660904081548g7ea3e3bfn858f2336db9a671f@mail.gmail.com> (Tom Herbert's message of "Wed, 8 Apr 2009 15:48:12 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <therbert@google.com> writes:

> +static int netif_cpu_for_rps(struct net_device *dev, struct sk_buff *skb)
> +{
> +	cpumask_t mask;
> +	unsigned int hash;
> +	int cpu, count = 0;
> +
> +	cpus_and(mask, dev->soft_rps_cpus, cpu_online_map);
> +	if (cpus_empty(mask))
> +		return smp_processor_id();

There's a race here with CPU hotunplug I think. When a CPU is hotunplugged
in parallel you can still push packets to it even though they are not
drained. You probably need some kind of drain callback in a CPU hotunplug
notifier that eats all packets left over.

> +got_hash:
> +	hash %= cpus_weight_nr(mask);

That looks rather heavyweight even on modern CPUs. I bet it's 40-50+ cycles
alone forth the hweight and the division. Surely that can be done better?

Also I suspect some kind of runtime switch for this would be useful.

Also the manual set up of the receive mask seems really clumpsy. Couldn't
you set that up dynamically based on where processes executing recvmsg()
are running?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
