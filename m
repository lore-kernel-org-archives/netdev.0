From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/3] net-2.6.24: wrap netdevice hardware header creation
Date: Wed, 26 Sep 2007 17:21:29 -0700
Message-ID: <20070926172129.5550a636@freepuppy.rosehill>
References: <20070824204310.388073598@linux-foundation.org>
 <20070925.192428.18597166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52258 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751285AbXI0AXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 20:23:00 -0400
In-Reply-To: <20070925.192428.18597166.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add inline for common usage of hardware header creation, and
fix bug in IPV6 mcast where the assumption about negative return is
an errno. Negative return from hard_header means not enough space
was available,(ie -N bytes).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/include/linux/netdevice.h	2007-09-26 15:07:34.000000000 -0700
+++ b/include/linux/netdevice.h	2007-09-26 15:22:26.000000000 -0700
@@ -801,6 +801,15 @@ extern int		dev_restart(struct net_devic
 extern int		netpoll_trap(void);
 #endif
 
+static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
+				  unsigned short type,
+				  void *daddr, void *saddr, unsigned len)
+{
+	if (!dev->hard_header)
+		return 0;
+	return dev->hard_header(skb, dev, type, daddr, saddr, len);
+}
+
 typedef int gifconf_func_t(struct net_device * dev, char __user * bufptr, int len);
 extern int		register_gifconf(unsigned int family, gifconf_func_t * gifconf);
 static inline int unregister_gifconf(unsigned int family)
--- a/net/ipv4/arp.c	2007-09-26 15:07:35.000000000 -0700
+++ b/net/ipv4/arp.c	2007-09-26 15:22:26.000000000 -0700
@@ -591,8 +591,7 @@ struct sk_buff *arp_create(int type, int
 	/*
 	 *	Fill the device header for the ARP frame
 	 */
-	if (dev->hard_header &&
-	    dev->hard_header(skb,dev,ptype,dest_hw,src_hw,skb->len) < 0)
+	if (dev_hard_header(skb, dev, ptype, dest_hw, src_hw, skb->len) < 0)
 		goto out;
 
 	/*
--- a/net/core/neighbour.c	2007-09-26 15:07:35.000000000 -0700
+++ b/net/core/neighbour.c	2007-09-26 15:22:26.000000000 -0700
@@ -1125,9 +1125,8 @@ int neigh_compat_output(struct sk_buff *
 
 	__skb_pull(skb, skb_network_offset(skb));
 
-	if (dev->hard_header &&
-	    dev->hard_header(skb, dev, ntohs(skb->protocol), NULL, NULL,
-			     skb->len) < 0 &&
+	if (dev_hard_header(skb, dev, ntohs(skb->protocol), NULL, NULL,
+			    skb->len) < 0 &&
 	    dev->rebuild_header(skb))
 		return 0;
 
@@ -1154,13 +1153,13 @@ int neigh_resolve_output(struct sk_buff 
 			write_lock_bh(&neigh->lock);
 			if (!dst->hh)
 				neigh_hh_init(neigh, dst, dst->ops->protocol);
-			err = dev->hard_header(skb, dev, ntohs(skb->protocol),
-					       neigh->ha, NULL, skb->len);
+			err = dev_hard_header(skb, dev, ntohs(skb->protocol),
+					      neigh->ha, NULL, skb->len);
 			write_unlock_bh(&neigh->lock);
 		} else {
 			read_lock_bh(&neigh->lock);
-			err = dev->hard_header(skb, dev, ntohs(skb->protocol),
-					       neigh->ha, NULL, skb->len);
+			err = dev_hard_header(skb, dev, ntohs(skb->protocol),
+					      neigh->ha, NULL, skb->len);
 			read_unlock_bh(&neigh->lock);
 		}
 		if (err >= 0)
@@ -1191,8 +1190,8 @@ int neigh_connected_output(struct sk_buf
 	__skb_pull(skb, skb_network_offset(skb));
 
 	read_lock_bh(&neigh->lock);
-	err = dev->hard_header(skb, dev, ntohs(skb->protocol),
-			       neigh->ha, NULL, skb->len);
+	err = dev_hard_header(skb, dev, ntohs(skb->protocol),
+			      neigh->ha, NULL, skb->len);
 	read_unlock_bh(&neigh->lock);
 	if (err >= 0)
 		err = neigh->ops->queue_xmit(skb);
--- a/net/8021q/vlan_dev.c	2007-09-26 15:07:35.000000000 -0700
+++ b/net/8021q/vlan_dev.c	2007-09-26 15:22:26.000000000 -0700
@@ -434,21 +434,19 @@ int vlan_dev_hard_header(struct sk_buff 
 
 	if (build_vlan_header) {
 		/* Now make the underlying real hard header */
-		rc = dev->hard_header(skb, dev, ETH_P_8021Q, daddr, saddr, len + VLAN_HLEN);
-
-		if (rc > 0) {
+		rc = dev_hard_header(skb, dev, ETH_P_8021Q, daddr, saddr,
+				     len + VLAN_HLEN);
+		if (rc > 0)
 			rc += VLAN_HLEN;
-		} else if (rc < 0) {
+		else if (rc < 0)
 			rc -= VLAN_HLEN;
-		}
-	} else {
+	} else
 		/* If here, then we'll just make a normal looking ethernet frame,
 		 * but, the hard_start_xmit method will insert the tag (it has to
 		 * be able to do this for bridged and other skbs that don't come
 		 * down the protocol stack in an orderly manner.
 		 */
-		rc = dev->hard_header(skb, dev, type, daddr, saddr, len);
-	}
+		rc = dev_hard_header(skb, dev, type, daddr, saddr, len);
 
 	return rc;
 }
--- a/net/core/netpoll.c	2007-09-26 15:07:35.000000000 -0700
+++ b/net/core/netpoll.c	2007-09-26 15:22:26.000000000 -0700
@@ -415,11 +415,9 @@ static void arp_reply(struct sk_buff *sk
 	send_skb->protocol = htons(ETH_P_ARP);
 
 	/* Fill the device header for the ARP frame */
-
-	if (np->dev->hard_header &&
-	    np->dev->hard_header(send_skb, skb->dev, ptype,
-				 sha, np->local_mac,
-				 send_skb->len) < 0) {
+	if (dev_hard_header(send_skb, skb->dev, ptype,
+			    sha, np->local_mac,
+			    send_skb->len) < 0) {
 		kfree_skb(send_skb);
 		return;
 	}
--- a/net/packet/af_packet.c	2007-09-26 15:07:35.000000000 -0700
+++ b/net/packet/af_packet.c	2007-09-26 15:22:26.000000000 -0700
@@ -765,16 +765,10 @@ static int packet_sendmsg(struct kiocb *
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 	skb_reset_network_header(skb);
 
-	if (dev->hard_header) {
-		int res;
-		err = -EINVAL;
-		res = dev->hard_header(skb, dev, ntohs(proto), addr, NULL, len);
-		if (sock->type != SOCK_DGRAM) {
-			skb_reset_tail_pointer(skb);
-			skb->len = 0;
-		} else if (res < 0)
-			goto out_free;
-	}
+	err = -EINVAL;
+	if (sock->type == SOCK_DGRAM &&
+	    dev_hard_header(skb, dev, ntohs(proto), addr, NULL, len) < 0)
+		goto out_free;
 
 	/* Returns -EFAULT on error */
 	err = memcpy_fromiovec(skb_put(skb,len), msg->msg_iov, len);
--- a/net/802/p8023.c	2007-09-26 15:07:35.000000000 -0700
+++ b/net/802/p8023.c	2007-09-26 15:22:26.000000000 -0700
@@ -31,7 +31,7 @@ static int p8023_request(struct datalink
 {
 	struct net_device *dev = skb->dev;
 
-	dev->hard_header(skb, dev, ETH_P_802_3, dest_node, NULL, skb->len);
+	dev_hard_header(skb, dev, ETH_P_802_3, dest_node, NULL, skb->len);
 	return dev_queue_xmit(skb);
 }
 
--- a/net/decnet/dn_neigh.c	2007-09-26 15:07:35.000000000 -0700
+++ b/net/decnet/dn_neigh.c	2007-09-26 15:22:26.000000000 -0700
@@ -211,7 +211,8 @@ static int dn_neigh_output_packet(struct
 	char mac_addr[ETH_ALEN];
 
 	dn_dn2eth(mac_addr, rt->rt_local_src);
-	if (!dev->hard_header || dev->hard_header(skb, dev, ntohs(skb->protocol), neigh->ha, mac_addr, skb->len) >= 0)
+	if (dev_hard_header(skb, dev, ntohs(skb->protocol), neigh->ha,
+			    mac_addr, skb->len) >= 0)
 		return neigh->ops->queue_xmit(skb);
 
 	if (net_ratelimit())
--- a/net/econet/af_econet.c	2007-09-26 15:07:35.000000000 -0700
+++ b/net/econet/af_econet.c	2007-09-26 15:22:26.000000000 -0700
@@ -336,6 +336,7 @@ static int econet_sendmsg(struct kiocb *
 		/* Real hardware Econet.  We're not worthy etc. */
 #ifdef CONFIG_ECONET_NATIVE
 		unsigned short proto = 0;
+		int res;
 
 		dev_hold(dev);
 
@@ -354,12 +355,12 @@ static int econet_sendmsg(struct kiocb *
 		eb->sec = *saddr;
 		eb->sent = ec_tx_done;
 
-		if (dev->hard_header) {
-			int res;
+		err = -EINVAL;
+		res = dev_hard_header(skb, dev, ntohs(proto), &addr, NULL, len);
+		if (res < 0)
+			goto out_free;
+		if (res > 0) {
 			struct ec_framehdr *fh;
-			err = -EINVAL;
-			res = dev->hard_header(skb, dev, ntohs(proto),
-					       &addr, NULL, len);
 			/* Poke in our control byte and
 			   port number.  Hack, hack.  */
 			fh = (struct ec_framehdr *)(skb->data);
@@ -368,8 +369,7 @@ static int econet_sendmsg(struct kiocb *
 			if (sock->type != SOCK_DGRAM) {
 				skb_reset_tail_pointer(skb);
 				skb->len = 0;
-			} else if (res < 0)
-				goto out_free;
+			}
 		}
 
 		/* Copy the data. Returns -EFAULT on error */
--- a/net/ethernet/pe2.c	2007-09-26 15:07:35.000000000 -0700
+++ b/net/ethernet/pe2.c	2007-09-26 15:22:26.000000000 -0700
@@ -12,9 +12,7 @@ static int pEII_request(struct datalink_
 	struct net_device *dev = skb->dev;
 
 	skb->protocol = htons(ETH_P_IPX);
-	if (dev->hard_header)
-		dev->hard_header(skb, dev, ETH_P_IPX,
-				 dest_node, NULL, skb->len);
+	dev_hard_header(skb, dev, ETH_P_IPX, dest_node, NULL, skb->len);
 	return dev_queue_xmit(skb);
 }
 
--- a/net/ipv4/ipconfig.c	2007-09-26 15:07:35.000000000 -0700
+++ b/net/ipv4/ipconfig.c	2007-09-26 15:22:26.000000000 -0700
@@ -753,8 +753,8 @@ static void __init ic_bootp_send_if(stru
 	/* Chain packet down the line... */
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
-	if ((dev->hard_header &&
-	     dev->hard_header(skb, dev, ntohs(skb->protocol), dev->broadcast, dev->dev_addr, skb->len) < 0) ||
+	if (dev_hard_header(skb, dev, ntohs(skb->protocol),
+			    dev->broadcast, dev->dev_addr, skb->len) < 0) ||
 	    dev_queue_xmit(skb) < 0)
 		printk("E");
 }
--- a/net/ipv6/mcast.c	2007-09-26 15:07:35.000000000 -0700
+++ b/net/ipv6/mcast.c	2007-09-26 15:22:26.000000000 -0700
@@ -1438,17 +1438,12 @@ static struct sk_buff *mld_newpack(struc
 static inline int mld_dev_queue_xmit2(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
+	unsigned char ha[MAX_ADDR_LEN];
 
-	if (dev->hard_header) {
-		unsigned char ha[MAX_ADDR_LEN];
-		int err;
-
-		ndisc_mc_map(&ipv6_hdr(skb)->daddr, ha, dev, 1);
-		err = dev->hard_header(skb, dev, ETH_P_IPV6, ha, NULL, skb->len);
-		if (err < 0) {
-			kfree_skb(skb);
-			return err;
-		}
+	ndisc_mc_map(&ipv6_hdr(skb)->daddr, ha, dev, 1);
+	if (dev_hard_header(skb, dev, ETH_P_IPV6, ha, NULL, skb->len) < 0) {
+		kfree_skb(skb);
+		return -EINVAL;
 	}
 	return dev_queue_xmit(skb);
 }
--- a/net/sched/sch_teql.c	2007-09-26 15:07:35.000000000 -0700
+++ b/net/sched/sch_teql.c	2007-09-26 15:22:26.000000000 -0700
@@ -232,9 +232,12 @@ __teql_resolve(struct sk_buff *skb, stru
 	}
 	if (neigh_event_send(n, skb_res) == 0) {
 		int err;
+
 		read_lock(&n->lock);
-		err = dev->hard_header(skb, dev, ntohs(skb->protocol), n->ha, NULL, skb->len);
+		err = dev_hard_header(skb, dev, ntohs(skb->protocol),
+				      n->ha, NULL, skb->len);
 		read_unlock(&n->lock);
+
 		if (err < 0) {
 			neigh_release(n);
 			return -EINVAL;
--- a/net/tipc/eth_media.c	2007-09-26 15:07:35.000000000 -0700
+++ b/net/tipc/eth_media.c	2007-09-26 15:22:26.000000000 -0700
@@ -77,7 +77,7 @@ static int send_msg(struct sk_buff *buf,
 		skb_reset_network_header(clone);
 		dev = ((struct eth_bearer *)(tb_ptr->usr_handle))->dev;
 		clone->dev = dev;
-		dev->hard_header(clone, dev, ETH_P_TIPC,
+		dev_hard_header(clone, dev, ETH_P_TIPC,
 				 &dest->dev_addr.eth_addr,
 				 dev->dev_addr, clone->len);
 		dev_queue_xmit(clone);
--- a/drivers/net/hamradio/bpqether.c	2007-09-26 15:07:23.000000000 -0700
+++ b/drivers/net/hamradio/bpqether.c	2007-09-26 15:22:26.000000000 -0700
@@ -286,7 +286,7 @@ static int bpq_xmit(struct sk_buff *skb,
 
 	skb->protocol = ax25_type_trans(skb, dev);
 	skb_reset_network_header(skb);
-	dev->hard_header(skb, dev, ETH_P_BPQ, bpq->dest_addr, NULL, 0);
+	dev_hard_header(skb, dev, ETH_P_BPQ, bpq->dest_addr, NULL, 0);
 	bpq->stats.tx_packets++;
 	bpq->stats.tx_bytes+=skb->len;
   
--- a/drivers/net/macvlan.c	2007-09-26 15:07:23.000000000 -0700
+++ b/drivers/net/macvlan.c	2007-09-26 15:22:26.000000000 -0700
@@ -170,8 +170,8 @@ static int macvlan_hard_header(struct sk
 	const struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
 
-	return lowerdev->hard_header(skb, lowerdev, type, daddr,
-				     saddr ? : dev->dev_addr, len);
+	return dev_hard_header(skb, lowerdev, type, daddr,
+			       saddr ? : dev->dev_addr, len);
 }
 
 static int macvlan_open(struct net_device *dev)
--- a/drivers/net/pppoe.c	2007-09-26 15:07:23.000000000 -0700
+++ b/drivers/net/pppoe.c	2007-09-26 15:23:07.000000000 -0700
@@ -834,8 +834,8 @@ static int pppoe_sendmsg(struct kiocb *i
 	}
 
 	error = total_len;
-	dev->hard_header(skb, dev, ETH_P_PPP_SES,
-			 po->pppoe_pa.remote, NULL, total_len);
+	dev_hard_header(skb, dev, ETH_P_PPP_SES,
+			po->pppoe_pa.remote, NULL, total_len);
 
 	memcpy(ph, &hdr, sizeof(struct pppoe_hdr));
 
@@ -886,8 +886,8 @@ static int __pppoe_xmit(struct sock *sk,
 	skb->protocol = __constant_htons(ETH_P_PPP_SES);
 	skb->dev = dev;
 
-	dev->hard_header(skb, dev, ETH_P_PPP_SES,
-			 po->pppoe_pa.remote, NULL, data_len);
+	dev_hard_header(skb, dev, ETH_P_PPP_SES,
+			po->pppoe_pa.remote, NULL, data_len);
 
 	dev_queue_xmit(skb);
 
--- a/include/net/dn_route.h	2007-09-26 15:07:34.000000000 -0700
+++ b/include/net/dn_route.h	2007-09-26 15:22:26.000000000 -0700
@@ -100,8 +100,7 @@ static inline void dn_rt_finish_output(s
 	if ((dev->type != ARPHRD_ETHER) && (dev->type != ARPHRD_LOOPBACK))
 		dst = NULL;
 
-	if (!dev->hard_header || (dev->hard_header(skb, dev, ETH_P_DNA_RT,
-			dst, src, skb->len) >= 0))
+	if (dev_hard_header(skb, dev, ETH_P_DNA_RT, dst, src, skb->len) >= 0)
 		dn_rt_send(skb);
 	else
 		kfree_skb(skb);
--- a/drivers/net/wan/lapbether.c	2007-09-26 15:07:23.000000000 -0700
+++ b/drivers/net/wan/lapbether.c	2007-09-26 15:22:26.000000000 -0700
@@ -216,7 +216,7 @@ static void lapbeth_data_transmit(struct
 
 	skb->dev = dev = lapbeth->ethdev;
 
-	dev->hard_header(skb, dev, ETH_P_DEC, bcast_addr, NULL, 0);
+	dev_hard_header(skb, dev, ETH_P_DEC, bcast_addr, NULL, 0);
 
 	dev_queue_xmit(skb);
 }
