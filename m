From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: fix crash during node removal
Date: Thu, 25 Feb 2016 17:06:40 -0500 (EST)
Message-ID: <20160225.170640.215834405851268589.davem@davemloft.net>
References: <1456330248-12510-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46717 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbcBYWGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 17:06:42 -0500
In-Reply-To: <1456330248-12510-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 24 Feb 2016 11:10:48 -0500

> When the TIPC module is unloaded, we have identified a race condition
> that allows a node reference counter to go to zero and the node instance
> being freed before the node timer is finished with accessing it. This
> leads to occasional crashes, especially in multi-namespace environments.
> 
> The scenario goes as follows:
> 
> CPU0:(node_stop)                       CPU1:(node_timeout)  // ref == 2
> 
> 1:                                          if(!mod_timer())
> 2: if (del_timer())
> 3:   tipc_node_put()                                        // ref -> 1
> 4: tipc_node_put()                                          // ref -> 0
> 5:   kfree_rcu(node);
> 6:                                               tipc_node_get(node)
> 7:                                               // BOOM!
> 
> We now clean up this functionality as follows:
> 
> 1) We remove the node pointer from the node lookup table before we
>    attempt deactivating the timer. This way, we reduce the risk that
>    tipc_node_find() may obtain a valid pointer to an instance marked
>    for deletion; a harmless but undesirable situation.
> 
> 2) We use del_timer_sync() instead of del_timer() to safely deactivate
>    the node timer without any risk that it might be reactivated by the
>    timeout handler. There is no risk of deadlock here, since the two
>    functions never touch the same spinlocks.
> 
> 3: We remove a pointless tipc_node_get() + tipc_node_put() from the
>    timeout handler.
> 
> Reported-by: Zhijiang Hu <huzhijiang@gmail.com>
> Acked-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
