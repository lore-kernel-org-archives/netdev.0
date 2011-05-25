From: greearb@candelatech.com
Subject: [RFC] af-packet:  Save reference to bound network device.
Date: Wed, 25 May 2011 14:56:42 -0700
Message-ID: <1306360602-9672-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46345 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755561Ab1EYV4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 17:56:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This saves a network device lookup on each packet transmitted,
for sockets that are bound to a network device.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 4005b24... ba16759... M	net/packet/af_packet.c
 net/packet/af_packet.c |   48 +++++++++++++++++++++++++++++++++++-------------
 1 files changed, 35 insertions(+), 13 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 4005b24..ba16759 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -201,8 +201,9 @@ struct packet_sock {
 				auxdata:1,
 				origdev:1,
 				has_vnet_hdr:1;
-	int			ifindex;	/* bound device		*/
+	int			ifindex;	/* bound device id	*/
 	__be16			num;
+	struct net_device	*bound_dev; /* bound device */
 	struct packet_mclist	*mclist;
 	atomic_t		mapped;
 	enum tpacket_versions	tp_version;
@@ -987,8 +988,9 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 {
 	struct sk_buff *skb;
-	struct net_device *dev;
+	struct net_device *dev = NULL;
 	__be16 proto;
+	bool need_rls_dev = false;
 	int ifindex, err, reserve = 0;
 	void *ph;
 	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
@@ -1002,6 +1004,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	err = -EBUSY;
 	if (saddr == NULL) {
 		ifindex	= po->ifindex;
+		dev = po->bound_dev;
 		proto	= po->num;
 		addr	= NULL;
 	} else {
@@ -1017,7 +1020,10 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		addr	= saddr->sll_addr;
 	}
 
-	dev = dev_get_by_index(sock_net(&po->sk), ifindex);
+	if (!dev) {
+		dev = dev_get_by_index(sock_net(&po->sk), ifindex);
+		need_rls_dev = true;
+	}
 	err = -ENXIO;
 	if (unlikely(dev == NULL))
 		goto out;
@@ -1103,7 +1109,8 @@ out_status:
 	__packet_set_status(po, ph, status);
 	kfree_skb(skb);
 out_put:
-	dev_put(dev);
+	if (need_rls_dev)
+		dev_put(dev);
 out:
 	mutex_unlock(&po->pg_vec_lock);
 	return err;
@@ -1139,8 +1146,9 @@ static int packet_snd(struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
 	struct sk_buff *skb;
-	struct net_device *dev;
+	struct net_device *dev = NULL;
 	__be16 proto;
+	bool need_rls_dev = false;
 	unsigned char *addr;
 	int ifindex, err, reserve = 0;
 	struct virtio_net_hdr vnet_hdr = { 0 };
@@ -1161,6 +1169,7 @@ static int packet_snd(struct socket *sock,
 
 	if (saddr == NULL) {
 		ifindex	= po->ifindex;
+		dev = po->bound_dev;
 		proto	= po->num;
 		addr	= NULL;
 	} else {
@@ -1174,8 +1183,11 @@ static int packet_snd(struct socket *sock,
 		addr	= saddr->sll_addr;
 	}
 
+	if (!dev) {
+		dev = dev_get_by_index(sock_net(sk), ifindex);
+		need_rls_dev = true;
+	}
 
-	dev = dev_get_by_index(sock_net(sk), ifindex);
 	err = -ENXIO;
 	if (dev == NULL)
 		goto out_unlock;
@@ -1315,14 +1327,15 @@ static int packet_snd(struct socket *sock,
 	if (err > 0 && (err = net_xmit_errno(err)) != 0)
 		goto out_unlock;
 
-	dev_put(dev);
+	if (need_rls_dev)
+		dev_put(dev);
 
 	return len;
 
 out_free:
 	kfree_skb(skb);
 out_unlock:
-	if (dev)
+	if (dev && need_rls_dev)
 		dev_put(dev);
 out:
 	return err;
@@ -1372,6 +1385,12 @@ static int packet_release(struct socket *sock)
 		__dev_remove_pack(&po->prot_hook);
 		__sock_put(sk);
 	}
+
+	if (po->bound_dev) {
+		dev_put(po->bound_dev);
+		po->bound_dev = NULL;
+	}
+	
 	spin_unlock(&po->bind_lock);
 
 	packet_flush_mclist(sk);
@@ -1428,6 +1447,9 @@ static int packet_do_bind(struct sock *sk, struct net_device *dev, __be16 protoc
 	po->prot_hook.dev = dev;
 
 	po->ifindex = dev ? dev->ifindex : 0;
+	if (po->bound_dev)
+		dev_put(po->bound_dev);
+	po->bound_dev = dev;
 
 	if (protocol == 0)
 		goto out_unlock;
@@ -1469,10 +1491,8 @@ static int packet_bind_spkt(struct socket *sock, struct sockaddr *uaddr,
 	strlcpy(name, uaddr->sa_data, sizeof(name));
 
 	dev = dev_get_by_name(sock_net(sk), name);
-	if (dev) {
+	if (dev)
 		err = packet_do_bind(sk, dev, pkt_sk(sk)->num);
-		dev_put(dev);
-	}
 	return err;
 }
 
@@ -1500,8 +1520,6 @@ static int packet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len
 			goto out;
 	}
 	err = packet_do_bind(sk, dev, sll->sll_protocol ? : pkt_sk(sk)->num);
-	if (dev)
-		dev_put(dev);
 
 out:
 	return err;
@@ -2266,6 +2284,10 @@ static int packet_notifier(struct notifier_block *this, unsigned long msg, void
 				}
 				if (msg == NETDEV_UNREGISTER) {
 					po->ifindex = -1;
+					if (po->bound_dev) {
+						dev_put(po->bound_dev);
+						po->bound_dev = NULL;
+					}
 					po->prot_hook.dev = NULL;
 				}
 				spin_unlock(&po->bind_lock);
-- 
1.7.3.4

