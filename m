From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] vlan: Add GRO support for non hardware
 accelerated vlan
Date: Mon, 01 Jun 2015 14:56:25 -0700 (PDT)
Message-ID: <20150601.145625.1435351866234972759.davem@davemloft.net>
References: <1433163307-9299-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<1433167957.1895.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: makita.toshiaki@lab.ntt.co.jp, kaber@trash.net,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245AbbFAV40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 17:56:26 -0400
In-Reply-To: <1433167957.1895.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 01 Jun 2015 07:12:37 -0700

> Can we ensure offload_base contains a sensible order of expected
> types ?

This seemed easy enough to kill, so I pushed the following into net-next:

====================
[PATCH] net: Add priority to packet_offload objects.

When we scan a packet for GRO processing, we want to see the most
common packet types in the front of the offload_base list.

So add a priority field so we can handle this properly.

IPv4/IPv6 get the highest priority with the implicit zero priority
field.

Next comes ethernet with a priority of 10, and then we have the MPLS
types with a priority of 15.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Suggested-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h | 1 +
 net/core/dev.c            | 8 ++++++--
 net/ethernet/eth.c        | 1 +
 net/mpls/mpls_gso.c       | 2 ++
 4 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 51f8d2f..6f5f71f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1997,6 +1997,7 @@ struct offload_callbacks {
 
 struct packet_offload {
 	__be16			 type;	/* This is really htons(ether_type). */
+	u16			 priority;
 	struct offload_callbacks callbacks;
 	struct list_head	 list;
 };
diff --git a/net/core/dev.c b/net/core/dev.c
index 594163d..0602e91 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -469,10 +469,14 @@ EXPORT_SYMBOL(dev_remove_pack);
  */
 void dev_add_offload(struct packet_offload *po)
 {
-	struct list_head *head = &offload_base;
+	struct packet_offload *elem;
 
 	spin_lock(&offload_lock);
-	list_add_rcu(&po->list, head);
+	list_for_each_entry(elem, &offload_base, list) {
+		if (po->priority < elem->priority)
+			break;
+	}
+	list_add_rcu(&po->list, elem->list.prev);
 	spin_unlock(&offload_lock);
 }
 EXPORT_SYMBOL(dev_add_offload);
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index c3325bd..7d0e239 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -470,6 +470,7 @@ EXPORT_SYMBOL(eth_gro_complete);
 
 static struct packet_offload eth_packet_offload __read_mostly = {
 	.type = cpu_to_be16(ETH_P_TEB),
+	.priority = 10,
 	.callbacks = {
 		.gro_receive = eth_gro_receive,
 		.gro_complete = eth_gro_complete,
diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
index 809df53..0183b32 100644
--- a/net/mpls/mpls_gso.c
+++ b/net/mpls/mpls_gso.c
@@ -62,6 +62,7 @@ out:
 
 static struct packet_offload mpls_mc_offload __read_mostly = {
 	.type = cpu_to_be16(ETH_P_MPLS_MC),
+	.priority = 15,
 	.callbacks = {
 		.gso_segment    =	mpls_gso_segment,
 	},
@@ -69,6 +70,7 @@ static struct packet_offload mpls_mc_offload __read_mostly = {
 
 static struct packet_offload mpls_uc_offload __read_mostly = {
 	.type = cpu_to_be16(ETH_P_MPLS_UC),
+	.priority = 15,
 	.callbacks = {
 		.gso_segment    =	mpls_gso_segment,
 	},
-- 
2.1.0
