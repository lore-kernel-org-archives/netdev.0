From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] netfilter: fix xt_TEE and xt_TPROXY dependencies
Date: Tue, 10 Nov 2015 13:22:15 +0100
Message-ID: <8068952.JJURCanWFy@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kconfig is too smart for its own good: a Kconfig line that states

	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES

means that if IP6_NF_IPTABLES is set to 'm', then NF_DEFRAG_IPV6 will
also be set to 'm', regardless of the state of the symbol from which
it is selected. When the xt_TEE driver is built-in and nothing else
forces NF_DEFRAG_IPV6 to be built-in, this causes a link-time error:

net/built-in.o: In function `tee_tg6':
net/netfilter/xt_TEE.c:46: undefined reference to `nf_dup_ipv6'

This works around that behavior by changing the dependency to
'if IP6_NF_IPTABLES != n', which is interpreted as boolean expression
rather than a tristate and causes the NF_DEFRAG_IPV6 symbol to
be built-in as well.

The bug only occurs once in thousands of 'randconfig' builds and
does not really impact real users. From inspecting the other
surrounding Kconfig symbols, I am guessing that NETFILTER_XT_TARGET_TPROXY
and NETFILTER_XT_MATCH_SOCKET have the same issue. If not, this
change should still be harmless.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
I have done a few thousand randconfig builds with this applied, and the
problem did not come back, but it is super-rare.

Several people have tried to fix this in the past, but so far
every patch was wrong. Maybe this one is lucky.

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index e22349ea7256..4692782b5280 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -869,7 +869,7 @@ config NETFILTER_XT_TARGET_TEE
 	depends on IPV6 || IPV6=n
 	depends on !NF_CONNTRACK || NF_CONNTRACK
 	select NF_DUP_IPV4
-	select NF_DUP_IPV6 if IP6_NF_IPTABLES
+	select NF_DUP_IPV6 if IP6_NF_IPTABLES != n
 	---help---
 	This option adds a "TEE" target with which a packet can be cloned and
 	this clone be rerouted to another nexthop.
@@ -882,7 +882,7 @@ config NETFILTER_XT_TARGET_TPROXY
 	depends on IP6_NF_IPTABLES || IP6_NF_IPTABLES=n
 	depends on IP_NF_MANGLE
 	select NF_DEFRAG_IPV4
-	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
+	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES != n
 	help
 	  This option adds a `TPROXY' target, which is somewhat similar to
 	  REDIRECT.  It can only be used in the mangle table and is useful
@@ -1375,7 +1375,7 @@ config NETFILTER_XT_MATCH_SOCKET
 	depends on IPV6 || IPV6=n
 	depends on IP6_NF_IPTABLES || IP6_NF_IPTABLES=n
 	select NF_DEFRAG_IPV4
-	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
+	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES != n
 	help
 	  This option adds a `socket' match, which can be used to match
 	  packets for which a TCP or UDP socket lookup finds a valid socket.
