From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next] ipv6: sr: fix IPv6 initialization failure without lwtunnels
Date: Thu, 10 Nov 2016 10:55:15 +0100
Message-ID: <1478771715-23137-1-git-send-email-david.lebrun@uclouvain.be>
References: <CAKD1Yr0fDFdDv9+S3i_rH6W6btEuvs9s-h33_N67iM4qrtDezQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <lorenzo@google.com>, <davem@davemloft.net>,
        David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:49394 "EHLO
        smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753562AbcKJJyU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 04:54:20 -0500
In-Reply-To: <CAKD1Yr0fDFdDv9+S3i_rH6W6btEuvs9s-h33_N67iM4qrtDezQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch compiles SR lwtunnels support only if CONFIG_LWTUNNEL=y.

If IPv6 is enabled and CONFIG_LWTUNNEL=n, then seg6_iptunnel_init()
fails with EOPNOTSUPP which in turn makes seg6_init() fail, blocking
the IPv6 initialization, with the following messages:

NET: Registered protocol family 10
IPv6: Attempt to unregister permanent protocol 6
IPv6: Attempt to unregister permanent protocol 136
IPv6: Attempt to unregister permanent protocol 17
NET: Unregistered protocol family 10

Fix commit 6c8702c60b88 ("ipv6: sr: add support for SRH encapsulation and injection with lwtunnels")

Tested with various combinations of CONFIG_IPV6 and CONFIG_LWTUNNEL.

Reported-by: Lorenzo Colitti <lorenzo@google.com>
Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/Kconfig  | 1 +
 net/ipv6/Makefile | 3 ++-
 net/ipv6/seg6.c   | 8 ++++++++
 3 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 0f00811..030cdb6 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -292,6 +292,7 @@ config IPV6_PIMSM_V2
 config IPV6_SEG6_INLINE
 	bool "IPv6: direct Segment Routing Header insertion "
 	depends on IPV6
+	depends on LWTUNNEL
 	---help---
 	  Support for direct insertion of the Segment Routing Header,
 	  also known as inline mode. Be aware that direct insertion of
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 129cad2..065c322 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -9,7 +9,7 @@ ipv6-objs :=	af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
 		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o udplite.o \
 		raw.o icmp.o mcast.o reassembly.o tcp_ipv6.o ping.o \
 		exthdrs.o datagram.o ip6_flowlabel.o inet6_connection_sock.o \
-		udp_offload.o seg6.o seg6_iptunnel.o
+		udp_offload.o seg6.o
 
 ipv6-offload :=	ip6_offload.o tcpv6_offload.o exthdrs_offload.o
 
@@ -45,6 +45,7 @@ obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
 obj-$(CONFIG_IPV6_GRE) += ip6_gre.o
 obj-$(CONFIG_IPV6_FOU) += fou6.o
 obj-$(CONFIG_IPV6_SEG6_HMAC) += seg6_hmac.o
+obj-$(CONFIG_LWTUNNEL) += seg6_iptunnel.o
 
 obj-y += addrconf_core.o exthdrs_core.o ip6_checksum.o ip6_icmp.o
 obj-$(CONFIG_INET) += output_core.o protocol.o $(ipv6-offload)
diff --git a/net/ipv6/seg6.c b/net/ipv6/seg6.c
index 50f6e06..0f74f90 100644
--- a/net/ipv6/seg6.c
+++ b/net/ipv6/seg6.c
@@ -451,9 +451,11 @@ int __init seg6_init(void)
 	if (err)
 		goto out_unregister_genl;
 
+#ifdef CONFIG_LWTUNNEL
 	err = seg6_iptunnel_init();
 	if (err)
 		goto out_unregister_pernet;
+#endif
 
 #ifdef CONFIG_IPV6_SEG6_HMAC
 	err = seg6_hmac_init();
@@ -467,10 +469,14 @@ int __init seg6_init(void)
 	return err;
 #ifdef CONFIG_IPV6_SEG6_HMAC
 out_unregister_iptun:
+#ifdef CONFIG_LWTUNNEL
 	seg6_iptunnel_exit();
 #endif
+#endif
+#ifdef CONFIG_LWTUNNEL
 out_unregister_pernet:
 	unregister_pernet_subsys(&ip6_segments_ops);
+#endif
 out_unregister_genl:
 	genl_unregister_family(&seg6_genl_family);
 	goto out;
@@ -481,7 +487,9 @@ void seg6_exit(void)
 #ifdef CONFIG_IPV6_SEG6_HMAC
 	seg6_hmac_exit();
 #endif
+#ifdef CONFIG_LWTUNNEL
 	seg6_iptunnel_exit();
+#endif
 	unregister_pernet_subsys(&ip6_segments_ops);
 	genl_unregister_family(&seg6_genl_family);
 }
-- 
2.7.3
