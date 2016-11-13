From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/39] udp: provide udp{4,6}_lib_lookup for nf_socket_ipv{4,6}
Date: Sun, 13 Nov 2016 23:25:08 +0100
Message-ID: <1479075933-4491-15-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47698 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964978AbcKMW0N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 17:26:13 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id EC32BB497D
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:11 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DCF1ADA851
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:11 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9B808DA80B
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:09 +0100 (CET)
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

Since commit ca065d0cf80f ("udp: no longer use SLAB_DESTROY_BY_RCU")
the udp6_lib_lookup and udp4_lib_lookup functions are only
provided when it is actually possible to call them.

However, moving the callers now caused a link error:

net/built-in.o: In function `nf_sk_lookup_slow_v6':
(.text+0x131a39): undefined reference to `udp6_lib_lookup'
net/ipv4/netfilter/nf_socket_ipv4.o: In function `nf_sk_lookup_slow_v4':
nf_socket_ipv4.c:(.text.nf_sk_lookup_slow_v4+0x114): undefined reference to `udp4_lib_lookup'

This extends the #ifdef so we also provide the functions when
CONFIG_NF_SOCKET_IPV4 or CONFIG_NF_SOCKET_IPV6, respectively
are set.

Fixes: 8db4c5be88f6 ("netfilter: move socket lookup infrastructure to nf_socket_ipv{4,6}.c")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/udp.c | 3 ++-
 net/ipv6/udp.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 195992e0440d..395361b1398e 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -580,7 +580,8 @@ EXPORT_SYMBOL_GPL(udp4_lib_lookup_skb);
  * Does increment socket refcount.
  */
 #if IS_ENABLED(CONFIG_NETFILTER_XT_MATCH_SOCKET) || \
-    IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TPROXY)
+    IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TPROXY) || \
+    IS_ENABLED(CONFIG_NF_SOCKET_IPV4)
 struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			     __be32 daddr, __be16 dport, int dif)
 {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index a7700bbf6788..3e232585b0ff 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -302,7 +302,8 @@ EXPORT_SYMBOL_GPL(udp6_lib_lookup_skb);
  * Does increment socket refcount.
  */
 #if IS_ENABLED(CONFIG_NETFILTER_XT_MATCH_SOCKET) || \
-    IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TPROXY)
+    IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TPROXY) || \
+    IS_ENABLED(CONFIG_NF_SOCKET_IPV6)
 struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be16 sport,
 			     const struct in6_addr *daddr, __be16 dport, int dif)
 {
-- 
2.1.4
