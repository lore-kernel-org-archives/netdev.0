From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/2] fou: add Kconfig options for IPv6 support
Date: Wed, 25 May 2016 16:50:46 +0200
Message-ID: <1464187873-219087-2-git-send-email-arnd@arndb.de>
References: <1464187873-219087-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464187873-219087-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A previous patch added the fou6.ko module, but that failed to link
in a couple of configurations:

net/built-in.o: In function `ip6_tnl_encap_add_fou_ops':
net/ipv6/fou6.c:88: undefined reference to `ip6_tnl_encap_add_ops'
net/ipv6/fou6.c:94: undefined reference to `ip6_tnl_encap_add_ops'
net/ipv6/fou6.c:97: undefined reference to `ip6_tnl_encap_del_ops'
net/built-in.o: In function `ip6_tnl_encap_del_fou_ops':
net/ipv6/fou6.c:106: undefined reference to `ip6_tnl_encap_del_ops'
net/ipv6/fou6.c:107: undefined reference to `ip6_tnl_encap_del_ops'

If CONFIG_IPV6=m, ip6_tnl_encap_add_ops/ip6_tnl_encap_del_ops
are in a module, but fou6.c can still be built-in, and that
obviously fails to link.

Also, if CONFIG_IPV6=y, but CONFIG_IPV6_TUNNEL=m or
CONFIG_IPV6_TUNNEL=n, the same problem happens for a different
reason.

This adds two new silent Kconfig symbols to work around both
problems:

- CONFIG_IPV6_FOU is now always set to 'm' if either CONFIG_NET_FOU=m
  or CONFIG_IPV6=m
- CONFIG_IPV6_FOU_TUNNEL is set implicitly when IPV6_FOU is enabled
  and NET_FOU_IP_TUNNELS is also turned out, and it will ensure
  that CONFIG_IPV6_TUNNEL is also available.

The options could be made user-visible as well, to give additional
room for configuration, but it seems easier not to bother users
with more choice here.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: aa3463d65e7b ("fou: Add encap ops for IPv6 tunnels")
---
 net/ipv6/Kconfig  | 9 +++++++++
 net/ipv6/Makefile | 2 +-
 net/ipv6/fou6.c   | 2 +-
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 3f8411328de5..994608263260 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -232,6 +232,15 @@ config IPV6_GRE
 
 	  Saying M here will produce a module called ip6_gre. If unsure, say N.
 
+config IPV6_FOU
+	tristate
+	default NET_FOU && IPV6
+
+config IPV6_FOU_TUNNEL
+	tristate
+	default NET_FOU_IP_TUNNELS && IPV6_FOU
+	select INET6_TUNNEL
+
 config IPV6_MULTIPLE_TABLES
 	bool "IPv6: Multiple Routing Tables"
 	select FIB_RULES
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 7ec3129c9ace..d42ca3d1197f 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -42,7 +42,7 @@ obj-$(CONFIG_IPV6_VTI) += ip6_vti.o
 obj-$(CONFIG_IPV6_SIT) += sit.o
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
 obj-$(CONFIG_IPV6_GRE) += ip6_gre.o
-obj-$(CONFIG_NET_FOU) += fou6.o
+obj-$(CONFIG_NET_FOU_IPV6_TUNNELS) += fou6.o
 
 obj-y += addrconf_core.o exthdrs_core.o ip6_checksum.o ip6_icmp.o
 obj-$(CONFIG_INET) += output_core.o protocol.o $(ipv6-offload)
diff --git a/net/ipv6/fou6.c b/net/ipv6/fou6.c
index c972d0b52579..9ea249b9451e 100644
--- a/net/ipv6/fou6.c
+++ b/net/ipv6/fou6.c
@@ -69,7 +69,7 @@ int gue6_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 }
 EXPORT_SYMBOL(gue6_build_header);
 
-#ifdef CONFIG_NET_FOU_IP_TUNNELS
+#if IS_ENABLED(CONFIG_IPV6_FOU_TUNNEL)
 
 static const struct ip6_tnl_encap_ops fou_ip6tun_ops = {
 	.encap_hlen = fou_encap_hlen,
-- 
2.7.0
