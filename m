From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 08/14] Phonet: receive path socket lookup
Date: Tue, 16 Sep 2008 18:08:08 +0300
Message-ID: <1221577694-4513-8-git-send-email-remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:52821 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753672AbYIPPI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 11:08:29 -0400
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8GF88JJ031631
	for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 18:08:26 +0300
In-Reply-To: <200809161757.38571.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This delivers received packet to the right socket, if any.

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/phonet.h |    1 +
 net/phonet/af_phonet.c      |   13 ++++++++++++-
 2 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index e0fa080..8e7e42d 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -35,6 +35,7 @@
  */
 struct pn_sock {
 	struct sock	sk;
+	int		(*handler)(struct sock *, struct sk_buff *);
 	u16		sobject;
 	u8		resource;
 };
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 12c72e1..317f30c 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -96,7 +96,9 @@ static int phonet_rcv(struct sk_buff *skb, struct net_device *dev,
 			struct net_device *orig_dev)
 {
 	struct phonethdr *ph;
+	struct sock *sk;
 	struct sockaddr_pn sa;
+	int err;
 	u16 len;
 
 	if (dev_net(dev) != &init_net)
@@ -120,7 +122,15 @@ static int phonet_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (pn_sockaddr_get_addr(&sa) == 0)
 		goto out; /* currently, we cannot be device 0 */
 
-	/* TODO: put packets to sockets backlog */
+	sk = pn_find_sock_by_sa(&sa);
+	if (sk == NULL)
+		goto out;
+
+	/* Push data to the socket (or other sockets connected to it). */
+	err = pn_sk(sk)->handler(sk, skb);
+	sock_put(sk);
+
+	return err ? NET_RX_DROP : NET_RX_SUCCESS;
 
 out:
 	kfree_skb(skb);
@@ -196,6 +206,7 @@ static int __init phonet_init(void)
 {
 	int err;
 
+	phonet_socket_init();
 	err = sock_register(&phonet_proto_family);
 	if (err) {
 		printk(KERN_ALERT
-- 
1.5.4.3

