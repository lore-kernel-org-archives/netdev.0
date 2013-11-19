From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] packet: fix use after free race in send path when dev is released
Date: Wed, 20 Nov 2013 00:08:23 +0100
Message-ID: <1384902503-1588-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Salam Noureddine <noureddine@aristanetworks.com>,
	Ben Greear <greearb@candelatech.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49991 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752058Ab3KSXI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 18:08:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Salam reported a use after free bug in PF_PACKET that occurs when
we're sending out frames on a socket bound device and suddenly the
netdevice is being unregistered. It appears that commit 827d9780
introduced a possible race condition between {t,}packet_snd and
packet_notifier. In the case of a bound socket, packet_notifier can
drop the last reference to the net_device and {t,}packet_snd might
end up sending a packet over a freed net_device.

To avoid reverting 827d9780 entirely, we could make use of po->running
member that gets reset when we're calling __unregister_prot_hook() in
packet_notifier() when we receive NETDEV_DOWN or NETDEV_UNREGISTER
notification. Plus, we still need to hold ref to the netdev, so
that we can assure it won't be released while we're in send path.
We try to avoid holding the bind lock all over send code as this
would likely make it worse when multiple threads want to send on
the same socket (in mmap code we're holding the pg_vec_lock mutex
all over the send code; we should try to get rid of that at some
point in time!). This at least buys us the possibility that we don't
have to walk over the entire dev list in dev_get_by_index() that we
would need to do as before 827d9780, which can just hurt as well
with many devices registered.

Fixes: 827d978037d7 ("af-packet: Use existing netdev reference for bound sockets.")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>
Tested-by: Salam Noureddine <noureddine@aristanetworks.com>
Cc: Ben Greear <greearb@candelatech.com>
---
 net/packet/af_packet.c | 33 ++++++++++++++++++++-------------
 1 file changed, 20 insertions(+), 13 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 2e8286b..385b2cc 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1045,6 +1045,19 @@ static void *__prb_previous_block(struct packet_sock *po,
 	return prb_lookup_block(po, rb, previous, status);
 }
 
+static struct net_device *dev_get_packet_sock(struct packet_sock *po)
+{
+	struct net_device *dev;
+
+	spin_lock(&po->bind_lock);
+	dev = po->prot_hook.dev;
+	if (dev)
+		dev_hold(dev);
+	spin_unlock(&po->bind_lock);
+
+	return dev;
+}
+
 static void *packet_previous_rx_frame(struct packet_sock *po,
 					     struct packet_ring_buffer *rb,
 					     int status)
@@ -2057,7 +2070,6 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	struct sk_buff *skb;
 	struct net_device *dev;
 	__be16 proto;
-	bool need_rls_dev = false;
 	int err, reserve = 0;
 	void *ph;
 	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
@@ -2070,7 +2082,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	mutex_lock(&po->pg_vec_lock);
 
 	if (saddr == NULL) {
-		dev = po->prot_hook.dev;
+		dev	= dev_get_packet_sock(po);
 		proto	= po->num;
 		addr	= NULL;
 	} else {
@@ -2084,7 +2096,6 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 		proto	= saddr->sll_protocol;
 		addr	= saddr->sll_addr;
 		dev = dev_get_by_index(sock_net(&po->sk), saddr->sll_ifindex);
-		need_rls_dev = true;
 	}
 
 	err = -ENXIO;
@@ -2094,7 +2105,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	reserve = dev->hard_header_len;
 
 	err = -ENETDOWN;
-	if (unlikely(!(dev->flags & IFF_UP)))
+	if (unlikely(!(dev->flags & IFF_UP) || !po->running))
 		goto out_put;
 
 	size_max = po->tx_ring.frame_size
@@ -2173,8 +2184,7 @@ out_status:
 	__packet_set_status(po, ph, status);
 	kfree_skb(skb);
 out_put:
-	if (need_rls_dev)
-		dev_put(dev);
+	dev_put(dev);
 out:
 	mutex_unlock(&po->pg_vec_lock);
 	return err;
@@ -2212,7 +2222,6 @@ static int packet_snd(struct socket *sock,
 	struct sk_buff *skb;
 	struct net_device *dev;
 	__be16 proto;
-	bool need_rls_dev = false;
 	unsigned char *addr;
 	int err, reserve = 0;
 	struct virtio_net_hdr vnet_hdr = { 0 };
@@ -2228,7 +2237,7 @@ static int packet_snd(struct socket *sock,
 	 */
 
 	if (saddr == NULL) {
-		dev = po->prot_hook.dev;
+		dev	= dev_get_packet_sock(po);
 		proto	= po->num;
 		addr	= NULL;
 	} else {
@@ -2240,7 +2249,6 @@ static int packet_snd(struct socket *sock,
 		proto	= saddr->sll_protocol;
 		addr	= saddr->sll_addr;
 		dev = dev_get_by_index(sock_net(sk), saddr->sll_ifindex);
-		need_rls_dev = true;
 	}
 
 	err = -ENXIO;
@@ -2250,7 +2258,7 @@ static int packet_snd(struct socket *sock,
 		reserve = dev->hard_header_len;
 
 	err = -ENETDOWN;
-	if (!(dev->flags & IFF_UP))
+	if (unlikely(!(dev->flags & IFF_UP) || !po->running))
 		goto out_unlock;
 
 	if (po->has_vnet_hdr) {
@@ -2386,15 +2394,14 @@ static int packet_snd(struct socket *sock,
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
1.8.3.1
