From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/19] netfilter: tproxy: remove nf_tproxy_core, keep tw sk assigned to skb
Date: Tue, 20 Aug 2013 12:54:38 +0200
Message-ID: <1376996091-3964-7-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60078 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751062Ab3HTKzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 06:55:09 -0400
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

The module was "permanent", due to the special tproxy skb->destructor.
Nowadays we have tcp early demux and its sock_edemux destructor in
networking core which can be used instead.

Thanks to early demux changes the input path now also handles
"skb->sk is tw socket" correctly, so this no longer needs the special
handling introduced with commit d503b30bd648b3cb4e5f50b65d27e389960cc6d9
(netfilter: tproxy: do not assign timewait sockets to skb->sk).

Thus:
- move assign_sock function to where its needed
- don't prevent timewait sockets from being assigned to the skb
- remove nf_tproxy_core.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 Documentation/networking/tproxy.txt    |    5 ++-
 include/net/netfilter/nf_tproxy_core.h |    4 ---
 net/netfilter/Kconfig                  |   22 +++---------
 net/netfilter/Makefile                 |    3 --
 net/netfilter/nf_tproxy_core.c         |   62 --------------------------------
 net/netfilter/xt_TPROXY.c              |    9 +++++
 6 files changed, 16 insertions(+), 89 deletions(-)
 delete mode 100644 net/netfilter/nf_tproxy_core.c

diff --git a/Documentation/networking/tproxy.txt b/Documentation/networking/tproxy.txt
index 7b5996d..ec11429 100644
--- a/Documentation/networking/tproxy.txt
+++ b/Documentation/networking/tproxy.txt
@@ -2,9 +2,8 @@ Transparent proxy support
 =========================
 
 This feature adds Linux 2.2-like transparent proxy support to current kernels.
-To use it, enable NETFILTER_TPROXY, the socket match and the TPROXY target in
-your kernel config. You will need policy routing too, so be sure to enable that
-as well.
+To use it, enable the socket match and the TPROXY target in your kernel config.
+You will need policy routing too, so be sure to enable that as well.
 
 
 1. Making non-local sockets work
diff --git a/include/net/netfilter/nf_tproxy_core.h b/include/net/netfilter/nf_tproxy_core.h
index 36d9379..975ffa4 100644
--- a/include/net/netfilter/nf_tproxy_core.h
+++ b/include/net/netfilter/nf_tproxy_core.h
@@ -203,8 +203,4 @@ nf_tproxy_get_sock_v6(struct net *net, const u8 protocol,
 }
 #endif
 
-/* assign a socket to the skb -- consumes sk */
-void
-nf_tproxy_assign_sock(struct sk_buff *skb, struct sock *sk);
-
 #endif
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 56d22ca..c45fc1a 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -410,20 +410,6 @@ config NF_NAT_TFTP
 
 endif # NF_CONNTRACK
 
-# transparent proxy support
-config NETFILTER_TPROXY
-	tristate "Transparent proxying support"
-	depends on IP_NF_MANGLE
-	depends on NETFILTER_ADVANCED
-	help
-	  This option enables transparent proxying support, that is,
-	  support for handling non-locally bound IPv4 TCP and UDP sockets.
-	  For it to work you will have to configure certain iptables rules
-	  and use policy routing. For more information on how to set it up
-	  see Documentation/networking/tproxy.txt.
-
-	  To compile it as a module, choose M here.  If unsure, say N.
-
 config NETFILTER_XTABLES
 	tristate "Netfilter Xtables support (required for ip_tables)"
 	default m if NETFILTER_ADVANCED=n
@@ -720,10 +706,10 @@ config NETFILTER_XT_TARGET_TEE
 	this clone be rerouted to another nexthop.
 
 config NETFILTER_XT_TARGET_TPROXY
-	tristate '"TPROXY" target support'
-	depends on NETFILTER_TPROXY
+	tristate '"TPROXY" target transparent proxying support'
 	depends on NETFILTER_XTABLES
 	depends on NETFILTER_ADVANCED
+	depends on IP_NF_MANGLE
 	select NF_DEFRAG_IPV4
 	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
 	help
@@ -731,6 +717,9 @@ config NETFILTER_XT_TARGET_TPROXY
 	  REDIRECT.  It can only be used in the mangle table and is useful
 	  to redirect traffic to a transparent proxy.  It does _not_ depend
 	  on Netfilter connection tracking and NAT, unlike REDIRECT.
+	  For it to work you will have to configure certain iptables rules
+	  and use policy routing. For more information on how to set it up
+	  see Documentation/networking/tproxy.txt.
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
@@ -1180,7 +1169,6 @@ config NETFILTER_XT_MATCH_SCTP
 
 config NETFILTER_XT_MATCH_SOCKET
 	tristate '"socket" match support'
-	depends on NETFILTER_TPROXY
 	depends on NETFILTER_XTABLES
 	depends on NETFILTER_ADVANCED
 	depends on !NF_CONNTRACK || NF_CONNTRACK
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index a1abf87..ebfa7dc 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -61,9 +61,6 @@ obj-$(CONFIG_NF_NAT_IRC) += nf_nat_irc.o
 obj-$(CONFIG_NF_NAT_SIP) += nf_nat_sip.o
 obj-$(CONFIG_NF_NAT_TFTP) += nf_nat_tftp.o
 
-# transparent proxy support
-obj-$(CONFIG_NETFILTER_TPROXY) += nf_tproxy_core.o
-
 # generic X tables 
 obj-$(CONFIG_NETFILTER_XTABLES) += x_tables.o xt_tcpudp.o
 
diff --git a/net/netfilter/nf_tproxy_core.c b/net/netfilter/nf_tproxy_core.c
deleted file mode 100644
index 474d621..0000000
--- a/net/netfilter/nf_tproxy_core.c
+++ /dev/null
@@ -1,62 +0,0 @@
-/*
- * Transparent proxy support for Linux/iptables
- *
- * Copyright (c) 2006-2007 BalaBit IT Ltd.
- * Author: Balazs Scheidler, Krisztian Kovacs
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- *
- */
-
-#include <linux/module.h>
-
-#include <linux/net.h>
-#include <linux/if.h>
-#include <linux/netdevice.h>
-#include <net/udp.h>
-#include <net/netfilter/nf_tproxy_core.h>
-
-
-static void
-nf_tproxy_destructor(struct sk_buff *skb)
-{
-	struct sock *sk = skb->sk;
-
-	skb->sk = NULL;
-	skb->destructor = NULL;
-
-	if (sk)
-		sock_put(sk);
-}
-
-/* consumes sk */
-void
-nf_tproxy_assign_sock(struct sk_buff *skb, struct sock *sk)
-{
-	/* assigning tw sockets complicates things; most
-	 * skb->sk->X checks would have to test sk->sk_state first */
-	if (sk->sk_state == TCP_TIME_WAIT) {
-		inet_twsk_put(inet_twsk(sk));
-		return;
-	}
-
-	skb_orphan(skb);
-	skb->sk = sk;
-	skb->destructor = nf_tproxy_destructor;
-}
-EXPORT_SYMBOL_GPL(nf_tproxy_assign_sock);
-
-static int __init nf_tproxy_init(void)
-{
-	pr_info("NF_TPROXY: Transparent proxy support initialized, version 4.1.0\n");
-	pr_info("NF_TPROXY: Copyright (c) 2006-2007 BalaBit IT Ltd.\n");
-	return 0;
-}
-
-module_init(nf_tproxy_init);
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Krisztian Kovacs");
-MODULE_DESCRIPTION("Transparent proxy support core routines");
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index d7f1953..17c40de 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -117,6 +117,15 @@ tproxy_handle_time_wait4(struct sk_buff *skb, __be32 laddr, __be16 lport,
 	return sk;
 }
 
+/* assign a socket to the skb -- consumes sk */
+static void
+nf_tproxy_assign_sock(struct sk_buff *skb, struct sock *sk)
+{
+	skb_orphan(skb);
+	skb->sk = sk;
+	skb->destructor = sock_edemux;
+}
+
 static unsigned int
 tproxy_tg4(struct sk_buff *skb, __be32 laddr, __be16 lport,
 	   u_int32_t mark_mask, u_int32_t mark_value)
-- 
1.7.10.4
