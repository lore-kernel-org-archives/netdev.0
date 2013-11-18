From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: [PATCH 1/1] Revert "af-packet: Use existing netdev reference for bound sockets"
Date: Sun, 17 Nov 2013 21:32:08 -0800
Message-ID: <1384752728-37157-1-git-send-email-noureddine@aristanetworks.com>
Cc: Salam Noureddine <noureddine@bs324.sjc.aristanetworks.com>
To: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Phil Sutter <phil@nwl.cc>, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:56511 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712Ab3KRFcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 00:32:18 -0500
Received: by mail-pb0-f43.google.com with SMTP id rq2so4123947pbb.2
        for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 21:32:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Salam Noureddine <noureddine@bs324.sjc.aristanetworks.com>

This reverts commit 827d978037d7d0bf0860481948c6d26ead10042f
("af-packet: Use existing netdev reference for bound sockets")

The patch introduced a race condition between packet_snd and
packet_notifier when a net_device is being unregistered. In the case of
a bound socket, packet_notifier can drop the last reference to the
net_device and packet_snd might end up sending a packet over a freed
net_device.

Signed-off-by: Salam Noureddine <noureddine@bs324.sjc.aristanetworks.com>
---
 net/packet/af_packet.c |   26 +++++++++++---------------
 1 files changed, 11 insertions(+), 15 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2e8286b..34fe9eb 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2057,8 +2057,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	struct sk_buff *skb;
 	struct net_device *dev;
 	__be16 proto;
-	bool need_rls_dev = false;
-	int err, reserve = 0;
+	int ifindex, err, reserve = 0;
 	void *ph;
 	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
 	int tp_len, size_max;
@@ -2070,7 +2069,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	mutex_lock(&po->pg_vec_lock);
 
 	if (saddr == NULL) {
-		dev = po->prot_hook.dev;
+		ifindex	= po->ifindex;
 		proto	= po->num;
 		addr	= NULL;
 	} else {
@@ -2081,12 +2080,12 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 					+ offsetof(struct sockaddr_ll,
 						sll_addr)))
 			goto out;
+		ifindex	= saddr->sll_ifindex;
 		proto	= saddr->sll_protocol;
 		addr	= saddr->sll_addr;
-		dev = dev_get_by_index(sock_net(&po->sk), saddr->sll_ifindex);
-		need_rls_dev = true;
 	}
 
+	dev = dev_get_by_index(sock_net(&po->sk), ifindex);
 	err = -ENXIO;
 	if (unlikely(dev == NULL))
 		goto out;
@@ -2173,8 +2172,7 @@ out_status:
 	__packet_set_status(po, ph, status);
 	kfree_skb(skb);
 out_put:
-	if (need_rls_dev)
-		dev_put(dev);
+	dev_put(dev);
 out:
 	mutex_unlock(&po->pg_vec_lock);
 	return err;
@@ -2212,9 +2210,8 @@ static int packet_snd(struct socket *sock,
 	struct sk_buff *skb;
 	struct net_device *dev;
 	__be16 proto;
-	bool need_rls_dev = false;
 	unsigned char *addr;
-	int err, reserve = 0;
+	int ifindex, err, reserve = 0;
 	struct virtio_net_hdr vnet_hdr = { 0 };
 	int offset = 0;
 	int vnet_hdr_len;
@@ -2228,7 +2225,7 @@ static int packet_snd(struct socket *sock,
 	 */
 
 	if (saddr == NULL) {
-		dev = po->prot_hook.dev;
+		ifindex	= po->ifindex;
 		proto	= po->num;
 		addr	= NULL;
 	} else {
@@ -2237,12 +2234,12 @@ static int packet_snd(struct socket *sock,
 			goto out;
 		if (msg->msg_namelen < (saddr->sll_halen + offsetof(struct sockaddr_ll, sll_addr)))
 			goto out;
+		ifindex	= saddr->sll_ifindex;
 		proto	= saddr->sll_protocol;
 		addr	= saddr->sll_addr;
-		dev = dev_get_by_index(sock_net(sk), saddr->sll_ifindex);
-		need_rls_dev = true;
 	}
 
+	dev = dev_get_by_index(sock_net(sk), ifindex);
 	err = -ENXIO;
 	if (dev == NULL)
 		goto out_unlock;
@@ -2386,15 +2383,14 @@ static int packet_snd(struct socket *sock,
 	if (err > 0 && (err = net_xmit_errno(err)) != 0)
 		goto out_unlock;
 
-	if (need_rls_dev)
-		dev_put(dev);
+	dev_put(dev);
 
 	return len;
 
 out_free:
 	kfree_skb(skb);
 out_unlock:
-	if (dev && need_rls_dev)
+	if (dev)
 		dev_put(dev);
 out:
 	return err;
-- 
1.7.4.4
