From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] net: sched: fix call_rcu() race on classifier module unloads
Date: Wed, 20 May 2015 10:38:42 -0700
Message-ID: <CAHA+R7PMC7Zi0gqAUFzfWfJ_CLTmNYqjSgAQH2kKVONEy_3gZQ@mail.gmail.com>
References: <9f44c4c5d2ad81e7d7ef828b9e60bd308fc7caf9.1432134471.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, subramanian.vijay@gmail.com,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:34430 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431AbbETRio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 13:38:44 -0400
Received: by wghq2 with SMTP id q2so60541007wgh.1
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 10:38:42 -0700 (PDT)
In-Reply-To: <9f44c4c5d2ad81e7d7ef828b9e60bd308fc7caf9.1432134471.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2015 at 8:13 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Vijay reported that a loop as simple as ...
>
>   while true; do
>     tc qdisc add dev foo root handle 1: prio
>     tc filter add dev foo parent 1: u32 match u32 0 0  flowid 1
>     tc qdisc del dev foo root
>     rmmod cls_u32
>   done
>
> ... will panic the kernel. Moreover, he bisected the change
> apparently introducing it to 78fd1d0ab072 ("netlink: Re-add
> locking to netlink_lookup() and seq walker").


Please include the stack trace whenever possible, it helps
a lots even just for reviewing the patch.

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


Why synchronize_rcu() even matters here? It waits for
readers, not for RCU callbacks.

>
> Since we came here via unregister_tcf_proto_ops(), there
> are no users of a given classifier anymore. Further nested
> call_rcu()s pointing into the module space are not being
> done anywhere.


This doesn't look like the best way to fix it, since calling
call_rcu() is tc filter specific, so why not just move the
rcu_barrier() to each of the ->destroy() implementation?
Let each filter handle its own implementation bug.
