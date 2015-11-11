From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/10] netfilter: fix xt_TEE and xt_TPROXY dependencies
Date: Wed, 11 Nov 2015 18:33:41 +0100
Message-ID: <1447263223-22662-9-git-send-email-pablo@netfilter.org>
References: <1447263223-22662-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48403 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752641AbbKKRd7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2015 12:33:59 -0500
Received: from antivirus1-rhel7.int (antivirus1.int [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 6A4901392B4
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:58 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 593BC123030
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:58 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 73D7A4E0E0
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:56 +0100 (CET)
In-Reply-To: <1447263223-22662-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

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
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index e22349e..4692782 100644
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
-- 
2.1.4
