From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xps: fix xps for stacked devices
Date: Wed, 04 Feb 2015 13:03:08 -0800 (PST)
Message-ID: <20150204.130308.1433096157491856856.davem@davemloft.net>
References: <1423036104.907.99.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, nanditad@google.com,
	ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38594 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965378AbbBDVDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 16:03:12 -0500
In-Reply-To: <1423036104.907.99.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 Feb 2015 23:48:24 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> A typical qdisc setup is the following :
> 
> bond0 : bonding device, using HTB hierarchy
> eth1/eth2 : slaves, multiqueue NIC, using MQ + FQ qdisc
> 
> XPS allows to spread packets on specific tx queues, based on the cpu
> doing the send.
> 
> Problem is that dequeues from bond0 qdisc can happen on random cpus,
> due to the fact that qdisc_run() can dequeue a batch of packets.
> 
> CPUA -> queue packet P1 on bond0 qdisc, P1->ooo_okay=1
> CPUA -> queue packet P2 on bond0 qdisc, P2->ooo_okay=0
> 
> CPUB -> dequeue packet P1 from bond0
>         enqueue packet on eth1/eth2
> CPUC -> dequeue packet P2 from bond0
>         enqueue packet on eth1/eth2 using sk cache (ooo_okay is 0)
> 
> get_xps_queue() then might select wrong queue for P1, since current cpu
> might be different than CPUA.
> 
> P2 might be sent on the old queue (stored in sk->sk_tx_queue_mapping),
> if CPUC runs a bit faster (or CPUB spins a bit on qdisc lock)
> 
> Effect of this bug is TCP reorders, and more generally not optimal
> TX queue placement. (A victim bulk flow can be migrated to the wrong TX
> queue for a while)
> 
> To fix this, we have to record sender cpu number the first time
> dev_queue_xmit() is called for one tx skb.
> 
> We can union napi_id (used on receive path) and sender_cpu,
> granted we clear sender_cpu in skb_scrub_packet() (credit to Willem for
> this union idea)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks everyone.
