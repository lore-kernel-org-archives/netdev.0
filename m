From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] gre_offload: statically build GRE offloading
 support
Date: Mon, 06 Jan 2014 14:03:07 -0800
Message-ID: <1389045787.26646.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1388896679-23152-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, ogerlitz@mellanox.com,
	netdev@vger.kernel.org
To: "H.K. Jerry Chu" <hkchu@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f41.google.com ([209.85.128.41]:61732 "EHLO
	mail-qe0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756268AbaAFWDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 17:03:11 -0500
Received: by mail-qe0-f41.google.com with SMTP id gh4so19587233qeb.0
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 14:03:10 -0800 (PST)
In-Reply-To: <1388896679-23152-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

GRO/GSO layers can be enabled on a node, even if said
node is only forwarding packets.

This patch permits GSO (and upcoming GRO) support for GRE
encapsulated packets, even if the host has no GRE tunnel setup.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: H.K. Jerry Chu <hkchu@google.com>
---
Note : We probably can remove EXPORT_SYMBOL() on inet_add_offload()
and inet_del_protocol() on a followup patch if there is interest.

 include/net/gre.h      |    3 ---
 net/ipv4/Makefile      |    4 ++--
 net/ipv4/gre_demux.c   |    9 ---------
 net/ipv4/gre_offload.c |    7 +++++--
 4 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index dcd9ae3270d3..70046a0b0b89 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -33,9 +33,6 @@ struct gre_cisco_protocol {
 int gre_cisco_register(struct gre_cisco_protocol *proto);
 int gre_cisco_unregister(struct gre_cisco_protocol *proto);
 
-int gre_offload_init(void);
-void gre_offload_exit(void);
-
 void gre_build_header(struct sk_buff *skb, const struct tnl_ptk_info *tpi,
 		      int hdr_len);
 
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 4b81e91c80fe..f8c49ce5b283 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -11,7 +11,7 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     tcp_offload.o datagram.o raw.o udp.o udplite.o \
 	     udp_offload.o arp.o icmp.o devinet.o af_inet.o igmp.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
-	     inet_fragment.o ping.o ip_tunnel_core.o
+	     inet_fragment.o ping.o ip_tunnel_core.o gre_offload.o
 
 obj-$(CONFIG_NET_IP_TUNNEL) += ip_tunnel.o
 obj-$(CONFIG_SYSCTL) += sysctl_net_ipv4.o
@@ -19,7 +19,7 @@ obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
 obj-$(CONFIG_IP_MROUTE) += ipmr.o
 obj-$(CONFIG_NET_IPIP) += ipip.o
-gre-y := gre_demux.o gre_offload.o
+gre-y := gre_demux.o
 obj-$(CONFIG_NET_IPGRE_DEMUX) += gre.o
 obj-$(CONFIG_NET_IPGRE) += ip_gre.o
 obj-$(CONFIG_NET_IPVTI) += ip_vti.o
diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 5893e99e8299..1863422fb7d5 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -355,14 +355,7 @@ static int __init gre_init(void)
 		goto err_gre;
 	}
 
-	if (gre_offload_init()) {
-		pr_err("can't add protocol offload\n");
-		goto err_gso;
-	}
-
 	return 0;
-err_gso:
-	gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO);
 err_gre:
 	inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
 err:
@@ -371,8 +364,6 @@ err:
 
 static void __exit gre_exit(void)
 {
-	gre_offload_exit();
-
 	gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO);
 	inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
 }
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index e5d436188464..a26e6fbf79be 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -120,12 +120,15 @@ static const struct net_offload gre_offload = {
 	},
 };
 
-int __init gre_offload_init(void)
+static int __init gre_offload_init(void)
 {
 	return inet_add_offload(&gre_offload, IPPROTO_GRE);
 }
 
-void __exit gre_offload_exit(void)
+static void __exit gre_offload_exit(void)
 {
 	inet_del_offload(&gre_offload, IPPROTO_GRE);
 }
+
+module_init(gre_offload_init);
+module_exit(gre_offload_exit);
