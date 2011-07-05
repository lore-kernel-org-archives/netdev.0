From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG] bd4265fe36 bridge: Only flood unreg groups... breaks
	DHCP setup
Date: Wed, 6 Jul 2011 07:58:33 +0800
Message-ID: <20110705235833.GA5599@gondor.apana.org.au>
References: <20110705204200@it-loops.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Michael Guntsche <mike@it-loops.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:49944 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753080Ab1GEX6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 19:58:37 -0400
Content-Disposition: inline
In-Reply-To: <20110705204200@it-loops.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Guntsche <mike@it-loops.com> wrote:
>
> Looking at the changes between rc5 and rc6 I noticed commit
> 
> bd4265fe365c0f3945d: bridge: Only flood unregistered groups to routers

Oops, that was definitely my fault.  This patch should fix your
problem.

bridge: Always flood broadcast packets

As is_multicast_ether_addr returns true on broadcast packets as
well, we need to explicitly exclude broadcast packets so that
they're always flooded.  This wasn't an issue before as broadcast
packets were considered to be an unregistered multicast group,
which were always flooded.  However, as we now only flood such
packets to router ports, this is no longer acceptable.

Reported-by: Michael Guntsche <mike@it-loops.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

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

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
