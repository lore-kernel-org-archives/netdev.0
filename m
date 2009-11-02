From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] packet: less dev_put() calls
Date: Mon, 02 Nov 2009 10:43:32 +0100
Message-ID: <4AEEA9C4.6040305@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44218 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754105AbZKBJna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 04:43:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- packet_sendmsg_spkt() can use dev_get_by_name_rcu() to avoid touching device refcount.

- packet_getname_spkt() & packet_getname() can use dev_get_by_index_rcu() to
  avoid touching device refcount too.

tpacket_snd() & packet_snd() can not use RCU yet because they can sleep when
allocating skb.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/packet/af_packet.c |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 95ef64e..91d246d 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -437,7 +437,8 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 	 */
 
 	saddr->spkt_device[13] = 0;
-	dev = dev_get_by_name(sock_net(sk), saddr->spkt_device);
+	rcu_read_lock();
+	dev = dev_get_by_name_rcu(sock_net(sk), saddr->spkt_device);
 	err = -ENODEV;
 	if (dev == NULL)
 		goto out_unlock;
@@ -500,14 +501,13 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 	 */
 
 	dev_queue_xmit(skb);
-	dev_put(dev);
+	rcu_read_unlock();
 	return len;
 
 out_free:
 	kfree_skb(skb);
 out_unlock:
-	if (dev)
-		dev_put(dev);
+	rcu_read_unlock();
 	return err;
 }
 
@@ -1518,12 +1518,13 @@ static int packet_getname_spkt(struct socket *sock, struct sockaddr *uaddr,
 		return -EOPNOTSUPP;
 
 	uaddr->sa_family = AF_PACKET;
-	dev = dev_get_by_index(sock_net(sk), pkt_sk(sk)->ifindex);
-	if (dev) {
+	rcu_read_lock();
+	dev = dev_get_by_index_rcu(sock_net(sk), pkt_sk(sk)->ifindex);
+	if (dev)
 		strlcpy(uaddr->sa_data, dev->name, 15);
-		dev_put(dev);
-	} else
+	else
 		memset(uaddr->sa_data, 0, 14);
+	rcu_read_unlock();
 	*uaddr_len = sizeof(*uaddr);
 
 	return 0;
@@ -1543,16 +1544,17 @@ static int packet_getname(struct socket *sock, struct sockaddr *uaddr,
 	sll->sll_family = AF_PACKET;
 	sll->sll_ifindex = po->ifindex;
 	sll->sll_protocol = po->num;
-	dev = dev_get_by_index(sock_net(sk), po->ifindex);
+	rcu_read_lock();
+	dev = dev_get_by_index_rcu(sock_net(sk), po->ifindex);
 	if (dev) {
 		sll->sll_hatype = dev->type;
 		sll->sll_halen = dev->addr_len;
 		memcpy(sll->sll_addr, dev->dev_addr, dev->addr_len);
-		dev_put(dev);
 	} else {
 		sll->sll_hatype = 0;	/* Bad: we have no ARPHRD_UNSPEC */
 		sll->sll_halen = 0;
 	}
+	rcu_read_unlock();
 	*uaddr_len = offsetof(struct sockaddr_ll, sll_addr) + sll->sll_halen;
 
 	return 0;
