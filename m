From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: macvtap: Limit packet queue length
Date: Thu, 22 Jul 2010 15:44:31 +0800
Message-ID: <20100722074431.GA26744@gondor.apana.org.au>
References: <20100722064157.GA25913@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Wagner <mwagner@redhat.com>,
	Chris Wright <chrisw@sous-sol.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:42282 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915Ab0GVHoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 03:44:37 -0400
Content-Disposition: inline
In-Reply-To: <20100722064157.GA25913@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 22, 2010 at 02:41:57PM +0800, Herbert Xu wrote:
> Hi:
> 
> macvtap: Limit packet queue length

Chris has informed me that he's already tried a similar patch
and it only makes the problem worse :)

The issue is that the macvtap TX queue length defaults to zero.

So here is an updated patch which addresses this:

macvtap: Limit packet queue length

Mark Wagner reported OOM symptoms when sending UDP traffic over
a macvtap link to a kvm receiver.

This appears to be caused by the fact that macvtap packet queues
are unlimited in length.  This means that if the receiver can't
keep up with the rate of flow, then we will hit OOM. Of course
it gets worse if the OOM killer then decides to kill the receiver.

This patch imposes a cap on the packet queue length, in the same
way as the tuntap driver, using the device TX queue length.

Please note that macvtap currently has no way of giving congestion
notification, that means the software device TX queue cannot be
used and packets will always be dropped once the macvtap driver
queue fills up.

This shouldn't be a great problem for the scenario where macvtap
is used to feed a kvm receiver, as the traffic is most likely
external in origin so congestion notification can't be applied
anyway.

Of course, if anybody decides to complain about guest-to-guest
UDP packet loss down the track, then we may have to revisit this.

Incidentally, this patch also fixes a real memory leak when
macvtap_get_queue fails.

Chris Wright noticed that for this patch to work, we need a
non-zero TX queue length.  This patch includes his work to change
the default macvtap TX queue length to 500.

Reported-by: Mark Wagner <mwagner@redhat.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 87e8d4c..f15fe2c 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -499,7 +499,7 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-static void macvlan_setup(struct net_device *dev)
+void macvlan_common_setup(struct net_device *dev)
 {
 	ether_setup(dev);
 
@@ -508,6 +508,12 @@ static void macvlan_setup(struct net_device *dev)
 	dev->destructor		= free_netdev;
 	dev->header_ops		= &macvlan_hard_header_ops,
 	dev->ethtool_ops	= &macvlan_ethtool_ops;
+}
+EXPORT_SYMBOL_GPL(macvlan_common_setup);
+
+static void macvlan_setup(struct net_device *dev)
+{
+	macvlan_common_setup(dev);
 	dev->tx_queue_len	= 0;
 }
 
@@ -705,7 +711,6 @@ int macvlan_link_register(struct rtnl_link_ops *ops)
 	/* common fields */
 	ops->priv_size		= sizeof(struct macvlan_dev);
 	ops->get_tx_queues	= macvlan_get_tx_queues;
-	ops->setup		= macvlan_setup;
 	ops->validate		= macvlan_validate;
 	ops->maxtype		= IFLA_MACVLAN_MAX;
 	ops->policy		= macvlan_policy;
@@ -719,6 +724,7 @@ EXPORT_SYMBOL_GPL(macvlan_link_register);
 
 static struct rtnl_link_ops macvlan_link_ops = {
 	.kind		= "macvlan",
+	.setup		= macvlan_setup,
 	.newlink	= macvlan_newlink,
 	.dellink	= macvlan_dellink,
 };
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index a8a94e2..ff02b83 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -180,11 +180,18 @@ static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
 {
 	struct macvtap_queue *q = macvtap_get_queue(dev, skb);
 	if (!q)
-		return -ENOLINK;
+		goto drop;
+
+	if (skb_queue_len(&q->sk.sk_receive_queue) >= dev->tx_queue_len)
+		goto drop;
 
 	skb_queue_tail(&q->sk.sk_receive_queue, skb);
 	wake_up_interruptible_poll(sk_sleep(&q->sk), POLLIN | POLLRDNORM | POLLRDBAND);
-	return 0;
+	return NET_RX_SUCCESS;
+
+drop:
+	kfree_skb(skb);
+	return NET_RX_DROP;
 }
 
 /*
@@ -235,8 +242,15 @@ static void macvtap_dellink(struct net_device *dev,
 	macvlan_dellink(dev, head);
 }
 
+static void macvtap_setup(struct net_device *dev)
+{
+	macvlan_common_setup(dev);
+	dev->tx_queue_len = TUN_READQ_SIZE;
+}
+
 static struct rtnl_link_ops macvtap_link_ops __read_mostly = {
 	.kind		= "macvtap",
+	.setup		= macvtap_setup,
 	.newlink	= macvtap_newlink,
 	.dellink	= macvtap_dellink,
 };
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index 9ea047a..1ffaeff 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -67,6 +67,8 @@ static inline void macvlan_count_rx(const struct macvlan_dev *vlan,
 	}
 }
 
+extern void macvlan_common_setup(struct net_device *dev);
+
 extern int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 				  struct nlattr *tb[], struct nlattr *data[],
 				  int (*receive)(struct sk_buff *skb),

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
