From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 2/3][ARP] Minus one level of ndentation in arp_req_delete
Date: Wed, 05 Dec 2007 20:16:48 +0300
Message-ID: <4756DD00.5030402@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56815 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751988AbXLERQ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 12:16:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The same cleanup for deletion requests.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index d628e6e..0a3f00c 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1075,32 +1075,39 @@ static int arp_req_get(struct arpreq *r, struct net_device *dev)
 	return err;
 }
 
+static int arp_req_delete_public(struct arpreq *r, struct net_device *dev)
+{
+	__be32 ip = ((struct sockaddr_in *) &r->arp_pa)->sin_addr.s_addr;
+	__be32 mask = ((struct sockaddr_in *)&r->arp_netmask)->sin_addr.s_addr;
+
+	if (mask == htonl(0xFFFFFFFF))
+		return pneigh_delete(&arp_tbl, &ip, dev);
+
+	if (mask == 0) {
+		if (dev == NULL) {
+			IPV4_DEVCONF_ALL(PROXY_ARP) = 0;
+			return 0;
+		}
+		if (__in_dev_get_rtnl(dev)) {
+			IN_DEV_CONF_SET(__in_dev_get_rtnl(dev),
+					PROXY_ARP, 0);
+			return 0;
+		}
+		return -ENXIO;
+	}
+	return -EINVAL;
+}
+
 static int arp_req_delete(struct arpreq *r, struct net_device * dev)
 {
 	int err;
-	__be32 ip = ((struct sockaddr_in *)&r->arp_pa)->sin_addr.s_addr;
+	__be32 ip;
 	struct neighbour *neigh;
 
-	if (r->arp_flags & ATF_PUBL) {
-		__be32 mask =
-		       ((struct sockaddr_in *)&r->arp_netmask)->sin_addr.s_addr;
-		if (mask == htonl(0xFFFFFFFF))
-			return pneigh_delete(&arp_tbl, &ip, dev);
-		if (mask == 0) {
-			if (dev == NULL) {
-				IPV4_DEVCONF_ALL(PROXY_ARP) = 0;
-				return 0;
-			}
-			if (__in_dev_get_rtnl(dev)) {
-				IN_DEV_CONF_SET(__in_dev_get_rtnl(dev),
-						PROXY_ARP, 0);
-				return 0;
-			}
-			return -ENXIO;
-		}
-		return -EINVAL;
-	}
+	if (r->arp_flags & ATF_PUBL)
+		return arp_req_delete_public(r, dev);
 
+	ip = ((struct sockaddr_in *)&r->arp_pa)->sin_addr.s_addr;
 	if (dev == NULL) {
 		struct flowi fl = { .nl_u = { .ip4_u = { .daddr = ip,
 							 .tos = RTO_ONLINK } } };
-- 
1.5.3.4

