From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/2] [NET]: Add NETIF_F_GEN_CSUM and NETIF_F_ALL_CSUM
Date: Tue, 13 Jun 2006 21:25:11 +1000
Message-ID: <20060613112511.GA13204@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AhhlLboLdkugWU4S"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:27143 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750990AbWFMLZl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 07:25:41 -0400
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

These patches are based on your net-2.6.18 tree.  They add support for
NETIF_F_HW_CSUM on bridges.

[NET]: Add NETIF_F_GEN_CSUM and NETIF_F_ALL_CSUM

The current stack treats NETIF_F_HW_CSUM and NETIF_F_NO_CSUM identically
so we test for them in quite a few places.  For the sake of brevity, I'm
adding the macro NETIF_F_GEN_CSUM for these two.  We also test the disjunct
of NETIF_F_IP_CSUM and the other two in various places, for that purpose
I've added NETIF_F_ALL_CSUM.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p1.patch"

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1199,8 +1199,7 @@ int bond_sethwaddr(struct net_device *bo
 }
 
 #define BOND_INTERSECT_FEATURES \
-	(NETIF_F_SG|NETIF_F_IP_CSUM|NETIF_F_NO_CSUM|NETIF_F_HW_CSUM|\
-	NETIF_F_TSO|NETIF_F_UFO)
+	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_TSO | NETIF_F_UFO)
 
 /* 
  * Compute the common dev->feature set available to all slaves.  Some
@@ -1218,9 +1217,7 @@ static int bond_compute_features(struct 
 		features &= (slave->dev->features & BOND_INTERSECT_FEATURES);
 
 	if ((features & NETIF_F_SG) && 
-	    !(features & (NETIF_F_IP_CSUM |
-			  NETIF_F_NO_CSUM |
-			  NETIF_F_HW_CSUM)))
+	    !(features & NETIF_F_ALL_CSUM))
 		features &= ~NETIF_F_SG;
 
 	/* 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -312,6 +312,9 @@ struct net_device
 #define NETIF_F_LLTX		4096	/* LockLess TX */
 #define NETIF_F_UFO             8192    /* Can offload UDP Large Send*/
 
+#define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
+#define NETIF_F_ALL_CSUM	(NETIF_F_IP_CSUM | NETIF_F_GEN_CSUM)
+
 	struct net_device	*next_sched;
 
 	/* Interface index. Unique device identifier	*/
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -381,8 +381,7 @@ void br_features_recompute(struct net_br
 	checksum = br->feature_mask & NETIF_F_IP_CSUM;
 
 	list_for_each_entry(p, &br->port_list, list) {
-		if (!(p->dev->features 
-		      & (NETIF_F_IP_CSUM|NETIF_F_NO_CSUM|NETIF_F_HW_CSUM)))
+		if (!(p->dev->features & NETIF_F_ALL_CSUM))
 			checksum = 0;
 		features &= p->dev->features;
 	}
diff --git a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1284,7 +1284,7 @@ int dev_queue_xmit(struct sk_buff *skb)
 	 * checksumming for this protocol, complete checksumming here.
 	 */
 	if (skb->ip_summed == CHECKSUM_HW &&
-	    (!(dev->features & (NETIF_F_HW_CSUM | NETIF_F_NO_CSUM)) &&
+	    (!(dev->features & NETIF_F_GEN_CSUM) &&
 	     (!(dev->features & NETIF_F_IP_CSUM) ||
 	      skb->protocol != htons(ETH_P_IP))))
 	      	if (skb_checksum_help(skb, 0))
@@ -2789,9 +2789,7 @@ int register_netdevice(struct net_device
 
 	/* Fix illegal SG+CSUM combinations. */
 	if ((dev->features & NETIF_F_SG) &&
-	    !(dev->features & (NETIF_F_IP_CSUM |
-			       NETIF_F_NO_CSUM |
-			       NETIF_F_HW_CSUM))) {
+	    !(dev->features & NETIF_F_ALL_CSUM)) {
 		printk("%s: Dropping NETIF_F_SG since no checksum feature.\n",
 		       dev->name);
 		dev->features &= ~NETIF_F_SG;
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -30,7 +30,7 @@ u32 ethtool_op_get_link(struct net_devic
 
 u32 ethtool_op_get_tx_csum(struct net_device *dev)
 {
-	return (dev->features & (NETIF_F_IP_CSUM | NETIF_F_HW_CSUM)) != 0;
+	return (dev->features & NETIF_F_ALL_CSUM) != 0;
 }
 
 int ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
@@ -551,9 +551,7 @@ static int ethtool_set_sg(struct net_dev
 		return -EFAULT;
 
 	if (edata.data && 
-	    !(dev->features & (NETIF_F_IP_CSUM |
-			       NETIF_F_NO_CSUM |
-			       NETIF_F_HW_CSUM)))
+	    !(dev->features & NETIF_F_ALL_CSUM))
 		return -EINVAL;
 
 	return __ethtool_set_sg(dev, edata.data);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -839,7 +839,7 @@ int ip_append_data(struct sock *sk,
 	 */
 	if (transhdrlen &&
 	    length + fragheaderlen <= mtu &&
-	    rt->u.dst.dev->features&(NETIF_F_IP_CSUM|NETIF_F_NO_CSUM|NETIF_F_HW_CSUM) &&
+	    rt->u.dst.dev->features & NETIF_F_ALL_CSUM &&
 	    !exthdrlen)
 		csummode = CHECKSUM_HW;
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -622,14 +622,10 @@ ssize_t tcp_sendpage(struct socket *sock
 	ssize_t res;
 	struct sock *sk = sock->sk;
 
-#define TCP_ZC_CSUM_FLAGS (NETIF_F_IP_CSUM | NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
-
 	if (!(sk->sk_route_caps & NETIF_F_SG) ||
-	    !(sk->sk_route_caps & TCP_ZC_CSUM_FLAGS))
+	    !(sk->sk_route_caps & NETIF_F_ALL_CSUM))
 		return sock_no_sendpage(sock, page, offset, size, flags);
 
-#undef TCP_ZC_CSUM_FLAGS
-
 	lock_sock(sk);
 	TCP_CHECK_TIMER(sk);
 	res = do_tcp_sendpages(sk, &page, offset, size, flags);
@@ -726,9 +722,7 @@ new_segment:
 				/*
 				 * Check whether we can use HW checksum.
 				 */
-				if (sk->sk_route_caps &
-				    (NETIF_F_IP_CSUM | NETIF_F_NO_CSUM |
-				     NETIF_F_HW_CSUM))
+				if (sk->sk_route_caps & NETIF_F_ALL_CSUM)
 					skb->ip_summed = CHECKSUM_HW;
 
 				skb_entail(sk, tp, skb);

--AhhlLboLdkugWU4S--
