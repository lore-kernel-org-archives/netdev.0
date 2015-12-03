From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net_sched: fix qdisc_tree_decrease_qlen() races
Date: Thu, 03 Dec 2015 14:59:40 -0500 (EST)
Message-ID: <20151203.145940.1297777652481637863.davem@davemloft.net>
References: <CAHA+R7M++LboS_2OmhNjoApvFf6Xk-e+vsEgZrFeKG+k1J8edw@mail.gmail.com>
	<1449011431.32764.7.camel@edumazet-glaptop2.roam.corp.google.com>
	<1449029331.32764.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, pageexec@freemail.hu, dfucini@gmail.com,
	netdev@vger.kernel.org, jhs@mojatatu.com, spender@grsecurity.net,
	re.emese@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753264AbbLCT7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 14:59:42 -0500
In-Reply-To: <1449029331.32764.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 01 Dec 2015 20:08:51 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> qdisc_tree_decrease_qlen() suffers from two problems on multiqueue
> devices.
> 
> One problem is that it updates sch->q.qlen and sch->qstats.drops
> on the mq/mqprio root qdisc, while it should not : Daniele
> reported underflows errors : 
 ...
> mq/mqprio have their own ways to report qlen/drops by folding stats on
> all their queues, with appropriate locking.
> 
> A second problem is that qdisc_tree_decrease_qlen() calls qdisc_lookup()
> without proper locking : concurrent qdisc updates could corrupt the list
> that qdisc_match_from_root() parses to find a qdisc given its handle.
> 
> Fix first problem adding a TCQ_F_NOPARENT qdisc flag that
> qdisc_tree_decrease_qlen() can use to abort its tree traversal,
> as soon as it meets a mq/mqprio qdisc children.
> 
> Second problem can be fixed by RCU protection.
> Qdisc are already freed after RCU grace period, so qdisc_list_add() and
> qdisc_list_del() simply have to use appropriate rcu list variants.
> 
> A future patch will add a per struct netdev_queue list anchor, so that
> qdisc_tree_decrease_qlen() can have more efficient lookups.
> 
> Reported-by: Daniele Fucini <dfucini@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric!
