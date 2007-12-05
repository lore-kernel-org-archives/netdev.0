From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 1/3][ARP] Minus one level of indentation in arp_req_set
Date: Wed, 05 Dec 2007 20:15:02 +0300
Message-ID: <4756DC96.7050700@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56695 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751964AbXLERPM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 12:15:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ATF_PUBL requests are handled completely separate from
the others. Emphasize it with a separate function. This also
reduces the indentation level.

The same issue exists with the arp_delete_request, but
when I tried to make it in one patch diff produced completely
unreadable patch. So I split it into two, but they may be 
done with one commit.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index b3f366a..d628e6e 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -953,37 +953,45 @@ out_of_mem:
  *	Set (create) an ARP cache entry.
  */
 
+static int arp_req_set_public(struct arpreq *r, struct net_device *dev)
+{
+	__be32 ip = ((struct sockaddr_in *)&r->arp_pa)->sin_addr.s_addr;
+	__be32 mask = ((struct sockaddr_in *)&r->arp_netmask)->sin_addr.s_addr;
+
+	if (mask && mask != htonl(0xFFFFFFFF))
+		return -EINVAL;
+	if (!dev && (r->arp_flags & ATF_COM)) {
+		dev = dev_getbyhwaddr(&init_net, r->arp_ha.sa_family,
+				r->arp_ha.sa_data);
+		if (!dev)
+			return -ENODEV;
+	}
+	if (mask) {
+		if (pneigh_lookup(&arp_tbl, &ip, dev, 1) == NULL)
+			return -ENOBUFS;
+		return 0;
+	}
+	if (dev == NULL) {
+		IPV4_DEVCONF_ALL(PROXY_ARP) = 1;
+		return 0;
+	}
+	if (__in_dev_get_rtnl(dev)) {
+		IN_DEV_CONF_SET(__in_dev_get_rtnl(dev), PROXY_ARP, 1);
+		return 0;
+	}
+	return -ENXIO;
+}
+
 static int arp_req_set(struct arpreq *r, struct net_device * dev)
 {
-	__be32 ip = ((struct sockaddr_in *) &r->arp_pa)->sin_addr.s_addr;
+	__be32 ip;
 	struct neighbour *neigh;
 	int err;
 
-	if (r->arp_flags&ATF_PUBL) {
-		__be32 mask = ((struct sockaddr_in *) &r->arp_netmask)->sin_addr.s_addr;
-		if (mask && mask != htonl(0xFFFFFFFF))
-			return -EINVAL;
-		if (!dev && (r->arp_flags & ATF_COM)) {
-			dev = dev_getbyhwaddr(&init_net, r->arp_ha.sa_family, r->arp_ha.sa_data);
-			if (!dev)
-				return -ENODEV;
-		}
-		if (mask) {
-			if (pneigh_lookup(&arp_tbl, &ip, dev, 1) == NULL)
-				return -ENOBUFS;
-			return 0;
-		}
-		if (dev == NULL) {
-			IPV4_DEVCONF_ALL(PROXY_ARP) = 1;
-			return 0;
-		}
-		if (__in_dev_get_rtnl(dev)) {
-			IN_DEV_CONF_SET(__in_dev_get_rtnl(dev), PROXY_ARP, 1);
-			return 0;
-		}
-		return -ENXIO;
-	}
+	if (r->arp_flags & ATF_PUBL)
+		return arp_req_set_public(r, dev);
 
+	ip = ((struct sockaddr_in *)&r->arp_pa)->sin_addr.s_addr;
 	if (r->arp_flags & ATF_PERM)
 		r->arp_flags |= ATF_COM;
 	if (dev == NULL) {
-- 
1.5.3.4

