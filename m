From: greearb@candelatech.com
Subject: [PATCH] af-packet:  Use existing netdev reference for bound sockets.
Date: Wed, 25 May 2011 16:15:32 -0700
Message-ID: <1306365332-12105-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50278 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752194Ab1EYXPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 19:15:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This saves a network device lookup on each packet transmitted,
for sockets that are bound to a network device.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 4005b24... 658edd1... M	net/packet/af_packet.c
 net/packet/af_packet.c |   26 +++++++++++++++++++-------
 1 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 4005b24..658edd1 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -987,8 +987,9 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
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
@@ -1002,6 +1003,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	err = -EBUSY;
 	if (saddr == NULL) {
 		ifindex	= po->ifindex;
+		dev = po->prot_hook.dev;
 		proto	= po->num;
 		addr	= NULL;
 	} else {
@@ -1017,7 +1019,10 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
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
@@ -1103,7 +1108,8 @@ out_status:
 	__packet_set_status(po, ph, status);
 	kfree_skb(skb);
 out_put:
-	dev_put(dev);
+	if (need_rls_dev)
+		dev_put(dev);
 out:
 	mutex_unlock(&po->pg_vec_lock);
 	return err;
@@ -1139,8 +1145,9 @@ static int packet_snd(struct socket *sock,
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
@@ -1161,6 +1168,7 @@ static int packet_snd(struct socket *sock,
 
 	if (saddr == NULL) {
 		ifindex	= po->ifindex;
+		dev = po->prot_hook.dev;
 		proto	= po->num;
 		addr	= NULL;
 	} else {
@@ -1174,8 +1182,11 @@ static int packet_snd(struct socket *sock,
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
@@ -1315,14 +1326,15 @@ static int packet_snd(struct socket *sock,
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

