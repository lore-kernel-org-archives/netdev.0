From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] tunnels: fix netns vs proto registration ordering
Date: Tue, 16 Feb 2010 21:05:04 +0200
Message-ID: <20100216190504.GA4801@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, security@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f215.google.com ([209.85.220.215]:41858 "EHLO
	mail-fx0-f215.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932909Ab0BPTFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 14:05:08 -0500
Received: by fxm7 with SMTP id 7so7583942fxm.28
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2010 11:05:06 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same stuff as in ip_gre patch: receive hook can be called before netns
setup is done, oopsing in net_generic().

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/ipip.c         |   13 +++++------
 net/ipv6/ip6_tunnel.c   |   28 +++++++++++++-----------
 net/ipv6/sit.c          |   13 +++++------
 net/ipv6/xfrm6_tunnel.c |   55 +++++++++++++++++-------------------------------
 4 files changed, 47 insertions(+), 62 deletions(-)

--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -830,15 +830,14 @@ static int __init ipip_init(void)
 
 	printk(banner);
 
-	if (xfrm4_tunnel_register(&ipip_handler, AF_INET)) {
+	err = register_pernet_device(&ipip_net_ops);
+	if (err < 0)
+		return err;
+	err = xfrm4_tunnel_register(&ipip_handler, AF_INET);
+	if (err < 0) {
+		unregister_pernet_device(&ipip_net_ops);
 		printk(KERN_INFO "ipip init: can't register tunnel\n");
-		return -EAGAIN;
 	}
-
-	err = register_pernet_device(&ipip_net_ops);
-	if (err)
-		xfrm4_tunnel_deregister(&ipip_handler, AF_INET);
-
 	return err;
 }
 
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1461,27 +1461,29 @@ static int __init ip6_tunnel_init(void)
 {
 	int  err;
 
-	if (xfrm6_tunnel_register(&ip4ip6_handler, AF_INET)) {
+	err = register_pernet_device(&ip6_tnl_net_ops);
+	if (err < 0)
+		goto out_pernet;
+
+	err = xfrm6_tunnel_register(&ip4ip6_handler, AF_INET);
+	if (err < 0) {
 		printk(KERN_ERR "ip6_tunnel init: can't register ip4ip6\n");
-		err = -EAGAIN;
-		goto out;
+		goto out_ip4ip6;
 	}
 
-	if (xfrm6_tunnel_register(&ip6ip6_handler, AF_INET6)) {
+	err = xfrm6_tunnel_register(&ip6ip6_handler, AF_INET6);
+	if (err < 0) {
 		printk(KERN_ERR "ip6_tunnel init: can't register ip6ip6\n");
-		err = -EAGAIN;
-		goto unreg_ip4ip6;
+		goto out_ip6ip6;
 	}
 
-	err = register_pernet_device(&ip6_tnl_net_ops);
-	if (err < 0)
-		goto err_pernet;
 	return 0;
-err_pernet:
-	xfrm6_tunnel_deregister(&ip6ip6_handler, AF_INET6);
-unreg_ip4ip6:
+
+out_ip6ip6:
 	xfrm6_tunnel_deregister(&ip4ip6_handler, AF_INET);
-out:
+out_ip4ip6:
+	unregister_pernet_device(&ip6_tnl_net_ops);
+out_pernet:
 	return err;
 }
 
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1227,15 +1227,14 @@ static int __init sit_init(void)
 
 	printk(KERN_INFO "IPv6 over IPv4 tunneling driver\n");
 
-	if (xfrm4_tunnel_register(&sit_handler, AF_INET6) < 0) {
-		printk(KERN_INFO "sit init: Can't add protocol\n");
-		return -EAGAIN;
-	}
-
 	err = register_pernet_device(&sit_net_ops);
 	if (err < 0)
-		xfrm4_tunnel_deregister(&sit_handler, AF_INET6);
-
+		return err;
+	err = xfrm4_tunnel_register(&sit_handler, AF_INET6);
+	if (err < 0) {
+		unregister_pernet_device(&sit_net_ops);
+		printk(KERN_INFO "sit init: Can't add protocol\n");
+	}
 	return err;
 }
 
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -84,23 +84,6 @@ static inline unsigned xfrm6_tunnel_spi_hash_byspi(u32 spi)
 	return spi % XFRM6_TUNNEL_SPI_BYSPI_HSIZE;
 }
 
-
-static int __init xfrm6_tunnel_spi_init(void)
-{
-	xfrm6_tunnel_spi_kmem = kmem_cache_create("xfrm6_tunnel_spi",
-						  sizeof(struct xfrm6_tunnel_spi),
-						  0, SLAB_HWCACHE_ALIGN,
-						  NULL);
-	if (!xfrm6_tunnel_spi_kmem)
-		return -ENOMEM;
-	return 0;
-}
-
-static void xfrm6_tunnel_spi_fini(void)
-{
-	kmem_cache_destroy(xfrm6_tunnel_spi_kmem);
-}
-
 static struct xfrm6_tunnel_spi *__xfrm6_tunnel_spi_lookup(struct net *net, xfrm_address_t *saddr)
 {
 	struct xfrm6_tunnel_net *xfrm6_tn = xfrm6_tunnel_pernet(net);
@@ -375,42 +358,44 @@ static int __init xfrm6_tunnel_init(void)
 {
 	int rv;
 
+	xfrm6_tunnel_spi_kmem = kmem_cache_create("xfrm6_tunnel_spi",
+						  sizeof(struct xfrm6_tunnel_spi),
+						  0, SLAB_HWCACHE_ALIGN,
+						  NULL);
+	if (!xfrm6_tunnel_spi_kmem)
+		return -ENOMEM;
+	rv = register_pernet_subsys(&xfrm6_tunnel_net_ops);
+	if (rv < 0)
+		goto out_pernet;
 	rv = xfrm_register_type(&xfrm6_tunnel_type, AF_INET6);
 	if (rv < 0)
-		goto err;
+		goto out_type;
 	rv = xfrm6_tunnel_register(&xfrm6_tunnel_handler, AF_INET6);
 	if (rv < 0)
-		goto unreg;
+		goto out_xfrm6;
 	rv = xfrm6_tunnel_register(&xfrm46_tunnel_handler, AF_INET);
 	if (rv < 0)
-		goto dereg6;
-	rv = xfrm6_tunnel_spi_init();
-	if (rv < 0)
-		goto dereg46;
-	rv = register_pernet_subsys(&xfrm6_tunnel_net_ops);
-	if (rv < 0)
-		goto deregspi;
+		goto out_xfrm46;
 	return 0;
 
-deregspi:
-	xfrm6_tunnel_spi_fini();
-dereg46:
-	xfrm6_tunnel_deregister(&xfrm46_tunnel_handler, AF_INET);
-dereg6:
+out_xfrm46:
 	xfrm6_tunnel_deregister(&xfrm6_tunnel_handler, AF_INET6);
-unreg:
+out_xfrm6:
 	xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
-err:
+out_type:
+	unregister_pernet_subsys(&xfrm6_tunnel_net_ops);
+out_pernet:
+	kmem_cache_destroy(xfrm6_tunnel_spi_kmem);
 	return rv;
 }
 
 static void __exit xfrm6_tunnel_fini(void)
 {
-	unregister_pernet_subsys(&xfrm6_tunnel_net_ops);
-	xfrm6_tunnel_spi_fini();
 	xfrm6_tunnel_deregister(&xfrm46_tunnel_handler, AF_INET);
 	xfrm6_tunnel_deregister(&xfrm6_tunnel_handler, AF_INET6);
 	xfrm_unregister_type(&xfrm6_tunnel_type, AF_INET6);
+	unregister_pernet_subsys(&xfrm6_tunnel_net_ops);
+	kmem_cache_destroy(xfrm6_tunnel_spi_kmem);
 }
 
 module_init(xfrm6_tunnel_init);
