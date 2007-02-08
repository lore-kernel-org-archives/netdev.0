From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC][4/6] changing "ipip tunnel" and xfrm4_tunnel to the
 API change
Date: Thu, 8 Feb 2007 17:04:12 +0900
Message-ID: <20070208170412.2e627947.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:41276 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1161541AbXBHIL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 03:11:27 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changing ipip tunnel and xfrm4_tunnel to the API

xfrm4_tunnel should regitser against both addresses so that
it should handle a tunnel packet whose internal address is
either IPv4 or IPv6.

signed-off-by Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>

---
 net/ipv4/ipip.c         |    6 +++---
 net/ipv4/xfrm4_tunnel.c |   14 +++++++++-----
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 9d719d6..775e950 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -870,7 +870,7 @@ static int __init ipip_init(void)
 
 	printk(banner);
 
-	if (xfrm4_tunnel_register(&ipip_handler)) {
+	if (xfrm4_tunnel_register(&ipip_handler, AF_INET)) {
 		printk(KERN_INFO "ipip init: can't register tunnel\n");
 		return -EAGAIN;
 	}
@@ -892,7 +892,7 @@ static int __init ipip_init(void)
  err2:
 	free_netdev(ipip_fb_tunnel_dev);
  err1:
-	xfrm4_tunnel_deregister(&ipip_handler);
+	xfrm4_tunnel_deregister(&ipip_handler, AF_INET);
 	goto out;
 }
 
@@ -912,7 +912,7 @@ static void __exit ipip_destroy_tunnels(
 
 static void __exit ipip_fini(void)
 {
-	if (xfrm4_tunnel_deregister(&ipip_handler))
+	if (xfrm4_tunnel_deregister(&ipip_handler, AF_INET))
 		printk(KERN_INFO "ipip close: can't deregister tunnel\n");
 
 	rtnl_lock();
diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c
index f110af5..00fc09f 100644
--- a/net/ipv4/xfrm4_tunnel.c
+++ b/net/ipv4/xfrm4_tunnel.c
@@ -66,12 +66,15 @@ static struct xfrm_tunnel xfrm_tunnel_ha
 
 static int __init ipip_init(void)
 {
-	if (xfrm_register_type(&ipip_type, AF_INET) < 0) {
-		printk(KERN_INFO "ipip init: can't add xfrm type\n");
+	if (xfrm_register_type(&ipip_type, AF_INET) < 0)
+		return -EAGAIN;
+
+	if (xfrm4_tunnel_register(&xfrm_tunnel_handler, AF_INET)) {
+		printk(KERN_INFO "ipip init: can't add xfrm handler for AF_INET\n");
 		return -EAGAIN;
 	}
-	if (xfrm4_tunnel_register(&xfrm_tunnel_handler)) {
-		printk(KERN_INFO "ipip init: can't add xfrm handler\n");
+	if (xfrm4_tunnel_register(&xfrm_tunnel_handler, AF_INET6)) {
+		printk(KERN_INFO "ipip init: can't add xfrm handler for AF_INET6\n");
 		xfrm_unregister_type(&ipip_type, AF_INET);
 		return -EAGAIN;
 	}
@@ -80,7 +83,8 @@ static int __init ipip_init(void)
 
 static void __exit ipip_fini(void)
 {
-	if (xfrm4_tunnel_deregister(&xfrm_tunnel_handler))
+	if (xfrm4_tunnel_deregister(&xfrm_tunnel_handler, AF_INET) ||
+	    xfrm4_tunnel_deregister(&xfrm_tunnel_handler, AF_INET6))
 		printk(KERN_INFO "ipip close: can't remove xfrm handler\n");
 	if (xfrm_unregister_type(&ipip_type, AF_INET) < 0)
 		printk(KERN_INFO "ipip close: can't remove xfrm type\n");
-- 
1.4.1

