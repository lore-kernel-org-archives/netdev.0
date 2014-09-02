From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 2/2] tipc: add name distributor resiliency
 queue
Date: Mon, 01 Sep 2014 17:53:02 -0700 (PDT)
Message-ID: <20140901.175302.1115807278815176938.davem@davemloft.net>
References: <1409209727-15265-1-git-send-email-erik.hugne@ericsson.com>
	<1409209727-15265-2-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
	richard.alpe@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45676 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952AbaIBAxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 20:53:03 -0400
In-Reply-To: <1409209727-15265-2-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Thu, 28 Aug 2014 09:08:47 +0200

> TIPC name table updates are distributed asynchronously in a cluster,
> entailing a risk of certain race conditions. E.g., if two nodes
> simultaneously issue conflicting (overlapping) publications, this may
> not be detected until both publications have reached a third node, in
> which case one of the publications will be silently dropped on that
> node. Hence, we end up with an inconsistent name table.
> 
> In most cases this conflict is just a temporary race, e.g., one
> node is issuing a publication under the assumption that a previous,
> conflicting, publication has already been withdrawn by the other node.
> However, because of the (rtt related) distributed update delay, this
> may not yet hold true on all nodes. The symptom of this failure is a
> syslog message: "tipc: Cannot publish {%u,%u,%u}, overlap error".
> 
> In this commit we add a resiliency queue at the receiving end of
> the name table distributor. When insertion of an arriving publication
> fails, we retain it in this queue for a short amount of time, assuming
> that another update will arrive very soon and clear the conflict. If so
> happens, we insert the publication, otherwise we drop it.
> 
> The (configurable) retention value defaults to 2000 ms. Knowing from
> experience that the situation described above is extremely rare, there
> is no risk that the queue will accumulate any large number of items.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> Acked-by: Ying Xue <ying.xue@windriver.com>

 ...

> +static void tipc_named_add_backlog(struct distr_item *i, u32 type, u32 node)
> +{
> +	struct distr_queue_item *e;
> +	unsigned long now = get_jiffies_64();
> +
> +	e = kzalloc(sizeof(*e), GFP_ATOMIC);
> +	if (!e)
> +		return;

I don't like this new (effectively silent) failure mode, but this isn't
my code so I don't care that much.  Applied.
