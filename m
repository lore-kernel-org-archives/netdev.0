From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] RDMA/addr: remove dev_base_lock use from
 rdma_translate_ip()
Date: Fri, 29 Oct 2010 13:03:46 +0200
Message-ID: <1288350226.2560.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Roland Dreier <rolandd@cisco.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	linux-rdma@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60455 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761341Ab0J2LDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 07:03:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_base_lock is the legacy way to lock the device list, and is planned
to disappear. (writers hold RTNL, readers hold RCU lock)

Convert rdma_translate_ip() to RCU locking.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/infiniband/core/addr.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index a5ea1bc..309b477 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -130,8 +130,8 @@ int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_addr *dev_addr)
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
-		read_lock(&dev_base_lock);
-		for_each_netdev(&init_net, dev) {
+		rcu_read_lock();
+		for_each_netdev_rcu(&init_net, dev) {
 			if (ipv6_chk_addr(&init_net,
 					  &((struct sockaddr_in6 *) addr)->sin6_addr,
 					  dev, 1)) {
@@ -139,7 +139,7 @@ int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_addr *dev_addr)
 				break;
 			}
 		}
-		read_unlock(&dev_base_lock);
+		rcu_read_unlock();
 		break;
 #endif
 	}


