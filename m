From: greearb@candelatech.com
Subject: [PATCH 2/2 v3] af-packet: Use existing netdev reference for bound sockets.
Date: Wed,  1 Jun 2011 10:18:53 -0700
Message-ID: <1306948733-22441-2-git-send-email-greearb@candelatech.com>
References: <1306948733-22441-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35506 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758056Ab1FARTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 13:19:16 -0400
In-Reply-To: <1306948733-22441-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This saves a network device lookup on each packet transmitted,
for sockets that are bound to a network device.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---

v3:  No changes since last time, but previous patch to hold
     prot_hook.dev should fix locking problems with this patch.

:100644 100644 614d659... c1c5f33... M	net/packet/af_packet.c
 net/packet/af_packet.c |   27 +++++++++++++++------------
 1 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 614d659..c1c5f33 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -994,7 +994,8 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	struct sk_buff *skb;
 	struct net_device *dev;
 	__be16 proto;
-	int ifindex, err, reserve = 0;
+	bool need_rls_dev = false;
+	int err, reserve = 0;
 	void *ph;
 	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
 	int tp_len, size_max;
@@ -1006,7 +1007,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 
 	err = -EBUSY;
 	if (saddr == NULL) {
-		ifindex	= po->ifindex;
+		dev = po->prot_hook.dev;
 		proto	= po->num;
 		addr	= NULL;
 	} else {
@@ -1017,12 +1018,12 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
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
@@ -1108,7 +1109,8 @@ out_status:
 	__packet_set_status(po, ph, status);
 	kfree_skb(skb);
 out_put:
-	dev_put(dev);
+	if (need_rls_dev)
+		dev_put(dev);
 out:
 	mutex_unlock(&po->pg_vec_lock);
 	return err;
@@ -1146,8 +1148,9 @@ static int packet_snd(struct socket *sock,
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
@@ -1165,7 +1168,7 @@ static int packet_snd(struct socket *sock,
 	 */
 
 	if (saddr == NULL) {
-		ifindex	= po->ifindex;
+		dev = po->prot_hook.dev;
 		proto	= po->num;
 		addr	= NULL;
 	} else {
@@ -1174,13 +1177,12 @@ static int packet_snd(struct socket *sock,
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
@@ -1320,14 +1322,15 @@ static int packet_snd(struct socket *sock,
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

