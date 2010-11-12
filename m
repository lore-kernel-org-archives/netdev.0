From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] nete zero kobject in rx_queue_release
Date: Fri, 12 Nov 2010 13:08:24 -0800 (PST)
Message-ID: <20101112.130824.68146775.davem@davemloft.net>
References: <20101111201341.4418.16400.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, therbert@google.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38730
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754728Ab0KLVH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 16:07:59 -0500
In-Reply-To: <20101111201341.4418.16400.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Thu, 11 Nov 2010 12:13:41 -0800

> netif_set_real_num_rx_queues() can decrement and increment
> the number of rx queues. For example ixgbe does this as
> features and offloads are toggled. Presumably this could
> also happen across down/up on most devices if the available
> resources changed (cpu offlined).
> 
> The kobject needs to be zero'd in this case so that the
> state is not preserved across kobject_put()/kobject_init_and_add().
> 
> This resolves the following error report.
 ...
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

I think it's probably better to clear the entire netdev_rx_queue
object rather than just the embedded kobject.

Otherwise we leave dangling rps_map, rps_flow_table, etc. pointers.

In fact, it's more tricky than this, because notice that your
patch will memset() free'd memory in the case where the
first->count drops to zero and we execute the kfree().

So we'll need something like:

	if (atomic_dec_and_test(&first->count))
		kfree(first);
	else
		/* clear everything except queue->first */

or, alternatively:

--------------------
	map = rcu_dereference_raw(queue->rps_map);
	if (map) {
		call_rcu(&map->rcu, rps_map_release);
		rcu_assign_pointer(queue->rps_map, NULL);
	}

	flow_table = rcu_dereference_raw(queue->rps_flow_table);
	if (flow_table) {
		call_rcu(&flow_table->rcu, rps_dev_flow_table_release);
		rcu_assign_pointer(queue->rps_flow_table, NULL);
	}
	if (atomic_dec_and_test(&first->count))
		kfree(first);
	else
		memset(kobj);
--------------------

Something like that.
