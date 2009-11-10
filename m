From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] RDMA/addr: Use appropriate locking with for_each_netdev()
Date: Tue, 10 Nov 2009 05:27:16 +0100
Message-ID: <4AF8EBA4.2070102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Roland Dreier <rolandd@cisco.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50795 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814AbZKJE1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 23:27:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


for_each_netdev() should be used with RTNL or dev_base_lock held,
or risk a crash.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/infiniband/core/addr.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index bd07803..5ca0b2c 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -131,6 +131,7 @@ int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_addr *dev_addr)
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
+		read_lock(&dev_base_lock);
 		for_each_netdev(&init_net, dev) {
 			if (ipv6_chk_addr(&init_net,
 					  &((struct sockaddr_in6 *) addr)->sin6_addr,
@@ -139,6 +140,7 @@ int rdma_translate_ip(struct sockaddr *addr, struct rdma_dev_addr *dev_addr)
 				break;
 			}
 		}
+		read_unlock(&dev_base_lock);
 		break;
 #endif
 	}
@@ -391,15 +393,17 @@ static int addr_resolve_local(struct sockaddr *src_in,
 	{
 		struct in6_addr *a;
 
+		read_lock(&dev_base_lock);
 		for_each_netdev(&init_net, dev)
 			if (ipv6_chk_addr(&init_net,
 					  &((struct sockaddr_in6 *) dst_in)->sin6_addr,
 					  dev, 1))
 				break;
 
-		if (!dev)
+		if (!dev) {
+			read_unlock(&dev_base_lock);
 			return -EADDRNOTAVAIL;
-
+		}
 		a = &((struct sockaddr_in6 *) src_in)->sin6_addr;
 
 		if (ipv6_addr_any(a)) {
@@ -416,6 +420,7 @@ static int addr_resolve_local(struct sockaddr *src_in,
 			if (!ret)
 				memcpy(addr->dst_dev_addr, dev->dev_addr, MAX_ADDR_LEN);
 		}
+		read_unlock(&dev_base_lock);
 		break;
 	}
 #endif
