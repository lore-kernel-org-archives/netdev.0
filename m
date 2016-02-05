From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] netfilter: tee: select NF_DUP_IPV6 unconditionally
Date: Fri,  5 Feb 2016 10:20:21 +0100
Message-ID: <1454664040-1344109-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The NETFILTER_XT_TARGET_TEE option selects NF_DUP_IPV6 whenever
IP6_NF_IPTABLES is enabled, and it ensures that it cannot be
builtin itself if NF_CONNTRACK is a loadable module, as that
is a dependency for NF_DUP_IPV6.

However, NF_DUP_IPV6 can be enabled even if IP6_NF_IPTABLES is
turned off, and it only really depends on IPV6. With the current
check in tee_tg6, we call nf_dup_ipv6() whenever NF_DUP_IPV6
is enabled. This can however be a loadable module which is
unreachable from a built-in xt_TEE:

net/built-in.o: In function `tee_tg6':
:(.text+0x67728): undefined reference to `nf_dup_ipv6'

The bug was originally introduced in the split of the xt_TEE module
into separate modules for ipv4 and ipv6, and two patches tried
to fix it unsuccessfully afterwards.

This is a revert of the the first incorrect attempt to fix it,
going back to depending on IPV6 as the dependency, and we
adapt the 'select' condition accordingly.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: bbde9fc1824a ("netfilter: factor out packet duplication for IPv4/IPv6")
Fixes: 116984a316c3 ("netfilter: xt_TEE: use IS_ENABLED(CONFIG_NF_DUP_IPV6)")
Fixes: 74ec4d55c4d2 ("netfilter: fix xt_TEE and xt_TPROXY dependencies")
---
 net/netfilter/Kconfig  | 2 +-
 net/netfilter/xt_TEE.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 8c067e6663a1..95e757c377f9 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -891,7 +891,7 @@ config NETFILTER_XT_TARGET_TEE
 	depends on IPV6 || IPV6=n
 	depends on !NF_CONNTRACK || NF_CONNTRACK
 	select NF_DUP_IPV4
-	select NF_DUP_IPV6 if IP6_NF_IPTABLES != n
+	select NF_DUP_IPV6 if IPV6
 	---help---
 	This option adds a "TEE" target with which a packet can be cloned and
 	this clone be rerouted to another nexthop.
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 3eff7b67cdf2..6e57a3966dc5 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -38,7 +38,7 @@ tee_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 	return XT_CONTINUE;
 }
 
-#if IS_ENABLED(CONFIG_NF_DUP_IPV6)
+#if IS_ENABLED(CONFIG_IPV6)
 static unsigned int
 tee_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
@@ -131,7 +131,7 @@ static struct xt_target tee_tg_reg[] __read_mostly = {
 		.destroy    = tee_tg_destroy,
 		.me         = THIS_MODULE,
 	},
-#if IS_ENABLED(CONFIG_NF_DUP_IPV6)
+#if IS_ENABLED(CONFIG_IPV6)
 	{
 		.name       = "TEE",
 		.revision   = 1,
-- 
2.7.0
