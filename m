From: greearb@candelatech.com
Subject: [PATCH 1/2 v2] af-packet:  Use existing netdev reference for bound sockets.
Date: Thu, 26 May 2011 16:55:40 -0700
Message-ID: <1306454141-1634-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46744 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023Ab1EZXzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 19:55:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This saves a network device lookup on each packet transmitted,
for sockets that are bound to a network device.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---

v2:  Remove un-used ifindex, lookup dev in else branch.

:100644 100644 4005b24... f9b807d... M	net/packet/af_packet.c
 net/packet/af_packet.c |   27 +++++++++++++++------------
 1 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 4005b24..f9b807d 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -989,7 +989,8 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	struct sk_buff *skb;
 	struct net_device *dev;
 	__be16 proto;
-	int ifindex, err, reserve = 0;
+	bool need_rls_dev = false;
+	int err, reserve = 0;
 	void *ph;
 	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
 	int tp_len, size_max;
@@ -1001,7 +1002,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 
 	err = -EBUSY;
 	if (saddr == NULL) {
-		ifindex	= po->ifindex;
+		dev = po->prot_hook.dev;
 		proto	= po->num;
 		addr	= NULL;
 	} else {
@@ -1012,12 +1013,12 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 					+ offsetof(struct sockaddr_ll,
 						sll_addr)))
 			goto out;
-		ifindex	= saddr->sll_ifindex;
 		proto	= saddr->sll_protocol;
 		addr	= saddr->sll_addr;
+		dev = dev_get_by_index(sock_net(&po->sk), saddr->sll_ifindex);
+		need_rls_dev = true;
 	}
 
-	dev = dev_get_by_index(sock_net(&po->sk), ifindex);
 	err = -ENXIO;
 	if (unlikely(dev == NULL))
 		goto out;
@@ -1103,7 +1104,8 @@ out_status:
 	__packet_set_status(po, ph, status);
 	kfree_skb(skb);
 out_put:
-	dev_put(dev);
+	if (need_rls_dev)
+		dev_put(dev);
 out:
 	mutex_unlock(&po->pg_vec_lock);
 	return err;
@@ -1141,8 +1143,9 @@ static int packet_snd(struct socket *sock,
 	struct sk_buff *skb;
 	struct net_device *dev;
 	__be16 proto;
+	bool need_rls_dev = false;
 	unsigned char *addr;
-	int ifindex, err, reserve = 0;
+	int err, reserve = 0;
 	struct virtio_net_hdr vnet_hdr = { 0 };
 	int offset = 0;
 	int vnet_hdr_len;
@@ -1160,7 +1163,7 @@ static int packet_snd(struct socket *sock,
 	 */
 
 	if (saddr == NULL) {
-		ifindex	= po->ifindex;
+		dev = po->prot_hook.dev;
 		proto	= po->num;
 		addr	= NULL;
 	} else {
@@ -1169,13 +1172,12 @@ static int packet_snd(struct socket *sock,
 			goto out;
 		if (msg->msg_namelen < (saddr->sll_halen + offsetof(struct sockaddr_ll, sll_addr)))
 			goto out;
-		ifindex	= saddr->sll_ifindex;
 		proto	= saddr->sll_protocol;
 		addr	= saddr->sll_addr;
+		dev = dev_get_by_index(sock_net(sk), saddr->sll_ifindex);
+		need_rls_dev = true;
 	}
 
-
-	dev = dev_get_by_index(sock_net(sk), ifindex);
 	err = -ENXIO;
 	if (dev == NULL)
 		goto out_unlock;
@@ -1315,14 +1317,15 @@ static int packet_snd(struct socket *sock,
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
-- 
1.7.3.4

