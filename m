From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: fq: do not hold qdisc lock while allocating
 memory
Date: Fri, 07 Mar 2014 17:04:50 -0500 (EST)
Message-ID: <20140307.170450.1316250102185751283.davem@davemloft.net>
References: <1394175472.20149.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43867 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbaCGWEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 17:04:52 -0500
In-Reply-To: <1394175472.20149.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Mar 2014 22:57:52 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Resizing fq hash table allocates memory while holding qdisc spinlock,
> with BH disabled.
> 
> This is definitely not good, as allocation might sleep.
> 
> We can drop the lock and get it when needed, we hold RTNL so no other
> changes can happen at the same time.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: afe4fd062416 ("pkt_sched: fq: Fair Queue packet scheduler")

Eric I think you can simplify things a little further, and in fact I
think it makes these functions easier to understand.

The fq_resize() part should just grab the lock around the rehash and
the update of q->fq_root and q->fq_trees_log.

fq_change() should only grab the lock around the fq_dequeue() loop
and the call to qdisc_tree_descrease_qlen().  The rest of this
function is just validating netlink attributes and looking at state
that cannot change while we hold RTNL.
