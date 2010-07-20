From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Tue, 20 Jul 2010 13:26:45 +0800
Message-ID: <20100720052645.GA5214@gondor.apana.org.au>
References: <20100719101904.GA31743@redhat.com> <20100719105300.GA22179@gondor.apana.org.au> <20100719115411.GA22758@gondor.apana.org.au> <20100719.090503.73693858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mst@redhat.com, shemminger@vyatta.com, frzhang@redhat.com,
	netdev@vger.kernel.org, amwang@redhat.com, mpm@selenic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:48143 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab0GTF0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 01:26:54 -0400
Content-Disposition: inline
In-Reply-To: <20100719.090503.73693858.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 19, 2010 at 09:05:03AM -0700, David Miller wrote:
>
> I thought we did that already.... oh I see, we did it for bonding:
> 
> commit c22d7ac844f1cb9c6a5fd20f89ebadc2feef891b
> Author: Andy Gospodarek <andy@greyhouse.net>
> Date:   Fri Jun 25 09:50:44 2010 +0000
> 
>     bonding: prevent netpoll over bonded interfaces
> 
> I'm fine with disabling it for bridging too, just send me a patch
> similar to the bonding one.

OK, here is a minimal patch to remove the offending bits of the
bridge netpoll support.

Note that this patch needs to be reverted in net-next-2.6 as
bridge netpoll works correctly there.

bridge: Partially disable netpoll support

The new netpoll code in bridging contains use-after-free bugs
that are non-trivial to fix.

This patch fixes this by removing the code that uses skbs after
they're freed.

As a consequence, this means that we can no longer call bridge
from the netpoll path, so this patch also removes the controller
function in order to disable netpoll.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index eedf2c9..753fc42 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -217,14 +217,6 @@ static bool br_devices_support_netpoll(struct net_bridge *br)
 	return count != 0 && ret;
 }
 
-static void br_poll_controller(struct net_device *br_dev)
-{
-	struct netpoll *np = br_dev->npinfo->netpoll;
-
-	if (np->real_dev != br_dev)
-		netpoll_poll_dev(np->real_dev);
-}
-
 void br_netpoll_cleanup(struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
@@ -295,7 +287,6 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_do_ioctl		 = br_dev_ioctl,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_netpoll_cleanup	 = br_netpoll_cleanup,
-	.ndo_poll_controller	 = br_poll_controller,
 #endif
 };
 
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index a4e72a8..595da45 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -50,14 +50,7 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
 			kfree_skb(skb);
 		else {
 			skb_push(skb, ETH_HLEN);
-
-#ifdef CONFIG_NET_POLL_CONTROLLER
-			if (unlikely(skb->dev->priv_flags & IFF_IN_NETPOLL)) {
-				netpoll_send_skb(skb->dev->npinfo->netpoll, skb);
-				skb->dev->priv_flags &= ~IFF_IN_NETPOLL;
-			} else
-#endif
-				dev_queue_xmit(skb);
+			dev_queue_xmit(skb);
 		}
 	}
 
@@ -73,23 +66,9 @@ int br_forward_finish(struct sk_buff *skb)
 
 static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 {
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	struct net_bridge *br = to->br;
-	if (unlikely(br->dev->priv_flags & IFF_IN_NETPOLL)) {
-		struct netpoll *np;
-		to->dev->npinfo = skb->dev->npinfo;
-		np = skb->dev->npinfo->netpoll;
-		np->real_dev = np->dev = to->dev;
-		to->dev->priv_flags |= IFF_IN_NETPOLL;
-	}
-#endif
 	skb->dev = to->dev;
 	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
 		br_forward_finish);
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	if (skb->dev->npinfo)
-		skb->dev->npinfo->netpoll->dev = br->dev;
-#endif
 }
 
 static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
