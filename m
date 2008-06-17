From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] bridge: fix IPV6=n build
Date: Tue, 17 Jun 2008 09:42:14 -0700
Message-ID: <20080617094214.c8cc2ce2.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, davem@davemloft.net
To: netdev <netdev@vger.kernel.org>, shemminger@linux-foundation.org
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix bridge netfilter code so that it uses CONFIG_IPV6 as needed:

net/built-in.o: In function `ebt_filter_ip6':
ebt_ip6.c:(.text+0x87c37): undefined reference to `ipv6_skip_exthdr'
net/built-in.o: In function `ebt_log_packet':
ebt_log.c:(.text+0x88dee): undefined reference to `ipv6_skip_exthdr'
make[1]: *** [.tmp_vmlinux1] Error 1

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/bridge/netfilter/Kconfig   |    2 +-
 net/bridge/netfilter/Makefile  |    2 +-
 net/bridge/netfilter/ebt_log.c |    2 ++
 3 files changed, 4 insertions(+), 2 deletions(-)

--- linux-next-20080617.orig/net/bridge/netfilter/Kconfig
+++ linux-next-20080617/net/bridge/netfilter/Kconfig
@@ -85,7 +85,7 @@ config BRIDGE_EBT_IP
 
 config BRIDGE_EBT_IP6
 	tristate "ebt: IP6 filter support"
-	depends on BRIDGE_NF_EBTABLES
+	depends on BRIDGE_NF_EBTABLES && IPV6
 	help
 	  This option adds the IP6 match, which allows basic IPV6 header field
 	  filtering.
--- linux-next-20080617.orig/net/bridge/netfilter/Makefile
+++ linux-next-20080617/net/bridge/netfilter/Makefile
@@ -14,7 +14,7 @@ obj-$(CONFIG_BRIDGE_EBT_802_3) += ebt_80
 obj-$(CONFIG_BRIDGE_EBT_AMONG) += ebt_among.o
 obj-$(CONFIG_BRIDGE_EBT_ARP) += ebt_arp.o
 obj-$(CONFIG_BRIDGE_EBT_IP) += ebt_ip.o
-obj-$(CONFIG_BRIDGE_EBT_IP) += ebt_ip6.o
+obj-$(CONFIG_BRIDGE_EBT_IP6) += ebt_ip6.o
 obj-$(CONFIG_BRIDGE_EBT_LIMIT) += ebt_limit.o
 obj-$(CONFIG_BRIDGE_EBT_MARK) += ebt_mark_m.o
 obj-$(CONFIG_BRIDGE_EBT_PKTTYPE) += ebt_pkttype.o
--- linux-next-20080617.orig/net/bridge/netfilter/ebt_log.c
+++ linux-next-20080617/net/bridge/netfilter/ebt_log.c
@@ -123,6 +123,7 @@ ebt_log_packet(unsigned int pf, unsigned
 		goto out;
 	}
 
+#if defined(CONFIG_BRIDGE_EBT_IP6) || defined(CONFIG_BRIDGE_EBT_IP6_MODULE)
 	if ((bitmask & EBT_LOG_IP6) && eth_hdr(skb)->h_proto ==
 	   htons(ETH_P_IPV6)) {
 		const struct ipv6hdr *ih;
@@ -146,6 +147,7 @@ ebt_log_packet(unsigned int pf, unsigned
 		print_ports(skb, nexthdr, offset_ph);
 		goto out;
 	}
+#endif
 
 	if ((bitmask & EBT_LOG_ARP) &&
 	    ((eth_hdr(skb)->h_proto == htons(ETH_P_ARP)) ||
