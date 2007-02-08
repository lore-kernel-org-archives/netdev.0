From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC][5/6] changing ipv6 tunnel and xfrm6_tunnel to fit
 the API change
Date: Thu, 8 Feb 2007 17:04:17 +0900
Message-ID: <20070208170417.b216d7bb.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:52793 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1161545AbXBHIL1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 03:11:27 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

about xfrm6_tunnel, it is same as xfrm4_tunnel.

signed-off-by Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>

---
 net/ipv6/ip6_tunnel.c   |    6 +++---
 net/ipv6/xfrm6_tunnel.c |   12 +++++++++---
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 8d91834..850b72b 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1127,7 +1127,7 @@ static int __init ip6_tunnel_init(void)
 {
 	int  err;
 
-	if (xfrm6_tunnel_register(&ip6ip6_handler)) {
+	if (xfrm6_tunnel_register(&ip6ip6_handler, AF_INET6)) {
 		printk(KERN_ERR "ip6ip6 init: can't register tunnel\n");
 		return -EAGAIN;
 	}
@@ -1146,7 +1146,7 @@ static int __init ip6_tunnel_init(void)
 	}
 	return 0;
 fail:
-	xfrm6_tunnel_deregister(&ip6ip6_handler);
+	xfrm6_tunnel_deregister(&ip6ip6_handler, AF_INET6);
 	return err;
 }
 
@@ -1170,7 +1170,7 @@ static void __exit ip6ip6_destroy_tunnel
 
 static void __exit ip6_tunnel_cleanup(void)
 {
-	if (xfrm6_tunnel_deregister(&ip6ip6_handler))
+	if (xfrm6_tunnel_deregister(&ip6ip6_handler, AF_INET6))
 		printk(KERN_INFO "ip6ip6 close: can't deregister tunnel\n");
 
 	rtnl_lock();
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 12e426b..be31995 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -344,12 +344,17 @@ static int __init xfrm6_tunnel_init(void
 	if (xfrm_register_type(&xfrm6_tunnel_type, AF_INET6) < 0)
 		return -EAGAIN;
 
-	if (xfrm6_tunnel_register(&xfrm6_tunnel_handler)) {
+	if (xfrm6_tunnel_register(&xfrm6_tunnel_handler, AF_INET6)) {
+		xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
+		return -EAGAIN;
+	}
+	if (xfrm6_tunnel_register(&xfrm6_tunnel_handler, AF_INET)) {
 		xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
 		return -EAGAIN;
 	}
 	if (xfrm6_tunnel_spi_init() < 0) {
-		xfrm6_tunnel_deregister(&xfrm6_tunnel_handler);
+		xfrm6_tunnel_deregister(&xfrm6_tunnel_handler, AF_INET);
+		xfrm6_tunnel_deregister(&xfrm6_tunnel_handler, AF_INET6);
 		xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
 		return -EAGAIN;
 	}
@@ -359,7 +364,8 @@ static int __init xfrm6_tunnel_init(void
 static void __exit xfrm6_tunnel_fini(void)
 {
 	xfrm6_tunnel_spi_fini();
-	xfrm6_tunnel_deregister(&xfrm6_tunnel_handler);
+	xfrm6_tunnel_deregister(&xfrm6_tunnel_handler, AF_INET);
+	xfrm6_tunnel_deregister(&xfrm6_tunnel_handler, AF_INET6);
 	xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
 }
 
-- 
1.4.1

