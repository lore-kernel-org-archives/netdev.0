From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 3/3][ARP] Consolidate some code in arp_req_set/delete_publc
Date: Wed, 05 Dec 2007 20:18:44 +0300
Message-ID: <4756DD74.4090304@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:42160 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751063AbXLERSx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 12:18:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PROXY_ARP is set on devconfigs in a similar way in
both calls.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 0a3f00c..ccd36fa 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -953,6 +953,19 @@ out_of_mem:
  *	Set (create) an ARP cache entry.
  */
 
+static int arp_req_set_proxy(struct net_device *dev, int on)
+{
+	if (dev == NULL) {
+		IPV4_DEVCONF_ALL(PROXY_ARP) = on;
+		return 0;
+	}
+	if (__in_dev_get_rtnl(dev)) {
+		IN_DEV_CONF_SET(__in_dev_get_rtnl(dev), PROXY_ARP, on);
+		return 0;
+	}
+	return -ENXIO;
+}
+
 static int arp_req_set_public(struct arpreq *r, struct net_device *dev)
 {
 	__be32 ip = ((struct sockaddr_in *)&r->arp_pa)->sin_addr.s_addr;
@@ -971,15 +984,8 @@ static int arp_req_set_public(struct arpreq *r, struct net_device *dev)
 			return -ENOBUFS;
 		return 0;
 	}
-	if (dev == NULL) {
-		IPV4_DEVCONF_ALL(PROXY_ARP) = 1;
-		return 0;
-	}
-	if (__in_dev_get_rtnl(dev)) {
-		IN_DEV_CONF_SET(__in_dev_get_rtnl(dev), PROXY_ARP, 1);
-		return 0;
-	}
-	return -ENXIO;
+
+	return arp_req_set_proxy(dev, 1);
 }
 
 static int arp_req_set(struct arpreq *r, struct net_device * dev)
@@ -1083,19 +1089,10 @@ static int arp_req_delete_public(struct arpreq *r, struct net_device *dev)
 	if (mask == htonl(0xFFFFFFFF))
 		return pneigh_delete(&arp_tbl, &ip, dev);
 
-	if (mask == 0) {
-		if (dev == NULL) {
-			IPV4_DEVCONF_ALL(PROXY_ARP) = 0;
-			return 0;
-		}
-		if (__in_dev_get_rtnl(dev)) {
-			IN_DEV_CONF_SET(__in_dev_get_rtnl(dev),
-					PROXY_ARP, 0);
-			return 0;
-		}
-		return -ENXIO;
-	}
-	return -EINVAL;
+	if (mask)
+		return -EINVAL;
+
+	return arp_req_set_proxy(dev, 0);
 }
 
 static int arp_req_delete(struct arpreq *r, struct net_device * dev)
-- 
1.5.3.4

