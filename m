From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: RCU locking for simple ioctl()
Date: Mon, 02 Nov 2009 06:42:09 +0100
Message-ID: <4AEE7131.601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42545 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544AbZKBFmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 00:42:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All ioctls() implemented by dev_ifsioc_locked() :
SIOCGIFFLAGS, SIOCGIFMETRIC, SIOCGIFMTU, SIOCGIFHWADDR,
SIOCGIFSLAVE, SIOCGIFMAP, SIOCGIFINDEX & SIOCGIFTXQLEN
can use RCU lock instead of dev_base_lock rwlock

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f54d8b8..c0f27ad 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4315,12 +4315,12 @@ int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
 EXPORT_SYMBOL(dev_set_mac_address);
 
 /*
- *	Perform the SIOCxIFxxx calls, inside read_lock(dev_base_lock)
+ *	Perform the SIOCxIFxxx calls, inside rcu_read_lock()
  */
 static int dev_ifsioc_locked(struct net *net, struct ifreq *ifr, unsigned int cmd)
 {
 	int err;
-	struct net_device *dev = __dev_get_by_name(net, ifr->ifr_name);
+	struct net_device *dev = dev_get_by_name_rcu(net, ifr->ifr_name);
 
 	if (!dev)
 		return -ENODEV;
@@ -4552,9 +4552,9 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	case SIOCGIFINDEX:
 	case SIOCGIFTXQLEN:
 		dev_load(net, ifr.ifr_name);
-		read_lock(&dev_base_lock);
+		rcu_read_lock();
 		ret = dev_ifsioc_locked(net, &ifr, cmd);
-		read_unlock(&dev_base_lock);
+		rcu_read_unlock();
 		if (!ret) {
 			if (colon)
 				*colon = ':';
