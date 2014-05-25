From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net-next] netfilter: bridge: fix Kconfig unmet dependencies
Date: Sun, 25 May 2014 14:48:33 +0200
Message-ID: <1401022113-6430-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35189 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751422AbaEYMsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 May 2014 08:48:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before f5efc69 ("netfilter: nf_tables: Add meta expression key for
bridge interface name"), the entire net/bridge/netfilter/ directory
depended on BRIDGE_NF_EBTABLES, ie. on ebtables. However, that
directory already contained the nf_tables bridge extension that
we should allow to compile separately. In f5efc69, we tried to
generalize this by using CONFIG_BRIDGE_NETFILTER which was not a good
idea since this option already existed and it is dedicated to enable
the Netfilter bridge IP/ARP filtering.

Let's try to fix this mess by:

1) making net/bridge/netfilter/ dependent on the toplevel
   CONFIG_NETFILTER option, just like we do with the net/netfilter and
   net/ipv{4,6}/netfilter/ directories.

2) Changing 'selects' to 'depends on' NETFILTER_XTABLES for
   BRIDGE_NF_EBTABLES. I believe this problem was already before
   f5efc69:

warning: (BRIDGE_NF_EBTABLES) selects NETFILTER_XTABLES which has
unmet direct dependencies (NET && INET && NETFILTER)

3) Fix ebtables/nf_tables bridge dependencies by making NF_TABLES_BRIDGE
   and BRIDGE_NF_EBTABLES dependent on BRIDGE and NETFILTER:

warning: (NF_TABLES_BRIDGE && BRIDGE_NF_EBTABLES) selects
BRIDGE_NETFILTER which has unmet direct dependencies (NET && BRIDGE &&
NETFILTER && INET && NETFILTER_ADVANCED)

net/built-in.o: In function `br_parse_ip_options':
br_netfilter.c:(.text+0x4a5ba): undefined reference to `ip_options_compile'
br_netfilter.c:(.text+0x4a5ed): undefined reference to `ip_options_rcv_srr'
net/built-in.o: In function `br_nf_pre_routing_finish':
br_netfilter.c:(.text+0x4a8a4): undefined reference to `ip_route_input_noref'
br_netfilter.c:(.text+0x4a987): undefined reference to `ip_route_output_flow'
make: *** [vmlinux] Error 1

Reported-by: Jim Davis <jim.epost@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
@David: Please, feel free to pick this fix into your net-next, it addresses
http://marc.info/?l=linux-netdev&m=140095588506382&w=2

 net/bridge/Makefile          |    2 +-
 net/bridge/netfilter/Kconfig |    7 ++-----
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/bridge/Makefile b/net/bridge/Makefile
index 906a18b..be68796 100644
--- a/net/bridge/Makefile
+++ b/net/bridge/Makefile
@@ -16,4 +16,4 @@ bridge-$(CONFIG_BRIDGE_IGMP_SNOOPING) += br_multicast.o br_mdb.o
 
 bridge-$(CONFIG_BRIDGE_VLAN_FILTERING) += br_vlan.o
 
-obj-$(CONFIG_BRIDGE_NETFILTER) += netfilter/
+obj-$(CONFIG_NETFILTER) += netfilter/
diff --git a/net/bridge/netfilter/Kconfig b/net/bridge/netfilter/Kconfig
index 3baf29d..629dc77 100644
--- a/net/bridge/netfilter/Kconfig
+++ b/net/bridge/netfilter/Kconfig
@@ -3,8 +3,7 @@
 #
 #
 menuconfig NF_TABLES_BRIDGE
-	depends on NF_TABLES
-	select BRIDGE_NETFILTER
+	depends on BRIDGE && NETFILTER && NF_TABLES
 	tristate "Ethernet Bridge nf_tables support"
 
 if NF_TABLES_BRIDGE
@@ -19,9 +18,7 @@ endif # NF_TABLES_BRIDGE
 
 menuconfig BRIDGE_NF_EBTABLES
 	tristate "Ethernet Bridge tables (ebtables) support"
-	depends on BRIDGE && NETFILTER
-	select BRIDGE_NETFILTER
-	select NETFILTER_XTABLES
+	depends on BRIDGE && NETFILTER && NETFILTER_XTABLES
 	help
 	  ebtables is a general, extensible frame/packet identification
 	  framework. Say 'Y' or 'M' here if you want to do Ethernet
-- 
1.7.10.4
