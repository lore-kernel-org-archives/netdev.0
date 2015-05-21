From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sched: fix call_rcu() race on classifier
 module unloads
Date: Thu, 21 May 2015 18:48:57 -0400 (EDT)
Message-ID: <20150521.184857.1038956366531935453.davem@davemloft.net>
References: <9f44c4c5d2ad81e7d7ef828b9e60bd308fc7caf9.1432134471.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subramanian.vijay@gmail.com, netdev@vger.kernel.org,
	john.r.fastabend@intel.com, edumazet@google.com, tgraf@suug.ch,
	jhs@mojatatu.com, ast@plumgrid.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40705 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754067AbbEUWtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 18:49:00 -0400
In-Reply-To: <9f44c4c5d2ad81e7d7ef828b9e60bd308fc7caf9.1432134471.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 20 May 2015 17:13:33 +0200

> Vijay reported that a loop as simple as ...
 ...
> ... will panic the kernel. Moreover, he bisected the change
> apparently introducing it to 78fd1d0ab072 ("netlink: Re-add
> locking to netlink_lookup() and seq walker").
> 
> The removal of synchronize_net() from the netlink socket
> triggering the qdisc to be removed, seems to have uncovered
> an RCU resp. module reference count race from the tc API.
> Given that RCU conversion was done after e341694e3eb5 ("netlink:
> Convert netlink_lookup() to use RCU protected hash table")
> which added the synchronize_net() originally, occasion of
> hitting the bug was less likely (not impossible though):
> 
> When qdiscs that i) support attaching classifiers and,
> ii) have at least one of them attached, get deleted, they
> invoke tcf_destroy_chain(), and thus call into ->destroy()
> handler from a classifier module.
> 
> After RCU conversion, all classifier that have an internal
> prio list, unlink them and initiate freeing via call_rcu()
> deferral.
> 
> Meanhile, tcf_destroy() releases already reference to the
> tp->ops->owner module before the queued RCU callback handler
> has been invoked.
> 
> Subsequent rmmod on the classifier module is then not prevented
> since all module references are already dropped.
> 
> By the time, the kernel invokes the RCU callback handler from
> the module, that function address is then invalid.
> 
> One way to fix it would be to add an rcu_barrier() to
> unregister_tcf_proto_ops() to wait for all pending call_rcu()s
> to complete.
> 
> synchronize_rcu() is not appropriate as under heavy RCU
> callback load, registered call_rcu()s could be deferred
> longer than a grace period. In case we don't have any pending
> call_rcu()s, the barrier is allowed to return immediately.
> 
> Since we came here via unregister_tcf_proto_ops(), there
> are no users of a given classifier anymore. Further nested
> call_rcu()s pointing into the module space are not being
> done anywhere.
> 
> Only cls_bpf_delete_prog() may schedule a work item, to
> unlock pages eventually, but that is not in the range/context
> of cls_bpf anymore.
> 
> Fixes: 25d8c0d55f24 ("net: rcu-ify tcf_proto")
> Fixes: 9888faefe132 ("net: sched: cls_basic use RCU")
> Reported-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks a lot Daniel.
