From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: take rtnl_lock and mark mrt6 table as freed on namespace cleanup
Date: Tue, 23 Jul 2013 15:39:47 +0200
Message-ID: <20130723133947.GB32523@order.stressinduktion.org>
References: <20130722214553.GF6538@order.stressinduktion.org> <51EE3E9E.9030406@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, srivatsa.bhat@linux.vnet.ibm.com
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:34284 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757279Ab3GWNjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 09:39:48 -0400
Content-Disposition: inline
In-Reply-To: <51EE3E9E.9030406@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 23, 2013 at 04:28:14PM +0800, Fan Du wrote:
> This call trace actually comes a long way down from put_net, indicating net
> reference count is ZERO, then clean all things up. Since Srivatsa didn't
> enable CONFIG_IPV6_MROUTE_MULTIPLE_TABLES, so mrt could only be 
> net->ipv6.mrt6,
> which is allocated in ip6mr_rules_init. The only place to free mrt6 is
> ip6mr_rules_exit in this configuration.
> 
> Question is how could mrt6 be freed in ip6mr_rules_exit, and then put_net 
> has
> decreased net->count to zero and then free all things up, all of this 
> happened
> in boot up process? Even if mrt6 has been freed, subsequent access on that 
> area
> didn't necessarily cause page fault, PTE 8000002018552060 shows the mapping 
> is
> not present at all. I think SLAB did tired down page entry for kfreed area 
> once
> pte has been setup already.
> 
> The scenario is weird for me, or my ignorance reach a new limit :)

The important thing is: net->ipv6.mrt6 = NULL;

After we freed the mrt6 table we leave the pointer value intact. So when the
namespace cleanup calls the next callback and the icmpv6 socket closes, we try
to check mrt->mroute6_sk again.

See how ip6mr_for_each_table expands if you compile without
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES:

#define ip6mr_for_each_table(mrt, net) \
        for (mrt = net->ipv6.mrt6; mrt; mrt = NULL)

It is merely a NULL check.

Does it make sense now? I added the rtnl_lock for ip6mr_free_table ==>
mroute_clean_tables ==> mif6_delete and the lock has nothing to do with this
"race", as the netspace cleanup is serialized in the workqueue.

Greetings,

  Hannes
