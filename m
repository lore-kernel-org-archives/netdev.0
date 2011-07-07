From: David Miller <davem@davemloft.net>
Subject: Re: [heads-up] bridge in kernel 3.0~ and dhcp from kvm guest on
 tap device
Date: Thu, 07 Jul 2011 02:49:06 -0700 (PDT)
Message-ID: <20110707.024906.763895385840201032.davem@davemloft.net>
References: <4E158019.9040604@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org
To: mjt@tls.msk.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753363Ab1GGJtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 05:49:22 -0400
In-Reply-To: <4E158019.9040604@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Tokarev <mjt@tls.msk.ru>
Date: Thu, 07 Jul 2011 13:44:57 +0400

> The combination in $subject apparently stopped working --
> I'm running 3.0-rc6 kernel on host where it doesn't work.

Already fixed in net-2.6:

>From 44661462ee1ee3c922754fc1f246867f0d01e7ea Mon Sep 17 00:00:00 2001
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 5 Jul 2011 13:58:33 +0000
Subject: [PATCH 24/30] bridge: Always flood broadcast packets

As is_multicast_ether_addr returns true on broadcast packets as
well, we need to explicitly exclude broadcast packets so that
they're always flooded.  This wasn't an issue before as broadcast
packets were considered to be an unregistered multicast group,
which were always flooded.  However, as we now only flood such
packets to router ports, this is no longer acceptable.

Reported-by: Michael Guntsche <mike@it-loops.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/bridge/br_device.c |    4 +++-
 net/bridge/br_input.c  |    6 ++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index c188c80..32b8f9f 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -49,7 +49,9 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_pull(skb, ETH_HLEN);
 
 	rcu_read_lock();
-	if (is_multicast_ether_addr(dest)) {
+	if (is_broadcast_ether_addr(dest))
+		br_flood_deliver(br, skb);
+	else if (is_multicast_ether_addr(dest)) {
 		if (unlikely(netpoll_tx_running(dev))) {
 			br_flood_deliver(br, skb);
 			goto out;
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f3ac1e8..f06ee39 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -60,7 +60,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	br = p->br;
 	br_fdb_update(br, p, eth_hdr(skb)->h_source);
 
-	if (is_multicast_ether_addr(dest) &&
+	if (!is_broadcast_ether_addr(dest) && is_multicast_ether_addr(dest) &&
 	    br_multicast_rcv(br, p, skb))
 		goto drop;
 
@@ -77,7 +77,9 @@ int br_handle_frame_finish(struct sk_buff *skb)
 
 	dst = NULL;
 
-	if (is_multicast_ether_addr(dest)) {
+	if (is_broadcast_ether_addr(dest))
+		skb2 = skb;
+	else if (is_multicast_ether_addr(dest)) {
 		mdst = br_mdb_get(br, skb);
 		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) {
 			if ((mdst && mdst->mglist) ||
-- 
1.7.6

