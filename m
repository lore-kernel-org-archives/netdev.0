From: greearb@candelatech.com
Subject: [PATCH 1/2] af-packet:  Hold reference to bound network devices.
Date: Wed,  1 Jun 2011 10:18:52 -0700
Message-ID: <1306948733-22441-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35504 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759257Ab1FARTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 13:19:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Old code was probably safe, but with this change we
can actually use the netdev object, not just compare
the pointer values.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 f7250d5... 614d659... M	net/packet/af_packet.c
 net/packet/af_packet.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index f7250d5..614d659 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1377,6 +1377,10 @@ static int packet_release(struct socket *sock)
 		__dev_remove_pack(&po->prot_hook);
 		__sock_put(sk);
 	}
+	if (po->prot_hook.dev) {
+		dev_put(po->prot_hook.dev);
+		po->prot_hook.dev = NULL;
+	}
 	spin_unlock(&po->bind_lock);
 
 	packet_flush_mclist(sk);
@@ -1430,6 +1434,8 @@ static int packet_do_bind(struct sock *sk, struct net_device *dev, __be16 protoc
 
 	po->num = protocol;
 	po->prot_hook.type = protocol;
+	if (po->prot_hook.dev)
+		dev_put(po->prot_hook.dev);
 	po->prot_hook.dev = dev;
 
 	po->ifindex = dev ? dev->ifindex : 0;
@@ -1474,10 +1480,8 @@ static int packet_bind_spkt(struct socket *sock, struct sockaddr *uaddr,
 	strlcpy(name, uaddr->sa_data, sizeof(name));
 
 	dev = dev_get_by_name(sock_net(sk), name);
-	if (dev) {
+	if (dev)
 		err = packet_do_bind(sk, dev, pkt_sk(sk)->num);
-		dev_put(dev);
-	}
 	return err;
 }
 
@@ -1505,8 +1509,6 @@ static int packet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len
 			goto out;
 	}
 	err = packet_do_bind(sk, dev, sll->sll_protocol ? : pkt_sk(sk)->num);
-	if (dev)
-		dev_put(dev);
 
 out:
 	return err;
@@ -2275,6 +2277,8 @@ static int packet_notifier(struct notifier_block *this, unsigned long msg, void
 				}
 				if (msg == NETDEV_UNREGISTER) {
 					po->ifindex = -1;
+					if (po->prot_hook.dev)
+						dev_put(po->prot_hook.dev);
 					po->prot_hook.dev = NULL;
 				}
 				spin_unlock(&po->bind_lock);
-- 
1.7.3.4

