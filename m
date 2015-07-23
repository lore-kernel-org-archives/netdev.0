From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] ip_tunnel: Call ip_tunnel_core_init() from
 inet_init()
Date: Thu, 23 Jul 2015 10:08:44 +0200
Message-ID: <20150723080844.GB22790@pox.localdomain>
References: <20150723115824.071b84ff@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150723115824.071b84ff@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the module_init() to a invocation from inet_init() since
ip_tunnel_core is part of the INET built-in.

Fixes: 3093fbe7ff4 ("route: Per route IP tunnel metadata via lightweight tunnel")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
Compiles for me with:
make ARCH=arm CROSS_COMPILE=arm-linux-gnu-

 include/net/ip_tunnels.h  |  2 ++
 net/ipv4/af_inet.c        |  3 +++
 net/ipv4/ip_tunnel_core.c | 11 +----------
 3 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index d975b3e..4798441 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -311,6 +311,8 @@ static inline int ip_tunnel_collect_metadata(void)
 	return static_key_false(&ip_tunnel_metadata_cnt);
 }
 
+void __init ip_tunnel_core_init(void);
+
 void ip_tunnel_need_metadata(void);
 void ip_tunnel_unneed_metadata(void);
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9532ee8..cc4e498 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -112,6 +112,7 @@
 #include <net/raw.h>
 #include <net/icmp.h>
 #include <net/inet_common.h>
+#include <net/ip_tunnels.h>
 #include <net/xfrm.h>
 #include <net/net_namespace.h>
 #include <net/secure_seq.h>
@@ -1780,6 +1781,8 @@ static int __init inet_init(void)
 
 	dev_add_pack(&ip_packet_type);
 
+	ip_tunnel_core_init();
+
 	rc = 0;
 out:
 	return rc;
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 630e6d5..5512f4e 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -292,19 +292,10 @@ static const struct lwtunnel_encap_ops ip_tun_lwt_ops = {
 	.get_encap_size = ip_tun_encap_nlsize,
 };
 
-static int __init ip_tunnel_core_init(void)
+void __init ip_tunnel_core_init(void)
 {
 	lwtunnel_encap_add_ops(&ip_tun_lwt_ops, LWTUNNEL_ENCAP_IP);
-
-	return 0;
-}
-module_init(ip_tunnel_core_init);
-
-static void __exit ip_tunnel_core_exit(void)
-{
-	lwtunnel_encap_del_ops(&ip_tun_lwt_ops, LWTUNNEL_ENCAP_IP);
 }
-module_exit(ip_tunnel_core_exit);
 
 struct static_key ip_tunnel_metadata_cnt = STATIC_KEY_INIT_FALSE;
 EXPORT_SYMBOL(ip_tunnel_metadata_cnt);
-- 
2.4.3
