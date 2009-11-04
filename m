From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: sock_bindtodevice() RCU-ification
Date: Wed, 04 Nov 2009 23:36:44 +0100
Message-ID: <4AF201FC.3040908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37156 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758341AbZKDWgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 17:36:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid dev_hold()/dev_put() in sock_bindtodevice()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/sock.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 5a51512..38820ea 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -420,14 +420,16 @@ static int sock_bindtodevice(struct sock *sk, char __user *optval, int optlen)
 	if (devname[0] == '\0') {
 		index = 0;
 	} else {
-		struct net_device *dev = dev_get_by_name(net, devname);
+		struct net_device *dev;
 
+		rcu_read_lock();
+		dev = dev_get_by_name_rcu(net, devname);
+		if (dev)
+			index = dev->ifindex;
+		rcu_read_unlock();
 		ret = -ENODEV;
 		if (!dev)
 			goto out;
-
-		index = dev->ifindex;
-		dev_put(dev);
 	}
 
 	lock_sock(sk);
