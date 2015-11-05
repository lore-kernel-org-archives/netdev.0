From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] packet: race condition in packet_bind
Date: Thu, 05 Nov 2015 14:51:08 -0500 (EST)
Message-ID: <20151105.145108.906695545091791915.davem@davemloft.net>
References: <20151105161614.9C57658016E@fruggeri-AK-3.18.sjc.aristanetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, noureddine@arista.com,
	fruggeri@arista.com
To: fruggeri@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38356 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbbKETvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 14:51:12 -0500
In-Reply-To: <20151105161614.9C57658016E@fruggeri-AK-3.18.sjc.aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fruggeri@aristanetworks.com (Francesco Ruggeri)
Date: Thu, 05 Nov 2015 08:16:14 -0800

> There is a race conditions between packet_notifier and packet_bind{_spkt}.
> 
> It happens if packet_notifier(NETDEV_UNREGISTER) executes between the
> time packet_bind{_spkt} takes a reference on the new netdevice and the
> time packet_do_bind sets po->ifindex.
> In this case the notification can be missed.
> If this happens during a dev_change_net_namespace this can result in the
> netdevice to be moved to the new namespace while the packet_sock in the
> old namespace still holds a reference on it. When the netdevice is later
> deleted in the new namespace the deletion hangs since the packet_sock
> is not found in the new namespace' &net->packet.sklist.
> It can be reproduced with the script below.
> 
> This patch makes packet_do_bind check again for the presence of the
> netdevice in the packet_sock's namespace after the synchronize_net
> in unregister_prot_hook.
> More in general it also uses the rcu lock for the duration of the bind
> to stop dev_change_net_namespace/rollback_registered_many from
> going past the synchronize_net following unlist_netdevice, so that
> no NETDEV_UNREGISTER notifications can happen on the new netdevice
> while the bind is executing. In order to do this some code from
> packet_bind{_spkt} is consolidated into packet_do_dev.
 ...
> Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>

Looks good, applied and queued up for -stable, thanks.
